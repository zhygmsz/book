module("SkillMgr", package.seeall);
local CommonSkillData = require("Logic/Presenter/UI/Skill/WrapUI/CommonSkillData")

local mInterestSkillList = {};
local mCommonSkillList = {};
local mCommonLabelList = {};

local mNormalSkillSlotList = {};
local mInterestSkillSlotList = {};

local mSortedCommonSkillList = {};
local mFilteredCommonSkillList = {};
local mFilteredInterestSkillList = {};

local InitNetFlag = false;
local InitNormalFlag = false;

local NORMAL_SKILL_SLOT_COUNT = 6;
local INTEREST_SKILL_SLOT_COUNT = 5;

local SkillTipType = {
	PlayerSkillType = 1;
	NpcSkillType = 2;
}

function InitModule()
	require("Logic/Presenter/UI/Skill/UI_Tip_SkillInfo");
end

--初始化技能槽
function InitNormalSkillSlotInfo()
	if not InitNormalFlag then
		for i = 1, NORMAL_SKILL_SLOT_COUNT do
			local skillItem = {};
			skillItem.id = - 1;
			local skillInfo = UserData.PlayerAtt.playerData.initSkillSlots[i];
			if skillInfo ~= nil then
				skillItem.id = skillInfo.skillID;
			end
			skillItem.level = 0;
			table.insert(mNormalSkillSlotList, skillItem);
		end
		InitNormalFlag = true;
	end
end

function InitInterestSkillSlotInfo()
	for i = 1, INTEREST_SKILL_SLOT_COUNT do
		table.insert(mInterestSkillSlotList, - 1);
	end
end

--根据槽位索引获取技能信息
function GetSkillInfoBySlotIndex(slotIndex)
	return mNormalSkillSlotList[slotIndex];
end

--获取所有Common技能标签集合
function GetCommonSkillLabelList()
	if next(mCommonLabelList) == nil then
		local commonSkillList = SkillData.GetAllCommonSkillInfo();
		for k, v in ipairs(commonSkillList) do
			for r, m in ipairs(v.skillList) do
				for p, q in ipairs(m.filterList) do
					local isFind = false;
					for d, f in ipairs(mCommonLabelList) do
						if f == q then
							isFind = true;
							break;
						end
					end
					if not isFind then
						table.insert(mCommonLabelList, q);
					end
				end
			end
		end
	end
	return mCommonLabelList;
end

function UpdateSortedCommonSkillList()
	table.clear(mSortedCommonSkillList)
	local function commonSkillSortFun(a, b)
		local ai = a.skillId;
		local bi = b.skillId;
		local al = a.skillLevel;
		local bl = b.skillLevel;
		if al == bl then
			return ai < bi;
		else
			return al > bl;
		end
	end
	table.sort(mCommonSkillList, commonSkillSortFun);
	
	local commonSkillList = SkillData.GetAllCommonSkillInfo();
	for k, v in ipairs(commonSkillList) do
		local skillGroupItem = CommonSkillData.new(v.id);
		skillGroupItem:SetGroupSource(v.source);
		local skillList = {};
		for m, n in ipairs(mCommonSkillList) do
			local skillSource = SkillData.GetCommonSkillSource(n.skillId);
			if skillSource == v.source then
				local skillItem = {};
				skillItem.skillId = n.skillId;
				skillItem.isActive = true;
				table.insert(skillList, skillItem);
			end
		end
		for m, n in ipairs(v.skillList) do
			local isFind = false;
			for p, q in ipairs(skillList) do
				if q.skillId == n.skillId and q.isActive == true then
					q.filterList = n.filterList;
					isFind = true;
				end
			end
			if not isFind then
				local skillItem = {};
				skillItem.skillId = n.skillId;
				skillItem.filterList = n.filterList;
				skillItem.isActive = false;
				table.insert(skillList, skillItem);
			end
		end
		skillGroupItem:SetSkillList(skillList);
		table.insert(mSortedCommonSkillList, skillGroupItem);
	end
end

