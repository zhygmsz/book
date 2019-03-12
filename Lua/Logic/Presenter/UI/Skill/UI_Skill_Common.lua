module("UI_Skill_Common", package.seeall);

local mSelf;
local mSkillFilterTable;
local mSkillFilterPrefab;

local mSkillGroupScrollView;
local mSkillGroupWrap;
local mSkillGroupWrapCall;

local mSkillItemPrefab;

local mSkillIconTexture;
local mSkillIconLoader;
local mSkillNameLabel;
local mSkillStarList = {};

local mSkillLabelLabel;
local mSKillDescriptionLabel;

local mSkillReleaseNeedLabel;
local mSkillCDLabel;

local mSkillLevelUpInfoObject;
local mSkillLevelUpEffect;
local mSkillLevelUpConsumeTable;
local mSkillLevelUpItemConsumeInfoObject;
local mSkillLevelUpItemConsumeIcon;
local mSkillLevelUpItemConsumeCountLabel;
local mSkillLevelUpCoinConsumeInfoObject;
local mSkillLevelUpCoinConsumeCountLabel;
local mSkillLevelUpCoinOwnCountLabel;
local mSkillLevelUpBookConsumeIcon;
local mSkillLevelUpBookConsumeCountLabel;
local mSkillLevelUpFragConsumeIcon;
local mSkillLevelUpFragConsumeCountLabel;
local mSkillLevelUpBtnLabel;

local mLevelUpBookToggle;
local mLevelUpFragmentToggle;

local mSkillLevelStudyInfoObject;
local mSkillStudyConsumeInfo = {};
local mSkillStudyConsumeIcon;
local mSkillStudyComsumeCountLabel;

local mSkillTipLabelObject;

local mWrapUIs = {};

local mSkillFilterPool = {};
local mCurrentSkillFilter;

local mSkillGroupPool = {};
local mFilterdSkillGroupInfoList = {};

local mCurrentSelectSkillId = - 1;

local mStudyNeedItemInfo = {};
local mLevelUpNeedItemInfo = {};
local mLevelUpNeedSkillBookInfo = {};
local mLevelUpNeedFragmentInfo = {};

local MAX_STAR_COUNT = 5;
local SKILL_GROUP_COUNT = 3;
local SKILL_COUNT_PER_GROUP = 8;

function GetUISize(data)
	if #data._skillList > 4 then
		return 414;
	else
		return 239;
	end
end

