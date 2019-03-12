module("UI_Chat_Main", package.seeall)

local ChatInputWrap = require("Logic/Presenter/UI/Chat/ChatInputWrap")
local ContentWidget = require("Logic/Presenter/UI/Chat/Main/ChatMain_ContentWidget")

--组件
local mSelf

--HoverRoot
local mAtInfoGo
local mAutoPlayToggle
local mVoiceConfigGo

--InputRoot
local mLuaUIInput
local mChatInputWrap
local mCanInputGo
local mCanNotInputGo
local mPersonToggle
local mSysToggle
--聊天输入最大数量限制，读表
local mInputLimitCount = 50

--ContentRoot
local mContentRoot
local mContentWidget

local mToggleItemGroup

local mNotReadGo
local mNotReadLbl

local mLoopScrollViewEx

local mHotWordGo
local mEasyWordLoopEx
local mInputHistoryLoopEx

--变量
local mRoomBtnDataList =
{
	{ eventId = Chat_pb.CHAT_ROOM_WORLD, content = "世界" },
	{ eventId = Chat_pb.CHAT_ROOM_TEAM, content = "队伍" },
	{ eventId = Chat_pb.CHAT_ROOM_GANG, content = "帮会" },
	{ eventId = Chat_pb.CHAT_ROOM_PROFESSION, content = "门派" },
	{ eventId = Chat_pb.CHAT_ROOM_SCENE, content = "当前" },
	{ eventId = Chat_pb.CHAT_ROOM_NEW, content = "新手" },
	{ eventId = Chat_pb.CHAT_ROOM_CITY, content = "同城" },
	{ eventId = Chat_pb.CHAT_ROOM_SYSTEM, content = "系统" },
}
local mCurRoomType = -1

--常量
local mContentWidgetEventBaseId = 10000;

local mEasyWordEventBaseId = 500
local mInputHistoryEventBaseId = 600

local mNotReadStr = "未读消息%d条"

--聊天列表是否处于锁屏状态
local mChatListIsLock = false
--处于锁屏状态下，积攒的聊天消息
local mChatListNotReadNum = 0

local mEasyWordItemList = {}
local mEasyWordDataList = {}
local mInputHistoryItemList = {}
local mInputHistoryDataList = {}

--记录语音按钮的按下状态
local mVoiceBtnPressed = false

--便捷用语发送专用MsgCommon
local mEasyWordMsgCommon = Chat_pb.ChatMsgCommon()
mEasyWordMsgCommon.contentStyle = Chat_pb.ChatContentStyle_Common

--输入历史发送专用MsgCommon
local mInputHistoryMsgCommon = Chat_pb.ChatMsgCommon()
mInputHistoryMsgCommon.contentStyle = Chat_pb.ChatContentStyle_Common

local EasyWordItem = class("EasyWordItem")
function EasyWordItem:ctor(trs, eventId)
	--组件
	self._transform = trs
	self._gameObject = trs.gameObject

	self._widget = trs:GetComponent("UIWidget")
	self._uiEvent = trs:GetComponent("GameCore.UIEvent")
	self._uiEvent.id = eventId
	self._label = NGUITools.FindComponent(trs, "UILabel", "Value")

	--变量
	self._data = nil
end

function EasyWordItem:Show(data)
	self._data = data

	self._label.text = data.content
end

function EasyWordItem:GetData()
	return self._data
end

local InputHistoryItem = class("InputHistoryItem")
function InputHistoryItem:ctor(trs, eventId)
	--组件
	self._transform = trs
	self._gameObject = trs.gameObject

	self._root = trs:Find("Content/Root")

	--变量
	self._pos = Vector3(-105, 14, 0)
    self._labelPos = Vector3(0, -14, 0)
    self._lineWidth = 210
	self._lineSpace = 100
	
	self._data = nil
end

function InputHistoryItem:Show(data)
	self._data = data

	self._root.localPosition = self._pos

    local ui = AllUI.UI_Chat_Main.csScript
	TextHelper.ProcessItemCommon(ui, self, data.content, 
	self._root, self._lineWidth, self._lineSpace, true,
    data.links, nil, nil, nil, data.contentPrefix)

    --修改label位置
    local label = self._transform:Find("Content/Root/label")
    if not tolua.isnull(label) then
        label.localPosition = self._labelPos
    end
