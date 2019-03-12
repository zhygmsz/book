module("GemLevelupMgr", package.seeall)

local mAddExp = 0
local mMaterialList = {}

local mOperateGemInfo = 
{
    gemBagType = 0,
    gemSlotId = 0,
    gemIndex = 0,
}
local mShowLeftEventId = 0

local mCurrShowIndex
local mCurrShowOneIndex
local mCurrShowTwoIndex

local function InitData()
end

function InitModule()
    InitData()
end

local function GetTypeNameByType(gemType)
    if not gemType then
        retunr ""
    end

    if gemType == 0 then
        return WordData.GetWordStringByKey("common_gem0_name")
    elseif gemType == 1 then
        return WordData.GetWordStringByKey("common_gem1_name")
    elseif gemType == 2 then
        return WordData.GetWordStringByKey("common_gem2_name")
    elseif gemType == 3 then
        return WordData.GetWordStringByKey("common_gem3_name")
    elseif gemType == 4 then
        return WordData.GetWordStringByKey("common_gem4_name")
    else
        return ""
    end
end

local function CheckIsEquip(equipData)
    local itemData = ItemData.GetItemInfo(equipData.tempId)

    if itemData ~= nil and itemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
        return true
    end 
    return  false
end

local function MakeList(itemSlotList, outList, bagType)
    if itemSlotList == nil then
        return
    end

    for _, data in ipairs(itemSlotList) do
        if CheckIsEquip(data.item) then
            for _, v in ipairs(data.item.equipInfo.gems) do
                local gemData = ItemData.GetItemInfo(v.gemDataInfo.gemId)
                if gemData and gemData.itemInfoType == Item_pb.ItemInfo.GEMSTONE then
                    local gemData = {}
                    gemData.gemId = v.gemDataInfo.gemId
                    gemData.gemExp = v.gemDataInfo.exp
                    gemData.bagType = bagType
                    gemData.slotId = data.slotId
                    gemData.gemIndex = v.gemPos
                    gemData.itemData = ItemData.GetItemInfo(v.gemDataInfo.gemId)
                    gemData.gemData = GemData.GetGemDataById(v.gemDataInfo.gemId)
                    gemData.equipData = ItemData.GetEquipmentInfo(data.item.tempId)
                    table.insert(outList, gemData)
                end    
            end
        end
    end
end

function GetInlaiedDataList()
    local inlaiedList = {}

    local equipData = BagMgr.BagData[Bag_pb.EQUIP]
    if equipData then
        MakeList(equipData.items, inlaiedList, Bag_pb.EQUIP)
    end

    local bagData = BagMgr.BagData[Bag_pb.NORMAL]
    if bagData then
        MakeList(bagData.items, inlaiedList, Bag_pb.NORMAL)
    end
    return inlaiedList
end

function GetLevelupMaterialList(type)
    local materialList = {}
    local data = BagMgr.BagData[Bag_pb.NORMAL]
    if data == nil then
        return materialList
    end

    for _, slotData in ipairs(data.items) do
        if GemData.GetGemDataById(slotData.item.tempId) and ItemData.GetItemInfo(slotData.item.tempId).childType == type then
            local gemData = {}
            gemData.gemId = slotData.item.tempId
            gemData.count = slotData.item.count
            gemData.gemExp = slotData.item.gemDataInfo.exp
            gemData.gemSlotId = slotData.slotId
            gemData.gemBagType = Bag_pb.NORMAL
            gemData.itemData = ItemData.GetItemInfo(slotData.item.tempId)
            gemData.gemData = GemData.GetGemDataById(slotData.item.tempId)

            table.insert(materialList, gemData)     
        end
    end

    return materialList
end

function GetClassifyList()

    local gemType = -1
    local mianList = {}
    local gemList = GetInlaiedDataList()
    table.sort(gemList, function (a, b)
        return a.itemData.childType < b.itemData.childType
    end)
    local typeList = {}
    for _, data in ipairs(gemList) do
        if gemType ~= data.itemData.childType then
            gemType = data.itemData.childType
            table.insert(typeList, gemType)
        end
    end

    for index, type in ipairs(typeList) do
        local lt = {}
        lt.titleName = GetTypeNameByType(type)
        lt.type = type
        lt.list = {}
        for i, gemData in ipairs(gemList) do
            if gemData.itemData.childType == type then
                local vo = {}
                vo.isAdd = false
                vo.gemId = gemData.itemData.id
                vo.itemData = gemData.itemData
                vo.gemData = gemData.gemData
                vo.equipData = gemData.equipData
                vo.gemIndex = gemData.gemIndex
                vo.slotId = gemData.slotId
                vo.bagType = gemData.bagType
                vo.gemExp = gemData.gemExp
                table.insert(lt.list, vo)
            end
        end

        table.insert(mianList, lt)
    end

    return mianList
