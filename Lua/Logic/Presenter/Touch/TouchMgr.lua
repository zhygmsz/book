module("TouchMgr", package.seeall)

local mEventNames = 
{
	[1] = "OnPinchIn"; [2] = "OnPinchOut"; [3] = "OnPinchEnd";
	[4] = "OnSwipeBegin"; [5] = "OnSwipe"; [6] = "OnSwipeEnd";
	[7] = "OnTouchStart"; [8] = "OnTouchDown"; [9] = "OnTouchUp";
	[10] = "OnSimpleTap";
};

--事件开关及其回调
local mNGUIEnable = true;
local mTouchEnable = true;
local mCameraOperateEnable = true;
local mDragJoyStickEnable = true;
local mEventListeners = {};

--点地事件
local mClickGroundEnable = false;

--点击结果
local mTapResult = 
{
	frameCount = -1;
	frameObj = nil;
	framePoint = nil;
};

local function OnSimpleTapRaycast(dontTrigger)
	if mTapResult.frameCount ~= GameTime.frameCount then
		mTapResult.frameCount = GameTime.frameCount;
		mTapResult.tapObj,mTapResult.tapPoint = CameraMgr.Raycast(UICamera.lastEventPosition,CameraLayer.MainMaskLayer);
		local tapEntityScript = mTapResult.tapObj ~= nil and mTapResult.tapObj:GetComponent(typeof(GameCore.Entity)) or nil;
		mTapResult.entityType = tapEntityScript and tapEntityScript.mEntityType or nil;
		mTapResult.entityID = tapEntityScript and tapEntityScript.mEntityID or nil;
		local tapEntity = tapEntityScript and MapMgr.GetEntityByID(mTapResult.entityID) or nil;
		if not dontTrigger and tapEntity and tapEntity:IsValid() then GameEvent.Trigger(EVT.COMMON,EVT.CLICK_ENTITY,tapEntity); end
	end
	return mTapResult;
end

local function OnLuaEvent(eventName,eventParam,...)
	if (eventParam and mTouchEnable) or mNGUIEnable then
		local listeners = mEventListeners[eventName] or {};
		for idx,funcData in ipairs(listeners) do
			if funcData.isClass then
				local flag,msg = xpcall(funcData.func,traceback,funcData.obj,eventParam,...);
				if not flag then GameLog.LogError(msg); end
			else
				local flag,msg = xpcall(funcData.func,traceback,eventParam,...);
				if not flag then GameLog.LogError(msg); end
			end
		end
	end
end

local function OnTouchEvent(evtID,gesture)
	local evtName = mEventNames[evtID];
	if evtID >= 1 and evtID <= 3 then
		if not IsJoyStickDraging() then OnLuaEvent(evtName,gesture); end
	elseif evtID == 10 then
		OnLuaEvent(evtName,OnSimpleTapRaycast());
	else
		OnLuaEvent(evtName,gesture);
	end
end

local function AddListener(obj,eventName,isClass)
	local objType = type(obj);
	local func = (objType == "table" and obj[eventName]) or (objType == "function" and obj) or (nil);
	if func then
		local listeners = mEventListeners[eventName] or {};
		table.insert(listeners,{ func = func, obj = obj,isClass = isClass });
		mEventListeners[eventName] = listeners;
	end
end

local function RemoveListener(obj,eventName)
	local func = obj[eventName];
	if func then
		local listeners = mEventListeners[eventName] or {};
		for i = #listeners,1,-1 do
			if listeners[i] and listeners[i].func == func and listeners[i].obj == obj then
				table.remove(listeners,i);
			end
		end
	end
end

local function OnClickGround(tapResult)
	if tapResult.tapPoint and mClickGroundEnable then
		local mainPlayer = MapMgr.GetMainPlayer();
		if mainPlayer then mainPlayer:GetAIComponent():MoveWithDest(tapResult.tapPoint); end
	end
end

--开启监听滑动屏幕事件
function SetListenOnSwipe(obj,enable,isClass)
	if enable then
		AddListener(obj,"OnSwipeBegin",isClass);
		AddListener(obj,"OnSwipe",isClass);
		AddListener(obj,"OnSwipeEnd",isClass);
	else
		RemoveListener(obj,"OnSwipeBegin");
		RemoveListener(obj,"OnSwipe");
		RemoveListener(obj,"OnSwipeEnd");	
	end
end

--开启监听缩放屏幕事件
function SetListenOnPinch(obj,enable,isClass)
	if enable then
		AddListener(obj,"OnPinchIn",isClass);
		AddListener(obj,"OnPinchOut",isClass);
		AddListener(obj,"OnPinchEnd",isClass);
	else
		RemoveListener(obj,"OnPinchIn");
		RemoveListener(obj,"OnPinchOut");
		RemoveListener(obj,"OnPinchEnd");	
	end
