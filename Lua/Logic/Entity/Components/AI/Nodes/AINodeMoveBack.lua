AINodeMoveBack = class("AINodeMoveBack",AINodeBase);

function AINodeMoveBack:ctor()
    AINodeBase.ctor(self);
end

function AINodeMoveBack:dtor()
    AINodeBase.dtor(self);
end

function AINodeMoveBack:OnStart(aiData)
    
end

function AINodeMoveBack:OnUpdate(deltaTime,aiData)
    --不在自动战斗
    if not UserData.GetAutoFight() then return BTDefine.NODE_STATUS.FAILURE; end
    --不可控制状态
    if UserData.IsInControl() then return BTDefine.NODE_STATUS.FAILURE; end
    --支持追击敌人
    if UserData.GetAutoSkillFollowFlag() then return BTDefine.NODE_STATUS.FAILURE; end
    --不可移动状态
    if not aiData.stateComponent:CanMove() then return BTDefine.NODE_STATUS.FAILURE; end
    --检查与目标点距离
    local distance = math.DistanceXZ(aiData.propertyComponent:GetPosition(),aiData.autoFightPosition);
    if distance >= aiData.AUTOFIGHT_DISTANCE then
        --离开了挂机范围
        aiData.backFlag = true;
        if not aiData.moveComponent:IsMoving() then aiData.moveComponent:MoveWithDest(aiData.autoFightPosition); end
        return BTDefine.NODE_STATUS.RUNNING;
    elseif aiData.backFlag then
        --正在前往挂机点
        if not aiData.moveComponent:IsMoving() then
            if distance > 3 then
                --距离挂机点很远
                aiData.moveComponent:MoveWithDest(aiData.autoFightPosition);
            else
                --成功返回挂机点
                aiData.backFlag = false;
                return BTDefine.NODE_STATUS.SUCCESS;
            end
        end
        return BTDefine.NODE_STATUS.RUNNING;
    else
        --在挂机点范围内
        return BTDefine.NODE_STATUS.FAILURE;
    end
end

function AINodeMoveBack:OnAbort(aiData)
    AINodeBase.OnAbort(self);
    aiData.backFlag = false;
end