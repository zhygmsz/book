EntityPlayerMain = class("EntityPlayerMain",EntityPlayer);

function EntityPlayerMain:ctor(...)
    EntityPlayer.ctor(self,...);
    self:AddComponent(EntityDefine.COMPONENT_TYPE.AI,AIComponent.new(self));
    self:AddComponent(EntityDefine.COMPONENT_TYPE.SELECT,SelectComponent.new(self));
end

return EntityPlayerMain;