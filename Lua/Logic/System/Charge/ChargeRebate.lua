--首次购买此商品有更多的元宝赠送
local ChargeRebate = class("ChargeRebate");

function ChargeRebate:ctor(static)
    self._static = static;
    self._showItems = self._static.showItems;
    self._dynamic = {};
    self._dynamic.state = 0;
end

function ChargeRebate:InitDynamic(state)
    self:SetState(state);
end

function ChargeRebate:GetID()
    return self._static.id;
end
--阈值
function ChargeRebate:GetLimitValue()
    return self._static.limit;
end

function ChargeRebate:GetItems()
    return self._showItems;
end

-------------动态数据-------------------
--是否已经领取
function ChargeRebate:HasReceived()
    return self._dynamic.state == 2;
end
--是否等待领取
function ChargeRebate:IsWaitReceiving()
    return self._dynamic.state == 1;
end
--设置状态
function ChargeRebate:SetState(state)--该段累充奖励是否已领取 0条件未达到，1条件达到未领取，2已结领取
    if state == self._dynamic.state then return; end
    self._dynamic.state = state;
    GameEvent.Trigger(EVT.CHARGE,EVT.CHARGE_REBATE_STATE,self);
end

return ChargeRebate;