module("ChargeMgr",package.seeall)
local ChargeGoods = require("Logic/System/Charge/ChargeGoods");
local ChargeRebate = require("Logic/System/Charge/ChargeRebate");

local mChargeGoodsList = {};
local mChargeGoodsTable = {};
local mChargeRebateList = {};
local mChargeRebateTable = {};
local mCurPaySum=0;

local function InitDynamic(data)
    local chargeRecord = data.firstCharge;
    for i,record in ipairs(chargeRecord.firstPay) do
        local goods = mChargeGoodsTable[record.payId];
        goods:InitDynamic(record);
    end
    ChargeMgr.InitFirstChargeDynamic(chargeRecord,data.paySum);

    for i,info in ipairs(data.totleCharge) do
        local rebate = mChargeRebateTable[info.payId];
        rebate:InitDynamic(info.isGotGift);
    end
    if mCurPaySum~= data.paySum then
        mCurPaySum = data.paySum;
        GameEvent.Trigger(EVT.CHARGE,EVT.CHARGE_HAS_RECHARGE_UPDATEUI);
    end
end

local function InitStaticInfo()
    local goods = ChargeData.GetAllChargeGoods();
    for i,g in ipairs(goods) do
        mChargeGoodsList[i] = ChargeGoods.new(g);
        mChargeGoodsTable[g.id] = mChargeGoodsList[i];
    end

    local rebates = ChargeData.GetAllChargeRebates()
    for i,re in ipairs(rebates) do
        mChargeRebateList[i] = ChargeRebate.new(re);
        mChargeRebateTable[re.id] = mChargeRebateList[i];
    end
end

function InitModule()
    require("Logic/System/Charge/ChargeMgr_FirstReward");
end

function Init()
    InitStaticInfo();
    RequestInitCharge();
    ChargeMgr.InitFirstCharge();
end

function GetChargeGoods()
    return mChargeGoodsList;
end

function GetChargeRebates()
    return mChargeRebateList;
end
--获取当前首冲状态（0-没有充值过，1-存在今日可领取，2-存在明日或第三日可领取，3-三日全部领取完毕）
function GetFirstChargeState()
    if not ChargeMgr.HasAnyCharge() then return  0;end
    local mAward = ChargeMgr.GetFirstRewards();
    local x=0;
    if ChargeMgr.HasAnyWaitReceive() then   --等待领取
        x=1;
    elseif ChargeMgr.HasAnyWaitOpen() then  --等待开启领取
        x=2;
    elseif not ChargeMgr.NeedShowEntry() then  --全部领取完毕
        x=3;
    end
    return x;
end

--我拥有的元宝数量
function GetMyIngotCount()
    return BagMgr.GetMoney(Coin_pb.INGOT);
end
--获取当前充值进度
function GetPaySum()
    return mCurPaySum or 0;
end
--请求充值相关信息
function RequestInitCharge()
    local msg = NetCS_pb.CSAskPayInfo();
    GameNet.SendToGate(msg);
end
--充值相关信息请求回调
function OnInitCharge(data)
    InitDynamic(data);
end

function RequestBuyGoods(goods)
    local gmCommand = string.format("109 %s",goods:GetID());
    GameNet.SendGMCommand(gmCommand);
    GameLog.LogError(" Buy Goods With GM "..gmCommand);
end

-- 累充奖励
function RequestReceiveRebate(rebate)
    local msg = NetCS_pb.CSAskPayReward();
    msg.payType = NetCS_pb.TOTOLEPAY;--FIRSTPAY
    msg.payId = rebate:GetID();
    GameNet.SendToGate(msg);
    GameLog.LogError("Request Receive Rebate %s",msg.payId);
end

--元宝数值千分制
--author sjz
--time 2019-2-18 11:36
function NumberFormatPerMille(num,deperator)
    local str1 =""
    local str = tostring(num)
    local strLen = string.len(str)
        
    if deperator == nil then
        deperator = ","
    end
    deperator = tostring(deperator)
        
    for i=1,strLen do
        str1 = string.char(string.byte(str,strLen+1 - i)) .. str1
        if math.fmod(i,3) == 0 then
            if strLen - i ~= 0 then
                str1 = ","..str1
            end
        end
    end
    return str1
end


return ChargeMgr;
