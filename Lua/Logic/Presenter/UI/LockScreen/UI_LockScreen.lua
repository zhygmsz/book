module("UI_LockScreen",package.seeall)

local mLockScreen
local mTimer
local mCloseTimer

function OnCreate(ui)
    mLockScreen={};
    mLockScreen.slider = ui:FindComponent("UISlider","Offset/LockScreen")
    mLockScreen.uiEvent = ui:FindComponent("UIEvent","Offset/LockScreen/Tumb")
    mLockScreen.uiEvent.id = 1
    mLockScreen.label = ui:Find("Offset/Label").gameObject
end

function OnEnable(ui)
    mLockScreen.slider.value = 0
    mLockScreen.label:SetActive(true)
end

function OnDisable(ui)
end

function OnClick(go,id)
end

local function OnAddSlider()
    local value = mLockScreen.slider.value + 0.1
    mLockScreen.slider.value = value
    if mLockScreen.slider.value == 1 then
        GameTimer.DeleteTimer(mTimer);
        local function Close()
            UIMgr.UnShowUI(AllUI.UI_LockScreen)
            GameTimer.DeleteTimer(mCloseTimer);
        end
        mCloseTimer = GameTimer.AddTimer(0.2,1,Close)
    end
end

local function OnResetSlider()
    local value = mLockScreen.slider.value - 0.1
    mLockScreen.slider.value = value
    if mLockScreen.slider.value == 0 then
        mLockScreen.label:SetActive(true)
        GameTimer.DeleteTimer(mTimer);
    end
end

function OnPress(isPress,id)
    if id == 1 and isPress then
        mLockScreen.label:SetActive(false)
    elseif id== 1 and not isPress then
        if mLockScreen.slider.value >=0.65 then
            mTimer = GameTimer.AddTimer(0.03,20,OnAddSlider)
        else
            mTimer = GameTimer.AddTimer(0.03,20,OnResetSlider)
        end
    end
end