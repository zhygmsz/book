module("UI_LoadingUpdate",package.seeall);

local mLoadingSlider;
local mLoadingLabel;
local mLoadingProgress;

function OnCreate(self)
    mLoadingSlider = self:FindComponent("UIProgressBar","Offset/ForeheadRoot/ProgressBar");
    mLoadingLabel = self:FindComponent("UILabel","Offset/ForeheadRoot/ProgressLabel");
end

function OnEnable()
    mLoadingProgress = 0;
    mLoadingSlider.value = 0;
    mLoadingLabel.text = "";
    LateUpdateBeat:Add(OnLateUpdate);
end

function OnDisable()
    LateUpdateBeat:Remove(OnLateUpdate);
    remove_module("Logic.Presenter.UI.Loading.UI_LoadingUpdate");
end

function OnLateUpdate()
    local stateProgress = GameStateMgr.GetState():GetStateProgress();
    local followSpeed = GameStateMgr.GetState():GetStateSpeed();
    if mLoadingProgress <= stateProgress then
        mLoadingProgress = math.min(mLoadingProgress + UnityEngine.Time.deltaTime * followSpeed, stateProgress);
    else
        mLoadingProgress = stateProgress
    end
    mLoadingSlider.value = mLoadingProgress;
    mLoadingLabel.text = string.format("%s",GameStateMgr.GetState():GetStateProgressDes());
    GameStateMgr.GetState():SetLoadingProgress(mLoadingProgress);
end
