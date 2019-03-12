module("UI_Divine_Shoot",package.seeall);


local CountDownState = {
	Idel = 1,
	ShootTiming = 2,
	CloseTiming = 3,
	Complete = 4,
}

local OriginalBorderScale = 0.05;
local BorderScaleOffset = 0.05;

local mCameraTexture;
local mPhotographImg;
local mPhotoImgTween;
local mOnFrequentTipItemMoveFinish = nil;
local mResaultLabel;

local mCameraTextureLoader;
local mPhotographImgLoader;

local mShootBtnObj;

local mOffset;
local mPhotoImgObj;

local mShootFx;
local mPhotoFx;

local mCDSprite;
local mCDLabel;

local mCDTime = 0;
local mDuration = 0;

local mCurrentState;

local mShootCD = 10000;
local mCloseCD = 1500;

function OnCreate( self )
	mCameraTexture = self:FindComponent("UITexture","Offset/Texture");
	mCameraTextureLoader = LoaderMgr.CreateTextureLoader(mCameraTexture);
	mPhotographImg = self:FindComponent("UITexture","Offset/PhotographImg");
	mPhotographImgLoader = LoaderMgr.CreateTextureLoader(mPhotographImg);
	mPhotoImgTween = self:FindComponent("TweenScale","Offset/PhotographImg");
	mOffset = self:Find("Offset");
	mPhotoImgObj = self:Find("Offset/PhotographImg");
	mShootBtn = self:FindComponent("UISprite","Offset/ShootBtn");
	mResaultLabel = self:FindComponent("UILabel","Offset/ResaultText");

	mCDSprite = self:FindComponent("UISprite","Offset/CDSprite");
	mCDLabel = self:FindComponent("UILabel","Offset/CDSprite/CDLabel");

	local originScale = 1 - (OriginalBorderScale * 2);
	local targetScale = 1 - (OriginalBorderScale * 2 + BorderScaleOffset);

	mPhotoImgTween.enabled = false;
    mPhotoImgTween.from = Vector3.New(originScale,originScale,1);
    mPhotoImgTween.to =  Vector3.New(targetScale,targetScale,1);
	mPhotoImgTween.duration = 0.5

	mOnPhotoScaleFininsh = EventDelegate.Callback(OnPhotoScaleFinish);
	EventDelegate.Set(mPhotoImgTween.onFinished, mOnPhotoScaleFininsh);

	local isMail = UserData.IsMale();
	if isMail then
		mCameraTextureLoader:LoadObject(ResConfigData.GetResConfigID("bg_paishe_02_01"));
		mPhotographImgLoader:LoadObject(ResConfigData.GetResConfigID("bg_paishe_02_01"));
		--UIUtil.LoadIcon(mCameraTexture,"bg_paishe_02_01");
		--UIUtil.LoadIcon(mPhotographImg,"bg_paishe_02_01");
	else
		mCameraTextureLoader:LoadObject(ResConfigData.GetResConfigID("bg_paishe_01_01"));
		mPhotographImgLoader:LoadObject(ResConfigData.GetResConfigID("bg_paishe_01_01"));
		--UIUtil.LoadIcon(mCameraTexture,"bg_paishe_01_01");
		--UIUtil.LoadIcon(mPhotographImg,"bg_paishe_01_01");
	end
	
	ResetUI();

	InitPhotograph();
end

function OnEnable( self )
	PhotographController.CombineInstance():Play();
	ResetUI();
	UpdateBeat:Add(OnUpdate,self);
end

function OnDisable( self )
	UpdateBeat:Remove(OnUpdate,self);
end

function InitPhotograph()
	PhotographController.CombineInstance():init(mCameraTexture);
	PhotographController.CombineInstance():SetPhtotBorderScale(OriginalBorderScale);
	--PhotographController.CombineInstance():Play();
end

function OnClick( go,id )
	if (id == 1) then
		OnCloseCDComplete();
	elseif (id == 2) then
		OnShootCDComplete();
	end
end

function ResetUI()
	mPhotographImg.gameObject:SetActive(false);
	mShootBtn.gameObject:SetActive(true);
	mResaultLabel.gameObject:SetActive(false);
	--mShootFx:Hide();
	--mPhotoFx:Hide();

	mCurrentState = CountDownState.ShootTiming;
	mDuration = mShootCD;
	mCDTime = mShootCD;
	mCDSprite.fillAmount = 1;

	mCDSprite.gameObject:SetActive(true);
end

function OnPhotoScaleFinish()
--	mResaultLabel.gameObject:SetActive(true);
end 

function OnCloseCDComplete()
	GameEvent.Trigger(EVT.STORY,EVT.STORY_DIVINE);
	UIMgr.UnShowUI(AllUI.UI_Divine_Shoot);
end

function OnUpdate(self)
	if mCurrentState == CountDownState.ShootTiming then
		mCDTime = mCDTime - GameTime.deltaTime_L;
		mCDTime = mCDTime <= 0 and 0 or mCDTime;
		mCDSprite.fillAmount = mCDTime / mDuration;
		mCDLabel.text = math.ceil(mCDTime / 1000);
		if mCDTime <= 0 then
			OnShootCDComplete();
		end
	elseif mCurrentState == CountDownState.CloseTiming then
		mCDTime = mCDTime - GameTime.deltaTime_L;
		mCDTime = mCDTime <= 0 and 0 or mCDTime;
		if mCDTime <= 0 then
			OnCloseCDComplete();
		end
	end
end


function OnShootCDComplete()
	mCDSprite.gameObject:SetActive(false);
	TakePhtot();
end

function TakePhtot()
	mCurrentState = CountDownState.CloseTiming;
	mDuration = mCloseCD;
	mCDTime = mCloseCD;
	
	mPhotographImg.gameObject:SetActive(true);
--	PhotographController.CombineInstance():TakePhotograph(mPhotographImg);
--	PhotographController.CombineInstance():Stop();

	mPhotoImgTween.enabled = true;
	mPhotoImgTween:ResetToBeginning();
	mPhotoImgTween:PlayForward();
	--mShootFx:Show();
	--mPhotoFx:Show();
	mShootBtn.gameObject:SetActive(false);
end



