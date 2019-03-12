MainUISkill = class("MainUISkill");

function MainUISkill:ctor(uiFrame)
	self._SKILL_COUNT = 6;
	self._Skill_TIP_OFFSET = {x = -240, y = 438};
	
	self._skillRoot = uiFrame:Find("BottomRight/Skill");	
	local rootSortorder = uiFrame:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
	self._skills = {};
	for i = 1, self._SKILL_COUNT do
		local skillName = string.format("BottomRight/Skill/Skills/S_%s", i);
		local skillTweenTargetName = string.format("BottomRight/Skill/Tween/S_%s", i);
		local skillRoot = uiFrame:Find(skillName);
		local skillTweenTarget = uiFrame:Find(skillTweenTargetName);
		if not tolua.isnull(skillRoot) then
			local skill = {};
			self._skills[i] = skill;
			skill.lastClickTime = 0;
			skill.gameObject = skillRoot.gameObject;
			skill.transform = skillRoot;
			skill.tweenTarget = skillTweenTarget;
			skill.tweenPosition = skill.gameObject:GetComponent(typeof(TweenPosition));
			skill.tweenScale = skill.gameObject:GetComponent(typeof(TweenScale));
			skill.tweenButton = skill.gameObject:GetComponent(typeof(ButtonTween));
			skill.tweenPosition.to = skill.tweenTarget.localPosition;
			skill.tweenScale.to = skill.tweenTarget.localScale;
			skill.skillIcon = skill.transform:Find("Icon"):GetComponent(typeof(UITexture));
			skill.skillIconObject = skill.skillIcon.gameObject;
			skill.skillLabel = skill.transform:Find("Tap"):GetComponent(typeof(UILabel));
			skill.skillLabelObject = skill.skillLabel.gameObject;
			skill.skillIconLoader = LoaderMgr.CreateTextureLoader(skill.skillIcon);
			
			--加载技能解锁特效
			skill.skillUnlockEffect = LoaderMgr.CreateEffectLoader();
			skill.skillUnlockEffect:LoadObject(ResConfigData.GetResConfigID("UI_skill_eff01"));
			skill.skillUnlockEffect:SetParent(skill.skillIcon.transform);
			skill.skillUnlockEffect:SetLocalPosition(Vector3.zero);
			skill.skillUnlockEffect:SetLocalScale(Vector3.one);
			skill.skillUnlockEffect:SetSortOrder(rootSortorder);
			
			if i == 1 then
				--普攻技能
				skill.skillGauge = skill.transform:Find("Bar"):GetComponent(typeof(UISprite));
				skill.autoCastTimerID = GameTimer.AddForeverTimer(0.15, self.class.CastSkill, self, 1);
				GameTimer.PauseTimer(skill.autoCastTimerID, true);
				skill.onTweenFinish = EventDelegate.Callback(self.class.OnTweenFinish, self);
				EventDelegate.Set(skill.tweenScale.onFinished, skill.onTweenFinish);
			else
				--常规技能
				skill.skillLock = skill.transform:Find("Lock").gameObject;
				skill.skillCDSprite = skill.transform:Find("CD"):GetComponent(typeof(UISprite));
				skill.skillCDObject = skill.skillCDSprite.gameObject;
				skill.skillCDLabel = skill.transform:Find("Label"):GetComponent(typeof(UILabel));
				skill.skillCDEffect = LoaderMgr.CreateEffectLoader();
				skill.skillClickEffect = LoaderMgr.CreateEffectLoader();
				--加载技能UI点击反馈特效
				skill.skillClickEffect:LoadObject(ResConfigData.GetResConfigID("UI_anjianfankui_eff"));
				skill.skillClickEffect:SetParent(skill.transform);
				skill.skillClickEffect:SetLocalPosition(skill.skillIcon.transform.localPosition);
				skill.skillClickEffect:SetLocalScale(Vector3(330, 330, 330));
				skill.skillClickEffect:SetSortOrder(rootSortorder);
				--加载技能UICD开始特效
				skill.skillCDEffect:LoadObject(ResConfigData.GetResConfigID("UI_shuaxin_eff"));
				skill.skillCDEffect:SetParent(skill.transform);
				skill.skillCDEffect:SetLocalPosition(skill.skillIcon.transform.localPosition);
				skill.skillCDEffect:SetLocalScale(Vector3(330, 330, 330));
				skill.skillCDEffect:SetSortOrder(rootSortorder);
			end
		end
	end
	
	
	self._autoFight = uiFrame:FindComponent("UIToggle", "Bottom/Chat/BtnIg");
	self._autoFight:Set(UserData.GetAutoFight(), false);
	self._autoFightCallBack = EventDelegate.Callback(self.class.OnToggleAutoFight, self);
	EventDelegate.Set(self._autoFight.onChange, self._autoFightCallBack);
	
	self._rideIcon = uiFrame:FindComponent("UISprite", "BottomLeft/Ride/RideIcon");
	
	--监听事件
	GameEvent.Reg(EVT.MAINUI, EVT.MAINUI_BTN_STATE, self.OnMainUIBtnState, self);
	GameEvent.Reg(EVT.PLAYER, EVT.PLAYER_AUTOFIGHT, self.OnAutoFightState, self);
	GameEvent.Reg(EVT.PLAYER, EVT.PLAYER_CDENTER, self.OnCDEnter, self);
	GameEvent.Reg(EVT.PLAYER, EVT.PLAYER_CDUPDATE, self.OnCDUpdate, self);
	GameEvent.Reg(EVT.PLAYER, EVT.PLAYER_CDFINISH, self.OnCDFinish, self);
	GameEvent.Reg(EVT.MAPEVENT, EVT.MAP_ENTER_FINISH, self.OnEnterMap, self);
	GameEvent.Reg(EVT.SKILL, EVT.NORMAL_SKILL_SLOT_INFO, self.InitSlotInfo, self);
	GameEvent.Reg(EVT.SKILL, EVT.SLOT_SKILL_UNLOCK, self.UnLockSkill, self);
	GameEvent.Reg(EVT.FUN_UNLOCK, EVT.FUN_LOCK_STATE_CHANGED, self.UpdateSlotLockState, self);
	GameEvent.Reg(EVT.SKILL, EVT.Common_SKILL_EQUIPED, self.EquipCommonSkill, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_RIDE_OFF, self.OnOffRide, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_RIDE_ON, self.OnOnRide, self);
