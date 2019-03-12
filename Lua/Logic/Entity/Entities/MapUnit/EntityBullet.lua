EntityBullet = class("EntityBullet",EntityVisible);

function EntityBullet:ctor(...)
    EntityVisible.ctor(self,...)
    self:AddComponent(EntityDefine.COMPONENT_TYPE.FLY,FlyComponent.new(self));
    self:AddComponent(EntityDefine.COMPONENT_TYPE.PROPERTY,PropertyComponent.new(self));
end

function EntityBullet:OnAwake()
    self._passedTime = 0;
end

function EntityBullet:OnUpdate(deltaTime)
    EntityVisible.OnUpdate(self,deltaTime);
    self._passedTime = self._passedTime + deltaTime;
    if self._passedTime >= self._entityAtt.particle.duration then
        MapMgr.DestroyEntity(self:GetType(),self:GetID());
    end
end

function EntityBullet:GetPropertyComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.PROPERTY);
end

return EntityBullet;