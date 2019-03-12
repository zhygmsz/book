module("UI_Setting_Basis_Fight",package.seeall)

local mCombatVideo
local mEventType={
    CombatVideo=1,      --战斗录像
}


function OnCreate(ui)
    mFightInfo = {}
    mCombatVideo = {}
    
    mCombatVideo.open = {}
    mCombatVideo.open.uiEvent = ui:FindComponent("UIEvent","CombatVideo/Open")
    mCombatVideo.open.uiEvent.id= mEventType.CombatVideo
    mCombatVideo.open.select = ui:FindComponent("UISprite","CombatVideo/Open/Select").gameObject
    mCombatVideo.close = {}
    mCombatVideo.close.uiEvent = ui:FindComponent("UIEvent","CombatVideo/Close")
    mCombatVideo.close.uiEvent.id= mEventType.CombatVideo
    mCombatVideo.close.select = ui:FindComponent("UISprite","CombatVideo/Close/Select").gameObject
end

function OnEnable(ui)
    mCombatVideo.open.select:SetActive(UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticCombatVideo))
    mCombatVideo.close.select:SetActive(not UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticCombatVideo))
end

function OnDisable(ui)
end

function OnClick(go,id)
    local isTrue
    if id == mEventType.CombatVideo then
        isTrue = UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticCombatVideo)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.AutomaticCombatVideo,not isTrue)
        mCombatVideo.open.select:SetActive(not isTrue)
        mCombatVideo.close.select:SetActive(isTrue)
    end
end

return UI_Setting_Basis_Fight