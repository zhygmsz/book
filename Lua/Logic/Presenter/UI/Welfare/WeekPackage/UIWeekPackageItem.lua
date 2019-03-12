--[[
    author:{hesinian}
    time:2018-12-25 14:08:47
]]

local UIWeekPackageItem = class("UIWeekPackageItem",BaseWrapContentUI)
local UIWeekPackageGiftItem = require("Logic/Presenter/UI/Welfare/WeekPackage/UIWeekPackageGiftItem")

local mEventType = {
    RequestBuy ={Gold=0,RMB=1},--购买
    RequestReceivePackage=2,   --领取礼包
    TheReserved=3,--预留
    GiftItemsClick = {IdScopeOfMin=5,IdScopeOfMax=9},--礼包给予物品
    MonthGiveItemsClick = {IdScopeOfMin=10,IdScopeOfMax=14},--月卡额外奖励
    SubscribeToGiveItemsClick = {IdScopeOfMin=15,IdScopeOfMax=19},--订阅额外奖励
}
function UIWeekPackageItem:ctor(trans,context)
    BaseWrapContentUI.ctor(self, trans, context);
    self._ui = context.GetUI();
    self._giftPackageGrid = trans:Find("Grid");
    self._giftItemPrefab = trans:Find("Grid/GiftItem");
    
    self.mGiftPackageTable={};
    self.mGiftPackageTable[1] = UIWeekPackageGiftItem.new(self._giftItemPrefab,context,1);
    for i=2,3 do
        local giftItem = self._ui:DuplicateAndAdd(self._giftItemPrefab,self._giftPackageGrid,i);
        self.mGiftPackageTable[i] = UIWeekPackageGiftItem.new(giftItem,context,i);
    end

    self._tipGo = trans:Find("Tip").gameObject;
    self._buyGo = trans:Find("Buy").gameObject;
    self._goldGo = trans:Find("Buy/GoldBtn").gameObject;
    self._goldIcon = trans:Find("Buy/GoldBtn/Icon"):GetComponent("UISprite");
    self._goldIcon.spriteName = "icon_common_huobi02";
    self._goldLabel = trans:Find("Buy/GoldBtn/label"):GetComponent("UILabel");
    self._goldBtnEvent = trans:Find("Buy/GoldBtn"):GetComponent("UIEvent");
    self._rmbLabel = trans:Find("Buy/MoneyBtn/label"):GetComponent("UILabel");
    self._rmbBtnEvent = trans:Find("Buy/MoneyBtn"):GetComponent("UIEvent");
    local grid = trans:Find("Buy/Discount/Grid"):GetComponent("UIGrid");
    self._numberGrid = UISpriteNumber.new(self._ui,grid,"num_common_0");
    self._basicRmbLabel = trans:Find("Buy/SopriceBg/label"):GetComponent("UILabel");

    self._receivingGo = trans:Find("BtnReceiving").gameObject;
    self._receivingBtnEvent = trans:Find("BtnReceiving"):GetComponent("UIEvent");
    self._receivedGo = trans:Find("BtnReceived").gameObject;
    self._receivedBtnEvent = trans:Find("BtnReceived"):GetComponent("UIEvent");

end

function UIWeekPackageItem:SetOnClick(callbacks,caller,eventId)
    self._goldBtnEvent.id = eventId;
    self._rmbBtnEvent.id = eventId + 1;
    self._receivingBtnEvent.id = eventId + 2;
    self._receivedBtnEvent.id = eventId + 3;
    self._baseEventID = eventId;
    self.mGiftPackageTable[1]:SetOnClick(eventId+5)
    self.mGiftPackageTable[2]:SetOnClick(eventId+10)
    self.mGiftPackageTable[3]:SetOnClick(eventId+15)
end

function UIWeekPackageItem:OnRefresh()
    local container = self._data;
    for i=1,#self.mGiftPackageTable do
        self.mGiftPackageTable[i]:OnRefresh(container);
    end
    
    if SystemInfo.IsIosPlatform() then
        self.mGiftPackageTable[3]:SetVisible(false)
    else
        self.mGiftPackageTable[3]:SetVisible(true)
    end

    local hasBought = container:IsAvailable();
    self._buyGo:SetActive(not hasBought);
    self._receivingGo:SetActive(hasBought);
    self._receivedGo:SetActive(hasBought);

    self._tipGo:SetActive(true);
    if hasBought then
        local hasReceive = container:IsReceived();
        self._receivingGo:SetActive(not hasReceive);
        self._receivedGo:SetActive(hasReceive);
        self._tipGo:SetActive(not hasBought);
    else

        self._goldGo:SetActive(container:CanUseGold());
        self._goldLabel.text = container:GetGoldPrice();
        local rmbIcon = WordData.GetWordStringByKey("charge_shop_price_unit");--￥
        local discountPrice = container:GetDiscountPrice();
        local basicPrice = container:GetBasicPrice();
        self._rmbLabel.text = string.format( rmbIcon,discountPrice );
        self._basicRmbLabel.text = string.format( rmbIcon,basicPrice);
        local discount = math.floor(basicPrice/discountPrice * 100);
        self._numberGrid:SetNumber(discount);
    end
end

function UIWeekPackageItem:OnClick(id)
    id = id - 1;
    if id == mEventType.RequestBuy.Gold then
        AllPackageMgr.RequestBuyWeekPackage(AllPackageMgr.WeekPackageBuyType.Gold,self._data);
    elseif id == mEventType.RequestBuy.RMB then
        AllPackageMgr.RequestBuyWeekPackage(AllPackageMgr.WeekPackageBuyType.RMB,self._data);
    elseif id == mEventType.RequestReceive then
        WeekpackageMgr.RequestReceiveWeekPackage(self._data);
    elseif id == mEventType.TheReserved then
    elseif id >= mEventType.GiftItemsClick.IdScopeOfMin and id <= mEventType.GiftItemsClick.IdScopeOfMax then--normalGrid里会再次对baseEventID进行减法
        self.mGiftPackageTable[1]:OnClick(self._baseEventID + id);
    elseif id >= mEventType.MonthGiveItemsClick.IdScopeOfMin and id <= mEventType.MonthGiveItemsClick.IdScopeOfMax then
        self.mGiftPackageTable[2]:OnClick(self._baseEventID + id);
    elseif id >= mEventType.SubscribeToGiveItemsClick.IdScopeOfMin and id <= mEventType.SubscribeToGiveItemsClick.IdScopeOfMax then
        self.mGiftPackageTable[3]:OnClick(self._baseEventID + id);
    end
end

return UIWeekPackageItem;