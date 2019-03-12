module("TaskGoalFactory",package.seeall)

local mActionCtors = {};
local mActionCaches = {};

local function InitGoal(fileName,goalEnum)
    require("Logic/System/Task/Goal/TASK_GOAL_"..fileName);
    mActionCtors[goalEnum] = _G["TASK_GOAL_"..fileName];
end

function CreateAction(goalConditionType,...)
    local caches = mActionCaches[goalConditionType];
    if caches and #caches > 0 then
        local goalAction = caches[#caches];
        caches[#caches] = nil;
        goalAction:ctor(goalConditionType,...);
        return goalAction;
    else
        local actionCtor = mActionCtors[goalConditionType];
        if actionCtor then return actionCtor.new(goalConditionType,...); end
    end
end

function DestroyAction(goalAction)
    if not goalAction then return end
    local caches = mActionCaches[goalAction._goalConditionType];
    if not caches then
        caches = {};
        mActionCaches[goalAction._goalConditionType] = caches;
    end
    caches[#caches + 1] = goalAction;
end

function InitModule()
    require("Logic/System/Task/Goal/TASK_GOAL_BASE");
    require("Logic/System/Task/Goal/TASK_GOAL_GROUP");
    
    InitGoal("KILLNPC",Condition_pb.FIGHT_NPC_GROUP_DEAD);
    InitGoal("KILLNPC",Condition_pb.FIGHT_NPC_KILL);
    InitGoal("KILLNPC",Condition_pb.COND_SPACE_NPC_HPPERCENT_LESS);

    InitGoal("DIALOG",Condition_pb.STORY_NPC_TALK_FINISH);
    InitGoal("DIALOG",Condition_pb.RANDOM_SELECT_QUEST);

    InitGoal("OPENUI",Condition_pb.MISSION_DIVINE);
    InitGoal("OPENUI",Condition_pb.SELECT_GOAL);

    InitGoal("MOVE",Condition_pb.SCENE_ENTER_AREA);
    InitGoal("MAP",Condition_pb.FINISH_PARAWORLD);
end

return TaskGoalFactory;