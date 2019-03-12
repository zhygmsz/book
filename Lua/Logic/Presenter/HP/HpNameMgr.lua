module("HpNameMgr", package.seeall)

local mIsShowed = false

--保存所有entity和hpnameitem的对应关系，方便外部查找
local mEntity2HpNameItem = {}

--local方法
local function AddEntityId(entityId, hpNameItem)
    if not hpNameItem then
        GameLog.LogError("HpNameMgr.AddEntityId -> hpNameItem is nil")
        return
    end
    if entityId then
        if mEntity2HpNameItem[entityId] then
            GameLog.LogError("HpNameMgr.AddEntityId -> entityId is exist, entityId = %s", entityId)
        else
            mEntity2HpNameItem[entityId] = hpNameItem
        end
    else
        GameLog.LogError("HpNameMgr.AddEntityId -> entityId is nil")
    end
end

local function DeleteEntityId(entityId)
    if entityId then
        if mEntity2HpNameItem[entityId] then
            mEntity2HpNameItem[entityId] = nil
        else
            GameLog.LogError("HpNameMgr.DeleteEntityId -> entityId is not exist, entityId = %s", entityId)
        end
    else
        GameLog.LogError("HpNameMgr.DeleteEntityId -> entityId is nil")
    end
end

local function GetHpNameItemByEntityId(entityId)
    if entityId then
        return mEntity2HpNameItem[entityId]
    else
        GameLog.LogError("HpNameMgr.DeleteEntityId -> entityId is nil")
    end
end

function SetIsShowed(isShowed)
    mIsShowed = isShowed
end

function CheckIsShowed()
    return mIsShowed
end

function ShowHpNameUI()
    if CheckIsShowed() then
        UI_HP_Main.ShowHpNameUI()
    end
end

function HideHpNameUI()
    if CheckIsShowed() then
        UI_HP_Main.HideHpNameUI()
    end
end

function InitModule()

end

function AddHpNameItemByEntity(entity, hpNameItem)
    if not entity then
        GameLog.LogError("HpNameMgr.AddHpNameItemByEntity -> entity is nil")
        return
    end
    local entityId = entity:GetID()
    if entityId then
        AddEntityId(entityId, hpNameItem)
    end
end

function DeleteHpNameItemByEntity(entity)
    if not entity then
        GameLog.LogError("HpNameMgr.DeleteHpNameItemByEntity -> entity is nil")
        return
    end
    local entityId = entity:GetID()
    if entityId then
        DeleteEntityId(entityId)
    end
end

function GetHpNameItemByEntity(entity)
    if not entity then
        GameLog.LogError("HpNameMgr.GetHpNameItemByEntity -> entity is nil")
        return
    end
    local entityId = entity:GetID()
    if entityId then
        return GetHpNameItemByEntityId(entityId)
    end
end

return HpNameMgr