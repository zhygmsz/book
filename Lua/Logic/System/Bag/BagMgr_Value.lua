module("BagMgr",package.seeall);

--物品TIPS打开类
TIP_OPEN_TYPE = {PACKAGE = 1,STORAGE_L = 2,STORAGE_R = 3,TEMP = 4,EQUIP = 5}
--背包结构
--页组、页最大数、格子最大数、货币
BagData = 
{
    [Bag_pb.EQUIP] = nil,
    [Bag_pb.NORMAL] = nil,
    [Bag_pb.TEMP] = nil,
    [Bag_pb.DEPOT1] = nil,
    [Bag_pb.DEPOT2] = nil,
    [Bag_pb.DEPOT3] = nil,
    [Bag_pb.DEPOT4] = nil,
    [Bag_pb.DEPOT5] = nil,
    [Bag_pb.DEPOT6] = nil,
    [Bag_pb.DEPOT7] = nil,
    [Bag_pb.DEPOT8] = nil,
    [Bag_pb.DEPOT9] = nil,
    [Bag_pb.DEPOT10] = nil,
    [Bag_pb.DEPOT11] = nil,
    [Bag_pb.DEPOT12] = nil,
    [Bag_pb.PUZZLE] = nil,
}

BagGridData = 
{
    [Bag_pb.EQUIP] = nil,
    [Bag_pb.NORMAL] = nil,
    [Bag_pb.TEMP] = nil,
    [Bag_pb.DEPOT1] = nil,
    [Bag_pb.DEPOT2] = nil,
    [Bag_pb.DEPOT3] = nil,
    [Bag_pb.DEPOT4] = nil,
    [Bag_pb.DEPOT5] = nil,
    [Bag_pb.DEPOT6] = nil,
    [Bag_pb.DEPOT7] = nil,
    [Bag_pb.DEPOT8] = nil,
    [Bag_pb.DEPOT9] = nil,
    [Bag_pb.DEPOT10] = nil,
    [Bag_pb.DEPOT11] = nil,
    [Bag_pb.DEPOT12] = nil,
    [Bag_pb.PUZZLE] = nil,
}

--筛选指定类型的指定仓库的格子列表
FILTER_K_V = {
    [1] = {
            Item_pb.ItemInfo.COMMON,
            Item_pb.ItemInfo.EQUIP,
            Item_pb.ItemInfo.GEMSTONE,
            Item_pb.ItemInfo.BRINGUP,
            Item_pb.ItemInfo.GIFT,
            Item_pb.ItemInfo.MEDICINE,
            Item_pb.ItemInfo.ITEMINFO_OTHER
        },
    [2] = {Item_pb.ItemInfo.EQUIP},
    [3] = {Item_pb.ItemInfo.BRINGUP,Item_pb.ItemInfo.GEMSTONE},
    [4] = {Item_pb.ItemInfo.COMMON,Item_pb.ItemInfo.MEDICINE,Item_pb.ItemInfo.GIFT,Item_pb.ItemInfo.ITEMINFO_OTHER},
}

--使用物品的临时数组
mTempUsetable ={}
mLastEquipItem = nil
--上次打开背包的时间
mLastOpenTime=0
--特效缓存数组
mEffectID={}
--背包新增物品
mBagNewItems = {}

--背包内所有宝石分类字典（只考虑NORMAL类型背包）
--key：宝石类型
--value：该分类下的ItemSlot列表，按slotId从小到大排序
mGemTypeDic = {}

--货币补充兑换之后的回调
mCoinExchangeCallback = nil
mCoinExchangeCallbackParam = nil

--快捷使用数据对象
mQuickUseObj = nil

--货币补充兑换解决方案数组
mCoinSupplySolution = {}