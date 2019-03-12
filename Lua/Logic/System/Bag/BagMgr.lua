module("BagMgr",package.seeall);
local Json = require "cjson" 

--特效缓存数组
local mEffects = {}
--背包新增物品
local BagNewItems = {}
--上次打开背包的时间
local mLastOpenTime=0
local Bag_QuickUse = nil

function InitModule()
    require("Logic/System/Bag/BagMgr_Value")
    require("Logic/System/Bag/BagMgr_Func")
    require("Logic/System/Bag/BagMgr_Gets")
    require("Logic/System/Bag/BagMgr_MsgHandle")
    require("Logic/System/Bag/BagMgr_MsgRequest")
    Bag_QuickUse = require("Logic/System/Bag/Bag_QuickUse")

    require("Logic/Presenter/UI/Bag/UI_Tip_UseMultiItems")
    require("Logic/Presenter/UI/Bag/UI_Tip_UseItem")
    require("Logic/Presenter/UI/Bag/UI_Tip_UnLockBag")
    require("Logic/Presenter/UI/Bag/UI_Tip_ItemInfoEx")
    require("Logic/Presenter/UI/Bag/UI_Tip_ExchangeWarning")
    require("Logic/Presenter/UI/Bag/UI_Tip_EnsureSupplyExchange")
    
    GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL,QuickUseItemWhenLevelUp);
    --进到副本中的回调
    GameEvent.Reg(EVT.MAPEVENT,EVT.MAP_ENTER_FINISH,OnMapLoadingFinish);
end

--初始化数据
function InitData()
    RequestBagData({Bag_pb.EQUIP,Bag_pb.NORMAL,Bag_pb.TEMP,Bag_pb.DEPOT1,Bag_pb.DEPOT2,Bag_pb.DEPOT3,Bag_pb.DEPOT4,Bag_pb.DEPOT5,Bag_pb.DEPOT6,Bag_pb.DEPOT7,Bag_pb.DEPOT8,Bag_pb.DEPOT9,Bag_pb.DEPOT10,Bag_pb.DEPOT11,Bag_pb.DEPOT12})
    RequestCoinInfo();
    mLastOpenTime =  UserData.ReadIntConfig("LastOpenTime") or 0
    local datastr = UserData.ReadConfig("BagNewItems")
    if datastr and datastr ~= "" then
        datastr = string.gsub(datastr,"null","{}")
        mBagNewItems = Json.decode(datastr)
    end
    mQuickUseObj = Bag_QuickUse.new()
    mQuickUseObj:RegEvent()
end

--背包格子显示对象添加新物品特效
function AddNewItemEffectToBagItem(item)
    local resId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_hongdian_01.prefab")
    local newItemLoader = LoaderMgr.CreateEffectLoader();
	newItemLoader:LoadObject(resId);
	newItemLoader:SetParent(item.transform,true);
	newItemLoader:SetLayer(CameraLayer.UILayer);
	newItemLoader:SetSortOrder(230);
	item.effectID = newItemLoader:GetGUID();
	newItemLoader:SetActive(false);
	item.newItemLoader = newItemLoader
end

--背包整理前保存新物品tempid
function SaveTempNewItemTempId(bagType)
    local mCurrentBagData = BagData[bagType]
    mBagNewItems[bagType].temptable = {}
    for i=1,#mCurrentBagData.items do
        --类型为BagItemSlot
        local titem = mCurrentBagData.items[i]
        if titem and titem.item and mBagNewItems[bagType][titem.slotId] then
            --物品id
            local tempId = titem.item.tempId
            --类型为 Item_Pb.Item
            if mBagNewItems[bagType].temptable[tempId]==nil then
                mBagNewItems[bagType].temptable[tempId]=1
            else
                mBagNewItems[bagType].temptable[tempId]=mBagNewItems[bagType].temptable[tempId]+1
            end
        end
    end
end
--根据保存新物品tempid重建新物品图标
function CheckTempNewItemTempId(bagType)
    if mBagNewItems and mBagNewItems[bagType] and mBagNewItems[bagType].temptable then
        local mCurrentBagData = BagData[bagType]
        for i=1,#mCurrentBagData.items do
            --类型为BagItemSlot
            local titem = mCurrentBagData.items[i]
            if titem and titem.item  then
                --物品id
                local tempId = titem.item.tempId
                local newsign = mBagNewItems[bagType].temptable[tempId]
                if newsign and newsign >0 then
                    --类型为 Item_Pb.Item
                    mBagNewItems[bagType][titem.slotId]=1
                    mBagNewItems[bagType].temptable[tempId]=newsign-1
                    if newsign-1 <=0 then mBagNewItems[bagType].temptable[tempId] = nil end
                end
            end
        end
        mBagNewItems[bagType].temptable = nil
    end
