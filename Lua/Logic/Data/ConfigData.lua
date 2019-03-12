module("ConfigData",package.seeall)

DATA.ConfigData.mStrMap = nil;

local function OnLoadConfigData(data)
	local datas = ConfigData_pb.AllConfigData()
	datas:ParseFromString(data)

	local strMap = {};

	for _,v in ipairs(datas.tlist) do
		strMap[v.var_key] = v;
	end

	DATA.ConfigData.mStrMap = strMap;
end

local function GetConfigValue(key)
	local configData = DATA.ConfigData.mStrMap[key];
	if configData then
		if configData.valueType == 0 then
			return configData.stringValue;
		elseif configData.valueType == 1 then
			return configData.intValue / 10000.0;
		elseif configData.valueType == 2 then
			return configData.intValue;
		end
	end
end

function InitModule()
	local argData = 
	{
		keys = { mStrMap = true },
		fileName = "ConfigData.bytes",
		callBack = OnLoadConfigData,
	}
	DATA.CREATE_LOAD_TRIGGER(DATA.ConfigData,argData);
end

function GetStringValue(key)
	return GetConfigValue(key);
end

function GetIntValue(key)
	return GetConfigValue(key);
end

function GetFloatValue(key)
	return GetConfigValue(key);
end

function GetValue(key)
	return GetConfigValue(key);
end

return ConfigData;
