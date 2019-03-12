SACT_Base = class("SACT_Base") 

function SACT_Base:ctor(actionOwner,actionAtt)
    self._actionOwner = actionOwner;
    self._actionAtt = actionAtt;
    self._actionEntity = self._actionOwner._skillComponent._entity;
end

function SACT_Base:dtor()
    self:DoDestroyEffect();
end

function SACT_Base:OnCancel()
    self._start = false;
    self._stop = false;
    self:DoStopEffect();
end

function SACT_Base:OnUpdate(deltaTime,passedTime)
    if passedTime <= 0 then
        self._start = false;
        self._stop = false;
    end
    if not self._start then
        if self._actionAtt.startTime <= passedTime then 
            self._start = true;
            self:DoStartEffect(); 
        end
    elseif not self._stop then
        if self._actionAtt.duration == -1 then
            --没有持续时间,无限刷新
            self:DoUpdateEffect(deltaTime);
        elseif self._actionAtt.startTime + self._actionAtt.duration > passedTime then 
            --有持续时间并且尚未结束
            self:DoUpdateEffect(deltaTime);
        elseif not self._stop then
            --有持续时间已结束
            self._stop = true;
            self:DoStopEffect();
        end
    end
end

function SACT_Base:OnModelLoad()
    self:DoModelLoadEffect();
end

function SACT_Base:OnModelReplace()
    self:DoModelReplaceEffect();
end

function SACT_Base:DoAwakeEffect()

end

function SACT_Base:DoStartEffect()

end

function SACT_Base:DoUpdateEffect(deltaTime)

end

function SACT_Base:DoStopEffect()

end

function SACT_Base:DoDestroyEffect()

end

function SACT_Base:DoModelLoadEffect()

end

function SACT_Base:DoModelReplaceEffect()

end

return SACT_Base;

