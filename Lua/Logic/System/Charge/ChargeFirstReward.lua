--首充奖励
local ChargeFirstReward = class("ChargeFirstReward");

function ChargeFirstReward:ctor(static)
    self._static = static;
    self._showItems = self._static.showItems;
    if self._static.hasCloth then
        self._clothItems = ChargeMgr.GetSuitList();
    end
    self._dynamic = {};
    self._dynamic.state = 0;
end

function ChargeFirstReward:GetID()
    return self._static.id;
end
--所值价值
function ChargeFirstReward:GetValue()
    return self._static.value;
end
--客户端展示物品
function ChargeFirstReward:GetItems()
    return self._static.showItems;
end

function ChargeFirstReward:GetTitle()
    return self._static.title;
end

function ChargeFirstReward:GetDesc()
    return self._static.desc;
end

function ChargeFirstReward:HasClothes()
    return self._static.hasCloth;
end
-------------动态数据-------------------
--是否已经领取
function ChargeFirstReward:HasReceived()
    return self._dynamic.state == 2;
end
--是否等待领取
function ChargeFirstReward:IsWaitReceiving()
    return self._dynamic.state == 1;
end
--尚未到领取时间
function ChargeFirstReward:IsWaitOpen()
    return self._dynamic.state == 0;
end
--设置状态
function ChargeFirstReward:SetState(state)
    if self._dynamic.state == state then return; end
    self._dynamic.state = state;
    GameEvent.Trigger(EVT.CHARGE,EVT.CHARGE_FIRST_REWARD_CHANGE,self);
end

return ChargeFirstReward;