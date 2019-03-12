module("UI_FightHelp_Main", package.seeall);

local mSelf;
local mConfigTab;
local mRecruitTab;
local mTravelTab;
local mHandbookTab;

function OnCreate(self)
	mSelf = self;
	
	mConfigTab = self:FindComponent("UIToggle", "Offset/TabList/ConfigTab");
	mRecruitTab = self:FindComponent("UIToggle", "Offset/TabList/RecruitTab");
	mTravelTab = self:FindComponent("UIToggle", "Offset/TabList/TravelTab");
	mHandbookTab = self:FindComponent("UIToggle", "Offset/TabList/HandbookTab");
	
	local configCall = EventDelegate.Callback(OnConfigToggleChanged);
	local recruitCall = EventDelegate.Callback(OnRecruitToggleChanged);
	local travelCall = EventDelegate.Callback(OnTravelToggleChanged);
	local handBookCall = EventDelegate.Callback(OnHandBookToggleChanged);
	EventDelegate.Add(mConfigTab.onChange, configCall);
	EventDelegate.Add(mRecruitTab.onChange, recruitCall);
	EventDelegate.Add(mTravelTab.onChange, travelCall);
	EventDelegate.Add(mHandbookTab.onChange, handBookCall);
end

function OnEnable(self)
	mConfigTab.value = true;
	UIMgr.ShowUI(AllUI.UI_FightHelp_Config);
end

function OnDisable(self)
	-- body
end

function OnClick(go, id)
	if id == 0 then
		UIMgr.UnShowUI(AllUI.UI_FightHelp_Main);
		UIMgr.UnShowUI(AllUI.UI_FightHelp_Config);
		UIMgr.UnShowUI(AllUI.UI_FightHelp_Handbook);
		UIMgr.UnShowUI(AllUI.UI_FightHelp_Recruit);
	end
end

function OnConfigToggleChanged()
	local currentValue = mConfigTab.value;
	if currentValue == true then
		UIMgr.ShowUI(AllUI.UI_FightHelp_Config);
	else
		UIMgr.UnShowUI(AllUI.UI_FightHelp_Config);
	end
end

function OnRecruitToggleChanged()
	local currentValue = mRecruitTab.value;
	if currentValue == true then
		UIMgr.ShowUI(AllUI.UI_FightHelp_Recruit);
	else
		UIMgr.UnShowUI(AllUI.UI_FightHelp_Recruit);
	end
end

function OnTravelToggleChanged()
	local currentValue = mTravelTab.value;
	if currentValue == true then
		TipsMgr.TipByKey("equip_share_not_support");
	end
end

function OnHandBookToggleChanged(...)
	local currentValue = mHandbookTab.value;
	if currentValue == true then
		UIMgr.ShowUI(AllUI.UI_FightHelp_Handbook);
	else
		UIMgr.UnShowUI(AllUI.UI_FightHelp_Handbook);
	end
end

