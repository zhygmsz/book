module("UI_FightHelp_Handbook", package.seeall);

local FightHelperShowModel = {
	List_Show = 1;
	Grid_Show = 2
}

local mSelf;

local mHeroDetailItemPrefab;
local mHeroDetailListWrap;
local mDetailWrapCall;

local mHeroBreviaryItemPrefab;
local mHeroBreviaryListWrap;
local mBreviaryWrapCall;

local mHeroDetailItemPool = {};
local mHeroBreviaryItemPool = {};
local mFightHelperInfoList = {};

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

local mStarPool = {};
local mStarLevelProgressBar;
local mStarLevelProgressLabel;

local mAttackSkillPool = {};
local mTravelSkillPool = {};

local mSkillTable;
local mAttackSkillGrid;
local mTravelSkillGrid;

local mGetFunctionLabel;

local mBackgroundInfoToggle;
local mDetailInfoToggle;

local mFightHelperShowModel;

local mFightHelperTexLoader = nil;
local mAnimationState1;
local mFightHelperTexture;

local mBtnIcon;

local mSwitchBtnIcon;

local mFilterItemList = {};

local mSelectFightHelperId = - 1;
local mBackgroundInfoId = - 1;
local mDetailInfoId = - 1;

local mCurrentFragmentCount = - 1;
local mNextStarLevelNeeds = - 1;

local MAX_HERO_DETAIL_WRAP_COUNT = 7;
local MAX_HERO_BREVIARY_WRAP_COUNT = 20;
local MAX_STAR_COUNT = 6;
local mCurrentFilterIndex = 0;

local FILTER_COUNT = 5;

local MAX_ATTACK_SKILL_COUNT = 8;
local MAX_TRAVEL_SKILL_COUNT = 8;

