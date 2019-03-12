EntityInVisible = class("EntityInVisible",Entity);

function EntityInVisible:ctor(entityType,dynamicID,modelPath)
    Entity.ctor(self,entityType,dynamicID);
end

return EntityInVisible;