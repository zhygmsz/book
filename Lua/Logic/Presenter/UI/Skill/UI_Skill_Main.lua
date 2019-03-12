module("UI_Skill_Main", package.seeall);

local mCurrentUI = nil;
local mSkillToggle;
local mCommonSkillToggle;
local mPracticeToggle;
local mOtherToggle;

function OnCreate(self)
	mSkillToggle = self:FindComponent("UIToggle", "Offset/TabList/SkillTab");
	mCommonSkillToggle = self:FindComponent("UIToggle", "Offset/TabList/CommonSkillTab");
	mPracticeToggle = self:FindComponent("UIToggle", "Offset/TabList/PracticeTab");
	mOtherToggle = self:FindComponent("UIToggle", "Offset/TabList/OtherTab");

	local toggleCallBack = EventDelegate.Callback(OnToggleChanged);
	
	EventDelegate.Add(mSkillToggle.onChange, toggleCallBack);
	EventDelegate.Add(mCommonSkillToggle.onChange, toggleCallBack);
	EventDelegate.Add(mPracticeToggle.onChange, toggleCallBack);
	EventDelegate.Add(mOtherToggle.onChange, toggleCallBack);
end

function OnEnable(self)
	mSkillToggle.value = true;
	UIMgr.ShowUI(AllUI.UI_Skill_Base);
	local isInitByNetInfo = SkillMgr.GetIsInitByNetInfo();
	if not isInitByNetInfo then
		SkillMgr.RequestSkillData();
	end
end

function OnDisable(self)
end

function OnClick(go, id)
	if(id == 0) then
		CloseSecondUI();
		UIMgr.UnShowUI(AllUI.UI_Skill_Main);
		UIMgr.UnShowUI(AllUI.UI_Skill_Base);
		UIMgr.UnShowUI(AllUI.UI_Skill_Common);
	elseif(id == - 100) then
		CloseSecondUI();
	end
end

function OnToggleChanged()
	if mSkillToggle.value == true then
		UIMgr.ShowUI(AllUI.UI_Skill_Base);
	elseif mCommonSkillToggle.value == true then
		UIMgr.ShowUI(AllUI.UI_Skill_Common);
	elseif mPracticeToggle.value == true then
		TipsMgr.TipByKey("equip_share_not_support");
	elseif mOtherToggle.value == true then
		TipsMgr.TipByKey("equip_share_not_support");
	end
end

function CloseSecondUI()
	UIMgr.UnShowUI(AllUI.UI_Tip_SkillInfo);
end 