--商会
module("CommerceMgr", package.seeall)

--测试模式
DebugMode = false

--变量，服务器数据是否准备完毕，本次登录有效
local mGoodsSpecInfoIsInited = false

--所有的商品特殊信息，商品id为key
local mGoodsSpecInfoDic = {}

--关闭界面前的记录
--左侧一级列表和二级列表按钮被点击时，及时更新到该组合
local mLastLeftId = {one = -1, two = -1}
--middle区域被刷新时的一二级列表id组合（同时合法）
local mLastMiddleId = {one = -1, two = -1}
--right区域刷新时，记录该id
local mLastGoodsId = -1 --商品id

--商会默认货币itemid
local mCommerceCoinItemId = 701000001

local mOneTypeName = {
    [1] = WordData.GetWordStringByKey("Shop_class1_1"),
    [2] = WordData.GetWordStringByKey("Shop_class1_2"),
    [3] = WordData.GetWordStringByKey("Shop_class1_3"),
    [4] = WordData.GetWordStringByKey("Shop_class1_4"),
    [5] = WordData.GetWordStringByKey("Shop_class1_5"),
}

local mTwoTypeName = {
    [1] = {[1] = WordData.GetWordStringByKey("Shop_class1_1_1"), [2] = WordData.GetWordStringByKey("Shop_class1_1_2"),[3] = WordData.GetWordStringByKey("Shop_class1_1_3")},
    [2] = {[1] = WordData.GetWordStringByKey("Shop_class1_2_1")},
    [3] = {[1] = WordData.GetWordStringByKey("Shop_class1_3_1")},
    [4] = {[1] = WordData.GetWordStringByKey("Shop_class1_4_1"), [2] = WordData.GetWordStringByKey("Shop_class1_4_2"), [3] = WordData.GetWordStringByKey("Shop_class1_4_3")},
    [5] = {[1] = WordData.GetWordStringByKey("Shop_class1_5_1"), [2] = WordData.GetWordStringByKey("Shop_class1_5_2"), [3] = WordData.GetWordStringByKey("Shop_class1_5_3")}
}

--保证测试数据只初始化一次
local mDebugDataIsInited = false
--测试数据，拥有货币数量
local mHaveNum = 11111
--测试背包，只有该系统需要的字段
local debugItems = {}

--local方法
--msg：一个pb.Message结构
--打印发出去的消息内容，和收到的消息内容，便于查错
local function LogProto(msg)
    if not DebugMode then
        GameLog.LogProto(msg)
    end
end

--检查一个ItemData是否可出售
--后续该逻辑可能会更多过滤条件，所以抽成一个函数
local function CheckItemDataIsCanSell(itemData)
    if not itemData then
        return false
    end
    return itemData.sellShop
end

--从数据表读出剩余购买次数，优先判断服务器限购，其次判断个人限购
local function GetLeftBuyCountByTableData(tableData)
    if tableData then
        if tableData.maxcount > 0 then
            --服务器限购
            return tableData.maxcount
        elseif tableData.player_maxcount > 0 then
            --个人限购
            return tableData.player_maxcount
        else
            --不限购
            return 0
        end
    else
        return 0
    end
end

--[[
    @desc: 检查是否限制购买次数
]]
local function CheckIsLimitBuyCount(tableData)
    if tableData and tableData.maxcount == 0 and tableData.player_maxcount == 0 then
        return false
    else
        return true
    end
end

----从数据表读出剩余出售次数，出售次数只和个人限购有关
local function GetLeftSellCountByTableData(tableData)
    if tableData then
        if tableData.player_maxcount > 0 then
            return tableData.player_maxcount
        else
            --不限制出售次数
            return 0
        end
    else
        return 0
    end
end

--[[
    @desc: 检测是否限制出售次数
]]
local function CheckIsLimitSellCount(tableData)
    if tableData and tableData.player_maxcount == 0 then
        return false
    else
        return true
    end