end

function InputHistoryItem:GetData()
	return self._data
end


--local方法
local function CheckVoiceConfigGoVisible(id)
	if not id then
		return false
	end
	return id == Chat_pb.CHAT_ROOM_TEAM or id == Chat_pb.CHAT_ROOM_GANG
end

local function CheckCanInputGoVisible(id)
	if not id then
		return false
	end
	if id == Chat_pb.CHAT_ROOM_WORLD or id == Chat_pb.CHAT_ROOM_TEAM 
		or id == Chat_pb.CHAT_ROOM_GANG or id == Chat_pb.CHAT_ROOM_PROFESSION 
		or id == Chat_pb.CHAT_ROOM_SCENE or id == Chat_pb.CHAT_ROOM_NEW 
		or id == Chat_pb.CHAT_ROOM_CITY then
		return true
	else
		return false
	end
end

local function CheckCanNotInputGoVisible(id)
	if not id then
		return false
	end
	return id == Chat_pb.CHAT_ROOM_SYSTEM
end

local function ResetVisible(id)
	mVoiceConfigGo:SetActive(CheckVoiceConfigGoVisible(id))
	mCanInputGo:SetActive(CheckCanInputGoVisible(id))
	mCanNotInputGo:SetActive(CheckCanNotInputGoVisible(id))
end

--[[
    @desc: 测试跳转到@条目
    --@startIdx: 消息数据列表的索引，从0开始
]]
local function OnJumpToAt(idx)
	mContentWidget:JumpToAt(idx)
end

--[[
    @desc: 增加一条未读消息，自动显示出现
]]
local function AddNotReadNum()
	mChatListNotReadNum = mChatListNotReadNum + 1
	mNotReadGo:SetActive(true)
	mNotReadLbl.text = string.format(mNotReadStr, mChatListNotReadNum)
end

local function HideNotRead()
	mNotReadGo:SetActive(false)
	mChatListNotReadNum = 0
end

--[[
    @desc: 重置锁屏状态
]]
local function ResetNotRead()
	mChatListIsLock = false
	mChatListNotReadNum = 0
	mNotReadGo:SetActive(false)
end

--[[
    @desc: 新收到的都是房间消息ChatMsgCommon
    --@msgData: 
]]
local function OnNewMsg(msgData)
	if not msgData or msgData.roomType ~= mCurRoomType then
		return
	end

	--待做项
	--频道说话CD，说话权限，说话消耗

	if mChatListIsLock then
		--锁屏下，更新未读消息数目，并拦截后面的刷新逻辑
		AddNotReadNum()
		return
	end

	--如果当前是系统频道，则判断是否勾选了个人
	if msgData.roomType == Chat_pb.CHAT_ROOM_SYSTEM then
		if mPersonToggle.value then
			if ChatMgr.IsPersonMsg(msgData.sysMsgType) then
				mContentWidget:Update(msgData)
			end
		else
			mContentWidget:Update(msgData)	
		end
	else
		--新消息类型为当前选中的房间，则刷新content区域
		--原则上，新消息往wrap组件的头部插入并刷新位置即可，wrap组件应支持各种非重刷的接口
		mContentWidget:Update(msgData)
	end
end

local function CheckIsRoomBtn(id)
	local isRoomBtn = false

	for _, data in ipairs(mRoomBtnDataList) do
		if data.eventId == id then
			isRoomBtn = true
			break
		end
	end

	return isRoomBtn
end

--[[
    @desc: 个人和系统toggle变更回调
]]
local function OnPerAndSysToggleChange()
	local msgList = nil

	if mSysToggle.value and mPersonToggle.value then
		--同时勾选，用房间消息列表
		msgList = ChatMgr.GetRoomMsgList(mCurRoomType)
	else
		if mSysToggle.value then
			--单独显示系统类
			msgList = ChatMgr.GetSystomSysMsgList()
		elseif mPersonToggle.value then
			--单独显示个人类
			msgList = ChatMgr.GetPersonSysMsgList()
		end
	end
	
	if msgList then
		mContentWidget:Show(msgList)
	end

	--保存记录
	ChatMgr.SetSysToggleValue(mSysToggle.value)
	ChatMgr.SetPersonToggleValue(mPersonToggle.value)
