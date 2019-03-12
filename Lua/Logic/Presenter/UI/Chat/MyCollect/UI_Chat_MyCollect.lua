--我添加的表情

module("UI_Chat_MyCollect", package.seeall)

local EmojiWidget = require("Logic/Presenter/UI/Chat/MyCollect/MyCollect_EmojiWidget")
local PkgWidget = require("Logic/Presenter/UI/Chat/MyCollect/MyCollect_PkgWidget")


--组件
local mSelf
local mOffsetGo
local mEmojiTrs
local mPkgTrs

local mTidyGo
local mTidyEndGo
local mDeleteGo
local mToFirstGo

local mToggleItemGroup
local mEmojiWidget
local mPkgWidget

--变量
local mEvents = {}
local mTopBtnNum = 2
local mTopBtnDataList = 
{
    { eventId = 1, content = "表情单品" },
    { eventId = 2, content = "表情系列" },
}
local mTop2Widget = {}
local mCurTopEventId = mTopBtnDataList[1].eventId


local mEventIdSpan = 1
local mEventIdBaseEmoji = 10000
local mEventIdBasePkg = 20000

--local方法
local function SetOffsetGoVisible(visible)
    mOffsetGo:SetActive(visible)
end

local function OnUIClose()
    SetOffsetGoVisible(true)
end

local function OnUIOpen()
    SetOffsetGoVisible(false)
    CustomEmojiMgr.RegInvokeData(AllUI.UI_Chat_EmojiPic, OnUIClose)
end

local function OnNor(eventId)
    if eventId and mTop2Widget[eventId] then
        mTop2Widget[eventId]:Hide()
    end
end

local function OnSpec(eventId)
    if eventId and mTop2Widget[eventId] then
        mTop2Widget[eventId]:Show()
        mCurTopEventId = eventId
    end
end

--[[
    @desc: 设置整理状态
    --@state: 
]]
local function SetTidyState(state)
    --UI
    mTidyGo:SetActive(not state)

    mTidyEndGo:SetActive(state)
    mDeleteGo:SetActive(state)
    mToFirstGo:SetActive(state)

    if mTop2Widget[mCurTopEventId] then
        mTop2Widget[mCurTopEventId]:ResetInteractMode(state and 2 or 1)
    end

    --逻辑
    if state then
        --整理

    else
        --整理完毕
    end
end

local function RegEvent(self)
    
end

local function UnRegEvent(self)

end

function OnCreate(self)
    mSelf = self

    mOffsetGo = self:Find("Offset").gameObject

    mToggleItemGroup = ToggleItemGroup.new(OnNor, OnSpec)

    local trs = nil
    for idx = 1, mTopBtnNum do
        trs = self:Find("Offset/top/btn" .. tostring(idx))
        mToggleItemGroup:AddItem(trs, mTopBtnDataList[idx])
    end

    mEmojiTrs = self:Find("Offset/middle/emojiwidget")
    mEmojiWidget = EmojiWidget.new(mEmojiTrs, self, OnUIOpen, mEventIdBaseEmoji, mEventIdSpan)
    mTop2Widget[1] = mEmojiWidget

    mPkgTrs = self:Find("Offset/middle/pkgwidget")
    mPkgWidget = PkgWidget.new(mPkgTrs, self, mEventIdBasePkg, mEventIdSpan)
    mTop2Widget[2] = mPkgWidget

    mTidyGo = self:Find("Offset/tidy").gameObject
    mTidyEndGo = self:Find("Offset/tidyend").gameObject
    mDeleteGo = self:Find("Offset/delete").gameObject
    mToFirstGo = self:Find("Offset/tofirst").gameObject
end

function OnEnable(self)
    RegEvent(self)

    SetTidyState(false)
    for _, widget in pairs(mTop2Widget) do
        widget:OnEnable()
    end
    mToggleItemGroup:OnClick(1)
end

function OnDisable(self)
    UnRegEvent(self)

    for _, widget in pairs(mTop2Widget) do
        widget:OnDisable()
    end
    mToggleItemGroup:OnDisable()
end

function OnDestroy(self)
    for _, widget in pairs(mTop2Widget) do
        widget:OnDestroy()
    end

    mToggleItemGroup:OnDestroy()
end

function OnClick(go, id)
    if id == -100 then
        UIMgr.UnShowUI(AllUI.UI_Chat_MyCollect)
    elseif id == -11 then
        --整理
        SetTidyState(true)
    elseif id == -12 then
        --完成
        SetTidyState(false)
    elseif id == -13 then
        --删除
        SetTidyState(false)
    elseif id == -14 then
        --移到最前
        SetTidyState(false)
    elseif 1 <= id and id <= mTopBtnNum then
        --topbtn
        mToggleItemGroup:OnClick(id)
    elseif mEventIdBaseEmoji < id and id <= mEventIdBasePkg then
        mEmojiWidget:OnClick(id)
    elseif mEventIdBasePkg < id then
        mPkgWidget:OnClick(id)
    end
end