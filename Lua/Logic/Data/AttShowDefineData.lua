module("AttShowDefineData",package.seeall);

DATA.AttShowDefineData.mAllShowDatas = nil;

local function OnLoadAttShowDefineData(data)
    local datas = AttShowDefineData_pb.AllAttShowDefineData();
    datas:ParseFromString(data);

	local allShowDatas = {}

    for k,v in ipairs(datas.datas) do
		allShowDatas[v.id] = v;
	end

	DATA.AttShowDefineData.mAllShowDatas = allShowDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mAllShowDatas = true },
		fileName = "AttShowDefineData.bytes",
		callBack = OnLoadAttShowDefineData,
	}
	DATA.CREATE_LOAD_TRIGGER(DATA.AttShowDefineData,argData1);
end

function GetAllShowData()
	return DATA.AttShowDefineData.mAllShowDatas;
end

return AttShowDefineData;
