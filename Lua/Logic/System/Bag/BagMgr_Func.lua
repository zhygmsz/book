module("BagMgr",package.seeall);

--排序函数
function SortWithSlotId(array)
	table.sort(array, function(a, b) return a.slotId < b.slotId end)
end

--[[
    @desc: 计算一个宝石物品的排序权重
    --@gem: 
]]
function CalGemSortScore(gem)
    local score = 0
    if gem then
        local gemData = GemData.GetGemDataById(gem.item.tempId)
        if gemData then
            score = 1000 * gemData.level + gem.slotId
        end
    end
    return score
end

--[[
    @desc: 以插入排序的方式动态维护宝石列表顺序
    宝石等级从小到大顺序
    同等级宝石，按照slotid从小到大顺序
    --@gemList:
	--@gem: 
]]
function CustomInsertOneGem(gemList, gem)
    if not gemList or not gem then
        return
    end
    local targetIdx = 1
    local len = #gemList
    local gemScore = CalGemSortScore(gem)
    local score = 0
    for idx = len, 0, -1 do
        score = CalGemSortScore(gemList[idx])
        if gemScore >= score then
            targetIdx = idx + 1
            break
        end
    end
    table.insert(gemList, targetIdx, gem)
end

--解锁格子
function UnlockPackageGrid(tempId)
    local openlevel =  ConfigData.GetIntValue("Bag_open_level") or 50
    if UserData.GetLevel() >= openlevel then
        local function UnLockFunc()
            if GetMoney(Coin_pb.SILVER) < BagMgr.GetUnlockPackagePrice() then
                TipsMgr.TipByKey("backpack_info_2")
                SupplyExchangeCoin(Coin_pb.SILVER,BagMgr.GetUnlockPackagePrice()-GetMoney(Coin_pb.SILVER),BagMgr.RequestUnlockBagGrid,tempId)
            else
                BagMgr.RequestUnlockBagGrid(tempId)
            end
        end
        --解锁背包
        local content = TipsMgr.GetTipByKey("bag_unlock_content")
        local title = TipsMgr.GetTipByKey("bag_unlock_title")
        local price = BagMgr.GetUnlockPackagePrice()
        UI_Tip_UnLockBag.ShowTip(title,content,price,UnLockFunc,nil)
    else
        TipsMgr.TipByKey("backpack_info_1")
    end
end

--解锁仓库
function UnlockDepot()
     --解锁仓库
    local price =ConfigData.GetIntValue("Warehouse_everytime_unlock_price") or 0;
    local function okfunc(iprice)
        if GetMoney(Coin_pb.SILVER) < iprice then
            TipsMgr.TipByKey("backpack_info_2")
            SupplyExchangeCoin(Coin_pb.SILVER,price-GetMoney(Coin_pb.SILVER),BagMgr.RequestUnlockDepot)
        else
            BagMgr.RequestUnlockDepot()
        end
    end
    local content = TipsMgr.GetTipByKey("Warehouse_unlock_content")
    local title = TipsMgr.GetTipByKey("Warehouse_unlock_title")
    UI_Tip_UnLockBag.ShowTip(title,content,price,okfunc,nil)
end

--物品是否可堆叠
function CheckSuperPosotion(itemid)
    if itemid then
        local itemData = ItemData.GetItemInfo(itemid);
        if itemData and (itemData.maxSuperPosition==nil or itemData.maxSuperPosition<=1) then 
            return false
        end
        return true
    end
    return false
end

--背包是否已经满了
function IsFull(bagType,itemid)
    local mCurrentBagData = BagData[bagType]
    if mCurrentBagData then
        if itemid and CheckSuperPosotion(itemid) then
            local itemData = ItemData.GetItemInfo(itemid);
            local max =itemData.maxSuperPosition
            for i=1,#mCurrentBagData.items do
                --类型为BagItemSlot
                local titem = mCurrentBagData.items[i]
                if titem and titem.item and titem.item.tempId==itemid then
                    --有格子没满
                    if titem.item.count < max then
                        return false
                    end
                end
            end
            return true
        else
            local currentNUm =table.getn(BagData[bagType].items)
            return currentNUm>=BagData[bagType].maxSlots
        end
    end
end


