module("UI_FightHelp_Info", package.seeall);

local mSelf;
local mFightHelperId;
local mCurrentFightHelperIndex = 1;
local mFightHelperList;

local mNameLabel;
local mProfessionIcon;
local mLevelLabel;
local mQualityLabel;

local mCharacterLabel;
local mBackgroundLabel;

local mHPValueLabel;
local mPhysicalAttackValueLabel;
local mMagicAttackValueLabel;
local mPhysicalDefenceValueLabel;
local mMagicDefenseValueLabel;
local mFightHelperTexture;

local mStarPool = {};
local mStarLevelProgressBar;
local mStarLevelProgressLabel;

local mAttackSkillPool = {};
local mTravelSkillPool = {};

local mCurrentFragmentCount;
local mNextStarLevelNeeds;

local mSkillTable;
local mAttackSkillGrid;
local mTravelSkillGrid;

local mOutFromeFormationBtn;
local mJoinFormationBtnObject;

local mBtnIcon;

local mFightHelperTexLoader = nil;

local MAX_STAR_COUNT = 6;

local MAX_ATTACK_SKILL_COUNT = 8;
local MAX_TRAVEL_SKILL_COUNT = 8;

function OnCreate(self)
	mSelf = self;
	
	mNameLabel = self:FindComponent("UILabel", "Offset/BaseInfo/NameLabel");
	mProfessionIcon = self:FindComponent("UISprite", "Offset/BaseInfo/ProfessionIcon");
	mLevelLabel = self:FindComponent("UILabel", "Offset/BaseInfo/LevelLabel");
	mQualityLabel = self:FindComponent("UILabel", "Offset/BaseInfo/Quality/Label");
	
	mCharacterLabel = self:FindComponent("UILabel", "Offset/DesInfo/CharacterLabel");
	mBackgroundLabel = self:FindComponent("UILabel", "Offset/DesInfo/BackgroundLabel");
	
	mHPValueLabel = self:FindComponent("UILabel", "Offset/DetailInfo/ValueInfo/HPValueLabel");
	mPhysicalAttackValueLabel = self:FindComponent("UILabel", "Offset/DetailInfo/ValueInfo/PhysicalAttackValue");
	mMagicAttackValueLabel = self:FindComponent("UILabel", "Offset/DetailInfo/ValueInfo/MagicAttackValue");
	mPhysicalDefenceValueLabel = self:FindComponent("UILabel", "Offset/DetailInfo/ValueInfo/PhysicalDefenceValue");
	mMagicDefenseValueLabel = self:FindComponent("UILabel", "Offset/DetailInfo/ValueInfo/MagicDefenseValue");
	
	mFightHelperTexture = self:Find("Offset/FightHelperTexture").transform;
	
	local starCommonPath = "Offset/DetailInfo/StarLevelInfo/StarList/StarBg";
	for i = 1, MAX_STAR_COUNT do
		local starItem = {};
		starItem.bg = self:FindComponent("UISprite", starCommonPath .. i);
		starItem.icon = self:FindComponent("UISprite", starCommonPath .. i .. "/Icon");
		table.insert(mStarPool, starItem);
	end
	
	mStarLevelProgressBar = self:FindComponent("UIProgressBar", "Offset/DetailInfo/StarLevelInfo/StarLevelProgressBar");
	mStarLevelProgressLabel = self:FindComponent("UILabel", "Offset/DetailInfo/StarLevelInfo/StarLevelProgressBar/ProgressLabel");
	
	mSkillTable = self:FindComponent("UITable", "Offset/DetailInfo/SkillInfo/SkillScrollView/Table");
	mAttackSkillGrid = self:FindComponent("UIGrid", "Offset/DetailInfo/SkillInfo/SkillScrollView/Table/AttackSkillGrid");
	mTravelSkillGrid = self:FindComponent("UIGrid", "Offset/DetailInfo/SkillInfo/SkillScrollView/Table/TravelSkillGrid");
	
	local attackSkillCommonPath = "Offset/DetailInfo/SkillInfo/SkillScrollView/Table/AttackSkillGrid/AttackSkill"
	for i = 1, MAX_ATTACK_SKILL_COUNT do
		local skillItem = {};
		skillItem.skillId = 0;
		skillItem.skillLevel = - 1;
		skillItem.openStarLevel = 0;
		skillItem.isActive = false;
		skillItem.bg = self:FindComponent("UISprite", attackSkillCommonPath .. i);
		skillItem.skillIcon = self:FindComponent("UITexture", attackSkillCommonPath .. i .. "/SkillIcon");
		skillItem.iconLoader = LoaderMgr.CreateTextureLoader(skillItem.skillIcon);
		skillItem.skillLevelInfo = self:FindComponent("UISprite", attackSkillCommonPath .. i .. "/SkillLevelBg");
		skillItem.skillLevelLabel = self:FindComponent("UILabel", attackSkillCommonPath .. i .. "/SkillLevelBg/LevelLabel");
		skillItem.locakFlag = self:FindComponent("UISprite", attackSkillCommonPath .. i .. "/LockFlag");
		table.insert(mAttackSkillPool, skillItem);
	end
	
	local travelSkillCommonPath = "Offset/DetailInfo/SkillInfo/SkillScrollView/Table/TravelSkillGrid/TravelSkill"
	for i = 1, MAX_TRAVEL_SKILL_COUNT do
		local skillItem = {};
		skillItem.skillId = 0;
		skillItem.skillLevel = - 1;
		skillItem.openStarLevel = 0;
		skillItem.isActive = false;
		skillItem.bg = self:FindComponent("UISprite", travelSkillCommonPath .. i);
		skillItem.skillIcon = self:FindComponent("UITexture", travelSkillCommonPath .. i .. "/SkillIcon");
		skillItem.iconLoader = LoaderMgr.CreateTextureLoader(skillItem.skillIcon);
		skillItem.skillLevelInfo = self:FindComponent("UISprite", travelSkillCommonPath .. i .. "/SkillLevelBg");
		skillItem.skillLevelLabel = self:FindComponent("UILabel", travelSkillCommonPath .. i .. "/SkillLevelBg/LevelLabel");
		skillItem.locakFlag = self:FindComponent("UISprite", travelSkillCommonPath .. i .. "/LockFlag");
		table.insert(mTravelSkillPool, skillItem);
	end
	
	mOutFromeFormationBtn = self:FindComponent("UISprite", "Offset/InactiveBtn");
	mJoinFormationBtnObject = self:Find("Offset/ActiveBtn").gameObject;
	mBtnIcon = self:FindComponent("UISprite", "Offset/DetailInfo/StarLevelInfo/StarLevelUpBtn/Sprite");
	
	mFightHelperTexLoader = LoaderMgr.CreateEffectLoader();
