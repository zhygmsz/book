module("UIMgr",package.seeall)
local xpcall = xpcall;
local traceback = traceback;
local mUIRoot;
local mUIRootTransform;
local mUICamera;
local mUICameraGo;
local mUIMask;
local mUIGrey;
local mUIMgr = GameCore.UIMgr.Instance;

local CALLBACK_ID_GEN = 0;
local mCallBacks = {};

local function OnOpenEvent(uiData,eventName,...)
    if uiData.luaScript then
        if uiData.luaScript[eventName] then
            local flag,msg = xpcall(uiData.luaScript[eventName],traceback,uiData.csScript,...);
            if not flag then 
                GameLog.LogError("can't open ui %s, lua script has error %s",uiData.uiName,msg);
                uiData.csScript:GetRootGo():SetActive(false);
            end
        end
    else
        GameLog.LogError("can't open ui %s, lua script has error %s",uiData.uiName,uiData.error);
        uiData.csScript:GetRootGo():SetActive(false);
    end
end

local function OnCreate(uiID,uiFrame)
    local uiData = AllUI.GetUIData(uiID);
    local flag,msg = xpcall(require,traceback,uiData.uiPath);

    if not flag then uiData.error = msg; end
    uiData.valid = true;
    uiData.csScript = uiFrame;
    uiData.luaScript = flag and _G[uiData.uiName] or nil;
    uiFrame:SetUILayer(uiData.layer,uiData.group,uiData.alpha);
    uiFrame:SetPanelDepth(uiData.depth);
    uiFrame:SetToggleGroup(uiData.uiID * 1000);
    OnOpenEvent(uiData,"OnCreate");
end

local function OnEnable(uiID)
    local uiData = AllUI.GetUIData(uiID);
    GameLog.Log("open ui %s",uiData.uiName);
    uiData.enable = true;
    if uiData.args then
        OnOpenEvent(uiData,"OnEnable",unpack(uiData.args));
    else
        OnOpenEvent(uiData,"OnEnable");
    end
    if uiData.targetLayer and uiData.targetDepth then
        uiData.csScript:SetUILayer(uiData.targetLayer,uiData.group,uiData.alpha);
        uiData.csScript:SetPanelDepth(uiData.targetDepth);
    end
    local callBack = uiData.callBack;
    if callBack and callBack.func and callBack.valid then callBack.func(callBack.self); end
end