end

local function OnRoomBtnNor(eventId)
end

local function OnRoomBtnSpec(eventId)
	if not eventId then
		return
	end

	--房间切换，并同步给mChatInputWrap
	mCurRoomType = eventId
	mChatInputWrap:ResetRoomType(mCurRoomType)

	--处理其他组件可见性
	ResetVisible(mCurRoomType)

	--重置锁屏状态
	ResetNotRead()

	--重刷content区域
	if mCurRoomType == Chat_pb.CHAT_ROOM_SYSTEM then
		OnPerAndSysToggleChange()
	else
		local msgList = ChatMgr.GetRoomMsgList(mCurRoomType)
		if msgList then
			mContentWidget:Show(msgList)
		end
	end
end

--[[
    @desc: 点击未读消息
]]
local function OnClickNotRead()
	mChatListIsLock = false
	HideNotRead()
	mContentWidget:UpdateForUnlock()
end

local function OnLockStateChange(lock)
	if lock then
		--锁屏
		mChatListIsLock = true
	else
		--解锁
		mChatListIsLock = false
		if mChatListNotReadNum > 0 then
			mContentWidget:UpdateForUnlock()
			HideNotRead()
		end
	end
end

local function OnEasyWordItemChange(go, realIdx, wrapIdx)
	local item = mEasyWordItemList[wrapIdx + 1]
	local data = mEasyWordDataList[realIdx + 1]
	if item and data then
		item:Show(data)
	end
end

local function OnInputHistoryItemChange(go, realIdx, wrapIdx)
	local item = mInputHistoryItemList[wrapIdx + 1]
	local data = mInputHistoryDataList[realIdx + 1]
	if item and data then
		item:Show(data)
	end
end

