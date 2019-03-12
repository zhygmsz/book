--录音通用UI，由SpeechMgr控制，请不要私用
module("UI_Tip_Speech",package.seeall)

local mSpeachRoot;
local mCancelRoot;
local mCountDownSprit;

local mStartTime;
local mMaxLength;
local mToken;

local function OnUpdate()
    local current = TimeUtils.SystemTimeStamp(true);

    if current >= mStartTime + mMaxLength then
        SpeechMgr.StopRecord(mToken);
        UpdateBeat:Remove(OnUpdate);
        return;
    end
    mCountDownSprit.fillAmount = (current-mStartTime)/mMaxLength;
end

local function OnPrepareCancel(state)
    mSpeachRoot:SetActive(not state);
    mCancelRoot:SetActive(state);
end

function OnCreate(self)
    mSpeachRoot = self:FindGo("Offset/SpeachRoot");
    mCancelRoot = self:FindGo("Offset/CancelRoot");	
    mCountDownSprit = self:FindComponent("UISprite", "Offset/TimeDown");
end

function OnEnable(self, token, length)
    mToken = token;
    mMaxLength = length;
    mStartTime = TimeUtils.SystemTimeStamp(true);
    
    mCountDownSprit.fillAmount = 1;
    OnPrepareCancel(false);
    UpdateBeat:Add(OnUpdate);
    GameEvent.Reg(EVT.SPEECH, EVT.SPEECH_PREPARE_CANCEL, OnPrepareCancel);
end

function OnDisable(self)
    GameEvent.UnReg(EVT.SPEECH, EVT.SPEECH_PREPARE_CANCEL, OnPrepareCancel);
    UpdateBeat:Remove(OnUpdate);
end

function OnDestroy()
    mSpeachRoot = nil;
    mCancelRoot = nil;
    mCountDownSprit = nil;
end