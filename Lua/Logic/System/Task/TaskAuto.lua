module(...,package.seeall)

--当前自动执行的任务目标
local mGoalGroupCache = TASK_GOAL_GROUP.new();
local mGoalGroup = nil;

local function IsInAutoFight()
    return UserData.GetAutoFight();
end

local function OnGoalStop(stop)
    if mGoalGroup then
        mGoalGroup:OnStop();
    end
    if stop then
        mGoalGroup = nil;
    end
    GameEvent.Trigger(EVT.TASK,EVT.TASK_AI_STOP);
    UserData.SetAutoFight(false,"TASK_AUTO");
end

local function OnGoalStart(taskType,taskID)
    UserData.SetAutoFight(false,"TASK_AUTO");
    mGoalGroup:OnStart(taskType,taskID);
    GameEvent.Trigger(EVT.TASK,EVT.TASK_AI_START,taskType,taskID);
end

local function OnGoalSwitch(goalIndex)
    if mGoalGroup._goalIndex ~= goalIndex then
        UserData.SetAutoFight(false,"TASK_AUTO");
        mGoalGroup:OnSwitchGoal(goalIndex)
    end
end

--拖拽摇杆
local function OnDragJoystick(isDraging)
    if mGoalGroup and isDraging and not IsInAutoFight() then OnGoalStop(true); end
end

--主动移动
local function OnCustomMove()
    if mGoalGroup then OnGoalStop(true); end
end

--主动技能
local function OnCastSkill()
    if mGoalGroup and not IsInAutoFight() then OnGoalStop(true); end
end

--自动战斗
local function OnAutoFightState(state,param)
    if param == "TASK_AUTO" then return end
    if mGoalGroup then OnGoalStop(true); end
end

--任务领取
local function OnTaskAccept(taskType,taskID)
    if mGoalGroup then
        if mGoalGroup:IsEqualTask(taskType,taskID) then
            local autoExecute,goalIndex = mGoalGroup:IsNextAutoGoal(taskType,taskID);
            if autoExecute then
                OnGoalSwitch(goalIndex);
            else
                OnGoalStop(true);
            end
        elseif mGoalGroup:IsNextAutoTask(taskType,taskID) then
            if mGoalGroup:IsNextAutoGoal(taskType,taskID) then
                OnGoalStart(taskType,taskID)
            else
                OnGoalStop(true);
            end
        end 
    end
end

--进度更新
local function OnTaskUpdate(taskType,taskID)
    if mGoalGroup and mGoalGroup:IsEqualTask(taskType,taskID) then
        local autoExecute,goalIndex = mGoalGroup:IsNextAutoGoal(taskType,taskID)
        if autoExecute then
            OnGoalSwitch(goalIndex);
        else
            OnGoalStop(false);
        end
    end
end

--任务取消
local function OnTaskCancel(taskType,taskID)
    if mGoalGroup and mGoalGroup:IsEqualTask(taskType,taskID) then
        OnGoalStop(true);
    end
end

--前往完成
local function OnTaskGotoFinish(taskType,taskID)
    if not mGoalGroup then
        mGoalGroup = mGoalGroupCache;
        OnGoalStart(taskType,taskID)
    else
        if mGoalGroup:IsAutoTask(taskType,taskID) and mGoalGroup:IsNotExecute(taskType,taskID) then
            OnGoalStop(false);
            OnGoalStart(taskType,taskID);
        end
    end
end

--前往领取
local function OnTaskGotoAccept(taskType,taskID)
    if not mGoalGroup then
        mGoalGroup = mGoalGroupCache;
    else
        OnGoalStop(false);
    end
    OnGoalStart(taskType,taskID);
end

--对话结束
local function OnDialogFinish(dialogData)
    local function FilterDialogID(goal,dialogGroupID)
        local conditionType = goal.condition.conditionType;
        local conditionParams = goal.condition.params;
        if conditionType == Condition_pb.STORY_NPC_TALK_FINISH and conditionParams[3] == dialogGroupID then return true; end
        if conditionType == Condition_pb.RANDOM_SELECT_QUEST and conditionParams[5] == dialogGroupID then return true; end
        return false;
    end
    local taskID,taskType,taskGoal,goalIndex = TaskMgr.GetAcceptedTasksByFilter(FilterDialogID,dialogData.groupID);
    if taskID and taskType and taskGoal then
        if taskGoal.condition.conditionType == Condition_pb.RANDOM_SELECT_QUEST then
            TaskMgr.RequestTaskSelect(taskType,taskID,goalIndex,dialogData.selectType);
        else
            TaskMgr.RequestTaskTalkOver(dialogData.groupID,dialogData.selectType or 0);
        end
    end
end

--剧情结束
local function OnStoryFinish(storyData)
    local function FilterStoryID(goal,storyID)
        return goal.condition.conditionType == Condition_pb.STORY_FINISH and goal.condition.params[1] == storyID; 
    end
    if storyData ~= nil then
        local taskID,taskType,taskGoal = TaskMgr.GetAcceptedTasksByFilter(FilterStoryID,storyData.id);
        if taskID and taskType and taskGoal then
            TaskMgr.RequestTaskStoryOver(taskID,taskType,taskGoal);
        end
    end
end

--打开算命UI
local function OnOpenDivineUI()
    local function FilterDivine(goal)
        return goal.condition.conditionType == Condition_pb.MISSION_DIVINE;
    end
    local taskID,taskType,taskGoal,goalIndex = TaskMgr.GetAcceptedTasksByFilter(FilterDivine);
    if taskID and taskType and taskGoal then
        TaskMgr.RequestOpenDivineUI();
    end
end

--循环更新
local function OnUpdate()
    if mGoalGroup then
        mGoalGroup:OnUpdate();
    end
end

function InitModule()
    UpdateBeat:Add(OnUpdate);
    --打断自动任务
    GameEvent.Reg(EVT.COMMON,EVT.DRAGJOYSTICK,OnDragJoystick);
    GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_CASTSKILL,OnCastSkill);
    GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_AUTOFIGHT,OnAutoFightState);
    GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_CUSTOM_MOVE,OnCustomMove);

    GameEvent.Reg(EVT.TASK,EVT.TASK_ACCEPT,OnTaskAccept);
    GameEvent.Reg(EVT.TASK,EVT.TASK_UPDATE,OnTaskUpdate);
    GameEvent.Reg(EVT.TASK,EVT.TASK_CANCEL,OnTaskCancel);
    GameEvent.Reg(EVT.TASK,EVT.TASK_GOTO_FINISH,OnTaskGotoFinish);
    GameEvent.Reg(EVT.TASK,EVT.TASK_GOTO_ACCEPT,OnTaskGotoAccept);

    --目标达成事件
    GameEvent.Reg(EVT.STORY,EVT.DIALOG_FINISH,OnDialogFinish);
    GameEvent.Reg(EVT.STORY,EVT.STORY_FINISH,OnStoryFinish);
	GameEvent.Reg(EVT.STORY,EVT.STORY_DIVINE,OnOpenDivineUI);
end