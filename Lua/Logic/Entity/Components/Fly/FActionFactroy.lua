module("FActionFactroy",package.seeall)

local mActionCtors = {};
local mActionCaches = {};

function CreateAction(pathData,...)
    if not pathData then return nil; end
    local actions = mActionCaches[pathData.pathType];
    if actions and #actions > 0 then
        local action = actions[#actions];
        actions[#actions] = nil;
        action:ctor(pathData,...);
        return action;
    else
        local actionCtor = mActionCtors[pathData.pathType];
        return actionCtor and actionCtor.new(pathData,...) or nil;
    end
end

function DestroyAction(action)
    if not action then return; end
    local actions = mActionCaches[action._pathData.pathType];
    if not actions then
        actions = {};
        mActionCaches[action._pathData.pathType] = actions;
    end
    actions[#actions + 1] = action;
    action:dtor();
end

function RegAction(actionEnum,fileName)
    mActionCtors[actionEnum] = require(fileName);
end

function InitModule()
    --require("Logic/Entity/Components/Fly/FActionGroup");
    require("Logic/Entity/Components/Fly/Actions/FACT_Base");

    local FACT = Skill_pb.SkillPath;
    RegAction(FACT.FIXED,"Logic/Entity/Components/Fly/Actions/FACT_Fixed");
    RegAction(FACT.FOLLOW,"Logic/Entity/Components/Fly/Actions/FACT_Follow");
end

return FActionFactroy;