EntityRender = class("EntityRender",EntityVisible);

function EntityRender:ctor(...)
    EntityVisible.ctor(self,...);
    self:AddComponent(EntityDefine.COMPONENT_TYPE.RENDER,RenderComponent.new(self));
end

function EntityRender:GetRenderComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.RENDER);
end

return EntityRender;