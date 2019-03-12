module("ActionFactory",package.seeall)

local mActionCtors = {};
local mActionCaches = {};
local mGroupCaches = {};

local function RegAction(fileName,actionEnum)
    mActionCtors[actionEnum] = require(fileName);
end

function CreateAction(actionData,dynamicID,playerID)
    if not actionData then return nil; end
    local actions = mActionCaches[actionData.actionType];
    if actions and #actions > 0 then
        local action = actions[#actions];
        actions[#actions] = nil;
        action:ctor(actionData,dynamicID,playerID);
        return action;
    else
        local actionCtor = mActionCtors[actionData.actionType];
        return actionCtor and actionCtor.new(actionData,dynamicID,playerID) or nil;
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
end

function CreateGroup(actionDatas,serialFlag,groupID,dynamicID,playerID)
    if #mGroupCaches > 0 then
        local group = mGroupCaches[#mGroupCaches];
        mGroupCaches[#mGroupCaches] = nil;
        group:ctor(actionDatas,serialFlag,groupID,dynamicID,playerID);
        return group;
    else
        return ActionGroup.new(actionDatas,serialFlag,groupID,dynamicID,playerID);
    end
end

function DestroyGroup(actionGroup)
    if not actionGroup then return; end
    actionGroup:dtor();
    mGroupCaches[#mGroupCaches + 1] = actionGroup;
end

function InitModule()
    local ACT = GameAction_pb.GameAction;
	require("Logic/System/Action/ActionGroup");
    require("Logic/System/Action/Action/ACTION_BASE");
    
    --基础功能
    RegAction("Logic/System/Action/Action/ACTION_STORY",ACT.ACTION_ROLE_CLIENT_STORY);              --剧情
    RegAction("Logic/System/Action/Action/ACTION_DIALOG",ACT.ACTION_ROLE_CLIENT_DIALOG);            --对话
    RegAction("Logic/System/Action/Action/ACTION_UIOPT",ACT.ACTION_ROLE_CLIENT_UI);                 --UI操作
    RegAction("Logic/System/Action/Action/ACTION_TIP",ACT.ACTION_ROLE_CLIENT_TIP);                  --TIP
    RegAction("Logic/System/Action/Action/ACTION_CAMERA",ACT.ACTION_ROLE_CLIENT_CAMERA_SETTING);    --摄像机操作
    RegAction("Logic/System/Action/Action/ACTION_ANIMATION",ACT.ACTION_ROLE_CLIENT_ANIMATION);      --视觉表现
    RegAction("Logic/System/Action/Action/ACTION_ANIMATION",ACT.PLAY_ANIMATION);                    --视觉表现 TODO这种要删除掉
    RegAction("Logic/System/Action/Action/ACTION_CASTSKILL",ACT.ACTION_ROLE_CLIENT_SKILL);          --释放技能
    RegAction("Logic/System/Action/Action/ACTION_AUTOFIGHT",ACT.ACTION_ROLE_CLIENT_AUTOFIGHT);      --自动战斗
end

return ActionFactory;