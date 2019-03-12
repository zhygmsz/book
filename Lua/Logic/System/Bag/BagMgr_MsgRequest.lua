module("BagMgr",package.seeall);
--==============================--
--desc: 消息发送与回调
--time:2018-04-26 08:20:44
--@bagTypes:
--@return 
--==============================--

--关闭背包物品同步
function RequestCloseBagSync(seconds)
    local msg = NetCS_pb.CSBagSyncClose();
    msg.closeSecs=seconds
    GameNet.SendToGate(msg);
end

--打开背包物品同步
function RequestOpenBagSync()
    local msg = NetCS_pb.CSBagSyncOpen();
    GameNet.SendToGate(msg);
end

--取背包数据,异步获取(因为有时候会向服务器申请数据)
function RequestBagData(bagTypes)
    local msg = NetCS_pb.CSBagGetInfo();
    msg.bagTypes:ParseFrom(bagTypes);
    msg.isFull=true
    GameNet.SendToGate(msg);
end

--整理背包
function RequestArrangeBag(bagType)
    local msg = NetCS_pb.CSBagArrange();
    msg.bagType = bagType
    GameNet.SendToGate(msg);
end

--解锁格子
function RequestUnlockBagGrid(tempId)
    --todo check
    local msg = NetCS_pb.CSBagUnlock();
    msg.tempId = tempId;
    GameNet.SendToGate(msg);
end

--解锁仓库
function RequestUnlockDepot()
    local bagType=Bag_pb.DEPOT1
    for i=Bag_pb.DEPOT1,Bag_pb.DEPOT12 do
        local mCurrentBagData = BagData[i]
        if not mCurrentBagData.isOpen then
            bagType = i
            break
        end
    end  
    local msg = NetCS_pb.CSBagDepotUnlock();
    msg.bagType = bagType;
    GameNet.SendToGate(msg);
end

--获取货币信息
function RequestCoinInfo()
    --todo check
    local msg = NetCS_pb.CSCoinGetInfo();
    GameNet.SendToGate(msg); 
end

--所有分页名称
function RequestBagBaseInfo(bagTypes)
    local msg = NetCS_pb.CSBagGetInfo();
    msg.bagTypes:ParseFrom(bagTypes);
    msg.isFull=false
    GameNet.SendToGate(msg);
end

--修改分页名称
function RequestRenameDepot(bagType,pageName)
    local msg = NetCS_pb.CSBagDepotRename();
    msg.bagType = bagType;
    msg.name = pageName;
    GameNet.SendToGate(msg);
end

--移动背包物品
function RequestMoveBagItem(fromType,fromSlotId,fromId,toType,toSlotId)
     --存入仓库判断还是取回背包
    local istoDepot =  fromType == Bag_pb.NORMAL and toType >= Bag_pb.DEPOT1 and toType <= Bag_pb.DEPOT12
    local istoNormal =  toType == Bag_pb.NORMAL 
    if istoDepot then
        if BagMgr.IsFull(toType) then
            TipsMgr.TipByKey("backpack_info_10");
            return
        end
        --背包格子数据
        local bagitem = GetBagSlotItemWitnIndex(fromSlotId,fromType)
        local stuffid = bagitem.item.tempId
        --物品信息 Item_Pb.ItemInfo
        local itemData = ItemData.GetItemInfo(stuffid);
        --物品数据
        if not itemData.wareHouse then--不可进仓库
            TipsMgr.TipByKey("backpack_info_9");
            return
        end 
    end
    if istoNormal then
        if BagMgr.IsFull(Bag_pb.NORMAL) then
            TipsMgr.TipByKey("backpack_info_7");
            return
        end
    end
    local msg = NetCS_pb.CSBagTransfer();
    msg.fromType = fromType;
    msg.fromSlotId = fromSlotId;
    msg.fromId = fromId;
    msg.toType = toType;
    msg.toSlotId = toSlotId;
    GameNet.SendToGate(msg);
end

--使用物品
function RequestUseBagItem(bagType,slotId,id,tempId,num)
    local msg = NetCS_pb.CSBagUseItem();
    msg.itemInfo.bagType = bagType;
    msg.itemInfo.slotId = slotId;
    msg.itemInfo.id = id;
    msg.itemInfo.num = num;
    msg.itemInfo.tempId = tempId
    GameNet.SendToGate(msg);
end

--使用多个物品
function RequestUseMultiBagItems(bagType,dataarray)
    local msg = NetCS_pb.CSBagUseItemEx()
    msg.itemInfo:ParseFrom(dataarray);
    GameNet.SendToGate(msg);
end

--分解物品
function RequestDecomposeBagItem(bagType,slotId,id,num)
    local msg = NetCS_pb.CSBagDecomposeItem();
    msg.bagType = bagType;
    msg.slotId = slotId;
    msg.id = id;
    msg.num = num;
    GameNet.SendToGate(msg);
end

--货币兑换
function RequestCoinExchange(holds,earns,sValues)
    local exchangeTypes = {}
    local count = table.count(earns)
    for i=1,count do
        local exType = Coin_pb.CASH2GOLD
        if holds[i] == Coin_pb.INGOT and earns[i] == Coin_pb.GOLD then
            exType = Coin_pb.CASH2GOLD
        elseif holds[i] == Coin_pb.INGOT and earns[i] == Coin_pb.SILVER then
            exType = Coin_pb.CASH2SILVER
        elseif holds[i] == Coin_pb.GOLD and earns[i] == Coin_pb.SILVER then
            exType = Coin_pb.GOLD2SILVER
        end
        exchangeTypes[i] = exType
    end
   
    -- 仙玉兑换金币 CASH2GOLD = 1;	
	--仙玉兑换银币 CASH2SILVER = 2;
	-- 金币兑换银币 GOLD2SILVER = 3;
    local msg = NetCS_pb.CSBagCoinExchange();
    msg.exchangeType:ParseFrom(exchangeTypes);
    msg.srcValue:ParseFrom(sValues);
    GameNet.SendToGate(msg);
end

--临时背包一键取回
function RequestClearTempPackage()
    local msg = NetCS_pb.CSGetBackFast();
    GameNet.SendToGate(msg);
end
