module("UI_EmojiLibrary", package.seeall)

local EmojiLibraryWidget = require("Logic/Presenter/UI/Chat/EmojiLibrary/EmojiLibraryWidget")

--组件
local mSelf
local mSelfPanel
local mMiddleTrs

local mEmojiLibraryWidget
local mTopToggleGroup
local mRightToggleGroup

--变量
local mEvents = {}
local mTopBtnNum = 3
local mTopEventIdBase = 10
local mTopBtnDataList = {
    {eventId = mTopEventIdBase + 1, content = "最火"},
    {eventId = mTopEventIdBase + 2, content = "最新"},
    {eventId = mTopEventIdBase + 3, content = ""}
}

local mRightBtnNum = 2
local mRightEventIdBase = 0
local mRightBtnDataList = {
    {eventId = mRightEventIdBase + 1, content = "单品"},
    {eventId = mRightEventIdBase + 2, content = "系列"}
}

local mEmojiAndSerieStr = {
    [mRightBtnDataList[1].eventId] = "我的单品",
    [mRightBtnDataList[2].eventId] = "我的系列"
}

local mWidgetEventIdBase = 20

local mCurRightIdx = -1
local mCurTopIdx = -1

local mOpenIdx = { rightIdx = 1, topIdx = 1 }

--local方法
local function SetOffsetGoVisible(visible)
    mSelfPanel.alpha = visible and 1 or 0.01
end

local function OnUIClose()
    SetOffsetGoVisible(true)
end

local function OnUIOpen(uiData)
    SetOffsetGoVisible(false)
    CustomEmojiMgr.RegInvokeData(uiData, OnUIClose, nil)
end


local function GetWidgetIdx()
    local widgetIdx = -1

    if mCurRightIdx == 1 then
        --单品
        if mCurTopIdx == 1 then
            --最火单品
            widgetIdx = 1
        elseif mCurTopIdx == 2 then
            --最新单品
            widgetIdx = 2
        elseif mCurTopIdx == 3 then
            --我的单品
            widgetIdx = 3
        end
    elseif mCurRightIdx == 2 then
        --系列
        if mCurTopIdx == 1 then
            --最火系列
            widgetIdx = 4
        elseif mCurTopIdx == 2 then
            --最新系列
            widgetIdx = 5
        elseif mCurTopIdx == 3 then
            --我的系列
            widgetIdx = 6
        end
    end

    return widgetIdx
end

--[[
    @desc: 获取当前widget内数据列表
]]
local function GetWidgetDataList()
    local dataList = nil

    local widgetIdx = GetWidgetIdx()
    if widgetIdx == 1 then
        --最火单品
        dataList = CustomEmojiMgr.GetHotEmojiList()
    elseif widgetIdx == 2 then
        --最新单品
        dataList = CustomEmojiMgr.GetTimeEmojiList()
    elseif widgetIdx == 3 then
        --我的单品
        dataList = CustomEmojiMgr.GetMyAddEmojiListWithName()
    elseif widgetIdx == 4 then
        --最火系列
        dataList = CustomEmojiMgr.GetHotPkgList()
    elseif widgetIdx == 5 then
        --最新系列
        dataList = CustomEmojiMgr.GetTimePkgList()
    elseif widgetIdx == 6 then
        --我的系列
        dataList = CustomEmojiMgr.GetMyAddPkgList()
    end

    return dataList
end

local function OnTopNor(eventId)
end

--[[
    @desc: 
    --@restorePos: 是否恢复当前浏览位置
]]
local function DoShowWidget(restorePos)
    local dataList = GetWidgetDataList()
    if dataList then
        mEmojiLibraryWidget:SetEmojiOrSerie(mCurRightIdx)
        mEmojiLibraryWidget:SetHotOrTimeOrMy(mCurTopIdx)
        --根据情况，区分某些刷新需要重置位置，某些刷新需要保留现场并恢复位置
        --需要外部传参数控制
        mEmojiLibraryWidget:Show(dataList, restorePos)
    end
end

--[[
    @desc: 刷UI的响应操作，主要在该方法里
    --@eventId: :
]]
local function OnTopSpec(eventId)
    mCurTopIdx = eventId - mTopEventIdBase

    DoShowWidget(false)
end

local function OnRightNor(eventId)
end

local function OnRightSpec(eventId)
    mCurRightIdx = eventId - mRightEventIdBase

    --重置top[3]的content 
    mTopBtnDataList[3].content = mEmojiAndSerieStr[eventId]
    mTopToggleGroup:UpdateItem(mTopBtnDataList[3])

    --切换right时，top清空选中状态，并重新选中第一个
    mTopToggleGroup:ClearCurEventId()
    mTopToggleGroup:OnClick(mTopEventIdBase + mOpenIdx.topIdx)
    --设置失效
    mOpenIdx.topIdx = 1
end

--[[
    @desc: 新添加一个表情，事件处理方法
]]
local function OnAddOneEmojiWithName()
    if mCurRightIdx == 1 and mCurTopIdx == 3 then
        --单品 - 我的上传
        DoShowWidget(true)
    end
end

--[[
    @desc: 获取到更多最火表情
]]
local function OnGetMoreHotEmoji()
    if mCurRightIdx == 1 and mCurTopIdx == 1 then
        --单品 - 最火
        DoShowWidget(true)
    end
end

--[[
    @desc: 获取到更多最新表情
]]
local function OnGetMoreTimeEmoji()
    if mCurRightIdx == 1 and mCurTopIdx == 2 then
        --单品 - 最新
        DoShowWidget(true)
    end