function OnCreate(self)
	mSelf = self;
	
	--过滤标签
	mSkillFilterTable = self:FindComponent("UITable", "Offset/Left/ChoiceTabList/FilterList/FilterScrollView/Table");
	mSkillFilterPrefab = self:Find("Offset/Left/ChoiceTabList/FilterList/FilterPrefab").transform;
	mSkillFilterPrefab.gameObject:SetActive(false);
	
	--技能组wrap部分
	mSkillGroupScrollView = self:FindComponent("UIScrollView", "Offset/Left/CommonSkillList/ScrollView");
	local CommonSkillGroupItem = require("Logic/Presenter/UI/Skill/WrapUI/CommonSkillGroupItem");
	mWrapUIs = {CommonSkillGroupItem};
	mSkillGroupWrap = UICommonCollapseTableWrap.new(self, "Offset/Left/CommonSkillList/ScrollView", 4, mWrapUIs, 10000, 20, UI_Skill_Common);
	mSkillGroupWrap:RegisterData("CommonSkillData", "CommonSkillGroupItem", GetUISize);
	
	--技能详情
	mSkillIconTexture = self:FindComponent("UITexture", "Offset/Right/SkillBaseInfo/IconBg/Icon");
	mSkillIconLoader = LoaderMgr.CreateTextureLoader(mSkillIconTexture);
	mSkillNameLabel = self:FindComponent("UILabel", "Offset/Right/SkillBaseInfo/NameLabel");
	local rootSortorder = mSelf:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
	local starBasePath = "Offset/Right/SkillBaseInfo/Stars/Star0"
	for i = 1, MAX_STAR_COUNT do
		local starItem = {};
		starItem.starBg = self:FindComponent("UISprite", starBasePath .. i);
		starItem.starIcon = self:FindComponent("UISprite", starBasePath .. i .. "/Sprite");
		--升星特效
		starItem.levelUpEffect = LoaderMgr.CreateEffectLoader();
		starItem.levelUpEffect:LoadObject(ResConfigData.GetResConfigID("UI_skill_eff03"));
		starItem.levelUpEffect:SetParent(starItem.starIcon.transform);
		starItem.levelUpEffect:SetLocalPosition(Vector3.zero);
		starItem.levelUpEffect:SetLocalScale(Vector3.one);
		starItem.levelUpEffect:SetSortOrder(rootSortorder);
		table.insert(mSkillStarList, starItem);
	end
	mSkillLabelLabel = self:FindComponent("UILabel", "Offset/Right/SkillBaseInfo/SkillLabel/Label");
	mSKillDescriptionLabel = self:FindComponent("UILabel", "Offset/Right/SkillDetailInfo/DesTab/DesLabel");
	mSkillReleaseNeedLabel = self:FindComponent("UILabel", "Offset/Right/SkillDetailInfo/Consume/ConsumeLabel");
	mSkillCDLabel = self:FindComponent("UILabel", "Offset/Right/SkillDetailInfo/CD/CDLabel");
	
	--技能升级
	mSkillLevelUpInfoObject = self:Find("Offset/Right/SkillLevelUpInfo").gameObject;
	mSkillLevelUpEffect = self:FindComponent("UILabel", "Offset/Right/SkillLevelUpInfo/LevelUpEffect/LevelUpEffectLabel");
	mSkillLevelUpConsumeTable = self:FindComponent("UITable", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable");
	mSkillLevelUpItemConsumeInfoObject = self:Find("Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/01-SeniorNeed").gameObject;
	mSkillLevelUpItemConsumeIcon = self:FindComponent("UISprite", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/01-SeniorNeed/NeedItem/Icon");
	mSkillLevelUpItemConsumeCountLabel = self:FindComponent("UILabel", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/01-SeniorNeed/NeedItem/Count");
	mSkillLevelUpCoinConsumeInfoObject = self:Find("Offset/Right/SkillLevelUpInfo/CoinNeed").gameObject;
	mSkillLevelUpCoinConsumeCountLabel = self:FindComponent("UILabel", "Offset/Right/SkillLevelUpInfo/CoinNeed/NeedTab/CoountTab");
	mSkillLevelUpCoinOwnCountLabel = self:FindComponent("UILabel", "Offset/Right/SkillLevelUpInfo/CoinNeed/HaveTab/CoountTab");
	mSkillLevelUpBookConsumeIcon = self:FindComponent("UISprite", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/02-OptionalNeedItem/SkillBookLevelUp/NeedItem/Icon");
	mSkillLevelUpBookConsumeCountLabel = self:FindComponent("UILabel", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/02-OptionalNeedItem/SkillBookLevelUp/NeedItem/Count");
	mSkillLevelUpFragConsumeIcon = self:FindComponent("UISprite", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/02-OptionalNeedItem/FragmentLevelUp/NeedItem/Icon");
	mSkillLevelUpFragConsumeCountLabel = self:FindComponent("UILabel", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/02-OptionalNeedItem/FragmentLevelUp/NeedItem/Count");
	mSkillLevelUpBtnLabel = self:FindComponent("UILabel", "Offset/Right/SkillLevelUpInfo/LevelUpBtn/Label");

	mLevelUpBookToggle = self:FindComponent("UIToggle", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/02-OptionalNeedItem/SkillBookLevelUp/tog1");
	mLevelUpFragmentToggle = self:FindComponent("UIToggle", "Offset/Right/SkillLevelUpInfo/LevelUpConsumeTable/02-OptionalNeedItem/FragmentLevelUp/tog2");
	local call = EventDelegate.Callback(OnLevelUpConsumeOptionToggle);
	EventDelegate.Add(mLevelUpBookToggle.onChange, call);
	EventDelegate.Add(mLevelUpFragmentToggle.onChange, call);
	
	mSkillLevelStudyInfoObject = self:Find("Offset/Right/Study").gameObject;
	mSkillStudyConsumeIcon = self:FindComponent("UISprite", "Offset/Right/Study/NeedItem/Sprite");
	mSkillStudyComsumeCountLabel = self:FindComponent("UILabel", "Offset/Right/Study/NeedItem/Label");
	
	--最高等级提示信息
	mSkillTipLabelObject = self:Find("Offset/Right/TipInfoLabel").gameObject;
	
	InitSkillFilterList();
end

function OnEnable(self)
	RegEvent(self);
	--更新江湖技能排序
	SkillMgr.UpdateSortedCommonSkillList();
	--重置选择“全部”标签
	mFilterdSkillGroupInfoList = SkillMgr.GetFilterSkillList(WordData.GetWordStringByKey("skill_filter_all"));
	mSkillGroupWrap:ResetAll(mFilterdSkillGroupInfoList);
end

function OnDisable(self)
	UnRegEvent(self);
	mStudyNeedItemInfo.itemId = - 1;
	mLevelUpNeedItemInfo.itemId = - 1;
	mLevelUpNeedSkillBookInfo.itemId = - 1;
	mLevelUpNeedFragmentInfo.itemId = - 1;
	mCurrentSelectSkillId = - 1;
end

function RegEvent(self)
	GameEvent.Reg(EVT.SKILL, EVT.Common_SKILL_EQUIPED, OnSetCommonSkillIsEquipe);
	GameEvent.Reg(EVT.SKILL, EVT.Common_SKILL_STUDY, OnCommonSkillStarChanged);
	GameEvent.Reg(EVT.SKILL, EVT.Common_SKILL_LEVEL_UP, OnCommonSkillStarChanged);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_GETCOIN, UpdateMoney);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_BAG_NORMALITEMCHANGE, OnItemChange);
end

function UnRegEvent(self)
	GameEvent.UnReg(EVT.SKILL, EVT.Common_SKILL_EQUIPED, OnSetCommonSkillIsEquipe);
	GameEvent.UnReg(EVT.SKILL, EVT.Common_SKILL_STUDY, OnCommonSkillStarChanged);
	GameEvent.UnReg(EVT.SKILL, EVT.Common_SKILL_LEVEL_UP, OnCommonSkillStarChanged);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_GETCOIN, UpdateMoney);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_BAG_NORMALITEMCHANGE, OnItemChange);
end

function OnClick(go, id)
	if id >= 10000 then --点击技能
		mSkillGroupWrap:OnClick(id);
	elseif id > 100 and id < 200 then --点击筛选标签
		ResetSkillList(id - 100); 
	elseif id == 1 then --技能学习
		SkillMgr.RequestCommonSkillStudy(mCurrentSelectSkillId);
	elseif id == 2 then --升级
		if mLevelUpBookToggle.value then
			SkillMgr.RequestCommonSkillLevelUp(NetCS_pb.CSOrgSkillLiftStar.Op_JNS, mCurrentSelectSkillId);
		else
			SkillMgr.RequestCommonSkillLevelUp(NetCS_pb.CSOrgSkillLiftStar.Op_SPS, mCurrentSelectSkillId);
		end
	elseif id == 4 then --技能学习所需物品
		BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, mStudyNeedItemInfo.itemId);
	elseif id == 5 then --升级技能所需物品
		BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, mLevelUpNeedItemInfo.itemId);
	elseif id == 6 then --技能书物品
		BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, mLevelUpNeedSkillBookInfo.itemId);
	elseif id == 7 then	--技能书碎片物品
		BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, mLevelUpNeedFragmentInfo.itemId);
	end
