module("UI_Skill_AotoSet", package.seeall);

local skillItemList = {};
local targetToogleList = {};
local followToggleList = {};

local SKILL_ITEM_COUNT = 6;
local PLAYER_SKILL_COUNT = 5;

function OnCreate(self)
	local skillItemCommonPath = "Offset/Left/Table/Cell";
	for i = 1, SKILL_ITEM_COUNT do
		local skillItem = {};
		skillItem.isEnable = false;
		skillItem.grayBg = self:Find(skillItemCommonPath .. i .. "/Gray").gameObject;
		skillItem.skillIcon = self:FindComponent("UITexture", skillItemCommonPath .. i .. "/Icon_bg/Icon");
		skillItem.skillIconLoader = LoaderMgr.CreateTextureLoader(skillItem.skillIcon);
		skillItem.skillName = self:FindComponent("UILabel", skillItemCommonPath .. i .. "/Name");
		skillItem.switchBg = self:FindComponent("UISprite", skillItemCommonPath .. i .. "/SwitchBg");
		skillItem.switchItem = self:Find(skillItemCommonPath .. i .. "/SwitchBg/Yuan");
		skillItem.tweenPosition = self:FindComponent("TweenPosition", skillItemCommonPath .. i .. "/SwitchBg/Yuan");
		skillItem.slotIndex = i + 1;
		if i == 6 then
			--宠物技能
			skillItem.slotIndex = -1;
		end
		table.insert(skillItemList, skillItem);
	end
	
	--目标设置
	local targetToogle1 = self:FindComponent("UIToggle", "Offset/Right/TargetTabList/Tab1");
	local targetToogle2 = self:FindComponent("UIToggle", "Offset/Right/TargetTabList/Tab2");
	local targetToogle3 = self:FindComponent("UIToggle", "Offset/Right/TargetTabList/Tab3");
	table.insert(targetToogleList, targetToogle1);
	table.insert(targetToogleList, targetToogle2);
	table.insert(targetToogleList, targetToogle3);
	
	local targetToogleCall = EventDelegate.Callback(OnTargetToogleChanged);
	
	EventDelegate.Add(targetToogleList[1].onChange, targetToogleCall);
	EventDelegate.Add(targetToogleList[2].onChange, targetToogleCall);
	EventDelegate.Add(targetToogleList[3].onChange, targetToogleCall);
	
	--追击设置
	local followToogle1 = self:FindComponent("UIToggle", "Offset/Right/PursuitTabList/Tab1");
	local followToogle2 = self:FindComponent("UIToggle", "Offset/Right/PursuitTabList/Tab2");
	table.insert(followToggleList, followToogle1);
	table.insert(followToggleList, followToogle2);
	
	local followToogleCall = EventDelegate.Callback(OnFollowToogleChanged);
	
	EventDelegate.Add(followToggleList[1].onChange, followToogleCall);
	EventDelegate.Add(followToggleList[2].onChange, followToogleCall);
end

function OnDestroy(self)
	
end

function OnEnable(self)
	InitView();
end

function OnDisable(self)
--[[	for k, skillItem in ipairs(skillItemList) do
		local isSlotUnLock = FunUnLockMgr.GetSkillSlotIsUnlock(skillItem.slotIndex);
		local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(skillItem.slotIndex);
		if isSlotUnLock and slotInfo.level > 0 then
			skillItem.isEnable = true;
			skillItem.grayBg:SetActive(false);
			skillItem.skillIcon.gameObject:SetActive(true);
			skillItem.skillName.gameObject:SetActive(true);
			local skillInfo = SkillData.GetSkillInfo(slotInfo.id);
			skillItem.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillInfo.icon));
			skillItem.skillName.text = skillInfo.name;
			local isAtuoRelease = UserData.GetAutoSkillActiveFlag(skillItem.slotIndex);
			SetSlotIsAutoRelease(k, isAtuoRelease, false);
		else
			skillItem.isEnable = false;
			skillItem.grayBg:SetActive(true);
			skillItem.skillIcon.gameObject:SetActive(false);
			skillItem.skillName.gameObject:SetActive(false);
			SetSlotIsAutoRelease(k, false, false);
		end
	end
	]]
end

function OnClick(go, id)
	if id == 0 then
		UIMgr.UnShowUI(AllUI.UI_Skill_AotoSet);
	elseif id >= 100 and id <= 100 + SKILL_ITEM_COUNT then
		local skillItemIndex = id - 100;
		local skillItem = skillItemList[skillItemIndex];
		if skillItem and skillItem.isEnable then
			ChangeSlotAutoRelease(skillItemIndex);
		end
	end
end

function InitView()
	InitSkillList();
	InitTargetType();
	InitFollowFlag();
end

