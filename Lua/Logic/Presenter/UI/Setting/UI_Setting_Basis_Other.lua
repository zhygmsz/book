module("UI_Setting_Basis_Other",package.seeall)

local mRefusedFriendRequest
local mRefusedGangRequest
local mClickScreenPad
local mEventType={
    RefusedFriendRequest = 1,   --拒绝好友邀请
    RefusedGangRequest = 2,     --拒绝帮派邀请
    ClickFeedback = 3,          --点击反馈
    SelectColor = 4,            --屏幕点击反馈颜色
}

function OnCreate(ui)
    mRefusedFriendRequest={}
    mRefusedFriendRequest.uiEvent = ui:FindComponent("UIEvent","RefusedFriendRequest")
    mRefusedFriendRequest.bg = ui:FindComponent("UISprite","RefusedFriendRequest")
    mRefusedFriendRequest.collider = ui:FindComponent("BoxCollider","RefusedFriendRequest")
    mRefusedFriendRequest.thumb = ui:FindComponent("TweenPosition", "RefusedFriendRequest/thumb")
    mRefusedFriendRequest.thumbTrans = ui:Find("RefusedFriendRequest/thumb").transform
    mRefusedFriendRequest.thumb.enabled=false
    mRefusedFriendRequest.uiEvent.id = mEventType.RefusedFriendRequest

    mRefusedGangRequest={}
    mRefusedGangRequest.uiEvent = ui:FindComponent("UIEvent","RefusedGangRequest")
    mRefusedGangRequest.bg = ui:FindComponent("UISprite","RefusedGangRequest")
    mRefusedGangRequest.collider = ui:FindComponent("BoxCollider","RefusedGangRequest")
    mRefusedGangRequest.thumb = ui:FindComponent("TweenPosition", "RefusedGangRequest/thumb")
    mRefusedGangRequest.thumbTrans = ui:Find("RefusedGangRequest/thumb").transform
    mRefusedGangRequest.thumb.enabled=false
    mRefusedGangRequest.uiEvent.id = mEventType.RefusedGangRequest

    
    mClickScreenPad ={}
    mClickScreenPad.obj = ui:Find("ClickScreenPad").gameObject
    mClickScreenPad.clickFeedback={}
    mClickScreenPad.clickFeedback.bg = ui:FindComponent("UISprite", "ClickScreenPad/Switch")
    mClickScreenPad.clickFeedback.uiEvent = ui:FindComponent("UIEvent", "ClickScreenPad/Switch")
    mClickScreenPad.clickFeedback.uiEvent.id = mEventType.ClickFeedback
    mClickScreenPad.clickFeedback.thumb = ui:FindComponent("TweenPosition", "ClickScreenPad/Switch/thumb")
    mClickScreenPad.clickFeedback.thumbTrans = ui:Find("ClickScreenPad/Switch/thumb").transform
    mClickScreenPad.clickFeedback.thumb.enabled = false
    mClickScreenPad.colorBlue={}
    mClickScreenPad.colorBlue.uiEvent = ui:FindComponent("UIEvent", "ClickScreenPad/Color/BlueBtn")
    mClickScreenPad.colorBlue.uiEvent.id = mEventType.SelectColor
    mClickScreenPad.colorBlue.select = ui:Find("ClickScreenPad/Color/BlueBtn/Select").gameObject
    mClickScreenPad.colorPink={}
    mClickScreenPad.colorPink.uiEvent = ui:FindComponent("UIEvent", "ClickScreenPad/Color/PinkBtn")
    mClickScreenPad.colorPink.uiEvent.id = mEventType.SelectColor
    mClickScreenPad.colorPink.select = ui:Find("ClickScreenPad/Color/PinkBtn/Select").gameObject
end

