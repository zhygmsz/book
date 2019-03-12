module("UI_Chat_Setting", package.seeall)

--组件
local mSelf
local mTopToggleGroup


--变量
local mTopBtnNum = 3
local mTopEventIdBase = 0
local mTopBtnDataList =
{
    {eventId = mTopEventIdBase + 1, content = "频道设置"},
    {eventId = mTopEventIdBase + 2, content = "@我的信息"},
    {eventId = mTopEventIdBase + 3, content = "屏蔽列表"}
}

local mSettingEventIdBase = 100
local mWidgetList = {}

local SettingWidget = class("SettingWidget")
function SettingWidget:ctor(ui, path, eventIdBase)
    --组件
    self._transform = ui:Find(path)
    self._gameObject = ui:FindGo(path)

    self._eventIdBase = eventIdBase

    self._ui = ui
    path = path .. "/"
    self._path = path

    self._BtnTemp = ui:Find(path .. "BtnTemp")
    self._textGrid = ui:FindComponent("UIGrid", path .. "Grid1")
    self._textGridTrs = ui:Find(path .. "Grid1")
    self._voiceGrid = ui:FindComponent("UIGrid", path .. "Grid2")
    self._voiceGridTrs = ui:Find(path .. "Grid2")

    --变量
    self._isShowed = false
    self._btnNum = 8
    self._btnDataList = 
    {
        { content = "世界频道", roomType = Chat_pb.CHAT_ROOM_WORLD },
        { content = "队伍频道", roomType = Chat_pb.CHAT_ROOM_TEAM },
        { content = "帮会频道", roomType = Chat_pb.CHAT_ROOM_GANG },
        { content = "门派频道", roomType = Chat_pb.CHAT_ROOM_PROFESSION },
        { content = "当前频道", roomType = Chat_pb.CHAT_ROOM_SCENE },
        { content = "新手频道", roomType = Chat_pb.CHAT_ROOM_NEW },
        { content = "同城频道", roomType = Chat_pb.CHAT_ROOM_CITY },
        { content = "系统频道", roomType = Chat_pb.CHAT_ROOM_SYSTEM },
    }

    self._textEventIdBase = 0
    self._voiceEventIdBase = 10
    
    self._textToggleList = {}
    self._voiceToggleList = {}
    self._voiceOnlyWifi = nil
    self._voiceAll = nil
    self._voice2Text = nil

    self:Init()
end

function SettingWidget:Init()
    local trs = nil
    local label = nil
    local labelPath = nil
    local uiEvent = nil
    local toggle = nil
    local cb = EventDelegate.Callback(self.OnTextToggleChange, self)
    self._BtnTemp.gameObject:SetActive(true)
    for idx = 1, self._btnNum do
        trs = self._ui:DuplicateAndAdd(self._BtnTemp, self._textGridTrs, 0)
        trs.name = "btn" .. tostring(idx)
        labelPath = string.format("Grid1/btn%s/Label", idx)
        label = self._ui:FindComponent("UILabel", self._path .. labelPath)
        label.text = self._btnDataList[idx].content
        uiEvent = trs:GetComponent("GameCore.UIEvent")
        uiEvent.id = self._eventIdBase + self._textEventIdBase  + idx
        toggle = trs:GetComponent("UIToggle")
        EventDelegate.Set(toggle.onChange, cb)
        self._textToggleList[idx] = toggle

        trs = self._ui:DuplicateAndAdd(self._BtnTemp, self._voiceGridTrs, 0)
        trs.name = "btn" .. tostring(idx)
        labelPath = string.format("Grid2/btn%s/Label", idx)
        label = self._ui:FindComponent("UILabel", self._path .. labelPath)
        label.text = self._btnDataList[idx].content
        uiEvent = trs:GetComponent("GameCore.UIEvent")
        uiEvent.id = self._eventIdBase + self._voiceEventIdBase  + idx
        toggle = trs:GetComponent("UIToggle")
        EventDelegate.Set(toggle.onChange, cb)
        self._voiceToggleList[idx] = toggle
    end
    self._BtnTemp.gameObject:SetActive(false)
    self._textGrid:Reposition()
    self._voiceGrid:Reposition()

    toggle = NGUITools.FindComponent(self._transform, "UIToggle", "BtnOnly")
    EventDelegate.Set(toggle.onChange, cb)
    self._voiceOnlyWifi = toggle

    toggle = NGUITools.FindComponent(self._transform, "UIToggle", "BtnAll")
    EventDelegate.Set(toggle.onChange, cb)
    self._voiceAll = toggle

    toggle = NGUITools.FindComponent(self._transform, "UIToggle", "BtnWord")
    EventDelegate.Set(toggle.onChange, cb)
    self._voice2Text = toggle
end