function InitSkillList()
	for k, skillItem in ipairs(skillItemList) do
		if skillItem.slotIndex ~= -1 then
			--人物技能
			local isSlotUnLock = FunUnLockMgr.GetSkillSlotIsUnlock(skillItem.slotIndex);
			local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(skillItem.slotIndex);
			if isSlotUnLock and slotInfo.level > 0 then
				skillItem.isEnable = true;
				skillItem.grayBg:SetActive(false);
				skillItem.skillIcon.gameObject:SetActive(true);
				skillItem.skillName.gameObject:SetActive(true);
				local skillInfo = SkillData.GetSkillInfo(slotInfo.id);
				skillItem.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillInfo.icon));
				skillItem.skillName.text = skillInfo.name;
				local isAtuoRelease = UserData.GetAutoSkillActiveFlag(skillItem.slotIndex);
				SetSlotIsAutoRelease(k, isAtuoRelease, false);
			else
				skillItem.isEnable = false;
				skillItem.grayBg:SetActive(true);
				skillItem.skillIcon.gameObject:SetActive(false);
				skillItem.skillName.gameObject:SetActive(false);
				SetSlotIsAutoRelease(k, false, false);
			end
		else
			--宠物技能
			skillItem.isEnable = false;
			skillItem.grayBg:SetActive(true);
			skillItem.skillIcon.gameObject:SetActive(false);
			skillItem.skillName.gameObject:SetActive(false);
			SetSlotIsAutoRelease(k, false, false);
		end
	end
end

function InitTargetType()
	local currentTargetType = UserData.GetAutoSkillLimitType();
	if currentTargetType == EntityDefine.SKILL_PRIORITY_TYPE.NONE then
		targetToogleList[1].value = true;
	elseif currentTargetType == EntityDefine.SKILL_PRIORITY_TYPE.OTHER then
		targetToogleList[2].value = true;
	elseif currentTargetType == EntityDefine.SKILL_PRIORITY_TYPE.PLAYER then
		targetToogleList[3].value = true;
	end
end

function InitFollowFlag()
	local currentFollowFlag = UserData.GetAutoSkillFollowFlag();
	if currentFollowFlag == true then
		followToggleList[1].value = true;
	elseif currentFollowFlag == false then
		followToggleList[2].value = true;
	end
end

function ChangeSlotAutoRelease(skillItemIndex)
	local skillItem = skillItemList[skillItemIndex];
	if skillItem == nil then return; end
	local isAutoRelease = UserData.GetAutoSkillActiveFlag(skillItem.slotIndex);
	SetSlotIsAutoRelease(skillItemIndex, not isAutoRelease, true);
	UserData.SetAutoSkillActiveFlag(skillItem.slotIndex, not isAutoRelease);
end

function SetSlotIsAutoRelease(skillItemIndex, isAutoRelease, isPlay)
	local skillItem = skillItemList[skillItemIndex];
	if skillItem == nil then return; end
	if isAutoRelease then
		skillItem.switchBg.spriteName = "frame_common_22"
	else
		skillItem.switchBg.spriteName = "frame_common_23"
	end
	if isPlay then
		skillItem.tweenPosition.enabled = true;
		skillItem.tweenPosition:Play(isAutoRelease);		
	else
		skillItem.tweenPosition.enabled = false;
		if isAutoRelease then
			skillItem.switchItem.localPosition = Vector3.New(30, 0, 0);
		else
			skillItem.switchItem.localPosition = Vector3.New(- 30, 0, 0);
		end
	end
end

function OnTargetToogleChanged()
	local currentTargetType = UserData.GetAutoSkillLimitType();
	if targetToogleList[1].value then
		if currentTargetType ~= EntityDefine.SKILL_PRIORITY_TYPE.NONE then
			UserData.SetAutoSkillLimitType(EntityDefine.SKILL_PRIORITY_TYPE.NONE);
		end
	elseif targetToogleList[2].value then
		if currentTargetType ~= EntityDefine.SKILL_PRIORITY_TYPE.OTHER then
			UserData.SetAutoSkillLimitType(EntityDefine.SKILL_PRIORITY_TYPE.OTHER);
		end
	elseif targetToogleList[3].value then
		if currentTargetType ~= EntityDefine.SKILL_PRIORITY_TYPE.PLAYER then
			UserData.SetAutoSkillLimitType(EntityDefine.SKILL_PRIORITY_TYPE.PLAYER);
		end
	end
end

function OnFollowToogleChanged()
	local currentFollowFlag = UserData.GetAutoSkillFollowFlag();
	if followToggleList[1].value then
		if currentFollowFlag ~= true then
			UserData.SetAutoSkillFollowFlag(true)
		end
	elseif followToggleList[2].value then
		if currentFollowFlag ~= false then
			UserData.SetAutoSkillFollowFlag(false);
		end
	end
end 