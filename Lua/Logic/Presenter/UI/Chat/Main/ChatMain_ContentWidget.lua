--------------------------------ChatItem--------------------------------
local ChatItem = class("ChatItem")
function ChatItem:ctor(trs)
	--组件
	self._transform = trs
	self._gameObject = trs.gameObject

	--变量
	self._isShowed = false
	self._data = nil
end

function ChatItem:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function ChatItem:Show(data)
	self._data = data
	self:SetVisible(true)
end

function ChatItem:Hide()
	self:SetVisible(false)
	self._data = nil
end
--------------------------------ChatItem--------------------------------

--------------------------------BaseChatItem--------------------------------
local BaseChatItem = class("BaseChatItem", ChatItem)
function BaseChatItem:ctor(trs, ui, eventIdBase, eventIdOffset)
	ChatItem.ctor(self, trs)

	self._ui = ui

	self._eventIdBase = eventIdBase
	self._eventIdOffset = eventIdOffset

	--基础部分占用10个id
	self._customOffset = 10

	self._widget = trs:GetComponent("UIWidget")

	--组件
	--头像
	self._headIcon = NGUITools.FindComponent(trs, "UITexture", "Base/HeadWrap/Head")
	--等级
	self._level = NGUITools.FindComponent(trs, "UILabel", "Base/Level")
	--房间标识
	self._roomIcon = NGUITools.FindComponent(trs, "UISprite", "Base/Room")
	self._roomIcon.gameObject:SetActive(false)
	--名字
	self._name = NGUITools.FindComponent(trs, "UILabel", "Base/Name")

	--loader
	self._texLoader = LoaderMgr.CreateTextureLoader(self._headIcon)

	--现在使用默认写死的头像
	self._resId = ResConfigData.GetResConfigID("icon_head_banmoying")
end

function BaseChatItem:Show(data)
	ChatItem.Show(self, data)

	self._level.text = self._data.msgCommon.sender.senderLevel
	--self._roomIcon.spriteName = tostring(self._data.msgCommon.roomType)
	self._name.text = self._data.msgCommon.sender.senderName
	--头像
	self._texLoader:LoadObject(self._resId)
end

function BaseChatItem:GetHeight()
	return self._widget.height
end

function BaseChatItem:OnClick(spanIdx)
	--判断点击头像，点击各种名字后面的图标
end

function BaseChatItem:OnLongPress(spanIdx)
end
--------------------------------BaseChatItem--------------------------------

--------------------------------CommonChatItem--------------------------------
local CommonChatItem = class("CommonChatItem", BaseChatItem)
function CommonChatItem:ctor(trs, ui, eventIdBase, eventIdOffset)
	BaseChatItem.ctor(self, trs, ui, eventIdBase, eventIdOffset)

	--组件
	self._uiEvent = trs:GetComponent("GameCore.UIEvent")
	self._uiEvent.id = eventIdBase + self._customOffset + 1

	--内容背景
	self._contentBg = NGUITools.FindComponent(trs, "UISprite", "ContentBg")
	--图文混排的根节点
	self._root = trs:Find("Content/Root")
	self._rootGo = NGUITools.FindGo(trs, "Content/Root")
	--自定义表情
	self._tex = NGUITools.FindComponent(trs, "UITexture", "tex")
	self._texTrs = self._tex.transform
    self._texGo = self._tex.gameObject

	--变量
	self._zeroPos = Vector3.zero
	--自定义表情限高100，宽度自适应
	self._texHeightLimit = 100
	self._texBgSize = { width = 100, height = 100 }

	--1普通聊天消息，2自定义表情消息
	self._msgType = 1

	--自定义表情独有
	self._picId = ""
	self._emojiInfo = nil
	--左或右
	self._leftRight = 1

	self._widgetDefaultHeight = 46
	self._contentBgDefaultWidth = 26
	self._contentBgDefaultHeight = 21
end

--[[
    @desc: 根据新消息，确定其msgType
]]
function CommonChatItem:InitMsgType()
	if MsgLinkHelper.CheckIsCustomEmoji(self._data.msgCommon) then
		self._msgType = 2
	else
		self._msgType = 1
	end
end

