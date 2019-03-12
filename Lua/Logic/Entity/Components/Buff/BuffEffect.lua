BuffEffect = class("BuffEffect");

local TICK_TYPE = StatusInfo_pb.StatusEffect;

function BuffEffect:ctor(buffGroup,effectData)
    self._buffGroup = buffGroup;
    self._effectData = effectData;
    self._leftCount = self._effectData.count;
    self._leftTime = self._effectData.interval;
    self._tickType = self._effectData.tickType;
    self._stop = false;
    self:DoStartEffect();
end

function BuffEffect:dtor()
    if not self._stop then self:DoStopEffect(); end
end

function BuffEffect:OnUpdate(deltaTime)
    if not self._stop then
        self._leftTime = self._leftTime - deltaTime;
        self:DoUpdateEffect(deltaTime);
        if self._tickType == TICK_TYPE.INSTANT then
            --瞬时效果
            self._stop = true;
        elseif self._tickType == TICK_TYPE.UNLIMITED_TIME then 
            --无限时间
        elseif self._tickType == TICK_TYPE.ONLY_TIME then
            --持续一段时间
            self._stop = self._leftTime <= 0;
        elseif self._tickType == TICK_TYPE.TIME_WITH_UNLIMITED_COUNT then
            --周期性无限次
            if self._leftTime <= 0 then
                self:DoIntervalEffect();
                self._leftTime = self._effectData.interval;
            end
        elseif self._tickType == TICK_TYPE.TIME_WITH_LIMITED_COUNT then
            --周期性有限次
            if self._leftTime <= 0 then
                self:DoIntervalEffect();
                self._leftCount = self._leftCount - 1;
                self._leftTime = self._effectData.interval;
                self._stop = self._leftCount <= 0;
            end
        end
        if self._stop then self:DoStopEffect(); end
    end
end

function BuffEffect:DoStartEffect()
end

function BuffEffect:DoUpdateEffect(deltaTime)
end

function BuffEffect:DoIntervalEffect()
end

function BuffEffect:DoStopEffect()
end

function BuffEffect:IsFinished()
    return self._stop;
end

function BuffEffect:GetLeftTime()
    if self._stop then
        --已经结束
        return 0;
    elseif self._tickType == TICK_TYPE.INSTANT then
        --瞬时效果
        return 0;
    elseif self._tickType == TICK_TYPE.UNLIMITED_TIME then 
        --无限时间
        return -1;
    elseif self._tickType == TICK_TYPE.ONLY_TIME then
        --持续一段时间
        return self._leftTime;
    elseif self._tickType == TICK_TYPE.TIME_WITH_UNLIMITED_COUNT then
        --周期性无限次
        return -1;
    elseif self._tickType == TICK_TYPE.TIME_WITH_LIMITED_COUNT then
        --周期性有限次
        return self._leftCount * self._effectData.interval - self._effectData.interval + self._leftTime;
    end
end

function BuffEffect:SetLeftTime(passedTime,lastTime)
    if self._tickType == TICK_TYPE.ONLY_TIME then
        self._leftTime = lastTime - passedTime;
    else
        GameLog.LogError("buff tick type isn't ONLY_TIME",self._effectData.id);
    end
end