module("AttDefineData",package.seeall);

DATA.AttDefineData.mAttDefineData = nil;
DATA.AttDefineData.mPropertyMappingData = nil;
DATA.AttDefineData.mLevelAttDefineData = nil;
DATA.AttDefineData.mAllShowDatas = nil;

local function OnLoadAttDefineData(data)
    local datas = AttDefineData_pb.AllAttDefineData();
    datas:ParseFromString(data);

	local defineData = {}
	local allShowDatas = {}

    for k,v in ipairs(datas.datas) do
		defineData[v.id] = v;
		if v.weight ~= 0 and v.showWhether == 1 then table.insert(allShowDatas, { id = v.id, deltaValue = 0, data = v }) end
	end

	DATA.AttDefineData.mAttDefineData = defineData;
	DATA.AttDefineData.mAllShowDatas = allShowDatas;
end

local function OnLoadPropertyMappingData(data)
    local datas = AttDefineData_pb.AllPropertyMapping();
    datas:ParseFromString(data);

    local pmData = {}

    for k,v in ipairs(datas.maps) do
        pmData[v.id] = v.values;
    end

    DATA.AttDefineData.mPropertyMappingData = pmData;
end

local function OnLoadLevelAttDefineData(data)
    local datas = AttDefineData_pb.AllLevelAttDefineData();
    datas:ParseFromString(data);

    local levelDefineData = {}

    for k,v in ipairs(datas.datas) do
        levelDefineData[v.level] = v;
    end

    DATA.AttDefineData.mLevelAttDefineData = levelDefineData;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAttDefineData = true, mAllShowDatas = true },
		fileName = "AttDefineData.bytes",
		callBack = OnLoadAttDefineData,
	}
	local argData2 = 
	{
		keys = { mPropertyMappingData = true },
		fileName = "PropertyMapping.bytes",
		callBack = OnLoadPropertyMappingData,
	}
	local argData3 = 
	{
		keys = { mLevelAttDefineData = true },
		fileName = "LevelAttDefineData.bytes",
		callBack = OnLoadLevelAttDefineData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.AttDefineData,argData1,argData2,argData3);
end

function GetConvertDatas(pID)
	return DATA.AttDefineData.mPropertyMappingData[pID] or {};
end

function GetLevelData(level)
	return DATA.AttDefineData.mLevelAttDefineData[level];
end

function GetDefineData(pID)
	return DATA.AttDefineData.mAttDefineData[pID];
end

function GetAllDefineData()
	return DATA.AttDefineData.mAttDefineData;
end

function GetAllShowData()
	return DATA.AttDefineData.mAllShowDatas;
end

return AttDefineData;
