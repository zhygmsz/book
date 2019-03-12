module("UI_Skill_Base", package.seeall);

local mSelf;

local SkillLevelUpState = {
	LevelUp_Normal = 1,	--技能可升级
	LevelUp_Max = 2,	--技能达到最高等级
	LevelUp_Study = 3;	--等级不足待学习
	LevelUp_Locked = 4; --槽位锁定
}

local mCurrentLevelUpState;

local mSkillSlotList = {};

local mSkillNameAndLevelLabel;
local mSkillDescriptionLabel;
local mConsumeLabel;
local mCDLabel;

local mLevelUpInfoGroupObject;
local mLevelUpEffectLabel;
local mLevelUpCountLabel;
local mOwnCount;
local mSkillLockFlagObject;

local mSkillTipLabel;
local mSkillTipLabelObject;

local mCurrentSelectSlotIndex = - 1;

local SKILL_SLOT_COUNT = 5;

function OnCreate(self)
	mSelf = self;
	
	local skillSlotBasePath = "Offset/Left/SkillList/Skill"
	for i = 1, SKILL_SLOT_COUNT do
		local skillSlotItem = {};
		--技能信息
		skillSlotItem.skillIcon = self:FindComponent("UITexture", skillSlotBasePath .. i .. "/Icon");
		skillSlotItem.skillIconObject = skillSlotItem.skillIcon.gameObject;
		skillSlotItem.skillIconLoader = LoaderMgr.CreateTextureLoader(skillSlotItem.skillIcon);
		skillSlotItem.lockFlagObject = self:Find(skillSlotBasePath .. i .. "/Lock").gameObject;
		skillSlotItem.tagObject = self:Find(skillSlotBasePath .. i .. "/Tag").gameObject;
		skillSlotItem.tagLabel = self:FindComponent("UILabel", skillSlotBasePath .. i .. "/Tag/Label");
		skillSlotItem.skillInfoLabel = self:FindComponent("UILabel", skillSlotBasePath .. i .. "/Info/Label");
		skillSlotItem.selectFlagObject = self:Find(skillSlotBasePath .. i .. "/SelectFlag").gameObject;
		skillSlotItem.selectFlagObject:SetActive(false);
		skillSlotItem.upFlagObject = self:Find(skillSlotBasePath .. i .. "/UpFlag").gameObject;
		skillSlotItem.skillId = - 1;
		skillSlotItem.skillLevel = 0;
		skillSlotItem.slotIndex = i;
		--此界面不包含江湖技能
		if i >= 5 then skillSlotItem.slotIndex = i + 1; end
		
		local rootSortorder = mSelf:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
		local levelUpEffectResId;
		if skillSlotItem.slotIndex == 6 then
			levelUpEffectResId = ResConfigData.GetResConfigID("UI_skill_eff05");
		else
			levelUpEffectResId = ResConfigData.GetResConfigID("UI_skill_eff04");
		end
		
		--技能升级特效
		skillSlotItem.levelUpEffect = LoaderMgr.CreateEffectLoader();
		skillSlotItem.levelUpEffect:LoadObject(levelUpEffectResId);
		skillSlotItem.levelUpEffect:SetParent(skillSlotItem.skillIcon.transform);
		skillSlotItem.levelUpEffect:SetLocalPosition(Vector3.zero);
		skillSlotItem.levelUpEffect:SetLocalScale(Vector3.one);
		skillSlotItem.levelUpEffect:SetSortOrder(rootSortorder);
		
		--技能解锁特效
		skillSlotItem.unLockEffect = LoaderMgr.CreateEffectLoader();
		skillSlotItem.unLockEffect:LoadObject(ResConfigData.GetResConfigID("UI_skill_eff01"));
		skillSlotItem.unLockEffect:SetParent(skillSlotItem.skillIcon.transform);
		skillSlotItem.unLockEffect:SetLocalPosition(Vector3.zero);
		skillSlotItem.unLockEffect:SetLocalScale(Vector3.one);
		skillSlotItem.unLockEffect:SetSortOrder(rootSortorder);
		
		table.insert(mSkillSlotList, skillSlotItem);
	end
	
	--技能详情
	mSkillNameAndLevelLabel = self:FindComponent("UILabel", "Offset/Right/TipTab/LevelTab");
	mSkillDescriptionLabel = self:FindComponent("UILabel", "Offset/Right/DesTab/DesLabelPanelOffset/DesLabelScrollView/DesLabel");
	mConsumeLabel = self:FindComponent("UILabel", "Offset/Right/DesTab/Consume/Label");
	mCDLabel = self:FindComponent("UILabel", "Offset/Right/DesTab/CD/Label");
	
	mLevelUpInfoGroupObject = self:Find("Offset/Right/LevelUpTab").gameObject;
	mLevelUpEffectLabel = self:FindComponent("UILabel", "Offset/Right/LevelUpTab/LevelUpEffect/Label");
	mLevelUpCountLabel = self:FindComponent("UILabel", "Offset/Right/LevelUpTab/LevelUpNeedInfo/NeedTab/CoountTab");
	mOwnCount = self:FindComponent("UILabel", "Offset/Right/LevelUpTab/LevelUpNeedInfo/HaveTab/CoountTab");
	
	mSkillTipLabel = self:FindComponent("UILabel", "Offset/Right/SkillTipLabel");
	mSkillTipLabelObject = mSkillTipLabel.gameObject;
	mSkillLockFlagObject = self:Find("Offset/Right/Lock").gameObject;
	mSkillLockTipLabel = self:FindComponent("UILabel", "Offset/Right/Lock/UnlockTipLabel");
