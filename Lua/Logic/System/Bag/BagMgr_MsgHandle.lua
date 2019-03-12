module("BagMgr",package.seeall);

--背包数据更新
function OnHandleBagData(data)
    if data then
        local num = #data.bags;
        for i=1,num do
            local bag = data.bags[i]
            local bagType = bag.type;
            --请求是否是完整信息
            if data.isFull then 
                BagData[bagType] = bag
            else
                if BagData[bagType]==nil then
                    BagData[bagType] = Bag_pb.Bag()
                end
                BagData[bagType].type = bag.type
                BagData[bagType].isOpen = bag.isOpen
                BagData[bagType].maxSlots = bag.maxSlots
                BagData[bagType].addSlots = bag.addSlots
                BagData[bagType].name = bag.name
            end
            --重建宝石分类字典
            if bagType == Bag_pb.NORMAL then
                RebuildGemTypeDic()
            end
            GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PACKAGE,bagType);
            GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_PACKAGE_FULL,bagType,IsFull(bagType));
        end
    end
end

--整理背包回调 0=成功
function OnHandleArrangeBag(result)
    if result.ret == 0 then
        TipsMgr.TipByKey("backpack_info_13");
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_ARRANGE_BAG,result);
    else
        TipsMgr.TipErrorByID(result.ret)
    end
end

--背包数据更新
function OnHandleBagItemUpdate(data)
    if data.bags then
        local isAdd =false
        for i=1,#data.bags do
            local UpdateInfo = data.bags[i]
            GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_UPDATE_GRID_PRE,UpdateInfo.type);
            local N = #UpdateInfo.opers
            for j=1,N do
                local bagOperation = UpdateInfo.opers[j]
                DoBagOperation(UpdateInfo.type,bagOperation)
                if isAdd == false and UpdateInfo.type == Bag_pb.NORMAL then
                    --  获得提示
                    if bagOperation.reason>= Bag_pb.BAGITEMREASON_ADD_DEFAULT and bagOperation.reason < Bag_pb.BAGITEMREASON_OPERATE_MIDDLE then
                        isAdd =true
                    end
                end
            end
            GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_UPDATE_GRID,UpdateInfo.type);
            GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_PACKAGE_FULL,UpdateInfo.type,GetBagLeftSlotNumber(UpdateInfo.type)<=0);
        end
        if  isAdd then
            local currentNUm =GetBagLeftSlotNumber(Bag_pb.NORMAL)
            if currentNUm <=5 and  currentNUm >= 0 then
                TipsMgr.TipByKey("backpack_info_4")
            end
        end
    end
end

--解锁背包格子
function OnHandleUnlockBagGrid(data)
    if data.ret==0 then
        local mCurrentBagData = BagData[Bag_pb.NORMAL]
        mCurrentBagData.unLockCount = data.unLockCount
        mCurrentBagData.maxSlots = data.newBagSize
        local n = ConfigData.GetIntValue("Bag_everytime_unlock_lattice") or 5
        mCurrentBagData.addSlots = mCurrentBagData.unLockCount*n
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_UNLOCK_GRID);
    else
        TipsMgr.TipErrorByID(data.ret)
    end
end

--仓库解锁回调
function OnHandleUnlockDepot(data)
    if data.ret == 0 then
        RequestBagData({data.bagType})
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_UNLOCK_PAGE,data.bagType);
    else
        TipsMgr.TipErrorByID(data.ret)
    end
    
end

--获取物品的通知
function OnHandleBagSyncItemMessage(data)
    if tonumber(data.itemNum)>0 then --sourceType
        local itemData = ItemData.GetItemInfo(data.itemID);
        local content = TipsMgr.GetTipByKey("drop_item", itemData.name,data.itemNum)
        TipsMgr.TipCommon(content, itemData) 
    end
end

--获取货币的通知
function OnHandleCoinSyncItemMessage(data)
    if data then --sourceType
        TipsMgr.TipByKey("bag_exchange_gotnum",data.coinNum,GetCoinName(data.coinType))
    end
end

--获取货币的回调
function OnHandleCoinInfo(data)
    if data then
        for i=1,#data.coins do
            local mCoinUnit = data.coins[i]
            --元宝
            if mCoinUnit.coinType == Coin_pb.INGOT then
                BagData.ingotCount =tonumber(mCoinUnit.count)
            --金币
            elseif mCoinUnit.coinType == Coin_pb.GOLD then
                BagData.goldCount = tonumber(mCoinUnit.count)
            --银币
            elseif mCoinUnit.coinType == Coin_pb.SILVER then
                BagData.silverCount = tonumber(mCoinUnit.count)
            end
        end
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_GETCOIN);
    end
end

