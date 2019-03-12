module("UI_FightHelp_Config", package.seeall);
local FightHelperShowModel = {
	List_Show = 1;
	Grid_Show = 2
}

local mSelf;

local mFormationList = {};

local mHeroDetailItemPrefab;
local mHeroDetailListWrap;
local mDetailWrapCall;

local mHeroBreviaryItemPrefab;
local mHeroBreviaryListWrap;
local mBreviaryWrapCall;

local mSwitchBtnIcon;

local mHeroDetailItemPool = {};
local mHeroBreviaryItemPool = {};
local mFightHelperInfoList = {};

local mFilterItemList = {};

local FORMATION_COUNT = 3;
local FORMATION_PER_HERO_COUNT = 5;

local FILTER_COUNT = 5;

local MAX_HERO_DETAIL_WRAP_COUNT = 7;
local MAX_HERO_BREVIARY_WRAP_COUNT = 20;
local MAX_STAR_COUNT = 6;

local mIsInConfigModel = false;

local mFightHelperShowModel;

local mCurrentSelectFormationIndex = - 1;
local mSelectSlotInfo = {formationIndex = - 1, slotIndex = - 1};
local mCurrentSelectFightHelperId = - 1;
local mCurrentFilterIndex = 0;

local mCurrentActiveFormationIndex = - 1;

local FormationState = {
	None = 0,
	AddAble = 1,
	ExchangeAble = 2;
}

function OnCreate(self)
	mSelf = self;
	
	local formationBasePath = "Offset/FormationList/Formation";
	for i = 1, FORMATION_COUNT do
		local formationInfo = {};
		local formationPath = "Offset/FormationList/Formation" .. i;
		formationInfo.bg = self:FindComponent("UISprite", formationPath);
		formationInfo.nameLabel = self:FindComponent("UILabel", formationPath .. "/FormationInfo/InfoLabel");
		formationInfo.fightHelperSlotList = {};
		for k = 1, FORMATION_PER_HERO_COUNT do
			local heroItem = {};
			heroItem.id = 0;
			local heroItemPath = formationPath .. "/HeroList/HeroBg" .. k;
			heroItem.heroIcon = self:FindComponent("UITexture", heroItemPath .. "/HeroIcon");
			heroItem.heroIconLoader = LoaderMgr.CreateTextureLoader(heroItem.heroIcon);
			heroItem.heroIconObject = heroItem.heroIcon.gameObject;
			heroItem.addFlagObject = self:Find(heroItemPath .. "/AddFlag").gameObject;
			heroItem.exchangeFlag = self:FindComponent("UISprite", heroItemPath .. "/ExchangeFlag");
			heroItem.outFlag = self:FindComponent("UISprite", heroItemPath .. "/OutFlag");
			heroItem.selectFlag = self:FindComponent("UISprite", heroItemPath .. "/SelectFlag");
			heroItem.state = FormationState.None;
			formationInfo.fightHelperSlotList[k] = heroItem;
		end
		formationInfo.useFlagObject = self:Find(formationPath .. "/UseFlagBg/Sprite").gameObject;
		mFormationList[i] = formationInfo;
	end
	
	for i = 1, FILTER_COUNT do
		local filterItem = {};
		filterItem.index = i;
		local filterPath = "Offset/HeroList/FilterList/Filte0" .. i;
		filterItem.bg = self:FindComponent("UISprite", filterPath);
		table.insert(mFilterItemList, filterItem);
	end
	
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
	
	mSwitchBtnIcon = self:FindComponent("UISprite", "Offset/ModelSwitchBtn/SwitchIcon");
	mFightHelperShowModel = FightHelperShowModel.List_Show;
end

function OnEnable(self)
	SetFightHelperShowModel(mFightHelperShowModel);
	UpdateFihgtHelperInfoList();
	InitFormation();
	RegEvent(self);
end

function OnDisabel(self)
	UnRegEvent(self);
end

