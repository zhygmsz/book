TASK_GOAL_DIALOG = class("TASK_GOAL_DIALOG",TASK_GOAL_BASE);

function TASK_GOAL_DIALOG:ctor(...)
    TASK_GOAL_BASE.ctor(self,...);
end

function TASK_GOAL_DIALOG:OnStart()
    TASK_GOAL_BASE.OnStart(self);
    self._param = self._param or {};
    if self._taskDynamicData.staticData.minorType == Quest_pb.QuestInfo.RANDOM_ENTER then
        local task1 = QuestData.GetData(self._goalDynamicData.extraData.selectQuests[1]);
        local task2 = QuestData.GetData(self._goalDynamicData.extraData.selectQuests[2]);
        local task3 = QuestData.GetData(self._goalDynamicData.extraData.selectQuests[3]);
        self._param.contentList = self._param.contentList or {};
        self._param.contentList[1] = task1 and task1.acceptDes or "";
        self._param.contentList[2] = task2 and task2.acceptDes or "";
        self._param.contentList[3] = task3 and task3.acceptDes or "";

        self._mapUnitID = self._goalConditionParams[6];
        self._npcUnitID = self._goalConditionParams[7];
        self._dialogGroupID = self._goalConditionParams[5];
    else
        self._mapUnitID = self._goalConditionParams[1];
        self._npcUnitID = self._goalConditionParams[2];
        self._dialogGroupID = self._goalConditionParams[3];
    end
    self._param.dialogGroupID = self._dialogGroupID;
    self._moveFinish = false;
    if self._npcUnitID ~= -1 then
        self:MoveToPoint(self._mapUnitID,MapMgr.GetNPCPoint(self._mapUnitID,self._npcUnitID),false);
    else
        self:OnMoveToPoint();
    end
end

function TASK_GOAL_DIALOG:OnMoveToPoint()
    TASK_GOAL_BASE.OnMoveToPoint(self);
    self._moveFinish = true;
    GameEvent.Trigger(EVT.STORY,EVT.DIALOG_OPEN,self._param);
end

function TASK_GOAL_DIALOG:IsFinish()
    return self._moveFinish;
end

function TASK_GOAL_DIALOG:IsExecuting()
    if self._npcUnitID ~= -1 then
        local mainPlayer = MapMgr.GetMainPlayer();
        if not self._moveFinish and mainPlayer and mainPlayer:GetMoveComponent():IsMoving() then return true; end
    else
        return true;
    end
end