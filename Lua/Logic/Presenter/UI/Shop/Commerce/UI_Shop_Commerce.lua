module("UI_Shop_Commerce", package.seeall)

local BuyWidget = require("Logic/Presenter/UI/Shop/Commerce/CommerceBuy")
local SellWidget = require("Logic/Presenter/UI/Shop/Commerce/CommerceSell")
--右侧区域公用，根据选中的购买/出售页签做逻辑区分
local RightItem = require("Logic/Presenter/UI/Shop/CommerceRightWidget")

--组件
local mSelf
local mBuyTrs
local mSellTrs
local mRightTrs

--变量
local mEventIds = {}
local mToggleItemGroup
local mTop2Widget = {}
local mTopBtnNum = 2

local mRightItem

local mTopBtnDataList = {
    { eventId = 1, content = "我要购买" },
    { eventId = 2, content =  "我要出售" },
}


--local方法
local function CheckIsTopBtn(eventId)
    local isTopBtn = false

    for _, data in ipairs(mTopBtnDataList) do
        if data.eventId == eventId then
            isTopBtn = true
            break
        end
    end

    return isTopBtn
end

local function OnNor(eventId)
    if mTop2Widget[eventId] then
        mTop2Widget[eventId]:Hide()
    end
end

local function OnSpec(eventId)
    if mTop2Widget[eventId] then
        mTop2Widget[eventId]:Show()
    end
end

local function RegEvent(self)
end

local function UnRegEvent(self)

end

function OnCreate(self)
    mSelf = self

    mToggleItemGroup = ToggleItemGroup.new(OnNor, OnSpec)

    local trs = nil
    for idx = 1, mTopBtnNum do
        trs = self:Find("Offset/top/btn" .. tostring(idx))
        mToggleItemGroup:AddItem(trs, mTopBtnDataList[idx])
    end

    mRightTrs = self:Find("Offset/right")
    mRightItem = RightItem.new(mRightTrs)

    mBuyTrs = self:Find("Offset/buy")
    mTop2Widget[1] = BuyWidget.new(mBuyTrs, mSelf, mRightItem)
    mSellTrs = self:Find("Offset/sell")
    mTop2Widget[2] = SellWidget.new(mSellTrs, mSelf, mRightItem)
end

function OnEnable(self)
    RegEvent(self)

    --打开UI，选中的页签
    mToggleItemGroup:OnClick(1)
end

function OnDisable(self)
    UnRegEvent(self)
    mToggleItemGroup:OnDisable()
end

function OnDestroy(self)
    for _, widget in ipairs(mTop2Widget) do
        if widget then
            widget:OnDestroy()
        end
    end
end

function OnClick(go, id)
    if CheckIsTopBtn(id) then
        mToggleItemGroup:OnClick(id)
    end
end

