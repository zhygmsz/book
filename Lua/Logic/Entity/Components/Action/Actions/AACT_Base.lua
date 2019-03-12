AACT_Base = class("AACT_Base");

function AACT_Base:ctor(actionData,animData,entity,attacker)
    self._animData = animData;
    self._actionData = actionData;
    self._actionArgs = actionData.args;
    self._actionEntity = entity;
    self._attacker = attacker;
    self._passedTime = 0;
    self._totalTime = actionData.duration;
    self._delayTime = actionData.delayTime;
    self._start = false;
    self._stop = false;
end

function AACT_Base:dtor()
    if self._start and not self._stop then
        self._stop = true;
        self:DoStopEffect();
    end
end

function AACT_Base:OnUpdate(deltaTime)
    if self._stop then return end
    self._passedTime = self._passedTime + deltaTime;
    if not self._start then
        if self._delayTime <= self._passedTime then
            self._start = true;
            self._passedTime = 0;
            self:DoStartEffect();
        end
    else
        if self._totalTime <= self._passedTime then
            self._stop = true;
            self:DoStopEffect();
        else
            self:DoUpdateEffect();
        end
    end
end

function AACT_Base:DoStartEffect()
end

function AACT_Base:DoUpdateEffect()
end

function AACT_Base:DoStopEffect()
end