end

function OnEnable(self, ...)
	RegEvent(self);
	local args = {...};
	mFightHelperList = args[1];
	local fightHelperId = args[2];
	mFightHelperId = fightHelperId;
	for k, v in ipairs(mFightHelperList) do
		if v.id == fightHelperId then
			mCurrentFightHelperIndex = k;
		end
	end
	SetFightHelperInfo(fightHelperId);
end

function OnDisabel(self)
	UnRegEvent(self);
end

function RegEvent(self)
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_STARUP, OnFightHelperStarUpInInfoPage);
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, OnPlayerLevelUp);
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_FORMATIONCHANGED, OnFightHelperActiveStateChanged);
end

function UnRegEvent(self)
	GameEvent.UnReg(EVT.FIGHTHELP, EVT.FIGHTHELP_STARUP, OnFightHelperStarUpInInfoPage);
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, OnPlayerLevelUp);
	GameEvent.UnReg(EVT.FIGHTHELP, EVT.FIGHTHELP_FORMATIONCHANGED, OnFightHelperActiveStateChanged);
end

function OnClick(go, id)
	if id == 0 then
		UIMgr.UnShowUI(AllUI.UI_FightHelp_Info);
	elseif id == 1 then --获取按钮被点击了
	elseif id == 2 then --下阵按钮被点击了
		FightHelpMgr.WithdrawFromCurrentFormation(mFightHelperId);
	elseif id == 3 then --升星按钮被点击了
		FightHelpMgr.FightHelperStarUp(mFightHelperId);
	elseif id == 4 then --左翻页
		SwitchFightHelperInfo(false);
	elseif id == 5 then --右翻页
		SwitchFightHelperInfo(true);
	elseif id == 6 then --上阵
		JoinCurrentFormation();
	elseif id > 10 and id <= 20 then --攻击技能被点击了
		SelectAttackSkill(id - 10);
	elseif id > 20 and id <= 30 then --游历技能被点击了
		SelectTrabelSkill(id - 20);
	end