function SettingWidget:OnTextToggleChange()
    local btnData = nil
    local flag = nil
    for idx, toggle in ipairs(self._textToggleList) do
        btnData = self._btnDataList[idx]
        flag = toggle.value
        UserData.SetChatSetting(ChatMgr.TextSettingKey .. btnData.roomType, flag)
        ChatMgr.SetSettingText(btnData.roomType, flag)
    end
    for idx, toggle in ipairs(self._voiceToggleList) do
        btnData = self._btnDataList[idx]
        flag = toggle.value
        UserData.SetChatSetting(ChatMgr.VoiceSettingKey .. btnData.roomType, flag)
        ChatMgr.SetSettingVoice(btnData.roomType, flag)
    end
    
    if self._voiceOnlyWifi.value then
        UserData.SetChatSetting(ChatMgr.WifiSettingKey, true)
        UserData.SetChatSetting(ChatMgr.AllSettingKey, false)
        ChatMgr.SetWifiOrAll(1)
    elseif self._voiceAll.value then
        UserData.SetChatSetting(ChatMgr.AllSettingKey, true)
        UserData.SetChatSetting(ChatMgr.WifiSettingKey, false)
        ChatMgr.SetWifiOrAll(2)
    end

    flag = self._voice2Text.value
    UserData.SetChatSetting(ChatMgr.Text2VoiceSettingKey, flag)
    ChatMgr.SetVoice2Text(flag)
end

function SettingWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function SettingWidget:Show()
    self:SetVisible(true)
end

function SettingWidget:Hide()
    self:SetVisible(false)
end

function SettingWidget:OnEnable()
    local btnData = nil
    local flag = nil
    for idx, toggle in ipairs(self._textToggleList) do
        btnData = self._btnDataList[idx]
        flag = UserData.GetChatSetting(ChatMgr.TextSettingKey .. btnData.roomType)
        toggle.value = flag
        ChatMgr.SetSettingText(btnData.roomType, flag)
    end
    for idx, toggle in ipairs(self._voiceToggleList) do
        btnData = self._btnDataList[idx]
        flag = UserData.GetChatSetting(ChatMgr.VoiceSettingKey .. btnData.roomType)
        toggle.value = flag
        ChatMgr.SetSettingVoice(btnData.roomType, flag)
    end
    
    flag = UserData.GetChatSetting(ChatMgr.WifiSettingKey)
    self._voiceOnlyWifi.value = flag
    if flag then
        ChatMgr.SetWifiOrAll(1)
    end
    flag = UserData.GetChatSetting(ChatMgr.AllSettingKey)
    self._voiceAll.value = flag
    if flag then
        ChatMgr.SetWifiOrAll(2)
    end

    flag = UserData.GetChatSetting(ChatMgr.Text2VoiceSettingKey)
    self._voice2Text.value = flag
    ChatMgr.SetVoice2Text(flag)
end

function SettingWidget:OnDisable()
    
end

function SettingWidget:OnDestroy()
    
end

function SettingWidget:OnClick(go, id)
    
end


--local方法
local function OnTopNor(eventId)
    local idx = eventId - mTopEventIdBase
    if mWidgetList[idx] then
        mWidgetList[idx]:Hide()
    end
end

local function OnTopSpec(eventId)
    local idx = eventId - mTopEventIdBase
    if mWidgetList[idx] then
        mWidgetList[idx]:Show()
    end
end

local function RegEvent()

end

local function UnRegEvent()

end


function OnCreate(self)
    mSelf = self

    mTopToggleGroup = ToggleItemGroup.new(OnTopNor, OnTopSpec)

    local trs = nil
    for idx = 1, mTopBtnNum do
        trs = self:Find("Offset/top/btn" .. tostring(idx))
        mTopToggleGroup:AddItem(trs, mTopBtnDataList[idx])
    end

    local settingWidget = SettingWidget.new(self, "Offset/Setting", mSettingEventIdBase)
    table.insert(mWidgetList, settingWidget)
end

function OnEnable(self)
    RegEvent()

    for _, widget in ipairs(mWidgetList) do
        widget:OnEnable()
    end

    mTopToggleGroup:OnClick(mTopEventIdBase + 1)
end

function OnDisable(self)
    UnRegEvent()

    for _, widget in ipairs(mWidgetList) do
        widget:OnDisable()
    end
end

function OnDestroy(self)
    for _, widget in ipairs(mWidgetList) do
        widget:OnDestroy()
    end
end

function OnClick(go, id)
    if id == -100 then
        UIMgr.UnShowUI(AllUI.UI_Chat_Setting)
    end
    if mTopEventIdBase + 1 <= id and id <= mTopEventIdBase + mTopBtnNum then
        mTopToggleGroup:OnClick(id)
    elseif mSettingEventIdBase + 1 <= id then
        --频道设置
        mWidgetList[1]:OnClick(go, id)
    end
end