end

--用服务器数据刷新缓存
local function InitGoodsSpecInfoDic(list)
    mGoodsSpecInfoDic = {}

    local tableDataList = ShopData.GetTotalDataList()
    for _, tableData in ipairs(tableDataList) do
        mGoodsSpecInfoDic[tableData.id] = {
            goodsId = tableData.id,
            isLimitBuyCount = CheckIsLimitBuyCount(tableData),
            leftbuycount = GetLeftBuyCountByTableData(tableData),
            dynamicprice = tableData.price,
            isLimitSellCount = CheckIsLimitSellCount(tableData),
            leftsellcount = GetLeftSellCountByTableData(tableData),
            endbuytime = 0,
        }
    end
    for _, data in ipairs(list) do
        --服务器数据有就刷新本地缓存，两三个字段同时合法
        mGoodsSpecInfoDic[data.goodsId].leftbuycount = data.leftbuycount
        mGoodsSpecInfoDic[data.goodsId].dynamicprice = data.dynamicprice
        mGoodsSpecInfoDic[data.goodsId].leftsellcount = data.leftsellcount
        mGoodsSpecInfoDic[data.goodsId].endbuytime = data.endbuytime
    end
end

local function UpdateGoodsSpecInfoDic(specInfo)
    if not specInfo then
        return
    end
    if mGoodsSpecInfoDic[specInfo.goodsId] then
        mGoodsSpecInfoDic[specInfo.goodsId].leftbuycount = specInfo.leftbuycount
        mGoodsSpecInfoDic[specInfo.goodsId].dynamicprice = specInfo.dynamicprice
        mGoodsSpecInfoDic[specInfo.goodsId].leftsellcount = specInfo.leftsellcount
        mGoodsSpecInfoDic[specInfo.goodsId].endbuytime = specInfo.endbuytime
    end
end

--itemid转换为goodsid
local function ItemId2GoodsId(itemId)
    if not itemId then
        return -1
    end
    local itemData = ItemData.GetItemInfo(itemId)
    return itemData and itemData.goodsId
end

--goodsid转换为itemid
local function GoodsId2ItemId(goodsId)
    if not goodsId then
        return -1
    end
    local tableData = GetTableDataById(goodsId)
    return tableData and tableData.itemId
end

--==============================--
--desc:检测某个商品，在当前条件（如自身等级等）下是否可以显示出来
--@tableData:商品详细数据
--@return bool
--==============================--
local function CheckCanShow(tableData)
    local canShow = false

    if not tableData then
        return canShow
    end

    local selfLevel = UserData.GetLevel()
    local levelMeet = selfLevel >= tableData.level

    canShow = levelMeet

    return canShow
end

if DebugMode then
    function InitDebugItems()
        --组装一些临时可出售的物品数据，测试
        table.insert(debugItems, {slotId = 1, item = {id = 1, tempId = 200100001, count = 1}})
        table.insert(debugItems, {slotId = 2, item = {id = 2, tempId = 200100002, count = 2}})
        table.insert(debugItems, {slotId = 3, item = {id = 3, tempId = 201100001, count = 3}})
        table.insert(debugItems, {slotId = 4, item = {id = 4, tempId = 201100002, count = 4}})
        table.insert(debugItems, {slotId = 5, item = {id = 5, tempId = 202100001, count = 5}})
        table.insert(debugItems, {slotId = 6, item = {id = 6, tempId = 202100002, count = 6}})
        table.insert(debugItems, {slotId = 7, item = {id = 7, tempId = 203100001, count = 7}})
        table.insert(debugItems, {slotId = 8, item = {id = 8, tempId = 203100002, count = 8}})
        table.insert(debugItems, {slotId = 9, item = {id = 9, tempId = 204100001, count = 9}})
        table.insert(debugItems, {slotId = 10, item = {id = 10, tempId = 204100002, count = 10}})
        table.insert(debugItems, {slotId = 11, item = {id = 11, tempId = 205100001, count = 11}})
        table.insert(debugItems, {slotId = 12, item = {id = 12, tempId = 205100002, count = 12}})
    end

    if DebugMode then
        function GetCountByItemId(itemId)
            local count = 0
            for _, itemSlot in ipairs(debugItems) do
                if itemSlot.item.tempId == itemId then
                    count = count + itemSlot.item.count
                end
            end
            return count
        end
    end

    function GetIndexByItemId(itemId)
        for idx, itemSlot in ipairs(debugItems) do
            if itemSlot.item.tempId == itemId then
                return idx
            end
        end
        return -1
    end

    function UpdataCountByItemId(itemId, newCount)
        if newCount <= 0 then
            local index = GetIndexByItemId(itemId)
            if index ~= -1 then
                table.remove(debugItems, index)
            end
        else
            for _, itemSlot in ipairs(debugItems) do
                if itemSlot.item.tempId == itemId then
                    itemSlot.item.count = newCount
                end
            end
        end
    end
