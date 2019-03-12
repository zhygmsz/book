module("AllPackageMgr",package.seeall);

local WeekPackageDayAward = require("Logic/System/Welfare/WeekPackage/WeekPackageDayAward");
local WelfareWeekPackageContainer = require("Logic/System/Welfare/WeekPackage/WelfareWeekPackageContainer");
local mDayAward;
local mDayRefreshTime;
local mWeekPackageContainers = {};
local mWeekPackageContainerList = {};
local mWeekPackageRefreshTime;
AllPackageMgr.WeekPackageBuyType = {
    Gold=1,
    RMB=2,
}
local MonthCardStateType={
    NotBuy=0,--未购买
    HaveBuyAndReceive=1,--已购买可领取
    HaveBuyAndReceived=2,--已购买已领取
}


local mMonthCardState;
local mMonthCardLeftDay;
local mMonthCardBuyTime;
local mMonthCardLastGostTime;

local mMonthCardExpireTime;
local mMonthCardAwardRefreshTime;

local mMonthCardDailyDropID;
local mMonthCardDailyReceived;

local mSubscribeDropID;
local mSubscribeState;
local mSubscribeReceived;

local mFirstSubscribeAwardItems;

local mDebug;

function InitModule()
end

function Init()
    mDebug=true;
    --todo 请求每周礼包，月卡，订阅信息
    local allAwards = WelfareWeekPackageData.GetAllWeekPackages();
    mDayAward = WeekPackageDayAward.new();
    mWeekPackageContainers[1] = WelfareWeekPackageContainer.new(WelfareWeekPackage_pb.PK_ONE);
    mWeekPackageContainers[2] = WelfareWeekPackageContainer.new(WelfareWeekPackage_pb.PK_TWO);
    mWeekPackageContainers[3] = WelfareWeekPackageContainer.new(WelfareWeekPackage_pb.PK_THREE);
    mWeekPackageContainerList[WelfareWeekPackage_pb.PK_ONE] = mWeekPackageContainers[1];
    mWeekPackageContainerList[WelfareWeekPackage_pb.PK_TWO] = mWeekPackageContainers[2];
    mWeekPackageContainerList[WelfareWeekPackage_pb.PK_THREE] = mWeekPackageContainers[3];

    RequestInitWeekPackage();

    
    mMonthCardExpireTime = TimeUtils.SystemTimeStamp(true);
    mMonthCardAwardRefreshTime = TimeUtils.SystemTimeStamp(true);

    mMonthCardDailyDropID = 124101;
    mMonthCardDailyReceived = false;

    mSubscribeDropID = 124102;
    mSubscribeState = false;
    mSubscribeReceived = false;
    GameEvent.Trigger(EVT.MONTHCARD,EVT.MONTH_CARD_BUY);
end

function OnInitDynamic(data)

    mDayAward:Bind(data.award);
    mDayRefreshTime = data.dayTime;

    for i,p in ipairs(data.packageItems) do
        local container = mWeekPackageContainerList[p.pType];
        container:Bind(p);
        container:SetState(p.state);
    end
    mPackageRefreshTime = data.packageTime;
end

function OnReveiveAllCards(msg)
    local monthcardInfo = msg.monthCard;
    mMonthCardState = monthcardInfo.getStatus;  --领取状态
    mMonthCardLeftDay = monthcardInfo.leftDay;  --剩余天数
    mMonthCardBuyTime = monthcardInfo.buyTime;  --最近一次购买时间

end

-----------------------------------------------每周礼包、每日免费礼包---------------------------------------------------
function GetWeekPackageRefreshTime()
    return mWeekPackageRefreshTime;
end

function GetDayAwardRefreshTime()
    return mDayRefreshTime;
end

function GetWeekPackageContainers()
    return mWeekPackageContainers;
end

function GetDayAward()
    return mDayAward;
end


function RequestInitWeekPackage()
    data = {};
    data.award={prize = {itemlist = {{itemid = 302310004, count = 2}}},state = 0};
    data.dayTime = TimeUtils.SystemTimeStamp(true) + 1000;
    data.packageTime = TimeUtils.SystemTimeStamp(true) + 10000;
    data.packageItems = {};
    for i =1,3 do
        data.packageItems[i] = {};
        data.packageItems[i].pType = i - 1;
        data.packageItems[i].pid = 10001 + (i-1)*12;
        data.packageItems[i].state = 0;
        data.packageItems[i].normalPrize = {itemlist = {{itemid = 00000002, count = 2},{itemid = 00000005, count = 2}}};
        data.packageItems[i].monthPrize = {itemlist = {{itemid = 00000003, count = 2},{itemid = 00000006, count = 2}}};
        data.packageItems[i].subscribePrize = {itemlist = {{itemid = 00000004, count = 2},{itemid = 00000007, count = 2}}};
    end
    OnInitDynamic(data);
