module("UI_Vitality_Main", package.seeall);

local mSelf;
local MAX_VITALITY_VALUE = 100;
local mEvents = {};

local mActivityItemPool = {};
local mActivityInfoList = {};

local mVitalityItemList = {};

local mRecommendToggle;
local mDailyToggle;
local mChallengeToggle;
local mArderToggle;

local mUpdateTimeLabel;
local mProgressBarBg;
local mActivityListTable;

local mActivityItemPrefab;
local mActivityWrap;

local mVitalityAwardPrefab;
local mAwardListTrans;

local mWrapCall;
local mThumbValueLabel;

local MAX_ACTIVITY_WRAP_COUNT = 10;

function OnCreate(self)
	mSelf = self;
	mRecommendToggle = self:FindComponent("UIToggle", "Offset/ActivityTabList/RecommendTab");
	mDailyToggle = self:FindComponent("UIToggle", "Offset/ActivityTabList/DailyTab");
	mChallengeToggle = self:FindComponent("UIToggle", "Offset/ActivityTabList/ChallengeTab");
	mArderToggle = self:FindComponent("UIToggle", "Offset/ActivityTabList/ArderTab");
	
	mUpdateTimeLabel = self:FindComponent("UILabel", "Offset/Remind/UpdateTimeBg/UpdateTimeLabel");
	
	mActivityItemPrefab = self:Find("Offset/ActivityList/ActivityItemPrefab").transform;
	mActivityItemPrefab.gameObject:SetActive(false);
	mActivityWrap = self:FindComponent("UIWrapContent", "Offset/ActivityList/ActivityScrollView/ActivityWrap");
	mWrapCall = UIWrapContent.OnInitializeItem(OnUpdateItem);
	
	mVitalityAwardPrefab = self:Find("Offset/DailyVitalityProgress/AwardList/AwardPrefab").transform;
	mVitalityAwardPrefab.gameObject:SetActive(false);
	mAwardListTrans = self:Find("Offset/DailyVitalityProgress/AwardList").transform;
	
	mProgressBar = self:FindComponent("UIProgressBar", "Offset/DailyVitalityProgress/ProgressBar");
	mProgressBarBg = self:FindComponent("UISprite", "Offset/DailyVitalityProgress/ProgressBar/Background");
	mThumbValueLabel = self:FindComponent("UILabel", "Offset/DailyVitalityProgress/ProgressBar/Thumb/Thumb/ThumbValue");
	
	local recommendCall = EventDelegate.Callback(OnRecommendToggleChanged);
	local dailyCall = EventDelegate.Callback(OnDailyToggleChanged);
	local challengeCall = EventDelegate.Callback(OnChallengeToggleChanged);
	local arderCall = EventDelegate.Callback(OnArderToggleChanged);
	
	EventDelegate.Add(mRecommendToggle.onChange, recommendCall);
	EventDelegate.Add(mDailyToggle.onChange, dailyCall);
	EventDelegate.Add(mChallengeToggle.onChange, challengeCall);
	EventDelegate.Add(mArderToggle.onChange, arderCall);
	
	InitActiveItemPool();
	InitVitalityAward();
end

function OnEnable(self)
	InitVitalityPrize()
	RegEvent(self);
	OnVatilityValueChanged();
end

function OnDisable(self)
	UnRegEvent(self);
end

function RegEvent(self)
	mEvents[1] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_VALUE_CHANGE, OnVatilityValueChanged);
	mEvents[2] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_GET_AWARD, OnGetVitalityAward);
	mEvents[3] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RECOMMEND_UPDATE, OnRecommendUpdated);
	mEvents[4] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RESET_VITALITY, OnResetVitality);
end

function UnRegEvent(self)
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_VALUE_CHANGE, mEvents[1]);
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_GET_AWARD, mEvents[2]);
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RECOMMEND_UPDATE, mEvents[3]);
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RESET_VITALITY, mEvents[4]);
end

