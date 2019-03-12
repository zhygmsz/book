module("CameraEffectController",package.seeall)

local mDamageAtlas = nil;
local mDamageShader = nil;
local mCameraObj = nil;
local mCameraEffects = {};

local function CreateEffects(effectType,effectPath)
	mCameraEffects[effectType] = require(effectPath).new()
end

function InitModule()
	local CETYPE = CameraDefine.CAMERA_EFFECT;
	CreateEffects(CETYPE.CE_WATER_WAVE,"Logic/Presenter/Camera/Effect/CameraEffect_WaterWave")
end

function InitCamera(mainPlayer,cameraObj)
	mCameraObj = cameraObj;
    --实时阴影
	-- local shadowTarget = mainPlayer:GetModelComponent():GetEntityRoot();
	-- local shadowQuality = 1024;
	-- local shadowCasterLayer = CameraLayer.ShadowCasterMaskLayer;
	-- local shadowIgnoreLayer = CameraLayer.IgnoreShadowLayer;
	-- local shadowDistance = 10;
	-- local shadowShader = CommonData.FindShader("Assets/Shader/Program/EntityShadow.shader","GameEffects/EntityShadow");
    -- GameCore.EntityShadow.EnableShadow(shadowTarget,shadowQuality,shadowCasterLayer,shadowIgnoreLayer,shadowDistance,shadowShader);
end

--播放摄像机效果
function PlayCameraEffect(effectType,...)
	local effect = mCameraEffects[effectType];
	if effect ~= nil then
		effect:Play(mCameraObj,...);
	else
		GameLog.LogError("can't find camera effect %s",effectType);
	end
end

--停止播放摄像机效果
function StopCameraEffect(effectType,...)
	local effect = mCameraEffects[effectType];
	if effect ~= nil then
		effect:Stop(mCameraObj,...);
	else
		GameLog.LogError("can't find camera effect %s",effectType);
	end
end

return CameraEffectController;