--获取筛选后的江湖技能列表
function GetFilterSkillList(filterContent)
	if filterContent == WordData.GetWordStringByKey("skill_filter_all") then
		return mSortedCommonSkillList;
	else
		table.clear(mFilteredCommonSkillList);
		for k, v in ipairs(mSortedCommonSkillList) do
			local isFind = false;
			local skillList = {};
			for m, n in ipairs(v._skillList) do
				for p, q in ipairs(n.filterList) do
					if filterContent == q then
						local skillItem = {};
						skillItem.skillId = n.skillId;
						skillItem.isActive = n.isActive;
						skillItem.filterList = n.filterList;
						table.insert(skillList, skillItem);
						isFind = true;
					end
				end
			end
			if isFind == true then
				local skillGroupItem = CommonSkillData.new(v._id);
				skillGroupItem:SetGroupSource(v._source);
				skillGroupItem:SetSkillList(skillList);
				table.insert(mFilteredCommonSkillList, skillGroupItem);
			end
		end
		return mFilteredCommonSkillList;
	end
end

--获取江湖技能信息
function GetCommonSkillInfo(skillId)
	for k, v in ipairs(mCommonSkillList) do
		if v.skillId == skillId then
			return v;
		end
	end
	return nil;
end

--获取趣味技能列表
function GetInterestSkillList()
	return mInterestSkillList;
end

--获取筛选后的趣味技能列表
function GetFilteredInterestSkillList(filterContent)
	if filterContent == WordData.GetWordStringByKey("skill_filter_all") then
		return mInterestSkillList;
	else
		table.clear(mFilteredInterestSkillList);
		for k, v in ipairs(mInterestSkillList) do
			local skillInfo = SkillData.GetInterestSkillInfoBySkillId(v);
			if skillInfo ~= nil then
				local filterInfoList = skillInfo.filterList;
				for m, n in ipairs(filterInfoList) do
					if n == filterContent then
						table.insert(mFilteredInterestSkillList, v);
						break;
					end
				end
			end
		end
		return mFilteredInterestSkillList;
	end
end

--获取趣味技能筛选选项
function GetInterestSkillFilterList()
	local interestSkillList = GetInterestSkillList();
	local skillFilterList = {};
	for k, v in ipairs(interestSkillList) do
		local skillInfo = SkillData.GetInterestSkillInfoBySkillId(v);
		if skillInfo ~= nil then
			local filterInfoList = skillInfo.filterList;
			for m, n in ipairs(filterInfoList) do
				local isFind = false;
				for p, q in ipairs(skillFilterList) do
					if q == n then
						isFind = true;
						break;
					end
				end
				if not isFind then
					table.insert(skillFilterList, n);
				end
			end
		end
	end
	return skillFilterList;
end

--向服务器请求技能数据
function RequestSkillData()
	local commonSkillMsg = NetCS_pb.CSOrgSkillInfo();
	GameNet.SendToGate(commonSkillMsg);
	
	local interestSkillMsg = NetCS_pb.CSAmusSkillInfo();
	GameNet.SendToGate(interestSkillMsg);
	
	local interestSkillSlotMsg = NetCS_pb.CSSkillSdShowInfo();
	GameNet.SendToGate(interestSkillSlotMsg);
end

--获取江湖技能数据
function OnGetCommonSkillInfo(msg)
	InitNetFlag = true;
	local commonSkillInfo = msg.orgSkillInfos;
	for k, v in ipairs(commonSkillInfo.orgSkillInfos) do
		local netSkillInfo = v.skillInfo;
		local skillInfo = {};
		skillInfo.skillId = netSkillInfo.skillTempID;
		skillInfo.skillLevel = netSkillInfo.skillLevel;
		table.insert(mCommonSkillList, skillInfo);
	end
	UpdateSortedCommonSkillList();
end

--获取趣味技能数据
function OnGetInterestSkillInfo(msg)
	InitNetFlag = true;
	local interestSkillInfo = msg.amusSkillInfos;
	for k, v in ipairs(interestSkillInfo.amusSkillInfos) do
		local skillId = v.skillTempID;
		table.insert(mInterestSkillList, skillId);
	end
