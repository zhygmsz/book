
local UIChargeGoodsWrapUI = class("UIChargeGoodsWrapUI",BaseWrapContentUI);
local LoaderMgr = require "LoaderMgr"
local mPackageEvent;
local mContent;
local mEffectSortOrder;

function UIChargeGoodsWrapUI:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    mContent = context;
    mTransform = wrapItemTrans;
    self._labelIngot = wrapItemTrans:Find("Count_bg/Count"):GetComponent("UILabel");
    self._labelValue = wrapItemTrans:Find("Money_bg/Money"):GetComponent("UILabel");
    self._packageDesc = wrapItemTrans:Find("GiftPackage_bg/Label"):GetComponent("UILabel");
    
    self._itemSprite = wrapItemTrans:Find("Gold_Icon"):GetComponent("UISprite");

    local grid = wrapItemTrans:Find("Give_bg/Grid"):GetComponent("UIGrid");
    self._ingotSendCount = UISpriteNumber.new(context.GetUIFrame(),grid,"num_common_0");

    self._packageGo = wrapItemTrans:Find("GiftPackage_bg").gameObject;
    mPackageEvent = wrapItemTrans:Find("GiftPackage_bg"):GetComponent("UIEvent");
    self:InsertUIEvent(wrapItemTrans:GetComponent("UIEvent"));
    mEffectSortOrder = wrapItemTrans.transform.parent.parent:GetComponent("UIPanel").sortingOrder+1;
    
end

function UIChargeGoodsWrapUI:OnRefresh()
    local goods = self._data;

    if not self.mEffectLoader then
        self.class:ShowEffect(goods,self._itemSprite.transform.parent,self);
    end
    self._packageGo:GetComponent("UIEvent").id = goods:GetShowItem();
    self._labelIngot.text = ChargeMgr.NumberFormatPerMille(goods:GetIngotCount(),",");
    self._labelValue.text =  string.format(WordData.GetWordStringByKey("charge_shop_price_unit"),goods:GetRMBPrice());
    if goods:IsGiftPackage() then
        self._packageGo:SetActive(true);
        self._packageDesc.text = goods:GetGiftPackageDesc();
    else
        self._packageGo:SetActive(false);
    end
    self._itemSprite.spriteName = goods:GetIconName();
    self._ingotSendCount:SetNumber(goods:GetFreeIngotCount());
end

function UIChargeGoodsWrapUI:ShowEffect(data,parent,self)
    if data then
        local id = mContent.GetGoodsEffectRes(1);
        if data:GetRMBPrice() == 30 then
            id = mContent.GetGoodsEffectRes(2);
        elseif data:GetRMBPrice() == 50 then
            id = mContent.GetGoodsEffectRes(3);
        elseif data:GetRMBPrice() == 98 then
            id = mContent.GetGoodsEffectRes(4);
        elseif data:GetRMBPrice() == 198 then
            id = mContent.GetGoodsEffectRes(5);
        elseif data:GetRMBPrice() == 298 then
            id = mContent.GetGoodsEffectRes(6);
        elseif data:GetRMBPrice() == 488 then
            id = mContent.GetGoodsEffectRes(7);
        elseif data:GetRMBPrice() == 648 then
            id = mContent.GetGoodsEffectRes(8);
        end
        self.mEffectLoader = LoaderMgr.CreateEffectLoader();
        self.mEffectLoader:LoadObject(id);
        self.mEffectLoader:SetTransform(parent,Vector3.zero,Vector3.one,Vector3.zero,mEffectSortOrder);
        self.mEffectLoader:SetLayer(CameraLayer.UILayer);
        self.mEffectLoader:SetActive(true,true);
    end
end

function UIChargeGoodsWrapUI:DestoryEffect()
    LoaderMgr.DeleteLoader(self.mEffectLoader);
    self.mEffectLoader=nil;
end

return UIChargeGoodsWrapUI;