function RegEvent(self)
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_SETACTIVE, OnSetFightHelperActive);
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_EXCHANGE, SlotFightHelperExchange);
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_STARUP, OnFightHelperStarUp);
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_USEFORMATION, SetFormationActive);
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_FORMATIONCHANGED, UpdateFormationInfo);
	GameEvent.Reg(EVT.FIGHTHELP, EVT.FIGHTHELP_HEROSTATECHANGE, EvnUpdateFightHelperState);
	GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, OnPlayerLevelUp);
end

function UnRegEvent(self)
	GameEvent.UnReg(EVT.FIGHTHELP, EVT.FIGHTHELP_SETACTIVE, OnSetFightHelperActive);
	GameEvent.UnReg(EVT.FIGHTHELP, EVT.FIGHTHELP_EXCHANGE, SlotFightHelperExchange);
	GameEvent.UnReg(EVT.FIGHTHELP, EVT.FIGHTHELP_STARUP, OnFightHelperStarUp);
	GameEvent.UnReg(EVT.FIGHTHELP, EVT.FIGHTHELP_USEFORMATION, SetFormationActive);
	GameEvent.UnReg(EVT.FIGHTHELP, EVT.FIGHTHELP_FORMATIONCHANGED, EvnUpdateFightHelperState);
	GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, OnPlayerLevelUp);
end

function OnClick(go, id)
	if id == 1 then --助战筛选1
		SelectFilterItem(1);
	elseif id == 2 then --助战筛选2
		SelectFilterItem(2);
	elseif id == 3 then --助战筛选3
		SelectFilterItem(3);
	elseif id == 4 then --助战筛选4
		SelectFilterItem(4);
	elseif id == 5 then --助战筛选5
		SelectFilterItem(5);
	elseif id == 6 then --模式切换
		SwitchFightHelperShowModel();
	elseif id == 21 then --阵型1助战1
		SelectFormationSlot(1, 1);
	elseif id == 22 then --阵型1助战2
		SelectFormationSlot(1, 2);
	elseif id == 23 then --阵型1助战3
		SelectFormationSlot(1, 3);
	elseif id == 24 then --阵型1助战4
		SelectFormationSlot(1, 4);
	elseif id == 20 then --阵型1阵型选择
	elseif id == 25 then --启用阵型1
		OnSetFormationBtnClicked(1);
	elseif id == 26 then
		WithdrawFromFormation(1, 1);
	elseif id == 27 then
		WithdrawFromFormation(1, 2);
	elseif id == 28 then
		WithdrawFromFormation(1, 3);
	elseif id == 29 then
		WithdrawFromFormation(1, 4);
	elseif id == 31 then --阵型2助战1
		SelectFormationSlot(2, 1);
	elseif id == 32 then --阵型2助战2
		SelectFormationSlot(2, 2);
	elseif id == 33 then --阵型2助战3
		SelectFormationSlot(2, 3);
	elseif id == 34 then --阵型2助战4
		SelectFormationSlot(2, 4);
	elseif id == 30 then --阵型2阵型选择
	elseif id == 35 then --启用阵型2
		OnSetFormationBtnClicked(2);
	elseif id == 36 then
		WithdrawFromFormation(2, 1);
	elseif id == 37 then
		WithdrawFromFormation(2, 2);
	elseif id == 38 then
		WithdrawFromFormation(2, 3);
	elseif id == 39 then
		WithdrawFromFormation(2, 4);
	elseif id == 41 then --阵型3助战1
		SelectFormationSlot(3, 1);
	elseif id == 42 then --阵型3助战2
		SelectFormationSlot(3, 2);
	elseif id == 43 then --阵型3助战3
		SelectFormationSlot(3, 3);
	elseif id == 44 then --阵型3助战4
		SelectFormationSlot(3, 4);
	elseif id == 40 then --阵型3阵型选择
	elseif id == 45 then --启用阵型3
		OnSetFormationBtnClicked(3);
	elseif id == 46 then
		WithdrawFromFormation(3, 1);
	elseif id == 47 then
		WithdrawFromFormation(3, 2);
	elseif id == 48 then
		WithdrawFromFormation(3, 3);
	elseif id == 49 then
		WithdrawFromFormation(3, 4);
	elseif id >= 1000 then --助战英雄被选择了
		SelectFightHelperItem(id);
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
		heroItem.stateFlag = heroItem.transform:Find("StateFlag"):GetComponent("UISprite");
		heroItem.stateFlagObject = heroItem.stateFlag.gameObject;
		heroItem.upFlagObject = heroItem.transform:Find("HeroIconBg/UpFlag").gameObject;
		heroItem.unuseableMaskObject = heroItem.transform:Find("UnuseableMask").gameObject;
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
		heroItem.isAchieve = false;
		heroItem.isFree = false;
		heroItem.transform = heroItem.gameObject.transform;
		heroItem.heroIcon = heroItem.transform:Find("HeroIcon"):GetComponent("UITexture");
		heroItem.heroIconLoader = LoaderMgr.CreateTextureLoader(heroItem.heroIcon);
		heroItem.freeFlagObject = heroItem.transform:Find("FreeFlag").gameObject;
		heroItem.upFlagObject = heroItem.transform:Find("UpFlag").gameObject;
		heroItem.unuseableMaskObject = heroItem.transform:Find("UnuseableMask").gameObject;
		heroItem.selectFlag = heroItem.transform:Find("SelectFlag"):GetComponent("UISprite");
		heroItem.stateFlag = heroItem.transform:Find("StateFlag"):GetComponent("UISprite");
		heroItem.stateFlagObject = heroItem.stateFlag.gameObject;
		heroItem.qualityLabel = heroItem.transform:Find("HeroLevelBg/LevelLabel"):GetComponent("UILabel");
		heroItem.uiEvent = heroItem.transform:GetComponent("UIEvent");
		heroItem.eventId = 0;
		table.insert(mHeroBreviaryItemPool, heroItem);
	end
