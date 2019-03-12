module("BagMgr",package.seeall);

--获取背包的剩余格子数
function GetBagLeftSlotNumber(bagType)
    mCurrentBagData = BagMgr.BagData[bagType]
    if mCurrentBagData then
        local N= table.getn(mCurrentBagData.items)
        local left =mCurrentBagData.maxSlots-N
        return left
    end
    return 0
end

--背包格子下限
function GetMinGridCount(bagType)
    if bagType == Bag_pb.NORMAL then 
        return 30;
    elseif bagType == Bag_pb.EQUIP then
        return 10;
    elseif bagType >= Bag_pb.DEPOT1 and bagType<= Bag_pb.DEPOT12 then 
        return   30;
    elseif bagType == Bag_pb.TEMP then 
        return  16 
    else    
        return 0;
    end
end

--背包格子上限
function GetMaxGridCount(bagType)
    if bagType == Bag_pb.NORMAL then 
        local n = ConfigData.GetIntValue("Bag_everytime_unlock_lattice") or 5
        return ConfigData.GetIntValue("Bag_unlock_number")*n+ConfigData.GetIntValue("Bag_default_open_lattice")-- ConfigData.GetIntValue("Bag_max_count_lattice") or 30;
    elseif bagType == Bag_pb.EQUIP then 
        return 10;
    elseif bagType >= Bag_pb.DEPOT1 and bagType<= Bag_pb.DEPOT12 then 
        return  ConfigData.GetIntValue("Warehouse_page_lattice") or 30;
    elseif bagType == Bag_pb.TEMP then 
        return ConfigData.GetIntValue("Bag_temporary_page_lattice") or 16 
    else    
        return 0;
    end
end

--已解锁背包格子上限
function GetOpenGridCount(bagType)
    if BagData[bagType] then
        return BagData[bagType].maxSlots
    end
end

--整理背包的CD
function GetArrangementCd()
    return ConfigData.GetIntValue("Bag_arrangement_cd") or 10 
end

--获取显示的格子信息 给背包UI逻辑使用
function GetGridDatas(bagType,filterID)
    local mCurrentBagData = BagData[bagType]
    if mCurrentBagData==nil then
        return {};
    end
    local filterItems = {}
    local MAX_GRID_COUNT = GetMaxGridCount(bagType)
    local MAXItemNum = mCurrentBagData.maxSlots+ConfigData.GetIntValue("Bag_lock_display_number")
    if MAXItemNum > MAX_GRID_COUNT then MAXItemNum=MAX_GRID_COUNT end
    filterID = -1*filterID
    if filterID==1 then
        for i=1, MAXItemNum do
            table.insert(filterItems,{})
            filterItems[i].item = nil
            filterItems[i].itemData = nil
            filterItems[i].slotId = -1
            if i <= mCurrentBagData.maxSlots then
             filterItems[i].lock = false;
            else
             filterItems[i].lock = true;
            end
         end
         for i=1,#mCurrentBagData.items do
            --类型为BagItemSlot
            local titem = mCurrentBagData.items[i]
            if titem and titem.item and titem.item.count>0 then
                --类型为 Item_Pb.Item
                filterItems[titem.slotId+1].item = titem.item
                filterItems[titem.slotId+1].titem = titem
                filterItems[titem.slotId+1].slotId = titem.slotId
                --物品id
                local stuffid = titem.item.tempId
                --物品信息 Item_Pb.ItemInfo
                local itemData = ItemData.GetItemInfo(stuffid);
                filterItems[titem.slotId+1].itemData = itemData
            end
        end
    else
        for i=1,#mCurrentBagData.items do
            local titem = mCurrentBagData.items[i]
            if titem and titem.item and titem.item.count>0 then
                --物品id
                local stuffid = titem.item.tempId
                --物品信息
                local itemData = ItemData.GetItemInfo(stuffid);
                if itemData then
                    for i,v in ipairs(FILTER_K_V[filterID]) do
                        if itemData.itemInfoType == v then
                            table.insert(filterItems,{item =titem.item, titem = titem, slotId =titem.slotId, itemData = itemData,lock=false})
                        end
                    end
                end
            end
        end
        local function SortBySlot(a,b)
			return a.slotId < b.slotId;
		end
		table.sort(filterItems,SortBySlot);
    end
    if BagGridData[bagType]==nil then
        BagGridData[bagType] ={}
    end
    BagGridData[bagType][filterID] = filterItems
    --过滤出来的数据在前边,后续补充空数据
    --local tmpItem = Item_pb.Item();
    return filterItems;
end

