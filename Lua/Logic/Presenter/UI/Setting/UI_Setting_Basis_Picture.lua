module("UI_Setting_Basis_Picture",package.seeall)

local mSceneEffect
local mWithTheNumberOfScreen
local mScreenResolution

local mEventType={
    SceneEffect = 1,        --场景特效
    WithTheNumberOfScreen = 2,        --同屏人数
    ScreenResolution = 3,   --分辨率
}

function OnCreate(ui)
    mSceneEffect={}
    mSceneEffect.open = {}
    mSceneEffect.open.uiEvent = ui:FindComponent("UIEvent","SceneEffect/Open")
    mSceneEffect.open.uiEvent.id= mEventType.SceneEffect
    mSceneEffect.open.select = ui:FindComponent("UISprite","SceneEffect/Open/Select").gameObject
    mSceneEffect.close = {}
    mSceneEffect.close.uiEvent = ui:FindComponent("UIEvent","SceneEffect/Close")
    mSceneEffect.close.uiEvent.id= mEventType.SceneEffect
    mSceneEffect.close.select = ui:FindComponent("UISprite","SceneEffect/Close/Select").gameObject

    mWithTheNumberOfScreen={}
    mWithTheNumberOfScreen.open = {}
    mWithTheNumberOfScreen.open.uiEvent = ui:FindComponent("UIEvent","ScenePerson/Open")
    mWithTheNumberOfScreen.open.uiEvent.id= mEventType.WithTheNumberOfScreen
    mWithTheNumberOfScreen.open.select = ui:FindComponent("UISprite","ScenePerson/Open/Select").gameObject
    mWithTheNumberOfScreen.close = {}
    mWithTheNumberOfScreen.close.uiEvent = ui:FindComponent("UIEvent","ScenePerson/Close")
    mWithTheNumberOfScreen.close.uiEvent.id= mEventType.WithTheNumberOfScreen
    mWithTheNumberOfScreen.close.select = ui:FindComponent("UISprite","ScenePerson/Close/Select").gameObject

    mScreenResolution={}
    mScreenResolution.open = {}
    mScreenResolution.open.uiEvent = ui:FindComponent("UIEvent","ScreenResolution/Open")
    mScreenResolution.open.uiEvent.id= mEventType.ScreenResolution
    mScreenResolution.open.select = ui:FindComponent("UISprite","ScreenResolution/Open/Select").gameObject
    mScreenResolution.close = {}
    mScreenResolution.close.uiEvent = ui:FindComponent("UIEvent","ScreenResolution/Close")
    mScreenResolution.close.uiEvent.id= mEventType.ScreenResolution
    mScreenResolution.close.select = ui:FindComponent("UISprite","ScreenResolution/Close/Select").gameObject
end

function OnEnable(ui)
    mSceneEffect.open.select:SetActive(UserData.GetSystemSetting(SettingMgr.SettingEnum.SceneEffect))
    mSceneEffect.close.select:SetActive(not UserData.GetSystemSetting(SettingMgr.SettingEnum.SceneEffect))

    mWithTheNumberOfScreen.open.select:SetActive(UserData.GetSystemSetting(SettingMgr.SettingEnum.WithTheNumberOfScreen))
    mWithTheNumberOfScreen.close.select:SetActive(not UserData.GetSystemSetting(SettingMgr.SettingEnum.WithTheNumberOfScreen))
    mScreenResolution.open.select:SetActive(UserData.GetSystemSetting(SettingMgr.SettingEnum.ScreenResolution))
    mScreenResolution.close.select:SetActive(not UserData.GetSystemSetting(SettingMgr.SettingEnum.ScreenResolution))
end

function OnDisable(ui)
end

function OnClick(go,id)
    local isTure
    if id == mEventType.SceneEffect then
        isTrue = UserData.GetSystemSetting(SettingMgr.SettingEnum.SceneEffect)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.SceneEffect,not isTrue)
        mSceneEffect.open.select:SetActive(not isTrue)
        mSceneEffect.close.select:SetActive(isTrue)
    elseif id == mEventType.WithTheNumberOfScreen then
        isTrue = UserData.GetSystemSetting(SettingMgr.SettingEnum.WithTheNumberOfScreen)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.WithTheNumberOfScreen,not isTrue)
        mWithTheNumberOfScreen.open.select:SetActive(not isTrue)
        mWithTheNumberOfScreen.close.select:SetActive(isTrue)
    elseif id == mEventType.ScreenResolution then
        isTrue = UserData.GetSystemSetting(SettingMgr.SettingEnum.ScreenResolution)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.ScreenResolution,not isTrue)
        mScreenResolution.open.select:SetActive(not isTrue)
        mScreenResolution.close.select:SetActive(isTrue)
    end
end

return UI_Setting_Basis_Picture