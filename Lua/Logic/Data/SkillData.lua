module("SkillData", package.seeall)

DATA.SkillData.mAllSkillInfos = nil;
DATA.SkillData.mAllSkillLevels = nil;
DATA.SkillData.mAllSkillUnitIDs = nil;
DATA.SkillData.mAllSkillParams = nil;
DATA.SkillData.mAllCommonSkillInfos = nil;
DATA.SkillData.mAllInterestSkillInfos = nil;
DATA.SkillData.mAllSkillUnits = {};

local function OnLoadSkillInfoData(data)
	local datas = SkillInfo_pb.AllSkills();
	datas:ParseFromString(data);
	
	local skillInfos = {};
	
	for k, v in ipairs(datas.skills) do
		skillInfos[v.id] = v;
	end
	
	DATA.SkillData.mAllSkillInfos = skillInfos;
end

local function OnLoadSkillLevelData(data)
	local datas = SkillInfo_pb.AllSkillLevels();
	datas:ParseFromString(data);
	
	local skillLevelDatas = {};
	
	for k, v in ipairs(datas.levels) do
		skillLevelDatas[v.id] = skillLevelDatas[v.id] or {};
		skillLevelDatas[v.id] [v.level] = v;
	end
	
	DATA.SkillData.mAllSkillLevels = skillLevelDatas;
end

local function OnLoadSkillUnitData(data, unitID)
	local datas = Skill_pb.Skill();
	datas:ParseFromString(data);
	
	DATA.SkillData.mAllSkillUnits[unitID] = datas;
end

local function OnLoadSkillIDData(data)
	local datas = SkillInfo_pb.AllSkillIDs();
	datas:ParseFromString(data);
	
	local allSkillUnitIDs = {};
	
	for k, v in ipairs(datas.skills) do
		allSkillUnitIDs[v.id] = v.strID;
	end
	
	DATA.SkillData.mAllSkillUnitIDs = allSkillUnitIDs;
end

local function OnLoadSkillParamData(data, param)
	local datas = SkillInfo_pb.AllSkillFillingInfos();
	datas:ParseFromString(data);
	
	local allSkillParams = {};
	
	for k, v in ipairs(datas.infos) do
		local skillInfoParams = allSkillParams[v.skillInfoID] or {};
		local skillLevelParams = skillInfoParams[v.level] or {};
		
		for _, paramInfo in ipairs(v.buff) do
			skillLevelParams[paramInfo.id] = paramInfo.value;
		end
		for _, paramInfo in ipairs(v.hits) do
			skillLevelParams[paramInfo.id] = paramInfo.value;
		end
		
		skillInfoParams[v.level] = skillLevelParams;
		allSkillParams[v.skillInfoID] = skillInfoParams;
	end
	
	DATA.SkillData.mAllSkillParams = allSkillParams;
end

function OnLoadCommonSkillData(data)
	local datas = SkillAuxiliaryInfo_pb.AllCommonSkills();
	datas:ParseFromString(data);
	
	local allCommonSkills = {};
	
	for k, v in ipairs(datas.commonSkills) do
		allCommonSkills[k] = v;
	end
	
	DATA.SkillData.mAllCommonSkillInfos = allCommonSkills;
end

function OnLoadInterestSkillData(data)
	local datas = SkillAuxiliaryInfo_pb.AllInterestSkillInfos();
	datas:ParseFromString(data);
	
	local allInterestSkills = {};
	
	for k, v in ipairs(datas.interestSkills) do
		allInterestSkills[v.id] = v;
	end
	
	DATA.SkillData.mAllInterestSkillInfos = allInterestSkills;
end

function InitModule()
	local argData1 =
	{
		keys = {mAllSkillInfos = true},
		fileName = "SkillInfo.bytes",
		callBack = OnLoadSkillInfoData,
	}
	local argData2 =
	{
		keys = {mAllSkillLevels = true},
		fileName = "SkillLevelInfo.bytes",
		callBack = OnLoadSkillLevelData,
	}
	local argData3 =
	{
		keys = {mAllSkillUnitIDs = true},
		fileName = "SkillID.bytes",
		callBack = OnLoadSkillIDData,
	}
	local argData4 =
	{
		keys = {mAllSkillParams = true},
		fileName = "SkillFillingInfo.bytes",
		callBack = OnLoadSkillParamData,
	}
	local argData5 =
	{
		keys = {mAllCommonSkillInfos = true},
		fileName = "CommonSkillInfo.bytes",
		callBack = OnLoadCommonSkillData,
	}
	local argData6 =
	{
		keys = {mAllInterestSkillInfos = true},
		fileName = "InterestSkillInfo.bytes",
		callBack = OnLoadInterestSkillData,
	}
	DATA.CREATE_LOAD_TRIGGER(DATA.SkillData, argData1, argData2, argData3, argData4, argData5, argData6);
end

function GetSkillLevelInfo(id, level)
	local skills = DATA.SkillData.mAllSkillLevels[id];
	return skills and skills[level] or nil;
end

function GetSkillInfo(id)
	return DATA.SkillData.mAllSkillInfos[id];
end

function GetSkillUnitData(unitID)
	local skillUnitID = DATA.SkillData.mAllSkillUnitIDs[unitID];
	if not skillUnitID then return nil end
	local skillUnitData = DATA.SkillData.mAllSkillUnits[unitID];
	if not skillUnitData then
		local unitFileName = "Skill/Skill_" .. skillUnitID .. ".bytes";
		ResMgr.LoadBytes(unitFileName, OnLoadSkillUnitData, unitID);
	end
	return DATA.SkillData.mAllSkillUnits[unitID];
end

function GetSkillParam(skillInfoID, level, paramID)
	local skillParams = DATA.SkillData.mAllSkillParams[skillInfoID];
	if skillParams then
		local skillLevelParams = skillParams[level];
		return skillLevelParams and skillLevelParams[paramID];
	end
end

function GetInitSkillIdBySlotIndex(slotIndex)
	local playerSkillInfo = UserData.PlayerAtt.playerData.initSkillSlots;
	for k, v in ipairs(playerSkillInfo) do
		if slotIndex == v.skillSlot then
			return v.skillID
		end
	end
	return - 1;
end

function GetAllCommonSkillInfo()
	return DATA.SkillData.mAllCommonSkillInfos;
end

function GetCommonSkillSource(skillId)
	for k, v in ipairs(DATA.SkillData.mAllCommonSkillInfos) do
		for m, n in ipairs(v.skillList) do
			if skillId == n.skillId then
				return v.source;
			end
		end
	end
	return nil;
end

function GetAllInterestSkill()
	local interestSkillList = {};
	for k, v in ipairs(DATA.SkillData.mAllInterestSkillInfos) do
		table.insert(interestSkillList, v.skillId);
	end
	return interestSkillList;
end

function GetInterestSkillInfoBySkillId(skillId)
	for k, v in ipairs(DATA.SkillData.mAllInterestSkillInfos) do
		if v.skillId == skillId then
			return v
		end
	end
	return nil;
end

return SkillData;