function OnCreate(self)
	mSelf = self;
	
	mHeroDetailItemPrefab = self:Find("Offset/HeroList/HeroDetailItemPrefab").transform;
	mHeroDetailItemPrefab.gameObject:SetActive(false);
	mHeroDetailListWrap = self:FindComponent("UIWrapContent", "Offset/HeroList/ScrollView/HeroDetailWrap");
	mDetailWrapCall = UIWrapContent.OnInitializeItem(OnUpdateDetailItem);
	InitHeroDetailItemPool();
	
	mHeroBreviaryItemPrefab = self:Find("Offset/HeroList/HeroBreviaryItemPrefab").transform;
	mHeroBreviaryItemPrefab.gameObject:SetActive(false);
	mHeroBreviaryListWrap = self:FindComponent("UIWrapContent", "Offset/HeroList/ScrollView/HeroBreviaryWrap");
	mBreviaryWrapCall = UIWrapContent.OnInitializeItem(OnUpdateBreviaryItem);
	InitHeroBreviaryItemPool();
	
	mBackgroundInfoToggle = self:FindComponent("UIToggle", "Offset/TabList/BackgroundTab");
	mDetailInfoToggle = self:FindComponent("UIToggle", "Offset/TabList/AttributeTab");
	local backGroundInfoCall = EventDelegate.Callback(OnBackgroundInfoToggleChanged);
	local detailInfoCall = EventDelegate.Callback(OnDetailInfoToggleChanged);
	EventDelegate.Add(mBackgroundInfoToggle.onChange, backGroundInfoCall);
	EventDelegate.Add(mDetailInfoToggle.onChange, detailInfoCall);
	
	mNameLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/BackgroundInfo/BaseInfo/NameLabel");
	mProfessionIcon = self:FindComponent("UISprite", "Offset/FightHelpInfo/BackgroundInfo/BaseInfo/ProfessionIcon");
	mLevelLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/BackgroundInfo/BaseInfo/LevelLabel");
	mQualityLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/BackgroundInfo/BaseInfo/Quality/Label");
	
	mCharacterLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/BackgroundInfo/DesInfo/CharacterLabel");
	mBackgroundLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/BackgroundInfo/DesInfo/BackgroundLabel");
	
	mHPValueLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/DetailInfo/ValueInfo/HPValueLabel");
	mPhysicalAttackValueLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/DetailInfo/ValueInfo/PhysicalAttackValue");
	mMagicAttackValueLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/DetailInfo/ValueInfo/MagicAttackValue");
	mPhysicalDefenceValueLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/DetailInfo/ValueInfo/PhysicalDefenceValue");
	mMagicDefenseValueLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/DetailInfo/ValueInfo/MagicDefenseValue");
	
	for i = 1, FILTER_COUNT do
		local filterItem = {};
		filterItem.index = i;
		local filterPath = "Offset/HeroList/FilterList/Filte0" .. i;
		filterItem.bg = self:FindComponent("UISprite", filterPath);
		table.insert(mFilterItemList, filterItem);
	end
	
	local starCommonPath = "Offset/FightHelpInfo/DetailInfo/StarLevelInfo/StarList/StarBg";
	for i = 1, MAX_STAR_COUNT do
		local starItem = {};
		starItem.bg = self:FindComponent("UISprite", starCommonPath .. i);
		starItem.icon = self:FindComponent("UISprite", starCommonPath .. i .. "/Icon");
		table.insert(mStarPool, starItem);
	end
	
	mStarLevelProgressBar = self:FindComponent("UIProgressBar", "Offset/FightHelpInfo/DetailInfo/StarLevelInfo/StarLevelProgressBar");
	mStarLevelProgressLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/DetailInfo/StarLevelInfo/StarLevelProgressBar/ProgressLabel");
	
	mSkillTable = self:FindComponent("UITable", "Offset/FightHelpInfo/DetailInfo/SkillInfo/SkillScrollView/Table");
	mAttackSkillGrid = self:FindComponent("UIGrid", "Offset/FightHelpInfo/DetailInfo/SkillInfo/SkillScrollView/Table/AttackSkillGrid");
	mTravelSkillGrid = self:FindComponent("UIGrid", "Offset/FightHelpInfo/DetailInfo/SkillInfo/SkillScrollView/Table/TravelSkillGrid");
	
	mGetFunctionLabel = self:FindComponent("UILabel", "Offset/FightHelpInfo/DetailInfo/GetFunctionTitle/GetFunctionLabel");
	
	local attackSkillCommonPath = "Offset/FightHelpInfo/DetailInfo/SkillInfo/SkillScrollView/Table/AttackSkillGrid/AttackSkill"
	for i = 1, MAX_ATTACK_SKILL_COUNT do
		local skillItem = {};
		skillItem.skillId = 0;
		skillItem.skillLevel = - 1;
		skillItem.openStarLevel = 0;
		skillItem.isActive = false;
		skillItem.bg = self:FindComponent("UISprite", attackSkillCommonPath .. i);
		skillItem.skillIcon = self:FindComponent("UITexture", attackSkillCommonPath .. i .. "/SkillIcon");
		skillItem.iconLoader = LoaderMgr.CreateTextureLoader(skillItem.skillIcon);
		skillItem.skillLevelLabel = self:FindComponent("UILabel", attackSkillCommonPath .. i .. "/SkillLevelBg/LevelLabel");
		skillItem.skillLevelInfo = self:FindComponent("UISprite", attackSkillCommonPath .. i .. "/SkillLevelBg");
		skillItem.locakFlagObject = self:FindComponent("UISprite", attackSkillCommonPath .. i .. "/LockFlag").gameObject;
		table.insert(mAttackSkillPool, skillItem);
	end
	
	local travelSkillCommonPath = "Offset/FightHelpInfo/DetailInfo/SkillInfo/SkillScrollView/Table/TravelSkillGrid/TravelSkill"
	for i = 1, MAX_TRAVEL_SKILL_COUNT do
		local skillItem = {};
		skillItem.bg = self:FindComponent("UISprite", travelSkillCommonPath .. i);
		skillItem.skillIcon = self:FindComponent("UITexture", travelSkillCommonPath .. i .. "/SkillIcon");
		skillItem.iconLoader = LoaderMgr.CreateTextureLoader(skillItem.skillIcon);
		skillItem.skillLevelInfo = self:FindComponent("UISprite", attackSkillCommonPath .. i .. "/SkillLevelBg");
		skillItem.skillLevelLabel = self:FindComponent("UILabel", travelSkillCommonPath .. i .. "/SkillLevelBg/LevelLabel");
		skillItem.locakFlagObject = self:FindComponent("UISprite", travelSkillCommonPath .. i .. "/LockFlag");
		table.insert(mTravelSkillPool, skillItem);
	end
	
	mBtnIcon = self:FindComponent("UISprite", "Offset/FightHelpInfo/DetailInfo/StarLevelInfo/StarLevelUpBtn/Sprite");
	
	mFightHelperTexture = self:Find("Offset/FightHelpInfo/BackgroundInfo/FightHelperTexture").transform;
	mFightHelperTexLoader = LoaderMgr.CreateEffectLoader();
	
	mSwitchBtnIcon = self:FindComponent("UISprite", "Offset/ModelSwitchBtn/SwitchIcon");
	
	mFightHelperShowModel = FightHelperShowModel.List_Show;
