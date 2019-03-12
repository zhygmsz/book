AActionGroup = class("AActionGroup");

function AActionGroup:ctor(actionComponent)
    self._actions = self._actions or {};
    self._entity = actionComponent._entity;
    self._actionComponent = actionComponent;
    self._totalTime = 0;
    self._passedTime = 0;
    self._actionActive = false;
end

function AActionGroup:ReleaseAction()
    for idx,action in ipairs(self._actions) do
        AActionFactory.DestroyAction(action);
        self._actions[idx] = nil;
    end
end

function AActionGroup:CreateAction(animationData,attacker)
    if not animationData then return end
    for _,actionData in ipairs(animationData.actions) do
        local action = AActionFactory.CreateAction(actionData,animationData,self._actionComponent._entity,attacker);
        if action then
            self._actions[#self._actions + 1] = action;
        else
            GameLog.LogError("anim action is null %s",actionData.actionType);
        end
        self._totalTime = math.max(self._totalTime,actionData.duration + actionData.delayTime);
    end
end

function AActionGroup:RandomAnimation(animGroupID)
    if not animGroupID then return nil; end
    if animGroupID < -1 then return AnimationData.GetAnimationInfo(-animGroupID); end
    local anims = AnimationData.GetAnimationGroup(animGroupID);
    if not anims then return nil; end
    if #anims == 1 then return anims[1]; end
    local weights = table.tmpEmptyTable();
    local totalWeight = 0;
    for _,animData in ipairs(anims) do
        totalWeight = totalWeight + animData.weight;
        weights[#weights + 1] = totalWeight;
    end
    local randomValue = math.random(1,totalWeight);
    for idx,weight in ipairs(weights) do
        if randomValue <= weight then return anims[idx]; end
    end
end

function AActionGroup:OnStart(groupIDSelf,groupIDOther,froceStart,...)
    if not self._repeatActive then self._repeatFlag = false; end
    if self._actionActive and not froceStart then return false; end
    local animationDataSelf = self:RandomAnimation(groupIDSelf);
    local animationDataOther = self:RandomAnimation(groupIDOther);
    if animationDataSelf then
        --回收旧的表现资源
        self:ReleaseAction();
        --创建新的表现资源     
        self:CreateAction(animationDataSelf,...);
        self:CreateAction(animationDataOther,...);
        self._passedTime = 0;
        self._actionActive = true;
        return true,self._totalTime;
    else
        self:OnStop();
        return false;
    end
end

function AActionGroup:OnStartRepeat(groupIDSelf,repeatCount,repeatDelta)
    self._repeatFlag = true;
    self._repeatGroup = groupIDSelf;
    self._repeatCount = repeatCount;
    self._repeatDelta = repeatDelta;
    self._repeatActive = true;
    self:OnStart(groupIDSelf,-1,true);
    self._repeatActive = false;
end

function AActionGroup:OnUpdate(deltaTime)
    if not self._actionActive then return end
    if self._totalTime <= self._passedTime then
        self:OnStop();
    else
        self._passedTime = self._passedTime + deltaTime;
        for _,action in ipairs(self._actions) do
            action:OnUpdate(deltaTime);
        end
        if self._repeatFlag and self._passedTime >= self._repeatDelta then
            local leftCount = self._repeatCount - 1;
            if leftCount > 0 then
                self:OnStartRepeat(self._repeatGroup,leftCount,self._repeatDelta);
            end
        end
    end
end

function AActionGroup:OnStop()
    self._actionActive = false;
    self:ReleaseAction();
    if self._entity:IsNPC() and self._entity:IsDead() then
        MapMgr.DestroyEntity(self._entity:GetType(),self._entity:GetID());
    end
end

function AActionGroup:OnCancel()
    if self._actionActive then self:OnStop(); end
end

function AActionGroup:OnDestroy()
    self:ReleaseAction();
end