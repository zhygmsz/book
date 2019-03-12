--首次购买此商品有更多的元宝赠送
local ChargeGoods = class("ChargeGoods");

function ChargeGoods:ctor(static)
    self._static = static;
    self._dynamic = {};
    self._dynamic.isGiftPackage = true;
    self._dynamic.isFreeDouble = true;
end

function ChargeGoods:InitDynamic(dynamic)
    self:SetDouble(dynamic.payFlag);--该段首冲奖励活动参与标志，true可以参与首冲奖励，false不可参与首冲奖励（已经参与过或者不在活动时间段）
    self:SetGiftPackage(false);
end

function ChargeGoods:GetID()
    return self._static.id;
end

function ChargeGoods:GetRMBPrice()
    return self._static.price;
end

function ChargeGoods:GetIngotCount()
    return self._static.ingot;
end

function ChargeGoods:GetIconName()
    return self._static.iconName;
end

function ChargeGoods:GetShowItem()
    return self._static.giftShowItem;
end

--赠送数量
function ChargeGoods:GetFreeIngotCount()
    if self:IsDouble() then
        return self._static.doubleFreebie;
    else
        return self._static.normalFreebie;
    end
end

function ChargeGoods:GetGiftPackageDesc()
    return self._static.giftPackageDesc;
end

-------------动态数据-------------------
--是否赠送双倍元宝
function ChargeGoods:IsDouble()
    return self._dynamic.isFreeDouble;
end
function ChargeGoods:SetDouble(value)
    if value == self._dynamic.isFreeDouble then return; end
    self._dynamic.isFreeDouble = value;
    GameEvent.Trigger(EVT.CHARGE,EVT.CHARGE_FREE_DOUBLE,self);
end
--是否赠送大礼包
function ChargeGoods:IsGiftPackage()
    return self._dynamic.isGiftPackage and self._static.giftPackageDesc and self._static.giftPackageDesc ~="";
end
function ChargeGoods:SetGiftPackage(value)
    if value == self._dynamic.isGiftPackage then return; end
    self._dynamic.isGiftPackage = value;
    GameEvent.Trigger(EVT.CHARGE,EVT.CHARGE_GIFT_PACKAGE,self);
end

return ChargeGoods;