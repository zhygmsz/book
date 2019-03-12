MainUIEnemyInfo = class("MainUIEnemyInfo");

function MainUIEnemyInfo:ctor(uiFrame)
	self._uiFrame = uiFrame;
	
	self.BOSS_BUFF_COUNT = 6;	--boss的Buff最大显示数量
	self.BOSS_SKILL_COUNT = 5;	--boss的技能最大数量
	self.BOSS_SKILL_CD_UPDATE_TIME = 0.2;	--boss技能CD更新时间
	
	self._bossUnitId = - 1;
	self._buffInfoList = {};
	
	--boss信息
	self._bossInfo = uiFrame:Find("Top/BossInfo").gameObject;
	self._bossInfo:SetActive(false);
	self._bossIcon = uiFrame:FindComponent("UITexture", "Top/BossInfo/AvatarBtn/Icon");
	self._bossIconLoader = LoaderMgr.CreateTextureLoader(self._bossIcon);
	self._bossName = uiFrame:FindComponent("UILabel", "Top/BossInfo/Name");
	self._bossLevel = uiFrame:FindComponent("UILabel", "Top/BossInfo/LevelBg/Level");
	self._bossHpBar = uiFrame:FindComponent("UISlider", "Top/BossInfo/HpBar");
	self._bossHpValue = uiFrame:FindComponent("UILabel", "Top/BossInfo/HpBar/ValueLabel");
	self._bossBuffList = {};
	local buffPath = "Top/BossInfo/BuffGrid/buff";
	for i = 1, self.BOSS_BUFF_COUNT do
		local buffItem = {};
		buffItem.buffObj = uiFrame:Find(buffPath .. i).gameObject;
		buffItem.buffObj:SetActive(false);
		buffItem.buffId = - 1;
		buffItem.buffIcon = uiFrame:FindComponent("UISprite", buffPath .. i .. "/spr");
		table.insert(self._bossBuffList, buffItem);
	end
	self.skillList = {};
	local skillPath = "Top/BossInfo/SkillList/S_";
	for i = 1, self.BOSS_SKILL_COUNT do
		local skillItem = {};
		skillItem.transform = uiFrame:Find(skillPath .. i);
		skillItem.skillObj = skillItem.transform.gameObject;
		skillItem.skillObj:SetActive(false);
		skillItem.skillId = - 1;
		skillItem.skillLevel = 0;
		skillItem.iconTex = uiFrame:FindComponent("UITexture", skillPath .. i .. "/Icon");
		skillItem.iconLoader = LoaderMgr.CreateTextureLoader(skillItem.iconTex);
		skillItem.cdBar = uiFrame:FindComponent("UISprite", skillPath .. i .. "/CD");
		skillItem.cdBarObject = skillItem.cdBar.gameObject;
		skillItem.CDTiem = - 1;
		table.insert(self.skillList, skillItem);
	end
	
	self._LeaderInfo = uiFrame:Find("Top/LeaderInfo").gameObject;
	self._LeaderInfo:SetActive(false);
	
	GameTimer.AddForeverTimer(self.BOSS_SKILL_CD_UPDATE_TIME, self.UpdateSkillCD, self);
	
	self:RegEvent()
end

function MainUIEnemyInfo:OnEnable()
	
end

function MainUIEnemyInfo:OnDisable()
	
end

function MainUIEnemyInfo:OnDestroy()
	self:UnRegEvent()
end

function MainUIEnemyInfo:RegEvent()
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_CREATE, self.OnAddEntity, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_DELETE, self.OnKillEntity, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_HP_UPDATE, self.OnHPChange, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_ADD_BUFF, self.OnBuffAdded, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_REMOVE_BUFF, self.OnBuffRemoved, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_CAST_SKILL, self.OnCastSkill, self);
end