function InitActiveItemPool()
	for i = 1, MAX_ACTIVITY_WRAP_COUNT do
		local activityItem = {};
		activityItem.activityId = - 1
		activityItem.gameObject = mSelf:DuplicateAndAdd(mActivityItemPrefab, mActivityWrap.transform, i).gameObject;
		activityItem.transform = activityItem.gameObject.transform;
		activityItem.background = activityItem.transform:Find("ActiveItemBg"):GetComponent("UISprite");
		activityItem.activityIcon = activityItem.transform:Find("ActiveIconBg/Texture"):GetComponent("UITexture");
		activityItem.activityIconLoader = LoaderMgr.CreateTextureLoader(activityItem.activityIcon);
		activityItem.activityName = activityItem.transform:Find("ActiveNameLabel"):GetComponent("UILabel");
		activityItem.countValueLabel = activityItem.transform:Find("CountAndVitality/CountValueLabel"):GetComponent("UILabel");
		activityItem.vitalityValueLabel = activityItem.transform:Find("CountAndVitality/VitalityValueLabel"):GetComponent("UILabel");
		activityItem.joinBtn = activityItem.transform:Find("JoinBtn"):GetComponent("UISprite");
		activityItem.openTimeTip = activityItem.transform:Find("OpenTimeTip"):GetComponent("UISprite");
		activityItem.openTimeTipLabel = activityItem.transform:Find("OpenTimeTip/TipLabel"):GetComponent("UILabel");
		activityItem.finishFlag = activityItem.transform:Find("FinishFlag"):GetComponent("UISprite");
		local iconBg = activityItem.transform:Find("ActiveIconBg"):GetComponent("UISprite");
		activityItem.desEvent = iconBg.transform:GetComponent("UIEvent");
		activityItem.joinEvent = activityItem.joinBtn.transform:GetComponent("UIEvent");
		table.insert(mActivityItemPool, activityItem);
	end
end

function OnUpdateItem(go, index, realIndex)
	if realIndex >= 0 and realIndex < #mActivityInfoList then
		go:SetActive(true);
		SetActivityItemInfo(index + 1, realIndex + 1);
	else
		go:SetActive(false);
	end
end

function SetActivityItemInfo(activityPoolIndex, ActivityInfoIndex)
	local activityItem = mActivityItemPool[activityPoolIndex];
	local activityInfo = mActivityInfoList[ActivityInfoIndex];
	
	if activityItem and activityInfo then
		activityItem.activityId = activityInfo.id;
		activityItem.activityIconLoader:LoadObject(activityInfo.icon);
		activityItem.activityName.text = activityInfo.name;
		activityItem.countValueLabel.text = tostring(activityInfo.complete_count);
		activityItem.vitalityValueLabel.text = tostring(activityInfo.value);
		activityItem.joinBtn.gameObject:SetActive(true);
		activityItem.background.spriteName = "button_common_06";
		--button_common_20
		activityItem.openTimeTip.gameObject:SetActive(false);
		--activityItem.openTimeTipLabel
		activityItem.finishFlag.gameObject:SetActive(false);
		activityItem.desEvent.id = activityInfo.id + 1000;
		activityItem.joinEvent.id = activityInfo.id + 2000;
	end
end

function OnRecommendToggleChanged()
	local currentValue = mRecommendToggle.value;
	if currentValue == true then
		mActivityInfoList = VitalityMgr.GetRecommendActivityList();
		ResetWrap();
	end
end

function OnDailyToggleChanged()
	local currentValue = mDailyToggle.value;
	if currentValue == true then
		mActivityInfoList = VitalityMgr.GetDailyActivityList();
		ResetWrap();
	end
end

function OnChallengeToggleChanged()
	local currentValue = mChallengeToggle.value;
	if currentValue == true then
		mActivityInfoList = VitalityMgr.GetChallengeActivityList();
		ResetWrap();
	end
end

function OnArderToggleChanged()
	local currentValue = mArderToggle.value;
	if currentValue == true then
		mActivityInfoList = VitalityMgr.GetArderActivityList();
		ResetWrap();
	end
end

