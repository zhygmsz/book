EntityComponent = class("EntityComponent");

function EntityComponent:ctor(entity)
    self._entity = entity;
end

function EntityComponent:OnSpawn()
end

function EntityComponent:OnDeSpawn()
end

function EntityComponent:OnStart()
end

function EntityComponent:OnEnable()
end

function EntityComponent:OnModelLoad(modelObject)
end

function EntityComponent:OnModelReplace(modelObject)
end

function EntityComponent:OnDisable()
end

function EntityComponent:OnUpdate(deltaTime)
end

function EntityComponent:OnLateUpdate(deltaTime)
end

function EntityComponent:OnDestroy()
end

return EntityComponent;