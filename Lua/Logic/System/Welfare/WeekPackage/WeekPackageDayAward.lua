--[[
    author:{hesinian}
    time:2018-12-25 10:19:00
]]

local WeekPackageDayAward = class("WeekPackageDayAward")

function WeekPackageDayAward:ctor()
    self._state = 0;
end

function WeekPackageDayAward:Bind(itemInfo)

    self._normalDropItems = itemInfo.prize.itemlist;
    self._state = itemInfo.state;

    GameEvent.Trigger(EVT.WEEKPACKAGE,EVT.WEEK_DAY_AWARD_CHANGE,self);
end

function WeekPackageDayAward:GetDropItems()
    return self._normalDropItems or table.emptyTable;
end

function WeekPackageDayAward:SetState(state)
    if self._state == state then return; end 
    self._state = state;
    GameEvent.Trigger(EVT.WEEKPACKAGE,EVT.WEEK_DAY_AWARD_STATE,self);
end

function WeekPackageDayAward:IsReceived( )
    return self._state == 2;
end
function WeekPackageDayAward:IsWaitingReceived( )
    return self._state == 1;
end
function WeekPackageDayAward:IsAvailable( )
    return self._state ~= 0;
end

return WeekPackageDayAward;