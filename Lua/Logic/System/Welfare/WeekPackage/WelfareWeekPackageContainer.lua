--[[
    author:{hesinian}
    time:2018-12-25 10:19:00
]]
local WelfareWeekPackageContainer = class("WelfareWeekPackageContainer",xxx)

function WelfareWeekPackageContainer:ctor(_type)
    self._type = _type;
    self._name = WordData.GetWordStringByKey(string.format( "welfare_weekpackage_%d_name",_type+1));--1,2,3;折扣礼包，优惠礼包，超值礼包
end

function WelfareWeekPackageContainer:Bind(info)--PackageItem
    local id = info.pid;
    if self._id == id then return; end
    
    self._info = WelfareWeekPackageData.GetWeekPackage(id);
    if self._type ~= self._info.pType then
        GameLog.LogError("Wrong Type Bind to WeekPackage");
        --return;
    end
    
    self._id = id;
    self._normalDropItems = info.normalPrize.itemlist;
    self._monthDropItems = info.monthPrize.itemlist;
    self._subscribelDropItems = info.subscribePrize.itemlist;

    self._state = 0;

    GameEvent.Trigger(EVT.WEEKPACKAGE,EVT.WEEK_PACKAGE_CHANGE,self);
end

function WelfareWeekPackageContainer:GetName()
    return self._name;
end

function WelfareWeekPackageContainer:GetNormalItems()
    return self._normalDropItems or table.emptyTable;
end
function WelfareWeekPackageContainer:GetMonthItems()
    return self._monthDropItems or table.emptyTable;
end
function WelfareWeekPackageContainer:GetSubscribeItems()
    return self._subscribelDropItems or table.emptyTable;
end

function WelfareWeekPackageContainer:GetBasicPrice( )
    return self._info.basicPrice;
end
function WelfareWeekPackageContainer:GetDiscountPrice( )
    return self._info.discountPrice;
end
function WelfareWeekPackageContainer:CanUseGold( )
    return self._info.goldPrice > 0;
end
function WelfareWeekPackageContainer:GetGoldPrice( )
    return self._info.goldPrice;
end

function WelfareWeekPackageContainer:SetState(state)
    if self._state == state then return; end 
    self._state = state;
    GameEvent.Trigger(EVT.WEEKPACKAGE,EVT.WEEK_PACKAGE_STATE,self);
end

--已买,已领取
function WelfareWeekPackageContainer:IsReceived( )
    return self._state == 2;
end
--已买，没领取
function WelfareWeekPackageContainer:IsWaitingReceived( )
    return self._state == 1;
end
--已经购买
function WelfareWeekPackageContainer:IsAvailable( )
    return self._state ~= 0;
end

return WelfareWeekPackageContainer;





