TASK_GOAL_MAP = class("TASK_GOAL_MAP",TASK_GOAL_BASE);

function TASK_GOAL_MAP:ctor(...)
    TASK_GOAL_BASE.ctor(self,...);
    self._mapUnitID = self._goalConditionParams[1];
end

function TASK_GOAL_MAP:OnStart()
    TASK_GOAL_BASE.OnStart(self);
    self._mapEntering = true;
    GameEvent.Reg(EVT.MAPEVENT,EVT.MAP_ENTER_MSG_RET,self.OnEnterMap,self);
    MapMgr.RequestEnterMap(-1,self._mapUnitID,-1);
end

function TASK_GOAL_MAP:IsFinish()
    return self._mapUnitID == MapMgr.GetMapUnitID();
end

function TASK_GOAL_MAP:IsExecuting()
    return self._mapEntering;
end

function TASK_GOAL_MAP:OnEnterMap()
    GameEvent.UnReg(EVT.MAPEVENT,EVT.MAP_ENTER_MSG_RET,self.OnEnterMap,self);
    self._mapEntering = false;
end