end

local function InitData()
    --待实现
    --客户端数据加载异步，不能再Mgr.InitModel方法里访问数据
    --mCommerceCoinItemData = ItemData.GetItemInfo(mCommerceCoinItemId)

    if DebugMode then
        InitDebugItems()
    end
end

function InitModule()
    InitData()
end

---------------------------------消息收发---------------------------------
--请求所有商品的特殊信息
function SendGoodsSpecInfo()
    --待实现
    --为了兼容服务器限购类型的剩余数量，每次打开界面申请数据
    --后续考虑全部信息请求一次，之后每次打开界面只向服务器请求服务器限购类型的数据列表
    --减少消息量
    --[[
    if mGoodsSpecInfoIsInited then
        MessageSub.SendMessage(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_GOTSPECINFO)
        return
    end
    --]]

    local msg = NetCW_pb.CWAskShopGoodsSpecialInfo()
    msg.roleId = UserData.PlayerID;
    GameNet.SendToGate(msg)

    LogProto(msg)

    if DebugMode then
        local data = {}
        local specialgoods = {}
        mDebugDataIsInited = false
        if not mDebugDataIsInited then
            mDebugDataIsInited = true
            --初始化测试数据
            local tableDataList = ShopData.GetTotalDataList()
            for _, tableData in ipairs(tableDataList) do
                table.insert(
                    specialgoods,
                    {
                        goodsId = tableData.id,
                        leftbuycount = 11,
                        dynamicprice = 1024,
                        leftsellcount = 11,
                        endbuytime = 1540915200
                    }
                )
            end
        else
            --由游戏内数据组装
            --待实现
        end

        data.specialgoods = specialgoods
        OnGoodsSpecInfo(data)
    end
end

--收到所有商品的特殊信息
function OnGoodsSpecInfo(data)
    LogProto(data)

    InitGoodsSpecInfoDic(data.specialgoods)

    --服务器数据准备完毕
    mGoodsSpecInfoIsInited = true

    MessageSub.SendMessage(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_GOTSPECINFO)
end

--购买
function SendBuy(goodsId, count)
    local msg = NetCS_pb.CSShopBuy()
    msg.roleId = UserData.PlayerID;
    msg.goodsId = goodsId
    msg.count = count
    GameNet.SendToGate(msg)

    LogProto(msg)

    if DebugMode then
        local data = {}
        data.ret = 0
        data.goodsinfo = {}
        data.goodsinfo.goodsId = goodsId
        data.goodsinfo.dynamicprice = mGoodsSpecInfoDic[goodsId].dynamicprice
        data.goodsinfo.leftbuycount = mGoodsSpecInfoDic[goodsId].leftbuycount - count
        data.goodsinfo.leftsellcount = mGoodsSpecInfoDic[goodsId].leftsellcount
        data.goodsinfo.endbuytime = mGoodsSpecInfoDic[goodsId].endbuytime

        local realPrice = GetRealPrice(GetTableDataById(goodsId), 1)
        mHaveNum = mHaveNum - realPrice * count

        OnBuy(data)
    end
