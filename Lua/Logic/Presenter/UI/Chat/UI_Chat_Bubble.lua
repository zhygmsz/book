module("UI_Chat_Bubble", package.seeall)

--组件
local mSelf
local mOffset
local mBubbleItemTemp

--变量
--气泡缓存池
local mChatBubbleItemList = {}
local mBubbleIdx = 0
--正在显示的气泡
local mShowingBubbleItemList = {}

local mMsgWrap = MsgCommonWrap.new()

local ChatBubbleItem = class("ChatBubbleItem")
function ChatBubbleItem:ctor(ui, path, funcOnEnd)
    --组件
    self._transform = ui:Find(path)
    self._gameObject = ui:FindGo(path)

    self._ui = ui
    path = path .. "/"
    self._path = path

    self._offset = ui:Find(path .. "Offset")
    self._root = ui:Find(path .. "Offset/Content/Root")
    self._rootWidget = ui:FindComponent("UIWidget", path .. "Offset/Content/Root")
    self._bg = ui:FindComponent("UISprite", path .. "Offset/Bg")

    self._funcOnEnd = funcOnEnd

    --变量
    self._isShowed = false
    self._localPos = Vector3.zero
    self._offsetPos = Vector3.zero
    self._localOffsetPos = Vector3.zero
    self._followID = nil
    self._msgCommon = nil
    self._timerId = nil
    self._duration = 6
    self._zeroPos = Vector3.zero
    self._lineWidth = 200
    self._lineSpace = 0
end

function ChatBubbleItem:Show(msgCommon)
    self._gameObject:SetActive(true)
    self._isShowed = true
    self._msgCommon = msgCommon

    self._root.localPosition = self._zeroPos

	TextHelper.ProcessItemCommon(self._ui, self, msgCommon.content, 
	self._root, self._lineWidth, self._lineSpace, true,
    msgCommon.links, nil, nil, nil, msgCommon.contentPrefix)
    
    self._rootWidget.width = self.curWidth
    self._rootWidget.height = self.curHeight

    self:InitOffset()
    self:SetFollow()

    self._timerId = GameTimer.AddTimer(self._duration, 1, self.OnShowEnd, self)

    local playerId = tonumber(msgCommon.sender.senderID)
    mShowingBubbleItemList[playerId] = self
end

function ChatBubbleItem:OnShowEnd()
    self:Hide()

    local playerId = tonumber(self._msgCommon.sender.senderID)
    mShowingBubbleItemList[playerId] = nil

    --结束后，调用外部回调，告知上层自己结束了
    if self._funcOnEnd then
        self._funcOnEnd(self)
    end
end

function ChatBubbleItem:InitOffset()
    self._bg:Update()
    self._localPos.x = -(self._bg.width / 2)
    self._localPos.y = self._bg.height
    self._offset.localPosition = self._localPos
end

function ChatBubbleItem:SetFollow()
    local player = MapMgr.GetPlayer(self._msgCommon.sender.senderID)
    --在上层逻辑里已经判断了当前该玩家是否可见，这里保证player不为nil
    local followTarget = player:GetModelComponent():GetEntityRoot()
    self._offsetPos.y = player:GetPropertyComponent():GetHeight()
    self._localOffsetPos.y = 40
    local hpNameItem = HpNameMgr.GetHpNameItemByEntity(player)
    if hpNameItem then
        local hpNameLocalOffset = hpNameItem:GetLocalOffset()
        self._localOffsetPos.y = self._localOffsetPos.y + hpNameLocalOffset.y
    end
    self._followID = GameUIFollow.AddFollow(followTarget, self._transform, self._offsetPos, self._localOffsetPos)
end

function ChatBubbleItem:Reset()
    if self._timerId then
        GameTimer.DeleteTimer(self._timerId)
        self._timerId = nil
    end
    if self._followID then
        GameUIFollow.RemoveFollow(self._followID)
        self._followID = nil
    end
end

function ChatBubbleItem:Hide()
    self._gameObject:SetActive(false)
    self._isShowed = false

    self:Reset()
end

function ChatBubbleItem:IsShowed()
    return self._isShowed
end

--local方法
local function OnItemShowEnd(bubbleItem)
    mChatBubbleItemList[#mChatBubbleItemList + 1] = bubbleItem
end

local function CreateBubbleItem()
    local trs = mSelf:DuplicateAndAdd(mBubbleItemTemp, mOffset, 0)
    mBubbleIdx = mBubbleIdx + 1
    trs.name = "BubbleItem" .. tostring(mBubbleIdx)
    local item = ChatBubbleItem.new(mSelf, "Offset/BubbleItem" .. tostring(mBubbleIdx), OnItemShowEnd, mBubbleIdx)
    return item
end

local function GetBubbleItem()
    local item = mChatBubbleItemList[#mChatBubbleItemList]
    if item then
        mChatBubbleItemList[#mChatBubbleItemList] = nil
    else
        item = CreateBubbleItem()
    end

    return item
end

--[[
    @desc: 语音的特殊改造，创建新的，保留旧的
    --@msgCommon: 
]]
local function PreVoiceFlag(msgCommon)
    mMsgWrap:ResetMsgCommon()
    mMsgWrap:ResetRoomType(msgCommon.roomType)

    local link = mMsgWrap:CreateMsgLink()
    MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.EMOJI, link, "914", -1)
    mMsgWrap:TryAppendMsgLink(link)

    mMsgWrap:TryAppendStr(msgCommon.content)

    return mMsgWrap:GetMsgCommon()
end

--[[
    @desc: 接收到新消息
    --@msgCommon: 
]]
local function OnReceiveChatMsg(msgCommon)
    if msgCommon.roomType ~= Chat_pb.CHAT_ROOM_SCENE then
        return
    end

    --判断该玩家是否可见
    local player = MapMgr.GetPlayer(msgCommon.sender.senderID)
    if not player then
        return
    end

    --先检查该玩家头顶是否已经有显示的气泡
    local playerId = tonumber(msgCommon.sender.senderID)

    --如果是语音，则需要改造msgcommon
    if msgCommon.contentStyle == Chat_pb.ChatContentStyle_Voice then
        msgCommon = PreVoiceFlag(msgCommon)
    end
    if mShowingBubbleItemList[playerId] then
        local item = mShowingBubbleItemList[playerId]
        item:Reset()
        item:Show(msgCommon)
    else
        local item = GetBubbleItem()
        item:Show(msgCommon)
    end
end

local function RegEvent()
    GameEvent.Reg(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, OnReceiveChatMsg)
end

local function UnRegEvent()
    GameEvent.UnReg(EVT.CHAT, EVT.CHAT_ROOM_NEWMSG, OnReceiveChatMsg)
end


function OnCreate(self)
    mSelf = self

    mOffset = self:Find("Offset")
    mBubbleItemTemp = self:Find("Offset/BubbleTemp")
    mBubbleItemTemp.gameObject:SetActive(false)

end

function OnEnable(self)
    RegEvent()
end

function OnDisable(self)
    UnRegEvent()
end

function OnDestroy(self)

end