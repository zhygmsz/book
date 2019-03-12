module("UI_Tip_SkillInfo", package.seeall)

local mSelf;
local mOffset;

local mTipType;

local mWidgetOffset = {x = 0, y = 0};
local mAnchorObj;

local mOffset;
local BgWidget;
local mSkillIconBackground;
local mSkillIcon;
local mSkillIconLoader;
local mSkillName;
local mSkillBriefDes;
local mSkillCD;
local mSkillNeed;
local mSkillDetailedDes;
local mEquipFlag;

function OnCreate(self)
	mSelf = self;
	mOffset = self:Find("Offset/BgWidget");
	
	mTable = self:FindComponent("UITable", "Offset/BgWidget/Table");
	BgWidget = self:FindComponent("UIWidget", "Offset/BgWidget");
	mCDTitle = self:FindComponent("UILabel", "Offset/BgWidget/Table/Title1").gameObject;
	mNeedTitle = self:FindComponent("UILabel", "Offset/BgWidget/Table/Title2").gameObject;
	mDesTitle = self:FindComponent("UILabel", "Offset/BgWidget/Table/Title3").gameObject;
	
	mSkillIconBackground = self:FindComponent("UISprite", "Offset/BgWidget/SkillIconBgSprite");
	mSkillIcon = self:FindComponent("UITexture", "Offset/BgWidget/SkillIconBgSprite/IconTexture");
	mSkillIconLoader = LoaderMgr.CreateTextureLoader(mSkillIcon);
	mSkillName = self:FindComponent("UILabel", "Offset/BgWidget/SkillNameLabel");
	mSkillBriefDes = self:FindComponent("UILabel", "Offset/BgWidget/SkillDesBriefLabel");
	mSkillCD = self:FindComponent("UILabel", "Offset/BgWidget/Table/Title1/CDLabel");
	mSkillNeed = self:FindComponent("UILabel", "Offset/BgWidget/Table/Title2/NeedLabel");
	mSkillDetailedDes = self:FindComponent("UILabel", "Offset/BgWidget/Table/Title3/SkillDesDetailedLabel");
	mEquipFlag = self:FindComponent("UISprite", "Offset/BgWidget/EquipFlga");
	
	mSkillCD.color = Color.New(1, 1, 1, 1);
	mSkillNeed.color = Color.New(1, 1, 1, 1);
end

function OnEnable(self, ...)
	local args = {...}
	mTipType = args[1];
	
	local skillId = args[2];
	local skilllevel = args[3];
	
	mAnchorObj = args[4];
	mWidgetOffset.x = args[5];
	mWidgetOffset.y = args[6];
	
	SetSkillInfo(skillId, skilllevel);
end

function OnDisable(self)
end

function SetSkillInfo(skillId, skillLevel)
	if skillId == - 1 then return; end
	
	local skillNormalInfo = SkillData.GetSkillInfo(skillId);
	local skillCurrentLevelInfo = SkillData.GetSkillLevelInfo(skillId, skillLevel);
	
	mOffset.transform.localPosition = Vector3.New(0, 0, 0);
	if mAnchorObj ~= nil then
		local orignParent = mOffset.transform.parent;
		mOffset.transform.parent = mAnchorObj.transform;
		mOffset.transform.localPosition = Vector3.New(mWidgetOffset.x, mWidgetOffset.y, 0);
		mOffset.transform.parent = orignParent;
	else
		mOffset.transform.localPosition = Vector3.New(mWidgetOffset.x, mWidgetOffset.y, 0);
	end
	mSkillName.text = skillNormalInfo.name;
	mSkillBriefDes.text = skillNormalInfo.desc;
	mSkillDetailedDes.text = skillCurrentLevelInfo.desc2;
	mSkillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillNormalInfo.icon));
	if mTipType == 1 then
		BgWidget.height = 370;
		mNeedTitle:SetActive(true);
		local cunsumeStr = SkillMgr.GetSkillReleaseNeedsStr(skillCurrentLevelInfo.releaseNeeds, 2);
		mSkillNeed.text = cunsumeStr;
		mCDTitle:SetActive(true);
		local skillCD = SkillMgr.GetSkillCD(skillId, skillLevel);
		mSkillCD.text = "[7ad8f4ff]" .. skillCD .. "[-][ffddabff]秒[-]";
		mTable:Reposition()
	elseif mTipType == 2 then
		BgWidget.height = 300;
		mNeedTitle:SetActive(false);
		mCDTitle:SetActive(false);
		mTable:Reposition()
	end
end
