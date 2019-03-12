module("UserData", package.seeall)

--自动释放配置技能
function GetAutoSkill(autoIndex)
	return PlayerAtt.autoSkills[autoIndex];
end

--指定槽位上装配的技能
function GetSkill(skillIndex)
	for _, skillSlotData in ipairs(PlayerAtt.skillSlots) do
		if skillIndex == skillSlotData.skillSlot then
			for _, skillAsset in ipairs(PlayerAtt.skillOpens) do
				if skillSlotData.skillID == skillAsset.skillID then
					return skillAsset;
				end
			end
		end
	end	
end

--根据技能槽位查找技能表现ID
function GetSkillUnitIDWithIndex(skillIndex)
	local skillAsset = GetSkill(skillIndex);
	if not skillAsset then return end
	local skillLevelData = SkillData.GetSkillLevelInfo(skillAsset.skillID, skillAsset.skillLevel);
	return skillLevelData and skillLevelData.unit;
end

--根据技能表现ID查找技能槽位
function GetSkillIndexWithUnitID(skillUnitID)
	for _, skillAsset in ipairs(PlayerAtt.skillOpens) do
		local skillLevelData = SkillData.GetSkillLevelInfo(skillAsset.skillID, skillAsset.skillLevel);
		if skillLevelData and skillLevelData.unit == skillUnitID then
			for _, skillSlotData in ipairs(PlayerAtt.skillSlots) do
				if skillAsset.skillID == skillSlotData.skillID then
					return skillSlotData.skillSlot;
				end
			end
		end
	end
end

--根据技能槽位查找技能CD
function GetSkillCDWithIndex(skillIndex)
	local skillUnitID = GetSkillUnitIDWithIndex(skillIndex);
	if not skillUnitID then return 0; end
	return GetSkillCD(skillUnitID);
end

--根据技能表现ID查找技能CD
function GetSkillCD(skillUnitID)
	local skillCDData = PlayerAtt.skillCDs[skillUnitID];
	if not skillCDData then return 0; end
	return skillCDData.skillCDLeftTime;
end

--更新技能等级
function UpdateSkillLevel(skillInfoList)
	for k, v in ipairs(skillInfoList) do
		for m, n in ipairs(PlayerAtt.skillOpens) do
			if v.skillId == n.skillID then
				n.skillLevel = v.skillLevel;
				break;
			end
		end
	end
end

--解锁新技能
function UnLockSkill(newSkillInfo)
	local skillInfo = {};
	skillInfo.skillID = newSkillInfo.skillId;
	skillInfo.skillLevel = newSkillInfo.skillLevel;
	table.insert(PlayerAtt.skillOpens, skillInfo);
end

--替换槽位上的技能
function SetSlotSkill(slotIndex,skillID)
	for idx,slotData in ipairs(PlayerAtt.skillSlots) do
		if slotData.skillSlot == slotIndex then
			slotData.skillID = skillID; return;
		end
	end
end

function TriggerCDEvent(skillUnitID, evtID, skillCDData)
	local skillIndex = GetSkillIndexWithUnitID(skillUnitID);
	if skillIndex then
		GameEvent.Trigger(EVT.PLAYER, evtID, skillIndex, skillCDData);
	end
end

function OnSkillCDUpdate(skillUnitID)
	local skillCDData = PlayerAtt.skillCDs[skillUnitID];
	if not skillCDData or skillCDData.skillCDFinish then return end
	local lastStamp = skillCDData.skillCDLastTime;
	skillCDData.skillCDLastTime = TimeUtils.SystemTimeStamp();
	skillCDData.skillCDLeftTime = skillCDData.skillCDLeftTime -(skillCDData.skillCDLastTime - lastStamp);
	if skillCDData.skillCDLeftTime > 0 then
		TriggerCDEvent(skillUnitID, EVT.PLAYER_CDUPDATE, skillCDData);
	else
		skillCDData.skillCDFinish = true;
		GameTimer.DeleteTimer(skillCDData.skillCDTimerID);
		TriggerCDEvent(skillUnitID, EVT.PLAYER_CDFINISH, skillCDData);
	end
end

function SetSkillCD(skillUnitID, skillCDTotalTime)
	local skillCDData = PlayerAtt.skillCDs[skillUnitID];
	if not skillCDData then skillCDData = {}; PlayerAtt.skillCDs[skillUnitID] = skillCDData; end
	skillCDData.skillCDTotalTime = skillCDTotalTime;
	skillCDData.skillCDLeftTime = skillCDTotalTime;
	skillCDData.skillCDLastTime = TimeUtils.SystemTimeStamp();
	skillCDData.skillCDTimerID = GameTimer.AddTimer(0.02, skillCDData.skillCDTotalTime * 0.05, OnSkillCDUpdate, skillUnitID);
	skillCDData.skillCDFinish = false;
	TriggerCDEvent(skillUnitID, EVT.PLAYER_CDENTER, skillCDData);
end 