--获取下一个打开的仓库
function GetNextDepot(bagType)
    local tbagType = bagType - Bag_pb.DEPOT1+1
    local Max = Bag_pb.DEPOT_SIZE- Bag_pb.DEPOT1+1
    for i=1,Max-1 do
        local next = (tbagType+i-1)%Max+1
        next = next + Bag_pb.DEPOT1-1
        if BagData[next] and BagData[next].isOpen then
            i=Max
            return next
        end
    end
    return bagType
end

--获取上一个打开的仓库
function GetLastDepot(bagType)
    bagType = bagType - Bag_pb.DEPOT1+1
    local Max = Bag_pb.DEPOT_SIZE- Bag_pb.DEPOT1+1
    for i=Max-1,1,-1 do
        local next = (bagType+i-1)%Max+1
        next = next + Bag_pb.DEPOT1-1
        if BagData[next] and BagData[next].isOpen then
            i=0
            return next
        end
    end
    return bagType
end

--仓库对象
function GetBagBaseInfo(bagType)
    local mCurrentBagData = BagData[bagType]
    return mCurrentBagData;
end

--仓库名字
function GetDEPOTName(bagType)
    local mCurrentBagData = BagData[bagType]
    local defaultName =  TipsMgr.GetTipByKey("Warehouse_unlock_name",bagType-Bag_pb.DEPOT1+1)
    if mCurrentBagData==nil or mCurrentBagData.name =="" then
        return defaultName
    end
    return mCurrentBagData.name;
end

--背包里下一个装备的data索引
function GetNextEquipDataIndex(bagType,filterID,curIndex)
    local curgriddatas = GetGridDatas(bagType,filterID)
    local N = #curgriddatas
    for i = 1,N do
        curIndex = curIndex + 1
        if curIndex > N then
            curIndex = 1
        end
        local gridData = curgriddatas[curIndex]
        if gridData.itemData and gridData.itemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
            return curIndex
        end
    end
    return -1
end

--背包里上一个装备的data索引
function GetLastEquipDataIndex(bagType,filterID,curIndex)
    local curgriddatas = GetGridDatas(bagType,filterID)
    local N = #curgriddatas
    for i = 1,N do
        curIndex = curIndex - 1
        if curIndex < 1 then
            curIndex = N
        end
        local gridData = curgriddatas[curIndex]
        if gridData.itemData and gridData.itemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
            return curIndex
        end
    end
    return -1
end

--获取背包某个类型的物品最大位置
function GetMaxDataID(bagType, filterID)
    local filterItems = BagGridData[bagType][filterID]
    if not filterItems then
        filterItems = GetGridDatas(bagType, filterID)
    end
    local maxDataID = -1
    for idx = #filterItems, 1, -1 do
        local item = filterItems[idx]
        if item and item.itemData and item.item then
            maxDataID = idx
            break
        end
    end
    return maxDataID
end

--道具在哪个格子里
function GetGridIndex(item,bagType)
    if item then
        bagType = bagType or Bag_pb.NORMAL;
        local mCurrentBagData = BagData[bagType]
        local items = mCurrentBagData.items
        for i = 1,#items do
            if items[i].slotId == item.slotId then
                return i;
            end
        end
    end
    return -1;
end

--根据slotid获取物品
function GetBagSlotItemWitnIndex(slotId,bagType)
    bagType = bagType or Bag_pb.NORMAL;
    local mCurrentBagData = BagData[bagType]
    local items = mCurrentBagData.items
    for i = 1,#items do
        if items[i].slotId == slotId then
            return items[i];
        end
    end
    return nil;
end

--获取解锁背包格子的价格
function GetUnlockPackagePrice()
    local mCurrentBagData = BagData[Bag_pb.NORMAL]
    local count =mCurrentBagData.unLockCount+1
    local price = ConfigData.GetIntValue(string.format("Bag_unlock_count_price_%d",count)) or 0
    return price
end

--获取解锁背包格子的价格
function GetUnlockDepotPrice()
    return ConfigData.GetIntValue("Warehouse_everytime_unlock_price")
end

--货币
function GetMoney(moneyType)
    if moneyType == Coin_pb.SILVER then
        return BagData.silverCount or 0;
    elseif moneyType ==  Coin_pb.INGOT then
        return BagData.ingotCount or 0;
    elseif moneyType ==  Coin_pb.GOLD then
        return BagData.goldCount or 0;
    else
        return 0;
    end
end

--==============================--
--desc:返回物品数量，该方法只遍历Bag_pb.NORMAL类型背包
--@tempId:物品表id
--==============================--
function GetCountByItemId(tempId)
    if not tempId then
        return 0
    end
    return GetCountByTypeAndId(Bag_pb.NORMAL, tempId)
