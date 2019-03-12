ActionGroup = class("ActionGroup")

function ActionGroup:ctor(actionDatas,serialFlag,groupID,dynamicID,entityID)
    self._groupID = groupID;
    self._serialFlag = serialFlag;
    self._dynamicID = dynamicID;
    self._entityID = entityID;
    self._actions = self._actions or {};
    for _,actionData in ipairs(actionDatas) do
        local action = ActionFactory.CreateAction(actionData);
        if action then
            self._actions[#self._actions + 1] = action;
        else
            GameLog.LogError("client action undefine %s",actionData.actionType);
        end
    end
    self._allFinish = false;
end

function ActionGroup:dtor()
    for idx,action in ipairs(self._actions) do
        ActionFactory.DestroyAction(action);
        self._actions[idx] = nil;
    end
end

function ActionGroup:OnUpdate(deltaTime)
    self._allFinish = true;
    if self._serialFlag then
        --串行组
        for actionIndex,action in ipairs(self._actions) do
            if action:IsDelayFinish() then
                if not action:IsFinish() then
                    action:OnUpdate(deltaTime);
                end
                if not action:IsFinish() then
                    self._allFinish = false;
                    break;
                end
            else
                action:OnDelay(deltaTime);
                self._allFinish = false;
                break;
            end
        end
    else
        --并行组
        for actionIndex,action in ipairs(self._actions) do
            if action:IsDelayFinish() then
                if not action:IsFinish() then
                    action:OnUpdate(deltaTime);
                end
                if not action:IsFinish() then
                    self._allFinish = false;
                end
            else
                action:OnDelay(deltaTime);
                self._allFinish = false;
            end
        end
    end
end

function ActionGroup:IsFinish()
    return self._allFinish;
end