end

function OnEnable(self)
	RegEvent(self);
	mSelectFightHelperId = - 1;
	mBackgroundInfoId = - 1;
	mDetailInfoId = - 1;
	SetFightHelperShowModel(mFightHelperShowModel);
	UpdateFihgtHelperInfoList();
end

function OnDisable(self)
	UnRegEvent(self);
	mSelectFightHelperId = - 1;
	mBackgroundInfoId = - 1;
	mDetailInfoId = - 1;
end

function RegEvent(self)
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_STARUP, OnFightHelperStarUpInHandbook);
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, OnPlayerLevelUp);
end

function UnRegEvent(self)
	GameEvent.UnReg(EVT.FIGHTHELP, EVT.FIGHTHELP_STARUP, OnFightHelperStarUpInHandbook);
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, OnPlayerLevelUp);
end

function OnClick(go, id)
	if id == 1 then     --助战列表显示模式切换
		SwitchFightHelperShowModel();
	elseif id == 2 then	--助战升星按钮被点击了
		FightHelpMgr.FightHelperStarUp(mSelectFightHelperId);
	elseif id == 3 then	--助战筛选1
		SelectFilterItem(1);
	elseif id == 4 then	--助战筛选2
		SelectFilterItem(2);
	elseif id == 5 then	--助战筛选3
		SelectFilterItem(3);
	elseif id == 6 then	--助战筛选4
		SelectFilterItem(4);
	elseif id == 7 then	--助战筛选5
		SelectFilterItem(5);
	elseif id > 10 and id <= 20 then --攻击技能被点击了
		SelectAttackSkill(id - 10);
	elseif id > 20 and id <= 30 then --游历技能被点击了
		SelectTrabelSkill(id - 20);
	elseif id > 1000 then
		OnFightHelperItemClicked(id);
	end
end

