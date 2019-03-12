SACT_CameraShake = class("SACT_CameraShake",SACT_Base)

function SACT_CameraShake:ctor(...)
    SACT_Base.ctor(self,...);
    --时间
    self._shakeT = self._actionAtt.duration;
    --振幅
    self._shakeA = self._actionAtt.args[1].vector3Value;
    --频率
    self._shakeF = self._actionAtt.args[2].vector3Value;
    --简化访问
    self._shakeAX = self._shakeA.x * 0.01;
    self._shakeAY = self._shakeA.y * 0.01;
    self._shakeFX = self._shakeF.x * 0.001;
    self._shakeFY = self._shakeF.y * 0.001;
    self._shakeOffset = Vector3.zero;
end

function SACT_CameraShake:DoStartEffect()
    self._passedTime = 0;
end

function SACT_CameraShake:DoUpdateEffect(deltaTime)
    self._passedTime = self._passedTime + deltaTime;
    self._shakeOffset.x = self._shakeAX * math.sin(self._shakeFX * self._passedTime);
    self._shakeOffset.y = self._shakeAY * math.sin(self._shakeFY * self._passedTime);
    GameCore.CameraSetting.localOffset = self._shakeOffset;
end

function SACT_CameraShake:DoStopEffect()
    GameCore.CameraSetting.localOffset = Vector3.zero;
end

function SACT_CameraShake:DoDestroyEffect()
    GameCore.CameraSetting.localOffset = Vector3.zero;
end

return SACT_CameraShake;