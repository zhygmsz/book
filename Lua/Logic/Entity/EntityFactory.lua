module("EntityFactory",package.seeall)

local mEntityPools = {};
local mEntityCtors = {};

function CreateEntity(entityType,entityID,entityAtt)
    local pool = mEntityPools[entityType];
    if pool and #pool > 0 then 
        local entity = pool[#pool];
        pool[#pool] = nil;
        entity:OnSpawn(entityType,entityID,entityAtt);
        return entity;
    else
        local ctor = mEntityCtors[entityType];
        if ctor then 
            return ctor(entityType,entityID,entityAtt);
        else
            return nil
        end
    end
end

function DestroyEntity(entity)
    local entityType = entity:GetType();
    local pool = mEntityPools[entityType];
    if not pool then
        pool = {};
        mEntityPools[entityType] = pool;
    end
    entity:OnDeSpawn();
    pool[#pool + 1] = entity;
end

function RegEntity(entityType,classPath)
    local entityClass = require(classPath);
    mEntityCtors[entityType] = entityClass.new;
end

function InitModule()
    --实体基类
    require("Logic/Entity/Entities/Base/Entity");
    require("Logic/Entity/Entities/Base/EntityInVisible");
    require("Logic/Entity/Entities/Base/EntityVisible");
    require("Logic/Entity/Entities/Base/EntityCharacter");
    --注册实体到缓存池
    RegEntity(EntityDefine.ENTITY_TYPE.AREA,"Logic/Entity/Entities/MapUnit/EntityArea");
    RegEntity(EntityDefine.ENTITY_TYPE.COUNTER,"Logic/Entity/Entities/MapUnit/EntityCounter");
    RegEntity(EntityDefine.ENTITY_TYPE.TIMER,"Logic/Entity/Entities/MapUnit/EntityTimer");
    RegEntity(EntityDefine.ENTITY_TYPE.WALL,"Logic/Entity/Entities/MapUnit/EntityWall");
    RegEntity(EntityDefine.ENTITY_TYPE.TRANSFER,"Logic/Entity/Entities/MapUnit/EntityTransfer");
    RegEntity(EntityDefine.ENTITY_TYPE.BULLET,"Logic/Entity/Entities/MapUnit/EntityBullet");
    RegEntity(EntityDefine.ENTITY_TYPE.AIPET,"Logic/Entity/Entities/MapUnit/EntityAIPet");

    RegEntity(EntityDefine.ENTITY_TYPE.PLAYER,"Logic/Entity/Entities/Character/EntityPlayer");
    RegEntity(EntityDefine.ENTITY_TYPE.PLAYER_MAIN,"Logic/Entity/Entities/Character/EntityPlayerMain");
    RegEntity(EntityDefine.ENTITY_TYPE.NPC,"Logic/Entity/Entities/Character/EntityNPC");
    RegEntity(EntityDefine.ENTITY_TYPE.PET,"Logic/Entity/Entities/Character/EntityPet");
    RegEntity(EntityDefine.ENTITY_TYPE.HELPER,"Logic/Entity/Entities/Character/EntityHelper");

    

    RegEntity(EntityDefine.ENTITY_TYPE.RENDER,"Logic/Entity/Entities/Preview/EntityRender");
    RegEntity(EntityDefine.ENTITY_TYPE.CREATE,"Logic/Entity/Entities/Preview/EntityCreateRole");

    
end

return EntityFactory;