--[[
    @desc: 判定是左还是右
]]
function CommonChatItem:InitLeftOrRight()
	if self._data.isSelfMsg then
		self._leftRight = 2
	else
		self._leftRight = 1
	end
end

function CommonChatItem:Show(data)
	BaseChatItem.Show(self, data)

	self:InitMsgType()

	self:InitLeftOrRight()

	self._root.localPosition = self._zeroPos

	self._rootGo:SetActive(self._msgType == 1)
	self._texGo:SetActive(self._msgType == 2)
	if self._msgType == 1 then
		TextHelper.ProcessItemCommon(self._ui, self, self._data.msgCommon.content, 
		self._root, self._data.lineWidth, self._data.lineSpace, not self._data.isSelfMsg,
		self._data.msgCommon.links, nil, nil, nil, self._data.msgCommon.contentPrefix)

		--来自图文混排处理后的赋值
		self._contentBg.height = self.curHeight + self._contentBgDefaultHeight
		self._contentBg.width = self.curWidth + self._contentBgDefaultWidth
	elseif self._msgType == 2 then
		--自定义表情消息，自己处理其widget尺寸，不走图文混排接口
		--同时满足其上层ContentWidget的排序要求
		self._contentBg.height = self._texHeightLimit + self._contentBgDefaultHeight
		self._contentBg.width = self._texHeightLimit + self._contentBgDefaultWidth

		self._picId = MsgLinkHelper.GetPicIdByCustomEmojiMsg(self._data.msgCommon)
		self._emojiInfo = CustomEmojiMgr.GetEmojiFromChatMainByPicId(self._picId)
		UIUtil.LoadImage(self._tex, CustomEmojiMgr.GetEmojiSize(), self._emojiInfo:GetUrl(), true, self.OnLoadTex, self)
	end

	self._widget.height = self._contentBg.height + self._widgetDefaultHeight
end

function CommonChatItem:OnLoadTex()
	local w, h = UIUtil.AdjustTexByLen(self._tex, self._texHeightLimit, false)
	self._texBgSize.width = w
	self._texBgSize.height = h
	--自定义表情的widget尺寸，高度固定为100，动态调整宽度
	self._contentBg.width = w + self._contentBgDefaultWidth
end

--[[
    @desc: 检测鼠标是否在自定义表情区域
]]
function CommonChatItem:CheckIsInTex()
	local localPos = self._texTrs:InverseTransformPoint(UICamera.lastWorldPosition)
	if self._leftRight == 1 then
	elseif self._leftRight == 2 then
		localPos.x = localPos.x + self._texBgSize.width
	end
	localPos.y = localPos.y + self._texBgSize.height
	if 0 <= localPos.x and localPos.x <= self._texBgSize.width
		and 0 <= localPos.y and localPos.y <= self._texBgSize.height then
		--
		return true
	else
		return false
	end
end

--[[
    @desc: 点中自定义表情，处理
]]
function CommonChatItem:OnClickTex()
	if self._msgType ~= 2 then
		return
	end
	MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWEMOJIPIC, self._emojiInfo)
end

function CommonChatItem:OnClick(spanIdx)
	if spanIdx <= self._customOffset then
		BaseChatItem.OnClick(self, spanIdx)
	else
		spanIdx = spanIdx - self._customOffset

		if spanIdx == 1 then
			if self._msgType == 1 then
				local linkIdx = self.imageLabelContent:ProcessClick()
				if linkIdx then
					local linkData = self._data.msgCommon.links[linkIdx]
					if linkData then
						MsgLinkHelper.OnClick(linkData)
					end
				end
			elseif self._msgType == 2 then
				--自定义表情消息，自己处理点击，不走图文混排逻辑
				if self:CheckIsInTex() then
					self:OnClickTex()
				end
			end
		end
	end
end

function CommonChatItem:OnLongPress(spanIdx)
	if spanIdx <= self._customOffset then
		BaseChatItem.OnLongPress(self, spanIdx)
	else
		spanIdx = spanIdx - self._customOffset

		if spanIdx == 1 then
			if self._msgType ~= 2 then
				return
			end
			if self:CheckIsInTex() then
				--长按处理
				local localPos = self._texTrs.localPosition
				local localX = 0
				local localY = 0
				if self._leftRight == 1 then
					localX = localPos.x + self._texBgSize.width + 20
				elseif self._leftRight == 2 then
					localX = localPos.x + 20
				end
				localY = localPos.y - self._texBgSize.height / 2
				local pos = self._texTrs.parent:TransformPoint(localX, localY, 0)
				MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWEMOJIOPERLIST, pos, self._emojiInfo)
			end
		end
	end
