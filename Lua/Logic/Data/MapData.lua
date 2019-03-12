module("MapData",package.seeall);

DATA.MapData.mMapInfos = nil;
DATA.MapData.mMapUnit2MapInfo = nil;
DATA.MapData.mMapUnit2SceneID = nil;
DATA.MapData.mMapUnits = {};
DATA.MapData.mMapPreLoads = nil;
DATA.MapData.mWorldMapItemInfos = nil;
DATA.MapData.mAreaMapItemInfos = nil;

local function OnLoadMapInfo(data)
	local datas = MapInfo_pb.AllSpaceConfigs();
	datas:ParseFromString(data);

	local mapInfos = {};
	local mapUnit2MapInfo = {};
	local mapUnit2SceneID = {};

	for k,v in ipairs(datas.configs) do
		mapInfos[v.spaceId] = v;
		for _,spaceMap in ipairs(v.spaceMaps) do
			mapUnit2MapInfo[spaceMap.mapUnitID] = v.spaceId;
			mapUnit2SceneID[spaceMap.mapUnitID] = spaceMap.mapResID;
		end
	end

	DATA.MapData.mMapInfos = mapInfos;
	DATA.MapData.mMapUnit2MapInfo = mapUnit2MapInfo;
	DATA.MapData.mMapUnit2SceneID = mapUnit2SceneID;
end

local function OnLoadMapUnit(data, mapID)
	local datas = MapUnit_pb.MapUnit();
	datas:ParseFromString(data);	
	DATA.MapData.mMapUnits[mapID] = datas;  
end

local function OnLoadMapPreLoad(data)
	local datas = MapInfo_pb.AllMapPreloadItems();
	datas:ParseFromString(data);

	local preloads = {};

	DATA.MapData.mMapPreLoads = preloads;
end

local function OnLoadWorldMapInfoData(data)
	local datas = MapInfo_pb.AllWorldMapItems();
	datas:ParseFromString(data);

	local worldMapItemInfos = {};
	
	for k,v in ipairs(datas.worldMapItems) do
		worldMapItemInfos[k] = v;
	end

	DATA.MapData.mWorldMapItemInfos = worldMapItemInfos;
end

local function OnLoadAreaMapData(data)
	local datas = MapInfo_pb.AllAreaMaps();
	datas:ParseFromString(data);

	local areaMapItemInfos = {};

	for k,v in ipairs(datas.areaMaps) do
		areaMapItemInfos[v.id] = v;
	end

	DATA.MapData.mAreaMapItemInfos = areaMapItemInfos;
end

function InitModule()
	local argData1 = 
	{
		keys = { mMapInfos = true, mMapUnit2MapInfo = true, },
		fileName = "SpaceConfig.bytes",
		callBack = OnLoadMapInfo,
	}
	local argData2 = 
	{
		keys = { mMapPreLoads = true },
		fileName = "PreloadInfo.bytes",
		callBack = OnLoadMapPreLoad,
	}
	local argData3 = 
	{
		keys = { mWorldMapItemInfos = true },
		fileName = "WorldMapInfo.bytes",
		callBack = OnLoadWorldMapInfoData,
	}
	local argData4 = 
	{
		keys = { mAreaMapItemInfos = true },
		fileName = "AreaMapInfo.bytes",
		callBack = OnLoadAreaMapData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.MapData,argData1,argData2,argData3,argData4);
end

function GetMapInfo(mapID)
	return DATA.MapData.mMapInfos[mapID];
end

function GetSpaceID(mapUnitID)
	return DATA.MapData.mMapUnit2MapInfo[mapUnitID] or -1;
end

function GetSceneID(mapUnitID)
	return DATA.MapData.mMapUnit2SceneID[mapUnitID] or -1;
end

function GetMapUnit(mapUnitID)
	if not DATA.MapData.mMapUnits[mapUnitID] then
		ResMgr.LoadBytes("MapUnit/MapUnit_" .. mapUnitID .. ".bytes",OnLoadMapUnit,mapUnitID);
	end
	return DATA.MapData.mMapUnits[mapUnitID];
end

function GetMapPreload(mapID)
	return DATA.MapData.mMapPreLoads[mapID];
end

function GetAreaMapInfo(sceneID)
    return DATA.MapData.mAreaMapItemInfos[sceneID];
end

function GetAllWorldMapItemInfo()
    return DATA.MapData.mWorldMapItemInfos;
end

return MapData;