end

function MainUISkill:OnEnable()
end

function MainUISkill:OnDisable()
end

function MainUISkill:OnDestroy()
end

function MainUISkill:OnPress(id, press)
	if id == 1 then
		local skill = self._skills[id];
		if press then
			self:CastSkill(id);
			GameTimer.PauseTimer(skill.autoCastTimerID, false);
		else
			GameTimer.PauseTimer(skill.autoCastTimerID, true);
		end
	elseif id >= 2 and id <= self._SKILL_COUNT then
		if not press then
			if AllUI.UI_Tip_SkillInfo.enable then
				UIMgr.UnShowUI(AllUI.UI_Tip_SkillInfo);
			end
		end
	end
end

function MainUISkill:OnClick(id)
	if id >= 2 and id <= self._SKILL_COUNT then
		local skill = self._skills[id];
		--点击特效
		skill.skillClickEffect:SetActive(false);
		skill.skillClickEffect:SetActive(true);
		self:CastSkill(id);
	elseif id == 20 then
		self:ChangeRideState();
	end
end

function MainUISkill:OnLongPress(id)
	if id >= 2 and id <= self._SKILL_COUNT then --长按技能弹出技能详情
		local slotIndex = id;
		if FunUnLockMgr.GetSkillSlotIsUnlock(slotIndex) then
			local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(slotIndex);
			if slotInfo.level ~= 0 then
				local slotIndex = id;
				SkillMgr.ShowPlayerSkillInfoTips(slotInfo.id, slotInfo.level, self._skills[slotIndex].transform, self._Skill_TIP_OFFSET.x, self._Skill_TIP_OFFSET.y);
			end
		end
	elseif id == 10 then --长按自动按钮弹出自动战斗设置
		UIMgr.ShowUI(AllUI.UI_Skill_AotoSet);
	end
