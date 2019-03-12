module("ItemDropData", package.seeall)

DATA.ItemDropData.mItemDropInfos = nil;
DATA.ItemDropData.mItemPackageInfos = nil;
DATA.ItemDropData.mRandPakageInfos = nil;

local function OnLoadItemDropInfo(data)
	local datas = ItemDrop_pb.AllItemDrops();
	datas:ParseFromString(data);
	
	local itemDropInfo = {};
	
	for k, v in ipairs(datas.itemdroplist) do
		itemDropInfo[v.id] = v;
	end
	
	DATA.ItemDropData.mItemDropInfos = itemDropInfo;
end

local function OnLoadItemPackageInfo(data)	
	local datas = ItemDrop_pb.AllItemPackage();
	datas:ParseFromString(data);
	
	local itemPackageInfo = {};
	
	for k, v in ipairs(datas.certainlist) do
		itemPackageInfo[v.id] = v;
	end
	
	DATA.ItemDropData.mItemPackageInfos = itemPackageInfo;
end

local function OnLoadRandPackageInfo(data)
	local datas = ItemDrop_pb.AllRandPackage();
	datas:ParseFromString(data);
	
	local randPackageInfo = {};
	
	for k, v in ipairs(datas.randlist) do
		randPackageInfo[v.id] = v;
	end
	
	DATA.ItemDropData.mRandPakageInfos = randPackageInfo;
end

function InitModule()
	local argData1 =
	{
		keys = {mItemDropInfos = true},
		fileName = "ItemDrop.bytes",
		callBack = OnLoadItemDropInfo,
	}
	local argData2 =
	{
		keys = {mItemPackageInfos = true},
		fileName = "ItemPackage.bytes",
		callBack = OnLoadItemPackageInfo,
	}
	local argData3 =
	{
		keys = {mRandPakageInfos = true},
		fileName = "ItemRandPackage.bytes",
		callBack = OnLoadRandPackageInfo,
	}
	
	DATA.CREATE_LOAD_TRIGGER(DATA.ItemDropData, argData1, argData2, argData3);
end

function GetDropItemInfo(dropId)
	return DATA.ItemDropData.mItemDropInfos[dropId];
end

function GetCertainDropInfo(certaomDropId)
	return DATA.ItemDropData.mItemPackageInfos[certaomDropId];
end

function GetProbabilityDropInfo(probabilityId)
	return DATA.ItemDropData.mRandPakageInfos[probabilityId];
end

--Warning: 这个方法根据掉落ID 获得所有 必掉 和 随机 小包里的物品
function GetAwardItems(awardId, certianDropCount, ProbabilityDropCount)
	local dropList = {};
	
	local dropInfo = GetDropItemInfo(awardId);
	if not dropInfo then return dropList; end
	local certainDropBindId = dropInfo.certainDropbindID;
	local certainDropBindInof = GetCertainDropInfo(certainDropBindId);
	if certainDropBindInof then
		local certainDropBindItemList = certainDropBindInof.items;
		for k, v in ipairs(certainDropBindItemList) do
			local certainDropInfo = {};
			certainDropInfo.itemId = v.id;
			certainDropInfo.minCount = v.minNum;
			certainDropInfo.maxCount = v.maxNum;
			certainDropInfo.isBind = true;
			table.insert(dropList, certainDropInfo)
		end
	end
	local certainDropNotBindId = dropInfo.certainDropnotBindID;
	local certainDropNotBindInof = GetCertainDropInfo(certainDropNotBindId);
	if certainDropNotBindInof then
		local certainDropNotBindItemList = certainDropNotBindInof.items;
		for k, v in ipairs(certainDropNotBindItemList) do
			--没有查重
			local certainDropInfo = {};
			certainDropInfo.itemId = v.id;
			certainDropInfo.minCount = v.minNum;
			certainDropInfo.maxCount = v.maxNum;
			certainDropInfo.isBind = false;
			table.insert(dropList, certainDropInfo)
		end
	end
	
	local randPackageIds = dropInfo.probabilityDrops;
	for k, v in ipairs(randPackageIds) do
		local randItemDropInfo = GetProbabilityDropInfo(v.id);
		if randItemDropInfo then
			local randDropList = randItemDropInfo.list;
			for r, m in ipairs(randDropList) do
				--没有查重
				local randDropItem = {};
				randDropItem.itemId = m.id;
				randDropItem.isBind = v.isbind;
				randDropItem.minCount = m.count;
				randDropItem.maxCount = m.count;--为了数据统一
				randDropItem.isRandom = true;
				table.insert(dropList, randDropItem);
			end
		end
	end
	return dropList;
end


return ItemDropData; 