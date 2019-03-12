module("UI_Shop_Store", package.seeall)

local StoreWidget = require("Logic/Presenter/UI/Shop/Store/StoreWidget")
local RightItem = require("Logic/Presenter/UI/Shop/CommerceRightWidget")

--组件
local mSelf
local mToggleItemGroup
local mMiddleTrs
local mLeftWidget
local mRightTrs
local mSelectIndex = 3

--变量
local mEventIds = {}
local mTopBtnDataList = 
{
    { eventId = 1, content = WordData.GetWordStringByKey("Shop_class2_1") },
    { eventId = 2, content = WordData.GetWordStringByKey("Shop_class2_2")},
    { eventId = 3, content = WordData.GetWordStringByKey("Shop_class2_3") },
}
local mTopBtnNum = 3
local mMiddleEventIdBase = 10

local mRightPanel



--local方法
local function OnNor(topBtnIdx)
   --不处理 
end

local function OnSpec(topBtnIdx)
    --显示left区域
    mLeftWidget:Show(topBtnIdx)
    mRightPanel:Show(nil, 1) --切换页签后的初始化
end

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

local function CheckIsLeftWidget(eventId)
    if 10 < eventId then
        return true
    else
        return false
    end
end

local function OnClickCallBack(data)
    mRightPanel:Show(data, 1)
end

local function OnBuy(goodsId)
    local data = mLeftWidget:GetDataByGoodsId(goodsId)
    if data == nil then
        GameLog.LogError("CommerceBuy.BuyWidget.UpdateMiddleItem -> middleData is nil, goodsId = %s", goodsId)
        return 
    end

    mRightPanel:UpdateOnBuy(data)
    mLeftWidget:OnBuy(goodsId)
end

local function RegEvent(self)
    mEventIds[1] = MessageSub.Register(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_BUY, OnBuy)
end

local function UnRegEvent(self)
    MessageSub.UnRegister(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_BUY, mEventIds[1])
    mEventIds = {}
end

function OnCreate(self)
    mSelf = self

    mToggleItemGroup = ToggleItemGroup.new(OnNor, OnSpec)

    local trs = nil
    for idx = 1, mTopBtnNum do
        trs = self:Find("Offset/top/btn" .. tostring(idx))
        mToggleItemGroup:AddItem(trs, mTopBtnDataList[idx])
    end

    mMiddleTrs = self:Find("Offset/middle")
    mRightTrs = self:Find("Offset/right")
    mRightPanel = RightItem.new(mRightTrs)
    
    mLeftWidget = StoreWidget.new(mMiddleTrs, mMiddleEventIdBase, OnClickCallBack)
end

function OnEnable(self)
    RegEvent(self)

    --默认选中第一个
    mToggleItemGroup:OnClick(mSelectIndex)
end

function OnDisable(self)
    UnRegEvent(self)
    mToggleItemGroup:OnDisable()
end

function OnDestroy(self)
    mToggleItemGroup:OnDestroy()
    mLeftWidget:OnDestroy()
end

function OnClick(go, id)
    if id == -100 then
        TipsMgr.TipByFormat("功能未开放")
    elseif CheckIsTopBtn(id) then
        --topbtn
        mToggleItemGroup:OnClick(id)
        mSelectIndex = id
    elseif CheckIsLeftWidget(id) then
        mLeftWidget:OnClick(id)
    end
end