function OnEnable(ui)
    if UserData.GetSystemSetting(SettingMgr.SettingEnum.RefusedFriendRequest) then
        mRefusedFriendRequest.bg.spriteName = "frame_common_22"
        mRefusedFriendRequest.thumbTrans.localPosition = Vector3(25,0,0)
    else
        mRefusedFriendRequest.bg.spriteName = "frame_common_23"
        mRefusedFriendRequest.thumbTrans.localPosition = Vector3(-25,0,0)
    end
    if UserData.GetSystemSetting(SettingMgr.SettingEnum.RefusedGangRequest) then
        mRefusedGangRequest.bg.spriteName = "frame_common_22"
        mRefusedGangRequest.thumbTrans.localPosition = Vector3(25,0,0)
    else
        mRefusedGangRequest.bg.spriteName = "frame_common_23"
        mRefusedGangRequest.thumbTrans.localPosition = Vector3(-25,0,0)
    end
    if UserData.GetSystemSetting(SettingMgr.SettingEnum.ClickFeedback) then
        mClickScreenPad.clickFeedback.bg.spriteName = "frame_common_22"
        mClickScreenPad.clickFeedback.thumbTrans.localPosition = Vector3(25,0,0)
    else
        mClickScreenPad.clickFeedback.bg.spriteName = "frame_common_23"
        mClickScreenPad.clickFeedback.thumbTrans.localPosition = Vector3(-25,0,0)
    end
    local coloridx = UserData.GetScreenClickColor()
    mClickScreenPad.colorBlue.select:SetActive(coloridx==2)
    mClickScreenPad.colorPink.select:SetActive(coloridx==3)
end

function OnDisable(ui)
end


function OnChangeSetting(key)
    if key == SettingMgr.SettingEnum.RefusedFriendRequest then 
        local mul = UserData.GetSystemSetting(SettingMgr.SettingEnum.RefusedFriendRequest) and -1 or 1
        mRefusedFriendRequest.thumb.enabled = true
        mRefusedFriendRequest.thumb.from =Vector3(-25*mul,0,0)
        mRefusedFriendRequest.thumb.to = Vector3(25*mul,0,0)
        mRefusedFriendRequest.thumb.duration = 0
        mRefusedFriendRequest.thumb:PlayForward()
        if mul == -1 then
            mRefusedFriendRequest.bg.spriteName = "frame_common_23"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.RefusedFriendRequest,false)
        else
            mRefusedFriendRequest.bg.spriteName = "frame_common_22"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.RefusedFriendRequest,true)
        end
    elseif key == SettingMgr.SettingEnum.RefusedGangRequest then
        local mul = UserData.GetSystemSetting(SettingMgr.SettingEnum.RefusedGangRequest) and -1 or 1
        mRefusedGangRequest.thumb.enabled = true
            mRefusedGangRequest.thumb.from =Vector3(-25*mul,0,0)
            mRefusedGangRequest.thumb.to = Vector3(25*mul,0,0)
            mRefusedGangRequest.thumb.duration = 0
            mRefusedGangRequest.thumb:PlayForward()
        if mul == -1 then 
            mRefusedGangRequest.bg.spriteName = "frame_common_23"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.RefusedGangRequest,false)
        else
            mRefusedGangRequest.bg.spriteName = "frame_common_22"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.RefusedGangRequest,true)
        end
    elseif key == SettingMgr.SettingEnum.ClickFeedback then
        local mul = UserData.GetSystemSetting(SettingMgr.SettingEnum.ClickFeedback) and -1 or 1
        mClickScreenPad.clickFeedback.thumb.enabled = true
        mClickScreenPad.clickFeedback.thumb.from =Vector3(-25*mul,0,0)
        mClickScreenPad.clickFeedback.thumb.to = Vector3(25*mul,0,0)
        mClickScreenPad.clickFeedback.thumb.duration = 0
        mClickScreenPad.clickFeedback.thumb:PlayForward()
        if mul == -1 then 
            mClickScreenPad.clickFeedback.bg.spriteName = "frame_common_23"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.ClickFeedback,false)
        else
            mClickScreenPad.clickFeedback.bg.spriteName = "frame_common_22"
            UserData.SetSystemSetting(SettingMgr.SettingEnum.ClickFeedback,true)
        end
    end
end

function OnClick(go,id)
    if id == mEventType.RefusedFriendRequest then
        OnChangeSetting(SettingMgr.SettingEnum.RefusedFriendRequest)
    elseif id == mEventType.RefusedGangRequest then
        OnChangeSetting(SettingMgr.SettingEnum.RefusedGangRequest)
    elseif id == mEventType.ClickFeedback then--点击反馈开关
        OnChangeSetting(SettingMgr.SettingEnum.ClickFeedback)
    elseif id == mEventType.SelectColor then--点击反馈颜色
        local idx = UserData.GetScreenClickColor()
        if idx == 2 then
            UserData.SetSystemSetting(SettingMgr.SettingEnum.ClickScreenColor,3)
            idx=3
        elseif idx==3 then 
            UserData.SetSystemSetting(SettingMgr.SettingEnum.ClickScreenColor,2)
            idx=2
        end
        mClickScreenPad.colorBlue.select:SetActive(idx==2)
        mClickScreenPad.colorPink.select:SetActive(idx==3)
    end
end

return UI_Setting_Basis_Other