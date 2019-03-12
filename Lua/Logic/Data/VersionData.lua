--[[
    author:{hesinian}
    time:2019-01-15 17:22:13
]]

module("VersionData",package.seeall)
local Json = require "cjson" 

DATA.VersionData.mVersions = nil;

local function OnLoadVersionData(str)
	local datas = Json.decode(str);

	DATA.VersionData.mVersions = datas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mVersions = true },
		fileName = "Version.bytes",
		callBack = OnLoadVersionData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.VersionData,argData1);
end

function GetSNSVersion()
    return DATA.VersionData.mVersions.SnsVersion;
end

function GetMajorVer()
    return DATA.VersionData.mVersions.MajorVersionNumber;
end

function GetMinorVer()
    return DATA.VersionData.mVersions.MinorVersionNumber;
end

function GetRevisionNumber()
    return DATA.VersionData.mVersions.RevisionNumber;
end

return VersionData;