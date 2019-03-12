module("FightHelpData", package.seeall)

DATA.FightHelpData.mFightHelperItemInfos = nil;
DATA.FightHelpData.mFightHelpStarInfos = nil;
DATA.FightHelpData.mFightHelpSkillInfos = nil;

local function OnLoadFightHelperInfoData(data)
	local datas = FightHelp_pb.AllFightHelpers();
	datas:ParseFromString(data);
	
	local fightHelperItemInfos = {};
	
	for k, v in ipairs(datas.fightHelperItems) do
		fightHelperItemInfos[v.id] = v;
	end
	
	DATA.FightHelpData.mFightHelperItemInfos = fightHelperItemInfos;
end

local function OnLoadFightHelpStarInfoData(data)
	local datas = FightHelp_pb.AllFightHelpStarLevels();
	datas:ParseFromString(data);
	
	local fightHelpStarInfos = {};
	
	for k, v in ipairs(datas.fightHelpStarLevelInfos) do
		fightHelpStarInfos[k] = v;
	end
	DATA.FightHelpData.mFightHelpStarInfos = fightHelpStarInfos;
end

local function OnLoadFightHelpSkillInfoData(data)
	local datas = FightHelp_pb.AllFightHelpSkills();
	datas:ParseFromString(data);
	
	local fightHelpSkillInfos = {};
	
	for k, v in ipairs(datas.fightHelpSkills) do
		fightHelpSkillInfos[v.id] = v;
	end
	DATA.FightHelpData.mFightHelpSkillInfos = fightHelpSkillInfos;
end

function InitModule()
	local argData1 =
	{
		keys = {mFightHelperItemInfos = true},
		fileName = "FightHelperItemInfo.bytes",
		callBack = OnLoadFightHelperInfoData,
	}
	
	local argData2 =
	{
		keys = {mFightHelpStarInfos = true},
		fileName = "FightHelpStarLevelInfo.bytes",
		callBack = OnLoadFightHelpStarInfoData,
	}
	
	local argData3 =
	{
		keys = {mFightHelpSkillInfos = true},
		fileName = "FightHelpSkillInfo.bytes",
		callBack = OnLoadFightHelpSkillInfoData,
	}
	
	DATA.CREATE_LOAD_TRIGGER(DATA.FightHelpData, argData1, argData2, argData3);
end

function GetFightHelperList()
	return DATA.FightHelpData.mFightHelperItemInfos;
end

function GetFihtHelperInfoById(id)
	return DATA.FightHelpData.mFightHelperItemInfos[id];
end

function GetFightHelpStarInfo(fightHelperId, starLevel)
	for k, v in ipairs(DATA.FightHelpData.mFightHelpStarInfos) do
		if v.id == fightHelperId and v.starLevel == starLevel then
			return v;
		end
	end
	return nil;
end

function GetFightHelpSkillInfoById(fightHelpSkillId)
    return DATA.FightHelpData.mFightHelpSkillInfos[fightHelpSkillId];
end

return FightHelpData; 