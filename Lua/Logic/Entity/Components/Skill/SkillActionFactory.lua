module("SkillActionFactory",package.seeall)

local mActions = {};
local mActionCtors = {};

function CreateAction(owner,actionAtt)
    local actions = mActions[actionAtt.actionType];
    local action = actions and actions[#actions] or nil;
    if not action then
        local actionCtor = mActionCtors[actionAtt.actionType];
        action = actionCtor and actionCtor(owner,actionAtt) or nil;
    else
        actions[#actions] = nil;
        action:ctor(owner,actionAtt);
    end
    return action;
end

function DestroyAction(action)
    local actions = mActions[action._actionAtt.actionType];
    if not actions then 
        actions = {};
        mActions[action._actionAtt.actionType] = actions;
    end
    actions[#actions + 1] = action;
    action:dtor();
end

function RegAction(actionType,actionPath)
    if actionPath ~= "" then 
        mActionCtors[actionType] = require(actionPath).new;
    end
end

function InitModule()
    require("Logic/Entity/Components/Skill/Actions/SACT_Base");
    
    local SACT = Skill_pb.SkillAction;
    --无效数据
    RegAction(SACT.EMIT_PARTICLE,"Logic/Entity/Components/Skill/Actions/SACT_EmitParticle");

    --播放特效、音效、动作
    RegAction(SACT.PLAY_ACTION,"Logic/Entity/Components/Skill/Actions/SACT_PlayAction");
    RegAction(SACT.PLAY_EFFECT,"Logic/Entity/Components/Skill/Actions/SACT_PlayEffect");
    RegAction(SACT.PLAY_SOUND,"Logic/Entity/Components/Skill/Actions/SACT_PlaySound");

    --摄像机震屏、模糊、高亮自身
    RegAction(SACT.CAMERA_SHAKE,"Logic/Entity/Components/Skill/Actions/SACT_CameraShake");
    RegAction(SACT.CAMERA_BLUR,"Logic/Entity/Components/Skill/Actions/SACT_CameraBlur");
    RegAction(SACT.CAMERA_BLACK,"Logic/Entity/Components/Skill/Actions/SACT_CameraBlack");

    --禁止移动、禁止主动技能、禁止奔跑、禁止打断
    RegAction(SACT.LIMIT_MOVE_ROTATE,"Logic/Entity/Components/Skill/Actions/SACT_LimitMoveRotate");
    RegAction(SACT.LIMIT_SKILL,"Logic/Entity/Components/Skill/Actions/SACT_LimitSkill");
    RegAction(SACT.LIMIT_MOVE,"Logic/Entity/Components/Skill/Actions/SACT_LimitMove");
    RegAction(SACT.LIMIT_CANCEL,"Logic/Entity/Components/Skill/Actions/SACT_LimitCancel");

    --引导、预警
    RegAction(SACT.TIP_GUIDE,"Logic/Entity/Components/Skill/Actions/SACT_TipGuide");
    RegAction(SACT.TIP_WARNING,"Logic/Entity/Components/Skill/Actions/SACT_TipWarning");

    --跳跃、冲锋、召唤
    RegAction(SACT.ACTION_JUMP,"Logic/Entity/Components/Skill/Actions/SACT_ActionJump");
    RegAction(SACT.ACTION_CHARGE,"Logic/Entity/Components/Skill/Actions/SACT_ActionCharge");

    --添加BUFF、碰撞检测
    RegAction(SACT.BUFF_HIT,"Logic/Entity/Components/Skill/Actions/SACT_BuffHit");
    RegAction(SACT.BUFF_ADD,"Logic/Entity/Components/Skill/Actions/SACT_BuffAdd");

    --释放指定技能、连击下一段技能
    RegAction(SACT.SKILL_MAKE,"");
    RegAction(SACT.SKILL_COMBO,"Logic/Entity/Components/Skill/Actions/SACT_SkillCombo");
end

return SkillActionFactory;