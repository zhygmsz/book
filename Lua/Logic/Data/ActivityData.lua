module("ActivityData", package.seeall)

DATA.ActivityData.mActivityItemInfos = nil;
DATA.ActivityData.mVitalityItemInfos = nil;
DATA.ActivityData.mActivityImageInfos = nil;
DATA.ActivityData.mVitalityColorItemInfos = nil;

local function OnLoadActivityInfoData(data)
	local datas = ActivityInfo_pb.AllActivityItems();
	datas:ParseFromString(data);
	
	local activityItemInfos = {};
	
	for k, v in ipairs(datas.activityItems) do
		activityItemInfos[k] = v;
	end
	
	DATA.ActivityData.mActivityItemInfos = activityItemInfos;
end

local function OnLoadVitalityData(data)
	local datas = ActivityInfo_pb.AllVitalityItems();
	datas:ParseFromString(data);
	
	local vitalityItemInfos = {};
	
	for k, v in ipairs(datas.vitalityItems) do
		vitalityItemInfos[k] = v;
	end
	
	DATA.ActivityData.mVitalityItemInfos = vitalityItemInfos;
end

local function OnLoadAcitvityImageData(data)
	local datas = ActivityInfo_pb.AllActivityImages();
	datas:ParseFromString(data);
	
	local acitvityImageInfos = {};
	
	for k, v in ipairs(datas.activityImages) do
		acitvityImageInfos[k] = v;
	end
	
	DATA.ActivityData.mActivityImageInfos = acitvityImageInfos;
end

local function OnLoadVitalityColorItemData(data)
	local datas = ActivityInfo_pb.AllVitalityColorItems();
	datas:ParseFromString(data);
	
	local vitalityColorItemInfos = {};
	
	for k, v in ipairs(datas.vitalityColorItems) do
		vitalityColorItemInfos[k] = v;
	end
	
	DATA.ActivityData.mVitalityColorItemInfos = vitalityColorItemInfos;
end

function InitModule()
	local argData1 =
	{
		keys = {mActivityItemInfos = true},
		fileName = "ActivityItemInfo.bytes",
		callBack = OnLoadActivityInfoData,
	}
	local argData2 =
	{
		keys = {mVitalityItemInfos = true},
		fileName = "VitalityItemInfo.bytes",
		callBack = OnLoadVitalityData,
	}
	local argData3 =
	{
		keys = {mActivityImageInfos = true},
		fileName = "ActivityImageInfo.bytes",
		callBack = OnLoadAcitvityImageData,
	}
	local argData4 =
	{
		keys = {mVitalityColorItemInfos = true},
		fileName = "ColorItemInfo.bytes",
		callBack = OnLoadVitalityColorItemData,
	}
	
	DATA.CREATE_LOAD_TRIGGER(DATA.ActivityData, argData1, argData2, argData3, argData4);
end

function GetActivityItemInfoByType(activityType)
	local activityInfoList = {};
	for k, v in ipairs(DATA.ActivityData.mActivityItemInfos) do
		if v.type == activityType then
			table.insert(activityInfoList, v)
		end
	end
	return activityInfoList;
end

function GetActivityItemInfoById(activityId)
	for k, v in ipairs(DATA.ActivityData.mActivityItemInfos) do
		if v.id == activityId then
			return v;
		end
	end
	return nil;
end

function GetActivityItemInfos()
	return DATA.ActivityData.mActivityItemInfos;
end

function GetVitalityInfo()
	return DATA.ActivityData.mVitalityItemInfos;
end

function GetActivityImageById(imageId)
	for k,v in ipairs(DATA.ActivityData.mActivityImageInfos) do 
		if v.id == imageId then
			return v;
		end
	end
	return nil;
end

function GetVitalityColorInfoById(colorId)
	for k,v in ipairs(DATA.ActivityData.mVitalityColorItemInfos) do 
		if v.id == colorId then
			return v;
		end
	end
	return nil;
end

function GetVitalityColorInfos()
	return DATA.ActivityData.mVitalityColorItemInfos;
end

return ActivityData; 