end

function MainUISkill:CastSkill(skillIndex)
	local mainPlayer = MapMgr.GetMainPlayer();
	if mainPlayer then
		mainPlayer:GetAIComponent():CastSkill(skillIndex);
	end
end

function MainUISkill:OnCDEnter(skillIndex, skillCDData)
	local skill = self._skills[skillIndex];
	skill.skillCDFlag = true;
	skill.skillCDObject:SetActive(true);
	skill.skillCDLabel.text = tostring(math.ceil(skillCDData.skillCDLeftTime * 0.001));
	skill.skillCDSprite.fillAmount = 1;
end

function MainUISkill:OnCDUpdate(skillIndex, skillCDData)
	local skill = self._skills[skillIndex];
	if not skill.skillCDFlag then self:OnCDEnter(skillIndex, skillCDData) end
	skill.skillCDLabel.text = tostring(math.ceil(skillCDData.skillCDLeftTime * 0.001));
	skill.skillCDSprite.fillAmount = skillCDData.skillCDLeftTime / skillCDData.skillCDTotalTime;
end

function MainUISkill:OnCDFinish(skillIndex)
	local skill = self._skills[skillIndex];
	if skill.skillCDEffect then
		skill.skillCDEffect:SetActive(false);
		skill.skillCDEffect:SetActive(true);
	end
	skill.skillCDObject:SetActive(false);
	skill.skillCDLabel.text = "";
	skill.skillCDFlag = false;
end

function MainUISkill:OnSkillEquip(skillIndex)
	local skill = self._skills[skillIndex];
	skill.skillCDObject:SetActive(false);
	skill.skillCDLabel.text = "";
end

function MainUISkill:OnMainUIBtnState()
	local btnState = UserData.GetMainUIBtnState();
	if btnState then
		self._skillRoot.localPosition = Vector3.New(500, - 4, 0);
	else
		self._skillRoot.localPosition = Vector3.New(4, - 4, 0);
	end
end

function MainUISkill:OnAutoFightState()
	if UserData.GetAutoFight() ~= self._autoFight.value then
		self._autoFight:Set(UserData.GetAutoFight(), false);
	end
end

function MainUISkill:OnToggleAutoFight()
	UserData.SetAutoFight(self._autoFight.value);
	if UserData.GetAutoFight() ~= self._autoFight.value then
		self._autoFight:Set(UserData.GetAutoFight(), false);
	end
end

function MainUISkill:OnTweenFinish()
	for _, skill in ipairs(self._skills) do
		skill.tweenButton:Invoke("SetupCurve", 0);
		if skill.skillClickEffect then
			skill.skillCDEffect:SetLocalScale(Vector3(330, 330, 330));
			skill.skillClickEffect:SetLocalScale(Vector3(330, 330, 330));
		end
	end
end

function MainUISkill:OnEnterMap()
	SkillMgr.InitNormalSkillSlotInfoFromUserData();
	self:InitSlotInfo();
	self:InitRideState();
end

