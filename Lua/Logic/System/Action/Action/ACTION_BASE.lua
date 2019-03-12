ACTION_BASE = class("ACTION_BASE");

function ACTION_BASE:ctor(actionData,dynamicID,entityID)
    self._actionData = actionData;
    self._actionDone = false;
    self._dynamicID = dynamicID;
    self._entityID = entityID;
    self._actionDelayTime = 0;
end

function ACTION_BASE:OnUpdate(deltaTime)

end

function ACTION_BASE:OnDelay(deltaTime)
    self._actionDelayTime = self._actionDelayTime + deltaTime;
end

function ACTION_BASE:IsFinish()
    return self._actionDone;
end

function ACTION_BASE:IsDelayFinish()
    return self._actionDelayTime >= self._actionData.delayTime;
end