end

function OnEnable(self)
	RegEvent(self);
	OnUpdateSkillView();
end

function OnDisable(self)
	UnRegEvent(self);
	--重置技能槽位选中标志
	UpdateSlotSelectFlag(- 1);
	mCurrentLevelUpState = SkillLevelUpState.LevelUp_Normal;
end

function RegEvent(self)
	GameEvent.Reg(EVT.SKILL, EVT.SLOT_SKILL_LEVEL_UP, OnSkillLevelUp);
	GameEvent.Reg(EVT.SKILL, EVT.NORMAL_SKILL_SLOT_INFO, OnUpdateSkillView);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_GETCOIN, UpdateMoney);
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, OnPlayerLevelUp);
	GameEvent.Reg(EVT.FUN_UNLOCK, EVT.FUN_LOCK_STATE_CHANGED, UpdateSlotLockState);
end

function UnRegEvent(self)
	GameEvent.UnReg(EVT.SKILL, EVT.SLOT_SKILL_LEVEL_UP, OnSkillLevelUp);
	GameEvent.UnReg(EVT.SKILL, EVT.NORMAL_SKILL_SLOT_INFO, OnUpdateSkillView);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_GETCOIN, UpdateMoney);
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, OnPlayerLevelUp);
	GameEvent.UnReg(EVT.FUN_UNLOCK, EVT.FUN_LOCK_STATE_CHANGED, UpdateSlotLockState);
end

function OnClick(go, id)
	if id <= 10 then
		SelectSkillSlot(id);
	elseif id == 11 then --升级
		for k, v in ipairs(mSkillSlotList) do
			if v.slotIndex == mCurrentSelectSlotIndex then
				SkillLevelUp(v.skillId);
				--SkillMgr.RequestNormalSkillLevelUp(NetCS_pb.CSComSkillLiftLevel.Op_LIFT, v.skillId);
				break;
			end
		end
		
	elseif id == 12 then --一键升级
		for k, v in ipairs(mSkillSlotList) do
			if v.slotIndex == mCurrentSelectSlotIndex then
				SkillLevelUpAuto(v.skillId);
				break;
			end
		end
	elseif id == 13 then --银币添加
		UIMgr.ShowUI(AllUI.UI_Bag_GoldExchange, nil, nil, nil, nil, true, 2, 1);
	elseif id == 14 then --自动设置
		UIMgr.ShowUI(AllUI.UI_Skill_AotoSet);
	end
