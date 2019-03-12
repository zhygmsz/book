MainUIPlayerInfo = class("MainUIPlayerInfo");

function MainUIPlayerInfo:ctor(uiFrame)
	self._uiFrame = uiFrame;
	self.MAX_BUFF_COUNT = 7;	--玩家buff显示最大数量
	
	self._buffInfoList = {};

	self._isHpInit = false;		--血条初始化标志
	self._hpTargetValue = 0;	--血量目标值，用于血条缓动

	--玩家信息
	self._playerNameLabel = uiFrame:FindComponent("UILabel", "TopLeft/PlayerInfo/Name");
	self._playerLevelLabel = uiFrame:FindComponent("UILabel", "TopLeft/PlayerInfo/AvatarBtn/LevelBg/Level");
	self._professionSprite = uiFrame:FindComponent("UISprite", "TopLeft/PlayerInfo/Profession");
	self._playerIcon = uiFrame:FindComponent("UITexture", "TopLeft/PlayerInfo/AvatarBtn/Icon");
	self._playerIconLoader = LoaderMgr.CreateTextureLoader(self._playerIcon);
	self._hpBar = uiFrame:FindComponent("UISlider", "TopLeft/PlayerInfo/HpBar");
	self._mpBar = uiFrame:FindComponent("UISlider", "TopLeft/PlayerInfo/MpBar");
	self._expBar = uiFrame:FindComponent("UISlider", "Bottom/ExpBar");
	self._expBarForeground = uiFrame:FindComponent("UISprite", "Bottom/ExpBar/Foreground");
	self._buffList = {};
	local bufStr = "TopLeft/PlayerInfo/Grid/buff"
	for i = 1, self.MAX_BUFF_COUNT do
		local buff = {};
		buff.buffId = - 1;
		buff.buffItem = uiFrame:Find(bufStr .. i).gameObject;
		buff.buffIcon = uiFrame:FindComponent("UISprite", bufStr .. i .. "/spr");
		buff.buffBg = uiFrame:Find(bufStr .. i .. "/bg").gameObject;
		buff.buffItem:SetActive(false);
		table.insert(self._buffList, buff);
	end
	self._moreBuffFlagObject = uiFrame:Find("TopLeft/PlayerInfo/Grid/Add").gameObject;
	self._moreBuffFlagObject:SetActive(false);
	
	--宠物部分
	self._petIcon = uiFrame:FindComponent("UITexture", "TopLeft/PlayerInfo/PetAvatarBtn/Icon");
	self._petIconObject = self._petIcon.gameObject;
	self._petIconLoader = LoaderMgr.CreateTextureLoader(self._petIcon);
	self._petLevelLabel = uiFrame:FindComponent("UILabel", "TopLeft/PlayerInfo/PetAvatarBtn/Sprite/Level");
	self._petHpBar = uiFrame:FindComponent("UISlider", "TopLeft/PlayerInfo/PetAvatarBtn/HpBar");
	self._petIconBgObject = uiFrame:FindComponent("UISprite", "TopLeft/PlayerInfo/PetAvatarBtn/IconBg").gameObject;

	--低血量提示
	self._LOW_HP_PERCENT_MIN = ConfigData.GetValue("fight_lowhp_tip_percent_min");
	self._LOW_HP_PERCENT_MAX = ConfigData.GetValue("fight_lowhp_tip_percent_max");
	self._lowHPEffect = LoaderMgr.CreateEffectLoader();
	local lowHPEffectID = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_canxiepingmu_eff01.prefab");
	self._lowHPEffect:LoadObject(lowHPEffectID);
	self._lowHPEffect:SetParent(UIMgr.GetUIRootTransform(),true);
	self._lowHPEffect:SetSortOrder(899);
	self._lowHPEffect:SetFullScreen();
	self._lowHPActive = false;
	
	self:RegEvent();
	UpdateBeat:Add(self.Update, self);
end

function MainUIPlayerInfo:OnEnable()
	self._buffTimer = GameTimer.AddTimer(1, 1000000, self.UpdateBuffCDTime, self);	
	self._isHpInit = true;
end

function MainUIPlayerInfo:OnDisable()
	GameTimer.DeleteTimer(self._buffTimer);
end

function MainUIPlayerInfo:OnDestroy()
	self:UnRegEvent();
	UpdateBeat:Remove(self.Update, self)
end

