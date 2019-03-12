EntityCharacter = class("EntityCharacter",EntityVisible);

function EntityCharacter:ctor(...)
    EntityVisible.ctor(self,...);
    self:AddComponent(EntityDefine.COMPONENT_TYPE.BUFF,BuffComponent.new(self));
    self:AddComponent(EntityDefine.COMPONENT_TYPE.SKILL,SkillComponent.new(self));
    self:AddComponent(EntityDefine.COMPONENT_TYPE.MOVE,MoveComponent.new(self));
    self:AddComponent(EntityDefine.COMPONENT_TYPE.STATE,StateComponent.new(self));
    self:AddComponent(EntityDefine.COMPONENT_TYPE.CAMP,CampComponent.new(self));
    self:AddComponent(EntityDefine.COMPONENT_TYPE.PROPERTY,PropertyComponent.new(self));
    self:AddComponent(EntityDefine.COMPONENT_TYPE.ACTION,ActionComponent.new(self));
end

function EntityCharacter:GetBuffComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.BUFF);
end

function EntityCharacter:GetSkillComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.SKILL);
end

function EntityCharacter:GetMoveComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.MOVE);
end

function EntityCharacter:GetStateComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.STATE);
end

function EntityCharacter:GetCampComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.CAMP);
end

function EntityCharacter:GetPropertyComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.PROPERTY);
end

function EntityCharacter:GetActionComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.ACTION);
end

function EntityCharacter:GetAIComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.AI);
end

return EntityCharacter;