end

--刷新技能槽位
function OnUpdateSkillView()
	--更新技能信息
	for k, v in ipairs(mSkillSlotList) do
		local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(v.slotIndex);
		local isUnclock = FunUnLockMgr.GetSkillSlotIsUnlock(v.slotIndex);
		if slotInfo ~= nil and isUnclock then
			v.skillId = slotInfo.id;
			v.skillLevel = slotInfo.level;
			local skillInfo = SkillData.GetSkillInfo(slotInfo.id);
			if slotInfo.level == 0 then
				v.skillIconObject:SetActive(false);
				v.lockFlagObject:SetActive(true);
			else
				v.skillIconObject:SetActive(true);
				v.lockFlagObject:SetActive(false);
			end
			--加载技能图标
			v.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillInfo.icon));
			--设置技能标签
			v.tagObject:SetActive(true);
			v.tagLabel.text = skillInfo.desc;
			v.skillInfoLabel.text = WordData.GetWordStringByKey("skill_des_title_info", skillInfo.name, slotInfo.level);
		else
			v.skillIconObject:SetActive(false);
			v.tagObject:SetActive(false);
		end
		v.levelUpEffect:SetActive(false);
		v.unLockEffect:SetActive(false);
	end
	--默认选中普攻技能
	SelectSkillSlot(1);
	--更新技能可升级标志
	UpdateSkillUpFlag();
end

--选中技能槽位
function SelectSkillSlot(slotIndex)
	if mCurrentSelectSlotIndex == slotIndex then return; end
	local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(slotIndex);
	if slotInfo == nil then return; end
	SetSkillDetailInfo(slotInfo.id, slotInfo.level, slotIndex);
	UpdateSlotSelectFlag(slotIndex);
end

--设置技能详情
function SetSkillDetailInfo(skillId, skillLevel, slotIndex)
	local skillBaseInfo = SkillData.GetSkillInfo(skillId);
	local currentLevel = skillLevel;
	local skillCurrentLevelInfo = SkillData.GetSkillLevelInfo(skillId, currentLevel);
	local skillNextLevelInfo = SkillData.GetSkillLevelInfo(skillId, skillLevel + 1);
	local skillTittleStr = "[b]" .. WordData.GetWordStringByKey("skill_des_detail_info", skillBaseInfo.name, skillLevel);
	mSkillNameAndLevelLabel.text = skillTittleStr;
	mConsumeLabel.text = SkillMgr.GetSkillReleaseNeedsStr(skillCurrentLevelInfo.releaseNeeds, 1);
	mSkillDescriptionLabel.text = skillCurrentLevelInfo.desc2;
	mCDLabel.text = SkillMgr.GetSkillCD(skillId, currentLevel);
	
	UpdateSkillLevelUpNeeds(skillId, skillLevel, slotIndex);
end

