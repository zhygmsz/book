local CameraEffectBase = class("CameraEffectBase");

function CameraEffectBase:ctor(camGo,eff)
    self._camObj = camGo
	self._camEff = eff;
end

function CameraEffectBase:Instantiate()
    self._camObj = camGo
	self._camEff = eff;
end

return CameraEffectBase;
