AACT_PlayHitEffect = class("AACT_PlayHitEffect",AACT_Base);

function AACT_PlayHitEffect:ctor(...)
    AACT_Base.ctor(self,...);
    self._hitMaxValue = self._actionArgs[1].intValue * 0.001;
    self._hitDuration = self._totalTime;
    self._hitDurationHalf = self._totalTime * 0.5;
    self._modelComponent = self._actionEntity:GetModelComponent();
    self._hitDeltaValue = self._hitMaxValue / self._hitDurationHalf;
end

function AACT_PlayHitEffect:DoStartEffect()
end

function AACT_PlayHitEffect:DoUpdateEffect()
    if self._passedTime <= self._hitDurationHalf then
        self._modelComponent:PlayHit(self._hitDeltaValue * self._passedTime);
    else
        self._modelComponent:PlayHit(self._hitMaxValue - self._hitDeltaValue * (self._passedTime - self._hitDurationHalf));
    end
end

function AACT_PlayHitEffect:DoStopEffect()
    self._modelComponent:PlayHit(0);
end

return AACT_PlayHitEffect;