end

--从UserData获取普通技能槽位数据
function InitNormalSkillSlotInfoFromUserData()
	InitNormalSkillSlotInfo();
	for k, v in ipairs(mNormalSkillSlotList) do
		local skillInfo = UserData.GetSkill(k);
		if skillInfo then
			v.id = skillInfo.skillID;
			v.level = skillInfo.skillLevel;
		end
	end
end

--获取趣味技能槽位数据
function OnGetInterestSkillSlotInfo(msg)
	InitNetFlag = true;
	InitInterestSkillSlotInfo();
	local interestSkillSlotInfo = msg.sdSkillListShow;
	for k, v in ipairs(interestSkillSlotInfo) do
		if mInterestSkillSlotList[v.skillIndex + 1] ~= nil then
			mInterestSkillSlotList[v.skillIndex + 1] = v.skillTempID;
		end
	end
	GameEvent.Trigger(EVT.SKILL, EVT.UPDATE_INTEREST_SKILL_VIEW);
end

--技能升级
function RequestNormalSkillLevelUp(type, skillId)
	local skillLevelUpMsg = NetCS_pb.CSComSkillLiftLevel();
	skillLevelUpMsg.operType = type;
	skillLevelUpMsg.skillTempID = skillId;
	GameNet.SendToGate(skillLevelUpMsg);
end

--普通技能升级
function OnNormalSkillLevelUp(msg)
	if msg.ret ~= 0 then return; end
	local skillLevelUpInfoList = {};
	local levelUpSkillList = msg.skillUtInfo;
	for k, v in ipairs(levelUpSkillList) do
		for m, n in ipairs(mNormalSkillSlotList) do
			if n.id == v.skillInfo.skillTempID then
				local levelUpItem = {};
				levelUpItem.skillId = v.skillInfo.skillTempID;
				levelUpItem.skillLevel = v.skillInfo.skillLevel;
				table.insert(skillLevelUpInfoList, levelUpItem)
				if mNormalSkillSlotList[m].level == 0 then
					--发送解锁技能消息
					GameEvent.Trigger(EVT.SKILL, EVT.SLOT_SKILL_UNLOCK, m);
				end
				mNormalSkillSlotList[m].level = v.skillInfo.skillLevel;
				break;
			end
		end
	end
	GameEvent.Trigger(EVT.SKILL, EVT.SLOT_SKILL_LEVEL_UP, skillLevelUpInfoList);
	UserData.UpdateSkillLevel(skillLevelUpInfoList);
end

--技能解锁消息
function OnNormalSkillUpdate(msg)
	if msg.updateType == NetCS_pb.SCComSkillUpdate.Up_ADD then
		local skillInfo = msg.skillUtInfo;
		local skillLevelUpInfoList = {};
		local levelUpItem = {};
		local slotIndex = - 1;
		levelUpItem.skillId = skillInfo.skillInfo.skillTempID;
		levelUpItem.skillLevel = skillInfo.skillInfo.skillLevel;
		table.insert(skillLevelUpInfoList, levelUpItem);
		for m, n in ipairs(mNormalSkillSlotList) do
			if n.id == skillInfo.skillInfo.skillTempID then
				slotIndex = m;
				n.level = skillInfo.skillInfo.skillLevel;
				--发送解锁技能消息
				GameEvent.Trigger(EVT.SKILL, EVT.SLOT_SKILL_UNLOCK, m);
				break;
			end
		end
		GameEvent.Trigger(EVT.SKILL, EVT.SLOT_SKILL_LEVEL_UP, skillLevelUpInfoList);
		UserData.UnLockSkill(levelUpItem);
		UserData.SetSlotSkill(slotIndex, levelUpItem.skillId);
	end
end

--江湖技能学习
function RequestCommonSkillStudy(skillId)
	local commonSkillStudyMsg = NetCS_pb.CSOrgSkillLearn();
	commonSkillStudyMsg.skillTempID = skillId;
	GameNet.SendToGate(commonSkillStudyMsg);
end
 
