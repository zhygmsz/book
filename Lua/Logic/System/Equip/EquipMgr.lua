module("EquipMgr", package.seeall)

ItemTipsStyle = {}
--预留值
ItemTipsStyle.FromNone = 0
--当装Equip包裹处于打开时，点击Normal包裹里的装备
ItemTipsStyle.FromBagOnEquip = 1
--当Depot包裹处于打开时，点击Normal包裹里的装备
ItemTipsStyle.FromBagOnDepot = 2
--点击Equip包裹里的装备
ItemTipsStyle.FromEquip = 3
--点击Depot包裹里的装备
ItemTipsStyle.FromDepot = 4
--点击临时背包里的装备
ItemTipsStyle.FromTempBag = 5
--以tempId方式
ItemTipsStyle.FromTempId = 6
--点击快捷使用界面
ItemTipsStyle.FromUseItem = 7
--换装前后的装备总属性
local mPreProperties = {}
local mCurProperties = {}

--以下几种品质颜色，是专门针对于tips上的area1区域的
local mWhiteColor = Color(105 / 255, 105 / 255, 105 / 255, 1)
local mGreenColor = Color(41 / 255, 90 / 255, 46 / 255, 1)
local mBlueColor = Color(57 / 255, 92 / 255, 131 / 255, 1)
local mPurpleColor = Color(61 / 255, 50 / 255, 78 / 255, 1)
local mOrangeColor = Color(129 / 255, 71 / 255, 28 / 255, 1)

--通过快捷使用方式穿装备
local mEquipedFromQuickUseItem = false

--UI槽位到部位映射
Index2Bodytype = {
	--v换成部位枚举
	[1] = Item_pb.ItemInfo.WEAPON,
	[2] = Item_pb.ItemInfo.BRACERS,  --护腕
	[3] = Item_pb.ItemInfo.GLOVES,
	[4] = Item_pb.ItemInfo.RING,
	[5] = nil,
	[6] = Item_pb.ItemInfo.CLOTHES,
	[7] = Item_pb.ItemInfo.BELT,
	[8] = Item_pb.ItemInfo.SHOES,
	[9] = Item_pb.ItemInfo.NECKLACE,
	[10] = nil
}

--部位到UI槽位映射
Bodytype2Index = {}

--local方法
--[[
    @desc: 收集一件装备的所有属性（基础+随机）
    --@item:
	--@equipProperties: 
]]
local function FillOneEquipProperties(item, equipProperties)
	--基础属性
	for i = 1, #item.equipInfo.properties do
		local pro = item.equipInfo.properties[i]
		if equipProperties[pro.id] then
			equipProperties[pro.id] = equipProperties[pro.id] + pro.value
		else
			equipProperties[pro.id] = pro.value
		end
	end
	--随机属性
	for i = 1, #item.equipInfo.randProperties do
		local pro = item.equipInfo.randProperties[i]
		if equipProperties[pro.id] then
			equipProperties[pro.id] = equipProperties[pro.id] + pro.value
		else
			equipProperties[pro.id] = pro.value
		end
	end
end

local function ReverseIndex2Bodytype()
	for k, v in pairs(Index2Bodytype) do
		if v then
			Bodytype2Index[v] = k
		end
	end
end

local function ShowEquipTips(data)
	require("Logic/Presenter/UI/Bag/UI_Tip_EquipItemInfo")
	UI_Tip_EquipItemInfo.SetData(data)
	if AllUI.UI_Tip_EquipItemInfo.enable then
		UI_Tip_EquipItemInfo.ShowTips()
	else
		UIMgr.ShowUI(AllUI.UI_Tip_EquipItemInfo)
	end
end

--背包格子变化前
local function OnUpdateGridPre(bagType)
	if bagType == Bag_pb.EQUIP then
		table.clear(mPreProperties)
		GetAllEquipProperties(mPreProperties)
	end
end

--背包格子变化后
local function OnUpdateGrid(bagType)
	if bagType == Bag_pb.EQUIP then
		table.clear(mCurProperties)
		GetAllEquipProperties(mCurProperties)
		UserData.OnPropertyUpdate("EQUIP",mPreProperties,mCurProperties);
	end
end

local function OnBagOperation(bagType, oper)
	if bagType == Bag_pb.EQUIP then
		if oper.operType == Bag_pb.BAGOPERTYPE_ADD then
			TipsMgr.TipByKey("equip_equip")
		end
	end
end

--==============================--
--desc:打开装备tips
--@style:见EquipMgr.ItemTipsStyle枚举
--@itemSlot:Bag.proto的BagItemSlot结构
--==============================--
function OpenEquipTips(style, itemSlot)
	if not style or not itemSlot then
		GameLog.LogError("EquipMgr.OpenEquipTips -> style or itemSlot is nil")
		return
	end
	local data = {}
	data.style = style
	data.itemSlot = itemSlot
	if style == ItemTipsStyle.FromBagOnEquip then
		local equipedItemSlot = GetEquipedItemSlot(itemSlot.item)
		if equipedItemSlot then
			data.equipedItemSlot = equipedItemSlot
		end
	end
	ShowEquipTips(data)
end

--获取一件装备的部位
function Equip2BodyType(item)
	local data = ItemData.GetEquipmentInfo(item.tempId)
	return data and data.bodyType or - 1
end

