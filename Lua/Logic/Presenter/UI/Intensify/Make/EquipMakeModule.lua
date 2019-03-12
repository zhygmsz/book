module("EquipMakeModule", package.seeall)

local m_ironItemIndex = 1;
local m_bookItemIndex = 2;
local m_runeIndex = 3;
local m_intensifyItemIndex = 4;

local currentEquipMakeId = -1;
local currentMaterials = {};
local needMaterials = {};
local equipMakeData = {};
local currentMakeValue = 0;

local m_IsNormalMake = true;

local m_makeValueConfigDataKey = "Equipment_Make_Craftsmanship_Limit";

function InitModule()

end


--装备是否可以被打造
function IsEquipCanMake(equipMakeId)

    local tempMaterials = {};
    local tempEquipMakeData = EquipMakeData.GetEquipMakeData(equipMakeId);
    local ironItemId = EquipMakeModule.GetQualifiedItem(tempEquipMakeData.materials[m_ironItemIndex].itemId, tempEquipMakeData.materials[m_ironItemIndex].itemCount, tempEquipMakeData.materials[m_ironItemIndex].canReplace);
    tempMaterials[m_ironItemIndex] = ironItemId;

    --制造书不能用高等级的
    local bookCount = BagMgr.GetCountByItemId(tempEquipMakeData.materials[m_bookItemIndex].itemId);
    if bookCount >= tempEquipMakeData.materials[m_bookItemIndex].itemCount then
        tempMaterials[m_bookItemIndex] = tempEquipMakeData.materials[m_bookItemIndex].itemId;
    else
        tempMaterials[m_bookItemIndex] = -1;
    end

    local runeItemId = EquipMakeModule.GetQualifiedItem(tempEquipMakeData.materials[m_runeIndex].itemId, tempEquipMakeData.materials[m_runeIndex].itemCount, tempEquipMakeData.materials[m_runeIndex].canReplace);
    tempMaterials[m_runeIndex] = runeItemId;
    for i = 1, #tempMaterials do
        if tempMaterials[i] == -1 then
            return false
        end
    end
    return true
end
-- --返回Material的Id，为-1是找不到合适的Material
-- function IsMaterialEnough(materialIs,isCanReplace)
-- end
function Init(itemId)
    if itemId == -1 then
        return;
    end
    currentMaterials = {};
    equipMakeData = EquipMakeData.GetEquipMakeData(itemId);
    if equipMakeData == nil then
        return;
    end
    needMaterials = {};
    needMaterials[m_ironItemIndex] = equipMakeData.materials[m_ironItemIndex].itemId;
    needMaterials[m_bookItemIndex] = equipMakeData.materials[m_bookItemIndex].itemId;
    needMaterials[m_runeIndex] = equipMakeData.materials[m_runeIndex].itemId;
    needMaterials[m_intensifyItemIndex] = equipMakeData.exmaterialId;

    local ironItemId = EquipMakeModule.GetQualifiedItem(equipMakeData.materials[m_ironItemIndex].itemId, equipMakeData.materials[m_ironItemIndex].itemCount, equipMakeData.materials[m_ironItemIndex].canReplace);
    currentMaterials[m_ironItemIndex] = ironItemId;

    --local bookItemId = EquipMakeModule.GetQualifiedItem(equipMakeData.materials[m_bookItemIndex].itemId, equipMakeData.materials[m_bookItemIndex].itemCount, equipMakeData.materials[m_bookItemIndex].canReplace);
    --currentMaterials[m_bookItemIndex] = bookItemId;
    --制造书不能用高等级的
    local bookCount = BagMgr.GetCountByItemId(equipMakeData.materials[m_bookItemIndex].itemId);
    if bookCount >= equipMakeData.materials[m_bookItemIndex].itemCount then
        currentMaterials[m_bookItemIndex] = equipMakeData.materials[m_bookItemIndex].itemId;
    else
        currentMaterials[m_bookItemIndex] = -1;
    end

    local runeItemId = EquipMakeModule.GetQualifiedItem(equipMakeData.materials[m_runeIndex].itemId, equipMakeData.materials[m_runeIndex].itemCount, equipMakeData.materials[m_runeIndex].canReplace);
    currentMaterials[m_runeIndex] = runeItemId;

    currentMaterials[m_intensifyItemIndex] = -1;
    currentEquipMakeId = itemId;
end
function GetMaterials()
    return currentMaterials;
end

--改为GetIntensifyMaterial
-- function SetIntensifyMaterial(val)
--     if currentEquipMakeId == -1 then
--         return;
--     end
--     if val then
--         local currentCount = BagMgr.GetCountByItemId(equipMakeData.exmaterialId);
--         if currentCount >= equipMakeData.exmaterialCount then
--             currentMaterials[m_intensifyItemIndex] = equipMakeData.exmaterialId
--         else
--             currentMaterials[m_intensifyItemIndex] = -1;
--         end
--     else
--         currentMaterials[m_intensifyItemIndex] = -1;
--     end
-- end