function MainUIPlayerInfo:RegEvent()
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, self.OnPlayerLevelUp, self);
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_EXP, self.OnExpChanged, self);
	
	GameEvent.Reg(EVT.MAPEVENT, EVT.MAP_ENTER_FINISH, self.InitPlayerInfo, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_HP_UPDATE, self.OnHPChange, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_ADD_BUFF, self.OnBuffAdded, self);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_REMOVE_BUFF, self.OnBuffRemoved, self);
	GameEvent.Reg(EVT.MAINUI, EVT.MAINUI_BUFF_CHANGED, self.OnBuffChanged, self);
	GameEvent.Reg(EVT.PET, EVT.FIGHTSTATE_CHANGED, self.UpdatePetInfo, self);
	GameEvent.Reg(EVT.PET, EVT.PET_ONPETLEVELUP, self.OnPetLevelUp, self);
end

function MainUIPlayerInfo:UnRegEvent()
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, self.OnPlayerLevelUp, self);
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_EXP, self.OnExpChanged, self);
	
	GameEvent.UnReg(EVT.MAPEVENT, EVT.MAP_ENTER_FINISH, self.InitPlayerInfo, self);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_HP_UPDATE, self.OnHPChange, self);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_ADD_BUFF, self.OnBuffAdded, self);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_REMOVE_BUFF, self.OnBuffRemoved, self);
	GameEvent.UnReg(EVT.MAINUI, EVT.MAINUI_BUFF_CHANGED, self.OnBuffChanged, self);
	GameEvent.UnReg(EVT.PET, EVT.FIGHTSTATE_CHANGED, self.UpdatePetInfo, self);
	GameEvent.UnReg(EVT.PET, EVT.PET_ONPETLEVELUP, self.OnPetLevelUp, self);
end

function MainUIPlayerInfo:OnClick(id)
	if id == 51 then
		--buff面板
		if #self._buffInfoList > 0 then
			UIMgr.ShowUI(AllUI.UI_Tip_BuffInfo, self._uiFrame, nil, nil, nil, true, self._buffInfoList);
		end
	end
end

function MainUIPlayerInfo:OnPlayerLevelUp(entity)
	--MapMgr.PlayerLevelUp();
	if entity == nil and entity:IsSelf() then
		self._playerLevelLabel.text = UserData.GetLevel();
		self:OnExpChanged();
	end
end

function MainUIPlayerInfo:OnExpChanged()
	local currentExp = tonumber(UserData.GetExp());
	local currentLevel = UserData.GetLevel();
	local needExp = LevelExpData.GetExpByLevel(currentLevel);	
	
	if needExp == 0 then
		self._expBarForeground.spriteName = "frame_exp_03";
		self._expBar.value = 1;
	else
		if currentExp >= needExp * 10 then
			self._expBarForeground.spriteName = "frame_exp_03";
		else
			self._expBarForeground.spriteName = "frame_exp_01";
		end
		self._expBar.value = currentExp / needExp;
	end
end

function MainUIPlayerInfo:InitPlayerInfo()
	--等级
	self._playerLevelLabel.text = UserData.GetLevel();
	--经验
	self:OnExpChanged();
	--姓名
	self._playerNameLabel.text = UserData.GetName();
	--头像
	self._playerIconLoader:LoadObject(UserData.PlayerAtt.playerData.headIcon);
	--职业图标
	local professionId = UserData.PlayerAtt.playerData.profession;
	if professionId == 1 then --战士
		self._professionSprite.spriteName = "icon_common_zhiye_01";
	elseif professionId == 2 then --法师
		self._professionSprite.spriteName = "icon_common_zhiye_02";
	elseif professionId == 3 then --猎人
		self._professionSprite.spriteName = "icon_common_zhiye_03";
	elseif professionId == 4 then --刺客
		self._professionSprite.spriteName = "icon_common_zhiye_04";
	elseif professionId == 5 then --牧师
		self._professionSprite.spriteName = "icon_common_zhiye_05";
	end
	--HP、MP
	local cur = 0;
	local max = 0;
	local percent = 0;
	cur = UserData.GetHP();
	max = UserData.GetHPMax();
	percent = cur / max;
	self._hpBar.value = percent;
	self._hpTargetValue = percent;
	self:UpdateLowHPTip(percent);

	--MP
	cur = UserData.GetMP();
	max = UserData.GetMPMax();
	percent = cur / max;
	percent = percent - percent % 0.01;
	--self._mpBar.value = percent;
	self._mpBar.value = 1;
	--宠物
	self:UpdatePetInfo();
	--低血量提示
end

function MainUIPlayerInfo:OnHPChange(attacker, target, deltaValue, crit, buffEffectID)
	if target:IsSelf() then
		local cur = UserData.GetHP();
		local max = UserData.GetHPMax();
		local percent = cur / max;
		percent = percent - percent % 0.01;
		if self._isHpInit then
			self._hpBar.value = percent;
			self._hpTargetValue = percent;
			self._isHpInit = false;
		else
			self._hpTargetValue = percent;
		end
		
		--玩家血量低于一定阈值出现提示
		self:UpdateLowHPTip(percent);
	end