end

function InitSkillFilterList()
	local filterList = SkillMgr.GetCommonSkillLabelList();
	for i = 1, #filterList + 1 do
		local filterItem = {};
		local filterContent = "";
		if i == 1 then
			filterContent = WordData.GetWordStringByKey("skill_filter_all");
		else
			filterContent = filterList[i - 1];
		end
		filterItem.gameObject = mSelf:DuplicateAndAdd(mSkillFilterPrefab, mSkillFilterTable.transform, i).gameObject;
		filterItem.gameObject:SetActive(true);
		filterItem.transform = filterItem.gameObject.transform;
		filterItem.filter = filterContent;
		filterItem.normalFilterLabel = filterItem.transform:Find("Normal/Label"):GetComponent("UILabel");
		filterItem.normalFilterLabel.text = filterContent;
		filterItem.heightLightFilterLabel = filterItem.transform:Find("HightLight/Label"):GetComponent("UILabel");
		filterItem.heightLightFilterLabel.text = filterContent;
		filterItem.toggle = filterItem.transform:GetComponent("UIToggle");
		filterItem.uiEvent = filterItem.transform:GetComponent("UIEvent");
		filterItem.uiEvent.id = 100 + i;
		if i == 1 then
			filterItem.toggle.value = true;
		else
			filterItem.toggle.value = false;
		end
		table.insert(mSkillFilterPool, filterItem);
	end
