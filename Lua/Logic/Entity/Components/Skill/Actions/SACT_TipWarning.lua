SACT_TipWarning = class("SACT_TipWarning",SACT_Base)

function SACT_TipWarning:ctor(...)
    SACT_Base.ctor(self,...);
    self._warnDuration = self._actionAtt.duration;
    self._warnType = self._actionAtt.args[1].intValue;
    self._warnArg1 = self._actionAtt.args[2].floatValue;
    self._warnArg2 = self._actionAtt.args[3].floatValue;
    self._warnArg3 = self._actionAtt.args[4].floatValue;
    self._warnArg4 = math.ConvertProtoV3(self._actionAtt.args[5].vector3Value);
    self._warnID = -1;
end

function SACT_TipWarning:DoStartEffect()
    local propertyComponent = self._actionEntity:GetPropertyComponent()
    local position = propertyComponent:GetPosition() + self._warnArg4;
    local forward = propertyComponent:GetForward();
    self._warnID = EffectWarnning.EnableWarnning(self._warnType,position,forward,self._warnDuration,self._warnArg1,self._warnArg2,self._warnArg3);
    self._passedTime = 0;
end

function SACT_TipWarning:DoUpdateEffect(deltaTime)
    self._passedTime = self._passedTime + deltaTime;
    EffectWarnning.UpdateWarnning(self._warnID,self._passedTime * 0.001);
end

function SACT_TipWarning:DoStopEffect()
    EffectWarnning.DisableWarnning(self._warnID);
end

function SACT_TipWarning:DoDestroyEffect()
    EffectWarnning.DisableWarnning(self._warnID);
end

return SACT_TipWarning;