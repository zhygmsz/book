module("GameActionData",package.seeall);

DATA.GameActionData.mActionGroupDatas = nil;
DATA.GameActionData.mActionDatas = nil;

local function OnLoadGameActionData(data)
	local datas = GameAction_pb.AllGameAction();
	datas:ParseFromString(data);
	
	local actionGroupDatas = {};
	local actionDatas = {};
	
	for i = 1,#datas.datas do
		local actionData = datas.datas[i];
		
		actionDatas[actionData.id] = actionData;
		actionGroupDatas[actionData.groupID] = actionGroupDatas[actionData.groupID] or {};
		table.insert(actionGroupDatas[actionData.groupID],actionData);
	end

	DATA.GameActionData.mActionGroupDatas = actionGroupDatas;
	DATA.GameActionData.mActionDatas = actionDatas;
end

function InitModule()
	local argData1 = 
	{
		keys = { mActionGroupDatas = true, mActionDatas = true },
		fileName = "GameActionData.bytes",
		callBack = OnLoadGameActionData,
	}

	DATA.CREATE_LOAD_TRIGGER(DATA.GameActionData,argData1);
end

function GetActionDatas(groupID)
	return DATA.GameActionData.mActionGroupDatas[groupID];
end

function GetActionData(actionID)
	return DATA.GameActionData.mActionDatas[actionID];
end

function GetActionGroupID(actionID)
	local actionData = DATA.GameActionData.mActionDatas[actionID];
	return actionData and actionData.groupID;
end

return GameActionData;