end

function InitSkillGroupPool()
	for i = 1, SKILL_GROUP_COUNT do
		local skillGroupItem = {};
		skillGroupItem.gameObject = mSelf:DuplicateAndAdd(mSkillSourceGroupPrefab, mSkillGroupWrap.transform, i).gameObject;
		skillGroupItem.gameObject:SetActive(true);
		skillGroupItem.transform = skillGroupItem.gameObject.transform;
		skillGroupItem.id = - 1;
		skillGroupItem.bg = skillGroupItem.transform:Find("Bg/Bg_Main"):GetComponent("UISprite");
		skillGroupItem.grid = skillGroupItem.transform:Find("Grid"):GetComponent("UIGrid");
		skillGroupItem.title = skillGroupItem.transform:Find("Bg/Bg_Head/TitleLabel"):GetComponent("UILabel");
		skillGroupItem.title.text = "";
		skillGroupItem.skillList = {};
		for r = 1, SKILL_COUNT_PER_GROUP do
			local skillItem = {};
			skillItem.gameObject = mSelf:DuplicateAndAdd(mSkillItemPrefab, skillGroupItem.grid.transform, r).gameObject;
			skillItem.transform = skillItem.gameObject.transform;
			skillItem.id = - 1;
			skillItem.nameLabel = skillItem.transform:Find("NameLabel"):GetComponent("UILabel");
			skillItem.starList = {};
			local starCommonPath = "StarList/Start0";
			for n = 1, MAX_STAR_COUNT do
				local starItem = skillItem.transform:Find(starCommonPath .. n):GetComponent("UISprite");
				table.insert(skillItem.starList, starItem);
			end
			skillItem.equipedFlag = skillItem.transform:Find("EquipFlag"):GetComponent("UISprite");
			skillItem.upFlag = skillItem.transform:Find("UpFlag"):GetComponent("UISprite");
			skillItem.equipBtn = skillItem.transform:Find("EquipBtn"):GetComponent("UISprite");
			table.insert(skillGroupItem.skillList, skillItem);
		end
		table.insert(mSkillGroupPool, skillGroupItem);
	end
end

function ResetSkillList(filterIndex)
	local filterContent = mSkillFilterPool[filterIndex];
	if filterContent == nil then return; end
	mFilterdSkillGroupInfoList = SkillMgr.GetFilterSkillList(filterContent.filter);
	ResetWrapContent();
end

function ResetWrapContent()
	mSkillGroupWrap:ResetAll(mFilterdSkillGroupInfoList);
end