end

--==============================--
--desc:返回物品数量
--@type:背包类型
--@tempId:物品表id
--==============================--
function GetCountByTypeAndId(type, tempId)
    if not type or not tempId then
        return 0
    end
    local bagData = BagData[type]
    if not bagData then
        return 0
    end
    local count = 0
    for _, itemSlot in ipairs(bagData.items) do
        if itemSlot.item.tempId == tempId then
            count = count + itemSlot.item.count
        end
    end
    return count
end

--==============================--
--desc:返回物品数量
--@tempId:物品表id
--==============================--
function GetCountByItemIdInAllBags(tempId)
    
end

--[[
    @desc: 获取对应分类的列表
    --@gemType: 宝石二级分类
]]
function GetGemItemSlotList(gemType)
    if gemType and mGemTypeDic[gemType] then
        return mGemTypeDic[gemType]
    else
        return nil
    end
end

--[[
    @desc: 根据物品的主类型和子类型获取背包内的符合该条件的列表
    --@mainType: 主类型
     --@childType: 子类型
]]
function GetItemListByType(mainType, childType, bagType)
    bagType = bagType or Bag_pb.NORMAL
    if mainType == nil or childType == nil then
        GameLog.LogError("Param Error !")
        return nil
    end

    local bagData = BagData[bagType]

    local itemList = {}
    for _, itemSlot in ipairs(bagData.items) do
        local itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
        if itemData.itemInfoType == mainType and itemData.childType == childType then
            table.insert(itemList, itemSlot)
        end
    end

    return itemList
end

--获取货币兑换比例
function GetCoinExchangeRate(from,target)
    --元宝=100金币
    local ingotgold = ConfigData.GetIntValue("bag_exchange_cashtogold") or 100
    --金币=100银币
    local goldsilver = ConfigData.GetIntValue("bag_exchange_goldtosilver") or 100
    --元宝=10000银币
    local ingotsilver = ingotgold*goldsilver
    if from == Coin_pb.INGOT and target == Coin_pb.GOLD then
        rate = ingotgold
    elseif from == Coin_pb.INGOT and target == Coin_pb.SILVER then
        rate = ingotsilver
    elseif from == Coin_pb.GOLD and target == Coin_pb.SILVER then
        rate =goldsilver
    end
    return rate
end

--获取货币名称
function GetCoinName(coinType)
    local key = coinType == Coin_pb.INGOT and "bag_coin_ingot" or coinType == Coin_pb.SILVER and "bag_coin_silver" or "bag_coin_gold"
    if key then
        return TipsMgr.GetTipByKey(key)
    end
    return TipsMgr.GetTipByKey("bag_coin_gold")
end

--获取货币图片名称
function GetCoinIconName(coinType)
    local itemid = 703000001
    if coinType == Coin_pb.INGOT then
        itemid=703000001
    --金币
    elseif coinType == Coin_pb.GOLD then
        itemid=702000001
    --银币
    elseif coinType == Coin_pb.SILVER then
        itemid=701000001
    end
    local itemData = ItemData.GetItemInfo(itemid);
    return itemData.icon_big
end

--获取快捷使用对象
function GetQuickUseObj()
    return mQuickUseObj
end

--根据道具类型 子类型查找道具 
function GetItemsByInfoTypeAndChildType(bagType,itemInfoType,childType)
    local mCurrentBagData = BagData[bagType]
    local temptable ={}
    for i=1,#mCurrentBagData.items do
        --类型为BagItemSlot
        local bagGrid = mCurrentBagData.items[i]
        if bagGrid and bagGrid.item and bagGrid.item.count>0 then
            --物品id
            local stuffid = bagGrid.item.tempId
            --物品信息
            local itemData = ItemData.GetItemInfo(stuffid);
            if itemData.itemInfoType == itemInfoType and itemData.itemInfoType == itemInfoType then
                --类型为 Item_Pb.Item
                table.insert(temptable,bagGrid.item)
            end
        end
    end
    return temptable
end

--根据物品id 获取背包格子信息
function GetGridDataByTempId(bagType,tempId)
    local mCurrentBagData = BagData[bagType]
    local temptable ={}
    for i=1,#mCurrentBagData.items do
        --类型为BagItemSlot
        local bagGrid = mCurrentBagData.items[i]
        if bagGrid and bagGrid.item and bagGrid.item.count>0 then
            --物品id
            if tempId == bagGrid.item.tempId then
                --类型为 Item_Pb.Item
                table.insert(temptable, bagGrid)
            end
        end
    end
    return temptable
end