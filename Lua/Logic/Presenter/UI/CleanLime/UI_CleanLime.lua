module("UI_CleanLime", package.seeall)

local LimeCamera = require("Logic/Presenter/UI/CleanLime/LimeCamera")
local mLimeCamera = nil

local mLimeTexture
local mAlpha
local mTimer = nil

local mCameraTimer = nil

local mBuffTimer = nil

local function AlphaTween()
    local function Tween()
        mAlpha = mAlpha - 0.01
        mLimeTexture.alpha = mAlpha
        if mAlpha <= 0 and mTimer ~= nil then
            GameTimer.DeleteTimer(mTimer)
            mTimer = nil
            UIMgr.UnShowUI(AllUI.UI_CleanLime)
        end
    end
    mAlpha = mLimeTexture.alpha
    mTimer = GameTimer.AddTimer(0.01, 100, Tween)

    MapMgr.RequestSendMapEvent(MapEvent.LIME_FADE)
end

function OnCreate(self)
    mLimeCamera = LimeCamera.new()
    mLimeTexture = self:Find("Offset/LimeTexture"):GetComponent("UITexture")

    mLimeTexture.gameObject:SetActive(true)
end

function OnEnable(self)

    TouchMgr.SetEnableDragJoyStick(false)

    UpdateBeat:Add(OnUpdate, self)
    mLimeCamera:Creat()
    mLimeTexture.mainTexture = mLimeCamera:GetRT()
    mLimeCamera:AddEffect()

    local vec = UIMgr.ScreenRealSize()
    mLimeTexture.height = vec.y
    mLimeTexture.width = vec.x

    local shader = CommonData.FindShader("Assets/Shader/Program/Lime/Wipe.shader", "LDJ/Wipe");
    local mt = UnityEngine.Material(shader)
    local renderTexture = mLimeCamera:GetRT()
    local brush = CommonData.FindAsset("Assets/Res/Misc/Brush.png")
    CleanLime.SetRT(renderTexture, mt, mLimeTexture, brush, 0.6)

    GameEvent.Reg(EVT.LIME, EVT.LIME_FADE, AlphaTween)
    GameEvent.Reg(EVT.LIME, EVT.LIME_BUFFSTOP, AlphaTween)

    local function OnCameraStop()
        mLimeCamera:StopCamera()
        if mCameraTimer then
            GameTimer.DeleteTimer(mCameraTimer)
            mCameraTimer = nil
        end
    end
    mCameraTimer = GameTimer.AddTimer(0.6, 1, OnCameraStop)

    local function OnBuffStop()
        AlphaTween()
        if mBuffTimer then
            GameTimer.DeleteTimer(mBuffTimer)
            mBuffTimer = nil
        end
    end
    mBuffTimer = GameTimer.AddTimer(10, 1, OnBuffStop)
end

function OnUpdate()
    CleanLime.Update();
end

function OnDisable(self)
    TouchMgr.SetEnableDragJoyStick(true)
    if mTimer then
        GameTimer.DeleteTimer(mTimer)
        mTimer = nil
        return 
    end

    if mCameraTimer then
        GameTimer.DeleteTimer(mCameraTimer)
        mCameraTimer = nil
        return 
    end

    if mBuffTimer then
        GameTimer.DeleteTimer(mBuffTimer)
        mBuffTimer = nil
        return 
    end

    mLimeCamera:Destory()

    UpdateBeat:Remove(OnUpdate, self);
    GameEvent.UnReg(EVT.LIME, EVT.LIME_FADE, AlphaTween)
    GameEvent.UnReg(EVT.LIME, EVT.LIME_BUFFSTOP, AlphaTween)
end

function OnDestory()
    
end