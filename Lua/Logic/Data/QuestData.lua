module("QuestData",package.seeall);

DATA.QuestData.mTaskStaticDatas = nil;
DATA.QuestData.mTaskGroupDatas = nil;

local function OnLoadTaskData(data)
	local datas = Quest_pb.AllQuestInfos();
	datas:ParseFromString(data);

	local taskStaticDatas = {};
	local taskGroupDatas = {};

	for k,v in ipairs(datas.questInfos) do
		taskStaticDatas[v.id] = v;
		taskGroupDatas[v.groupID] = taskGroupDatas[v.groupID] or {};
		table.insert(taskGroupDatas[v.groupID],v);
	end
	
	DATA.QuestData.mTaskStaticDatas = taskStaticDatas;
	DATA.QuestData.mTaskGroupDatas = taskGroupDatas;
end 

function InitModule()
	local argData1 = 
	{
		keys = { mTaskStaticDatas = true,mTaskGroupDatas = true },
		fileName = "Quest.bytes",
		callBack = OnLoadTaskData,
    }

	DATA.CREATE_LOAD_TRIGGER(DATA.QuestData,argData1);
end

function GetData(id)  
    return DATA.QuestData.mTaskStaticDatas[id];
end

function GetDatas(groupID)
	return DATA.QuestData.mTaskGroupDatas[groupID];
end

return QuestData;