end
--------------------------------CommonChatItem--------------------------------

--------------------------------VoiceChatItem--------------------------------
local VoiceChatItem = class("VoiceChatItem", BaseChatItem)
function VoiceChatItem:ctor(trs, ui, eventIdBase, eventIdOffset)
	BaseChatItem.ctor(self, trs, ui, eventIdBase, eventIdOffset)

	--组件
	self._iconUIEvent = NGUITools.FindComponent(trs, "GameCore.UIEvent", "icon")
	self._iconUIEvent.id = self._eventIdBase + self._customOffset + 1

	self._contentBg = NGUITools.FindComponent(trs, "UISprite", "ContentBg")

	self._sec = NGUITools.FindComponent(trs, "UILabel", "sec")
	self._secStr = "%d秒"
    --语音红点
    self._flagGo = NGUITools.FindGo(trs, "ani")
    self._label = NGUITools.FindComponent(trs, "UILabel", "label")

	--变量
	self._widgetDefaultHeight = 35
	self._contentBgDefaultHeight = 48

    --播放语音相关
    --语音文件本地下载路径，用于播放
    self._localPath = ""
end

function VoiceChatItem:Show(data)
    BaseChatItem.Show(self, data)

    --用第一个Int参数表示是否播放过该语音，控制红点显示逻辑
    --0表示没播放过，1表示播放过
	self._flagGo:SetActive(data.msgCommon.links[1].intParams[1] == 0)
	--用第二个Int参数表示语音长度	
	self._sec.text = string.format(self._secStr, data.msgCommon.links[1].intParams[2])
    
    self._localPath = data.msgCommon.links[1].strParams[2]

	self._label.text = self._data.msgCommon.content
	self._label:Update()
	self._contentBg.height = self._label.height + self._contentBgDefaultHeight

	self._widget.height = self._contentBg.height + self._widgetDefaultHeight
end

--[[
    @desc: 隐藏红点标识，由上层主动调用，前提是该item当前对应的msgcommon就是播完的那个
]]
function VoiceChatItem:HideVoiceFlag()
    self._flagGo:SetActive(false)
end

function VoiceChatItem:OnClick(spanIdx)
	if spanIdx <= self._customOffset then
		BaseChatItem.OnClick(self, spanIdx)
	else
		spanIdx = spanIdx - self._customOffset

		if spanIdx == 1 then
			--判断msgcommon是否播放过了，如果没有则启动自动播放，如果播放过了则单次播放
			if self._data.msgCommon.links[1].intParams[1] == 0 then
				--启动自动播放流程
				ChatMgr.StartAutoPlayChatVoice(self._data.msgCommon)
			else
				--单次播放
				ChatMgr.PlayChatVoice(self._data.msgCommon)
			end
		end
	end
end

function VoiceChatItem:OnLongPress(spanIdx)
	if spanIdx <= self._customOffset then
		BaseChatItem.OnLongPress(self, spanIdx)
	else
		spanIdx = spanIdx - self._customOffset
	end
end
--------------------------------VoiceChatItem--------------------------------