end

--购买返回
function OnBuy(data)
    LogProto(data)

    if data.ret == 0 then
        UpdateGoodsSpecInfoDic(data.goodsinfo)
        MessageSub.SendMessage(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_BUY, data.goodsinfo.goodsId)
        --提示
        
        local itemData = ItemData.GetItemInfo(GoodsId2ItemId(data.goodsinfo.goodsId))
        local content = WordData.GetWordStringByKey("Shop_buy_finish", data.goodsinfo.buycount, itemData.name)
        --取消购买成功提示，统一走背包获得物品提示逻辑
        --TipsMgr.TipCommon(content, itemData)
    else
        GameLog.LogError("CommerceMgr.OnBuy -> data.ret = %s", data.ret)
    end
end

--出售
function SendSell(itemId, count)
    local msg = NetCS_pb.CSShopSell()
    msg.roleId = UserData.PlayerID;
    msg.itemId = itemId
    msg.count = count
    GameNet.SendToGate(msg)

    LogProto(msg)

    if DebugMode then
        local data = {}
        data.ret = 0
        data.goodsinfo = {}
        local goodsId = ItemId2GoodsId(itemId)
        data.goodsinfo.goodsId = goodsId
        data.goodsinfo.dynamicprice = mGoodsSpecInfoDic[goodsId].dynamicprice
        data.goodsinfo.leftbuycount = mGoodsSpecInfoDic[goodsId].leftbuycount
        data.goodsinfo.leftsellcount = mGoodsSpecInfoDic[goodsId].leftsellcount - count

        local realPrice = GetRealPrice(GetTableDataById(goodsId), 2)
        mHaveNum = mHaveNum + realPrice * count

        local newCount = GetItemCountByGoodsId(goodsId) - count
        UpdataCountByItemId(itemId, newCount)

        OnSell(data)
    end
end

--出售返回
function OnSell(data)
    LogProto(data)

    if data.ret == 0 then
        UpdateGoodsSpecInfoDic(data.goodsinfo)
        MessageSub.SendMessage(GameConfig.SUB_G_SHOP, GameConfig.SUB_G_SHOP_SELL, data.goodsinfo.goodsId)

        local itemData = ItemData.GetItemInfo(GoodsId2ItemId(data.goodsinfo.goodsId))
        local remainNum = data.goodsinfo.leftsellcount
        local content = WordData.GetWordStringByKey("Shop_sell_finish", data.goodsinfo.buycount, itemData.name, remainNum)
        TipsMgr.TipCommon(content, itemData)
    else
        GameLog.LogError("CommerceMgr.OnSell -> data.ret = %s", data.ret)
    end
end
---------------------------------消息收发---------------------------------

---------------------------------服务UI---------------------------------
--服务器数据是否准备完毕
function CheckServerDataIsInited()
    return mGoodsSpecInfoIsInited
end

--[[
    @desc: 根据筛选条件，获取符合数据的列表
    --@shopId: 商店类型，1商会，2商城
	--@oneType: 一级分类
	--@twoType: 二级分类
]]
function GetFullDataList(shopId, oneType, twoType)
    local dataList = {}

    local tableDataList = ShopData.GetDataList(shopId, oneType, twoType)
    if not tableDataList then
        return dataList
    end
    for _, tableData in ipairs(tableDataList) do
        if CheckCanShow(tableData) then
            table.insert(
                dataList,
                {
                    tableData = tableData,
                    info = mGoodsSpecInfoDic[tableData.id],
                    itemData = ItemData.GetItemInfo(tableData.itemId),
                    moneyItemData = ItemData.GetItemInfo(tableData.moneyId)
                }
            )
        end
    end

    return dataList
end

