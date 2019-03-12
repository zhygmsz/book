module("UI_Story_BossAppear", package.seeall);

--组件
local mNames = {};
local mNameEffects = {};
local mLines = {};

--变量
local mFinishedIdx = 1;
local mTimerIdxs = {};


function OnCreate(self)
    for idx = 1, 4 do
        mNames[idx] = self:FindComponent("UILabel", "Offset/Des/Des" .. idx);
        mNames[idx].gameObject:SetActive(false);
        mNameEffects[idx] = self:FindComponent("TypewriterEffect", "Offset/Des/Des" .. idx);

        local mContentFinishCB = EventDelegate.Callback(function()
            mFinishedIdx = idx;
            OnNameEffectFinished();
        end);
        EventDelegate.Set(mNameEffects[idx].onFinished, mContentFinishCB);
    end
end

function OnEnable(self)
    RegEvent(self);
    ShowEffect(mFinishedIdx);
end

function OnDisable(self)
    RemoveEvent(self);

    for _, v in pairs(mTimerIdxs) do
        if v then
            GameTimer.DeleteTimer(v);
        end
    end
end

function RegEvent(self)
    
end

function RemoveEvent(self)
    
end

function ShowEffect(idx)
    mTimerIdxs[idx] = GameTimer.AddTimer(1.5, 1, function()
        mTimerIdxs[idx] = nil;
        if mNameEffects[idx] then
            mNames[idx].gameObject:SetActive(true);
            local str = mNames[idx].text;
            mNames[idx].text = "";
            mNames[idx].text = str;
            mNameEffects[idx]:ResetToBeginning();
        end
    end);
end

function OnNameEffectFinished()
    if mNameEffects[mFinishedIdx].isActive then
        mFinishedIdx = mFinishedIdx + 1;
        if mFinishedIdx <= #mNameEffects then
            ShowEffect(mFinishedIdx);
        else
            --结束
        end
    end
end