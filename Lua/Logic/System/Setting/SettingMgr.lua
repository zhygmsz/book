module("SettingMgr",package.seeall)

local mSettings

SettingEnum={
    Music = "Music",
    Sound = "Sound",
    Volume = "Volume",
    AutomaticallyGang = "AutomaticallyGang",
    AutomaticallyWorld = "AutomaticallyWorld",
    AutomaticallyTeam = "AutomaticallyTeam",
    AutomaticallyUnited = "AutomaticallyUnited",
    AutomaticCombatVideo = "AutomaticCombatVideo",
    RefusedFriendRequest = "RefusedFriendRequest",
    RefusedGangRequest = "RefusedGangRequest",
    SceneEffect = "SceneEffect",
    WithTheNumberOfScreen = "WithTheNumberOfScreen",
    ScreenResolution = "ScreenResolution",
    ClickFeedback = "ClickFeedback",
    ClickScreenColor = "ClickScreenColor",
}

function InitModule()
end

function InitClientData()
    --todo 策划配表 默认配置
    mSettings={}
    --基础
    mSettings[SettingEnum.Music] = UserData.GetSystemSetting(SettingEnum.Music,true)
    mSettings[SettingEnum.Sound] = UserData.GetSystemSetting(SettingEnum.Sound,true)
    mSettings[SettingEnum.Volume] = UserData.GetSystemSetting(SettingEnum.Volume,100)
    mSettings[SettingEnum.AutomaticallyGang] = UserData.GetSystemSetting(SettingEnum.AutomaticallyGang,true)
    mSettings[SettingEnum.AutomaticallyWorld] = UserData.GetSystemSetting(SettingEnum.AutomaticallyWorld,true)
    mSettings[SettingEnum.AutomaticallyTeam] = UserData.GetSystemSetting(SettingEnum.AutomaticallyTeam,true)
    mSettings[SettingEnum.AutomaticallyUnited] = UserData.GetSystemSetting(SettingEnum.AutomaticallyUnited,true)
    --画面
    mSettings[SettingEnum.SceneEffect] = UserData.GetSystemSetting(SettingEnum.SceneEffect,true)
    mSettings[SettingEnum.WithTheNumberOfScreen] = UserData.GetSystemSetting(SettingEnum.WithTheNumberOfScreen,true)
    mSettings[SettingEnum.ScreenResolution] = UserData.GetSystemSetting(SettingEnum.ScreenResolution,true)
    --战斗
    mSettings[SettingEnum.AutomaticCombatVideo] = UserData.GetSystemSetting(SettingEnum.AutomaticCombatVideo,true)
    --其他
    mSettings[SettingEnum.RefusedFriendRequest] = UserData.GetSystemSetting(SettingEnum.RefusedFriendRequest,false)
    mSettings[SettingEnum.RefusedGangRequest] = UserData.GetSystemSetting(SettingEnum.RefusedFriendRequest,false)
    mSettings[SettingEnum.ClickFeedback] = UserData.GetSystemSetting(SettingEnum.ClickFeedback,true)
    mSettings[SettingEnum.ClickScreenColor] = UserData.GetSystemSetting(SettingEnum.ClickScreenColor,UserData.IsMale() and 2 or 3)
end

return SettingMgr