end

--开启监听触摸屏幕事件
function SetListenOnTouch(obj,enable,isClass)
	if enable then
		AddListener(obj,"OnTouchDown",isClass);
		AddListener(obj,"OnTouchUp",isClass);
		AddListener(obj,"OnTouchStart",isClass);
	else
		RemoveListener(obj,"OnTouchDown");
		RemoveListener(obj,"OnTouchUp");
		RemoveListener(obj,"OnTouchStart");	
	end
end

--开启监听射线碰撞
function SetListenOnSimpleTap(obj,enable,isClass)
	if enable then
		AddListener(obj,"OnSimpleTap",isClass);
	else
		RemoveListener(obj,"OnSimpleTap");
	end
end

--开启监听NGUI事件
function SetListenOnNGUIEvent(obj,enable,isClass)
	if enable then
		AddListener(obj,"OnPressScreen",isClass);
		AddListener(obj,"OnClickScreen",isClass);
		AddListener(obj,"OnLongPressScreen",isClass);
	else
		RemoveListener(obj,"OnPressScreen");
		RemoveListener(obj,"OnClickScreen");
		RemoveListener(obj,"OnLongPressScreen",isClass);
	end
end

--开关事件时的回调
function SetListenOnEventEnable(obj,enable,isClass)
	if enable then
		AddListener(obj,"OnTouchEnable",isClass);
		AddListener(obj,"OnTouchDisable",isClass);
		AddListener(obj,"OnNGUIEnable",isClass);
		AddListener(obj,"OnNGUIDisable",isClass);
	else
		RemoveListener(obj,"OnTouchEnable");
		RemoveListener(obj,"OnTouchDisable");
		RemoveListener(obj,"OnNGUIEnable");
		RemoveListener(obj,"OnNGUIDisable");
	end
end

--开关TOUCH事件,慎用,别一不小心把游戏弄挂了
function SetTouchEventEnable(enable)
	mTouchEnable = enable;
end

--开关NGUI事件,慎用,别一不小心把游戏弄挂了
function SetNGUIEventEnable(enable)
	mNGUIEnable = enable;
	UICamera.ignoreAllEvents = not enable;
end

--开关NGUI模式,开启模式下触摸到NGUI组件不会触发TOUCH事件,只会触发NGUI事件,关闭后两种事件会同时触发
function SetEnableNGUIMode(enable)
	GameCore.TouchMgr.SetEnableNGUIMode(enable);
end

--开关点地事件
function SetEnableClickGround(clickGroundEnable)
	--mClickGroundEnable = clickGroundEnable;
end

--开关摄像机操作(滑动、缩放)
function SetEnableCameraOperate(enable)
	mCameraOperateEnable = enable;
end

--开关摇杆拖拽操作 withObj控制是否需要隐藏摇杆
function SetEnableDragJoyStick(enable,withObj)
	mDragJoyStickEnable = enable;
	GameCore.UIJoystick.EnableJoyStick(mDragJoyStickEnable,withObj);
end

--开关PINCH操作
function SetEnablePinch(enable)
	GameCore.TouchMgr.SetEnablePinch(enable);
end

--开关点击事件
function SetEnableEvent(enable)
	SetTouchEventEnable(enable);
	SetNGUIEventEnable(enable);
end

--当前帧点击到的对象
function GetFrameClickObj()
	return OnSimpleTapRaycast(true);
end

--是否可拖拽
function IsDragJoyStickEnable()
	return mDragJoyStickEnable;
end

--摇杆是否处于拖拽状态
function IsJoyStickDraging()
	return GameCore.UIJoystick.IsJoyStickDraging();
end

--是否可操作摄像机
function IsCameraOperateEnable()
	return mCameraOperateEnable;
end

function InitModule()
	local function OnPressScreen(go,state) OnLuaEvent("OnPressScreen",go,state);end
	local function OnClickScreen() OnLuaEvent("OnClickScreen",UICamera.lastEventPosition);end
	local function OnLongPressScreen(go) OnLuaEvent("OnLongPressScreen",go);end
	GameCore.TouchMgr.Init(OnTouchEvent);
	UICamera.onPress = UICamera.BoolDelegate(OnPressScreen);
	UICamera.onClick = UICamera.VoidDelegate(OnClickScreen);
	UICamera.onLongPress = UICamera.VoidDelegate(OnLongPressScreen);
	require("Logic/Presenter/Touch/TouchMgr_ScreenClick").InitScreenClick();
	require("Logic/Presenter/Touch/TouchMgr_Event").InitEvent();
	AddListener(OnClickGround,"OnSimpleTap");
end

return TouchMgr;