end

function SetAddExp(data, isAdd, index)
    if not data then
        return 
    end

    if isAdd then
        mAddExp = mAddExp + data.gemExp * data.count
        local lt = {}
        lt.gemBagType = data.gemBagType
        lt.gemSlotId = data.gemSlotId
        lt.count = data.count
        table.insert(mMaterialList, lt)
    else
        mAddExp = mAddExp - data.gemExp * data.count
        table.remove(mMaterialList, index)
    end

    if mAddExp <= 0  then 
        mAddExp = 0 
        MessageSub.SendMessage(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_CANCEL)
    end

    if mAddExp >= 0 then
        MessageSub.SendMessage(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_MATCHANGE)
    end
end

function GetMaterialList()
    return mMaterialList
end

function GetAddExp()
    return mAddExp
end

function ReSetMaterialList()
    mAddExp = 0
    mMaterialList = {}
end

--请求宝石升级
function RequestCSGemCompose(gemBagType, gemSlotId, gemIndex, tarGemTempId, tarGemLevel, gemMaterial)
    local msg = NetCS_pb.CSGemCompose()
    msg.gemBagType = gemBagType
    msg.gemSlotId = gemSlotId
    msg.gemIndex = gemIndex
    msg.tarGemTempId = tarGemTempId
    msg.tarGemLevel = tarGemLevel
    for _, data in ipairs(gemMaterial) do
        local mt = msg.gemMaterial:add()
        mt.gemBagType = data.gemBagType
        mt.gemSlotId = data.gemSlotId
        mt.count = data.count
    end
    msg.isOnEquip = true

    GameNet.SendToGate(msg)
end

--宝石升级返回
function OnSCGemCompose(data)
    if data.result == 0 then
        MessageSub.SendMessage(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_LEVELUP, data)
        ReSetMaterialList()

        TipsMgr.TipByKey("gem_update_success")
    else
        GameLog.LogError("Gem level up Error !")
    end 
end

function GetGemDataListById(gemId)
    local dataList = {}
    local gemDataList = GemData.GetGemDataList()
    local aimData = ItemData.GetItemInfo(gemId)
    for _, gemdata in ipairs(gemDataList) do
        local itemData = ItemData.GetItemInfo(gemdata.id)
        if itemData.childType == aimData.childType then
            table.insert(dataList, gemdata)
        end
    end

    table.sort(dataList, function (a, b)
        return a.exp < b.exp
    end)

    return dataList
end

function GetGemLevelByExp(id, exp)
    local level = 0 
    local gemId = 0
    local gemList = GetGemDataListById(id)
    for _, data in ipairs(gemList) do
        if exp >= data.exp then
            level =  data.level
            gemId = data.id
        end
    end
    return level, gemId
end

function SetOprerateId(bagType, slotId, index)
    mOperateGemInfo.gemBagType = bagType
    mOperateGemInfo.gemSlotId = slotId
    mOperateGemInfo.gemIndex = index
end

function GetOprerateId()
    return mOperateGemInfo
end

function SetLeftEventId(eventId)
    mShowLeftEventId = eventId
end

function GetLeftEventId()
    return mShowLeftEventId
end

function SetOneIndex(index)
    mCurrShowIndex = index
end

function SetTwoIndex(oneIndex, twoIndex)
    mCurrShowOneIndex = oneIndex
    mCurrShowTwoIndex = twoIndex
end

--通过不分类视图的index 获得分类视图的两个一级index 和 二级index
function GetTwoIndex()
    local dataList = GetInlaiedDataList()
    local classifyList = GetClassifyList()

    if dataList[mCurrShowIndex] == nil then
        return 
    end

    for i, v in ipairs(classifyList) do
        for k, data in ipairs(v.list) do
            if dataList[mCurrShowIndex].bagType == data.bagType and dataList[mCurrShowIndex].slotId == data.slotId and dataList[mCurrShowIndex].gemIndex == data.gemIndex then
                return i, k
            end 
        end
    end

    return nil, nil
end

--通过分类视图的两个index 获得 不分类视图的一个index
function GetOneIndex(oneIndex, twoIndex)
    local dataList = GetInlaiedDataList()
    local classifyList = GetClassifyList()

    local list1 = classifyList[mCurrShowOneIndex]

    if list1 == nil then
        return 
    end
    local list2 = list1.list[mCurrShowTwoIndex]
    if list2 then
        for i, v in ipairs(dataList) do
            if list2.bagType == v.bagType and list2.slotId == v.slotId and list2.gemIndex == v.gemIndex then
                return  i
            end
        end
    end

    return nil
end

return GemLevelupMgr