--背包是否能装进多少物品
function CanPutIn(bagType,itemid,count)
    local mCurrentBagData = BagData[bagType]
    if mCurrentBagData then
        if itemid and CheckSuperPosotion(itemid) then
            local itemData = ItemData.GetItemInfo(itemid);
            local max =itemData.maxSuperPosition
            local empty = 0
            for i=1,#mCurrentBagData.items do
                --类型为BagItemSlot
                local titem = mCurrentBagData.items[i]
                if titem and titem.item and titem.item.tempId==itemid then
                    empty =empty+ titem.item.count
                    if empty >=count then
                        return true
                    end
                end
            end
            return false
        else
            local currentNUm =table.getn(BagData[bagType].items)
            local left = BagData[bagType].maxSlots - currentNUm
            return left>=count
        end
    end
end

--背包是否空
function IsEmpty(bagType)
    if BagData[bagType] then
        local currentNUm =table.getn(BagData[bagType].items)
        return currentNUm<=1
    end
end

--背包更新操作
function DoBagOperation(bagType,oper)
    -- body
    local mCurrentBagData = BagData[bagType]
    if mCurrentBagData then
        local changeNum=0
        if oper.operType == Bag_pb.BAGOPERTYPE_ADD then
            if oper.slot then
                table.insert(mCurrentBagData.items, oper.slot)
                changeNum = oper.slot.item.count
                --宝石分类字典
                TryAddGemItemSlot(bagType, oper.slot, true)
            end
        elseif oper.operType == Bag_pb.BAGOPERTYPE_DEL then
            if oper.slot then
                local index = GetGridIndex(oper.slot,bagType)
                if index > 0 then
                    if mCurrentBagData.items[index] and  mCurrentBagData.items[index].item then
                        changeNum = 0-mCurrentBagData.items[index].item.count
                        --删除之前先获取到其itemid，供后续使用
                        local delItemSlot = GetBagSlotItemWitnIndex(oper.slot.slotId, bagType)
                        table.remove(mCurrentBagData.items,index)
                        --宝石分类字典
                        TryRemoveGemItemSlot(bagType, oper.slot, delItemSlot.item.tempId)
                    end
                end
            end
        elseif oper.operType == Bag_pb.BAGOPERTYPE_UPDATE then
            if oper.slot then
                local index = GetGridIndex(oper.slot,bagType)
                if index > 0 then
                    if mCurrentBagData.items[index] and  mCurrentBagData.items[index].item then
                        changeNum = oper.slot.item.count - mCurrentBagData.items[index].item.count
                        mCurrentBagData.items[index]= oper.slot
                        --宝石分类字典
                        TryUpdateGemItemSlot(bagType, oper.slot)
                    end
                end
            end
        end
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_BAG_OPERATION,bagType,oper,changeNum);
        --  获得提示
        local isAdd = oper.reason>= Bag_pb.BAGITEMREASON_ADD_DEFAULT and oper.reason < Bag_pb.BAGITEMREASON_OPERATE_MIDDLE
        --来自临时背包
        local fromTemp = oper.reason==Bag_pb.BAGITEMREASON_ADD_TEMPORARY
        --分解获得
        local fromDec = oper.reason==Bag_pb.BAGITEMREASON_ADD_DECOMPOSE
        --面板之间的交换
        local fromExc = oper.reason==Bag_pb.BAGITEMREASON_ADD_EXCHANGE

        if bagType == Bag_pb.NORMAL then
            GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_BAG_NORMALITEMCHANGE,oper.slot.item.tempId,changeNum,oper.reason,oper.slot);
            local showTip = isAdd and not fromTemp and not fromExc
            local showAutoUse = isAdd and not fromDec and not fromExc
            local showFlying = isAdd and not fromDec and not fromExc and not fromTemp
           
            if changeNum>0 then
                local stuffid1 = oper.slot.item.tempId
                --物品信息 Item_Pb.ItemInfo
                local itemData1 = ItemData.GetItemInfo(stuffid1);
                if showAutoUse and itemData1.autouse then
                    QuickUseItem(oper.slot,itemData1,changeNum,false)
                end
                if showTip then
                --    TipsMgr.TipByKey("drop_item", itemData1.name,changeNum,itemData1)
                end
                if showFlying then
                    ItemFlyingMgr.AddItemList({ {itemId = stuffid1, bagType =Bag_pb.NORMAL }})
                end
                -- if fromTemp then
                --     local currentNUm =GetBagLeftSlotNumber(Bag_pb.NORMAL)
                --     if currentNUm <=5 and  currentNUm >= 0 then
                --         TipsMgr.TipByKey("backpack_info_4")
                --     end
                -- end
                
                if isAdd  then
                    local newicon = not fromDec and not fromExc
                    if newicon then
                        local now = TimeUtils.SystemTimeStamp(true)
                        local last = mLastOpenTime
                        if now>last then
                            if mBagNewItems[bagType] == nil then mBagNewItems[bagType] = {} end
                            mBagNewItems[bagType][oper.slot.slotId]=1
                        end
                    end
                else
                    if mBagNewItems[bagType] and mBagNewItems[bagType][oper.slot.slotId] then
                        mBagNewItems[bagType][oper.slot.slotId]=nil
                    end
                end
            else
                
            end
        elseif bagType == Bag_pb.TEMP then
            local showTip = isAdd and not fromDec and not fromExc
            local stuffid1 = oper.slot.item.tempId
            if showTip and changeNum>0 then
                --物品信息 Item_Pb.ItemInfo
                local itemData1 = ItemData.GetItemInfo(stuffid1);
               -- TipsMgr.TipByKey("drop_item", itemData1.name,changeNum,itemData1)
                --背包已满，道具进入临时背包，请及时清理”
                TipsMgr.TipByKey("backpack_info_5");
            end
            local showFlying = isAdd and not fromDec and not fromExc
            if showFlying then
                ItemFlyingMgr.AddItemList({ {itemId = stuffid1, bagType =Bag_pb.TEMP }})
            end
        end
    else
	    
    end