--获取合适的Item。返回ItemId,如果返回-1，则找不到合适的
function GetQualifiedItem(itemId, requireCount, isCanReplace)
    local currentCount = BagMgr.GetCountByItemId(itemId);
    if currentCount >= requireCount then
        return itemId;
    end
    if not isCanReplace then
        return -1;
    end
    local itemData = ItemData.GetItemInfo(itemId);
    local backUpItemId = GetBackUpItemId(itemData.showlevel, requireCount, itemData.itemInfoType, itemData.childType);
    return backUpItemId;
end

--获取备用Item的Id，返回-1说明找不到合适的Item
function GetBackUpItemId(requireLevel, requireCount, itemType, childType)
    local itemTable = GetSortedItemList(itemType, childType);
    for i = 1, #itemTable do
        if itemTable[i].level >= requireLevel and itemTable[i].count >= requireCount then
            return itemTable[i].tableId;
        end
    end
    return -1;
end

--根据Itemid，类型。获取已经排序过的Item列表。这些Item是在玩家背包中的
function GetSortedItemList(itemType, childType)
    local tempTable = BagMgr.GetItemsByInfoTypeAndChildType(Bag_pb.NORMAL, itemType, childType);
    local itemTable = {};
    for k, v in pairs(tempTable) do
        local item = {};
        item.tableId = v.tempId;
        item.id = v.id;
        item.count = v.count;
        local itemTabelData = ItemData.GetItemInfo(item.tableId);
        item.level = itemTabelData.showlevel;
        table.insert(itemTable, item);
    end
    table.sort(itemTable, function(a, b) return a.level < b.level end)
    return itemTable;
end

function GetCurrenEquipMakeId()
    return currentEquipMakeId;
end


function NormalMake()
    if currentEquipMakeId == -1 then
        return;
    end
    if CheckNormalMaterialEnough() == false then
        return;
    end
    m_IsNormalMake = true;
    if CheckMaterialLevelIsHigherThenRequireAndShowTips() == true then
        return;
    end
    if IsCoinEnough() == false then
        return;
    end
    if IsLevelOutnumber() == true then
        return;
    end
    SendNormalMakePacket();

end

function IntensifyMake()
    if currentEquipMakeId == -1 then
        return;
    end
    if CheckNormalMaterialEnough() == false then
        return;
    end
    if CheckIntensifyMaterialEnough() == false then
        return;
    end
    m_IsNormalMake = false;
    if CheckMaterialLevelIsHigherThenRequireAndShowTips() == true then
        return;
    end
    if IsCoinEnough() == false then
        return;
    end
    if IsLevelOutnumber() == true then
        return;
    end
    SendIntensifyMakePacket();
end




function ContinueNormalMake()
    if IsCoinEnough() == false then
        return;
    end
    if IsLevelOutnumber() == true then
        return;
    end
    SendNormalMakePacket();
end

function ContinueIntensifyMake()
    if IsCoinEnough() == false then
        return;
    end
    if IsLevelOutnumber() == true then
        return;
    end
    SendIntensifyMakePacket();
end


function IsCoinEnough()
    if equipMakeData.money <= BagMgr.GetMoney(Coin_pb.SILVER) then
        return true;
    else
        --消费提示还没有
        return false;
    end
end

function IsLevelOutnumber()
    if UserData.GetLevel() >= equipMakeData.levelLimit then
        return false;
    else
        local content = "等级不够";
        --local content = string.format(WordData.GetWordStringByKey("LevelNotEnough_EquipMake"));
        TipsMgr.TipCommon(content);
        return true;
    end
end


function SendNormalMakePacket()
    local CSMake = NetCS_pb.CSMakeEquip();
    for i = 1, #currentMaterials - 1 do
        local gridTabel = BagMgr.GetGridDataByTempId(Bag_pb.NORMAL, currentMaterials[i]);
        if not gridTabel[1] then
            return;
        end    
        local mt = CSMake.materials:add()
        mt.slotId = gridTabel[1].slotId
        mt.count = 1;
        mt.bagType = Bag_pb.NORMAL;
    end

    CSMake.makeId = currentEquipMakeId;
    CSMake.enhanceMaterialSlotId = -1;
    CSMake.enhanceMaterialCount = -1;
    CSMake.isEnhance = -1;

    GameNet.SendToGate(CSMake);
end

