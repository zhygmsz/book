module("LocationData",package.seeall);

DATA.LocationData.mProvinceList = nil;
DATA.LocationData.mProvincesByID = nil;
DATA.LocationData.mCityList = nil;
DATA.LocationData.mCitiesByID = nil;

local function OnLoadProvinceData(data)
    local datas = LocationData_pb.AllProvinceAddress();
    datas:ParseFromString(data);
    
    local provinceList = {};
    local provincesByID = {};
    for k,v in ipairs(datas.provinceAddress) do
        local item = {};
        item.id = v.id;
        item.name = v.name;
        item.cities = {};
        table.insert(provinceList,item);
        provincesByID[v.id] = item;
    end
    
    DATA.LocationData.mProvinceList = provinceList;
    DATA.LocationData.mProvincesByID = provincesByID;
    local trigger = DATA.LocationData.mCityTrigger;
end

local function OnLoadCityData(data)
    local datas = LocationData_pb.AllCityAddress();
    datas:ParseFromString(data);
    
    local cityList = {};
    local citiesByID = {};
    for k,v in ipairs(datas.cityAddress) do
        local item = {};
        item.id = v.id;
        item.name = v.name;
        item.pid = v.provinceId;
        table.insert(cityList,item);
        citiesByID[v.id] = item;
        
        local pid = v.provinceId;
        local province = DATA.LocationData.mProvincesByID[pid];
        table.insert(province.cities,v.id);
    end
    
    DATA.LocationData.mCityList = cityList;
    DATA.LocationData.mCitiesByID = citiesByID;
end

function InitModule()
	local argData1 = 
	{
		keys = { mProvinceList = true,mProvincesByID = true,mCityList = true,mCitiesByID = true },
		fileName = "ProvinceAddress.bytes",
		callBack = OnLoadProvinceData,
    }
    local argData2 = 
	{
		keys = { mCityTrigger = true},
		fileName = "CityAddress.bytes",
		callBack = OnLoadCityData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.LocationData,argData1,argData2);
end

function GetAllProvinces()
    local list = {};
    for i,pro in ipairs(DATA.LocationData.mProvinceList) do
        table.insert(list,pro.id);
    end
    return list;
end

function GetProvinceName(pid)
    if DATA.LocationData.mProvincesByID[pid] then
        return DATA.LocationData.mProvincesByID[pid].name;
    else
        return "";
    end
end

function GetAllCities(pid)
    local list = {};
    if DATA.LocationData.mProvincesByID[pid] then
        for i,cid in ipairs(DATA.LocationData.mProvincesByID[pid].cities) do
            table.insert(list,cid);
        end
    end
    return list;
end

function GetCityName(cid)
    if DATA.LocationData.mCitiesByID[cid] then
        return DATA.LocationData.mCitiesByID[cid].name;
    else
        return "";
    end
end

function IsProvince(id)
    if DATA.LocationData.mProvincesByID[id] then
        return true;
    end
    return false;
end

function IsCity(id)
    if DATA.LocationData.mCitiesByID[id] then
        return true;
    end
    return false;
end

function GetProvinceID(cityID)
    if DATA.LocationData.mCitiesByID[cityID] then
        return DATA.LocationData.mCitiesByID[cityID].pid;
    end
end

return LocationData;