--------------------------------LeftItem--------------------------------
local LeftItem = class("LeftItem")
function LeftItem:ctor(trs, ui, eventIdBase, eventIdOffset)
	--组件
	self._transform = trs
	self._gameObject = trs.gameObject

	self._widget = trs:GetComponent("UIWidget")

	self._itemTypeList = {}
	self._itemTypeList[Chat_pb.ChatContentStyle_Common] = CommonChatItem
	self._itemTypeList[Chat_pb.ChatContentStyle_Voice] = VoiceChatItem
	self._itemNameList = {}
	self._itemNameList[Chat_pb.ChatContentStyle_Common] = "Common"
	self._itemNameList[Chat_pb.ChatContentStyle_Voice] = "Voice"

	self._eventIdDataList = {}

	self._eventIdBase = eventIdBase
	self._eventIdOffset = eventIdOffset
	--每种样式分配50个id，可以容纳eventIdOffset/_eventIdSpan个样式
	self._eventIdSpan = 50

	self._itemList = {}
	--上述ChatContentStyle枚举并没有按照严格自增顺序，所以使用pairs
	for idx, item in pairs(self._itemTypeList) do
		local trs = trs:Find(self._itemNameList[idx])
		local eventId = eventIdBase + (idx - 1) * self._eventIdSpan
		self._eventIdDataList[idx] = { eventIdBase = (idx - 1) * self._eventIdSpan, eventIdOffset = self._eventIdSpan }
		self._itemList[idx] = item.new(trs, ui, eventId, self._eventIdSpan)
	end

	--变量
	self._isShowed = false
	self._proxyItem = nil
	self._data = nil
end

function LeftItem:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function LeftItem:Hide()
	self:SetVisible(false)
end

function LeftItem:HideAllItem()
	for _, item in pairs(self._itemList) do
		item:Hide()
	end
end

--[[
    @desc: 根据消息数据类型，确定是哪种item
]]
function LeftItem:ResetProxyItem()
	self._proxyItem = self._itemList[self._data.msgCommon.contentStyle]
end

function LeftItem:Show(data)
	self._data = data
	self:SetVisible(true)

	--先隐藏所有的区域
	self:HideAllItem()
	
	--再选择其中某些特定区域显示刷新
	self:ResetProxyItem()
	if self._proxyItem then
		self._proxyItem:Show(data)

		self._widget.height = self._proxyItem:GetHeight()
	end
end

function LeftItem:GetHeight()
	return self._widget.height
end

--[[
    @desc: 计算spanIdx
    --@eventId: 
]]
function LeftItem:CalSpanIdx(eventId)
	local spanIdx = -1

	local idData = self._eventIdDataList[self._data.msgCommon.contentStyle]
	if idData then
		spanIdx = eventId - idData.eventIdBase
	end

	return spanIdx
end

--[[
    @desc: 
    --@eventId: 从底层传递上来已经减去了baseid
]]
function LeftItem:OnClick(eventId)
	local spanIdx = self:CalSpanIdx(eventId)
	if spanIdx ~= -1 then
		self._proxyItem:OnClick(spanIdx)
	else
		--报错
	end
end

--[[
    @desc: 
    --@eventId: 从底层传递上来已经减去了baseid
]]
function LeftItem:OnLongPress(eventId)
	local spanIdx = self:CalSpanIdx(eventId)
	if spanIdx ~= -1 then
		self._proxyItem:OnLongPress(spanIdx)
	else
		--报错
	end	
end

--[[
    @desc: 调用内部的某个item的方法
    --@funcName:
	--@args: 
]]
function LeftItem:InvokeFunc(funcName, ...)
	if self._proxyItem[funcName] then
		self._proxyItem[funcName](self._proxyItem, ...)
	end
end
--------------------------------LeftItem--------------------------------

--------------------------------RightItem--------------------------------
local RightItem = class("RightItem", LeftItem)
function RightItem:ctor(trs, ui, eventIdBase, eventIdSpan)
	LeftItem.ctor(self, trs, ui, eventIdBase, eventIdSpan)

	--组件

	--变量
end
--------------------------------RightItem--------------------------------

--------------------------------NoneItem--------------------------------
local NoneItem = class("NoneItem")
function NoneItem:ctor(trs, ui, eventIdBase, eventIdOffset)
	--组件
	self._ui = ui
	self._transform = trs
	self._gameObject = trs.gameObject

	self._eventIdBase = eventIdBase
	self._eventIdOffset = eventIdOffset

	self._widget = trs:GetComponent("UIWidget")

	self._root = trs:Find("Content/Root")
	self._uiEvent = trs:GetComponent("GameCore.UIEvent")
	self._uiEvent.id = eventIdBase + 1

	--变量
	self._isShowed = false
	self._data = {}
	self._zeroPos = Vector3.zero

	self:Hide()
end