end

function SetFightHelperInfo(fightHelperId)
	local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(fightHelperId);
	if not fightHelperBaseInfo then return; end
	
	local fightHelpOwnState = FightHelpMgr.GetFightHelperOwnState(fightHelperId);
	
	local fightHelperNetInfo = FightHelpMgr.GetFightHelpInfo(fightHelperId);
	
	mNameLabel.text = fightHelperBaseInfo.name;
	--助战类型
	if fightHelperBaseInfo.professionId == 1 then --战士
		mProfessionIcon.spriteName = "icon_common_zhiye_01";
	elseif fightHelperBaseInfo.professionId == 2 then --法师
		mProfessionIcon.spriteName = "icon_common_zhiye_02";
	elseif fightHelperBaseInfo.professionId == 3 then --猎人
		mProfessionIcon.spriteName = "icon_common_zhiye_03";
	elseif fightHelperBaseInfo.professionId == 4 then --刺客
		mProfessionIcon.spriteName = "icon_common_zhiye_04";
	elseif fightHelperBaseInfo.professionId == 5 then --牧师
		mProfessionIcon.spriteName = "icon_common_zhiye_05";
	end
	--等级
	local levelValue = UserData.GetLevel();
	mLevelLabel.text = levelValue .. "级";
	
	--品质
	if fightHelperBaseInfo.quality == 1 then
		mQualityLabel.text = "N";
	elseif fightHelperBaseInfo.quality == 2 then
		mQualityLabel.text = "R";
	elseif fightHelperBaseInfo.quality == 3 then
		mQualityLabel.text = "SR";
	elseif fightHelperBaseInfo.quality == 4 then
		mQualityLabel.text = "SSR";
	end
	--个性标签
	--背景描述
	mBackgroundLabel.text = WordData.GetWordStringByKey(fightHelperBaseInfo.desKey);
	--星级
	for i = 1, #mStarPool do
		if i <= fightHelperBaseInfo.maxStarCount then
			mStarPool[i].bg.gameObject:SetActive(true);
			if fightHelpOwnState == 1 then
				if i <= fightHelperNetInfo.starLevel then
					mStarPool[i].icon.gameObject:SetActive(true);
				else
					mStarPool[i].icon.gameObject:SetActive(false);
				end
			else
				if i == 1 then
					mStarPool[i].icon.gameObject:SetActive(true);
				else
					mStarPool[i].icon.gameObject:SetActive(false);
				end
			end
		else
			mStarPool[i].bg.gameObject:SetActive(false);
		end
	end
	local currentStarLevel = 1;
	if fightHelpOwnState == 1 then
		mCurrentFragmentCount = fightHelperNetInfo.fragCount;
		currentStarLevel = fightHelperNetInfo.starLevel;
		local nextStarLevel = currentStarLevel == fightHelperBaseInfo.maxStarCount and currentStarLevel or currentStarLevel + 1;
		local nextStarInfo = FightHelpMgr.GetFightHelpStarInfo(fightHelperId, nextStarLevel);
		if nextStarInfo then
			mNextStarLevelNeeds = nextStarInfo.needItemCount;
		end
	elseif fightHelpOwnState == 2 or fightHelpOwnState == 3 then
		mCurrentFragmentCount = fightHelperNetInfo.fragCount;
		mNextStarLevelNeeds = fightHelperBaseInfo.fagmentRequireCount;
	else
		mCurrentFragmentCount = 0;
		mNextStarLevelNeeds = fightHelperBaseInfo.fagmentRequireCount;
	end
	
	mStarLevelProgressLabel.text = mCurrentFragmentCount .. "/" .. mNextStarLevelNeeds;
	mStarLevelProgressBar.value = mCurrentFragmentCount / mNextStarLevelNeeds;
	--设置升星按钮
	--数值
	local propertyArray = PropertyData.GetPropertyAtt(fightHelperBaseInfo.attributeId);
	local propertyType = EntityDefine.ENTITY_TYPE.HELPER;
	local emptyTable = table.emptyTable;
	mHPValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_HP_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
	mPhysicalAttackValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_PHYSIC_ATT_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
	mMagicAttackValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_MAGIC_ATT_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
	mPhysicalDefenceValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_PHYSIC_DEF_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
	mMagicDefenseValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_MAGIC_DEF_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
	
	--技能
	local skillGroupInfo = FightHelpData.GetFightHelpSkillInfoById(fightHelperBaseInfo.skillGroupId);
	local attackSkillList = skillGroupInfo.hurtSkillInfoList;
	local attackSkillCount = #attackSkillList;
	for k, v in ipairs(mAttackSkillPool) do
		if k <= attackSkillCount then
			v.bg.gameObject:SetActive(true);
			v.openStarLevel = attackSkillList[k].openStarLevel;
			v.skillId = attackSkillList[k].skillId;
			--设置技能图标
			local skillInfo = SkillData.GetSkillInfo(v.skillId);
			v.iconLoader:LoadObject(ResConfigData.GetResConfigID(skillInfo.icon));
			--设置是否可用
			if attackSkillList[k].openStarLevel <= currentStarLevel then
				v.locakFlag.gameObject:SetActive(false);
				v.isActive = true;
				v.skillLevel = FightHelpMgr.GetFightHelpSkillLevel(fightHelperId, attackSkillList[k].skillId);
				v.skillLevelInfo.gameObject:SetActive(true);
				v.skillLevelLabel.text = v.skillLevel;
			else
				v.locakFlag.gameObject:SetActive(true);
				v.isActive = false;
				v.skillLevel = - 1;
				v.skillLevelInfo.gameObject:SetActive(false);
			end
		else
			v.bg.gameObject:SetActive(false)
		end
	end
	mSkillTable:Reposition();
	mAttackSkillGrid:Reposition();
	mTravelSkillGrid:Reposition();
	
	--下阵按钮
	local isInCurrentFormation = FightHelpMgr.GetIsInCurrentFormation(fightHelperId);
	mOutFromeFormationBtn.gameObject:SetActive(isInCurrentFormation);
	mJoinFormationBtnObject:SetActive(not isInCurrentFormation);

	--解锁/升星按钮
	if fightHelpOwnState == 1 then
		mBtnIcon.spriteName = "icon_common_arrow06";
	else
		mBtnIcon.spriteName = "icon_common_lock2";
	end
	
	--立绘
	mFightHelperTexLoader:LoadObject(fightHelperBaseInfo.mainTexId);
	local rootSortorder = mSelf:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
	mFightHelperTexLoader:SetSortOrder(rootSortorder);
	mFightHelperTexLoader:SetParent(mFightHelperTexture.transform);
	mFightHelperTexLoader:SetLocalPosition(Vector3(-345.8, -190.48, 0));
	mFightHelperTexLoader:SetLocalScale(Vector3(20, 20, 1));
	mFightHelperTexLoader:SetActive(true);
