FlyComponent = class("FlyComponent",EntityComponent);

function FlyComponent:ctor(...)
    EntityComponent.ctor(self,...);
end

function FlyComponent:OnStart()
    self._flyAction = FActionFactroy.CreateAction(self._entity._entityAtt.pathData,self);
end

function FlyComponent:OnUpdate(deltaTime)
    if self._flyAction then self._flyAction:OnUpdate(deltaTime); end
end

function FlyComponent:OnLateUpdate(deltaTime)
    if self._flyAction then self._flyAction:OnLateUpdate(deltaTime); end
end

function FlyComponent:OnDestroy()
    FActionFactroy.DestroyAction(self._flyAction);
    self._flyAction = nil;
end

return FlyComponent;