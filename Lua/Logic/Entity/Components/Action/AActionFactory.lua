module("AActionFactory",package.seeall)

local mActionCtors = {};
local mActionCaches = {};

function CreateAction(actionData,...)
    if not actionData then return nil; end
    local actions = mActionCaches[actionData.actionType];
    if actions and #actions > 0 then
        local action = actions[#actions];
        actions[#actions] = nil;
        action:ctor(actionData,...);
        return action;
    else
        local actionCtor = mActionCtors[actionData.actionType];
        return actionCtor and actionCtor.new(actionData,...) or nil;
    end
end

function DestroyAction(action)
    if not action then return; end
    local actions = mActionCaches[action._actionData.actionType];
    if not actions then
        actions = {};
        mActionCaches[action._actionData.actionType] = actions;
    end
    actions[#actions + 1] = action;
    action:dtor();
end

function RegAction(actionEnum,fileName)
    mActionCtors[actionEnum] = require(fileName);
end

function InitModule()
    require("Logic/Entity/Components/Action/AActionGroup");
    require("Logic/Entity/Components/Action/Actions/AACT_Base");

    local AACT = AnimationInfo_pb.AnimationActionInfo;
    RegAction(AACT.PLAY_ACTION,"Logic/Entity/Components/Action/Actions/AACT_PlayAction");
    RegAction(AACT.PLAY_EFFECT,"Logic/Entity/Components/Action/Actions/AACT_PlayEffect");
    RegAction(AACT.PLAY_SOUND,"Logic/Entity/Components/Action/Actions/AACT_PlaySound");
    RegAction(AACT.PLAY_DISSOLVE,"Logic/Entity/Components/Action/Actions/AACT_PlayDissolve");
    RegAction(AACT.PLYA_HITEFFECT,"Logic/Entity/Components/Action/Actions/AACT_PlayHitEffect")

    RegAction(AACT.SHOW_DIALOG,"Logic/Entity/Components/Action/Actions/AACT_ShowDialog");
    RegAction(AACT.SHOW_UI,"Logic/Entity/Components/Action/Actions/AACT_ShowUI");

    RegAction(AACT.MOVE_AWAY,"Logic/Entity/Components/Action/Actions/AACT_MoveAway");
end

return AActionFactory;