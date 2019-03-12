TASK_GOAL_MOVE = class("TASK_GOAL_MOVE",TASK_GOAL_BASE);

function TASK_GOAL_MOVE:ctor(...)
    TASK_GOAL_BASE.ctor(self,...);
end

function TASK_GOAL_MOVE:OnStart()
    TASK_GOAL_BASE.OnStart(self);
    self._mapUnitID = self._goalConditionParams[1];
    self._mapAreaID = self._goalConditionParams[2];
    self._moveFinish = false;
    self:MoveToPoint(self._mapUnitID,MapMgr.GetAreaPoint(self._mapUnitID,self._mapAreaID),true);
end

function TASK_GOAL_MOVE:OnMoveToPoint()
    TASK_GOAL_BASE.OnMoveToPoint(self);
    self._moveFinish = true;
end

function TASK_GOAL_MOVE:IsFinish()
    return self._moveFinish;
end

function TASK_GOAL_MOVE:IsExecuting()
    local mainPlayer = MapMgr.GetMainPlayer();
    if not self._moveFinish and mainPlayer and mainPlayer:GetMoveComponent():IsMoving() then return true; end
end