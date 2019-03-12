module("BigMapMgr",package.seeall);

function GetAreaMapInfoById(areaMapId)
    return MapData.GetAreaMapInfo(areaMapId);
end

function GetWorldMapItemList()
    return MapData.GetAllWorldMapItemInfo();
end

function InitModule()
end

return BigMapMgr;