MainUIChat = class("MainUIChat")

local ContentItem = class("ContentItem")
function ContentItem:ctor(ui, path, eventId)
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._uiEvent = ui:FindComponent("GameCore.UIEvent", path)
	self._uiEvent.id = eventId
	self._widget = ui:FindComponent("UIWidget", path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._root = ui:Find(path .. "Content/Root")

	self._zeroPos = Vector3.zero
	self._lineWidth = 430
	self._lineSpace = 0
	
	self._msgCommon = nil
	self._isShowed = false

	self:Hide()
end

function ContentItem:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function ContentItem:Show(msgCommon)
	self:SetVisible(true)
	self._msgCommon = msgCommon

	--图文混排
	self._root.localPosition = self._zeroPos

	TextHelper.ProcessItemCommon(self._ui, self, msgCommon.content, 
	self._root, self._lineWidth, self._lineSpace, true,
	msgCommon.links, nil, nil, nil, msgCommon.contentPrefix)

	self._widget.height = self.curHeight + 5
end

function ContentItem:Hide()
	self:SetVisible(false)
end

function ContentItem:OnClick()
	local linkIdx = self.imageLabelContent:ProcessClick()
	if linkIdx > 0 then
		local linkData = self._msgCommon.links[linkIdx]
		--过滤某些类型超链接，在这里不作点击响应，当做点击背景处理
		if linkData then
			if linkData.linkType == Chat_pb.ChatMsgLink.EMOJI
			or linkData.linkType == Chat_pb.ChatMsgLink.PLAYER then
				ChatMgr.OpenChatUI(self._msgCommon.roomType)
			else
				MsgLinkHelper.OnClick(linkData)
			end
		else
			ChatMgr.OpenChatUI(self._msgCommon.roomType)
		end
	else
		--没点中超链接则当做点击背景处理，并跳转到对应的房间类型
		ChatMgr.OpenChatUI(self._msgCommon.roomType)
	end
end



function MainUIChat:ctor(uiFrame)
	self._uiFrame = uiFrame
    self._MIN_SIZE = 120
	self._MAX_SIZE = 180

	self._bg = uiFrame:FindComponent("UISprite", "Bottom/Chat/Bg")
	self._dragParent = uiFrame:FindComponent("UIWidget", "Bottom/Chat/DragParent")
	self._dragPanel = uiFrame:FindComponent("UIPanel", "Bottom/Chat/DragParent/DragScrollView")
	self._dragPanelTrs = uiFrame:Find("Bottom/Chat/DragParent/DragScrollView")
	self._dirSprite = uiFrame:FindComponent("UISprite", "Bottom/Chat/HoverPanel/Direction")

	--新消息提示
	self._newMsgTips = uiFrame:FindGo("Bottom/Chat/BtnChatTips")
	self._newMsgTips:SetActive(false)
	--新@提示
	self._newMsgAtTips = uiFrame:FindGo("Bottom/Chat/BtnChatAtTips")
	self._newMsgAtTips:SetActive(false)

	self._msgWrap = MsgCommonWrap.new()

	self._baseClipRegion = Vector4(0, 0, 462, 104)
	self._minTablePos = Vector3(-220, 52, 0)
	self._maxTablePos = Vector3(-220, 80, 0)

	self._msgCommonList = {}
	self._contentItemList = {}
	self._chatItemEventIdBase = 150
	self._maxContentItemNum = 10

	self._zero3 = Vector3.zero
	self._zero2 = Vector2.zero

	self._MAX_CHAT_COUNT = ConfigData.GetIntValue("chat_max_count_mainui")

	self:InitItemPrefab()
	self._loopScrollViewEx = uiFrame:FindComponent("LoopScrollViewEx", "Bottom/Chat/DragParent/DragScrollView/Table")
	self._funcOnItemChange = LoopScrollViewEx.OnItemChange(self.OnItemChange, self)
	self._loopScrollViewEx:SetDelegate(self._funcOnItemChange)
	self._loopScrollViewEx:InitAlign(1)
	self._tableTrs = uiFrame:Find("Bottom/Chat/DragParent/DragScrollView/Table")

	--语音输入按钮选择
	self._voiceListGo = uiFrame:FindGo("Bottom/Chat/BtnVoices")
	self._voiceLabel = uiFrame:FindComponent("UILabel", "Bottom/Chat/BtnMac/label")
	self._voice2RoomData = {}
	local roomTypeList = 
	{
		--队伍
		Chat_pb.CHAT_ROOM_TEAM,
		--帮会
		Chat_pb.CHAT_ROOM_GANG,
		--世界
		Chat_pb.CHAT_ROOM_WORLD,
	}
	local roomNameList = { "队", "帮", "世" }
	--语音按钮偏移
	self._voiceBtnBase = 130
	local label = nil
	local path = nil
	local uiEvent = nil
	for idx = 1, 3 do
		path = string.format("Bottom/Chat/BtnVoices/BtnMac0%d", idx)
		uiEvent = uiFrame:FindComponent("GameCore.UIEvent", path)
		uiEvent.id = self._voiceBtnBase + idx
		self._voice2RoomData[idx] = { roomType = roomTypeList[idx], roomName = roomNameList[idx] }
	end

	self._voiceArrowSp = uiFrame:FindComponent("UISprite", "Bottom/Chat/ArrowBtn")

	self._curVoiceRoomType = -1

	--记录语音按钮的按下状态
	self._voiceBtnPressed = false
end

function MainUIChat:InitItemPrefab()
	local trs = nil
	local eventId = nil
	local pathTemp = nil
	for idx = 1, self._maxContentItemNum do
		eventId = self._chatItemEventIdBase + idx
		pathTemp = "Bottom/Chat/DragParent/DragScrollView/Table/" .. tostring(idx - 1)
		trs = self._uiFrame:Find(pathTemp)
		self._contentItemList[idx] = ContentItem.new(self._uiFrame, pathTemp, eventId)
	end
end

function MainUIChat:OnItemChange(go, realIdx, wrapIdx)
	local msgCommon = self._msgCommonList[realIdx + 1]
	local contentItem = self._contentItemList[wrapIdx + 1]
	if contentItem and msgCommon then
		contentItem:Show(msgCommon)
	end
end

function MainUIChat:UpdateChatList(refreshAll)
	self._loopScrollViewEx:Refresh(#self._msgCommonList, 100, refreshAll, false)
end

--[[
    @desc: 获取房间图标和玩家名字处理后的msgcommon
    --@msgCommon: 
]]
function MainUIChat:PreRoomIconAndPlayerName(msgCommon)
	self._msgWrap:ResetMsgCommon()
	self._msgWrap:ResetRoomType(msgCommon.roomType)
	
	local link = self._msgWrap:CreateMsgLink()
	MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.EMOJI, link, tostring(msgCommon.roomType), -1)
	self._msgWrap:TryAppendMsgLink(link)

	link = self._msgWrap:CreateMsgLink()
	local playerId = tonumber(msgCommon.sender.senderID)
	local playerName = msgCommon.sender.senderName
	MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.PLAYER, link, playerId, playerName)
	self._msgWrap:TryAppendMsgLink(link)