end

function SelectAttackSkill(slotIndex)
	local skillSlotItem = mAttackSkillPool[slotIndex];
	if not skillSlotItem then return; end
	local skillInfo = {};
	skillInfo.fightHelperId = mFightHelperId;
	skillInfo.skillId = skillSlotItem.skillId;
	skillInfo.skillLevel = skillSlotItem.skillLevel;
	
	UIMgr.ShowUI(AllUI.UI_Tip_FightHelpSkill, mSelf, nil, nil, nil, true, skillInfo);
end

function SelectTrabelSkill(slotIndex)
	
end

function OnFightHelperStarUpInInfoPage(info)
	if info.fightHelperId == mFightHelperId then
		for i = 1, #mStarPool do
			if i <= info.starLevel then
				mStarPool[i].icon.gameObject:SetActive(true);
			else
				mStarPool[i].icon.gameObject:SetActive(false);
			end
		end
	end
	local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(info.fightHelperId);
	local nextStarLevel = info.starLevel == fightHelperBaseInfo.maxStarCount and info.starLevel or info.starLevel + 1;
	local nextStarInfo = FightHelpMgr.GetFightHelpStarInfo(info.fightHelperId, nextStarLevel);
	if nextStarInfo then
		mNextStarLevelNeeds = nextStarInfo.needItemCount;
	end
	mCurrentFragmentCount = info.fragCount;
	mStarLevelProgressLabel.text = mCurrentFragmentCount .. "/" .. mNextStarLevelNeeds;
	mStarLevelProgressBar.value = mCurrentFragmentCount / mNextStarLevelNeeds;
	mBtnIcon.spriteName = "icon_common_arrow06";