end

--物品快捷使用
function QuickUseItem(bagItemSlot,mItemData,changeNum,forceEqual)
    local level=nil
    local selfRacial =nil
    local selfProfession= nil
    local mRacial=false
    local mProfession=false
    local mEquip=false
    local show = false
    level= UserData.GetLevel()
    selfRacial = UserData.GetRacial()
    selfProfession = UserData.GetProfession()
	--种族判定 0 无限制
    if (mItemData.useRacial<=0) or (selfRacial and mItemData.useRacial and selfRacial == mItemData.useRacial) then
        mRacial=true
    end
    --职业判定
    if (mItemData.useProfession<=0) or (selfProfession and mItemData.useProfession and selfProfession == mItemData.useProfession) then
        mProfession=true
    end
    --职业种族判定
    if mRacial  then --and mProfession then
        --类别条件判定
        if level and bagItemSlot.item.count>0 and mItemData.use and mItemData.autouse and mItemData.useLevelDown <= level then
            if mItemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
                show = EquipMgr.QuickUseItem(bagItemSlot,mItemData,changeNum,forceEqual)
            else
            --道具条件判定
                if forceEqual then
                    if mItemData.useLevelDown == level  then
                        show = true
                    end
                else
                    show = true
                end
            end
        end
    end
    if show then
        local Data ={item =bagItemSlot.item , slotId =bagItemSlot.slotId, itemData = mItemData,lock=false,Num=changeNum}
        local obj=GetQuickUseObj()
        obj:SetData(Bag_pb.NORMAL,Data)
        if UI_Tip_UseItem.enable then
            obj:CheckData()
        else
            UIMgr.ShowUI(AllUI.UI_Tip_UseItem)
        end
    end
end

--升级时检查背包中须要提示的物品
function QuickUseItemWhenLevelUp(entity)
    if entity == nil or entity:IsSelf() then
        local mCurrentBagData = BagData[Bag_pb.NORMAL]
        if mCurrentBagData then
            for i=1,#mCurrentBagData.items do
                local item = mCurrentBagData.items[i]
                --物品id
                local stuffid = item.item.tempId
                --物品信息
                local itemData = ItemData.GetItemInfo(stuffid);
                QuickUseItem(item,itemData,item.item.count,true)
            end
        else
            GameLog.LogError("bag is empty!")
        end
    end
end

