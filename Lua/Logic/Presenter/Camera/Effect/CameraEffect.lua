module("CameraEffect",package.seeall)

local mUUID = 0;
local function GENID()
    mUUID = mUUID + 1;
    return mUUID;
end

--对话镜头效果
CE_DIALOG_LOOK = GENID();
--对话模糊效果
CE_GAUSS_BLUR = GENID();
--淡入淡出效果
CE_BRIGHTNESS =  GENID();

local EFFECT_TYPE = 
{
    BRIGHTNESS  = 2,
}
--特效创建方法
local mEffectCreaters = {};

--相机对象对应的特效字典
local camObjEffects = {};

local function RegisterEffect(effectPath,effectType,typeofscript)
    local effect = require(effectPath);
    if effectType then mEffectCreaters[effectType] = {
        ctor=effect.new,
        script=typeofscript
    }; end
end

--==============================--
--desc:
--time:2018-09-21 12:08:56
--@effectType:EFFECT_TYPE 特效类型
--@cameraObj:相机GameObject
--@return 
--==============================--
local function CreateEffect(effectType,cameraObj,...)
    local key = cameraObj:GetHashCode()
    if camObjEffects[key] and camObjEffects[key][effectType] then
        return camObjEffects[key][effectType]
    end
    if camObjEffects[key]==nil then
        camObjEffects[key]={}
    end
    local ctor = mEffectCreaters[effectType].ctor
    local script = mEffectCreaters[effectType].script
    local effect = cameraObj:AddComponent(script)
    camObjEffects[key][effectType] = ctor(cameraObj,effect,...)
    return camObjEffects[key][effectType]
end

function InitModule()
    RegisterEffect("Logic/Presenter/Camera/Effect/CameraEffect_Brightness",EFFECT_TYPE.BRIGHTNESS,typeof(CameraEffect_Brightness));
end

function Brightness(func,obj)
    return CreateEffect(EFFECT_TYPE.BRIGHTNESS,CameraMgr.GetMainCameraObj(), func, obj); 
end

function BrightnessWithCamGO(camGO,func,obj)
    return CreateEffect(EFFECT_TYPE.BRIGHTNESS,camGO, func, obj);
end

return CameraEffect