function MainUISkill:InitSlotInfo()
	for k, v in ipairs(self._skills) do
		local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(k);
		local isSlotUnlocked = FunUnLockMgr.GetSkillSlotIsUnlock(k);
		if slotInfo ~= nil and isSlotUnlocked then
			if slotInfo.level > 0 then
				--设置技能标签
				local skillTableInfo = SkillData.GetSkillInfo(slotInfo.id);
				if k == 1 or k == 6 then
					v.skillLabelObject:SetActive(false);
				else
					v.skillLabelObject:SetActive(true);
					v.skillLabel.text = skillTableInfo.desc;
				end
				--加载技能图标
				v.skillIconObject:SetActive(true);
				v.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillTableInfo.icon));
			else
				v.skillLabelObject:SetActive(false);
				v.skillIconObject:SetActive(false);
			end
		else
			v.skillLabelObject:SetActive(false);
			v.skillIconObject:SetActive(false);
		end
	end
end

function MainUISkill:InitRideState()
	local isOnRide = RideMgr.IsOnRide();
	if isOnRide then
		self._rideIcon.spriteName = "button_zhujiemian_diban_zuoqi02";
	else
		self._rideIcon.spriteName = "button_zhujiemian_diban_zuoqi01";
	end
end

function MainUISkill:UnLockSkill(slotIndex)
	local slotItem = self._skills[slotIndex];
	local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(slotIndex);
	local isSlotUnlocked = FunUnLockMgr.GetSkillSlotIsUnlock(slotIndex);
	
	if isSlotUnlocked and slotInfo and slotItem then
		local skillTableInfo = SkillData.GetSkillInfo(slotInfo.id);
		--设置技能标签
		if slotIndex == 1 or slotIndex == 6 then
			slotItem.skillLabelObject:SetActive(false);
		else
			slotItem.skillLabelObject:SetActive(true);
			slotItem.skillLabel.text = skillTableInfo.desc;
		end
		--加载技能图标
		slotItem.skillIconObject:SetActive(true);
		slotItem.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillTableInfo.icon));
		--播放解锁特效
		slotItem.skillUnlockEffect:SetActive(false);
		slotItem.skillUnlockEffect:SetActive(true);
	end
end

function MainUISkill:UpdateSlotLockState(funIndex, isUnlock)
	local slotIndex = FunUnLockMgr.GetSkillSlotIndexByFunIndex(funIndex);
	local slotItem = self._skills[slotIndex];
	local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(slotIndex);
	if isUnlock and slotItem and slotInfo.level > 0 then
		local skillTableInfo = SkillData.GetSkillInfo(slotInfo.id);
		--设置技能标签
		if slotIndex == 1 or slotIndex == 6 then
			slotItem.skillLabelObject:SetActive(false);
		else
			slotItem.skillLabelObject:SetActive(true);
			slotItem.skillLabel.text = skillTableInfo.desc;
		end
		--加载技能图标
		slotItem.skillIconObject:SetActive(true);
		slotItem.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillTableInfo.icon));
		--播放解锁特效
		slotItem.skillUnlockEffect:SetActive(false);
		slotItem.skillUnlockEffect:SetActive(true);
	elseif not isUnlock then
		slotItem.skillLabelObject:SetActive(false);
		slotItem.skillIconObject:SetActive(false);
	end
end

function MainUISkill:EquipCommonSkill(skillId, isEquip)
	if isEquip then
		local slotItem = self._skills[5];
		slotItem.skillLabelObject:SetActive(true);
		local skillTableInfo = SkillData.GetSkillInfo(skillId);
		slotItem.skillLabel.text = skillTableInfo.desc;
		slotItem.skillIconObject:SetActive(true);
		slotItem.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillTableInfo.icon));
	end
end

function MainUISkill:ChangeRideState()
	local isOnRide = RideMgr.IsOnRide();
	if isOnRide then
		RideMgr.RequestRideOff();
	else
		RideMgr.RequestRideOn();
	end
end

function MainUISkill:OnOffRide(entity)
	if entity:IsSelf() then
		self._rideIcon.spriteName = "button_zhujiemian_diban_zuoqi01";
	end
end

function MainUISkill:OnOnRide(entity)
	if entity:IsSelf() then
		self._rideIcon.spriteName = "button_zhujiemian_diban_zuoqi02";
	end
end

return MainUISkill;