function InitHeroDetailItemPool()
	for i = 1, MAX_HERO_DETAIL_WRAP_COUNT do
		local heroItem = {};
		heroItem.gameObject = mSelf:DuplicateAndAdd(mHeroDetailItemPrefab, mHeroDetailListWrap.transform, i).gameObject;
		heroItem.gameObject:SetActive(true);
		heroItem.id = - 1;
		heroItem.isAchieve = false;
		heroItem.isFree = false;
		heroItem.transform = heroItem.gameObject.transform;
		heroItem.bg = heroItem.transform:GetComponent("UISprite");
		heroItem.heroIcon = heroItem.transform:Find("HeroIconBg/HeroIcon"):GetComponent("UITexture");
		heroItem.heroIconLoader = LoaderMgr.CreateTextureLoader(heroItem.heroIcon);
		heroItem.heroName = heroItem.transform:Find("HeroInfo/HeroNameLabel"):GetComponent("UILabel");
		heroItem.heroTypeIcon = heroItem.transform:Find("HeroInfo/TypeIcon"):GetComponent("UISprite");
		heroItem.heroLevelLabel = heroItem.transform:Find("HeroInfo/HeroLevelLabel"):GetComponent("UILabel");
		heroItem.levelBg = heroItem.transform:Find("HeroLevelBg"):GetComponent("UISprite");
		heroItem.qualityLabel = heroItem.transform:Find("HeroLevelBg/LevelLabel"):GetComponent("UILabel");
		heroItem.unuseableMask = heroItem.transform:Find("UnuseableMask"):GetComponent("UISprite");
		heroItem.freeFlagObject = heroItem.transform:Find("FreeFlag").gameObject;
		heroItem.uiEvent = heroItem.transform:GetComponent("UIEvent");
		heroItem.eventId = 0;
		heroItem.starList = {};
		local starBasePath = "HeroInfo/StarList/StarBg"
		for k = 1, MAX_STAR_COUNT do
			local starItem = {};
			starItem.starBg = heroItem.transform:Find(starBasePath .. k):GetComponent("UISprite");
			starItem.starIcon = starItem.starBg.transform:Find("StarIcon"):GetComponent("UISprite");
			heroItem.starList[k] = starItem;
		end
		table.insert(mHeroDetailItemPool, heroItem);
	end
end

function InitHeroBreviaryItemPool()
	for i = 1, MAX_HERO_BREVIARY_WRAP_COUNT do
		local heroItem = {};
		heroItem.gameObject = mSelf:DuplicateAndAdd(mHeroBreviaryItemPrefab, mHeroBreviaryListWrap.transform, i).gameObject;
		heroItem.gameObject:SetActive(true);
		heroItem.id = - 1;
		heroItem.transform = heroItem.gameObject.transform;
		heroItem.heroIcon = heroItem.transform:Find("HeroIcon"):GetComponent("UISprite");
		heroItem.heroIconLoader = LoaderMgr.CreateTextureLoader(heroItem.heroIcon);
		heroItem.freeFlagObject = heroItem.transform:Find("FreeFlag").gameObject;
		heroItem.unuseableMask = heroItem.transform:Find("UnuseableMask"):GetComponent("UISprite");
		heroItem.lockFlagObject = heroItem.transform:Find("LockFlag").gameObject;
		heroItem.selectFlag = heroItem.transform:Find("SelectFlag"):GetComponent("UISprite");
		heroItem.fragCollectLabel = heroItem.transform:Find("FragCollectLabel"):GetComponent("UILabel");
		heroItem.qualityLabel = heroItem.transform:Find("HeroLevelBg/LevelLabel"):GetComponent("UILabel");
		heroItem.uiEvent = heroItem.transform:GetComponent("UIEvent");
		heroItem.eventId = 0;
		table.insert(mHeroBreviaryItemPool, heroItem);
	end
end

function OnUpdateDetailItem(go, index, realIndex)
	if realIndex >= 0 and realIndex < #mFightHelperInfoList then
		go:SetActive(true);
		SetHeroDetailItemInfo(index + 1, realIndex + 1);
	else
		go:SetActive(false);
	end
end

function OnUpdateBreviaryItem(go, index, realIndex)
	if realIndex >= 0 and realIndex < #mFightHelperInfoList then
		go:SetActive(true);
		SetHeroBreviaryItemInfo(index + 1, realIndex + 1);
	else
		go:SetActive(false);
	end
end

