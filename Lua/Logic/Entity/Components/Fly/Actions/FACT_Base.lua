FACT_Base = class("FACT_Base");

function FACT_Base:ctor(pathData,flyComponent)
    self._pathData = pathData;
    self._actionEntity = flyComponent._entity;
    self._passedTime = 0;
    self._lateUpdate = true;
    self:DoStartEffect();
end

function FACT_Base:dtor()
end

function FACT_Base:OnUpdate(deltaTime)
    if not self._lateUpdate then self:DoUpdate(deltaTime); end
end

function FACT_Base:OnLateUpdate(deltaTime)
    if self._lateUpdate then self:DoUpdate(deltaTime); end
end

function FACT_Base:DoUpdate(deltaTime)
    if not self:IsFinish() then
        self._passedTime = self._passedTime + deltaTime;
        self:DoUpdateEffect(deltaTime);
        if self:IsFinish() then self:DoStopEffect(); end
    end
end

function FACT_Base:DoStartEffect()
    self._followTarget = self._actionEntity._entityAtt.target;
end

function FACT_Base:DoUpdateEffect(deltaTime)
end

function FACT_Base:DoLateUpdateEffect(deltaTime)
end

function FACT_Base:DoStopEffect()
    if self._actionEntity:IsBullet() then 
        MapMgr.DestroyEntity(self._actionEntity:GetType(),self._actionEntity:GetID()); 
    end
end

function FACT_Base:IsFinish()
    return false;
end

return FACT_Base;