--同步货币的回调
function OnHandleCoinSync(data)
    if data then
        for i=1,#data.coins do
            local mCoinUnit = data.coins[i]
            local cha =nil
            --元宝
            if mCoinUnit.coinType == Coin_pb.INGOT then
                cha = mCoinUnit.count-BagData.ingotCount
                BagData.ingotCount = tonumber(mCoinUnit.count)
            --金币
            elseif mCoinUnit.coinType == Coin_pb.GOLD then
                cha = mCoinUnit.count-BagData.goldCount
                BagData.goldCount = tonumber(mCoinUnit.count)
            --银币
            elseif mCoinUnit.coinType == Coin_pb.SILVER then
                cha = mCoinUnit.count-BagData.silverCount
                BagData.silverCount = tonumber(mCoinUnit.count)
            end
            --针对具体类型，抛出具体变化值
            GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_SYNCCOIN,mCoinUnit.coinType,cha);
        end
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_GETCOIN);
    end
end

--仓库重命名的回调
function OnHandleRenameDepot(data)
    if data.ret==0 then
        local mCurrentBagData = BagData[data.bagType]
        mCurrentBagData.name = data.name
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PAGENAME,data.bagType,data.ret);
    else
        TipsMgr.TipErrorByID(data.ret)
    end
end

--移动背包物品的回调
function OnHandleMoveBagItem(data)
     --存入仓库判断还是取回背包
    local istoDepot =  data.fromType == Bag_pb.NORMAL and data.toType >= Bag_pb.DEPOT1 and data.toType <= Bag_pb.DEPOT12
    local istoNormal =  data.toType == Bag_pb.NORMAL and data.fromType >= Bag_pb.DEPOT1 and data.fromType <= Bag_pb.DEPOT12
    local temptoNormal =  data.toType == Bag_pb.NORMAL and data.fromType == Bag_pb.TEMP
         
    if data.ret == 0 then
        if istoDepot then
            TipsMgr.TipByKey("backpack_info_8");
        elseif istoNormal then
            TipsMgr.TipByKey("backpack_info_6");
        elseif temptoNormal then
            TipsMgr.TipByKey("backpack_info_6");
        end
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_MOVE_ITEM,data);
    end
end

--使用背包物品的回调
function OnHandleUseBagItem(data)
    if data.ayitemInfo.ret==0 then
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_USE_ITEM,data.ayitemInfo);
    else
        TipsMgr.TipErrorByID(data.ayitemInfo.ret)
    end
end

--批量使用物品的回调
function OnHandleUseMultiBagItems(data)
    if data.operateRst==0 then
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_USE_MULITI_ITEM,data);
    else
        TipsMgr.TipErrorByID(data.operateRst)
    end
end

--分解物品回调
function OnHandleDecomposeBagItem(data)
    if  data.ret==0 then
        GameEvent.Trigger(EVT.PACKAGE,EVT.PACKAGE_DECOMPOSE,data.bagType);
    else
        TipsMgr.TipErrorByID(data.ret)
    end
end

--货币兑换的回调
function OnHandleCoinExchange(data)
    if  data.ret==0 then
        if data.exchangeInfo then
            -- for i=1,#data.exchangeInfo do
            --     local info = data.exchangeInfo[i]
            --     local coinType = info.exchangeType == Coin_pb.CASH2GOLD and Coin_pb.GOLD or Coin_pb.SILVER
            --     local name = GetCoinName(coinType)
            --     TipsMgr.TipByKey("bag_exchange_gotnum",info.dstValue,name);
            -- end
        end
        if mCoinExchangeCallback then
            mCoinExchangeCallback(mCoinExchangeCallbackParam)
        end
        mCoinExchangeCallback = nil
        mCoinExchangeCallbackParam = nil
    else
        TipsMgr.TipErrorByID(data.ret)
    end
end

--奖励通知，包括货币，经验
function OnHandleCurrencyItemPrize(commPrizeData)
    local itemList = commPrizeData.prize.itemlist;
    if itemList and #itemList>0 then
        for i=1,#itemList do
            local itemData = ItemData.GetItemInfo(itemList[i].itemid);
            --经验在其他地方提示
            if itemData.id ~= 700000001 then
                local itemData = ItemData.GetItemInfo(itemid);
                local content = TipsMgr.TipByKey("drop_item", itemData.name,itemList[i].count)
                TipsMgr.TipCommon(content, itemData)
            end
        end
    end
end

--一键取回临时背包的回调
function OnHandleClearTempBag(data)
    local ret = data.ret;
    if ret==0 then --取回背包成功
        TipsMgr.TipByKey("backpack_info_6");
    else
        TipsMgr.TipErrorByID(ret)
    end
   
end

--物品进入邮件的通知
-- optional int32  sourceType = 1; 	//来源类型
-- optional int32  itemID     = 2; 	//道具ID
-- optional int32  itemNum    = 3; 	//道具Num
function OnHandleBagItemToMail(data)
    TipsMgr.TipByKey("backpack_info_25");
end

