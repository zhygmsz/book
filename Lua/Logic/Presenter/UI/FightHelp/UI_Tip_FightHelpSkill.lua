module("UI_Tip_FightHelpSkill", package.seeall);

local mSelf;

local mSkillIcon;
local mSkillIconLoader;
local mSkillNameLabel;
local mSkillLevelInfo;
local mSkillLevelLabel;

local mSkillDesLabel;

local mSkillLevelUpInfo;
local mSpendItemIcon;
local mSpendItemIconLoader;
local mSpendItemCountLabel;
local mOwnItemIcon;
local mOwnItemIconLoader;
local mOwnItemCountLabel;

local mTipLabel;

function OnCreate(self)
	mSelf = self;
	
	mSkillIcon = self:FindComponent("UITexture", "Offset/SkillInfo/SkillIconBg/SkillIcon");
	mSkillIconLoader = LoaderMgr.CreateTextureLoader(mSkillIcon);
	mSkillNameLabel = self:FindComponent("UILabel", "Offset/SkillInfo/SkillNameLabel");
	
	mSkillLevelInfo = self:Find("Offset/SkillInfo/SkillLevelInfo").transform;
	mSkillLevelLabel = self:FindComponent("UILabel", "Offset/SkillInfo/SkillLevelInfo/SkillLevelLabel");
	
	mSkillDesLabel = self:FindComponent("UILabel", "Offset/SkillInfo/SkillDesLabel");
	
	mSkillLevelUpInfo = self:Find("Offset/SkillLevelUpInfo").transform;
	mSpendItemIcon = self:FindComponent("UITexture", "Offset/SkillLevelUpInfo/SpendInfo/ItemIcon");
	mSpendItemIconLoader = LoaderMgr.CreateTextureLoader(mSpendItemIcon);
	mSpendItemCountLabel = self:FindComponent("UILabel", "Offset/SkillLevelUpInfo/SpendInfo/ItemCountLabel");
	mOwnItemIcon = self:FindComponent("UITexture", "Offset/SkillLevelUpInfo/OwnInfo/ItemIcon");
	mOwnItemIconLoader = LoaderMgr.CreateTextureLoader(mOwnItemIcon);
	mOwnItemCountLabel = self:FindComponent("UILabel", "Offset/SkillLevelUpInfo/OwnInfo/ItemCountLabel");
	
	mTipLabel = self:FindComponent("UILabel", "Offset/TipLabel");
end

function OnEnable(self, ...)
	local skillInfo = ...;
	SetSkillInfo(skillInfo);
end

function OnDisable(self)
	-- body
end

function OnClick(go, id)
    if id == -1 then
        UIMgr.UnShowUI(AllUI.UI_Tip_FightHelpSkill);
    elseif id == 1 then
        --技能升级
    end
end

function SetSkillInfo(info)
	local skillInfo = SkillData.GetSkillInfo(info.skillId);
	mSkillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillInfo.icon));
    mSkillDesLabel.text = skillInfo.desc;
    mSkillNameLabel.text = skillInfo.name;

    local fightHelpInfo = FightHelpMgr.GetFightHelpInfo(info.fightHelperId);
    
	if info.skillLevel == -1 then
		mSkillLevelInfo.gameObject:SetActive(false);
        mSkillLevelUpInfo.gameObject:SetActive(false);
        mTipLabel.gameObject:SetActive(true);
        mTipLabel.text = "解锁技能以升级";
    elseif fightHelpInfo and info.skillLevel >= fightHelpInfo.starLevel then
        mSkillLevelInfo.gameObject:SetActive(false);
        mSkillLevelUpInfo.gameObject:SetActive(false);
        mTipLabel.gameObject:SetActive(true);
        mTipLabel.text = "技能等级已达上限";
	else
		mSkillLevelInfo.gameObject:SetActive(true);
        mSkillLevelLabel.text = info.skillLevel;
        mTipLabel.gameObject:SetActive(false);
        
		mSkillLevelUpInfo.gameObject:SetActive(true);
		local skillLevelUpInfo = SkillMgr.GetSkillLevelUpInfo(info.skillId, info.skillLevel + 1);
		local itemData = ItemData.GetItemInfo(skillLevelUpInfo.levelUpNeeds[1].id);
		UIUtil.LoadItemIcon(mSpendItemIcon, itemData);
		mSpendItemCountLabel.text = skillLevelUpInfo.levelUpNeeds[1].count;
		UIUtil.LoadItemIcon(mOwnItemIcon, itemData);
		mOwnItemCountLabel.text = BagMgr.GetMoney(Coin_pb.SILVER);
		--设置拥有数量
    end
end 