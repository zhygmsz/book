module("ResConfigData",package.seeall)

DATA.ResConfigData.mAllResConfigs = nil;

local function OnLoadResConfigData(data)
    local datas = ResConfig_pb.AllResConfig()
    datas:ParseFromString(data)

    local resConfigDatas = {};

    for k,v in ipairs(datas.datas) do
        resConfigDatas[v.name] = v.id;
    end

    DATA.ResConfigData.mAllResConfigs = resConfigDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllResConfigs = true },
		fileName = "ResData.bytes",
		callBack = OnLoadResConfigData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.ResConfigData,argData1);
end

function GetResConfigID(fileName)
    if fileName == "" then return end
    local configID = DATA.ResConfigData.mAllResConfigs[fileName] or GameAsset[fileName]
    if not configID then GameLog.LogError("can't find asset id for %s",fileName); end
    return configID;
end

return ResConfigData;