--根据道具类型自动计算slotId使用物品
function UseItemAutoSlotId(bagType,tempId,num)
    mTempUsetable ={}
    local mCurrentBagData = BagData[bagType]
    local temptable ={}
    for i=1,#mCurrentBagData.items do
        --类型为BagItemSlot
        local titem = mCurrentBagData.items[i]
        if titem and titem.item and titem.item.count>0 then
            --物品id
            if tempId == titem.item.tempId then
                --类型为 Item_Pb.Item
                table.insert(temptable,{slotId=titem.slotId,id=titem.item.id,tempId=titem.item.tempId,count=titem.item.count})
            end
        end
    end
    if temptable and table.getn(temptable)>0 then
        SortWithSlotId(temptable)
        local maxc =table.getn(temptable)
        local tempNum= num
        for i=maxc,1,-1 do
            local data = temptable[i]
            local item = NetCS_pb.BagUseItem()
            item.bagType = bagType;
            item.slotId = data.slotId;
            item.id = data.id;
            item.tempId = data.tempId;
            if tempNum > data.count then
                tempNum =tempNum - data.count
                item.num = data.count;
                table.insert(mTempUsetable,item)
            else
                item.num = tempNum;
                table.insert(mTempUsetable,item)
                break
            end
        end
        BagMgr.RequestUseMultiBagItems(bagType,mTempUsetable)
        return true
    end
    return false
end

--根据装备类型自动计算slotId使用物品
function GetEquipAutoSlotId(bagType,tempId)
    mTempUsetable ={}
    local mCurrentBagData = BagData[bagType]
    local temptable ={}
    for i=1,#mCurrentBagData.items do
        --类型为BagItemSlot
        local titem = mCurrentBagData.items[i]
        if titem and titem.item then
            --物品id
            if tempId == titem.item.tempId then
                --类型为 Item_Pb.Item
                table.insert(temptable,{item=titem,slotId=titem.slotId,id=titem.item.id,count=1})
            end
        end
    end
    if temptable and table.getn(temptable)>0 then
        SortWithSlotId(temptable)
        local maxc =table.getn(temptable)
        if maxc>0 then
            local tempNum= num
            local bestItem = temptable[maxc]
            local score=0
            for i=maxc,1,-1 do
                    local data = temptable[i]
                    local Item = data.item
                    local iscore = EquipMgr.GetScoreByItem(Item.item)
                    if iscore>score then
                        score = iscore
                        bestItem = data
                    end
            end
            mLastEquipItem = bestItem
        end
        return mLastEquipItem
    end
    return nil
end

--根据装备类型自动计算slotId使用物品
function UseEquipAutoSlotId(bagType,tempId)
    mLastEquipItem = GetEquipAutoSlotId(bagType,tempId)
    if mLastEquipItem then
        BagMgr.RequestMoveBagItem(bagType, mLastEquipItem.slotId, mLastEquipItem.item.item.id, Bag_pb.EQUIP, - 1)
        return true
    end
    return false
end

--检查刚刚使用的物品中有没有当前物品
function CheckLastUseContain(slotId,id)
   for i=1,#mTempUsetable do
        if mTempUsetable[i].slotId ==slotId and mTempUsetable[i].id ==id then
            return true
        end
        return false
   end 
end

--[[
    @desc: 尝试往字典里添加一个宝石数据
    --@itemSlot: 
    --@needMsg: 添加后，是否需要抛出事件
]]
function TryAddGemItemSlot(bagType, itemSlot, needMsg)
    if not bagType or bagType ~= Bag_pb.NORMAL then
        return
    end
    if not itemSlot then
        return
    end
    local itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
    local isGem = itemData and itemData.itemInfoType == Item_pb.ItemInfo.GEMSTONE
    if not isGem then
        return
    end

    if not mGemTypeDic[itemData.childType] then
        mGemTypeDic[itemData.childType] = {}
    end
    CustomInsertOneGem(mGemTypeDic[itemData.childType], itemSlot)

    if needMsg then
        GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_ADDGEM, itemSlot)
    end
end

--[[
    @desc: 尝试从字典里删除一个宝石数据，一个有序的数组删除一个元素后，仍然有序
    --@itemSlot: 该结构里只有slotId
]]
function TryRemoveGemItemSlot(bagType, itemSlot, delItemId)
    if not bagType or bagType ~= Bag_pb.NORMAL then
        return
    end
    if not itemSlot then
        return
    end
    local itemData = ItemData.GetItemInfo(delItemId)
    local isGem = itemData and itemData.itemInfoType == Item_pb.ItemInfo.GEMSTONE
    if not isGem then
        return
    end

    local existKey = nil
    for key, v in ipairs(mGemTypeDic[itemData.childType]) do
        if v.slotId == itemSlot.slotId then
            existKey = key
            break
        end
    end
    if existKey then
        table.remove(mGemTypeDic[itemData.childType], existKey)
        GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_REMOVEGEM, itemSlot)
    end