function MainUIEnemyInfo:UnRegEvent()
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_CREATE, self.OnAddEntity, self);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_DELETE, self.OnKillEntity, self);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_HP_UPDATE, self.OnHPChange, self);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_ADD_BUFF, self.OnBuffAdded, self);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_REMOVE_BUFF, self.OnBuffRemoved, self);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_CAST_SKILL, self.OnCastSkill, self);
end

function MainUIEnemyInfo:OnLongPress(id)
	if id == 701 then
		SkillMgr.ShowNpcSkillInfoTips(self.skillList[1].skillId, self.skillList[1].skillLevel, self.skillList[1].transform, - 200, - 12);
	elseif id == 702 then
		SkillMgr.ShowNpcSkillInfoTips(self.skillList[2].skillId, self.skillList[2].skillLevel, self.skillList[2].transform, - 200, - 12);
	elseif id == 703 then
		SkillMgr.ShowNpcSkillInfoTips(self.skillList[3].skillId, self.skillList[3].skillLevel, self.skillList[3].transform, - 200, - 12);
	elseif id == 704 then
		SkillMgr.ShowNpcSkillInfoTips(self.skillList[4].skillId, self.skillList[4].skillLevel, self.skillList[4].transform, - 200, - 12);
	elseif id == 705 then
		SkillMgr.ShowNpcSkillInfoTips(self.skillList[5].skillId, self.skillList[5].skillLevel, self.skillList[5].transform, - 200, - 12);
	end
end

function MainUIEnemyInfo:OnPress(id, press)
	local slotIndex = id - 700;
	if slotIndex >= 1 and slotIndex <= self.BOSS_SKILL_COUNT then
		if not press then
			if AllUI.UI_Tip_SkillInfo.enable then
				UIMgr.UnShowUI(AllUI.UI_Tip_SkillInfo);
			end
		end
	end
end

function MainUIEnemyInfo:OnAddEntity(entity)
	if entity:IsNPC() and entity:GetNPCType() == Common_pb.NPC_BOSS then
		self._bossInfo:SetActive(true);
		self:InitBossInfo(entity);
		self:UpdateBossHp(entity);
	end
end

function MainUIEnemyInfo:InitBossInfo(entity)
	local bossPropertyComponent = entity:GetPropertyComponent();
	self._bossUnitId = bossPropertyComponent:GetUnitID();
	--名字
	local bossName = entity:GetName();
	self._bossName.text = bossName;
	--等级
	local level = bossPropertyComponent:GetLevel();
	self._bossLevel.text = level;
	--头像
	local icon = bossPropertyComponent:GetIcon();
	self._bossIconLoader:LoadObject(icon);
	--技能
	local skillList = bossPropertyComponent:GetSkillList();
	local function skillSortFun(a, b)
		return a.showPriority > b.showPriority;
	end
	table.sort(skillList, skillSortFun);
	for k, v in ipairs(skillList) do
		local skillItem = self.skillList[k];
		if skillItem ~= nil then
			if v.showPriority ~= 0 then
				skillItem.skillId = v.skillID;
				skillItem.skillLevel = v.skillLevel;
				local isShowCD = v.isShowCD;
				local skillTableInfo = SkillData.GetSkillInfo(v.skillID);
				skillItem.iconLoader:LoadObject(ResConfigData.GetResConfigID(skillTableInfo.icon));
				skillItem.skillObj:SetActive(true);
				if isShowCD then
					skillItem.CDTiem = v.skillCD;
					skillItem.cdBar.fillAmount = 0;
				else
					skillItem.CDTiem = - 1;
				end
				skillItem.cdBarObject:SetActive(isShowCD);
			else
				skillItem.skillObj:SetActive(false);
				skillItem.skillId = - 1;
				skillItem.skillLevel = 0;
			end
		end
	end
	for i = #skillList + 1, #self.skillList do
		local skillItem = self.skillList[i];
		if skillItem ~= nil then
			skillItem.skillObj:SetActive(false);
			skillItem.skillId = - 1;
		end
	end
end