function OnUpdateItemGroup(go, index, realIndex)
	if realIndex >= 0 and realIndex < #mFilterdSkillGroupInfoList then
		go:SetActive(true);
		SetSkillGroupItemInfo(index + 1, realIndex + 1);
	else
		go:SetActive(false);
	end
end

function SetSkillGroupItemInfo(skillGroupPoolIndex, skillGroupListIndex)
	local skillGroupItem = mSkillGroupPool[skillGroupPoolIndex];
	local skillGroupInfo = mFilterdSkillGroupInfoList[skillGroupListIndex];
	skillGroupItem.title.text = "[b]" .. skillGroupInfo.source;
end

function GetUIFrame()
	return mSelf;
end

function SelectSkillItem(skillId)
	local lastSelectSkillId = mCurrentSelectSkillId;
	mCurrentSelectSkillId = skillId;	
	if skillId ~= lastSelectSkillId then
		if lastSelectSkillId ~= - 1 then
			for k, v in ipairs(mFilterdSkillGroupInfoList) do
				for m, n in ipairs(v._skillList) do
					if lastSelectSkillId == n.skillId then
						local wrapItem = mSkillGroupWrap:GetUIWithData(v);
						if wrapItem ~= nil then
							wrapItem:SetSelectFlagVisiable(m, false);
						end
					end
				end
			end
		end
		SetSkillDetailInfo(skillId);
	end
end

function GetCurrentSelectedSkillId()
	return mCurrentSelectSkillId;
end