function SetHeroDetailItemInfo(heroPoolIndex, heroInfoIndex)
	local fightHelperItem = mHeroDetailItemPool[heroPoolIndex];
	local fightHelpOwnInfo = mFightHelperInfoList[heroInfoIndex];
	
	local fightHelperInfo = FightHelpData.GetFihtHelperInfoById(fightHelpOwnInfo.id);
	if not fightHelperItem or not fightHelperInfo then return; end
	
	local fightHelperNetInfo = FightHelpMgr.GetFightHelpInfo(fightHelpOwnInfo.id);
	
	--助战基础信息
	fightHelperItem.id = fightHelperInfo.id;
	fightHelperItem.gameObject.name = #mFightHelperInfoList - heroInfoIndex;
	fightHelperItem.uiEvent.id = fightHelperInfo.id;
	fightHelperItem.heroName.text = fightHelperInfo.name;
	fightHelperItem.heroIconLoader:LoadObject(fightHelperInfo.icon);
	
	--状态标志	
	if fightHelpOwnInfo.ownState == 1 or fightHelpOwnInfo.ownState == 3 then
		fightHelperItem.unuseableMask.gameObject:SetActive(false);
		fightHelperItem.isAchieve = true;
	else
		fightHelperItem.unuseableMask.gameObject:SetActive(true);
		fightHelperItem.isAchieve = false;
	end
	
	if heroInfoIndex == 1 and mBackgroundInfoId == - 1 then
		OnFightHelperItemClicked(fightHelpOwnInfo.id)
	elseif mSelectFightHelperId == fightHelpOwnInfo.id then
		fightHelperItem.bg.spriteName = "button_common_07";
	else
		fightHelperItem.bg.spriteName = "button_common_06";
	end
	
	--周免
	if fightHelpOwnInfo.ownState == 3 then
		fightHelperItem.freeFlagObject:SetActive(true);
	else
		fightHelperItem.freeFlagObject:SetActive(false);
	end
	
	--助战类型
	if fightHelperInfo.professionId == 1 then --战士
		fightHelperItem.heroTypeIcon.spriteName = "icon_common_zhiye_01";
	elseif fightHelperInfo.professionId == 2 then --法师
		fightHelperItem.heroTypeIcon.spriteName = "icon_common_zhiye_02";
	elseif fightHelperInfo.professionId == 3 then --猎人
		fightHelperItem.heroTypeIcon.spriteName = "icon_common_zhiye_03";
	elseif fightHelperInfo.professionId == 4 then --刺客
		fightHelperItem.heroTypeIcon.spriteName = "icon_common_zhiye_04";
	elseif fightHelperInfo.professionId == 5 then --牧师
		fightHelperItem.heroTypeIcon.spriteName = "icon_common_zhiye_05";
	end
	
	--助战等级
	local levelValue = UserData.GetLevel();
	fightHelperItem.heroLevelLabel.text = levelValue .. "级";
	--品质
	if fightHelperInfo.quality == 1 then
		fightHelperItem.qualityLabel.text = "N";
	elseif fightHelperInfo.quality == 2 then
		fightHelperItem.qualityLabel.text = "R";
	elseif fightHelperInfo.quality == 3 then
		fightHelperItem.qualityLabel.text = "SR";
	elseif fightHelperInfo.quality == 4 then
		fightHelperItem.qualityLabel.text = "SSR";
	end
	--助战星级
	for i = 1, #fightHelperItem.starList do
		if i <= fightHelperInfo.maxStarCount then
			fightHelperItem.starList[i].starBg.gameObject:SetActive(true);
			if fightHelpOwnInfo.ownState == 1 then
				if i <= fightHelperNetInfo.starLevel then
					fightHelperItem.starList[i].starIcon.gameObject:SetActive(true);
				else
					fightHelperItem.starList[i].starIcon.gameObject:SetActive(false);
				end
			else
				if i == 1 then
					fightHelperItem.starList[i].starIcon.gameObject:SetActive(true);
				else
					fightHelperItem.starList[i].starIcon.gameObject:SetActive(false);
				end
			end
		else
			fightHelperItem.starList[i].starBg.gameObject:SetActive(false);
		end
	end
end