--刷新技能升级部分信息
function UpdateSkillLevelUpNeeds(skillId, currentSkillLevel, slotIndex)
	local skillLevelUpInfo = SkillData.GetSkillLevelInfo(skillId, currentSkillLevel + 1);
	local isUnclock = FunUnLockMgr.GetSkillSlotIsUnlock(slotIndex);
	local playerLevel = UserData.GetLevel();	
	if not isUnclock then
		--技能槽位未解锁
		mSkillTipLabelObject:SetActive(false);
		mSkillLockFlagObject:SetActive(true);
		mSkillLockTipLabel.text = WordData.GetWordStringByKey("skill_slot_Locked");
		mLevelUpInfoGroupObject:SetActive(false);
		mCurrentLevelUpState = SkillLevelUpState.LevelUp_Locked;
	elseif skillLevelUpInfo == nil then
		--技能达到最高等级
		mSkillTipLabelObject:SetActive(true);
		mSkillLockFlagObject:SetActive(false);
		local desStr = WordData.GetWordStringByKey("skill_des_max_level");
		mSkillTipLabel.text = desStr;
		mLevelUpInfoGroupObject:SetActive(false);
		mCurrentLevelUpState = SkillLevelUpState.LevelUp_Max;
	elseif currentSkillLevel == 0 and playerLevel < skillLevelUpInfo.learnRequireLevel then
		--技能待学习
		mSkillTipLabelObject:SetActive(false);
		mSkillLockFlagObject:SetActive(true);
		local tipStr = string.format(WordData.GetWordStringByKey("skill_study_require"), skillLevelUpInfo.learnRequireLevel);
		mSkillLockTipLabel.text = tipStr;
		mLevelUpInfoGroupObject:SetActive(false);
		mCurrentLevelUpState = SkillLevelUpState.LevelUp_Study;
	else
		--技能可升级
		mLevelUpInfoGroupObject:SetActive(true);
		mLevelUpEffectLabel.text = skillLevelUpInfo.desc;
		mSkillTipLabelObject:SetActive(false);
		mSkillLockFlagObject:SetActive(false);
		if skillLevelUpInfo.learnMustNeeds == nil or skillLevelUpInfo.learnMustNeeds[1] == nil then return; end
		local levelUpNeedInfo = skillLevelUpInfo.learnMustNeeds[1];
		local itemData = ItemData.GetItemInfo(levelUpNeedInfo.id);
		mLevelUpCountLabel.text = levelUpNeedInfo.count;
		local moneyCount = BagMgr.GetMoney(Coin_pb.SILVER);
		mOwnCount.text = moneyCount;
		if moneyCount < levelUpNeedInfo.count then
			mOwnCount.color = Color.New(1, 0, 0, 1);
		else
			mOwnCount.color = Color.New(0.53, 0.34, 0.2, 1);
		end
		mCurrentLevelUpState = SkillLevelUpState.LevelUp_Normal;
	end
end

--更新技能选择标志
function UpdateSlotSelectFlag(slotIndex)
	local currentIndex = mCurrentSelectSlotIndex;
	if mCurrentSelectSlotIndex > 4 then
		currentIndex = currentIndex - 1;
	end
	local beforeSelectSlotItem = mSkillSlotList[currentIndex];
	if beforeSelectSlotItem ~= nil then
		beforeSelectSlotItem.selectFlagObject:SetActive(false);
	end

	mCurrentSelectSlotIndex = slotIndex;
	if mCurrentSelectSlotIndex ~= - 1 then
		local newIndex = slotIndex;
		if slotIndex > 4 then
			newIndex = newIndex - 1;
		end
		mSkillSlotList[newIndex].selectFlagObject:SetActive(true);
	end
end

