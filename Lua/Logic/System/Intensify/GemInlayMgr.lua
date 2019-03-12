--强化-宝石镶嵌
module("GemInlayMgr", package.seeall)

--变量
--数据只初始化一次控制字段
local mOnlyOneTimeIsInited = false

--装备部位与可镶嵌宝石类型映射，在第一次打开界面时，遍历宝石表建立该结构
local mEquipBody2GemTypeDic = {}

--宝石二级分类相关的信息
local mGemTypeInfoDic = 
{
    [0] = { gemType = 0, name = WordData.GetWordStringByKey("common_gem0_name"), 
            proId = 50, proName = "", itemId = 200100001, itemData = nil },
    [1] = { gemType = 1, name = WordData.GetWordStringByKey("common_gem1_name"), 
            proId = 54, proName = "", itemId = 201100001, itemData = nil },
    [2] = { gemType = 2, name = WordData.GetWordStringByKey("common_gem2_name"), 
            proId = 62, proName = "", itemId = 202100001, itemData = nil },
    [3] = { gemType = 3, name = WordData.GetWordStringByKey("common_gem3_name"), 
            proId = 58, proName = "", itemId = 203100001, itemData = nil },
    [4] = { gemType = 4, name = WordData.GetWordStringByKey("common_gem4_name"), 
            proId = 66, proName = "", itemId = 204100001, itemData = nil },
}

--装备类型到一二级列表的映射，该结构在界面第一次打开时初始化，并以只读方式提供给UI的右侧列表
local mBodyType2OneTwoDataList = {}

--是否有必要为左侧的装备建立一个缓存


--local方法
local function LogProto(msg)
    GameLog.LogProto(msg)
end

local function AddEquipBody2GemType(equipBody, gemData)
    if not mEquipBody2GemTypeDic[equipBody] then
        mEquipBody2GemTypeDic[equipBody] = {}
    end
    local itemData = ItemData.GetItemInfo(gemData.id)
    if itemData then
        mEquipBody2GemTypeDic[equipBody][itemData.childType] = itemData.childType
    end
end

--[[
    @desc: 遍历宝石表，建立装备部位和可镶嵌宝石类型映射
    --待做项
    --如果装备表也附带可镶嵌宝石类型列表，则不需要这个结构，在表格层面维护了双向查询
    --增加了表格关联逻辑，方便了程序
]]
local function InitEquipBody2GemTypeDic()
    local gemDataList = GemData.GetGemDataList()
    for _, gemData in ipairs(gemDataList) do
        for _, equipBody in ipairs(gemData.equipBodys) do
            AddEquipBody2GemType(equipBody, gemData)
        end
    end
end

--[[
    @desc: 遍历mGemTypeInfoDic，根据proId获取属性名字
]]
local function InitGemTypeInfoDic()
    local proData = nil
    local itemData = nil
    for _, info in pairs(mGemTypeInfoDic) do
        proData = AttDefineData.GetDefineData(info.proId)
        itemData = ItemData.GetItemInfo(info.itemId)
        if proData and itemData then
            info.proName = proData.name
            info.itemData = itemData
        end
    end
end

local function GetGemTypeListByEquipBody(equipBody)
    if equipBody then
        return mEquipBody2GemTypeDic[equipBody]
    else
        return nil
    end
end

local function MakeOneTwoDataList(bodyType)
    local oneTwoDataList = {}
    local gemTypeList = GetGemTypeListByEquipBody(bodyType)
    if gemTypeList then
        --待实现
        --对宝石类型本身，按照其枚举从小到大的排序方式
        --放到创建gemtypelist的地方更好
        for typeIdx, gemType in pairs(gemTypeList) do
            local oneList = {}
            table.insert(oneList, {isAdd = true, gemTypeInfo = mGemTypeInfoDic[gemType]})
            table.insert(oneTwoDataList, {gemTypeInfo = mGemTypeInfoDic[gemType], list = oneList})
        end
    end
    return oneTwoDataList
end

local function InitBodyType2OneTwoDataList()
    --待实现
    --读枚举更好
    local bodyTypeNum = 8
    for bodyType = 1, bodyTypeNum do
        mBodyType2OneTwoDataList[bodyType] = MakeOneTwoDataList(bodyType)
    end
end

local function GetOneTwoDataListByBodyType(bodyType)
    if bodyType then
        return mBodyType2OneTwoDataList[bodyType]
    else
        return nil
    end
end