function MainUIEnemyInfo:OnHPChange(attacker, target, deltaValue, crit, buffEffectID)
	if target:IsNPC() and target:GetNPCType() == Common_pb.NPC_BOSS then
		local bossPropertyComponent = target:GetPropertyComponent();
		if bossPropertyComponent:GetUnitID() == self._bossUnitId then
			self:UpdateBossHp(target);
		end
	end
end

function MainUIEnemyInfo:UpdateBossHp(bossEntity)
	local currentValue = bossEntity:GetPropertyComponent():GetHP();
	local maxValue = bossEntity:GetPropertyComponent():GetHPMax();
	self._bossHpBar.value = currentValue / maxValue;
	self._bossHpValue.text = currentValue .. "/" .. maxValue;
end

function MainUIEnemyInfo:OnKillEntity(entity)
	if entity:IsNPC() and entity:GetNPCType() == Common_pb.NPC_BOSS then
		local bossPropertyComponent = entity:GetPropertyComponent();
		if bossPropertyComponent:GetUnitID() == self._bossUnitId then
			self._bossInfo:SetActive(false);
		end
	end
end

function MainUIEnemyInfo:UpdateSkillCD()
	for k, skillItem in ipairs(self.skillList) do
		if skillItem.CDTiem ~= - 1 then
			if skillItem.cdBar.fillAmount < 1 then
				local step = 1 /(skillItem.CDTiem / 1000 / self.BOSS_SKILL_CD_UPDATE_TIME);
				skillItem.cdBar.fillAmount = skillItem.cdBar.fillAmount + step;
			end
		end
	end
end

function MainUIEnemyInfo:OnBuffAdded(buffGroup)
	local entity = buffGroup._buffComponent._entity;
	if entity:IsNPC() and entity:GetNPCType() == Common_pb.NPC_BOSS then
		local bossPropertyComponent = entity:GetPropertyComponent();
		if bossPropertyComponent:GetUnitID() == self._bossUnitId then
			local buffId = buffGroup._buffID;
			local isFind = false;
			for k, v in ipairs(self._buffInfoList) do
				if v == buffId then
					isFind = true;
					break;
				end
			end
			if not isFind then
				table.insert(self._buffInfoList, buffId);
				self:UpdateBuffList();
			end
		end
	end
end

function MainUIEnemyInfo:OnBuffRemoved(buffGroup)
	local entity = buffGroup._buffComponent._entity;
	if entity:IsNPC() and entity:GetNPCType() == Common_pb.NPC_BOSS then
		local bossPropertyComponent = entity:GetPropertyComponent();
		if bossPropertyComponent:GetUnitID() == self._bossUnitId then
			local buffId = buffGroup._buffID;
			for k, v in ipairs(self._buffInfoList) do
				if v == buffId then
					table.remove(self._buffInfoList, k);
					self:UpdateBuffList();
					break;
				end
			end
		end
	end
end

function MainUIEnemyInfo:UpdateBuffList()
	for k, buffItem in ipairs(self._bossBuffList) do
		local buffId = self._buffInfoList[k];
		if buffId ~= nil then
			buffItem.buffId = buffId;
			buffItem.buffObj:SetActive(true);
			local buffTableInfo = BuffData.GetBuffData(buffId);
			buffItem.buffIcon.spriteName = buffTableInfo.icon_small;
		else
			buffItem.buffId = - 1;
			buffItem.buffObj:SetActive(false);
		end
	end
end

function OnCastSkill(entity, skillId)
	if entity:IsNPC() and entity:GetNPCType() == Common_pb.NPC_BOSS then
		local bossPropertyComponent = entity:GetPropertyComponent();
		if bossPropertyComponent:GetUnitID() == self._bossUnitId then
			for k, skillItem in ipairs(self.skillList) do
				if skillItem.skillId == skillId then
					skillItem.cdBar.fillAmount = 0;
					break;
				end
			end
		end
	end
end

return MainUIEnemyInfo; 