end

--[[
    @desc: Chat_pb.ChatContentStyle_Common类型
    --@msgCommon: 
]]
function MainUIChat:CommonStyle(msgCommon)
	self._msgWrap:TryAppendMsgCommon(msgCommon)
end

--[[
    @desc: Chat_pb.ChatContentStyle_Voice类型
    --@msgCommon: 
]]
function MainUIChat:VoiceStyle(msgCommon)
	local link = self._msgWrap:CreateMsgLink()
	MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.EMOJI, link, "914", -1)
	self._msgWrap:TryAppendMsgLink(link)

	self._msgWrap:TryAppendStr(msgCommon.content)
end

--[[
    @desc: Chat_pb.ChatContentStyle_Common类型
    --@msgCommon: 
]]
function MainUIChat:CustomEmojiStyle(msgCommon)
	
end

function MainUIChat:OnReceiveChatMsg(msgCommon)
	--根据设置界面过滤
	if not ChatMgr.GetSettingText(msgCommon.roomType) then
		return
	end

	if msgCommon.roomType == Chat_pb.CHAT_ROOM_SYSTEM then
		--系统房间消息，不用额外包装处理
		table.insert(self._msgCommonList, msgCommon)
	else
		--非Chat_pb.CHAT_ROOM_SYSTEM
		--共用处理
		self:PreRoomIconAndPlayerName(msgCommon)

		if msgCommon.contentStyle == Chat_pb.ChatContentStyle_Voice then
			--语音消息
			self:VoiceStyle(msgCommon)
		elseif msgCommon.contentStyle == Chat_pb.ChatContentStyle_Emoji then
			--自定义图片
			self:CustomEmojiStyle(msgCommon)
		elseif msgCommon.contentStyle == Chat_pb.ChatContentStyle_Common then
			--普通消息，使用图文混排
			self:CommonStyle(msgCommon)
		end

		local newMsg = self._msgWrap:GetMsgCommon()
		table.insert(self._msgCommonList, newMsg)
	end

	self:Update(msgCommon)