function OnSkillLevelUp(levelUpInfoList)
	--提示信息
	if #levelUpInfoList > 1 then
		--升级多个技能
		TipsMgr.TipByKey("Skill_LevelUp_True_All");
	elseif #levelUpInfoList == 1 then
		for m, n in ipairs(mSkillSlotList) do
			if levelUpInfoList[1].skillId == n.skillId then
				if levelUpInfoList[1].skillLevel - n.skillLevel > 1 then
					--单个技能升多级
					TipsMgr.TipByKey("Skill_LevelUp_True_All");
				else
					--单个技能升一级
					local skillTableInfo = SkillData.GetSkillInfo(levelUpInfoList[1].skillId);
					local skillLevelUpInfo = SkillData.GetSkillLevelInfo(levelUpInfoList[1].skillId, levelUpInfoList[1].skillLevel);
					local levelUpNeedInfo = skillLevelUpInfo.learnMustNeeds[1];
					local levelUpNeedCount = levelUpNeedInfo.count;
					local tipStr = string.format(WordData.GetWordStringByKey("skill_levelup_spend"), levelUpNeedCount, skillTableInfo.name, levelUpInfoList[1].skillLevel);
					TipsMgr.TipCommon(tipStr);
				end
				break;
			end
		end
	end
	--技能信息更新
	for k, v in ipairs(levelUpInfoList) do
		for m, n in ipairs(mSkillSlotList) do
			if v.skillId == n.skillId then
				local isUnclock = FunUnLockMgr.GetSkillSlotIsUnlock(n.slotIndex);
				if isUnclock then
					--技能基本信息
					local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(n.slotIndex);
					local skillInfo = SkillData.GetSkillInfo(slotInfo.id);
					n.skillInfoLabel.text = WordData.GetWordStringByKey("skill_des_title_info", skillInfo.name, slotInfo.level);
					n.skillIconObject:SetActive(true);
					n.lockFlagObject:SetActive(false);
					if n.slotIndex == mCurrentSelectSlotIndex then
						SetSkillDetailInfo(v.skillId, v.skillLevel, n.slotIndex);
					end
					if n.skillLevel ~= 0 then
						--播放技能升级特效
						n.levelUpEffect:SetActive(false);
						n.levelUpEffect:SetActive(true);
					else
						--播放技能解锁特效
						n.unlockEffect:SetActive(false);
						n.unlockEffect:SetActive(true);
					end
					--刷新技能可升级标志
					UpdateSkillUpFlagBySlotIndex(n.slotIndex);
				end
				n.skillLevel = v.skillLevel;
				break;
			end
		end
	end
end

--更新槽位锁定状态
function UpdateSlotLockState(funIndex, isUnlock)
	local slotIndex = FunUnLockMgr.GetSkillSlotIndexByFunIndex(funIndex);
	local slotItem = mSkillSlotList[slotIndex];
	local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(slotIndex);
	if slotItem == nil then return end
	if isUnlock then
		local skillInfo = SkillData.GetSkillInfo(slotInfo.id);
		slotItem.skillInfoLabel.text = WordData.GetWordStringByKey("skill_des_title_info", skillInfo.name, slotInfo.level);
		slotItem.skillIconObject:SetActive(true);
		slotItem.lockFlagObject:SetActive(false);
		if slotIndex == mCurrentSelectSlotIndex then
			SetSkillDetailInfo(slotInfo.id, slotInfo.level, slotIndex);
		end
		if slotInfo.level ~= 0 then
			slotItem.unlockEffect:SetActive(false);
			slotItem.unlockEffect:SetActive(true);
		end
		UpdateSkillUpFlagBySlotIndex(slotIndex);
	else
		slotItem.skillIconObject:SetActive(false);
		slotItem.lockFlagObject:SetActive(true);
		if slotIndex == mCurrentSelectSlotIndex then
			SetSkillDetailInfo(slotInfo.id, slotInfo.level, slotIndex);
		end
	end
end

--刷新货币数量
function UpdateMoney()
	local moneyCount = BagMgr.GetMoney(Coin_pb.SILVER);
	mOwnCount.text = moneyCount;
	local needCount = tonumber(mLevelUpCountLabel.text);
	if needCount > moneyCount then
		mOwnCount.color = Color.New(1, 0, 0, 1);
	else
		mOwnCount.color = Color.New(0.53, 0.34, 0.2, 1);
	end
end

--玩家升级
function OnPlayerLevelUp(entity)
	if entity == nil or entity:IsSelf() then
		UpdateSkillUpFlag();
		local selectSlotItem = mSkillSlotList[mCurrentSelectSlotIndex];
		if mCurrentLevelUpState == SkillLevelUpState.LevelUp_Study then
			local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(mCurrentSelectSlotIndex);
			if slotInfo == nil then return; end
			SetSkillDetailInfo(selectSlotItem.skillId, slotInfo.level);
		end
	end
end

function UpdateSkillUpFlag()
	for k, v in ipairs(mSkillSlotList) do
		UpdateSkillUpFlagBySlotIndex(v.slotIndex);
	end
end

