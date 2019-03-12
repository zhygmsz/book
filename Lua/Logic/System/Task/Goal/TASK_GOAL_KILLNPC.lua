TASK_GOAL_KILLNPC = class("TASK_GOAL_KILLNPC",TASK_GOAL_BASE);

function TASK_GOAL_KILLNPC:ctor(...)
    TASK_GOAL_BASE.ctor(self,...);
end

function TASK_GOAL_KILLNPC:OnStart()
    TASK_GOAL_BASE.OnStart(self);
    self._moveFinish = false;
    self._mapUnitID = self._goalConditionParams[1];
    local conditionType = self._goalDynamicData.staticData.condition.conditionType;
    if conditionType == Condition_pb.FIGHT_NPC_KILL then
        self._npcUnitID = self._goalConditionParams[2];
        self:MoveToPoint(self._mapUnitID,MapMgr.GetNPCPoint(self._mapUnitID,self._npcUnitID),false);
    elseif conditionType == Condition_pb.FIGHT_NPC_GROUP_DEAD then
        self._npcGroupID = self._goalConditionParams[2];
        self:MoveToPoint(self._mapUnitID,MapMgr.GetNPCGroupPoint(self._mapUnitID,self._npcGroupID),false);
    else
        TipsMgr.TipByKey("task_can_not_auto_execute");
    end
end

function TASK_GOAL_KILLNPC:OnStop()
    TASK_GOAL_BASE.OnStop(self);
end

function TASK_GOAL_KILLNPC:OnMoveToPoint()
    TASK_GOAL_BASE.OnMoveToPoint(self);
    self._moveFinish = true;
    UserData.SetAutoFight(true,"TASK_AUTO");
end

function TASK_GOAL_KILLNPC:IsFinish()
    return self._moveFinish;
end

function TASK_GOAL_KILLNPC:IsExecuting()
    local mainPlayer = MapMgr.GetMainPlayer();
    if not self._moveFinish and mainPlayer and mainPlayer:GetMoveComponent():IsMoving() then return true; end
    return UserData.GetAutoFight();
end