function SendIntensifyMakePacket()
    
    local intensifyGridTabel = BagMgr.GetGridDataByTempId(Bag_pb.NORMAL, currentMaterials[m_intensifyItemIndex]);
    if not intensifyGridTabel[1] then
        return;
    end

    local CSMake = NetCS_pb.CSMakeEquip();
    for i = 1, #currentMaterials - 1 do
        local gridTabel = BagMgr.GetGridDataByTempId(Bag_pb.NORMAL, currentMaterials[i]);
        if not gridTabel[1] then
            return;
        end
        local mt = CSMake.materials:add()
        mt.slotId = gridTabel[1].slotId
        mt.count = 1;
        mt.bagType = Bag_pb.NORMAL;
    end

    CSMake.makeId = currentEquipMakeId;
    CSMake.enhanceMaterialSlotId = intensifyGridTabel[1].slotId;
    CSMake.enhanceMaterialCount = 1;
    CSMake.isEnhance = 1;

    GameNet.SendToGate(CSMake);
    print("SendMakeEquipPacket");
end


function CheckNormalMaterialEnough()
    --判断材料不足
    for i = 1, #currentMaterials - 1 do
        if currentMaterials[i] == -1 then
            --弹tips
            local itemData = ItemData.GetItemInfo(needMaterials[i]);
            if itemData then
                local content = "材料不够";
                --local content = string.format(WordData.GetWordStringByKey("MaterialNotEnough"));
                TipsMgr.TipCommon(content, itemData);
            end
            return false;
        end
    end
    return true;
end    


function CheckIntensifyMaterialEnough()
    local currentCount = BagMgr.GetCountByItemId(equipMakeData.exmaterialId);
    if currentCount >= equipMakeData.exmaterialCount then
        --currentMaterials[m_intensifyItemIndex] = equipMakeData.exmaterialId
        return true;
    else
        --currentMaterials[m_intensifyItemIndex] = -1;
        local itemData = ItemData.GetItemInfo(equipMakeData.exmaterialId);
        if itemData then
            local content = "材料不够";
            --local content = string.format(WordData.GetWordStringByKey("MaterialNotEnough"));
            TipsMgr.TipCommon(content, itemData);
        end
        return false;
    end
end

function CheckMaterialLevelIsHigherThenRequireAndShowTips()
    local needTips = false;
    local nameStrs = "";
    for i = 1, #currentMaterials - 1 do
        if needMaterials[i] ~= currentMaterials[i] then
            local itemData = ItemData.GetItemInfo(needMaterials[i]);
            local itemName = itemData.name
            itemName = " "..itemName
            nameStrs = nameStrs .. itemName;
            needTips = true;
        end       
    end
    if needTips then
            --local str = string.format(WordData.GetWordStringByKey("MaterialLevelIsHigherThenRequire"), nameStrs)
            local str = nameStrs;
            TipsMgr.TipConfirmByStr(str, ContinueMakeFromHighConfirm, StopMake)
            return true;
        else
            return false;
        end
end

--从高品质是否打造中确认回来 继续打造
function ContinueMakeFromHighConfirm()
    if m_IsNormalMake then
        ContinueNormalMake()
    else
        ContinueIntensifyMake()
    end

end

--从高品质是否打造中确认回来 放弃打造
function StopMake()
    return;
end


function IsMakeValueEnough()
    local limit = ConfigData.GetIntValue(m_makeValueConfigDataKey)
    if currentMakeValue and currentMakeValue >= limit then
        return true;
    else
        return false;
    end
end

function AskMakeValueReward()
    local limit = ConfigData.GetIntValue(m_makeValueConfigDataKey)
    if currentMakeValue and currentMakeValue >= limit then
        local CSMake = NetCS_pb.CSAskMakeValueReward();
        GameNet.SendToGate(CSMake);
    else
        --GameLog.LogError("MakeValue is not enough");
        --local content = TipsMgr.TipByKey("MakeValueTips")
        --local title = TipsMgr.GetTipByKey("MakeValue")
        --local content = TipsMgr.GetTipByKey("MakeValue_Msg")
        local title = "巧匠值"
        local content = "MakeValue_Msg"
        TipsMgr.TipDerscribe({title = title,content = content})
    end
end

function SetCurrentMakeValue(val)
    currentMakeValue = val;
end

function GetCurrentMakeValue()
    if currentMakeValue then
        return currentMakeValue;
    else
        return 0;
    end
end

function SCMakeEquipHandler(data)
    GameLog.LogError("SCMakeEquipHandler");
    GameLog.LogError(data.ret);
    currentMakeValue = makeValue
    GameEvent.Trigger(EVT.EQUIPMAKE, EVT.EQUIPMAKE_REFRESH)
end

function SCAskMakeValueRewardHandler(data)
    GameLog.LogError("SCAskMakeValueRewardHandler");
    print(data.ret);
    if data.ret == 1 then
        SetCurrentMakeValue(0);
        GameEvent.Trigger(EVT.EQUIPMAKE, EVT.EQUIPMAKE_RECEIVEMAKEVALUE_REWARD, data)
        GameLog.LogError("AskMakeValueReward success!");
    else
        GameLog.LogError("AskMakeValueReward failed!");
    end
end



return EquipMakeModule