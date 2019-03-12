module("CameraMgr",package.seeall)

--摄像机对象
local mMainCameraObj = nil;
local mMainCamera = nil;

local function InitDamageNumber()

end

function InitModule()
	require("Logic/Presenter/Camera/CameraRenderController")
	require("Logic/Presenter/Camera/CameraFollowController").InitModule();
	require("Logic/Presenter/Camera/CameraEffectController").InitModule();
	require("Logic/Presenter/Camera/Effect/CameraEffect").InitModule()
end

function InitCamera(mainPlayer)
	--目前主摄像机直接配置在场景内
	mMainCameraObj = UnityEngine.GameObject.FindGameObjectWithTag("MainCamera");
	mMainCamera = mMainCameraObj:GetComponent(typeof(UnityEngine.Camera));
	mMainCamera.cullingMask = CameraLayer.MainMaskLayer;

	CameraFollowController.InitCamera(mainPlayer,mMainCameraObj);
	CameraEffectController.InitCamera(mainPlayer,mMainCameraObj);
end

--主摄像机Transform
function GetMainCameraTransform() return mMainCameraObj.transform; end

--主摄像机GameObject
function GetMainCameraObj() return mMainCameraObj; end

--开关主摄像机
function EnableMainCamera(enable)  if mMainCamera then mMainCamera.enabled = enable; end end

--获取屏幕点发射线碰到的对象
function Raycast(screenPosition,raycastMaskLayer,raycastDistance,customCamera)
	local camera = customCamera or mMainCamera;
	if not tolua.isnull(camera) then
		if UICamera.isOverUI then return end
		local ray = camera:ScreenPointToRay(screenPosition)
		local hit = GameUtil.GameFunc.PhysicsRaycast(ray, raycastDistance or 1000, raycastMaskLayer);
		if tolua.isnull(hit.collider) then return nil end
		return hit.collider.gameObject,hit.point;
	end
end

--播放摄像机效果
function PlayCameraEffect(...) return CameraEffectController.PlayCameraEffect(...); end

--停止播放摄像机效果
function StopCameraEffect(...) return CameraEffectController.StopCameraEffect(...); end

--进入固定视角模式
function EnterFixedMode(...) CameraFollowController.EnterFixedMode(...); end

--进入固定视角模式
function EnterFixedZoomMode(...) CameraFollowController.EnterFixedZoomMode(...); end

--进入自由视角模式
function EnterFreeMode(...) CameraFollowController.EnterFreeMode(...); end

--进入自动跟随模式
function EnterFollowMode(...) CameraFollowController.EnterFollowMode(...); end

--进入默认视角模式 跟随玩家
function EnterDefaultMode() CameraFollowController.EnterDefaultMode(); end

--是否处于跟随模式
function IsInFollowMode() return CameraFollowController.IsInFollowMode(); end

return CameraMgr
