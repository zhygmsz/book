Entity = class("Entity");
local UUID = 0;

local function GenDynamicID()
    UUID = UUID - 1;
    return UUID;
end

function Entity:ctor(entityType,dynamicID,entityAtt)
    --当前实体动态ID
    if dynamicID then 
        self._dynamicID = tonumber(dynamicID);
    else
        self._dynamicID = GenDynamicID();
    end
    --当前实体类型
    self._entityType = entityType;
    --是否处于激活状态
    self._enable = true;      
    --是否处于死亡状态
    self._dead = false; 
    --是否已被完全删除
    self._destroy = false;      
    --实体组件列表
    self._components = {};
    --实体属性
    self._entityAtt = entityAtt;
end

--添加组件
function Entity:AddComponent(componentType,component)
    self._components[componentType] = component;
end

--获取组件
function Entity:GetComponent(componentType)
    return self._components[componentType];
end

--从池子里取出来的实体重新使用
function Entity:OnSpawn(entityType,dynamicID,entityAtt)
    if dynamicID then 
        self._dynamicID = tonumber(dynamicID);
    else
        self._dynamicID = GenDynamicID();
    end
    self._entityType = entityType;
    self._enable = true;
    self._dead = false;
    self._destroy = false;
    self._entityAtt = entityAtt;
    for componentType,component in pairs(self._components) do
        component:OnSpawn();
    end
end

--实体被放入池子里
function Entity:OnDeSpawn()
    for componentType,component in pairs(self._components) do
        component:OnDeSpawn();
    end
end

--start之前执行,预处理一些start需要的信息
function Entity:OnAwake()
    
end

--实体被创建时执行一次
function Entity:OnStart()
    for componentType,component in pairs(self._components) do
        component:OnStart();
    end
end

--实体被激活时调用
function Entity:OnEnable()
    self._enable = true;
    for componentType,component in pairs(self._components) do
        component:OnEnable();
    end
end

--实体模型加载结束时调用
function Entity:OnModelLoad(modelObject)
    for componentType,component in pairs(self._components) do
        component:OnModelLoad(modelObject);
    end
    self._entityAtt.newFlag = false;
end

--实体模型替换开始时调用
function Entity:OnModelReplace(modelObject)
    for componentType,component in pairs(self._components) do
        component:OnModelReplace(modelObject);
    end
end

--实体被隐藏时调用
function Entity:OnDisable()
    self._enable = false;
    for componentType,component in pairs(self._components) do
        component:OnDisable();
    end
end

--实体组件TICK入口
function Entity:OnUpdate(deltaTime)
    for componentType,component in pairs(self._components) do
        component:OnUpdate(deltaTime);
    end
end

--实体组件TICK入口
function Entity:OnLateUpdate(deltaTime)
    for componentType,component in pairs(self._components) do
        component:OnLateUpdate(deltaTime);
    end
end

--实体被删除,此时释放所有资源
function Entity:OnDestroy()
    self._destroy = true;
    for componentType,component in pairs(self._components) do
        component:OnDestroy();
    end
end

--当前实体的动态ID
function Entity:GetID()
    return self._dynamicID;
end

--当前实体的客户端类型
function Entity:GetType()
    return self._entityType;
end

--当前实体的服务器类型
function Entity:GetServerType()
    return EntityDefine.CTS(self._entityType);
end

--当前实体的名称
function Entity:GetName()
    return self._entityAtt.name;
end

--当前实体主人的ID
function Entity:GetMasterID()
    return self._entityAtt.masterEntityId;
end

--当前实体主人的名称
function Entity:GetMasterName()
    return self._entityAtt.masterName;
end

--调试信息
function Entity:GetDebugInfo()
    return "";
end

--实体是否处于死亡状态
function Entity:IsDead()
    return self._dead;
end

--实体是否已释放所有资源,此时处于不可用状态
function Entity:IsDestroyed()
    return self._destroy;
end

--是否是有效的实体
function Entity:IsValid()
    return not self._destroy and not self._dead;
end

--是不是服务器创建的实体
function Entity:IsServerEntity()
    if self._entityType == EntityDefine.ENTITY_TYPE.PET then return true end
    if self._entityType == EntityDefine.ENTITY_TYPE.NPC then return true end
    if self._entityType == EntityDefine.ENTITY_TYPE.PLAYER then return true end
    if self._entityType == EntityDefine.ENTITY_TYPE.PLAYER_MAIN then return true end
end

function Entity:IsSelf()
    return self:GetType() == EntityDefine.ENTITY_TYPE.PLAYER_MAIN;
end

function Entity:IsPlayer()
    return self:IsSelf() or self:GetType() == EntityDefine.ENTITY_TYPE.PLAYER;
end

function Entity:IsPlayerOfTeam()
    return false;
end

function Entity:IsNPC()
    return self:GetType() == EntityDefine.ENTITY_TYPE.NPC;
end

function Entity:IsPet()
    return self:GetType() == EntityDefine.ENTITY_TYPE.PET;
end

function Entity:IsPetOfPlayer(playerID)
    return self:IsPet() and self:GetMasterID() == playerID;
end

function Entity:IsBullet()
    return self:GetType() == EntityDefine.ENTITY_TYPE.BULLET;
end

function Entity:IsRender()
    return self:GetType() == EntityDefine.ENTITY_TYPE.RENDER;
end

function Entity:IsHelper()
    return self:GetType() == EntityDefine.ENTITY_TYPE.HELPER;
end

function Entity:IsHelperOfTeam()
    return false;
end

function Entity:IsNewEntity()
    return self._entityAtt.newFlag;
end

return Entity;