--计算真实价格
--data：商品表一行数据
--buyOrSell，1buy，2sell
function GetRealPrice(data, buyOrSell)
    local realPrice = 0
    if data then
        if data.selltype == Shop_pb.GoodsInfo.ORIGINAL_PRICE then
            realPrice = data.price
        elseif data.selltype == Shop_pb.GoodsInfo.DISCOUNT_PRICE then
            local discount = data.discount / 1000
            realPrice = data.price * discount
            realPrice = math.floor(realPrice)
        elseif data.selltype == Shop_pb.GoodsInfo.FREE_PRICE then
            realPrice = 0
        elseif data.selltype == Shop_pb.GoodsInfo.DINAMIC_PRICE then
            --动态价格先不做
            realPrice = 1111
        end
    end

    --卖的打八折，折扣固定值
    if buyOrSell == 2 then
        realPrice = math.floor(realPrice * 0.8)
    end

    return realPrice
end
---------------------------------商会---------------------------------
--获取商会购买界面左侧的一二级下拉列表数据
function GetOneTwoList()
    local dataList = {}
    for oneIdx, twoList in ipairs(mTwoTypeName) do
        local oneName = mOneTypeName[oneIdx]
        local oneList = {}
        for twoIdx, twoName in ipairs(twoList) do
            local middleDataList = GetFullDataList(1, oneIdx, twoIdx)
            if #middleDataList > 0 then
                table.insert(oneList, {twoType = twoIdx, content = twoName})
            end
        end
        if #oneList > 0 then
            table.insert(dataList, {oneType = oneIdx, content = oneName, list = oneList})
        end
    end
    return dataList
end

--根据当前的Normal类型背包里的数据，填充并包装List，给商会出售界面使用
function GetLeftDataList()
    local dataList = {}

    local bagData = BagMgr.BagData[Bag_pb.NORMAL]

    if DebugMode then
        if not bagData then
            bagData = {}
        end
        bagData.items = debugItems
    end

    if not bagData or type(bagData) ~= "table" then
        return dataList
    end
    local itemData = nil
    local tableData = nil
    local info = nil
    for _, itemSlot in ipairs(bagData.items) do
        itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
        --检查该物品是否可出售
        if itemData and CheckItemDataIsCanSell(itemData) then
            tableData = GetTableDataById(itemData.goodsId)
            info = mGoodsSpecInfoDic[itemData.goodsId]
            if info then
                --出售剩余次数<=0则不显示在left区域内
                if info.leftsellcount >= 1 then
                    table.insert(
                        dataList,
                        {
                            tableData = tableData,
                            info = info,
                            itemData = itemData,
                            moneyItemData = ItemData.GetItemInfo(tableData.moneyId),
                            count = itemSlot.item.count
                        }
                    )
                end
            else
                --物品表里可卖的物品id，在商城表里不存在
                GameLog.LogError("CommerceMgr.GetLeftDataList -> info is nil, tempId = %s", itemData.id)
            end
        end
    end

    return dataList
end

--根据商品id获取LeftData，商会出售
function GetLeftData(goodsId)
    if not goodsId then
        return nil
    end
    --当前背包数量为0
    local count = GetItemCountByGoodsId(goodsId)
    if count <= 0 then
        return nil
    end
    local itemId = GoodsId2ItemId(goodsId)
    if itemId == -1 then
        return nil
    end
    local tableData = GetTableDataById(goodsId)
    if not tableData then
        return nil
    end
    --出售剩余次数<=0则不显示
    local info = mGoodsSpecInfoDic[goodsId]
    if info.leftsellcount <= 0 then
        return nil
    end
    local data = {}
    data.tableData = tableData
    data.info = info
    data.itemData = ItemData.GetItemInfo(itemId)
    data.moneyItemData = ItemData.GetItemInfo(tableData.moneyId)
    return data
end

