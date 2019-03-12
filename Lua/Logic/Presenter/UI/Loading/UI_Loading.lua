module("UI_Loading",package.seeall);

local mLoadingObject;
local mLoadingSlider;
local mLoadingLabel;
local mLoadingProgress;

function OnCreate(self)
    mLoadingObject = self:Find("LoginLoading").gameObject;
    mLoadingSlider = self:FindComponent("UIProgressBar","LoginLoading/ForeheadRoot/ProgressBar");
	mLoadingLabel = self:FindComponent("UILabel","LoginLoading/ForeheadRoot/ProgressLabel");	
end

function OnEnable(self)
    mLoadingProgress = 0;
    mLoadingSlider.value = 0;
    mLoadingLabel.text = "";
    mLoadingObject:SetActive(true);
    LateUpdateBeat:Add(OnLateUpdate);
end

function OnDisable(self)
    mLoadingObject:SetActive(false);
    LateUpdateBeat:Remove(OnLateUpdate);
end

function OnLateUpdate()
    local stateProgress = GameStateMgr.GetState():GetStateProgress();
    if mLoadingProgress <= stateProgress then
        mLoadingProgress = math.min(mLoadingProgress + GameTime.deltaTime_L * 0.001, stateProgress);
    end
    mLoadingSlider.value = mLoadingProgress;
    mLoadingLabel.text = string.format("%d%%",mLoadingProgress * 100);
    GameStateMgr.GetState():SetLoadingProgress(mLoadingProgress);
end
