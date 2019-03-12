TASK_GOAL_GROUP = class("TASK_GOAL_GROUP");

function TASK_GOAL_GROUP:ctor()
    self._taskType = nil;
    self._taskID = nil;
    self._dynamicData = nil;
    self._goalIndex = nil;
    self._goalActions = {};
    self._acceptAction = nil;
    self._submitAction = nil;
    self._curAction = nil;
    self._active = nil;
end

function TASK_GOAL_GROUP:OnStart(taskType,taskID)
    --任务信息
    self._taskType = taskType;
    self._taskID = taskID;
    self._dynamicData = TaskMgr.GetTaskDynamicData(taskType,taskID);
    self._goalIndex = -1;
    for idx,goalAction in pairs(self._goalActions) do
        TaskGoalFactory.DestroyAction(goalAction);
        self._goalActions[idx] = nil;
    end
    self._curAction = nil;
    self._active = true;
    --任务目标
    for i = 1,#self._dynamicData.goals do
        local goalDynamicData = self._dynamicData.goals[i];
        local goalConditionType = goalDynamicData.staticData.condition.conditionType;
        self._goalActions[i] = TaskGoalFactory.CreateAction(goalConditionType,goalDynamicData,self._dynamicData);
        if self._goalIndex == -1 and self._dynamicData.hasAccept and not TaskMgr.IsGoalFinish(goalDynamicData) then
            self._goalIndex = i;
        end
    end
    if self._goalIndex ~= -1 then
        --有目标尚未达成
        self._curAction = self._goalActions[self._goalIndex];
        --开始自动执行
        if self._curAction then 
            self._curAction:OnStart(); 
        else
            self._active = false;
            TipsMgr.GetTipByKey("task_auto_execute_fail");
        end
    else
        --未领取或者未提交
        self._active = false;
    end
end

function TASK_GOAL_GROUP:OnSwitchGoal(goalIndex)
    if self._goalIndex ~= goalIndex then
        if goalIndex >= 1 and goalIndex <= #self._dynamicData.goals then
            --已领取后或者前置目标达成后自动执行
            if self._curAction then self._curAction:OnStop(); end
            self._goalIndex = goalIndex;
            self._curAction = self._goalActions[self._goalIndex];
            if self._curAction then self._curAction:OnStart(); end
            self._active = true;
        elseif goalIndex == -1 then
            --前往提交任务
        end
    end
end

function TASK_GOAL_GROUP:OnUpdate()
    if self._active and self._curAction then 
        self._curAction:OnUpdate();
        if self._curAction:IsFinish() then self:OnStop(); end
    end
end

function TASK_GOAL_GROUP:OnStop()
    if self._active then
        if self._curAction then self._curAction:OnStop(); end
        self._active = false;
    end
end

function TASK_GOAL_GROUP:IsEqualTask(taskType,taskID)
    return self._taskID == taskID and self._taskType == taskType;
end

function TASK_GOAL_GROUP:IsNextAutoGoal(taskType,taskID)
    local dynamicData = TaskMgr.GetTaskDynamicData(taskType,taskID);
    for i = 1,#dynamicData.goals do
        if not TaskMgr.IsGoalFinish(dynamicData.goals[i]) then
            return dynamicData.staticData.goals[i].autoExecute,i;
        else
            if dynamicData.staticData.goalRelation == Quest_pb.QuestInfo.OR then
                --或关系目标达成一个就算完成
                break;
            end
        end
    end
    return not dynamicData.staticData.autoSubmit,-1;
end

function TASK_GOAL_GROUP:IsNextAutoTask(taskType,taskID)
    --检查领取后的任务是否与当前自动执行的任务属于同一序列
    if self._taskType == taskType then
        local function IsAutoTaskCondition(_condition,_taskID)
            if _condition.conditionType == Condition_pb.FINISH_QUEST and _condition.params[1] == _taskID then return true end
        end
        local dynamicData = TaskMgr.GetTaskDynamicData(taskType,taskID);
        for _,condition in ipairs(dynamicData.staticData.andAcceptCondition) do
            if IsAutoTaskCondition(condition,taskID) then return true; end
        end
        for _,condition in ipairs(dynamicData.staticData.orAcceptCondition) do
            if IsAutoTaskCondition(condition,taskID) then return true; end
        end
    end
    return false;
end

function TASK_GOAL_GROUP:IsAutoTask(taskType,taskID)
    return true;
end

function TASK_GOAL_GROUP:IsNotExecute(taskType,taskID)
    if self._taskType == taskType and self._taskID == taskID then
        --检查当前目标是否正在执行
        return not self._active or not self._curAction or not self._curAction:IsExecuting();
    else
        return TaskMgr.GetTaskDynamicData(taskType,taskID) ~= nil
    end
end