function ResetWrap()
	mActivityWrap:ResetWrapContent(#mActivityInfoList, mWrapCall);
end

function GetActivityNetData(activityId)
	-- body
end

function OnClick(go, id)
	if id >= 1000 and id < 2000 then
		--活动详情
		local activityId = id - 1000;
		UIMgr.ShowUI(AllUI.UI_Tip_Activity, mSelf, nil, nil, nil, true, activityId);
	elseif id >= 2000 and id < 3000 then
		--参加活动
		local activityId = id - 2000;
		VitalityMgr.CompleteActivity(activityId);
	elseif id >= 3000 then
		--领取奖励
		local vitalityId = id - 3000;
		GetVitalityAward(vitalityId);
	elseif id == 0 then
		--返回
		UIMgr.UnShowUI(AllUI.UI_Vitality_Main);
	elseif id == 1 then
		--日历
		UIMgr.ShowUI(AllUI.UI_Vitality_Calendar);
	elseif id == 2 then
		--提醒
	elseif id == 3 then
		--新闻
		UIMgr.ShowUI(AllUI.UI_Vitality_News);
	elseif id == 4 then
		--周活跃度
		UIMgr.ShowUI(AllUI.UI_Vitality_Week);
	end
end

function InitVitalityAward()
	local originPos = mProgressBar.transform.localPosition;
	local progressBarWidth = mProgressBarBg.width;
	local startPos = Vector3.New(originPos.x - progressBarWidth / 2, originPos.y, originPos.z);
	local endPos = Vector3.New(originPos.x + progressBarWidth / 2, originPos.y, originPos.z);
	
	local vitalityItemInfos = VitalityMgr.GetVitalityItemInfos();
	for k, v in ipairs(vitalityItemInfos) do
		--v.award_item;
		local active = v.active;
		local dropId = 102001;
		local vitalityItem = {};
		vitalityItem.id = v.id;
		vitalityItem.value = v.active;
		vitalityItem.getFlag = false;
		vitalityItem.gameObject = mSelf:DuplicateAndAdd(mVitalityAwardPrefab, mAwardListTrans, k).gameObject;
		vitalityItem.gameObject:SetActive(true);
		vitalityItem.transform = vitalityItem.gameObject.transform;
		vitalityItem.gameObject.name = v.id;
		vitalityItem.uiEvent = vitalityItem.transform:GetComponent("UIEvent");
		vitalityItem.uiEvent.id = 3000 + v.id;
		vitalityItem.bg = vitalityItem.transform:GetComponent("UISprite");
		
		vitalityItem.icon = vitalityItem.transform:Find("AwardIcon"):GetComponent("UITexture");
		vitalityItem.iconLoader = LoaderMgr.CreateTextureLoader(vitalityItem.icon);
		
		local rootSortorder = mSelf:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
		local effectResId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_zidongzhandou_eff01.prefab")
		vitalityItem.effectLoader = LoaderMgr.CreateEffectLoader();
		vitalityItem.effectLoader:LoadObject(effectResId);
		vitalityItem.effectLoader:SetParent(vitalityItem.icon.transform,true);
		vitalityItem.effectLoader:SetSortOrder(rootSortorder);
		vitalityItem.effectLoader:SetActive(false);
		
		local awardItemlist = ItemDropData.GetAwardItems(102001);
		local itemInfo = ItemData.GetItemInfo(awardItemlist[1].itemId);
		vitalityItem.iconLoader:LoadObject(ResConfigData.GetResConfigID(itemInfo.icon_big));
		
		vitalityItem.vitalityValueLabel = vitalityItem.transform:Find("VitalityValueLabel"):GetComponent("UILabel");
		vitalityItem.vitalityValueLabel.text = v.active;
		
		local pos = Vector3.Lerp(startPos, endPos, v.active / MAX_VITALITY_VALUE);
		vitalityItem.transform.localPosition = pos;
		
		table.insert(mVitalityItemList, vitalityItem);
	end
end

function OnVatilityValueChanged()
	local currentVitality = VitalityMgr.GetCurrentVitalityValue();
	mProgressBar.value = currentVitality / MAX_VITALITY_VALUE;
	mThumbValueLabel.text = currentVitality;
	for k, v in ipairs(mVitalityItemList) do
		if not v.getFlag and currentVitality >= v.value then
			if v.effectLoader then v.effectLoader:SetActive(true,true); end
		end
	end
end

function GetVitalityAward(vitalityId)
	for k, v in ipairs(mVitalityItemList) do
		if v.id == vitalityId then
			if v.getFlag == true then
				TipsMgr.TipByKey("Activity_prize_taked");
				return;
			end
			if v.value > VitalityMgr.GetCurrentVitalityValue() then
				TipsMgr.TipByKey("Activity_vitality_notenough");
				return;
			end
			VitalityMgr.GetAward(vitalityId);
		end
	end
end

function InitVitalityPrize()
	local awradGetInfo = VitalityMgr.GetAwardGetFlagInfo();
	local currentVitality = VitalityMgr.GetCurrentVitalityValue();
	for k, v in ipairs(awradGetInfo) do
		local vitalityItem = mVitalityItemList[k];
		if v == 0 then
			vitalityItem.bg.spriteName = "frame_common_bai";
			UIMgr.MakeUIGrey(vitalityItem.icon, false);
			vitalityItem.getFlag = false;
			if currentVitality >= vitalityItem.value then
				if vitalityItem.effectLoader then vitalityItem.effectLoader:SetActive(true,true); end
			end
		else
			vitalityItem.bg.spriteName = "frame_common_hui";
			UIMgr.MakeUIGrey(vitalityItem.icon, true);
			vitalityItem.getFlag = true;
		end
	end
end

function OnGetVitalityAward(vitalityId)
	for k, v in ipairs(mVitalityItemList) do
		if v.id == vitalityId then
			v.getFlag = true;
			v.bg.spriteName = "frame_common_hui";
			UIMgr.MakeUIGrey(v.icon, true);
			if v.effectLoader then v.effectLoader:SetActive(false); end
			VitalityMgr.SetAwardGetFlagInfo(k, true);
			break;
		end
	end
end

function OnRecommendUpdated(ifno)
	if mRecommendToggle.value == true then
		mActivityInfoList = VitalityMgr.GetRecommendActivityList();
		ResetWrap();
	end
end

function OnResetVitality()
	InitVitalityPrize()
	OnVatilityValueChanged();
end 