function OnCommonSkillStudy(msg)
	if msg.ret ~= 0 then return; end
	local netSkillInfo = msg.skillUtInfo.skillInfo;
	local newSkillInfo = {};
	newSkillInfo.skillId = netSkillInfo.skillTempID;
	newSkillInfo.skillLevel = netSkillInfo.skillLevel;
	table.insert(mCommonSkillList, newSkillInfo);
	UpdateSortedCommonSkillList();
	--更新排序列表拥有信息
	--向技能界面发送消息
	--更西门技能界面拥有信息（是否重排）
	UserData.UnLockSkill(newSkillInfo);
	GameEvent.Trigger(EVT.SKILL, EVT.Common_SKILL_STUDY, newSkillInfo.skillId);
end

--江湖技能装备
function RequestCommonSkillEquip(skillId)
	local commonSkillEquipMsg = NetCS_pb.CSOrgSkillFitting();
	commonSkillEquipMsg.skillTempID = skillId;
	GameNet.SendToGate(commonSkillEquipMsg);
end

function OnCommonSkillEquip(msg)
	if msg.ret ~= 0 then return; end
	local netSkillInfo = msg.skillUtInfo.skillInfo;
	
	local commonSlotInfo = mNormalSkillSlotList[5];
	if commonSlotInfo.id ~= - 1 and commonSlotInfo.level ~= 0 then
		GameEvent.Trigger(EVT.SKILL, EVT.Common_SKILL_EQUIPED, commonSlotInfo.id, false);
	end
	
	mNormalSkillSlotList[5].id = netSkillInfo.skillTempID;
	mNormalSkillSlotList[5].level = netSkillInfo.skillLevel;
	GameEvent.Trigger(EVT.SKILL, EVT.Common_SKILL_EQUIPED, netSkillInfo.skillTempID, true);
	UserData.SetSlotSkill(5, commonSlotInfo.id);
end

--江湖技能升星
function RequestCommonSkillLevelUp(type, skillId)
	local commonSkillLevelUpMsg = NetCS_pb.CSOrgSkillLiftStar();
	commonSkillLevelUpMsg.operType = type;
	commonSkillLevelUpMsg.skillTempID = skillId;
	GameNet.SendToGate(commonSkillLevelUpMsg);
end

function OnCommonSkillLevelUp(msg)
	if msg.ret ~= 0 then return; end
	local netSkillInfo = msg.skillUtInfo.skillInfo;
	for k, v in ipairs(mCommonSkillList) do
		if v.skillId == netSkillInfo.skillTempID then
			mCommonSkillList[k].skillLevel = netSkillInfo.skillLevel;
			break;
		end
	end
	--向技能界面发送消息
	GameEvent.Trigger(EVT.SKILL, EVT.Common_SKILL_STUDY, netSkillInfo.skillTempID);
end

--趣味技能更新
function OnInterestSkillUpdate(msg)
	local netSkillInfo = msg.skillUtInfo;
	table.insert(mInterestSkillList, netSkillInfo.skillTempID);
	--向技能界面发送消息
	GameEvent.Trigger(EVT.SKILL, EVT.INTEREST_SKILL_ADD, netSkillInfo.skillTempID);
end

--趣味技能装备
function RequestInterestSkillEquip(slotIndex, skillId)
	local interestSkillEquipMsg = NetCS_pb.CSAmusSkillFitting();
	interestSkillEquipMsg.skillIndex = slotIndex - 1;
	interestSkillEquipMsg.skillTempID = skillId;
	GameNet.SendToGate(interestSkillEquipMsg);
end

--趣味技能装配
function OnInterestSkillEquip(msg)
	if msg.ret ~= 0 then return; end
	local interestSkillEquipInfo = msg.amusSkillUtInfo;
	local equipInfoList = {};
	for k, v in ipairs(interestSkillEquipInfo) do
		if mInterestSkillSlotList[v.skillIndex + 1] ~= nil then
			mInterestSkillSlotList[v.skillIndex + 1] = v.skillTempID;
			local equipInfo = {};
			equipInfo.slotIndex = v.skillIndex + 1;
			equipInfo.skillId = v.skillTempID;
			table.insert(equipInfoList, equipInfo);
		end
	end
	GameEvent.Trigger(EVT.SKILL, EVT.INTEREST_SKILL_EQUIP, equipInfoList);
