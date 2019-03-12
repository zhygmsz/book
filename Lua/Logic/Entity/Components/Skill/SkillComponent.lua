SkillComponent = class("SkillComponent",EntityComponent);

function SkillComponent:ctor(...)
    EntityComponent.ctor(self,...);
    self._castingSkills = {};
end

function SkillComponent:OnUpdate(deltaTime)
    for _,skill in pairs(self._castingSkills) do skill:OnUpdate(deltaTime); end
end

function SkillComponent:OnEnable()

end

function SkillComponent:OnDisable()
    for _,skill in pairs(self._castingSkills) do 
        SkillFactory.DestroySkill(skill);
    end
    self._castingSkills = {};
end

function SkillComponent:OnModelLoad()
    for _,skill in pairs(self._castingSkills) do
        skill:OnModelLoad();
    end
end

function SkillComponent:OnModelReplace()
    for _,skill in pairs(self._castingSkills) do
        skill:OnModelReplace();
    end
end

function SkillComponent:CastSkill(skillIndex,skillLevel,skillUnitID,skillTarget)
    if not skillUnitID or skillUnitID <= 0 then return end
    local skill = self:GetCastingSkillByIndex(skillIndex);
    if skillIndex > 0 and skill and skill:IsSkillCasting() then
        skill:UpdateCombo(skillTarget);
        skill:CastCombo();
    else
        local skill = self._castingSkills[skillUnitID] or SkillFactory.CreateSkill(self,skillIndex,skillUnitID);
        self._castingSkills[skillUnitID] = skill;
        skill:CastSkill(skillLevel,skillTarget);
        --触发技能释放事件
        GameEvent.Trigger(EVT.ENTITY, EVT.ENTITY_CAST_SKILL, self._entity, skillUnitID);
    end
end

function SkillComponent:CancelSkill(cancelType)
    for _,skill in pairs(self._castingSkills) do
        skill:CancelSkill(cancelType);
    end
end

function SkillComponent:GetCastingSkillByUnit(skillUnitID)
    return self._castingSkills[skillUnitID];
end

function SkillComponent:GetCastingSkillByIndex(skillIndex)
    for _,skill in pairs(self._castingSkills) do
        if skill:IsSkillCasting() and skill._skillIndex == skillIndex then return skill; end
    end
end

function SkillComponent:GetCastingSkillCount()
    local castingCount = 0;
    for _,skill in pairs(self._castingSkills) do
        if skill:IsSkillCasting() then castingCount = castingCount + 1; end
    end
    return castingCount;
end

