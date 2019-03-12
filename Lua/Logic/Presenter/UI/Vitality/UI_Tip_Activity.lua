module("UI_Tip_Activity", package.seeall);

local mSelf;
local mEvents = {};
local mActivityId;

local mActivityIcon;
local mActivityIConLoader;
local mActivityNameLabel;
local mActivityCountLabel;
local mIsRecommendActivity;
local mRecommendBtn;
local mRecommendBtnLabel;

local mTimeInfoLabel;
local mParticipantTypeInfoLabel;
local mLimitInfoLabel;
local mDescriptionInfoLabel;
local mVatilityInfoLabel;

local mPrizeList = {};

function OnCreate(self)
	mSelf = self;
	mActivityIcon = self:FindComponent("UITexture", "Offset/ActivityInfo/IconBg/Icon");
	mActivityIConLoader = LoaderMgr.CreateTextureLoader(mActivityIcon);
	mActivityNameLabel = self:FindComponent("UILabel", "Offset/ActivityInfo/NameLabel");
	mActivityCountLabel = self:FindComponent("UILabel", "Offset/ActivityInfo/CountLable");
	mRecommendBtn = self:FindComponent("UISprite", "Offset/RecommendBtn");
	mRecommendBtnLabel = self:FindComponent("UILabel", "Offset/RecommendBtn/Label");
	
	mTimeInfoLabel = self:FindComponent("UILabel", "Offset/ActivityInfo/TimeInfo/TimeInfoLabel");
	mParticipantTypeInfoLabel = self:FindComponent("UILabel", "Offset/ActivityInfo/ParticipantTypeInfo/ParticipantTypeInfoLabel");
	mLimitInfoLabel = self:FindComponent("UILabel", "Offset/ActivityInfo/LimitInfo/LimitInfoLabel");
	mDescriptionInfoLabel = self:FindComponent("UILabel", "Offset/ActivityInfo/DescriptionInfo/DescriptionInfoLabel");
	mVatilityInfoLabel = self:FindComponent("UILabel", "Offset/ActivityInfo/VatilityInfo/VatilityInfoLabel");
	
	local prize01 = {};
	prize01.obj = self:FindComponent("UISprite", "Offset/ActivityInfo/ActivityPrizeInfo/Prize01");
	prize01.icon = self:FindComponent("UITexture", "Offset/ActivityInfo/ActivityPrizeInfo/Prize01/Icon");
	prize01.iconLoader = LoaderMgr.CreateTextureLoader(prize01.icon);
	table.insert(mPrizeList, prize01);
	local prize02 = {};
	prize02.obj = self:FindComponent("UISprite", "Offset/ActivityInfo/ActivityPrizeInfo/Prize02");
	prize02.icon = self:FindComponent("UITexture", "Offset/ActivityInfo/ActivityPrizeInfo/Prize02/Icon");
	prize02.iconLoader = LoaderMgr.CreateTextureLoader(prize02.icon);
	table.insert(mPrizeList, prize02);
	local prize03 = {};
	prize03.obj = self:FindComponent("UISprite", "Offset/ActivityInfo/ActivityPrizeInfo/Prize03");
	prize03.icon = self:FindComponent("UITexture", "Offset/ActivityInfo/ActivityPrizeInfo/Prize03/Icon");
	prize03.iconLoader = LoaderMgr.CreateTextureLoader(prize03.icon);
	table.insert(mPrizeList, prize03);
	local prize04 = {};
	prize04.obj = self:FindComponent("UISprite", "Offset/ActivityInfo/ActivityPrizeInfo/Prize04");
	prize04.icon = self:FindComponent("UITexture", "Offset/ActivityInfo/ActivityPrizeInfo/Prize04/Icon");
	prize04.iconLoader = LoaderMgr.CreateTextureLoader(prize04.icon);
	table.insert(mPrizeList, prize04);
	local prize05 = {};
	prize05.obj = self:FindComponent("UISprite", "Offset/ActivityInfo/ActivityPrizeInfo/Prize05");
	prize05.icon = self:FindComponent("UITexture", "Offset/ActivityInfo/ActivityPrizeInfo/Prize05/Icon");
	prize05.iconLoader = LoaderMgr.CreateTextureLoader(prize05.icon);
	table.insert(mPrizeList, prize05);
end

function OnEnable(self, ...)
	local args = ...;
	if args then
		mActivityId = args;
		UpdateActivityInfo(mActivityId);
	end
	RegEvent();
end

function OnDisable(self)
	mActivityId = nil;
	UnRegEvent();
end

function RegEvent(self)
	mEvents[1] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RECOMMEND_UPDATE, OnRecommendUpdated);
end

function UnRegEvent(self)
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RECOMMEND_UPDATE, mEvents[1]);
end

function OnClick(go, id)
	if id == 0 then
		UIMgr.UnShowUI(AllUI.UI_Tip_Activity);
	elseif id == 2 then
		--加入/移除推荐
		VitalityMgr.AddOrRemoveRecommendActivity(mActivityId, not mIsRecommendActivity);
		UIMgr.UnShowUI(AllUI.UI_Tip_Activity);
	end
end

function UpdateActivityInfo(activityId)
	local activityInfo = VitalityMgr.GetActivityItemInfoById(activityId);
	if activityInfo then
		mActivityIConLoader:LoadObject(activityInfo.icon);
		mActivityNameLabel.text = activityInfo.name;
		mActivityCountLabel.text = "0" .. "/" .. tostring(activityInfo.complete_count);
		mDescriptionInfoLabel.text = WordData.GetWordDataByID(activityInfo.description);
		mVatilityInfoLabel.text = activityInfo.value;
		--[[		
		if activityInfo.recommendatory then
			mRecommendBtn.gameObject:SetActive(false);
		else
			mRecommendBtn.gameObject:SetActive(true);
			mIsRecommendActivity =VitalityMgr.GetActivityIsInCustRecList(mActivityId);
			if mIsRecommendActivity then
				mRecommendBtnLabel.text = "移除推荐";
			else
				mRecommendBtnLabel.text = "加入推荐";
			end
		end
		]]
		mRecommendBtn.gameObject:SetActive(true);
		mIsRecommendActivity = VitalityMgr.GetActivityIsInCustRecList(mActivityId);
		if mIsRecommendActivity then
			mRecommendBtnLabel.text = WordData.GetWordDataByKey("Activity_recommend_out").value;
		else
			mRecommendBtnLabel.text = WordData.GetWordDataByKey("Activity_recommend_in").value;
		end
		--mTimeInfoLabel 时间
		--mLimitInfoLabel 等级限制
		--mRecommendBtnLabel 按钮文字
	end
end

function OnRecommendUpdated(info)
	if info.activityId == mActivityId then
		mIsRecommendActivity = info.isAdd;
		if info.isAdd then
			mRecommendBtnLabel.text = WordData.GetWordDataByKey("Activity_recommend_out").value;
		else
			mRecommendBtnLabel.text = WordData.GetWordDataByKey("Activity_recommend_in").value;
		end
	end
end 