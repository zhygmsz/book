module("QTEData",package.seeall)

DATA.QTEData.mIntMap = nil;
DATA.QTEData.mGroupMap = nil;

local function OnLoadQTEData(data)
	local datas = QTE_pb.AllQTEData()
	datas:ParseFromString(data)

	local intMap = {};
	local groupMap = {};

	for i,v in ipairs(datas.datas) do
		groupMap[v.groupId] = groupMap[v.groupId] or {};
		table.insert(groupMap[v.groupId],v)
		intMap[v.id] = v;
	end

	DATA.QTEData.mIntMap = intMap;
	DATA.QTEData.mGroupMap = groupMap;
end

function InitModule()
	local argData1 = 
	{
		keys = { mGroupMap = true , mIntMap = true  },
		fileName = "QTEData.bytes",
		callBack = OnLoadQTEData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.QTEData,argData1);
end

function GetData(id)
	return intMap[id];
end

function GetGroupData(id)
	return groupMap[id];
end

return QTEData;
