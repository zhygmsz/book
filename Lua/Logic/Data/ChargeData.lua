module("ChargeData",package.seeall)

DATA.ChargeData.mAllGoods = nil;
DATA.ChargeData.mAllRebates = nil;
DATA.ChargeData.mAllFirstRewards = nil;
DATA.ChargeData.mAllFirstSuits = nil;

local function OnLoadAllChargeGoods(data)
	local datas = Charge_pb.AllChargeGoods();
	datas:ParseFromString(data);
	DATA.ChargeData.mAllGoods = datas.chargeGoods;
end

local function OnLoadAllChargeRebates(data)
	local datas = Charge_pb.AllChargeRebates();
	datas:ParseFromString(data);
	DATA.ChargeData.mAllRebates = datas.chargeRebates;
end

local function OnLoadAllChargeFirstRewards(data)
	local datas = Charge_pb.AllChargeFirstRewards();
	datas:ParseFromString(data);
	DATA.ChargeData.mAllFirstRewards = datas.chargeRewards;
end

local function OnLoadAllChargeRewardSuits(data)
	local datas = Charge_pb.AllChargeRewardSuits();
	datas:ParseFromString(data);
	DATA.ChargeData.mAllFirstSuits = datas.chargeSuits;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllGoods = true },
		fileName = "ChargeGoods.bytes",
		callBack = OnLoadAllChargeGoods,
	}
	local argData2 = 
	{
		keys = { mAllRebates = true },
		fileName = "ChargeRebates.bytes",
		callBack = OnLoadAllChargeRebates,
	}
	local argData3 = 
	{
		keys = { mAllFirstRewards = true },
		fileName = "ChargeFirstRewards.bytes",
		callBack = OnLoadAllChargeFirstRewards,
	}
	local argData4 = 
	{
		keys = { mAllFirstSuits = true },
		fileName = "ChargeRewardSuit.bytes",
		callBack = OnLoadAllChargeRewardSuits,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.ChargeData,argData1,argData2,argData3,argData4);
end

function GetAllChargeGoods()
    return DATA.ChargeData.mAllGoods;
end

function GetAllChargeRebates()
    return DATA.ChargeData.mAllRebates;
end

function GetAllChargeFirstRewards()
    return DATA.ChargeData.mAllFirstRewards;
end

function GetAllChargeRewardSuits()
    return DATA.ChargeData.mAllFirstSuits;
end

return ChargeData;
