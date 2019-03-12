module("TouchMgr",package.seeall)

local CLICK_DISTANCE = 2000;

--	1自己的模型 2蓝色猫爪 3粉色猫爪 4惊喜特效
local mClickEffectNames = 
{
    400400001,400400002,400400004,400400093
};
local mClickEffects = {};

--是否是快速点击状态
local mQuickClick = 0
--开速点击次数
local mQuickClickCount = 0

--上次点击的时间
local mLastQuickClickTime = 0
--点击自己的次数
local mClickPlayerCount = -1;
local mLastFrame = 0

--点击功能是否开启 读取设置
local function GetClickEffectEnable()
    local enable = UserData.GetScreenClickEnable()
    return enable
end

--拖拽功能是否开启 读取设置
local function GetDragEffectEnable()
    return false
end

--点击功能是否开启 读取设置
local function GetScreenClickColor()
    local enable = UserData.GetScreenClickColor()
    return enable
end

--快速点击间隔
local function GetQuickClickTime()
    return ConfigData.GetIntValue("touch_surprise_time") or 1000
end

--连续点击出现特殊特效次数
local function GetTouchSurpriseCount()
    return ConfigData.GetIntValue("touch_surprise_count") or 3
end

--点击自己的次数
local function GetClickSelfCount()
    if mClickPlayerCount==-1 then
        local key = string.format("ClickSelf-%s",tostring(UserData.PlayerID))
        mClickPlayerCount = UserData.ReadIntConfig(key)
    end
end

--点击自己的次数
local function SetClickSelfCount(v)
    local key = string.format("ClickSelf-%s",tostring(UserData.PlayerID))
    UserData.WriteIntConfig(key,v)
end

local function ShowEffect(touchPos)
    --计算NGUI坐标系下的坐标
    local localPos = UIMgr.ScreenPos2NGUIPos(touchPos);
    --男的显示类型2,女的显示类型3
    local effectType = GetScreenClickColor();
    --点到角色显示类型3
    local tapResult = TouchMgr.GetFrameClickObj();
    local isPlayer = tapResult.entityType and tapResult.entityType == EntityDefine.ENTITY_TYPE.PLAYER;
    local isNPC = tapResult.entityType and tapResult.entityType == EntityDefine.ENTITY_TYPE.NPC;
    local isMainPlayer = tapResult.entityType and tapResult.entityType == EntityDefine.ENTITY_TYPE.PLAYER_MAIN;
    local show = true
    if isMainPlayer then
        effectType = 1;
        --点击自己的成就是否完成 完成后不计数
        GetClickSelfCount()
        mClickPlayerCount = mClickPlayerCount+1
        SetClickSelfCount(mClickPlayerCount)
    elseif isPlayer then
        show=false
    end
    if show then
        --连续三次点击
        if mQuickClickCount>=GetTouchSurpriseCount() and math.fmod(mQuickClickCount,GetTouchSurpriseCount())==0 then 
            effectType = 4;
        end
        local clickEffect = mClickEffects[effectType];
        clickEffect:SetActive(false);
        clickEffect:SetLocalPosition(localPos);
        clickEffect:SetActive(true);
    end
end

local function AddQuickCount()
    --计数开始
    if mQuickClick ==0 then
        mLastQuickClickTime = TimeUtils.SystemTimeStamp(false)
        mQuickClickCount = 1
        mQuickClick=1
        --连续状态
    elseif mQuickClick==1 then
        local now = TimeUtils.SystemTimeStamp(false)
        if now - mLastQuickClickTime > GetQuickClickTime() then
            mQuickClick=1
            mQuickClickCount = 1
            mLastQuickClickTime = TimeUtils.SystemTimeStamp(false)
        else
            mLastQuickClickTime = TimeUtils.SystemTimeStamp(false)
            mQuickClickCount =mQuickClickCount +1
        end
    end
end

local function CheckAchievement()
    --成就判断
    GameLog.Log("mQuickClickCount %d mClickPlayerCount %d",mQuickClickCount,mClickPlayerCount)
    -- local key = string.format("QuickClick-%s",tostring(UserData.PlayerID))
   --  mPlayerInfoInited = UserData.ReadIntConfig(key)
end

function OnClickScreen(touchPos)
    if AllUI.UI_Main.enable and GetClickEffectEnable() and not UICamera.isOverUI then--
        if GameTime.frameCount == mLastFrame then
        else
            mLastFrame=GameTime.frameCount
            AddQuickCount()
            ShowEffect(touchPos);
            CheckAchievement()
        end
    end
end

function OnLongPressScreen(go)
    mQuickClick=1
    mQuickClickCount = 1
    mLastQuickClickTime = TimeUtils.SystemTimeStamp(false)
    --成就判断
    GameLog.Log("mQuickClickCount %d mClickPlayerCount %d",mQuickClickCount,mClickPlayerCount)
end

function OnTouchDown(gesture)
    if GetDragEffectEnable() then
        local finger = gesture.fingerIndex+1;
        local localPos = UIMgr.ScreenPos2NGUIPos(Vector3(gesture.position.x,gesture.position.y,0));
        GameLog.Log("OnTouchDown %d",localPos.x)
        local clickEffect = mClickEffects[1];
        --clickEffect:SetActive(false);
        clickEffect:SetLocalPosition(localPos);
        --clickEffect:SetActive(true);
    end
end

function InitScreenClick()
    SetListenOnNGUIEvent(TouchMgr,true);
    SetListenOnTouch(TouchMgr,true);
    for i = 1,#mClickEffectNames do
        mClickEffects[i] = LoaderMgr.CreateEffectLoader();
        mClickEffects[i]:LoadObject(mClickEffectNames[i]);
        mClickEffects[i]:SetParent(UIMgr.GetUIRootTransform());
        mClickEffects[i]:SetLocalScale(Vector3.one);
        mClickEffects[i]:SetLayer(CameraLayer.UILayer);
        mClickEffects[i]:SetSortOrder(199);
    end
end

function EnableClickEffect(enable)
    --GetClickEffectEnable() = enable;
    if not GetClickEffectEnable() then
        for _,clickEffect in ipairs(mClickEffects) do
            clickEffect:SetActive(false);
        end    
    end
end


function Destory()
    for _,clickEffect in ipairs(mClickEffects) do
        LoaderMgr.DeleteLoader(clickEffect);
    end
end

return TouchMgr;