function SetSkillDetailInfo(skillId)
	local skillTableInfo = SkillData.GetSkillInfo(skillId);
	if skillTableInfo.icon then
		mSkillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillTableInfo.icon));
	end
	mSkillNameLabel.text = "[b]" .. skillTableInfo.name;
	mSkillLabelLabel.text = skillTableInfo.desc;
	
	local commonSkillInfo = SkillMgr.GetCommonSkillInfo(skillId);
	local skillRealLevel;
	local skillShowLevel;
	if commonSkillInfo == nil then
		skillRealLevel = 0;
		skillShowLevel = 1;
		mSkillLevelUpInfoObject:SetActive(false);
		mSkillLevelStudyInfoObject:SetActive(true);
		mSkillTipLabelObject:SetActive(false);
		local skillLevelInfo = SkillData.GetSkillLevelInfo(skillId, 1);
		local stardyNeedInfo = skillLevelInfo.learnMustNeeds[1];
		local needItemData = ItemData.GetItemInfo(stardyNeedInfo.id)
		mSkillStudyConsumeIcon.spriteName = needItemData.icon_big;
		local skillStudyOwnCount = BagMgr.GetCountByItemId(stardyNeedInfo.id);
		mSkillStudyComsumeCountLabel.text = skillStudyOwnCount .. "/" .. stardyNeedInfo.count;
		mStudyNeedItemInfo.itemId = stardyNeedInfo.id;
		mStudyNeedItemInfo.itemCount = stardyNeedInfo.count;
	else
		skillRealLevel = commonSkillInfo.skillLevel;
		skillShowLevel = commonSkillInfo.skillLevel;
		mSkillLevelStudyInfoObject:SetActive(false);
		--判断是否达到最高等级
		if commonSkillInfo.skillLevel >= 5 then
			mSkillLevelUpInfoObject:SetActive(false);
			mSkillTipLabelObject:SetActive(true);
		else
			mSkillLevelUpInfoObject:SetActive(true);
			mSkillTipLabelObject:SetActive(false);
			--设置升级信息
			local skillNextLevelInfo = SkillData.GetSkillLevelInfo(skillId, commonSkillInfo.skillLevel + 1);
			if skillNextLevelInfo ~= nil then
				mSkillLevelUpEffect.text = skillNextLevelInfo.desc;
				if skillNextLevelInfo.learnMustNeeds == nil then return; end
				if #skillNextLevelInfo.learnMustNeeds == 1 then
					mSkillLevelUpItemConsumeInfoObject:SetActive(false);
					mSkillLevelUpCoinConsumeCountLabel.text = skillNextLevelInfo.learnMustNeeds[1].count;
					local moneyCount = BagMgr.GetMoney(Coin_pb.SILVER);
					mSkillLevelUpCoinOwnCountLabel.text = moneyCount;
					mSkillLevelUpConsumeTable:Reposition();
				elseif #skillNextLevelInfo.learnMustNeeds == 2 then
					mSkillLevelUpItemConsumeInfoObject:SetActive(true);
					mSkillLevelUpCoinConsumeCountLabel.text = skillNextLevelInfo.learnMustNeeds[1].count;
					local moneyCount = BagMgr.GetMoney(Coin_pb.SILVER);
					mSkillLevelUpCoinOwnCountLabel.text = moneyCount;
					local itemData = ItemData.GetItemInfo(skillNextLevelInfo.learnMustNeeds[2].id);
					mSkillLevelUpItemConsumeIcon.spriteName = itemData.icon_big;
					local skillLevelUpItemOwnCount = BagMgr.GetCountByItemId(skillNextLevelInfo.learnMustNeeds[2].id);
					mSkillLevelUpItemConsumeCountLabel.text = skillLevelUpItemOwnCount .. "/" .. skillNextLevelInfo.learnMustNeeds[2].count;
					mLevelUpNeedItemInfo.itemId = skillNextLevelInfo.learnMustNeeds[2].id;
					mLevelUpNeedItemInfo.itemCount = skillNextLevelInfo.learnMustNeeds[2].count;
					mSkillLevelUpConsumeTable:Reposition();
				else
					mSkillLevelUpItemConsumeInfoObject:SetActive(false);
					mSkillLevelUpCoinConsumeInfoObject:SetActive(false);
				end
				if skillNextLevelInfo.learnNeeds ~= nil and #skillNextLevelInfo.learnNeeds == 2 then
					local choseItemInfo1 = ItemData.GetItemInfo(skillNextLevelInfo.learnNeeds[1].id);
					mSkillLevelUpBookConsumeIcon.spriteName = choseItemInfo1.icon_big;
					local choseItemOwnCount1 = BagMgr.GetCountByItemId(skillNextLevelInfo.learnNeeds[1].id);
					mSkillLevelUpBookConsumeCountLabel.text = choseItemOwnCount1 .. "/" .. skillNextLevelInfo.learnNeeds[1].count;
					mLevelUpNeedSkillBookInfo.itemId = skillNextLevelInfo.learnNeeds[1].id;
					mLevelUpNeedSkillBookInfo.itemCount = skillNextLevelInfo.learnNeeds[1].count;
					local choseItemInfo2 = ItemData.GetItemInfo(skillNextLevelInfo.learnNeeds[2].id);
					mSkillLevelUpFragConsumeIcon.spriteName = choseItemInfo2.icon_big;
					local choseItemOwnCount2 = BagMgr.GetCountByItemId(skillNextLevelInfo.learnNeeds[2].id);
					mSkillLevelUpFragConsumeCountLabel.text = choseItemOwnCount2 .. "/" .. skillNextLevelInfo.learnNeeds[2].count;
					mLevelUpNeedFragmentInfo.itemId = skillNextLevelInfo.learnNeeds[2].id;
					mLevelUpNeedFragmentInfo.itemCount = skillNextLevelInfo.learnNeeds[2].count;
				end
			end
		end
	end
	
	for k, v in ipairs(mSkillStarList) do
		if k <= skillRealLevel then
			v.starIcon.gameObject:SetActive(true);
		else
			v.starIcon.gameObject:SetActive(false);
		end
	end
	local skillLevelInfo = SkillData.GetSkillLevelInfo(skillId, skillShowLevel);
	mSKillDescriptionLabel.text = skillLevelInfo.desc;
	mSkillReleaseNeedLabel.text = SkillMgr.GetSkillReleaseNeedsStr(skillLevelInfo.releaseNeeds, 1);
	