function NoneItem:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function NoneItem:Show(data)
	self._data = data
	self:SetVisible(true)

	self._root.localPosition = self._zeroPos

	TextHelper.ProcessItemCommon(self._ui, self, self._data.msgCommon.content, 
	self._root, self._data.lineWidth, self._data.lineSpace, true,
	self._data.msgCommon.links, nil, nil, nil, self._data.msgCommon.contentPrefix)

	self._widget.height = self.curHeight + 10
end

function NoneItem:GetHeight()
	return self._widget.height
end

function NoneItem:Hide()
	self:SetVisible(false)
	self._data = {}
end

function NoneItem:OnClick(spanIdx)
	if spanIdx == 1 then
		--图文混排的根节点
		local linkIdx = self.imageLabelContent:ProcessClick()
		if linkIdx then
			local linkData = self._data.msgCommon.links[linkIdx]
			if linkData then
				MsgLinkHelper.OnClick(linkData)
			end
		end
	end
end
--------------------------------NoneItem--------------------------------

--------------------------------ContentItem--------------------------------
local ContentItem = class("ContentItem")
--给ContentItem里可能的样式划分枚举
ContentItem.Style_Null = -1
ContentItem.Style_Left = 1
ContentItem.Style_Right = 2
ContentItem.Style_None = 3
function ContentItem:ctor(trs, eventIdBase, eventIdOffset, ui)
	--组件
	self._ui = ui
	self._transform = trs
	self._gameObject = trs.gameObject

	--来自上层的分配
	self._eventIdBase = eventIdBase
	self._eventIdOffset = eventIdOffset

	self._widget = trs:GetComponent("UIWidget")

	self._itemTypeList = {}
	self._itemTypeList[ContentItem.Style_Left] = LeftItem
	self._itemTypeList[ContentItem.Style_Right] = RightItem
	self._itemTypeList[ContentItem.Style_None] = NoneItem
	self._itemNameList = {}
	self._itemNameList[ContentItem.Style_Left] = "Left"
	self._itemNameList[ContentItem.Style_Right] = "Right"
	self._itemNameList[ContentItem.Style_None] = "None"

	--不均等划分uieventid
	self._eventIdDataList = 
	{
		[ContentItem.Style_Left] = { eventIdBase = eventIdBase + 0, eventIdOffset = 400 },
		[ContentItem.Style_Right] = { eventIdBase = 0, eventIdOffset = 400 },
		[ContentItem.Style_None] = { eventIdBase = 0, eventIdOffset = 1 },
	}
	for idx = 2, #self._eventIdDataList do
		local preData = self._eventIdDataList[idx - 1]
		self._eventIdDataList[idx].eventIdBase = preData.eventIdBase + preData.eventIdOffset
	end

	self._itemList = {}
	self._style = ContentItem.Style_Null
	self._proxyItem = nil

	for idx, item in ipairs(self._itemTypeList) do
		local itemName = self._itemNameList[idx]
		local idData = self._eventIdDataList[idx]
		self._itemList[idx] = item.new(trs:Find(itemName), self._ui, idData.eventIdBase, idData.eventIdOffset)
	end

	--变量
	self._isShowed = false
	self._data = {}

	self._maxNoHeadLineWidth = 432
	self._maxHasHeadLineWidth = 312
	self._maxLineSpace = 0

	self:Hide()
end

function ContentItem:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function ContentItem:HideAll()
	for _, item in ipairs(self._itemList) do
		item:Hide()
	end
	self._style = ContentItem.Style_Null
end

function ContentItem:Reset()
	self:HideAll()
	self._data = {}
end

function ContentItem:Show(msgCommon)
	self._data.msgCommon = msgCommon
	self:SetVisible(true)

	--处理msgCommon
	self._data.isPlayerMsg = self._data.msgCommon.roomType ~= Chat_pb.CHAT_ROOM_SYSTEM
	self._data.isSelfMsg = self._data.msgCommon.sender.senderID == tostring(UserData.PlayerID)
	self._data.isSysMsg = self._data.msgCommon.roomType == Chat_pb.CHAT_ROOM_SYSTEM
	if self._data.isPlayerMsg then
		self._data.lineWidth = self._maxHasHeadLineWidth
	elseif self._data.isSysMsg then
		self._data.lineWidth = self._maxNoHeadLineWidth
	end
	self._data.lineSpace = self._maxLineSpace

	--判断是left,none,right哪种样式的item，然后交给对应item显示
	self:HideAll()

	if self._data.isPlayerMsg then
		if self._data.isSelfMsg then
			self._style = ContentItem.Style_Right
		else
			self._style = ContentItem.Style_Left
		end
	elseif self._data.isSysMsg then
		self._style = ContentItem.Style_None
	end

	self._proxyItem = self._itemList[self._style]
	if self._proxyItem then
		self._proxyItem:Show(self._data)
		self._widget.height = self._proxyItem:GetHeight()
	end