local function ShowHotWord()
	mHotWordGo:SetActive(true)

	mEasyWordDataList = ChatMgr.GetEasyWordListNoAdd()
	mInputHistoryDataList = ChatMgr.GetInputHistoryList()

	mEasyWordLoopEx:Refresh(#mEasyWordDataList, -1, true, true)
	mInputHistoryLoopEx:Refresh(#mInputHistoryDataList, -1, true, true)
end

local function HideHotWord()
	mHotWordGo:SetActive(false)
end

--[[
    @desc: 点击便捷用语
]]
local function OnClickEasyWord(itemIdx)
	local item = mEasyWordItemList[itemIdx]
	if not item then
		return
	end
	local data = item:GetData()
	--发送消息
	mEasyWordMsgCommon.roomType = mCurRoomType
	ChatMgr.SetSenderInfo(mEasyWordMsgCommon.sender)
	mEasyWordMsgCommon.content = data.content
	ChatMgr.RequestSendRoomMessage(mCurRoomType, "", Chat_pb.CHATMSG_COMMON, mEasyWordMsgCommon:SerializeToString())

	HideHotWord()
end

--[[
    @desc: 点击输入历史
]]
local function OnClickInputHistory(itemIdx)
	local item = mInputHistoryItemList[itemIdx]
	if not item then
		return
	end
	local data = item:GetData()
	--发送消息
	mInputHistoryMsgCommon:ParseFrom(data)
	--重新修改房间类型和样式
	mInputHistoryMsgCommon.roomType = mCurRoomType
	mInputHistoryMsgCommon.contentStyle = Chat_pb.ChatContentStyle_Common
	ChatMgr.SetSenderInfo(mInputHistoryMsgCommon.sender)
	ChatMgr.RequestSendRoomMessage(mCurRoomType, "", Chat_pb.CHATMSG_COMMON, mInputHistoryMsgCommon:SerializeToString())

	HideHotWord()
end

local function RegEvent(self)
	GameEvent.Reg(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, OnNewMsg)
	GameEvent.Reg(EVT.CHAT, EVT.CHAT_JUMPTOAT, OnJumpToAt)
end

local function UnRegEvent(self)
	GameEvent.UnReg(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, OnNewMsg)
	GameEvent.UnReg(EVT.CHAT, EVT.CHAT_JUMPTOAT, OnJumpToAt)
end


function OnCreate(self)
	mSelf = self

	--RoomRoot
	mToggleItemGroup = ToggleItemGroup.new(OnRoomBtnNor, OnRoomBtnSpec)
	local trs = nil
	for idx, data in ipairs(mRoomBtnDataList) do
		trs = self:Find("Offset/RoomRoot/btn" .. tostring(idx))
		mToggleItemGroup:AddItem(trs, data)
	end

	--HoverRoot
	mAtInfoGo = self:Find("Offset/HoverRoot/AtInfo").gameObject
	mAtInfoGo:SetActive(false)
	mAutoPlayToggle = self:FindComponent("UIToggle", "Offset/HoverRoot/AutoPlay")
	mVoiceConfigGo = self:Find("Offset/HoverRoot/VoiceConfig").gameObject
	mVoiceConfigGo:SetActive(false)

	--InputRoot
	mLuaUIInput = self:FindComponent("LuaUIInput", "Offset/InputRoot/CanInput/InputRoot/Input")
	mChatInputWrap = ChatInputWrap.new(mLuaUIInput, ChatMgr.CommonLinkOpenType.FromChat)
	mChatInputWrap:ResetMsgCommon()
	mChatInputWrap:ResetLimitCount(mInputLimitCount)
	mChatInputWrap:ResetRoomType(Chat_pb.CHAT_ROOM_WORLD)

	--默认显示输入框状态
	mCanInputGo = self:Find("Offset/InputRoot/CanInput").gameObject
	mCanInputGo:SetActive(true)
	mCanNotInputGo = self:Find("Offset/InputRoot/CanNotInput").gameObject
	mPersonToggle = self:FindComponent("UIToggle", "Offset/InputRoot/CanNotInput/Self")
	mPersonToggle.value = ChatMgr.GetPersonToggleValue()
	EventDelegate.Set(mPersonToggle.onChange, EventDelegate.Callback(OnPerAndSysToggleChange))
	mSysToggle = self:FindComponent("UIToggle", "Offset/InputRoot/CanNotInput/System")
	mSysToggle.value = ChatMgr.GetSysToggleValue()
	--自动触发事件问题
	EventDelegate.Set(mSysToggle.onChange, EventDelegate.Callback(OnPerAndSysToggleChange))
	mCanNotInputGo:SetActive(false)

	--ContentRoot
	local funcOnLockStateChange = System.Action_bool(OnLockStateChange)
	mContentRoot = self:Find("Offset/ContentRoot")
	mContentWidget = ContentWidget.new(mContentRoot, mSelf, mContentWidgetEventBaseId, funcOnLockStateChange)

	mNotReadGo = self:FindGo("Offset/HoverRoot/NotRead")
	mNotReadGo:SetActive(false)
	mNotReadLbl = self:FindComponent("UILabel", "Offset/HoverRoot/NotRead/Name")

	mLoopScrollViewEx = mContentWidget:GetLoopScrollViewEx()

	mHotWordGo = self:FindGo("Offset/HotWord")
	mEasyWordLoopEx = self:FindComponent("LoopScrollViewEx", "Offset/HotWord/EasyWord/widget/scrollview/Table")
	mEasyWordLoopEx:SetDelegate(LoopScrollViewEx.OnItemChange(OnEasyWordItemChange))
	mEasyWordLoopEx:InitAlign(0)
	mInputHistoryLoopEx = self:FindComponent("LoopScrollViewEx", "Offset/HotWord/History/widget/scrollview/Table")
	mInputHistoryLoopEx:SetDelegate(LoopScrollViewEx.OnItemChange(OnInputHistoryItemChange))
	mInputHistoryLoopEx:InitAlign(0)
	local trs = nil
	local eventId = nil
	local easyPath = "Offset/HotWord/EasyWord/widget/scrollview/Table/%d"
	local inputPath = "Offset/HotWord/History/widget/scrollview/Table/%d"
	for idx = 1, 10 do
		eventId = mEasyWordEventBaseId + idx
		trs = self:Find(string.format(easyPath, idx - 1))
		mEasyWordItemList[idx] = EasyWordItem.new(trs, eventId)

		eventId = mInputHistoryEventBaseId + idx
		trs = self:Find(string.format(inputPath, idx - 1))
		mInputHistoryItemList[idx] = InputHistoryItem.new(trs, eventId)
	end
	mHotWordGo:SetActive(false)
end

function OnEnable(self)
	RegEvent(self)

	mContentWidget:OnEnable()

	local targetRoomType = ChatMgr.GetTargetRoomType()
	mToggleItemGroup:OnClick(targetRoomType)

	UIMgr.ShowUI(AllUI.UI_Chat_AddBtnList)
	UIMgr.ShowUI(AllUI.UI_Chat_EmojiOperList)
	UIMgr.ShowUI(AllUI.UI_Chat_EmojiPic)
end

function OnDisable(self)
	UnRegEvent(self)

	mContentWidget:OnDisable()

	UIMgr.UnShowUI(AllUI.UI_Chat_AddBtnList)
	UIMgr.UnShowUI(AllUI.UI_Chat_EmojiOperList)
	UIMgr.UnShowUI(AllUI.UI_Chat_EmojiPic)

	mToggleItemGroup:ClearCurEventId(true)
end

function OnDestroy(self)
	mContentWidget:OnDestroy()
end

function OnPress(press,id)
	if id == 11 then
		mVoiceBtnPressed = press

		if press then
			ChatMgr.StartRecord(mCurRoomType)
		else
			ChatMgr.StopRecord()
		end
	end
end

function OnLongPress(id)
	if id > mContentWidgetEventBaseId then
		mContentWidget:OnLongPress(id)
	end
end

function OnDrag(delta,id)
end

function OnClick(go,id)
	if id == -100 then
		--关闭
		UIMgr.UnShowUI(AllUI.UI_Chat_Main);
	elseif id == 1 or id == 5 then	
		--千里传音、多彩气泡、红包
		local function OnPaintFinish(paintData)
			ChatMgr.RequestSendPaintMessage(paintData);
			UIMgr.UnShowUI(AllUI.UI_Chat_Paint);
		end
		UI_Chat_Paint.OpenForDraw(OnPaintFinish);
	elseif id == 2 then
		--热词
		ShowHotWord()
	elseif id == 3 then
		--链接
		mChatInputWrap:OnLinkBtnClick()
	elseif id == 4 then
		--发送
		--目前能通过该按钮发出去的都是普通类型
		mChatInputWrap:ResetContentStyle(Chat_pb.ChatContentStyle_Common)
		mChatInputWrap:OnSendBtnClick()
	elseif id == 6 then
		--设置
	elseif id == 7 then
		--@列表
	elseif id == 8 then
		--关闭@提示
	elseif id == 9 then
		--未读消息
		OnClickNotRead()
	elseif id == 10 then
		--热词快捷界面Mask
		HideHotWord()
	elseif id == 11 then
		--语音按钮
	elseif CheckIsRoomBtn(id) then
		--roombtn
		mToggleItemGroup:OnClick(id)
	elseif mEasyWordEventBaseId < id and id <= mInputHistoryEventBaseId then
		--便捷用语
		OnClickEasyWord(id - mEasyWordEventBaseId)
	elseif mInputHistoryEventBaseId < id and id <= mContentWidgetEventBaseId then
		--输入历史
		OnClickInputHistory(id - mInputHistoryEventBaseId)
	elseif id > mContentWidgetEventBaseId then
		--点击聊天文本
		mContentWidget:OnClick(id)
	end
end

function OnDragOver(id)
	if id == 11 and mVoiceBtnPressed then
		ChatMgr.PrepareCancel(false)
	end
end

function OnDragOut(id)
	if id == 11 and mVoiceBtnPressed then
		ChatMgr.PrepareCancel(true)
	end
end
