module("ItemData",package.seeall);

DATA.ItemData.mItemDatas = nil;
DATA.ItemData.mEquipmentDatas = nil;
DATA.ItemData.mAttachProperty = nil;
DATA.ItemData.mAttachValue = nil;

local function OnLoadItemData(data)
    local datas = Item_pb.AllItemInfos();
    datas:ParseFromString(data);
    
    local itemDatas = {};
    for k,v in ipairs(datas.iteminfos) do
        itemDatas[v.id] = v; 
    end
    
    DATA.ItemData.mItemDatas = itemDatas;
end 

local function OnLoadEquipData(data)
    local datas = EquipmentInfo_pb.AllEquipments();
    datas:ParseFromString(data);
    
    local equipDatas = {};

    for k,v in ipairs(datas.equips) do
        equipDatas[v.id] = v; 
    end
    
    DATA.ItemData.mEquipmentDatas = equipDatas;
end 

local function OnLoadAttachPropertyData(data)
    local datas = EquipmentInfo_pb.AllAttachProperties()
    datas:ParseFromString(data)

    local attachProperty = {};

    for k, v in ipairs(datas.properties) do
        attachProperty[v.id] = v
    end

    DATA.ItemData.mAttachProperty = attachProperty;
end

local function OnLoadAttachValueData(data)
    local datas = EquipmentInfo_pb.AllAttachValues()
    datas:ParseFromString(data)

    local attachValue = {};

    for k, v in ipairs(datas.values) do
        attachValue[v.id] = v
    end

    DATA.ItemData.mAttachValue = attachValue;
end

function InitModule()
	local argData1 = 
	{
		keys = { mItemDatas = true },
		fileName = "ItemInfo.bytes",
		callBack = OnLoadItemData,
	}
	local argData2 = 
	{
		keys = { mEquipmentDatas = true },
		fileName = "EquipmentInfo.bytes",
		callBack = OnLoadEquipData,
	}
	local argData3 = 
	{
		keys = { mAttachProperty = true },
		fileName = "AttachProperty.bytes",
		callBack = OnLoadAttachPropertyData,
	}
	local argData4 = 
	{
		keys = { mAttachValue = true },
		fileName = "AttachValue.bytes",
		callBack = OnLoadAttachValueData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.ItemData,argData1,argData2,argData3,argData4);
end

function GetItemInfo(id)  
    if id >= 0 then 
        return DATA.ItemData.mItemDatas[id];
    else
        return nil;
    end
end 

function GetEquipmentInfo(id)
    if id >= 0  then 
        return DATA.ItemData.mEquipmentDatas[id];
    else
        return nil;
    end
end

function GetAttachProperty(id)
    if id then
        return DATA.ItemData.mAttachProperty[id]
    else
        return nil
    end
end

function GetAttachValue(id)
    if id then
        return DATA.ItemData.mAttachValue[id]
    else
        return nil
    end
end

return ItemData;