end

--新物品添加特效
function ShowNewItemEffect(bagType,item)
    local resId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_hongdian_01.prefab")
    local data = item.data
    local newItemLoader = item.newItemLoader
    if newItemLoader then
        newItemLoader:SetActive(false);
    end
    if data then
        local slotid = data.slotId
        if mBagNewItems[bagType] and mBagNewItems[bagType][slotid] and mBagNewItems[bagType][slotid] == 1 then
            if newItemLoader then
                newItemLoader:SetActive(true,true);
            end
        else
            if newItemLoader then
                newItemLoader:SetActive(false);
            end
        end
    end
end

function RemoveNewItemEffect(bagType,item)
    local data = item.data
    local effect = nil
    if data and item.newItemLoader then
        local slotid = data.slotId
        local newItemLoader =item.newItemLoader
        if newItemLoader then newItemLoader:SetActive(false); end
        if mBagNewItems[bagType] and mBagNewItems[bagType][slotid] and mBagNewItems[bagType][slotid] then
            mBagNewItems[bagType][slotid] = nil;
        end
    end
end

--清空新道具
function ClearBagNewItems(bagType)
    if mBagNewItems[bagType] then
        mBagNewItems[bagType]={}
    end
end

--保存背包新道具
function SaveBagNewItems()
    local datastr = Json.encode(mBagNewItems)
    UserData.WriteConfig("BagNewItems",datastr)
    local sec = TimeUtils.SystemTimeStamp(true)
    UserData.WriteIntConfig("LastOpenTime", sec)
end

function ShowItemTips(data)
    UI_Tip_ItemInfoEx.SetData(data)
    if UI_Tip_ItemInfoEx.IsShowed() then
        UI_Tip_ItemInfoEx.ShowTips()
    else
        UIMgr.ShowUI(AllUI.UI_Tip_ItemInfoEx)
    end
end
  
--使用物品的唯一入口 bagitem 背包格子数据 bagitem.itemData 物品表数据
function UniqueUseItem(bagType,data,num,autoSlotId)
    local canUse = true
    if data == nil then return end
    if data.itemData == nil then return end
    if data.item == nil then return end
    local itemData = data.itemData
    --特殊使用 跳转界面使用物品
    if itemData.useFun and itemData.useFun ~= Item_pb.ItemInfo.UF_NONE then
        --判断系统功能开启 ToDo
        if true then
            local actionid = itemData.useFunParam1
            local funcID = tonumber(actionid)
            if funcID then
                ActionMgr.ExecuteActionGroup(funcID)
            end
        else
            --提示 您还没有开启XX系统哦
            --TipsMgr.TipByKey("backpack_info_6");
            canUse = false
            TipsMgr.TipByFormat("您还没有开启XX系统哦")
        end
    end
    if itemData.useLimit  ~= Item_pb.ItemInfo.NOT_USE then
        if itemData.useLimit == Item_pb.ItemInfo.MAP then
            local cScene = MapMgr.GetMapUnitID()
            if cScene ~= itemData.limitParam1 then
                --本场景中无法使用该道具”
                canUse = false
                TipsMgr.TipByFormat("本场景中无法使用该道具")
            end
        end
    end
    if UserData.IsFighting()  then
        --“您的角色正处于战斗状态，无法使用该道具”
        canUse = false
        TipsMgr.TipByFormat("您的角色正处于战斗状态，无法使用该道具")
    end
    if itemData.useLevelDown > UserData.GetLevel() then
        ---“您还没有到达道具使用的等级” 
        canUse = false
        TipsMgr.TipByFormat("您还没有到达道具使用的等级")
    end
    --种族判定 0 无限制
    if itemData.useRacial > 0 then 
        if itemData.useRacial~=UserData.GetRacial() then
            ---“您的种族无法使用该道具”
            canUse = false
            TipsMgr.TipByFormat("您的种族无法使用该道具")
        end
    end
    if itemData.useProfession > 0 then 
        if itemData.useProfession~=UserData.GetProfession() then
            ---“您的职业无法使用该道具”
            canUse = false
            TipsMgr.TipByFormat("您的职业无法使用该道具")
        end
    end
     if itemData.expiryDate then
        local len = string.Length(itemData.expiryDate,0)
        if len == 19 then
            local sec = TimeUtils.FormatDate2TimeStamp(itemData.expiryDate,true)
            if sec < TimeUtils.SystemTimeStamp(true) then
                ---该道具已经过期啦，系统帮您回收了哦”  
                TipsMgr.TipByFormat("该道具已经过期啦，系统帮您回收了哦")
                canUse = false
            end
        end
     end
    if canUse then
        --是否是装备
        local isEquip = itemData.itemInfoType == Item_pb.ItemInfo.EQUIP
        --可否批量
        local canBatch = data.itemData.batchUse==1
        --可否堆叠
        local canStack = CheckSuperPosotion(data.item.tempId)
        --自动使用
        if autoSlotId then
            if isEquip then
                --装备
                if bagType == Bag_pb.NORMAL then
                    return BagMgr.UseEquipAutoSlotId(bagType,data.item.tempId)
                else
                    GameLog.LogError("bagType is not Bag_pb.NORMAL")
                    return false
                end
            else
                --物品
                if data.item.count > 1 and num > 1 and canBatch and canStack then
                    BagMgr.ShowMultiSlotUseItems(1,data,bagType,false,true)
                    return true
                elseif data.item.count >= 1 then
                    return BagMgr.UseItemAutoSlotId(bagType,data.item.tempId,1)
                end
            end
        else
            if isEquip then
                if bagType == Bag_pb.NORMAL then
                    BagMgr.RequestMoveBagItem(Bag_pb.NORMAL, data.slotId, data.item.id, Bag_pb.EQUIP, - 1)
                    return true
                else
                    GameLog.LogError("bagType is not Bag_pb.NORMAL")
                    return false
                end
            else
                if canBatch and data.item.count > 1 then
                    BagMgr.ShowMultiUseItems(1,data, bagType, true)
                    return true
                else
                    BagMgr.RequestUseBagItem(bagType,data.slotId, data.item.id,data.item.tempId, num)
                    return true
                end
            end
        end
    end
    return false