end

function GetIsInitByNetInfo()
	return InitNetFlag;
end

--获取江湖技能是否处于装配状态
function GetCommonSkillIsEquiped(skillId)
	local slotInfo = mNormalSkillSlotList[5];
	if slotInfo.id == skillId and slotInfo.level ~= 0 then
		return true;
	else
		return false;	
	end
end

--获取装配的江湖技能
function GetEquipedSkillId()
	local slotInfo = mNormalSkillSlotList[5];
	if slotInfo.level ~= 0 then
		return slotInfo.id;	
	end
	return - 1;
end

--获取指定槽位上的趣味技能
function GetInterestSkillIdBySlotIndex(index)
	if mInterestSkillSlotList[index] ~= nil then
		return mInterestSkillSlotList[index];
	else
		return - 1;
	end
end

function ShowPlayerSkillInfoTips(skillId, skilllevel, anchorObj, offsetX, offsetY)
	UIMgr.ShowUI(AllUI.UI_Tip_SkillInfo, nil, nil, nil, nil, true, SkillTipType.PlayerSkillType, skillId, skilllevel, anchorObj, offsetX, offsetY);
end

function ShowNpcSkillInfoTips(skillId, skilllevel, anchorObj, offsetX, offsetY)
	UIMgr.ShowUI(AllUI.UI_Tip_SkillInfo, nil, nil, nil, nil, true, SkillTipType.NpcSkillType, skillId, skilllevel, anchorObj, offsetX, offsetY);
end

function GetSkillCD(skillId, skillLevel)
	local skillInfo = SkillData.GetSkillLevelInfo(skillId, skillLevel);
	local skillUnitData = SkillData.GetSkillUnitData(skillInfo.unit);
	if skillUnitData.skillCDTime then
		return skillUnitData.skillCDTime / 1000;
	else
		return 0;
	end
end

function GetSkillReleaseNeedsStr(releaseNeedList, StyleType)
	local cunsumeStr = "";
	if StyleType == 1 then
		for i = 1, #releaseNeedList do
			local consumeData = AttDefineData.GetDefineData(releaseNeedList[i].id);
			if i == 1 then
				if releaseNeedList[i].id ~= - 1 then
					cunsumeStr = "[0D6DCFFF]" .. releaseNeedList[i].count .. "[-][9E6941]" .. consumeData.name .. "[-]";
				end
			elseif i == 2 then
				if releaseNeedList[i].id ~= - 1 then
					if cunsumeStr == "" then
						cunsumeStr = releaseNeedList[i].count .. consumeData.name;
					else
						cunsumeStr = cunsumeStr .. " " .. "[0D6DCFFF]" .. releaseNeedList[i].count .. "[-][9E6941]" .. consumeData.name .. "[-]";
					end
				end
			end
		end
		if cunsumeStr == "" then
			cunsumeStr = "[9E6941]无[-]";
		end
	elseif StyleType == 2 then
		for i = 1, #releaseNeedList do
			local consumeData = AttDefineData.GetDefineData(releaseNeedList[i].id);
			if i == 1 then
				if releaseNeedList[i].id ~= - 1 then
					cunsumeStr = "[7ad8f4ff]" .. releaseNeedList[i].count .. "[-][EBCBA2]" .. consumeData.name .. "[-]";
				end
			elseif i == 2 then
				if releaseNeedList[i].id ~= - 1 then
					if cunsumeStr == "" then
						cunsumeStr = releaseNeedList[i].count .. consumeData.name;
					else
						cunsumeStr = cunsumeStr .. " " .. "[7ad8f4ff]" .. releaseNeedList[i].count .. "[-][EBCBA2]" .. consumeData.name .. "[-]";
					end
				end
			end
		end
		if cunsumeStr == "" then
			cunsumeStr = "[EBCBA2]无[-]";
		end
	end
	
	return cunsumeStr;
end

return SkillMgr; 