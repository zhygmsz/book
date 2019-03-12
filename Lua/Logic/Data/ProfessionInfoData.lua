module("ProfessionInfoData",package.seeall)

DATA.ProfessionInfoData.mProfessionInfo = nil;

local function OnLoadProfessionInfo(data)
	local datas = ProfessionInfo_pb.AllProfessionInfo();
	datas:ParseFromString(data);

	local attTable = {};

	for k,v in ipairs(datas) do
		attTable[v.id] = v
	end

	DATA.ProfessionInfoData.mProfessionInfo = attTable;
end

function InitModule()
	local argData1 = 
	{
		keys = { mProfessionInfo = true },
		fileName = "ProfessionInfo.bytes",
		callBack = OnLoadProfessionInfo,
    }
	DATA.CREATE_LOAD_TRIGGER(DATA.ProfessionInfoData,argData1);
end

function GetProfessionInfo()
	return DATA.ProfessionInfoData.mProfessionInfo;
end

return ProfessionInfoData;