SACT_SkillCombo = class("SACT_SkillCombo",SACT_Base)

function SACT_SkillCombo:ctor(...)
    SACT_Base.ctor(self,...);
    self._comboSkillID = string.StringIDToInt(self._actionAtt.args[1].strValue);
    self._comboDelayTime = self._actionAtt.args[2].floatValue * 1000;
    self._comboTarget = nil;
end

function SACT_SkillCombo:DoStartEffect()
    self._passedTime = 0;
    self._autoCastSkill = false;
end

function SACT_SkillCombo:DoUpdateEffect(deltaTime)
    self._passedTime = self._passedTime + deltaTime;
    if self._autoCastSkill and self._passedTime >= self._comboDelayTime then
        self:CastSkill();
    end
end

function SACT_SkillCombo:UpdateTarget(comboTarget)
    self._comboTarget = comboTarget;
end

function SACT_SkillCombo:CastSkill()
    if self._passedTime >= self._comboDelayTime then
        self._autoCastSkill = false;
        --取消上一段技能
        self._actionOwner:CancelSkill(EntityDefine.SKILL_CANCEL_TYPE.CAST_COMBO);
        --获取下一段技能表现信息
        local skillIndex,skillUnitID,skillLevel = self._actionOwner:GetComboSkill(self._comboSkillID);
        if skillIndex then
            --检查技能目标是否有效
            local skillData = SkillData.GetSkillInfo(self._comboSkillID);
            if skillData and skillData.castType == SkillInfo_pb.SkillInfo.FORCE_TARGET then
                if self._comboTarget == nil then return end
                if self._comboTarget.IsValid and not self._comboTarget:IsValid() then return end
            end
            self._actionOwner._skillComponent:CastSkill(skillIndex,skillLevel,skillUnitID,self._comboTarget);
        end
    else
        self._autoCastSkill = true;
    end
end

return SACT_SkillCombo;