end

function ResetDetailHeroWrap()
	mHeroDetailListWrap:ResetWrapContent(#mFightHelperInfoList, mDetailWrapCall);
end

function ResetBreviaryHeroWrap()
	mHeroBreviaryListWrap:ResetWrapContent(#mFightHelperInfoList, mBreviaryWrapCall);
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
	
	--拥有标志
	if fightHelpOwnInfo.ownState == 1 then
		fightHelperItem.unuseableMaskObject:SetActive(false);
		fightHelperItem.freeFlagObject:SetActive(false);
		fightHelperItem.isAchieve = true;
	elseif fightHelpOwnInfo.ownState == 2 then
		fightHelperItem.unuseableMaskObject:SetActive(false);
		fightHelperItem.freeFlagObject:SetActive(true);
		fightHelperItem.isAchieve = true;
	else
		fightHelperItem.unuseableMaskObject:SetActive(true);
		fightHelperItem.freeFlagObject:SetActive(false);
		fightHelperItem.isAchieve = false;
	end
	
	if fightHelperItem.isAchieve == true then
		local currentState = fightHelperNetInfo.state;
		if currentState == CombatElf_pb.CES_WORK then
			fightHelperItem.stateFlagObject:SetActive(true);
			fightHelperItem.stateFlag.spriteName = "icon_common_zhan";
		elseif currentState == CombatElf_pb.CES_TOUR then
			fightHelperItem.stateFlagObject:SetActive(true);
			fightHelperItem.stateFlag.spriteName = "icon_common_you";
		else
			fightHelperItem.stateFlagObject:SetActive(false);
		end
	else
		fightHelperItem.stateFlagObject:SetActive(false);
	end
	
	if mIsInConfigModel then
		if fightHelperItem.isAchieve == true and not GetIsInUseInCurrentFormation(fightHelperInfo.id) then
			fightHelperItem.upFlagObject:SetActive(true);
		else
			fightHelperItem.upFlagObject:SetActive(false);
		end
	else
		fightHelperItem.upFlagObject:SetActive(false);
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
	
	--如果不在三大列表中则为nil
	local fightHelperNetInfo = FightHelpMgr.GetFightHelpInfo(fightHelpOwnInfo.id);
	
	--状态标注
	fightHelperItem.id = fightHelperInfo.id;
	fightHelperItem.gameObject.name = #mFightHelperInfoList - heroInfoIndex;
	fightHelperItem.uiEvent.id = fightHelperInfo.id;
	fightHelperItem.heroIconLoader:LoadObject(fightHelperInfo.icon);
	
	if fightHelpOwnInfo.ownState == 1 or fightHelpOwnInfo.ownState == 2 then
		fightHelperItem.unuseableMaskObject:SetActive(false);
		fightHelperItem.isAchieve = true;
		
		fightHelperItem.stateFlagObject:SetActive(true);
		fightHelperItem.state = fightHelperNetInfo.state;
		if fightHelperNetInfo.state == CombatElf_pb.CES_FREE then
			fightHelperItem.stateFlagObject:SetActive(false);
		elseif fightHelperNetInfo.state == CombatElf_pb.CES_WORK then
			fightHelperItem.stateFlag.spriteName = "icon_common_zhan";
		elseif fightHelperNetInfo.state == CombatElf_pb.CES_TOUR then
			fightHelperItem.stateFlag.spriteName = "icon_common_you";
		end
	else
		fightHelperItem.unuseableMaskObject:SetActive(true);
		fightHelperItem.isAchieve = false;
		
		fightHelperItem.state = CombatElf_pb.CES_NONE;
		fightHelperItem.stateFlagObject:SetActive(false);
	end
	
	fightHelperItem.selectFlag.gameObject:SetActive(false);
	
	if fightHelpOwnInfo.ownState == 2 then
		fightHelperItem.freeFlagObject:SetActive(true);
	else
		fightHelperItem.freeFlagObject:SetActive(false);
	end
	
	--[[	if FightHelpMgr.GetFightHelperIsFree(fightHelperInfo.id) then
		fightHelperItem.freeFlag.gameObject:SetActive(true);
		--还要隐藏碎片收集进度
	else
		fightHelperItem.freeFlag.gameObject:SetActive(false);
		if fightHelpOwnInfo.ownState == 3 then
			--设置并显示收集进度
		end
	end
	]]
	if mIsInConfigModel then
		if fightHelperItem.isAchieve == true and not GetIsInUseInCurrentFormation(fightHelperInfo.id) then
			fightHelperItem.upFlagObject:SetActive(true);
		else
			fightHelperItem.upFlagObject:SetActive(false);
		end
	else
		fightHelperItem.upFlagObject:SetActive(false);
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

function InitFormation()
	for k, v in ipairs(mFormationList) do
		local isFindAddable = false;
		for r, n in ipairs(v.fightHelperSlotList) do
			n.id = - 1;
			n.outFlag.gameObject:SetActive(false);
			n.exchangeFlag.gameObject:SetActive(false);
			n.addFlagObject:SetActive(false);
			n.heroIconObject:SetActive(false);
			n.selectFlag.gameObject:SetActive(false);
			local formationMembers = FightHelpMgr.GetFormationMember(k);
			if formationMembers then
				if formationMembers[r] == - 1 then
					--无助战
					n.id = - 1;
					n.heroIconObject:SetActive(false);
				elseif formationMembers[r] == 0 then
					--玩家位置
					n.id = 0;
					n.heroIconObject:SetActive(true);
					n.heroIconLoader:LoadObject(UserData.PlayerAtt.playerData.headIcon);
				else
					--有助战，显示头像
					n.id = formationMembers[r];
					n.heroIconObject:SetActive(true);
					local fightHelperInfo = FightHelpData.GetFihtHelperInfoById(n.id);
					n.heroIconLoader:LoadObject(fightHelperInfo.icon);
				end
			end
		end
		ResetFormationSlotState(k);
	end
	SetFormationActive(FightHelpMgr.GetCurrentFormationIndex());
end

function SelectFormationSlot(formationIndex, slotIndex)
	local formationItem = mFormationList[formationIndex];
	if not formationItem then return; end
	local slotItem = formationItem.fightHelperSlotList[slotIndex];
	if not slotItem then return; end
	
	if slotItem.state == FormationState.ExchangeAble then
		--交换
		FightHelpMgr.RequireFightHelperExchange(mSelectSlotInfo.formationIndex, mSelectSlotInfo.slotIndex, slotIndex);
		--重置选择状态
		ResetView();
		return;
	end
	
	if mSelectSlotInfo.formationIndex == formationIndex then
		if mSelectSlotInfo.slotIndex == slotIndex then
			--选择了相同的槽位
			SwitchConfigModel(false);
			ResetFormationSlotState(formationIndex);
			UpdateFormationSlotSelectFlag(formationIndex, slotIndex);
			return;
		end
	end
	
	if slotItem.state == FormationState.AddAble then
		ResetFormationSlotState(formationIndex);
		if formationIndex ~= mSelectSlotInfo.formationIndex then
			ResetFormationSlotState(mSelectSlotInfo.formationIndex)
		end
		
		UpdateFormationSlotSelectFlag(formationIndex, slotIndex);
		SwitchConfigModel(true);
	elseif slotItem.state == FormationState.None and slotItem.id ~= - 1 then
		slotItem.state = FormationState.None;		
		slotItem.exchangeFlag.gameObject:SetActive(false);
		--玩家没有下阵操作，助战才有
		if slotItem.id == 0 then
			slotItem.outFlag.gameObject:SetActive(false);
		else
			slotItem.outFlag.gameObject:SetActive(true);
		end
		--重置上个阵型中所有槽位
		if formationIndex ~= mSelectSlotInfo.formationIndex then
			ResetFormationSlotState(mSelectSlotInfo.formationIndex)
		end
		--更新同阵型其他槽位状态
		for k, v in ipairs(formationItem.fightHelperSlotList) do
			if v.id ~= slotItem.id then
				v.state = FormationState.ExchangeAble;
				v.exchangeFlag.gameObject:SetActive(true);
			end
		end
		
		UpdateFormationSlotSelectFlag(formationIndex, slotIndex);
		--在不选择玩家时左侧助战列表进入配置状态，因为玩家不能被助战替换
		if slotItem.id ~= 0 then
			SwitchConfigModel(true);
		end
		
		if formationIndex ~= mSelectSlotInfo.formationIndex then
			ResetFormationSlotState(mSelectSlotInfo.formationIndex)
		end
	end
end

function ResetFormationSlotState(formationIndex)
	local formationItem = mFormationList[formationIndex];
	if not formationItem then return; end
	for k, v in ipairs(formationItem.fightHelperSlotList) do
		v.outFlag.gameObject:SetActive(false);
		if v.id == - 1 then	
			v.state = FormationState.AddAble;
			v.addFlagObject:SetActive(true);
			v.exchangeFlag.gameObject:SetActive(false);
		else
			v.state = FormationState.None;
			v.exchangeFlag.gameObject:SetActive(false);
			v.addFlagObject:SetActive(false);
		end
	end
end

function UpdateFormationSlotSelectFlag(formationIndex, slotIndex)
	if mFormationList[mSelectSlotInfo.formationIndex] and mFormationList[mSelectSlotInfo.formationIndex].fightHelperSlotList[mSelectSlotInfo.slotIndex] then
		mFormationList[mSelectSlotInfo.formationIndex].fightHelperSlotList[mSelectSlotInfo.slotIndex].selectFlag.gameObject:SetActive(false);
	end
	if mSelectSlotInfo.formationIndex == formationIndex and mSelectSlotInfo.slotIndex == slotIndex then
		mSelectSlotInfo.formationIndex = - 1;
		mSelectSlotInfo.slotIndex = - 1;
	else
		if mFormationList[formationIndex] and mFormationList[formationIndex].fightHelperSlotList[slotIndex] then
			mFormationList[formationIndex].fightHelperSlotList[slotIndex].selectFlag.gameObject:SetActive(true);
			mSelectSlotInfo.formationIndex = formationIndex;
			mSelectSlotInfo.slotIndex = slotIndex;
		end
	end
end

function ClearFormationSlotSelectFlag()
	if mFormationList[mSelectSlotInfo.formationIndex] and mFormationList[mSelectSlotInfo.formationIndex].fightHelperSlotList[mSelectSlotInfo.slotIndex] then
		mFormationList[mSelectSlotInfo.formationIndex].fightHelperSlotList[mSelectSlotInfo.slotIndex].selectFlag.gameObject:SetActive(false);
	end
	
	mSelectSlotInfo.formationIndex = - 1;
	mSelectSlotInfo.slotIndex = - 1;
end

function SwitchConfigModel(value)
	--if mIsInConfigModel == value then return; end
	local heroDetailItemPool = {};
	if mFightHelperShowModel == FightHelperShowModel.List_Show then
		heroDetailItemPool = mHeroDetailItemPool;
	else
		heroDetailItemPool = mHeroBreviaryItemPool;
	end
	for k, v in ipairs(heroDetailItemPool) do
		if v.isAchieve then
			if value then
				if not GetIsInUseInCurrentFormation(v.id) then
					v.upFlagObject:SetActive(true);
				else
					v.upFlagObject:SetActive(false);
				end
			else
				v.upFlagObject:SetActive(false);
			end
		else
			v.upFlagObject:SetActive(false);
		end
	end
	mIsInConfigModel = value;
end

function GetIsInUseInCurrentFormation(fightHelperId)
	local currentFormationIndex = mSelectSlotInfo.formationIndex;
	for k, v in ipairs(mFormationList[currentFormationIndex].fightHelperSlotList) do
		if v.id == fightHelperId then
			return true;
		end
	end
	return false;
end

function SelectFightHelperItem(fightHelperId)
	if mIsInConfigModel then
		--local fightHelperState = CES_NONE;
		local heroDetailItemPool = {};
		if mFightHelperShowModel == FightHelperShowModel.List_Show then
			heroDetailItemPool = mHeroDetailItemPool;
		else
			heroDetailItemPool = mHeroBreviaryItemPool;
		end
		local ownState = FightHelpMgr.GetFightHelperOwnState(fightHelperId);
		if ownState == 1 or ownState == 2 then
			if not GetIsInUseInCurrentFormation(fightHelperId) then
				--处于闲置状态，向服务器发送请求
				FightHelpMgr.RequireFightHelperActive(fightHelperId, mSelectSlotInfo.formationIndex, mSelectSlotInfo.slotIndex, true);
				--测试代码（客户端接受服务器数据）
				--[[				local testMsg = {};
				testMsg.ret = 0;
				testMsg.combatElfID = fightHelperId;
				testMsg.tacticGroupID = mSelectSlotInfo.formationIndex - 1;
				testMsg.tacticGroupIdx = mSelectSlotInfo.slotIndex - 1;
				testMsg.combatElfState = CombatElf_pb.CES_WORK;
				FightHelpMgr.OnFightHelperActive(testMsg);
				]]
				ResetView();
				--elseif fightHelperState == CombatElf_pb.CES_WORK then
				--处于上阵状态
				--elseif fightHelperState == CombatElf_pb.CES_TOUR then
				--处于游历状态
			end
		else
			TipsMgr.TipByKey("FightHelp_Hero_DonNotHave");
		end
	else
		--显示助战详情
		UIMgr.ShowUI(AllUI.UI_FightHelp_Info, mSelf, nil, nil, nil, true, mFightHelperInfoList, fightHelperId);
	end
	
end

function OnSetFightHelperActive(fightHelperId, formationIndex, slotIndex, isActive)
	if mFormationList[formationIndex] and mFormationList[formationIndex].fightHelperSlotList[slotIndex] then
		local slotItem = mFormationList[formationIndex].fightHelperSlotList[slotIndex];
		slotItem.heroIconObject:SetActive(isActive);
		slotItem.addFlagObject:SetActive(not isActive);
		if isActive then
			slotItem.id = fightHelperId;
			--设置头像信息
			local fightHelperInfo = FightHelpData.GetFihtHelperInfoById(fightHelperId);
			slotItem.heroIconLoader:LoadObject(fightHelperInfo.icon);
		else
			slotItem.id = 0;
			slotItem.heroIconObject:SetActive(false);
		end
	end
	local heroDetailItemPool = {};
	if mFightHelperShowModel == FightHelperShowModel.List_Show then
		heroDetailItemPool = mHeroDetailItemPool;
	else
		heroDetailItemPool = mHeroBreviaryItemPool;
	end
	if FightHelpMgr.GetCurrentFormationIndex() == formationIndex then
		for k, v in ipairs(heroDetailItemPool) do
			if v.id == fightHelperId then
				if isActive then
					v.stateFlag.spriteName = "icon_common_zhan";
					v.stateFlagObject:SetActive(true);
					v.state = CombatElf_pb.CES_WORK;
				else
					v.stateFlagObject:SetActive(false);
					v.state = CombatElf_pb.CES_FREE;
				end
			end
		end
	end
end

function SlotFightHelperExchange(formationIndex, srcSlotIndex, srcFightHelperId, dstSlotIndex, dstFihgtHelperId)
	if mFormationList[formationIndex] and mFormationList[formationIndex].fightHelperSlotList[srcSlotIndex] and mFormationList[formationIndex].fightHelperSlotList[dstSlotIndex] then
		local srcSlotItem = mFormationList[formationIndex].fightHelperSlotList[srcSlotIndex];
		local dstSlotItem = mFormationList[formationIndex].fightHelperSlotList[dstSlotIndex];
		--分别根据id设置两个槽位的头像
		local srcFightHelperInfo = FightHelpData.GetFihtHelperInfoById(srcFightHelperId);
		srcSlotItem.id = srcFightHelperId;
		srcSlotItem.heroIconLoader:LoadObject(srcFightHelperInfo.icon);
		local dstFightHelperInfo = FightHelpData.GetFihtHelperInfoById(dstFihgtHelperId);
		dstSlotItem.id = dstFihgtHelperId;
		dstSlotItem.heroIconLoader:LoadObject(dstFightHelperInfo.icon);
	end
end

function ResetView()
	ResetFormationSlotState(mSelectSlotInfo.formationIndex);
	ClearFormationSlotSelectFlag();
	SwitchConfigModel(false);
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
		mDetailWrapCall = UIWrapContent.OnInitializeItem(OnUpdateDetailItem);
		--InitHeroDetailItemPool();
		ResetDetailHeroWrap();
		mSwitchBtnIcon.spriteName = "img_common_pailie02";
	else
		mHeroDetailListWrap.gameObject:SetActive(false);
		mHeroBreviaryListWrap.gameObject:SetActive(true);
		mFightHelperShowModel = FightHelperShowModel.Grid_Show;
		mBreviaryWrapCall = UIWrapContent.OnInitializeItem(OnUpdateBreviaryItem);
		--InitHeroBreviaryItemPool();
		ResetBreviaryHeroWrap();
		mSwitchBtnIcon.spriteName = "img_common_pailie01";
	end
end

function OnFightHelperStarUp(info)
	UpdateFihgtHelperInfoList();
end

function SetFormationActive(formationIndex)
	local lastFormationItem = mFormationList[mCurrentSelectFormationIndex];
	if lastFormationItem then
		lastFormationItem.bg.spriteName = "button_common_12";
		lastFormationItem.useFlagObject:SetActive(false);
	end
	
	local currentFormationItem = mFormationList[formationIndex];
	local formationFightHelperList = FightHelpMgr.GetFormationInfoByIndex(formationIndex);
	if not formationFightHelperList then
		formationFightHelperList = {};
	end
	local fightHelperItemPool = {};
	if mFightHelperShowModel == FightHelperShowModel.List_Show then
		fightHelperItemPool = mHeroDetailItemPool;
	else
		fightHelperItemPool = mHeroBreviaryItemPool;
	end
	if currentFormationItem then
		for k, v in ipairs(fightHelperItemPool) do
			local isFind = false;
			for r, m in ipairs(formationFightHelperList) do
				if v.id == m then
					isFind = true;
					v.state = CombatElf_pb.CES_WORK;
					v.stateFlag.spriteName = "icon_common_zhan";
					v.stateFlagObject:SetActive(true);
				end
			end
			if not isFind then
				v.stateFlagObject:SetActive(false);
				v.state = CombatElf_pb.CES_FREE;
			end
		end
		
		currentFormationItem.bg.spriteName = "button_common_13";
		currentFormationItem.useFlagObject:SetActive(true);
	end
	mCurrentSelectFormationIndex = formationIndex;
end

function OnSetFormationBtnClicked(formationIndex)
	if mIsInConfigModel == true then
		SwitchConfigModel(false);
		ResetFormationSlotState(mSelectSlotInfo.formationIndex);
		UpdateFormationSlotSelectFlag(mSelectSlotInfo.formationIndex, mSelectSlotInfo.slotIndex);
	end
	FightHelpMgr.SetActiveFormation(formationIndex);
end

function WithdrawFromFormation(formationIndex, slotIndex)
	local formationItemId = mFormationList[formationIndex].fightHelperSlotList[slotIndex].id;
	FightHelpMgr.RequireFightHelperActive(formationItemId, formationIndex, slotIndex, false);
	ResetView();
end

function UpdateFormationInfo(formationIndex)
	local formationInfo = FightHelpMgr.GetFormationInfoByIndex(formationIndex);
	local formationItem = mFormationList[formationIndex];
	if formationItem then
		if formationInfo.state == CombatElf_pb.FPS_WORK then
			if mCurrentSelectFormationIndex ~= formationIndex then
				SetFormationActive(formationIndex);
			end
		end
		local slotList = formationItem.fightHelperSlotList;
		for k, v in ipairs(slotList) do
			local heroId = formationInfo.fightHelperList[k];
			v.id = heroId;
			if heroId == - 1 then
				v.heroIconObject:SetActive(false);
				v.addFlagObject:SetActive(true);
				v.state = FormationState.AddAble;
			elseif heroId == 0 then
				v.heroIconObject:SetActive(true);
				v.addFlagObject:SetActive(false);
				v.heroIconLoader:LoadObject(UserData.PlayerAtt.playerData.headIcon);
				v.state = FormationState.None;
			else
				v.heroIconObject:SetActive(true);
				v.addFlagObject:SetActive(false);
				local fightHelperInfo = FightHelpData.GetFihtHelperInfoById(heroId);
				v.heroIconLoader:LoadObject(fightHelperInfo.icon);
				v.state = FormationState.None;
			end
		end
	end
end

function EvnUpdateFightHelperState(fightHelperId, state)
	local fightHelperItemPool = {};
	if mFightHelperShowModel == FightHelperShowModel.List_Show then
		fightHelperItemPool = mHeroDetailItemPool;
	else
		fightHelperItemPool = mHeroBreviaryItemPool;
	end
	
	for k, v in ipairs(fightHelperItemPool) do
		if fightHelperId == v.id then
			v.state = state;
			if state == CombatElf_pb.CES_WORK then
				v.stateFlag.spriteName = "icon_common_zhan";
				v.stateFlagObject:SetActive(true);
			elseif state == CombatElf_pb.CES_FREE then
				v.stateFlagObject:SetActive(false);
			end
			break;
		end
	end
end

function UpdateFihgtHelperInfoList()
	mFightHelperInfoList = FightHelpMgr.GetFightHelperFilterList(mCurrentFilterIndex);
	if mFightHelperShowModel == FightHelperShowModel.List_Show then
		ResetDetailHeroWrap();
	else
		ResetBreviaryHeroWrap();
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
	end
end
