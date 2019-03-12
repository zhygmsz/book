module("UI_Setting_Basis_Voice",package.seeall)

local mMusic
local mSound
local mAutomatically
local mVolume
local mEventType={
    MusicSwitch=1,              --音乐开关
    SoundSwitch=2,              --音效开关
    VolumeSwitch=3,             --音量设置
    AutomaticallyGang=4,        --自动播放语音  帮派
    AutomaticallyWorld=5,       --自动播放语音  世界
    AutomaticallyTeam=6,        --自动播放语音  队伍
    AutomaticallyUnited=7,      --自动播放语音  门派
}

function OnCreate(ui)
    mMusic = {}
    mMusic.uiEvent = ui:FindComponent("UIEvent","Music")
    mMusic.bg = ui:FindComponent("UISprite","Music")
    mMusic.collider = ui:FindComponent("BoxCollider","Music")
    mMusic.thumb = ui:FindComponent("TweenPosition", "Music/thumb")
    mMusic.thumbTrans = ui:Find("Music/thumb").transform
    mMusic.thumb.enabled=false
    mMusic.uiEvent.id = mEventType.MusicSwitch

    mSound = {}
    mSound.uiEvent = ui:FindComponent("UIEvent","Sound")
    mSound.bg = ui:FindComponent("UISprite","Sound")
    mSound.collider = ui:FindComponent("BoxCollider","Sound")
    mSound.thumb = ui:FindComponent("TweenPosition", "Sound/thumb")
    mSound.thumbTrans = ui:Find("Sound/thumb").transform
    mSound.thumb.enabled=false
    mSound.uiEvent.id = mEventType.SoundSwitch

    mVolume={}
    mVolume.slider = ui:FindComponent("UISlider","Volume")
    mVolume.uiEvent = ui:FindComponent("UIEvent","Volume/Tumb")
    mVolume.uiEvent.id = mEventType.VolumeSwitch

    mAutomatically={}
    mAutomatically.gang={}
    mAutomatically.gang.uiEvent = ui:FindComponent("UIEvent","Label/GangChannel")
    mAutomatically.gang.select = ui:FindComponent("UISprite","Label/GangChannel/Select").gameObject
    mAutomatically.gang.uiEvent.id = mEventType.AutomaticallyGang
    
    mAutomatically.world={}
    mAutomatically.world.uiEvent = ui:FindComponent("UIEvent","Label/WorldChannel")
    mAutomatically.world.select = ui:FindComponent("UISprite","Label/WorldChannel/Select").gameObject
    mAutomatically.world.uiEvent.id = mEventType.AutomaticallyWorld
    
    mAutomatically.team={}
    mAutomatically.team.uiEvent = ui:FindComponent("UIEvent","Label/TeamChannel")
    mAutomatically.team.select = ui:FindComponent("UISprite","Label/TeamChannel/Select").gameObject
    mAutomatically.team.uiEvent.id = mEventType.AutomaticallyTeam
    
    mAutomatically.united={}
    mAutomatically.united.uiEvent = ui:FindComponent("UIEvent","Label/UnitedChannel")
    mAutomatically.united.select = ui:FindComponent("UISprite","Label/UnitedChannel/Select").gameObject
    mAutomatically.united.uiEvent.id = mEventType.AutomaticallyUnited

end

function OnEnable(ui)
    if UserData.GetSystemSetting(SettingMgr.SettingEnum.Music) then
        mMusic.bg.spriteName = "frame_common_22"
        mMusic.thumbTrans.localPosition = Vector3(25,0,0)
    else
        mMusic.bg.spriteName = "frame_common_23"
        mMusic.thumbTrans.localPosition = Vector3(-25,0,0)
    end
    if UserData.GetSystemSetting(SettingMgr.SettingEnum.Sound) then
        mSound.bg.spriteName = "frame_common_22"
        mSound.thumbTrans.localPosition = Vector3(25,0,0)
    else
        mSound.bg.spriteName = "frame_common_23"
        mSound.thumbTrans.localPosition = Vector3(-25,0,0)
    end
    mVolume.slider.value = tonumber(UserData.GetSystemSetting(SettingMgr.SettingEnum.Volume)) / 100
    mAutomatically.gang.select:SetActive(UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticallyGang))
    mAutomatically.world.select:SetActive(UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticallyWorld))
    mAutomatically.team.select:SetActive(UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticallyTeam))
    mAutomatically.united.select:SetActive(UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticallyUnited))
end

function OnDisable(ui)
end


function OnChangeSetting(key)
    if key == SettingMgr.SettingEnum.Music then 
        local mul = UserData.GetSystemSetting(SettingMgr.SettingEnum.Music) and -1 or 1
        mMusic.thumb.enabled = true
        mMusic.thumb.from =Vector3(-25*mul,0,0)
        mMusic.thumb.to = Vector3(25*mul,0,0)
        mMusic.thumb.duration = 0
        mMusic.thumb:PlayForward()
        if mul == -1 then
            mMusic.bg.spriteName = "frame_common_23"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.Music,false)
        else
            mMusic.bg.spriteName = "frame_common_22"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.Music,true)
        end
    elseif key == SettingMgr.SettingEnum.Sound then
        local mul = UserData.GetSystemSetting(SettingMgr.SettingEnum.Sound) and -1 or 1
        mSound.thumb.enabled = true
        mSound.thumb.from =Vector3(-25*mul,0,0)
        mSound.thumb.to = Vector3(25*mul,0,0)
        mSound.thumb.duration = 0
        mSound.thumb:PlayForward()
        if mul == -1 then 
            mSound.bg.spriteName = "frame_common_23"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.Sound,false)
        else
            mSound.bg.spriteName = "frame_common_22"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.Sound,true)
        end
    end
end

function OnClick(go,id)
    local isTrue

    if id == mEventType.MusicSwitch then
        OnChangeSetting(SettingMgr.SettingEnum.Music)
    elseif id == mEventType.SoundSwitch then
        OnChangeSetting(SettingMgr.SettingEnum.Sound)
    elseif id == mEventType.AutomaticallyGang then
        isTrue = UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticallyGang)
        mAutomatically.gang.select:SetActive(not isTrue)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.AutomaticallyGang,not isTrue)
    elseif id == mEventType.AutomaticallyWorld then
        isTrue = UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticallyWorld)
        mAutomatically.world.select:SetActive(not isTrue)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.AutomaticallyWorld,not isTrue)
    elseif id == mEventType.AutomaticallyTeam then
        isTrue = UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticallyTeam)
        mAutomatically.team.select:SetActive(not isTrue)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.AutomaticallyTeam,not isTrue)
    elseif id == mEventType.AutomaticallyUnited then
        isTrue = UserData.GetSystemSetting(SettingMgr.SettingEnum.AutomaticallyUnited)
        mAutomatically.united.select:SetActive(not isTrue)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.AutomaticallyUnited,not isTrue)
    end
end

function OnPress(isPress,id)
    if id == mEventType.VolumeSwitch and not isPress then
        local volume = math.ceil(mVolume.slider.value*100)
        AudioMgr.MuteAllEvents(volume == 0)
        UserData.SetSystemSetting(SettingMgr.SettingEnum.Volume,volume)
    end
end

return UI_Setting_Basis_Voice