end

--[[
    @desc: 尝试更新一个宝石数据
    --@itemSlot: 
]]
function TryUpdateGemItemSlot(bagType, itemSlot)
    if not bagType or bagType ~= Bag_pb.NORMAL then
        return
    end
    if not itemSlot then
        return
    end
    local itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
    local isGem = itemData and itemData.itemInfoType == Item_pb.ItemInfo.GEMSTONE
    if not isGem then
        return
    end

    local existKey = nil
    for key, v in ipairs(mGemTypeDic[itemData.childType]) do
        if v.slotId == itemSlot.slotId then
            existKey = key
            break
        end
    end
    if existKey then
        mGemTypeDic[itemData.childType][existKey] = itemSlot
        GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_UPDATEGEM, itemSlot)
    end
end

--[[
    @desc: 重建mGemTypeDic结构，只考虑NORMAL类型包裹
]]
function RebuildGemTypeDic()
    mGemTypeDic = {}

    local bagData = BagData[Bag_pb.NORMAL]
    local itemSlotList = bagData and bagData.items or {}
    for _, itemSlot in ipairs(itemSlotList) do
        TryAddGemItemSlot(Bag_pb.NORMAL, itemSlot, false)
    end
end

--普通货币兑换
function ExchangeCoin(from,target,inputNum)
    --元宝=100金币
    local ingotgold = ConfigData.GetIntValue("bag_exchange_cashtogold") or 100
    --金币=100银币
    local goldsilver = ConfigData.GetIntValue("bag_exchange_goldtosilver") or 100
    --元宝=10000银币
    local ingotsilver = ingotgold*goldsilver
    local exType = Coin_pb.CASH2GOLD
    local rate = ingotgold
    --正向兑换允许输入最大数量
    local maxCostNUm =  ConfigData.GetIntValue("bag_exchange_maxbao") or 9999
    local costNum = inputNum
    local warningNum =  ConfigData.GetIntValue("bag_exchange_warningbao") or 1000
    if from == Coin_pb.INGOT and target == Coin_pb.GOLD then
        exType = Coin_pb.CASH2GOLD
        rate = ingotgold
    elseif from == Coin_pb.INGOT and target == Coin_pb.SILVER then
        exType = Coin_pb.CASH2SILVER
        rate = ingotsilver
    elseif from == Coin_pb.GOLD and target == Coin_pb.SILVER then
        exType = Coin_pb.GOLD2SILVER
        rate = goldsilver
        maxCostNUm =  ConfigData.GetIntValue("bag_exchange_maxgold") or 999999
        warningNum =  ConfigData.GetIntValue("bag_exchange_warninggold") or 1000
    end
    --最大兑换数量
    costNum = math.min(inputNum,maxCostNUm)
    --获得货币数量
    local earnNum = costNum*rate
    --兑换数量超出警戒值
    if costNum > warningNum then
       UI_Tip_ExchangeWarning.ShowTip(from,target,costNum,earnNum,function ()
            RequestCoinExchange({from},{target},{costNum})
       end,nil)
    else
        RequestCoinExchange({from},{target},{costNum})
    end
end