end

function ContentItem:Hide()
	self:SetVisible(false)
	self:Reset()
end

--[[
    @desc: 计算spanIdx
    --@eventId: 
]]
function ContentItem:CalSpanIdx(eventId)
	local spanIdx = -1

	local idData = self._eventIdDataList[self._style]
	if idData then
		spanIdx = eventId - idData.eventIdBase
	end
	
	return spanIdx
end

function ContentItem:OnClick(eventId)
	local spanIdx = self:CalSpanIdx(eventId)
	if spanIdx ~= -1 then
		self._proxyItem:OnClick(spanIdx)
	else
		--报错
	end
end

function ContentItem:OnLongPress(eventId)
	local spanIdx = self:CalSpanIdx(eventId)
	if spanIdx ~= -1 then
		self._proxyItem:OnLongPress(spanIdx)
	else
		--报错
	end
end

function ContentItem:GetMsgCommon()
    return self._data.msgCommon
end

--[[
    @desc: 调用内部的某个item的方法
    --@funcName:
	--@args: 
]]
function ContentItem:InvokeFunc(funcName, ...)
	if self._proxyItem["InvokeFunc"] then
		self._proxyItem["InvokeFunc"](self._proxyItem, funcName, ...)
	end
end
--------------------------------ContentItem--------------------------------

--------------------------------ContentWidget--------------------------------
local ContentWidget = class("ContentWidget")
function ContentWidget:ctor(trs, ui, eventIdBase, funcOnLockStateChange)
	--组件
	self._ui = ui
	self._transform = trs
	self._gameObject = trs.gameObject

	self._itemTemp = trs:Find("ItemPrefab")
	self._itemTemp.gameObject:SetActive(false)
	self._tableTrs = trs:Find("ContentText/ScrollView/Table")

	--变量
	self._isShowed = false
	self._msgCommonList = {}
	--循环使用的item数组
	self._contentItemList = {}
	self._eventIdBase = eventIdBase
	self._maxContentItemNum = 30

	--每个ContentItem分配_eventIdSpan个eventId
	self._eventIdSpan = 1000

	--待做项
	--房间消息上限处理

	self:InitItemPrefab()
	self._loopScrollViewEx = ui:FindComponent("LoopScrollViewEx", "Offset/ContentRoot/ContentText/ScrollView/Table")
	self._loopScrollViewEx:Init()
	self._loopScrollViewEx:InitGoList()
	self._funcOnItemChange = LoopScrollViewEx.OnItemChange(self.OnItemChange, self)
	self._funcOnLockStateChange = funcOnLockStateChange
	self._loopScrollViewEx:SetDelegate(self._funcOnItemChange, self._funcOnLockStateChange)
	self._loopScrollViewEx:InitAlign(1)

	self:Hide()
end

function ContentWidget:InitItemPrefab()
	local trs = nil
	local eventId = nil
	for idx = 1, self._maxContentItemNum do
		trs = self._ui:DuplicateAndAdd(self._itemTemp, self._tableTrs, 0)
		trs.name = tostring(idx - 1)
		eventId = self._eventIdBase + (idx - 1) * self._eventIdSpan
		--每一个ContentItem的eventid区间为左开右闭
		self._contentItemList[idx] = ContentItem.new(trs, eventId, self._eventIdSpan, self._ui)
	end
end

function ContentWidget:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

--[[
    @desc: 播放语音通知，检查ContentItem，隐藏红点
    --@msgCommon: 
]]
function ContentWidget:OnPlayVoice(msgCommon)
    for _, item in ipairs(self._contentItemList) do
        if item:GetMsgCommon() == msgCommon then
            item:InvokeFunc("HideVoiceFlag")
            break
        end
    end