--[[
    @desc: 只初始化一次逻辑外壳
]]
local function InitDataOnlyOneTime()
    if mOnlyOneTimeIsInited then
        return
    else
        mOnlyOneTimeIsInited = true

        InitEquipBody2GemTypeDic()
        InitGemTypeInfoDic()
        InitBodyType2OneTwoDataList()
    end
end

--[[
    @desc: 检查该装备是否可被镶嵌，可镶嵌宝石数量大于0
    --@equipItem: Item_pb.Item
]]
local function CheckEquipCanInlay(equipItem)
    local canInlay = false

    local itemData = ItemData.GetItemInfo(equipItem.tempId)
    local equipData = ItemData.GetEquipmentInfo(equipItem.tempId)
    if itemData and itemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
        canInlay = equipData and equipData.gemCount > 0
    end

    return canInlay
end

--[[
    @desc: 检测宝石是否可以用于镶嵌
    --@tableData: 一行宝石表数据
    --@maxLevel: 装备能接受的宝石最高等级
]]
local function CheckGemCanInlay(gemItemSlot, maxLevel)
    local canInlay = false

    repeat
        if not gemItemSlot or not maxLevel then
            break
        end
        local tableData = GemData.GetGemDataById(gemItemSlot.item.tempId)
        if not tableData then
            break
        end
        canInlay = tableData.level <= maxLevel
    until true

    return canInlay
end

--[[
    @desc: 
    --@itemSlotList:
    --@isEquiped: 是否已经装备上
    --@equipList: 输出列表
]]
local function MakeCanInlayEquipList(itemSlotList, isEquiped, equipList)
    for _, itemSlot in ipairs(itemSlotList) do
        if CheckEquipCanInlay(itemSlot.item) then
            local data = {}
            data.isEquiped = isEquiped
            if isEquiped then
                data.bagType = Bag_pb.EQUIP
            else
                data.bagType = Bag_pb.NORMAL
            end
            data.itemSlot = itemSlot
            data.itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
            data.equipData = ItemData.GetEquipmentInfo(itemSlot.item.tempId)
    
            table.insert(equipList, data)
        end
    end
end

--[[
    @desc: 把宝石数据镶嵌到装备上
]]
local function InlayGemToEquip(data)
    if not data then
        return
    end
    local itemSlot = BagMgr.GetBagSlotItemWitnIndex(data.slotId, data.bagType)
    if not itemSlot then
        GameLog.LogError("GemInlayMgr.InlayGemToEquip -> itemSlot is nil, slotId = %s, bagType = %s", data.slotId, data.bagType)
        return
    end
    local existInfo = nil
    for _, equipGemInfo in ipairs(itemSlot.item.equipInfo.gems) do
        if equipGemInfo.gemPos == data.gemPos then
            existInfo = equipGemInfo
            break
        end
    end
    
    if existInfo then
        --计算属性差，并提示
        existInfo.gemDataInfo:ParseFrom(data.gemDataInfo)
        --提示
        TipsMgr.TipByKey("gem_change_success")
    else
        local newInfo = itemSlot.item.equipInfo.gems:add()
        newInfo.gemPos = data.gemPos
        newInfo.gemDataInfo:ParseFrom(data.gemDataInfo)
        --计算属性差，并提示
        --提示
        TipsMgr.TipByKey("gem_inlay_success")
    end
end

--[[
    @desc: 从装备上卸下宝石
]]
local function RemoveGemFromEquip(data)
    if not data then
        return
    end
    local itemSlot = BagMgr.GetBagSlotItemWitnIndex(data.slotId, data.bagType)
    if not itemSlot then
        GameLog.LogError("GemInlayMgr.RemoveGemFromEquip -> itemSlot is nil, slotId = %s, bagType = %s", data.slotId, data.bagType)
        return
    end
    local existKey = nil
    local existInfo = nil
    for key, equipGemInfo in ipairs(itemSlot.item.equipInfo.gems) do
        if equipGemInfo.gemPos == data.gemPos then
            existKey = key
            existInfo = equipGemInfo
            break
        end
    end
    if existKey then
        --计算属性差，并提示
        itemSlot.item.equipInfo.gems:remove(existKey)
        --提示
        TipsMgr.TipByKey("gem_demount_success")
    else
        GameLog.LogError("GemInlayMgr.RemoveGemFromEquip -> existKey is nil")
    end
end