--补充兑换货币 货币类型 补足数量
function SupplyExchangeCoin(costType,supplyNum,callback,param)
    --元宝=100金币
    local ingotgold = ConfigData.GetIntValue("bag_exchange_cashtogold") or 100
    --金币=100银币
    local goldsilver = ConfigData.GetIntValue("bag_exchange_goldtosilver") or 100
    --元宝=10000银币
    local ingotsilver = ingotgold*goldsilver
    --持有数量
    local haveNum = GetMoney(costType)
    if costType == Coin_pb.INGOT then
        --引导充值界面
        AskToCharge()
    elseif costType == Coin_pb.GOLD then
        --金币不足 弹出金币补足界面
        local costIngot = math.ceil(supplyNum/ingotgold)--兑换所需最少数量
        local leftnum = costIngot*ingotgold - supplyNum
        local haveNum = GetMoney(Coin_pb.INGOT)
        local enoughEx = haveNum>=costIngot
        local supplySolution = {}
        supplySolution[3]={from=Coin_pb.INGOT,to=Coin_pb.GOLD,supplyNum = supplyNum,num = costIngot,left = leftnum,enough = enoughEx}
        mCoinExchangeCallback = callback
        mCoinExchangeCallbackParam = param
        UI_Tip_EnsureSupplyExchange.ShowTip(costType,3,supplySolution,OnChooseSupplyExchangeCoin,ClearCallback)
    elseif costType == Coin_pb.SILVER then
        --银币不足 弹出银币补足界面
        local costGold = math.ceil(supplyNum/goldsilver)--金币兑换银币所需数量
        local leftGold = costGold*goldsilver - supplyNum--兑换后多出的银币
        local haveGold = GetMoney(Coin_pb.GOLD)
        local enoughGold = haveGold>=costGold

        local costIngot = math.ceil(supplyNum/ingotsilver)--金币兑换银币所需数量
        local leftIngot = costIngot*ingotsilver - supplyNum--兑换后多出的金币
        local haveIngot= GetMoney(Coin_pb.INGOT)
        local enoughIngot = haveIngot>=costIngot
        
        local supplySolution = {}
        supplySolution[1]={from=Coin_pb.GOLD,to=Coin_pb.SILVER,supplyNum = supplyNum,num = costGold,left = leftGold,enough = enoughGold }
        supplySolution[2]={from=Coin_pb.INGOT,to=Coin_pb.SILVER,supplyNum = supplyNum,num = costIngot,left = leftIngot,enough = enoughIngot}
        mCoinExchangeCallback = callback
        mCoinExchangeCallbackParam = param
        --金币不足 用元宝换金币
        if enoughGold==false then
            local leftgold = costGold - haveGold -- 剩余须要元宝换的金币
            local leftcostingot = math.ceil(leftgold/ingotgold) --须要的元宝
            local leftenoughIngot = haveIngot>=leftcostingot --有的元宝是否充足
            local leftleftgold = leftcostingot*ingotgold - leftgold --兑换后多出来的金币
            supplySolution[3] = {from=Coin_pb.INGOT,to=Coin_pb.GOLD,supplyNum = leftgold,num = leftcostingot,left = leftleftgold,enough = leftenoughIngot}
        end
        UI_Tip_EnsureSupplyExchange.ShowTip(costType,1,supplySolution,OnChooseSupplyExchangeCoin,ClearCallback)
    end
end

--选择兑换方案后的处理
function OnChooseSupplyExchangeCoin(sol,index)
    --有子方案
    if sol[3] and index ==1 then
      --  sol.child.parent = {from=sol.from,to=sol.to,num = sol.num,left = sol.left,enough = sol.enough}
        UI_Tip_EnsureSupplyExchange.ShowTip(sol[3].to,3,sol,OnChooseSupplyExchangeCoin,ClearCallback)
    elseif sol[index].enough then
        if sol[3] and index==3 and sol[1] then
            RequestCoinExchange({sol[3].from,sol[1].from},{sol[3].to,sol[1].to},{sol[3].num,sol[1].num})
        else
            RequestCoinExchange({sol[index].from},{sol[index].to},{sol[index].num})
        end
    else
        mCoinExchangeCallback = nil
        mCoinExchangeCallbackParam = nil
        if sol[index].from == Coin_pb.INGOT then 
            AskToCharge()
        elseif sol[index].from == Coin_pb.GOLD then
            UIMgr.ShowUI(AllUI.UI_Bag_GoldExchange,nil,nil,nil,nil,true,2,1)
        end
    end
end

function ClearCallback()
    mCoinExchangeCallback = nil
    mCoinExchangeCallbackParam = nil
end

----引导充值界面TipConfirmByCustomStr(str, okFunc, cancelFunc, okStr, cancelStr)
function AskToCharge()
    TipsMgr.TipConfirmByCustomStr(TipsMgr.GetTipByKey("common_exchange_charge_introduction"),function()
        UI_Exchange.ShowUI(4);
    end, nil,TipsMgr.GetTipByKey("common_exchange_charge_now"),TipsMgr.GetTipByKey("common_exchange_charge_later"))
end

return BagMgr;