end

function MainUIPlayerInfo:OnBuffAdded(buffGroup)
	local isSelf = buffGroup._buffComponent._entity:IsSelf();
	if not isSelf then return; end
	local buffId = buffGroup._buffID;
	local buffTime = buffGroup:GetLeftTime();
	--过滤掉瞬时buff
	if buffTime <= 0 then return; end
	--过滤掉重复buff
	local isContent = false;
	for k, v in ipairs(self._buffInfoList) do
		if v.buffId == buffId then
			isContent = true;
			break;
		end
	end
	if not isContent then
		local buffInfo = {};
		buffInfo.buffId = buffId;
		buffInfo.buffTime = buffTime;
		table.insert(self._buffInfoList, buffInfo);
		GameEvent.Trigger(EVT.MAINUI, EVT.MAINUI_BUFF_CHANGED, self._buffInfoList);
	end
end

function MainUIPlayerInfo:OnBuffRemoved(buffGroup)
	local isSelf = buffGroup._buffComponent._entity:IsSelf();
	if not isSelf then return; end
	local buffId = buffGroup._buffID;
	local isFind = false;
	for k, v in ipairs(self._buffInfoList) do
		if v.buffId == buffId then
			table.remove(self._buffInfoList, k);
			isFind = true;
			break;
		end
	end
	if isFind then
		GameEvent.Trigger(EVT.MAINUI, EVT.MAINUI_BUFF_CHANGED, self._buffInfoList);
	end
end

function MainUIPlayerInfo:OnBuffChanged(buffList)
	if #buffList > self.MAX_BUFF_COUNT then
		self._moreBuffFlagObject:SetActive(true);
	else
		self._moreBuffFlagObject:SetActive(false);
	end
	for k, v in ipairs(self._buffList) do
		
		if k <= #buffList then
			v.buffItem:SetActive(true);
			local buffInfo = buffList[k];
			if v.buffId ~= buffInfo.buffId then
				local buffTableInfo = BuffData.GetBuffData(buffInfo.buffId);
				v.buffId = buffInfo.buffId;
			end
		else
			v.buffId = - 1;
			v.buffItem:SetActive(false);
		end
	end
end

function MainUIPlayerInfo:UpdateBuffCDTime()
	for k, v in ipairs(self._buffInfoList) do
		v.buffTime = v.buffTime - 1;
	end
end

function MainUIPlayerInfo:UpdatePetInfo()
	local petInfo = PetMgr.GetCurrFightPet();
	if petInfo ~= nil then
		local petTableInfo = PetData.GetPetDataById(petInfo.tempId);
		self._petIconObject:SetActive(true);
		self._petIconLoader:LoadObject(petTableInfo.face);
		self._petLevelLabel.text = petInfo.level;
		local maxHp = PetMgr.GetPetMaxHPBySlotId(petInfo.slotId);
		if petInfo.curHP == - 1 then
			petInfo.curHP = maxHp;
		end
		self._petHpBar.value = petInfo.curHP / maxHp;
		self._petIconBgObject:SetActive(false);
	else
		self._petIcon.gameObject:SetActive(false);
		self._petIconBgObject:SetActive(true);
		self._petHpBar.value = 0;
		self._petLevelLabel.text = "0";
	end
end

function MainUIPlayerInfo:UpdateLowHPTip(percent)
	if percent <= 0 then
		--死亡后不再提示
		self._lowHPActive = false;
		self._lowHPEffect:SetActive(false);
	else
		if self._lowHPActive then
			--处于低血量状态,当超过阈值之后不再提示
			if percent >= self._LOW_HP_PERCENT_MAX then
				self._lowHPActive = false;
				self._lowHPEffect:SetActive(false);
			end
		else
			--不在低血量状态,检查是否需要进入
			if percent <= self._LOW_HP_PERCENT_MIN then
				self._lowHPActive = true;
				self._lowHPEffect:SetActive(true,true);
			end
		end
	end
end

function MainUIPlayerInfo:OnPetLevelUp(levelValue)
	self._petLevelLabel.text = levelValue;
end

function MainUIPlayerInfo:Update()
	local currentHpValue = self._hpBar.value;
	if currentHpValue - self._hpTargetValue > 0.01 then
		self._hpBar.value = currentHpValue - 0.01;
	elseif currentHpValue - self._hpTargetValue < - 0.01 then
		self._hpBar.value = currentHpValue + 0.01;
	end
end

return MainUIPlayerInfo; 