end

function MainUIChat:RegEvent()
	GameEvent.Reg(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, self.OnReceiveChatMsg, self)
end

function MainUIChat:UnRegEvent()
	GameEvent.UnReg(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, self.OnReceiveChatMsg, self)
end

function MainUIChat:OnEnable()
	self:RegEvent()

	--初始化聊天气泡
	UIMgr.ShowUI(AllUI.UI_Chat_Bubble)

	--初始化本UI
	self:ResetFrameSize(false)
	self:SetVoiceListVisible(false)
	self:SetRoomType(1)
end

function MainUIChat:Update(msgCommon)
	self:UpdateChatList(false)
end

function MainUIChat:OnDisable()
	self:UnRegEvent()
end

function MainUIChat:OnDestroy()
	
end

function MainUIChat:ResetFrameSize(isMax)
	self._bg.height = isMax and self._MAX_SIZE or self._MIN_SIZE
	self._dirSprite.flip = isMax and UIBasicSprite.Flip.Vertically or UIBasicSprite.Flip.Nothing
	self._tableTrs.localPosition = isMax and self._maxTablePos or self._minTablePos
	self._dragParent:Update()
	self._baseClipRegion.w = self._dragParent.height
	self._dragPanel.baseClipRegion = self._baseClipRegion

	self._dragPanelTrs.localPosition = self._zero3
	self._dragPanel.clipOffset = self._zero2

	self:UpdateChatList(true)
end

function MainUIChat:SetVoiceListVisible(visible)
	if visible then
		self._voiceArrowSp.flip = UIBasicSprite.Flip.Vertically
		self._voiceListGo:SetActive(true)
	else
		self._voiceArrowSp.flip = UIBasicSprite.Flip.Nothing
		self._voiceListGo:SetActive(false)
	end
end

function MainUIChat:SetRoomType(idx)
	self._curVoiceRoomType = self._voice2RoomData[idx].roomType
	self._voiceLabel.text = self._voice2RoomData[idx].roomName
end

function MainUIChat:OnPress(id,press)
	if id == 102 then
		self._voiceBtnPressed = press

		if press then
			ChatMgr.StartRecord(self._curVoiceRoomType)
		else
			ChatMgr.StopRecord()
		end
	end
end

function MainUIChat:OnClick(id)
    if id == 100 then
        --聊天背景大小变化
        self:ResetFrameSize(self._bg.height == self._MIN_SIZE)
    elseif id == 101 then
    elseif id == 102 then
        --录音
	elseif id == 103 then
		--设置
		UIMgr.ShowUI(AllUI.UI_Chat_Setting)
    elseif id == 104 then
        --弹出聊天界面 
		ChatMgr.OpenChatUI()
	elseif id == 105 then
		--新消息提示
	elseif id == 106 then
		--新@提示
	elseif id == 107 then
		--语音频道切换箭头
		if self._voiceArrowSp.flip == UIBasicSprite.Flip.Nothing then
			self:SetVoiceListVisible(true)
		else
			self:SetVoiceListVisible(false)
		end
	elseif self._voiceBtnBase < id and id < self._chatItemEventIdBase then
		--语音按钮列表
		self:SetRoomType(id - self._voiceBtnBase)
		self:SetVoiceListVisible(false)
	elseif id > self._chatItemEventIdBase then
		local idx = id - self._chatItemEventIdBase
		local contentItem = self._contentItemList[idx]
		if contentItem then
			contentItem:OnClick()
		end
    end
end

function MainUIChat:OnDragOver(id)
	if id == 102 and self._voiceBtnPressed then
		ChatMgr.PrepareCancel(false)
	end
end

function MainUIChat:OnDragOut(id)
	if id == 102 and self._voiceBtnPressed then
		ChatMgr.PrepareCancel(true)
	end	
end

return MainUIChat 