--商会购买左侧列表的一二级列表选中类型
function SetLastLeftType(oneType, twoType)
    mLastLeftId.one = oneType
    mLastLeftId.two = twoType
end

function GetLastLeftType()
    return mLastLeftId
end

--商会购买中间区域显示的一二级类型
function SetLastMiddleType(oneType, twoType)
    mLastMiddleId.one = oneType
    mLastMiddleId.two = twoType
end

function GetLastMiddleType()
    return mLastMiddleId
end

--商会购买右侧显示的商品记录
function SetLastGoodsId(goodsId)
    mLastGoodsId = goodsId
end

function GetLastGoodsId()
    return mLastGoodsId
end

--根据一个FullData计算折扣率字符串
function GetDiscountNumStr(data)
    local numStr = ""
    if data.tableData.selltype == Shop_pb.GoodsInfo.DISCOUNT_PRICE then
        numStr = WordData.GetWordStringByKey("Shop_discounts", data.tableData.discount / 100)
    end
    return numStr
end

function GetCommerceCoinItemData()
    return ItemData.GetItemInfo(mCommerceCoinItemId)
end

--根据货币类型获取拥有数量
function GetHaveNum(type)
    if DebugMode then
        return mHaveNum
    else
        return BagMgr.GetMoney(type)
    end
end

if DebugMode then
    --用于测试动态修改货币数量接口
    function SetHaveNum(haveNum)
        mHaveNum = haveNum
        GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_GETCOIN)
    end
end

if DebugMode then
    function AddNewItem(slotId, id, itemId, count)
        table.insert(debugItems, {slotId = slotId, item = {id = id, tempId = itemId, count = count}})
        local oper = {operType = Bag_pb.BAGOPERTYPE_ADD}
        local changeNum = 0
        GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_BAG_OPERATION, Bag_pb.NORMAL, oper, changeNum)
    end

    function UpdateItem(slotId, addCount)
        for _, itemSlot in ipairs(debugItems) do
            if itemSlot and itemSlot.slotId == slotId then
                itemSlot.item.count = itemSlot.item.count + addCount
            end
        end
        local oper = {operType = Bag_pb.BAGOPERTYPE_UPDATE}
        local changeNum = addCount
        GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_BAG_OPERATION, Bag_pb.NORMAL, oper, changeNum)
    end
end

--id：商品表id
function GetTableDataById(id)
    return ShopData.GetDataById(id)
end

--获取该商品的购买剩余次数（本周期内）
function GetLeftBuyCountById(goodsId)
    local count = 0

    if goodsId and mGoodsSpecInfoDic[goodsId] then
        return mGoodsSpecInfoDic[goodsId].leftbuycount
    end

    return count
end

--获取该商品的购买剩余次数（本周期内）
--data:MiddleData
function GetLeftBuyCountByData(data)
    if data then
        return data.info.leftbuycount
    else
        return 0
    end
end

--获取该商品的出售剩余次数（本周期内）
function GetLeftSellCountById(goodsId)
    local count = 0

    if goodsId and mGoodsSpecInfoDic[goodsId] then
        return mGoodsSpecInfoDic[goodsId].leftsellcount
    end

    return count
end

--获取该商品的出售剩余次数（本周期内）
--data:LeftData
function GetLeftSellCountByData(data)
    if data then
        return data.info.leftsellcount
    else
        return 0
    end
end

--获取goodsId对应的物品在Bag_pb.NORMAL类型的背包里的数量
function GetItemCountByGoodsId(goodsId)
    if not goodsId then
        return 0
    end
    local itemId = GoodsId2ItemId(goodsId)
    if itemId ~= -1 then
        if DebugMode then
            return GetCountByItemId(itemId)
        else
            return BagMgr.GetCountByItemId(itemId)
        end
    else
        return 0
    end
end
---------------------------------商会---------------------------------

---------------------------------商城---------------------------------

---------------------------------商城---------------------------------
---------------------------------服务UI---------------------------------

return CommerceMgr
