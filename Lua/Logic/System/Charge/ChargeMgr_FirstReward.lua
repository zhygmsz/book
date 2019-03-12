--首充奖励
module("ChargeMgr",package.seeall)
local ChargeFirstReward = require("Logic/System/Charge/ChargeFirstReward");
local ChargeRewardSuit = require("Logic/System/Charge/ChargeRewardSuit");

local mFirstChargeRewards = {};--每日奖品清单
local mFristChargeTable = {};
local mSuitList = {};--奖励套装

local mAnyCharge = false;
local mIsFirstRequest = true;

local function InitStatic()
    local firstRewards = ChargeData.GetAllChargeFirstRewards()
    for i,re in ipairs(firstRewards) do
        mFirstChargeRewards[i] =  ChargeFirstReward.new(re);
        mFristChargeTable[re.id] = mFirstChargeRewards[i];
    end
    local suits = ChargeData.GetAllChargeRewardSuits();
    
    for i,suit in ipairs(suits) do
        if suit.id == UserData.GetRacial() then
            table.insert(mSuitList, ChargeRewardSuit.new(suit.color1Show,1));
            table.insert(mSuitList, ChargeRewardSuit.new(suit.color2Show,2));
            table.insert(mSuitList, ChargeRewardSuit.new(suit.color3Show,3));
            break;
        end
    end
end

function InitFirstChargeDynamic(data,paysum)
    if mIsFirstRequest then
        mIsFirstRequest=false;
        if data.day1Gift == 1 or data.day2Gift==1 or data.day3Gift==1 then
            if UserData.IsFirstTimeLoginToday() then
                UIMgr.ShowUI(AllUI.UI_ChargeFirst);
            end
        end
        if paysum>0  then
            SetAnyChange(true);
        end
    else
        if not HasAnyCharge() and paysum>0 then
            SetAnyChange(true);
            UIMgr.ShowUI(AllUI.UI_ChargeFirst);
        end
    end
    mFirstChargeRewards[1]:SetState(data.day1Gift);
    mFirstChargeRewards[2]:SetState(data.day2Gift);
    mFirstChargeRewards[3]:SetState(data.day3Gift);
end

function InitFirstCharge()
    InitStatic();
end

--==============================--
--是否打开过首充UI，如果没有，在首次打次充值界面的时候会打开首充界面
function SetEntryUI(value)
    UserData.SetOpenFirstChargeUIRecord(true);
end
function GetEntryUI()
    return UserData.GetOpenFirstChargeUIRecord();
end

--是否有过充值的临时方法，以后服务器通知未做
function SetAnyChange(value)
    if value ~= mAnyCharge then
        mAnyCharge = value;
        GameEvent.Trigger(EVT.CHARGE,EVT.CHARGE_HAS_ANY_CHARGE,mAnyCharge);
    end
end
function HasAnyCharge()
    return mAnyCharge;
end    

--获得所有的首充奖励项
function GetFirstRewards()
    return mFirstChargeRewards;
end

function HasAnyWaitOpen()
    if not HasAnyCharge() then return false; end
    
    for i,reward in ipairs(mFirstChargeRewards) do
        if reward:IsWaitOpen() then
            return true;
        end
    end
    return false;
end

function HasAnyWaitReceive()
    if not HasAnyCharge() then return false; end
    
    for i,reward in ipairs(mFirstChargeRewards) do
        if reward:IsWaitReceiving() then
            return true;
        end
    end
    return false;
end

----是否需要展示首充入口
function NeedShowEntry()
    for _,reward in ipairs(mFirstChargeRewards) do
        if not reward:HasReceived() then return true; end
    end
    return false;
end

function GetSuitList()
    return mSuitList;
end
--初始化首充奖励

function OnInitFirstChargeAward(data)
    InitDynamic(data);
end

--领取奖励
function RequestReceiveAward(award,color)
    local msg = NetCS_pb.CSAskPayReward();
    msg.payType = NetCS_pb.FIRSTPAY;--首充奖励
    msg.dayId = award:GetID();
    msg.clothColor = color;--//1,2,3对应奖励时装表的三列
    GameNet.SendToGate(msg);
end

--改变奖励的状态
function OnChangeRewardState(data)
    mFristChargeTable[data.id]:SetState(data.state);
    if not NeedShowEntry() then
        GameEvent.Trigger(EVT.CHARGE,EVT.CHARGE_FIRST_REWARD_ENTRY);--关闭首充入口
    end
end