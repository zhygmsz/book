module("BuffData",package.seeall)

DATA.BuffData.mBuffDatas = nil;
DATA.BuffData.mBuffEffectDatas = nil;
DATA.BuffData.mBuffLayerDatas = nil;
DATA.BuffData.mBuffBoneDatas = nil;

local function OnLoadBuffData(data)
	local datas = StatusInfo_pb.AllStatuses();
	datas:ParseFromString(data);
	
	local buffDatas = {};

	for k,v in ipairs(datas.statuses) do
		buffDatas[v.id] = v;
	end

	DATA.BuffData.mBuffDatas = buffDatas;
end

local function OnLoadBuffEffectData(data)
	local datas = StatusInfo_pb.AllStatusEffects();
	datas:ParseFromString(data);

	local buffEffectDatas = {};

	for k,v in ipairs(datas.effects) do
		buffEffectDatas[v.id] = v;
	end

	DATA.BuffData.mBuffEffectDatas = buffEffectDatas;
end

local function OnLoadBuffLayerData(data)
    local datas = StatusInfo_pb.AllStatusLayer()
    datas:ParseFromString(data)

    local layerDatas = {};

    for k,v in ipairs(datas.datas) do
        layerDatas[v.layer] = v
    end

    DATA.BuffData.mBuffLayerDatas = layerDatas;	
end

local function OnLoadBuffBoneData(data)
    local datas = StatusInfo_pb.AllStatusBones()
	datas:ParseFromString(data)
	
	local boneDatas = {};
	for k,v in ipairs(datas.datas) do
		boneDatas[v.id] = v;
	end

	DATA.BuffData.mBuffBoneDatas = boneDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mBuffDatas = true },
		fileName = "StatusInfo.bytes",
		callBack = OnLoadBuffData,
	}
	local argData2 = 
	{
		keys = { mBuffEffectDatas = true },
		fileName = "StatusEffect.bytes",
		callBack = OnLoadBuffEffectData,
	}
	local argData3 = 
	{
		keys = { mBuffLayerDatas = true },
		fileName = "StatusLayer.bytes",
		callBack = OnLoadBuffLayerData,
	}
	local argData4 = 
	{
		keys = { mBuffBoneDatas = true },
		fileName = "StatusBone.bytes",
		callBack = OnLoadBuffBoneData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.BuffData,argData1,argData2,argData3,argData4);
end

function GetBuffData(id)
	return DATA.BuffData.mBuffDatas[id];
end

function GetBuffEffectData(id)
	return DATA.BuffData.mBuffEffectDatas[id];
end

function GetBuffLayerData(layer)
	return DATA.BuffData.mBuffLayerDatas[layer];
end

function GetBuffBoneData(buffBoneID)
	return DATA.BuffData.mBuffBoneDatas[buffBoneID];
end

function GetBuffIcon(layer)
	local buffLayerData = GetBuffLayerData(layer);
	return buffLayerData and buffLayerData.icon or "";
end

return BuffData;

