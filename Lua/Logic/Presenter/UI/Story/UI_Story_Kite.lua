module("UI_Story_Kite",package.seeall);
local mPoemEnable ;
local mPoemTexture;
local mStartTime;
local mUI;
local mStoryID;
local mActions = {};

function OnCreate(ui)
    mPoemTexture = ui:FindComponent("UITexture","Texture");

    mUI = ui;
end

function OnEnable(ui)
    UIMgr.MaskUI(true, AllUI.GET_MIN_DEPTH(), AllUI.GET_UI_DEPTH(AllUI.UI_Story_Kite));
    mPoemTexture.fillAmount = 0;
    mStartTime = GameTime.time_L;
    mPoemEnable = true;
    UpdateBeat:Add(Update);
    for i=1, #mActions do
        mActions[i]();
    end
    mActions = {};
end

function OnAction(params)

    local temp = function()
        local targetUIGo = mUI:Find(params[1]).gameObject;
        targetUIGo:SetActive(true);

        local duration = params[2] and tonumber(params[2])*0.001;
        if duration and duration >0 then
            GameTimer.AddTimer(duration,1,function(go) go:SetActive(false); end,targetUIGo);
        end
    end
    if not mUI then
        table.insert(mActions, temp);
    else
        temp();
    end
end

function Update()
    if mPoemTexture.fillAmount <1 then
        mPoemTexture.fillAmount  = mPoemTexture.fillAmount  + 0.05;
    end
    if mPoemEnable and GameTime.time_L - mStartTime > 10000 then
        mPoemTexture.enabled = false;
        mPoemEnable = false;
        UpdateBeat:Remove(Update);
    end
end

function OnDisable(ui)
    UIMgr.MaskUI(false);
end

function OnClick(go,id)
    if id == 0 then
        
    end
end