local function OnDisable(uiID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData then
        GameLog.Log("close ui %s",uiData.uiName);
        uiData.enable = false;
        if uiData.luaScript and uiData.luaScript.OnDisable then uiData.luaScript.OnDisable(uiData.csScript); end
    end
end

local function OnDestroy(uiID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData then
        GameLog.Log("destroy ui %s",uiData.uiName);
        uiData.valid = false;
        if uiData.luaScript and uiData.luaScript.OnDestroy then uiData.luaScript.OnDestroy(uiData.csScript); end
    end
end

local function OnPress(uiID, press, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnPress then uiData.luaScript.OnPress(press, btnID); end
end

local function OnLongPress(uiID, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnLongPress then uiData.luaScript.OnLongPress(btnID) end
end

local function OnSelect(uiID, select, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnSelect then uiData.luaScript.OnSelect(select, btnID); end
end

local function OnClick(uiID, go, btnID,soundType)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnClick then uiData.luaScript.OnClick(go, btnID); end
    GameEvent.Trigger(EVT.AUDIO,EVT.UI,soundType);
end

local function OnDragStart(uiID, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnDragStart then uiData.luaScript.OnDragStart(btnID); end
end

local function OnDrag(uiID, delta, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnDrag then uiData.luaScript.OnDrag(delta, btnID); end
end

local function OnDragEnd(uiID, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnDragEnd then uiData.luaScript.OnDragEnd(btnID); end
end

local function OnDragOver(uiID, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnDragOver then uiData.luaScript.OnDragOver(btnID); end
end

local function OnDragOut(uiID, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnDragOut then uiData.luaScript.OnDragOut(btnID); end
end

local function OnDoubleClick(uiID, btnID)
    local uiData = AllUI.GetUIData(uiID);
    if uiData.luaScript and uiData.luaScript.OnDoubleClick then uiData.luaScript.OnDoubleClick(btnID); end
end

local function OnMaskUIBegin(minDepth,maxDepth)
	if not mUIMask then
        mUIMask = {};
        --ROOT
        mUIMask.obj = UnityEngine.GameObject.New("MaskPanel");
        mUIMask.obj.layer = LayerMask.NameToLayer("UI");
        mUIMask.transform = mUIMask.obj.transform;
        mUIMask.transform:SetParent(mUIRoot.transform,false);
        mUIMask.panel = mUIMask.obj:AddComponent(typeof(UIPanel));
        --MASK
        mUIMask.maskObj = UnityEngine.GameObject.New("MaskTexture");
        mUIMask.maskObj.layer = LayerMask.NameToLayer("UI");
		mUIMask.maskTrans = mUIMask.maskObj.transform;
		mUIMask.maskTrans:SetParent(mUIMask.obj.transform,false);
        --MASK TEXTURE
		mUIMask.maskTexture = mUIMask.maskObj:AddComponent(typeof(UITexture));
        mUIMask.maskTexture.mainTexture = UnityEngine.Texture2D.blackTexture;
		mUIMask.maskTexture.width = 3000;
		mUIMask.maskTexture.height = 3000;
        mUIMask.maskTexture.shader = CommonData.FindShader("Assets/Shader/Program/UIMaskPanel.shader","GameEffects/UIMaskPanel");
        if tolua.isnull(mUIMask.maskTexture.shader) then
            GameLog.LogError("can't find mask panel shader");
        end
        --MASK COLLIDER ROOT
        mUIMask.colliderPanelObj = UnityEngine.GameObject.New("MaskColliderPanel");
        mUIMask.colliderPanelObj.layer = LayerMask.NameToLayer("UI");
        mUIMask.colliderPanelTrans = mUIMask.colliderPanelObj.transform;
        mUIMask.colliderPanelTrans:SetParent(mUIMask.transform,false);
        mUIMask.colliderPanel = mUIMask.colliderPanelObj:AddComponent(typeof(UIPanel));
        --MASK COLLIDER
        mUIMask.colliderObj = UnityEngine.GameObject.New("MaskCollider");
        mUIMask.colliderObj.layer = LayerMask.NameToLayer("UI");
		mUIMask.colliderTrans = mUIMask.colliderObj.transform;
		mUIMask.colliderTrans:SetParent(mUIMask.colliderPanelTrans,false);
        mUIMask.collider = mUIMask.colliderObj:AddComponent(typeof(UnityEngine.BoxCollider));
        mUIMask.colliderWidget = mUIMask.colliderObj:AddComponent(typeof(UIWidget));
        mUIMask.colliderWidget.autoResizeBoxCollider = true;
        mUIMask.colliderWidget.width = 3000;
        mUIMask.colliderWidget.height = 3000;

		mUIMask.obj:SetActive(false);
    end
    --修改遮罩的渲染顺序
	mUIMask.panel.depth = minDepth;
    mUIMask.panel.sortingOrder = minDepth;

    --修改遮罩距离摄像机的距离
    mUIMask.transform.localPosition = Vector3.New(0,0,2000 - math.abs(maxDepth) );
    --修改遮罩的碰撞渲染顺序
    mUIMask.colliderPanel.depth = maxDepth - 1;
    mUIMask.colliderPanel.sortingOrder = maxDepth - 1;
	mUIMask.obj:SetActive(true);
end

local function OnMaskUIFinish()
	if mUIMask then
		mUIMask.obj:SetActive(false);
	end
end

local function OnMakeUIGrey(uiElement,grey)
    if not mUIGrey then
        mUIGrey = {};
        mUIGrey.shader = CommonData.FindShader("Assets/Shader/Program/UIMaskGrey.shader","GameEffects/UIMaskGrey");
        mUIGrey.shader1 = CommonData.FindShader("Assets/Shader/Program/UIMaskGrey 1.shader","GameEffects/UIMaskGrey 1");
        if tolua.isnull(mUIGrey.shader) or tolua.isnull(mUIGrey.shader1) then
            GameLog.LogError("can't find mask grey shader");
        else
            mUIGrey.material = UnityEngine.Material(mUIGrey.shader);
            mUIGrey.material1 = UnityEngine.Material(mUIGrey.shader1);
        end
    end
    if not tolua.isnull(uiElement) then
        if grey then
            local uiPanel = uiElement.panel;
            local panelClipCount = (not tolua.isnull(uiPanel)) and uiPanel.clipCount or 0;
            if panelClipCount == 0 then
                uiElement.material = mUIGrey.material;
            elseif panelClipCount == 1 then
                uiElement.material = mUIGrey.material1;
            else
                GameLog.LogError("can't find grey shader for clip count %s",panelClipCount);
            end
        else
            uiElement.material = nil;
        end
    end
end

--[[
UI初始化,启动时调用一次
--]]
function InitModule()
    mUIRoot = UnityEngine.GameObject.Find("UI Root"):GetComponent(typeof(UIRoot));
    mUIRootTransform = mUIRoot.transform;
    mUICamera = UnityEngine.GameObject.Find("UI Root/Camera"):GetComponent(typeof(UnityEngine.Camera));
    mUICameraGo = mUICamera.gameObject;
    mUIMgr:Init(OnCreate,OnEnable,OnDisable,OnDestroy,OnPress,OnLongPress,OnSelect,OnClick,OnDragStart,OnDrag,OnDragEnd,OnDragOver,OnDragOut,OnDoubleClick);
end

--[[
打开指定的UI
uiData      table       使用AllUI.UI_XX_XX
self        class       回调对象(可选)
func        function    回调函数(可选)
layer       int         层级参数(可选)
depth       int         层级参数(可选)
hasArg      bool        OnEnable时是否需要传递参数  
...                     OnEnable时需要传递的额外参数(可选)
--]]
function ShowUI(uiData,self,func,layer,depth,hasArg,...)
    if not uiData then GameLog.LogError("can't open ui, uiData is nil"); return; end
    uiData.args = hasArg and {...} or nil;
    if uiData.enable and not layer then
        GameLog.LogError("can't open ui repeat,ui already opened %s",uiData.uiName);
    else
        uiData.targetLayer = layer;
        uiData.targetDepth = depth;
        if uiData.enable then
            uiData.csScript:SetUILayer(uiData.targetLayer,uiData.group,uiData.alpha);
            uiData.csScript:SetPanelDepth(uiData.targetDepth);
        else
            if func then
                uiData.callBack = uiData.callBack or {};
                uiData.callBack.func = func;
                uiData.callBack.self = self;
                uiData.callBack.valid = true;
                mUIMgr:ShowUI(uiData.uiID, uiData.uiResID, uiData.autoOpen);
            else
                if uiData.callBack then uiData.callBack.valid = false; end
                mUIMgr:ShowUI(uiData.uiID, uiData.uiResID, uiData.autoOpen);
            end
        end
    end
end

--[[
关闭指定UI
uiData      table       使用AllUI.UI_XX_XX
]]
function UnShowUI(uiData)
    if not uiData then GameLog.LogError("can't close ui, uiData is nil"); return; end
    if not uiData.enable then
        --GameLog.LogError("can't close ui repeat,ui already closed %s",uiData.uiName);
    else
        mUIMgr:UnShowUI(uiData.uiID);
        if uiData.targetDepth and uiData.targetLayer then
            uiData.targetDepth = nil;
            uiData.targetLayer = nil;
            uiData.csScript:SetUILayer(uiData.layer,uiData.group,uiData.alpha);
            uiData.csScript:SetPanelDepth(uiData.depth);
        end
    end
end

--[[
关闭所有UI,没啥事别调用这个函数
--]]
function UnShowAllUI(excludeUIData)
    mUIMgr:UnShowAllUI(excludeUIData and excludeUIData.uiID or -1);
end

--[[
卸载指定UI
uiData      table       使用AllUI.UI_XX_XX
]]
function UnLoadUI(uiData)
    mUIMgr:UnLoadUI(uiData.uiID);
end

--[[
卸载长期未使用的UI
--]]
function UnloadUnusedAssets()
    mUIMgr:UnloadUnusedAssets();
end

--[[
修改UI层级
uiData          table       使用AllUI.UI_XX_XX
uiLayer         int         新的层级
uiPanelDepth    int         新的深度
--]]
function ChangeLayer(uiData,uiLayer,uiPanelDepth)
	uiData.layer = uiLayer;
    uiData.depth = uiPanelDepth or AllUI.GET_UI_DEPTH_BY_LAYER(uiLayer);
    if uiData.valid then
        uiData.csScript:SetUILayer(uiData.layer,uiData.group,uiData.alpha);
        uiData.csScript:SetPanelDepth(uiData.depth);
    end
end

--[[
遮盖指定深度范围内的UI(不渲染,可能会触发点击)
mask            bool        打开或者关闭
maskMinDepth    int         最小深度值
maskMaxDepth    int         最大深度值
]]
function MaskUI(mask, maskMinDepth, maskMaxDepth)
    if mask then 
        OnMaskUIBegin(maskMinDepth,maskMaxDepth);
    else
        OnMaskUIFinish();
    end
end

--[[
遮盖指定深度范围内的UI(不渲染,可能会触发点击)
mask            bool        打开或者关闭
minLayer        int         最小层级值
maxLayer        int         最大层级值
]]
function MaskUIByLayer(mask, minLayer, maxLayer)
	if mask then
		if minLayer <= maxLayer then
			local minDepth = AllUI.GET_UI_DEPTH_BY_LAYER(minLayer) - 1
			local maxDepth = AllUI.GET_UI_DEPTH_BY_LAYER(maxLayer) + 1
			OnMaskUIBegin(minDepth, maxDepth)
		end
	else
		OnMaskUIFinish();
	end
end

--[[
是一个UI元素变灰
--]]
function MakeUIGrey(uiElement,grey)
    OnMakeUIGrey(uiElement,grey);
end

--[[
锁定某个界面的某个UI的点击事件
uiData          table       使用AllUI.UI_XX_XX
uiEventID       int         事件ID,-1表示该界面所有的UIEvent
lockEvent       bool        是否锁定事件
--]]
function LockEvent(uiData,uiEventID,lockEvent)
    mUIMgr:LockEvent(uiData.uiID,uiEventID,lockEvent);
end

--[[
聚焦某个界面的某个UI的点击事件
uiData          table       使用AllUI.UI_XX_XX
uiEventID       int         事件ID,除了该事件ID之外,其它都不可点击
focusEvent      bool        是否锁定事件
--]]
function FocusEvent(uiData,uiEventID,focusEvent)
    mUIMgr:FocusEvent(uiData.uiID,uiEventID,focusEvent);
end

--[[
Unity屏幕坐标点转NGUI坐标点
--]]
function ScreenPos2NGUIPos(screenPos)
    local screenSize = NGUITools.screenSize;
    return (screenPos - Vector3(screenSize.x,screenSize.y,0) * 0.5) * mUIRoot.pixelSizeAdjustment;
end

--[[
获取屏幕宽高比
--]]
function ScreenAspect()
    local screenSize = NGUITools.screenSize;
    return screenSize.x / screenSize.y;
end

--[[
屏幕相对于NGUI坐标系下的真实大小
--]]
function ScreenRealSize()
    local activeHeight = mUIRoot.activeHeight;
    local activeWidth = activeHeight * ScreenAspect();
    return Vector2(activeWidth,activeHeight);
end

--[[
调用UI的OnAction函数
uiData          table       使用AllUI.UI_XX_XX
...                         额外参数(可选)
--]]
function CallUIFunc(uiData,...)
	if uiData and uiData.luaScript and uiData.luaScript.OnAction then
		uiData.luaScript.OnAction(...);
	end
end

--[[
获取UI摄像机
--]]
function GetCamera()
    return mUICamera;
end

--[[
获取UI摄像机gameObject
--]]
function GetCameraGo()
    return mUICameraGo;
end

--[[
获取UIRoot
--]]
function GetUIRoot()
    return mUIRoot;
end

--[[
获取UIRoot根结点,用于设置父物体
--]]
function GetUIRootTransform()
    return mUIRootTransform;
end

--[[
获取指定UI指定事件ID的对象
--]]
function GetUIEventGo(uiData,evtID)

end

return UIMgr;