end

function OnSetCommonSkillIsEquipe(skillId, isEquip)
	for k, v in ipairs(mFilterdSkillGroupInfoList) do
		for m, n in ipairs(v._skillList) do
			if skillId == n.skillId then
				local wrapItem = mSkillGroupWrap:GetUIWithData(v);
				if wrapItem ~= nil then
					wrapItem:SetCommonSkillIsEquiped(m, isEquip);
				end
			end
		end
	end
end

function OnCommonSkillStarChanged(skillId)
	for k, v in ipairs(mFilterdSkillGroupInfoList) do
		for m, n in ipairs(v._skillList) do
			if skillId == n.skillId then
				local wrapItem = mSkillGroupWrap:GetUIWithData(v);
				if wrapItem ~= nil then
					mFilterdSkillGroupInfoList[k]._skillList[m].isActive = true;
					wrapItem:UpdateSkillStarInfo(m);
				end
			end
		end
	end
	--更新技能详情界面
	SetSkillDetailInfo(skillId);
	--播放升星特效
	local commonSkillInfo = SkillMgr.GetCommonSkillInfo(skillId);
	local skillLevel = commonSkillInfo.skillLevel;
	local starItem = mSkillStarList[skillLevel];
	if starItem then
		starItem.levelUpEffect:SetActive(false);
		starItem.levelUpEffect:SetActive(true);
	end
end

function GetDataindex(data)
	for k, v in ipairs(mFilterdSkillGroupInfoList) do
		if data._source == v._source then
			return k;
		end
	end
	return - 1;
end

function GetIsFilterListContainEquipedSkill()
	local equipSkillId = SkillMgr.GetEquipedSkillId();
	if equipSkillId == - 1 then
		return false;
	else
		local isFind = false;
		for k, v in ipairs(mFilterdSkillGroupInfoList) do
			for m, n in ipairs(v._skillList) do
				if equipSkillId == n.skillId then
					isFind = true;
					break;
				end
			end
		end
		return isFind;
	end
end

function UpdateMoney()
	local moneyCount = BagMgr.GetMoney(Coin_pb.SILVER);
	mSkillLevelUpCoinOwnCountLabel.text = moneyCount;
end

function OnItemChange(itemId, num)
	if itemId == mStudyNeedItemInfo.itemId then
		local ownCount = BagMgr.GetCountByItemId(mStudyNeedItemInfo.itemId);
		mSkillStudyComsumeCountLabel.text = ownCount .. "/" .. mStudyNeedItemInfo.itemCount;
	elseif itemId == mLevelUpNeedItemInfo.itemId then
		local ownCount = BagMgr.GetCountByItemId(mLevelUpNeedItemInfo.itemId);
		mSkillLevelUpItemConsumeCountLabel.text = ownCount .. "/" .. mLevelUpNeedItemInfo.itemCount;
	elseif itemId == mLevelUpNeedSkillBookInfo.itemId then
		local ownCount = BagMgr.GetCountByItemId(mLevelUpNeedSkillBookInfo.itemId);
		mSkillLevelUpBookConsumeCountLabel.text = ownCount .. "/" .. mLevelUpNeedSkillBookInfo.itemCount;
	elseif itemId == mLevelUpNeedFragmentInfo.itemId then
		local ownCount = BagMgr.GetCountByItemId(mLevelUpNeedFragmentInfo.itemId);
		mSkillLevelUpFragConsumeCountLabel.text = ownCount .. "/" .. mLevelUpNeedFragmentInfo.itemCount;
	end
end

function OnLevelUpConsumeOptionToggle()
	if mLevelUpBookToggle.value then
		mSkillLevelUpBtnLabel.text = WordData.GetWordStringByKey("skill_levelup_book");
	elseif mLevelUpFragmentToggle.value then
		mSkillLevelUpBtnLabel.text = WordData.GetWordStringByKey("skill_levelup_fragment");
	end
end 