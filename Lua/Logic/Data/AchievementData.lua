module("AchievementData",package.seeall)

DATA.AchievementData.mAllAchiInfos = nil;
DATA.AchievementData.mAllAchiTypes = nil;
DATA.AchievementData.mAllAchiRanks = nil;
DATA.AchievementData.mAllAchiLevels = nil;

local function OnLoadAchievementInfos(data)
	local datas = Achievement_pb.AllAchievementInfos();
	datas:ParseFromString(data);
	DATA.AchievementData.mAllAchiInfos = datas.achievementInfos;
end

local function OnLoadAchievementTypes(data)
	local datas = Achievement_pb.AllAchievementTypes();
	datas:ParseFromString(data);
	DATA.AchievementData.mAllAchiTypes = datas.achievementTypes;
end

local function OnLoadAchievementRankInfos(data)
	local datas = Achievement_pb.AllAchievementRankInfos();
	datas:ParseFromString(data);
	DATA.AchievementData.mAllAchiRanks = datas.achievementRankInfos;
end

local function OnLoadAchievementLevelInfos(data)
	local datas = Achievement_pb.AllAchievementLevelInfos();
	datas:ParseFromString(data);
	DATA.AchievementData.mAllAchiLevels = datas.achievementLevelInfos;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllAchiInfos = true },
		fileName = "AchievementInfo.bytes",
		callBack = OnLoadAchievementInfos,
	}
	local argData2 = 
	{
		keys = { mAllAchiTypes = true },
		fileName = "AchievementType.bytes",
		callBack = OnLoadAchievementTypes,
	}
	local argData3 = 
	{
		keys = { mAllAchiRanks = true },
		fileName = "AchievementRankInfo.bytes",
		callBack = OnLoadAchievementRankInfos,
	}
	local argData4 = 
	{
		keys = { mAllAchiLevels = true },
		fileName = "AchievementLevelInfo.bytes",
		callBack = OnLoadAchievementLevelInfos,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.AchievementData,argData1,argData2,argData3,argData4);
end

function GetAllAchievementList()
    return DATA.AchievementData.mAllAchiInfos;
end

function GetCatalogueInfoList()
    return DATA.AchievementData.mAllAchiTypes;
end

function GetLevelStandards()
    return DATA.AchievementData.mAllAchiLevels;
end

function GetRankStandards()
    return DATA.AchievementData.mAllAchiRanks;
end

return AchievementData;
