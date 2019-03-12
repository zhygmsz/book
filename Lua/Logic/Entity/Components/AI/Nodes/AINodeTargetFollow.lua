AINodeTargetFollow = class("AINodeTargetFollow",AINodeBase);

function AINodeTargetFollow:ctor()
    AINodeBase.ctor(self);
end

function AINodeTargetFollow:dtor()
    AINodeBase.dtor(self);
end

function AINodeTargetFollow:OnStart(aiData)
    self._followPosition = Vector3.zero;
    self._followFailFlag = false;
end

function AINodeTargetFollow:OnUpdate(deltaTime,aiData)
    if self:FollowTarget(aiData) then
        --目标死亡
        if aiData.skillTarget and aiData.skillTarget.IsValid and not aiData.skillTarget:IsValid() then
            return BTDefine.NODE_STATUS.FAILURE;
        end
        --追击成功
        if aiData.skillData.castType == SkillInfo_pb.SkillInfo.TARGET_POINT and aiData.skillTarget then
            aiData.skillTarget = aiData.skillTarget.IsValid and aiData.skillTarget:GetPropertyComponent():GetPosition() or aiData.skillTarget;
        end
        return BTDefine.NODE_STATUS.SUCCESS;
    elseif self._followFailFlag then
        --追击失败
        return BTDefine.NODE_STATUS.FAILURE;
    else
        --追击中
        return BTDefine.NODE_STATUS.RUNNING;
    end
end

function AINodeTargetFollow:FollowTarget(aiData)
    --没有目标
    if aiData.skillTarget == nil then return true; end
    --目标是一个点
    if not aiData.skillTarget.IsValid then return true; end
    --目标是一个实体对象
    local casterPosition = aiData.propertyComponent:GetPosition();
    --检查是否离开了挂机范围
    if UserData.GetAutoFight() and UserData.GetAutoSkillFollowFlag() then
        if math.DistanceXZ(casterPosition,aiData.autoFightPosition) >= aiData.AUTOFIGHT_DISTANCE then
            aiData.aiComponent:ResetAI();
            self._followFailFlag = true;
            return false;
        end
    end
    --检查目标是否在攻击距离内
    local targetPosition = aiData.skillTarget:GetPropertyComponent():GetPosition(true);
    local distance = math.DistanceXZ(targetPosition,casterPosition);
    if distance >= aiData.skillUnitData.castingDistance then
        --目标丢失
        if aiData.LOSS_DISTANCE <= distance then
            self._followFailFlag = true;
            self:OnFail("entity_skill_target_loss",aiData);
            return false;
        end
        --禁止移动
        if not aiData.stateComponent:CanMove() then return false; end
        --距离补偿
        if not self._followPosition:Equals(targetPosition) then
            self._followPosition = targetPosition;
            aiData.moveComponent:MoveWithDest(targetPosition);
        end
        if not aiData.moveComponent:IsMoving() then
            self._followPosition = targetPosition;
            aiData.moveComponent:MoveWithDest(targetPosition);
        end
        if not aiData.moveComponent:IsMoving() then
            return true;
        end
        return false;
    else
        return true;
    end
end