end

function RequestBuyWeekPackage(buyType,data)
    if buyType==WeekPackageBuyType.Gold then
    elseif buyType==WeekPackageBuyType.RMB then
    end
end

function ReceiveBuyWeekPackage(msg)
end

function RequestReceiveWeekPackage(data)
end
----------------------------------------------------月卡、订阅-----------------------------------------------------
function IsMonthlyBuy()
    if not mDebug then
        return mMonthCardState > 0;
    else
        return mMonthCardExpireTime and mMonthCardExpireTime>TimeUtils.SystemTimeStamp(true);
    end
end

function GetAwardRefreshTime()
    local refreshTime;
    local nowtime = TimeUtils.SystemTimeStamp(true);
    local zeroPointsTodayTime = TimeUtils.GetSpecifiedTimeInFutureOrPast(0,0,0,0,true);
    local fourPointTodayTime = TimeUtils.GetSpecifiedTimeInFutureOrPast(0,4,0,0,true);
    local nextRefreshTime = TimeUtils.GetSpecifiedTimeInFutureOrPast(1,4,0,0,true);
    if nowtime >= zeroPointsTodayTime and nowtime <= fourPointTodayTime then
        refreshTime = fourPointTodayTime - nowtime;
    else
        refreshTime = nextRefreshTime - nowtime;
    end
    return refreshTime;
end

function GetExpireDay()
    if not mDebug then
        return mMonthCardLeftDay;
    else
        if not mMonthCardExpireTime then return 0; end
        local time = mMonthCardExpireTime - TimeUtils.SystemTimeStamp(true);
        if time < 0 then return 0; end
        return TimeUtils.TimeStamp2Date(time,true).day;
    end
end

function GetDailyAwards()
    return mMonthCardDailyDropID and ItemDropData.GetAwardItems(mMonthCardDailyDropID) or table.emptyTable;
end

function IsDailyReceived()
    return mMonthCardDailyReceived;
end
function IsSubscribed()
    return mSubscribeState;
end
function IsSubscribedReceived()
    return mSubscribeReceived;
end
function GetSubscribeAwards()
    return mSubscribeDropID and ItemDropData.GetAwardItems(mSubscribeDropID) or table.emptyTable;
end

function GetFirstSubscribeItems()
    if not mFirstSubscribeAwardItems then
        local dropID = ConfigData.GetIntValue("welfare_first_subscribe_award");--月卡首次订阅奖励

        mFirstSubscribeAwardItems = ItemDropData.GetAwardItems(dropID) or table.emptyTable;
    end
    return mFirstSubscribeAwardItems;
end

--订阅
function RequestOpenSubscribe()
    mSubscribeState = true;
    GameEvent.Trigger(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_STATE);
    GameEvent.Trigger(EVT.MONTHCARD,EVT.MONTH_CARD_BUY);
end
--取消订阅
function RequestCancelSubscribe()
    mSubscribeState = false;
    GameEvent.Trigger(EVT.MONTHCARD,EVT.MONTH_SUBSCRIBE_STATE);
    GameEvent.Trigger(EVT.MONTHCARD,EVT.MONTH_CARD_BUY);
end

function RequestGetSubscribeAward()
end

function RequestGetDailyAward()
end

function RequestBuyUsingIngot()
    --假数据，todo function
    mMonthCardExpireTime = TimeUtils.SystemTimeStamp(true)+10000;
    mMonthCardAwardRefreshTime = TimeUtils.SystemTimeStamp(true)+10000;
    GameEvent.Trigger(EVT.MONTHCARD,EVT.MONTH_CARD_BUY);
end

function RequestBuyUsingRMB()
    --假数据，todo function
    mMonthCardExpireTime = TimeUtils.SystemTimeStamp(true)+10000;
    mMonthCardAwardRefreshTime = TimeUtils.SystemTimeStamp(true)+10000;
    GameEvent.Trigger(EVT.MONTHCARD,EVT.MONTH_CARD_BUY);
end

function OnGetDailyAward(data)
end

function OnBuyUsingIngot(data)
end

function OnBuyUsingRMB(data)
end

--------------------------------------------------------------------------

return AllPackageMgr

