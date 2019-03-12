AINodeMoveCustom = class("AINodeMoveCustom",AINodeBase);

function AINodeMoveCustom:ctor()
    AINodeBase.ctor(self);
end

function AINodeMoveCustom:dtor()
    AINodeBase.dtor(self);
end

--距离目标点是否足够近
function AINodeMoveCustom:IsInMinDistance(aiData)
    local distance = math.DistanceXZ(aiData.propertyComponent:GetPosition(),aiData.customMoveDest);
    if aiData.customMoveMinFlag then
        return distance <= 0.2;
    else
        return distance <= 1.5;
    end
end

--距离目标点是否足够远
function AINodeMoveCustom:IsInMaxDistance(aiData)
    local distance = math.DistanceXZ(aiData.propertyComponent:GetPosition(),aiData.customMoveDest);
    return distance >= 3;
end

function AINodeMoveCustom:OnStart(aiData)
    aiData.customMoveFlag = aiData.customMoveDest ~= nil;
end

function AINodeMoveCustom:OnUpdate(deltaTime,aiData)
    if not aiData.customMoveFlag then return BTDefine.NODE_STATUS.FAILURE; end
    --处于剧情或者对话中
    if UserData.IsInControl() then return end
    --不可移动状态
    if not aiData.stateComponent:CanMove() then return end
    --检查与目标点距离
    if self:IsInMinDistance(aiData) then
        self:OnMoveToPoint(aiData);
        return BTDefine.NODE_STATUS.SUCCESS;
    elseif not aiData.moveComponent:IsMoving() then
        if self:IsInMaxDistance(aiData) then
            aiData.moveComponent:MoveWithDest(aiData.customMoveDest);
            GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_PATHFINDING,aiData.customMoveDes);
            return BTDefine.NODE_STATUS.RUNNING;
        else
            self:OnMoveToPoint(aiData);
            return BTDefine.NODE_STATUS.SUCCESS;
        end
    else
        return BTDefine.NODE_STATUS.RUNNING;
    end
end

function AINodeMoveCustom:OnMoveToPoint(aiData)
    aiData.moveComponent:StopMove(0);
    if aiData.customMoveCallBack then
        local callBack = aiData.customMoveCallBack;
        local callObj = aiData.customMoveCallObj;
        self:OnClear(aiData);
        callBack(callObj);
    end
end

function AINodeMoveCustom:OnAbort(aiData)
    AINodeBase.OnAbort(self);
    self:OnClear(aiData);
end

function AINodeMoveCustom:OnClear(aiData)
    aiData.customMoveFlag = false;
    aiData.customMoveDest = nil;
    aiData.customMoveMinFlag = false;
    aiData.customMoveCallBack = nil;
    aiData.customMoveCallObj = nil;
end