function SetHeroBreviaryItemInfo(heroPoolIndex, heroInfoIndex)
	local fightHelperItem = mHeroBreviaryItemPool[heroPoolIndex];
	local fightHelpOwnInfo = mFightHelperInfoList[heroInfoIndex];
	
	local fightHelperInfo = FightHelpData.GetFihtHelperInfoById(fightHelpOwnInfo.id);
	if not fightHelperItem or not fightHelperInfo then return; end
	
	local fightHelperNetInfo = FightHelpMgr.GetFightHelpInfo(fightHelpOwnInfo.id);
	
	fightHelperItem.id = fightHelperInfo.id;
	fightHelperItem.gameObject.name = #mFightHelperInfoList - heroInfoIndex;
	fightHelperItem.uiEvent.id = fightHelperInfo.id;
	fightHelperItem.heroIconLoader:LoadObject(fightHelperInfo.icon)
	
	if fightHelpOwnInfo.ownState == 1 or fightHelpOwnInfo.ownState == 3 then
		fightHelperItem.unuseableMask.gameObject:SetActive(false);
		fightHelperItem.lockFlagObject:SetActive(false);
		fightHelperItem.isAchieve = true;
	else
		fightHelperItem.unuseableMask.gameObject:SetActive(true);
		fightHelperItem.lockFlagObject:SetActive(true);
		fightHelperItem.isAchieve = false;
	end
	if mSelectFightHelperId == fightHelpOwnInfo.id then
		fightHelperItem.selectFlag.gameObject:SetActive(true);
	else
		fightHelperItem.selectFlag.gameObject:SetActive(false);
	end
	
	fightHelperItem.isAchieve = true;
	
	if fightHelpOwnInfo.ownState == 3 then
		fightHelperItem.freeFlagObject:SetActive(true);
		fightHelperItem.fragCollectLabel.gameObject:SetActive(false);	
	elseif fightHelpOwnInfo.ownState == 2 then
		fightHelperItem.freeFlagObject:SetActive(false);
		fightHelperItem.fragCollectLabel.gameObject:SetActive(true);
		local nextStarInfo = FightHelpMgr.GetFightHelpStarInfo(fightHelperInfo.id, 1);
		nextStarLevelNeeds = nextStarInfo.needItemCount;
		fightHelperItem.fragCollectLabel.text = fightHelperNetInfo.fragCount .. "/" .. nextStarLevelNeeds;
	else
		fightHelperItem.freeFlagObject:SetActive(false);
		fightHelperItem.fragCollectLabel.gameObject:SetActive(false);
	end
	
	--品质
	if fightHelperInfo.quality == 1 then
		fightHelperItem.qualityLabel.text = "N";
	elseif fightHelperInfo.quality == 2 then
		fightHelperItem.qualityLabel.text = "R";
	elseif fightHelperInfo.quality == 3 then
		fightHelperItem.qualityLabel.text = "SR";
	elseif fightHelperInfo.quality == 4 then
		fightHelperItem.qualityLabel.text = "SSR";
	end
end

