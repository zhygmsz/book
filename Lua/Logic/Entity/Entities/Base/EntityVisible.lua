EntityVisible = class("EntityVisible",Entity);

function EntityVisible:ctor(...)
    Entity.ctor(self,...);
    self:AddComponent(EntityDefine.COMPONENT_TYPE.MODEL,ModelComponent.new(self));
end

function EntityVisible:GetModelComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.MODEL);
end

return EntityVisible;