--给定一个装备，返回装备栏对应部位的装备，没有则返回nil
function GetEquipedItemSlot(item)
	if not item then
		return
	end
	local bodyType = Equip2BodyType(item)
	return GetEquipedItemSlotByBodyType(bodyType)
end

function GetEquipedItemSlotByBodyType(bodyType)
	if not bodyType then
		return
	end
	local equipData = BagMgr.BagData[Bag_pb.EQUIP]
	if not equipData then
		return
	end
	for i = 1, #equipData.items do
		local itemSlot = equipData.items[i]
		if Equip2BodyType(itemSlot.item) == bodyType then
			return equipData.items[i]
		end
	end
end

--给定一个装备，检查装备栏是否已装备
function CheckIsEquiped(item)
	local equipedItem = GetEquipedItemSlot(item)
	return equipedItem and true or false
end

--获取对比数据
function GetComparedData(item, equipedItem)
	local comparedData = {}
	for i = 1, #item.equipInfo.properties do
		local property = item.equipInfo.properties[i]
		comparedData[property.id] = GetOneProCompareData(property, equipedItem)
	end
	return comparedData
end

--获取某一个属性的比较数据
--return 正数：上升箭头
--return 负数：下降箭头
function GetOneProCompareData(property, equipedItem)
	local difValue = property.value
	for i = 1, #equipedItem.equipInfo.properties do
		local pro = equipedItem.equipInfo.properties[i]
		if pro.id == property.id then
			difValue = property.value - pro.value
			break
		end
	end
	return difValue
end

--返回装备的某个基础属性的最小最大值
function GetOneProMinMaxValue(property, equipItem)
	local data = {min = 0, max = 0}
	local equipData = ItemData.GetEquipmentInfo(equipItem.tempId)
	for i = 1, #equipData.rateInfos do
		local rateInfo = equipData.rateInfos[i]
		if rateInfo.propertyID == property.id then
			data.min = tonumber(rateInfo.propertyMin)
			data.max = tonumber(rateInfo.propertyMax)
		end
	end
	return data
end

--返回装备的某个随机属性的最小最大值
function GetOneRandProMinMaxValue(property, equipItem)
	local data = {min = 0, max = 0}
	local equipData = ItemData.GetEquipmentInfo(equipItem.tempId)
	local attachValueData = ItemData.GetAttachValue(equipData.propertyAttachValueID)
	for i = 1, #attachValueData.rateInfos do
		local rateInfo = attachValueData.rateInfos[i]
		if rateInfo.propertyID == property.id then
			data.min = rateInfo.propertyMin
			data.max = rateInfo.propertyMax
			break
		end
	end
	return data
end

function GetEquipTipsArea1Color(quality)
    if quality == Item_pb.ItemInfo.WHITE then
        return mWhiteColor
    elseif quality == Item_pb.ItemInfo.GREEN then
        return mGreenColor
    elseif quality == Item_pb.ItemInfo.BLUE then
        return mBlueColor
    elseif quality == Item_pb.ItemInfo.PURPLE then
        return mPurpleColor
    elseif quality == Item_pb.ItemInfo.ORANGE then
        return mOrangeColor
    end
    return mWhiteColor
end

--物品快捷使用
function QuickUseItem(bagItemSlot, mItemData, changeNum, forceEqual)
	if not bagItemSlot or not bagItemSlot.item then
		return false
	end
	local selfLevel = UserData.GetLevel()
	if forceEqual then
		local newItem = bagItemSlot.item
		local newItemData = ItemData.GetItemInfo(newItem.tempId)
		if not newItemData then
			return false
		end
		return selfLevel == newItemData.useLevelDown or newItemData.useLevelDown == -1 or newItemData.useLevelDown == 0 
	else
		local newItem = bagItemSlot.item
		local equipedItemSlot = GetEquipedItemSlot(newItem)
		if equipedItemSlot then
			local newItemData = ItemData.GetItemInfo(newItem.tempId)
			local equipedItemData = ItemData.GetItemInfo(equipedItemSlot.item.tempId)
			if newItemData and equipedItemData then
				return newItemData.useLevelDown > equipedItemData.useLevelDown
			end
		else
			return true
		end
	end
	
	return false
end

--隐藏装备tips
function HideEquipTips()
	UIMgr.UnShowUI(AllUI.UI_Tip_EquipItemInfo)
end

--获取一件装备的评分
--item:Item.proto里的Item
--目前以最低使用等级作为最终评分
function GetScoreByItem(item)
	if item then
		local itemData = ItemData.GetItemInfo(item.tempId)
		if itemData then
			return itemData.useLevelDown
		end
	end
	return 0
end

--[[
	@desc: 收集当前所有装备的所有属性（基础+随机）
	--@equipProperties: 输出结构
]]
function GetAllEquipProperties(equipProperties)
	local equipData = BagMgr.BagData[Bag_pb.EQUIP]
	if equipData then
		for i = 1, #equipData.items do
			local itemSlot = equipData.items[i]
			FillOneEquipProperties(itemSlot.item, equipProperties)
		end
	end
end

function SetEquipedFromQuickUseItem(flag)
	mEquipedFromQuickUseItem = flag
end

function GetEquipedFromQuickUseItem()
	return mEquipedFromQuickUseItem
end

function InitModule()
	ReverseIndex2Bodytype();
	
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID_PRE, OnUpdateGridPre)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UPDATE_GRID, OnUpdateGrid)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_BAG_OPERATION, OnBagOperation)
end

return EquipMgr 