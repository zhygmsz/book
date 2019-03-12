module("SkillFactory",package.seeall);

local mSkillCaches = {};

function CreateSkill(...)
    local skill = mSkillCaches[#mSkillCaches];
    if not skill then 
        skill = Skill.new(...);
    else
        mSkillCaches[#mSkillCaches] = nil;
        skill:ctor(...);
    end
    return skill;
end

function DestroySkill(skill)
    if skill then
        mSkillCaches[#mSkillCaches + 1] = skill;
        skill:dtor();
    end
end

function InitModule()
    require("Logic/Entity/Components/Skill/Skills/Skill");
end

return SkillFactory;