end

--显示批量使用界面
function ShowMultiUseItems(type,data,bagType,fullCount)
    UI_Tip_UseMultiItems.type = type
    UI_Tip_UseMultiItems.data = data;
    UI_Tip_UseMultiItems.bagType  =bagType
    UI_Tip_UseMultiItems.fullCount  =fullCount
    UI_Tip_UseMultiItems.AutoSlotId  =false
    UIMgr.ShowUI(AllUI.UI_Tip_UseMultiItems);
end

--显示批量使用界面
function ShowMultiSlotUseItems(type,data,bagType,fullCount,AutoSlotId)
    UI_Tip_UseMultiItems.type = type
    UI_Tip_UseMultiItems.data = data;
    UI_Tip_UseMultiItems.bagType  =bagType
    UI_Tip_UseMultiItems.fullCount  =fullCount
    UI_Tip_UseMultiItems.AutoSlotId  =AutoSlotId
    UIMgr.ShowUI(AllUI.UI_Tip_UseMultiItems);
end

function HideItemTips()
    UIMgr.UnShowUI(AllUI.UI_Tip_ItemInfoEx)
end

--==============================--
--desc:打开物品tips界面
--@style:见EquipMgr.ItemTipsStyle枚举
--@data:背包数据
--@bagType:背包类型
--==============================--
function OpenItemTipsByData(style, data, bagType)
    if style and data and bagType then
        local openData = {}
        openData.style = style
        openData.data = data
        openData.bagType = bagType
        ShowItemTips(openData)
    else
        GameLog.LogError("BagMgr.OpenItemTipsByData -> style or data or bagType is nil")
    end
end

--==============================--
--desc:打开物品tips界面
--@style:见EquipMgr.ItemTipsStyle枚举
--@tempId:物品表id
--==============================--
function OpenItemTipsByTempId(style, tempId)
    if style and tempId then
        local openData = {}
        openData.style = style
        local itemData = ItemData.GetItemInfo(tempId)
        openData.data = { itemData = itemData }
        openData.bagType = nil
        ShowItemTips(openData)
    else
        GameLog.LogError("BagMgr.OpenItemTipsByTempId -> style or tempId is nil")
    end
end

--进到副本的回调
function OnMapLoadingFinish()
    local obj = GetQuickUseObj()
    if obj then
        if not obj:IsEmpty() then
            obj:ClearUsing()
            UIMgr.ShowUI(AllUI.UI_Tip_UseItem)
        end
    end
end

return BagMgr;