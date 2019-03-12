module("NPCData",package.seeall)

DATA.NPCData.mNpcDatas = nil;

local function OnLoadNPCData(data)
	local datas = NPCInfo_pb.AllNPCInfos();
	datas:ParseFromString(data);

	local npcDatas = {};

	for k,v in ipairs(datas.datas) do
		npcDatas[v.id] = v;
	end

	DATA.NPCData.mNpcDatas = npcDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mNpcDatas = true },
		fileName = "NPCInfo.bytes",
		callBack = OnLoadNPCData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.NPCData,argData1);
end

function GetNPCInfo(id)
	return DATA.NPCData.mNpcDatas[id];
end 

return NPCData;
