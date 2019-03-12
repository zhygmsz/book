AINodeSkillCast = class("AINodeSkillCast",AINodeBase);

function AINodeSkillCast:ctor()
    AINodeBase.ctor(self);
end

function AINodeSkillCast:dtor()
    AINodeBase.dtor(self);
end

function AINodeSkillCast:OnStart(aiData)
end

function AINodeSkillCast:OnUpdate(deltaTime,aiData)
    --检查连击是否已被激活
    if aiData.skillCombo then aiData.skillCombo:UpdateCombo(aiData.skillTarget); end
    if aiData.skillCombo and aiData.skillCombo:IsComboActive() then return BTDefine.NODE_STATUS.SUCCESS; end
    --自动战斗技能释放冷却
    if (not aiData.skillCombo) and UserData.GetAutoFight() and aiData.autoFlag and aiData.skillSwitchTime and aiData.skillSwitchTime > 0 then 
        aiData.skillSwitchTime = aiData.skillSwitchTime - deltaTime;
        return BTDefine.NODE_STATUS.RUNNING;
    else
        --开始释放技能
        aiData.skillSwitchTime = aiData.SKILL_SWITCH_TIME;
        MapMgr.RequestCastSkill(aiData.attacker,aiData.skillIndex,aiData.skillDynamicData.skillLevel,aiData.skillLevelData.unit,aiData.skillTarget);
        GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_CASTSKILL,aiData.skillTarget);
        return BTDefine.NODE_STATUS.SUCCESS;
    end
end