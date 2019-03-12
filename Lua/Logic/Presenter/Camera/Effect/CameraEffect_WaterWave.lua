CameraEffect_WaterWave = class("CameraEffect_WaterWave")

function CameraEffect_WaterWave:ctor()
    self._waveShader = CommonData.FindShader("Assets/Shader/Program/CameraEffect_WaterWave.shader","CameraEffects/WaterWave");
    local waterWaveA_A = 1.0;
    local waterWaveA_B = 0.1;

    local waterWaveW_A = 55;
    local waterWaveW_B = 12;

    local waterWaveR_B = 0.7;
    local waterWaveR_C = 0.2;

    GameCore.CameraEffect_WaterWave.Init(self._waveShader,waterWaveA_A,waterWaveA_B,waterWaveW_A,waterWaveW_B,waterWaveR_B,waterWaveR_C)
end

function CameraEffect_WaterWave:Play(cameraObj,duration)
    GameCore.CameraEffect_WaterWave.Play(UIMgr.GetCameraGo(),duration);
end

function CameraEffect_WaterWave:Stop(cameraObj)
    GameCore.CameraEffect_WaterWave.Stop(UIMgr.GetCameraGo());
end

return CameraEffect_WaterWave;