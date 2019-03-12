TASK_GOAL_BASE = class("TASK_GOAL_BASE");

function TASK_GOAL_BASE:ctor(goalConditionType,goalDynamicData,taskDynamicData)
    self._goalConditionType = goalConditionType;
    self._goalDynamicData = goalDynamicData;
    self._taskDynamicData = taskDynamicData;
    self._goalConditionParams = goalDynamicData and goalDynamicData.staticData.condition.params or nil;
end

function TASK_GOAL_BASE:OnStart()
end

function TASK_GOAL_BASE:OnStop()
    local mainPlayer = MapMgr.GetMainPlayer();
    if mainPlayer and mainPlayer:GetMoveComponent():IsMoving() then
        mainPlayer:GetAIComponent():ResetAI();
    end
end

function TASK_GOAL_BASE:OnUpdate()
    --不需要移动
    if not self._moveToPointFlag then return end
    --不在目标地图
    if self._moveDestMapUnitID ~= MapMgr.GetMapUnitID() then return end
    --加载过程中
    if not GameStateMgr.GetState():IsEnterFinish() then return end
    --处于剧情或者对话中
    if UserData.IsInControl() then return end
    --朝目标移动
    MapMgr.GetMainPlayer():GetAIComponent():MoveWithCallBack(true,self._moveDestPoint,self._moveDes,self.OnMoveToPoint,self,self._needMinDistance);
end

function TASK_GOAL_BASE:OnMoveToPoint()
    self._moveToPointFlag = false;
end

function TASK_GOAL_BASE:MoveToPoint(mapUnitID,destPoint,needMinDistance)
    if not destPoint or not mapUnitID or not MapMgr.GetMainPlayer() then
        self._moveToPointFlag = false;
        TipsMgr.TipByKey("task_move_fail");
    else
        self._moveToPointFlag = true;
        self._moveDestMapUnitID = mapUnitID;
        self._moveDestPoint = destPoint;
        self._needMinDistance = needMinDistance;
        self._moveDes = self._taskDynamicData.staticData.mainTitle;
        if self._moveDestMapUnitID ~= MapMgr.GetMapUnitID() then
            MapMgr.RequestEnterMap(-1,self._moveDestMapUnitID,-1);
        end
    end
end
