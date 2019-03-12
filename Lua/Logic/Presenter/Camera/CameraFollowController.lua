module("CameraFollowController",package.seeall)

function OnPinchIn(gesture)
	if TouchMgr.IsCameraOperateEnable() then GameCore.UtilCameraFollow.Zoom(gesture.deltaPinch); end
end

function OnPinchOut(gesture)
	if TouchMgr.IsCameraOperateEnable() then GameCore.UtilCameraFollow.Zoom(-gesture.deltaPinch); end
end

function OnPinchEnd(gesture) GameCore.UtilCameraFollow.ZoomEnd(); end

function OnSwipeBegin(gesture)
	if TouchMgr.IsCameraOperateEnable() then GameCore.UtilCameraFollow.RotateBegin(); end
end

function OnSwipe(gesture)
	if TouchMgr.IsCameraOperateEnable() then GameCore.UtilCameraFollow.Rotate(gesture.deltaPosition.x, gesture.deltaPosition.y); end
end

function OnSwipeEnd(gesture) GameCore.UtilCameraFollow.RotateEnd(); end

function InitModule()
	TouchMgr.SetListenOnPinch(CameraFollowController,true);
	TouchMgr.SetListenOnSwipe(CameraFollowController,true);
end

function InitCamera(mainPlayer,cameraObj)
	--观察点偏移,相对于目标点
	GameCore.CameraSetting.offset = Vector3(0, UserData.GetHeight(), 0);
	GameCore.CameraSetting.localOffset = Vector3.zero;
	--滑动屏幕时用于计算是水平运动还是垂直运动的角度
	GameCore.CameraSetting.dirDegree = ConfigData.GetValue("camera_config_dir_degree") or 60;

	--滑动屏幕时的旋转和缩放速度
	GameCore.CameraSetting.yawSpeed = ConfigData.GetValue("camera_config_yaw_speed") or 1;
	GameCore.CameraSetting.pitchSpeed = ConfigData.GetValue("camera_config_pitch_speed") or  2;
	GameCore.CameraSetting.zoomSpeed = ConfigData.GetValue("camera_config_zoom_speed") or  0.4;

	--滑动屏幕时的旋转阻尼系数
	GameCore.CameraSetting.yawDamping = ConfigData.GetValue("camera_config_yaw_damping") or 10;
	GameCore.CameraSetting.pitchDamping = ConfigData.GetValue("camera_config_pitch_damping") or 10;
	GameCore.CameraSetting.zoomDamping = ConfigData.GetValue("camera_config_zoom_damping") or 10;

	--跟随阻尼系数
	GameCore.CameraSetting.followYawDamping = ConfigData.GetValue("camera_config_follow_yaw_damping") or 0.4;
	GameCore.CameraSetting.followPosDamping = ConfigData.GetValue("camera_config_follow_pos_damping") or 4;
	GameCore.CameraSetting.recoverPosDamping = ConfigData.GetValue("camera_config_recover_pos_damping") or 4;

	--跟随开始角度
	GameCore.CameraSetting.followYawLimitMin = ConfigData.GetValue("camera_config_follow_yaw_limit_min") or 30;
	GameCore.CameraSetting.followYawLimitMax = ConfigData.GetValue("camera_config_follow_yaw_limit_max") or 150;
	GameCore.CameraSetting.followEnterLimitTime = ConfigData.GetValue("camera_config_follow_enter_limit_time") or 500;
    
	--碰撞层级
	GameCore.CameraSetting.alphaLayerMask = CameraLayer.CameraHitAlphaMaskLayer;
	GameCore.CameraSetting.hideLayerMask = CameraLayer.CameraHitHideMaskLayer;
	GameCore.CameraSetting.distanceLayerMask = CameraLayer.CameraHitDistanceMaskLayer;

	--碰撞偏移
	GameCore.CameraSetting.hitOffsetDistance = 1;
	GameCore.CameraSetting.hitOffsetSurface = 0.1;
	GameCore.CameraSetting.hitOffsetDistaceMin = -0.1;

	--俯仰角度上限和下限
	GameCore.CameraSetting.minPitch = ConfigData.GetValue("camera_config_pitch_min") or -30;
	GameCore.CameraSetting.maxPitch = ConfigData.GetValue("camera_config_pitch_max") or 75;

	--最远和最近观察距离
	GameCore.CameraSetting.minDistance = ConfigData.GetValue("camera_config_distance_min") or 2;
	GameCore.CameraSetting.maxDistance = ConfigData.GetValue("camera_config_distance_max") or 15;

	--默认观察角度
	GameCore.CameraSetting.defaultPitch = ConfigData.GetValue("camera_config_default_pitch") or 20;
	GameCore.CameraSetting.defaultYaw = ConfigData.GetValue("camera_config_default_yaw") or 0;
	GameCore.CameraSetting.defaultDistance = ConfigData.GetValue("camera_config_default_distance") or 13;
	--镜头控制脚本初始化
	local followTarget = mainPlayer:GetModelComponent():GetEntityRoot();
	GameCore.UtilCameraFollow.InitCamera(2,cameraObj.transform,followTarget);
end

--进入固定视角模式
function EnterFixedMode(pitch,yaw,distance,target)
	GameCore.UtilCameraFollow.SwitchState(0,pitch or -1,yaw or -1,distance or -1);
	if not tolua.isnull(target) then GameCore.UtilCameraFollow.UpdateTarget(target); end
end

--进入固定视角模式
function EnterFixedZoomMode(pitch,yaw,distance,target)
	GameCore.UtilCameraFollow.SwitchState(1,pitch or -1,yaw or -1,distance or -1);
	if not tolua.isnull(target) then GameCore.UtilCameraFollow.UpdateTarget(target); end
end

--进入自由视角模式
function EnterFreeMode(pitch,yaw,distance,target)
	GameCore.UtilCameraFollow.SwitchState(2,pitch or -1,yaw or -1,distance or -1);
	if not tolua.isnull(target) then GameCore.UtilCameraFollow.UpdateTarget(target); end
end

--进入自动跟随模式
function EnterFollowMode()
	GameCore.UtilCameraFollow.SwitchState(3,-1,-1,-1);
end

--进入默认视角模式,跟随玩家
function EnterDefaultMode()
    local defaultPitch = GameCore.CameraSetting.defaultPitch;
    local defaultYaw = GameCore.CameraSetting.defaultYaw;
    local defaultDistance = GameCore.CameraSetting.defaultDistance;
	GameCore.UtilCameraFollow.SwitchState(2,defaultPitch,defaultYaw,defaultDistance);
	local target = MapMgr.GetMainPlayer():GetModelComponent():GetEntityRoot();
	if not tolua.isnull(target) then GameCore.UtilCameraFollow.UpdateTarget(target); end
end

--是否处于跟随模式
function IsInFollowMode()
	return GameCore.UtilCameraFollow.IsInState(3);
end

return CameraFollowController;