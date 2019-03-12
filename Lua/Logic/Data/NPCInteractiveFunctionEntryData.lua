module("NPCInteractiveFunctionEntryData",package.seeall);

DATA.NPCInteractiveFunctionEntryData.mNPCFunGroupDatas = nil;
DATA.NPCInteractiveFunctionEntryData.mNPCFunDatas = nil;

local function OnLoadNPCFunData(data)
	local datas = NPCInteractiveFunctionEntry_pb.AllNPCInteractiveFunctionEntry();
	datas:ParseFromString(data);
	
	local npcFunGroupDatas = {};
	local npcFunDatas = {};
	
	for i = 1,#datas.datas do
		local npcFunData = datas.datas[i];
		
		npcFunDatas[npcFunData.id] = npcFunData;
		npcFunGroupDatas[npcFunData.groupId] = npcFunGroupDatas[npcFunData.groupId] or {};
		table.insert(npcFunGroupDatas[npcFunData.groupId],npcFunData);
	end

	DATA.NPCInteractiveFunctionEntryData.mNPCFunGroupDatas = npcFunGroupDatas;
	DATA.NPCInteractiveFunctionEntryData.mNPCFunDatas = npcFunDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mNPCFunGroupDatas = true, mNPCFunDatas = true },
		fileName = "NPCInteractiveFunctionEntry.bytes",
		callBack = OnLoadNPCFunData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.NPCInteractiveFunctionEntryData,argData1);
end

function GetNPCFunDatasByGroupId(groupID)
	return DATA.NPCInteractiveFunctionEntryData.mNPCFunGroupDatas[groupID];
end

function GetNPCFunData(entryID)
	return DATA.NPCInteractiveFunctionEntryData.mNPCFunDatas[entryID];
end

function GetNPCFunGroupID(entryID)
	local npcFunData = DATA.NPCInteractiveFunctionEntryData.mNPCFunDatas[entryID];
	return npcFunData and npcFunData.groupId;
end

return NPCInteractiveFunctionEntryData;