function UpdateSkillUpFlagBySlotIndex(slotIndex)
	local slotItem = nil;
	for k, v in ipairs(mSkillSlotList) do
		if v.slotIndex == slotIndex then
			slotItem = v;
			break;
		end
	end
	
	local slotInfo = SkillMgr.GetSkillInfoBySlotIndex(slotIndex);
	local isUnclock = FunUnLockMgr.GetSkillSlotIsUnlock(slotIndex);
	if slotItem and slotInfo then
		if isUnclock then
			local skillLevelUpInfo = SkillData.GetSkillLevelInfo(slotInfo.id, slotInfo.level + 1);
			if skillLevelUpInfo then
				local requireLevel = skillLevelUpInfo.learnRequireLevel;
				local playerLevel = UserData.GetLevel();
				if playerLevel >= requireLevel then
					slotItem.upFlagObject:SetActive(true);
				else
					slotItem.upFlagObject:SetActive(false);
				end
			else	
				slotItem.upFlagObject:SetActive(false);
			end
		else
			slotItem.upFlagObject:SetActive(false);
		end
	end
end

--一键升级
function SkillLevelUpAuto(firstSkillId)
	local isAllGetCurrentMaxLevel = true;
	local isAllGetMaxLevel = true;
	for k, v in ipairs(mSkillSlotList) do
		local skillId = v.skillId;
		local skillLevel = v.skillLevel;
		local nextSkillLevelInfo = SkillData.GetSkillLevelInfo(skillId, skillLevel + 1);
		if nextSkillLevelInfo then
			isAllGetMaxLevel = false;
			local playerLevel = UserData.GetLevel();
			if playerLevel >= nextSkillLevelInfo.learnRequireLevel then
				isAllGetCurrentMaxLevel = false;
				local learnNeeds = nextSkillLevelInfo.learnMustNeeds[1].count;
				local moneyCount = BagMgr.GetMoney(Coin_pb.SILVER);
				if moneyCount >= learnNeeds then
					SkillMgr.RequestNormalSkillLevelUp(NetCS_pb.CSComSkillLiftLevel.Op_FAST, firstSkillId);
					return;
				end
			end
		end
	end
	if isAllGetMaxLevel then
		--技能等级全满
		TipsMgr.TipByKey("skill_Auto_levelup_max");
	elseif isAllGetCurrentMaxLevel then
		--人物等级不足无法升级
		TipsMgr.TipByKey("Skill_LevelUp_False_LevelLimit");
	else
		--打开货币兑换界面
		local needCount = GetAllAutoLevelUpNeeds();
		local moneyCount = BagMgr.GetMoney(Coin_pb.SILVER);
		needCount = needCount - moneyCount;
		BagMgr.SupplyExchangeCoin(Coin_pb.SILVER, needCount, SkillLevelUpAuto, firstSkillId);
	end
end

--获取所有技能升至当前最高等级的消耗
function GetAllAutoLevelUpNeeds()
	local needCount = 0;
	local playerLevel = UserData.GetLevel();
	for k, v in ipairs(mSkillSlotList) do
		local skillId = v.skillId;
		local skillLevel = v.skillLevel;
		local nextSkillLevelInfo = SkillData.GetSkillLevelInfo(skillId, skillLevel + 1);
		while nextSkillLevelInfo and playerLevel >= nextSkillLevelInfo.learnRequireLevel do
			needCount = needCount + nextSkillLevelInfo.learnMustNeeds[1].count;
			skillLevel = skillLevel + 1;
			nextSkillLevelInfo = SkillData.GetSkillLevelInfo(skillId, skillLevel + 1);
		end
	end
	return needCount;
end

--技能升级
function SkillLevelUp(skillId)
	local needCount = tonumber(mLevelUpCountLabel.text);
	local ownCount = tonumber(mOwnCount.text);
	if ownCount >= needCount then
		SkillMgr.RequestNormalSkillLevelUp(NetCS_pb.CSComSkillLiftLevel.Op_LIFT, skillId);
	else
		BagMgr.SupplyExchangeCoin(Coin_pb.SILVER, needCount - ownCount, SkillLevelUp, skillId);
	end
end

