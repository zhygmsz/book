--[[
    author:{hesinian}
    time:2018-12-25 13:24:16
]]

module("WelfareWeekPackageData",package.seeall)

DATA.WelfareWeekPackageData.mWeekPackages = nil;
DATA.WelfareWeekPackageData.mDayAwards = nil;

local function OnLoadWelfareWeekPackageData(data)
	local datas = WelfareWeekPackage_pb.AllWeekPackages()
	datas:ParseFromString(data)

	DATA.WelfareWeekPackageData.mWeekPackages = datas.allPackages;
end
local function OnLoadDayAwardData(data)
	local datas = WelfareWeekPackage_pb.AllWeekDyaAward()
	datas:ParseFromString(data)

	DATA.WelfareWeekPackageData.mDayAwards = datas.allDayAwards;
end

function InitModule()
	local argData1 = 
	{
		keys = { mWeekPackages = true },
		fileName = "WelfareWeekPackage.bytes",
		callBack = OnLoadWelfareWeekPackageData,
	}
	local argData2 = 
	{
		keys = { mDayAwards = true },
		fileName = "WeekDayAward.bytes",
		callBack = OnLoadDayAwardData,
	}
	DATA.CREATE_LOAD_TRIGGER(DATA.WelfareWeekPackageData, argData1, argData2);
end

function GetDayAward(did)
    for i,award in ipairs(DATA.WelfareWeekPackageData.mDayAwards) do
        if award.id == did then
            return award;
        end
    end
end

function GetWeekPackage(pid)
    for i,package in ipairs(DATA.WelfareWeekPackageData.mWeekPackages) do
        if package.id == pid then
            return package;
        end
    end
end

function GetAllWeekPackages()
	return DATA.WelfareWeekPackageData.mWeekPackages;
end

return WelfareWeekPackageData;