function ResetDetailHeroWrap()
	mHeroDetailListWrap:ResetWrapContent(#mFightHelperInfoList, mDetailWrapCall);
end

function ResetBreviaryHeroWrap()
	mHeroBreviaryListWrap:ResetWrapContent(#mFightHelperInfoList, mBreviaryWrapCall);
end

function SwitchFightHelperShowModel()
	if mFightHelperShowModel == FightHelperShowModel.Grid_Show then
		SetFightHelperShowModel(FightHelperShowModel.List_Show);
	else
		SetFightHelperShowModel(FightHelperShowModel.Grid_Show);
	end
end

function SetFightHelperShowModel(model)
	if model == FightHelperShowModel.List_Show then
		mHeroBreviaryListWrap.gameObject:SetActive(false);
		mHeroDetailListWrap.gameObject:SetActive(true);
		mFightHelperShowModel = FightHelperShowModel.List_Show;
		ResetDetailHeroWrap();
		mSwitchBtnIcon.spriteName = "img_common_pailie02";
	else
		mHeroDetailListWrap.gameObject:SetActive(false);
		mHeroBreviaryListWrap.gameObject:SetActive(true);
		mFightHelperShowModel = FightHelperShowModel.Grid_Show;
		ResetBreviaryHeroWrap();
		mSwitchBtnIcon.spriteName = "img_common_pailie01";
	end
end

function OnBackgroundInfoToggleChanged()
	local currentValue = mBackgroundInfoToggle.value;
	if currentValue then
		if mBackgroundInfoId ~= mSelectFightHelperId then
			SetFightHelperBackgroundInfo(mSelectFightHelperId);
			mBackgroundInfoId = mSelectFightHelperId;
		end
	end
end

function OnDetailInfoToggleChanged()
	local currentValue = mDetailInfoToggle.value;
	if currentValue then
		if mDetailInfoId ~= mSelectFightHelperId then
			SetFightHelperDetailInfo(mSelectFightHelperId);
			mDetailInfoId = mSelectFightHelperId;
		end
	end
end

function OnFightHelperItemClicked(fightHelperId)
	local backgroundToggleValue = mBackgroundInfoToggle.value;
	if backgroundToggleValue then
		if mBackgroundInfoId ~= fightHelperId then
			SetFightHelperBackgroundInfo(fightHelperId);
			UpdateSelectFlag(fightHelperId);
			mSelectFightHelperId = fightHelperId;
			mBackgroundInfoId = fightHelperId;
		end
	else
		if mDetailInfoId ~= fightHelperId then
			SetFightHelperDetailInfo(fightHelperId);
			UpdateSelectFlag(fightHelperId);
			mSelectFightHelperId = fightHelperId;
			mDetailInfoId = fightHelperId;
		end
	end
	
	
end

function SetFightHelperBackgroundInfo(fightHelperId)
	local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(fightHelperId);
	if not fightHelperBaseInfo then return; end
	
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
	
	--立绘
	mFightHelperTexLoader:LoadObject(fightHelperBaseInfo.mainTexId);
	local rootSortorder = mSelf:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
	mFightHelperTexLoader:SetSortOrder(rootSortorder);
	mFightHelperTexLoader:SetParent(mFightHelperTexture);
	mFightHelperTexLoader:SetLocalPosition(Vector3(116.15, - 191.3, 0));
	mFightHelperTexLoader:SetLocalScale(Vector3(18, 18, 1));
	mFightHelperTexLoader:SetActive(true);
end

function SetFightHelperDetailInfo(fightHelperId)
	local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(fightHelperId);
	if not fightHelperBaseInfo then return; end
	
	local fightHelpOwnState = FightHelpMgr.GetFightHelperOwnState(fightHelperId);
	local fightHelperNetInfo = FightHelpMgr.GetFightHelpInfo(fightHelperId);
	
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
	local mCurrentFragmentCount = 0;
	if fightHelpOwnState == 1 then
		currentStarLevel = fightHelperNetInfo.starLevel;
		mCurrentFragmentCount = fightHelperNetInfo.fragCount;
		local nextStarLevel = currentStarLevel == fightHelperBaseInfo.maxStarCount and currentStarLevel or currentStarLevel;
		local nextStarInfo = FightHelpMgr.GetFightHelpStarInfo(fightHelperId, currentStarLevel + 1);
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
	
	--解锁/升星按钮
	if fightHelpOwnState == 1 then
		mBtnIcon.spriteName = "icon_common_arrow06";
	else
		mBtnIcon.spriteName = "icon_common_lock2";
	end
	
	--数值
	local levelValue = UserData.GetLevel();
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
				v.locakFlagObject:SetActive(false);
				v.isActive = true;
				v.skillLevel = FightHelpMgr.GetFightHelpSkillLevel(fightHelperId, attackSkillList[k].skillId);
				v.skillLevelInfo.gameObject:SetActive(true);
				v.skillLevelLabel.text = v.skillLevel;
			else
				v.locakFlagObject:SetActive(true);
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
	--获取途径
	local getFunStr = "";
	for k, v in ipairs(fightHelperBaseInfo.getFunctionList) do
		if k == 1 then
			getFunStr = v;
		else
			getFunStr = getFunStr .. "、" .. v;
		end
	end
	mGetFunctionLabel.text = getFunStr;
end

function UpdateSelectFlag(newFightHelperId)
	if mFightHelperShowModel == FightHelperShowModel.List_Show then
		for k, v in ipairs(mHeroDetailItemPool) do
			if v.id == mSelectFightHelperId then
				v.bg.spriteName = "button_common_06";
			end
			if v.id == newFightHelperId then
				v.bg.spriteName = "button_common_07";
			end
		end
	else
		for k, v in ipairs(mHeroBreviaryItemPool) do
			if v.id == mSelectFightHelperId then
				v.selectFlag.gameObject:SetActive(false);
			end
			if v.id == newFightHelperId then
				v.selectFlag.gameObject:SetActive(true);
			end
		end
	end
end

function OnFightHelperStarUpInHandbook(info)
	if mFightHelperShowModel == FightHelperShowModel.List_Show then
		for k, v in ipairs(mHeroDetailItemPool) do
			if v.id == info.fightHelperId then
				for i = 1, #v.starList do
					if i <= info.starLevel then
						v.starList[i].starIcon.gameObject:SetActive(true);
					else
						v.starList[i].starIcon.gameObject:SetActive(false);
					end
				end
			end
		end
	end
	local currentValue = mBackgroundInfoToggle.value;
	if not currentValue then
		local toggleValue = mDetailInfoToggle.value;
		if toggleValue then
			for i = 1, #mStarPool do
				if i <= info.starLevel then
					mStarPool[i].icon.gameObject:SetActive(true);
				else
					mStarPool[i].icon.gameObject:SetActive(false);
				end
			end
			local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(info.fightHelperId);
			local nextStarLevel = info.starLevel == fightHelperBaseInfo.maxStarCount and info.starLevel or info.starLevel + 1;
			local nextStarInfo = FightHelpMgr.GetFightHelpStarInfo(info.fightHelperId, nextStarLevel);
			if nextStarInfo then
				mNextStarLevelNeeds = nextStarInfo.needItemCount;
			end
			mCurrentFragmentCount = info.fagmentCount;
			mStarLevelProgressLabel.text = mCurrentFragmentCount .. "/" .. mNextStarLevelNeeds;
			mStarLevelProgressBar.value = mCurrentFragmentCount / mNextStarLevelNeeds;
			mBtnIcon.spriteName = "icon_common_arrow06";
		end
	end
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

function UpdateFihgtHelperInfoList()
	mFightHelperInfoList = FightHelpMgr.GetFightHelperFilterList(mCurrentFilterIndex);
	if mFightHelperShowModel == FightHelperShowModel.List_Show then
		ResetDetailHeroWrap();
	else
		ResetBreviaryHeroWrap();
	end
	
	local isFind = false;
	for k, v in ipairs(mFightHelperInfoList) do
		if mSelectFightHelperId == v.id then
			isFind = true;
			break;
		end
	end
	if isFind == false then
		if next(mFightHelperInfoList) ~= nil then
			OnFightHelperItemClicked(mFightHelperInfoList[1].id);
		end
	end
end

function SelectFilterItem(filterIndex)
	if mCurrentFilterIndex == filterIndex then
		mCurrentFilterIndex = 0;
		mFilterItemList[filterIndex].bg.spriteName = "button_common_12";
	else
		if mCurrentFilterIndex ~= 0 then
			mFilterItemList[mCurrentFilterIndex].bg.spriteName = "button_common_12";
		end
		mFilterItemList[filterIndex].bg.spriteName = "button_common_13";
		mCurrentFilterIndex = filterIndex;
	end
	UpdateFihgtHelperInfoList();
end

function OnPlayerLevelUp(entity)
	if entity == nil or entity:IsSelf() then
		local levelValue = UserData.GetLevel();
		if mFightHelperShowModel == FightHelperShowModel.List_Show then
			for k, v in ipairs(mHeroDetailItemPool) do
				v.heroLevelLabel.text = levelValue .. "级";
			end
		end
		local backgroundToggleValue = mBackgroundInfoToggle.value;
		if backgroundToggleValue then
			mLevelLabel.text = levelValue .. "级";
		else
			local fightHelperBaseInfo = FightHelpData.GetFihtHelperInfoById(mSelectFightHelperId);
			local levelValue = UserData.GetLevel();
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
end
