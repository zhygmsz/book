EntityManager = class("EntityManager");

local function __OnEntityCreate(entity)
    if entity and not entity:IsDestroyed() then
        entity:OnAwake();
        entity:OnStart();
        entity:OnEnable();
		if entity:IsServerEntity() then GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_CREATE,entity); end
    end
end

local function __OnEntityDestroy(entity)
    if entity and not entity:IsDestroyed() then 
        entity:OnDisable();
        entity:OnDestroy();
        EntityAttFactory.FreeEntityAtt(entity:GetType(),entity._entityAtt);
        EntityFactory.DestroyEntity(entity);
		if entity:IsServerEntity() then GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_DELETE,entity); end
    end
end

--实体被创建,正常创建
local function OnEntityCreate(self,entity)
    local function OnUpdateFinish()
        local entityType = entity:GetType();
        local entityID = entity:GetID();
        if not self._entities[entityType] then self._entities[entityType] = {} end
        self._entities[entityType][entityID] = entity;
        __OnEntityCreate(entity);
    end
    if self._updateFlag then
        table.insert(self._updateActions,OnUpdateFinish);
    else
        OnUpdateFinish();
    end
    return entity;
end

--实体被删除,正常删除
local function OnEntityDestroy(self,entity)
    local function OnUpdateFinish()
        local entities = self._entities[entity:GetType()];
        if entities then entities[entity:GetID()] = nil; end    
        __OnEntityDestroy(entity);
    end
    if self._updateFlag then
        table.insert(self._updateActions,OnUpdateFinish);
    else
        OnUpdateFinish();
    end
end

--构造函数
function EntityManager:ctor()
    self._entities = {};
    --遍历过程中不能操作字典
    self._updateActions = {};
    self._updateFlag = false;
end

--TICK入口
function EntityManager:OnUpdate(deltaTime)
    self._updateFlag = true;
    for entityType,entities in pairs(self._entities) do
        if EntityDefine.VALID_ENTITY(entityType) then
            for entityID,entity in pairs(entities) do
                local flag,msg = xpcall(entity.OnUpdate,traceback,entity,deltaTime);
                if not flag then GameLog.LogError("entity has error: %s",msg) end
            end
        end
    end
    self._updateFlag = false;
    if #self._updateActions > 0 then
        for _,action in ipairs(self._updateActions) do action(); end
        self._updateActions = {};
    end
end

--TICK入口
function EntityManager:OnLateUpdate(deltaTime)
    self._updateFlag = true;
    for entityType,entities in pairs(self._entities) do
        if EntityDefine.VALID_ENTITY(entityType) then
            for entityID,entity in pairs(entities) do
                local flag,msg = xpcall(entity.OnLateUpdate,traceback,entity,deltaTime);
                if not flag then GameLog.LogError("entity has error: %s",msg) end
            end
        end
    end
    self._updateFlag = false;
    if #self._updateActions > 0 then
        for _,action in ipairs(self._updateActions) do action(); end
        self._updateActions = {};
    end
end

--析构函数
function EntityManager:OnDestroy()
    self._updateFlag = true;
    for entityType,entities in pairs(self._entities) do
        for entityID,entity in pairs(entities) do
            __OnEntityDestroy(entity);
        end
    end
    self._entities = {};
    self._updateFlag = false;
    self._updateActions = {};
end

--创建实体
function EntityManager:CreateEntity(entityType,entityID,entityAtt)
    entityAtt = EntityAttFactory.AllocEntityAtt(entityType,entityAtt);
    return OnEntityCreate(self,EntityFactory.CreateEntity(entityType,entityID,entityAtt));
end

--获取实体
function EntityManager:FindEntity(entityType,entityID)
    local entities = self._entities[entityType];
    if entities then return entities[entityID] end
end

--获取指定ID的实体
function EntityManager:FindEntityByID(entityID)
    for entityType,entities in pairs(self._entities) do
        local entity = entities[entityID];
        if entity then return entity; end
    end    
end

--查找指定类型的所有实体
function EntityManager:FindAllEntityByType(entityType)
    return self._entities[entityType];
end

--删除实体
function EntityManager:DestroyEntity(entityType,entityID)
    local entity = self:FindEntity(entityType,entityID);
    if entity and not entity:IsDestroyed() then
        OnEntityDestroy(self,entity);
        return entity;
    end
end