end

--[[
    @desc: 获取到我添加的表情列表
]]
local function OnGetMyAddEmoji()
    if mCurRightIdx == 1 and mCurTopIdx == 3 then
        --单品 - 我的上传
        DoShowWidget(true)
    end
end

--[[
    @desc: 获取到我添加的系列列表
]]
local function OnGetMyAddPkg()
    if mCurRightIdx == 2 and mCurTopIdx == 3 then
        --系列 - 我的上传
        DoShowWidget(true)
    end
end

--[[
    @desc: 添加一个系列
]]
local function OnAddOnePkg()
    if mCurRightIdx == 2 and mCurTopIdx == 3 then
        --系列 - 我的上传
        DoShowWidget(true)
    end
end

local function OpenAddOneEmojiUI()
    OnUIOpen(AllUI.UI_AddOneEmoji)
    UIMgr.ShowUI(AllUI.UI_AddOneEmoji)
end

local function OpenEmojiInfoUI(emojiInfo)
    OnUIOpen(AllUI.UI_EmojiInfo)
    CustomEmojiMgr.OpenEmojiInfoUI(emojiInfo)
end

local function OpenAddPkgUI()
    OnUIOpen(AllUI.UI_AddOnePkg)
    UIMgr.ShowUI(AllUI.UI_AddOnePkg)
end

local function OpenPkgInfoUI(pkgInfo)
    OnUIOpen(AllUI.UI_PkgInfo)
    CustomEmojiMgr.OpenPkgInfoUI(pkgInfo)
end


--[[
    @desc: 点击响应，根据当前选中的top/right分页不同，作出不同的响应
    --@data: EmojiInfo
]]
local function OnClickWidgetItem(data)
    if not data then
        return
    end
    if data:CheckIsAdd() then
        --加号按钮
        if mCurRightIdx == 1 then
            --单品
            OpenAddOneEmojiUI()
        elseif mCurRightIdx == 2 then
            --系列
            OpenAddPkgUI()
        end
    else
        --单品/系列详情界面
        if mCurRightIdx == 1 then
            OpenEmojiInfoUI(data)
        elseif mCurRightIdx == 2 then
            OpenPkgInfoUI(data)
        end
    end
end

local function RegEvent(self)
    mEvents[1] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ADDONEEMOJIWITHNAME, OnAddOneEmojiWithName)
    mEvents[2] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_GETMOREHOTEMOJI, OnGetMoreHotEmoji)
    mEvents[3] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_GETMORETIMEEMOJI, OnGetMoreTimeEmoji)
    mEvents[4] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYADDEMOJI, OnGetMyAddEmoji)
    mEvents[5] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYADDPKG, OnGetMyAddPkg)
    mEvents[6] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ADDONEPKG, OnAddOnePkg)
end

local function UnRegEvent(self)
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ADDONEEMOJIWITHNAME, mEvents[1])
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_GETMOREHOTEMOJI, mEvents[2])
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_GETMORETIMEEMOJI, mEvents[3])
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYADDEMOJI, mEvents[4])
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ONGETMYADDPKG, mEvents[5])
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_ADDONEPKG, mEvents[6])
    mEvents = {}
end

function OnCreate(self)
    mSelf = self

    local offsetTrs = self:Find("Offset")
    mSelfPanel = offsetTrs.parent:GetComponent("UIPanel")

    mRightToggleGroup = ToggleItemGroup.new(OnRightNor, OnRightSpec)
    mTopToggleGroup = ToggleItemGroup.new(OnTopNor, OnTopSpec)

    local trs = nil
    for idx = 1, mRightBtnNum do
        trs = self:Find("Offset/right/btn" .. tostring(idx))
        mRightToggleGroup:AddItem(trs, mRightBtnDataList[idx])
    end
    for idx = 1, mTopBtnNum do
        trs = self:Find("Offset/top/btn" .. tostring(idx))
        mTopToggleGroup:AddItem(trs, mTopBtnDataList[idx])
    end

    mMiddleTrs = self:Find("Offset/middle")
    mEmojiLibraryWidget = EmojiLibraryWidget.new(mMiddleTrs, mWidgetEventIdBase, OnClickWidgetItem)
end

function OnEnable(self)
    RegEvent(self)

    local openIdx = CustomEmojiMgr.GetEmojiLibraryOpenIdx()
    mOpenIdx.rightIdx = openIdx.rightIdx
    mOpenIdx.topIdx = openIdx.topIdx
    mRightToggleGroup:OnClick(mRightEventIdBase + mOpenIdx.rightIdx)
    --设置为1，标识该值已经失效
    mOpenIdx.rightIdx = 1
end

function OnDisable(self)
    UnRegEvent(self)

    mTopToggleGroup:OnDisable()
    mRightToggleGroup:OnDisable()
end

function OnDestroy(self)
    mCurRightIdx = -1
    mCurTopIdx = -1

    mTopToggleGroup:OnDestroy()
    mRightToggleGroup:OnDestroy()

    mEmojiLibraryWidget:OnDestroy()
end

function OnClick(go, id)
    if id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_EmojiLibrary)
    elseif mRightEventIdBase + 1 <= id and id <= mRightEventIdBase + mRightBtnNum then
        mRightToggleGroup:OnClick(id)
    elseif mTopEventIdBase + 1 <= id and id <= mTopEventIdBase + mTopBtnNum then
        mTopToggleGroup:OnClick(id)
    elseif mWidgetEventIdBase < id then
        mEmojiLibraryWidget:OnClick(id)
    end
end