--[[
    @desc: 可镶嵌装备列表，自定义排序规则
    装备类型  > 普通类型
    装备类型里，按照装备UI的自左向右，自上向下顺序
    普通类型里，按照slotid从小到大顺序
    --@data:
]]
local function CalEquipScore(data)
    local score = 0
    if data.isEquiped then
        score = -1000 + EquipMgr.Bodytype2Index[data.equipData.bodyType]
    else
        score = data.itemSlot.slotId
    end
    return score
end

--[[
    @desc: 
    --@left:
	--@right: 
]]
local function CustomSort(left, right)
    local leftScore = CalEquipScore(left)
    local rightScore = CalEquipScore(right)
    return leftScore < rightScore
end

local function InitData()
end

function InitModule()
    InitData()
end

--消息收发
--[[
    @desc: 请求宝石镶嵌
]]
function CSInlayGem(equipBagType, equipSlotId, gemPos, gemBagType, gemSlotId)
    local msg = NetCS_pb.CSInsetGem()
    msg.equipBagType = equipBagType
    msg.equipSlotId = equipSlotId
    msg.gemPos = gemPos
    msg.gemBagType = gemBagType
    msg.gemSlotId = gemSlotId
    GameNet.SendToGate(msg)

    LogProto(msg)
end

--[[
    @desc: 宝石镶嵌返回
]]
function SCInlayGem(data)
    LogProto(data)

    if data.ret == 0 then
        InlayGemToEquip(data)
        MessageSub.SendMessage(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_INLAY, data)
    else
        GameLog.LogError("GemInlayMgr.SCInlayGem -> data.ret = %s", data.ret)
    end
end

--[[
    @desc: 请求卸下宝石
]]
function CSRemoveGem(fromType, fromSlotId, gemPos)
    local msg = NetCS_pb.CSRemoveGem()
    msg.fromType = fromType
    msg.fromSlotId = fromSlotId
    msg.gemPos = gemPos
    GameNet.SendToGate(msg)

    LogProto(msg)
end

--[[
    @desc: 卸下宝石返回
]]
function SCRemoveGem(data)
    LogProto(data)

    if data.ret == 0 then
        RemoveGemFromEquip(data)
        MessageSub.SendMessage(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_REMOVE, data)
    else
        GameLog.LogError("GemInlayMgr.SCRemoveGem -> data.ret = %s", data.ret)
    end
end

--服务UI
--[[
    @desc: 获取可镶嵌的装备列表
]]
function GetCanInlayEquipList()
    --考虑维护一个持久的对象，监听装备的变化
    --并且以插入排序的方式保证其一直处于有序状态
    --不再每次打开UI时，组建新list，只需要获取已有数据，并刷到UI上即可
    local canInlayEquipList = {}

    --先处理已装备的
    local equipData = BagMgr.BagData[Bag_pb.EQUIP]
    if equipData then
        --按照装备槽位从小到大排序处理
        MakeCanInlayEquipList(equipData.items, true, canInlayEquipList)
    end

    --普通背包里的
    local bagData = BagMgr.BagData[Bag_pb.NORMAL]
    if bagData then
        MakeCanInlayEquipList(bagData.items, false, canInlayEquipList)
    end

    table.sort(canInlayEquipList, CustomSort)

    return canInlayEquipList
end

--[[
    @desc: 获取一二级列表数据
    --@itemId: 
]]
function GetOneTwoDataList(itemId)
    InitDataOnlyOneTime()

    --根据当前选中的装备，筛选其能镶嵌的宝石种类
    local equipData = ItemData.GetEquipmentInfo(itemId)
    local oneTwoDataList = GetOneTwoDataListByBodyType(equipData.bodyType)
    return oneTwoDataList
end

function ExpandOneItem(oneTwoDataList, oneDataIdx, maxGemLevel)
    if not oneTwoDataList or not oneDataIdx then
        return
    end
    local oneData = oneTwoDataList[oneDataIdx]
    if not oneData then
        return
    end

    --先清空（保留第一个isAdd）
    local len = #oneData.list
    if len > 1 then
        for idx = 2, len do
            table.remove(oneData.list)
        end
    end
    --装载新的
    local gemItemSoltList = BagMgr.GetGemItemSlotList(oneData.gemTypeInfo.gemType)
    if not gemItemSoltList then
        return
    end
    for _, gemItemSlot in ipairs(gemItemSoltList) do
        if CheckGemCanInlay(gemItemSlot, maxGemLevel) then
            table.insert(oneData.list, gemItemSlot)
        end
    end
end

return GemInlayMgr