module("EnvelopeData", package.seeall)

DATA.EnvelopeData.infos = nil;

local function OnLoadEnvelopeInfoData(data)
	local datas = EnvelopeInfo_pb.AllEnvelopeInfos();
	datas:ParseFromString(data);
	
	local AllInfos = {};
	
	for k, v in ipairs(datas.infos) do
	AllInfos[v.id] = v;
	end
	
	DATA.EnvelopeData.infos = AllInfos;
end

function InitModule()
	local argData1 =
	{
		keys = {infos = true},
		fileName = "EnvelopeInfo.bytes",
		callBack = OnLoadEnvelopeInfoData,
	}
	
	DATA.CREATE_LOAD_TRIGGER(DATA.EnvelopeData, argData1);
end

function GetEnvelopeInfoByID(id)
	return DATA.EnvelopeData.infos[id];
end

return EnvelopeData;