end

function ContentWidget:RegEvent()
    GameEvent.Reg(EVT.CHAT, EVT.CHAT_PLAYVOICE, self.OnPlayVoice, self)
end

function ContentWidget:UnRegEvent()
    GameEvent.UnReg(EVT.CHAT, EVT.CHAT_PLAYVOICE, self.OnPlayVoice, self)
end

--[[
    @desc: 跟随UI的OnEnable方法
]]
function ContentWidget:OnEnable()
	self:RegEvent()
end

--[[
    @desc: 跟随UI的OnDisable方法
]]
function ContentWidget:OnDisable()
    self:UnRegEvent()
    
    --关闭界面，停止语音
    ChatMgr.StopAutoPlayChatVoice()
    ChatMgr.StopChatVoice()
end

--[[
    @desc: 跟随UI的OnDestroy方法
]]
function ContentWidget:OnDestroy()

end

--[[
    @desc: 计算一个eventId落在哪个ContentItem下，并且是哪个spanIdx
    --@eventId: 
]]
function ContentWidget:CalItemIdx(eventId)
	eventId = eventId - self._eventIdBase - 1
	local quotient = math.floor(eventId / self._eventIdSpan)
    local itemIdx = quotient + 1
    return itemIdx
end

--[[
    @desc: 
    --@eventId: 来自C#端的UIEvent.id
]]
function ContentWidget:OnClick(eventId)
	local itemIdx = self:CalItemIdx(eventId)
	local contentItem = self._contentItemList[itemIdx]
	if contentItem then
		--抛给ContentItem真正处理文本点击，根据LinkData类型，做出响应
		contentItem:OnClick(eventId)
	end
end

function ContentWidget:OnLongPress(eventId)
	local itemIdx = self:CalItemIdx(eventId)
	local contentItem = self._contentItemList[itemIdx]
	if contentItem then
		contentItem:OnLongPress(eventId)
	end
end

function ContentWidget:OnItemChange(go, realIdx, wrapIdx)
	local msgCommon = self._msgCommonList[realIdx + 1]
	local contentItem = self._contentItemList[wrapIdx + 1]
	if contentItem and msgCommon then
		contentItem:Show(msgCommon)
	end
end

--[[
    @desc: 刷新接口
    --@refreshAll: 是否全刷新
]]
function ContentWidget:UpdateChatList(refreshAll)
	self._loopScrollViewEx:Refresh(#self._msgCommonList, 100, refreshAll, false)
end

--[[
    @desc: 切换房间时，从ChatMgr获取消息列表，并调用该方法
    --@msgCommonList: Chat.ChatMsgCommon结构数组
]]
function ContentWidget:Show(msgCommonList)
	self._msgCommonList = msgCommonList
    self:SetVisible(true)
    
    --重置自动播放语音状态
    ChatMgr.StopAutoPlayChatVoice()
    ChatMgr.StopChatVoice()

	self:UpdateChatList(true)
end

--[[
    @desc: 
    --@msgCommon: Chat.ChatMsgCommon结构，一条房间消息对应的结构体，适用于单条刷新
]]
function ContentWidget:Update(msgCommon)
    self:UpdateChatList(false)
    
    --判断如果是语音则自动播放
    if msgCommon.contentStyle == Chat_pb.ChatContentStyle_Voice then

    end
end

--[[
    @desc: 锁屏结束后，全刷新方法
]]
function ContentWidget:UpdateForUnlock()
	self:UpdateChatList(true)
end

--[[
    @desc: 跳转到聊天的@消息处
    --@idx: 聊天消息在self._msgCommonList里的索引，从0开始的
]]
function ContentWidget:JumpToAt(idx)
	--self._loopScrollViewEx:JumpToAt(idx, #self._msgCommonList, true, 100)
end

function ContentWidget:Hide()
	self:SetVisible(false)
end

--[[
    @desc: 返回loopex组件
]]
function ContentWidget:GetLoopScrollViewEx()
	return self._loopScrollViewEx
end

return ContentWidget
--------------------------------ContentWidget--------------------------------