end

function SwitchFightHelperInfo(isNext)
	if isNext then
		local dirIndex = mCurrentFightHelperIndex + 1;
		if dirIndex > #mFightHelperList then
			TipsMgr.TipByKey("FightHelp_List_End");
		else
			SetFightHelperInfo(mFightHelperList[dirIndex].id);
			mFightHelperId = mFightHelperList[dirIndex].id;
			mCurrentFightHelperIndex = dirIndex;
		end
	else
		local dirIndex = mCurrentFightHelperIndex - 1;
		if dirIndex < 1 then
			TipsMgr.TipByKey("FightHelp_List_End");
		else
			SetFightHelperInfo(mFightHelperList[dirIndex].id);
			mFightHelperId = mFightHelperList[dirIndex].id;
			mCurrentFightHelperIndex = dirIndex;
		end
	end
end

function OnPlayerLevelUp(entity)
	if entity == nil or entity:IsSelf() then
		local levelValue = UserData.GetLevel();
		mLevelLabel.text = levelValue .. "级";
		
		--数值
		local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(mFightHelperId);
		local propertyArray = PropertyData.GetPropertyAtt(fightHelperBaseInfo.attributeId);
		local propertyType = EntityDefine.ENTITY_TYPE.HELPER;
		local emptyTable = table.emptyTable;
		mHPValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_HP_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
		mPhysicalAttackValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_PHYSIC_ATT_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
		mMagicAttackValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_MAGIC_ATT_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
		mPhysicalDefenceValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_PHYSIC_DEF_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
		mMagicDefenseValueLabel.text = AttrCalculator.CalculUIValue(PropertyInfo_pb.SP_MAGIC_DEF_BASE, levelValue, propertyArray, emptyTable, propertyType, fightHelperBaseInfo);
	end
end 

function OnFightHelperActiveStateChanged(formationIndex)
	if FightHelpMgr.GetCurrentFormationIndex() ~= formationIndex then return; end
	local formationInfo = FightHelpMgr.GetFormationInfoByIndex(formationIndex);
	local fightHelperList = formationInfo.fightHelperList;
	local isFind = false;
	for k, fightHelperId in ipairs(fightHelperList) do
		if fightHelperId == mFightHelperId then
			isFind = true;
			break;
		end
	end
	mOutFromeFormationBtn.gameObject:SetActive(isFind);
	mJoinFormationBtnObject:SetActive(not isFind);
end

function JoinCurrentFormation()
	local currentActiveFormation = FightHelpMgr.GetCurrentFormationIndex();
	local formationInfo = FightHelpMgr.GetFormationInfoByIndex(currentActiveFormation);
	local fightHelperList = formationInfo.fightHelperList;
	for k, fightHelperId in ipairs(fightHelperList) do
		if fightHelperId == -1 then
			FightHelpMgr.RequireFightHelperActive(mFightHelperId, currentActiveFormation, k, true);
			break;
		end
	end
	TipsMgr.TipByKey("fighthelper_tip_formationfull");
end