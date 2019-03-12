FACT_Follow = class("FACT_Follow",FACT_Base);

function FACT_Follow:ctor(...)
    FACT_Base.ctor(self,...);
end

function FACT_Follow:DoStartEffect()
    --跟随目标
    if self._pathData.basePoint == Skill_pb.SkillPath.TARGET then
        self._followTarget = self._actionEntity._entityAtt.target;
    elseif self._pathData.basePoint == Skill_pb.SkillPath.SELF then
        self._followTarget = self._actionEntity._entityAtt.caster;
    end
    --跟随状态
    self._followFinish = false;
    self._followSpeed = self._pathData.args[1].floatValue * 0.001;
    --跟随初始点和初始朝向
    local propertyComponent = self._actionEntity._entityAtt.caster:GetPropertyComponent()
    self._actionEntity:GetPropertyComponent():SetPosition(propertyComponent:GetPosition(true));
    self._actionEntity:GetPropertyComponent():SetForward(propertyComponent:GetForward(true));
end

function FACT_Follow:DoUpdateEffect(deltaTime)
    if not self._followFinish then
        if not self._followTarget or not self._followTarget.IsValid or not self._followTarget:IsValid() then
            self._followFinish = true;
        elseif self._pathData.basePoint == Skill_pb.SkillPath.SELF then
            self:FollowSelf();
        elseif self._pathData.basePoint == Skill_pb.SkillPath.TARGET then
            self:FollowTarget(deltaTime);
        end
    end
end

function FACT_Follow:FollowSelf()
    if self._followTarget then
        local propertyComponent = self._followTarget:GetPropertyComponent()
        self._actionEntity:GetPropertyComponent():SetPosition(propertyComponent:GetPosition(true));
        self._actionEntity:GetPropertyComponent():SetForward(propertyComponent:GetForward(true));
    end
end

function FACT_Follow:FollowTarget(deltaTime)
    local targetPosition = self._followTarget:GetPropertyComponent():GetPosition();
    local selfPosition = self._actionEntity:GetPropertyComponent():GetPosition();
    local followDirection = targetPosition - selfPosition;
    if followDirection.x ~= 0 or followDirection.z ~= 0 then
        followDirection.y = 0;
        local oldDistance = followDirection.magnitude; 
        followDirection:SetNormalize();

        local deltaMove = followDirection * deltaTime * self._followSpeed;
        local deltaDistance = deltaMove.magnitude;
        self._actionEntity:GetPropertyComponent():SetPosition(selfPosition + deltaMove);
        self._followFinish = deltaDistance >= oldDistance;
        if not self._followFinish then
            self._actionEntity:GetPropertyComponent():LookTarget(targetPosition);
        end
    else
        self._followFinish = true;
    end
end

function FACT_Follow:IsFinish()
    return self._followFinish;
end

return FACT_Follow;