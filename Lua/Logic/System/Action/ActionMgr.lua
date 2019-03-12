module("ActionMgr",package.seeall);

local mActionGroups = {};
local mActionRemotes = {};

local UUID = 0;

local function AddGroup(actionGroup)
	--功能组之间没有关系
	UUID = UUID + 1;
	mActionGroups[UUID] = actionGroup;
end

local function RemoveGroup(idx)
	--回收重复利用
	local actionGroup = mActionGroups[idx];
	mActionGroups[idx] = nil;
	ActionFactory.DestroyGroup(actionGroup);
	--通知服务器功能组执行结束
	if actionGroup and actionGroup._dynamicID then
		local msg = NetCS_pb.CSExecuteGameActionOver();
		msg.actionTempId = actionGroup._groupID;
		msg.actionId = actionGroup._dynamicID;
		msg.roleId = actionGroup._entityID;
		msg.isGroup = true;
		GameNet.SendToGate(msg);
	end
end

local function AddAction(actionRemote)
	--服务器功能全部并行
	UUID = UUID + 1;
	mActionRemotes[UUID] = actionRemote;
end

local function RemoveAction(idx)
	--回收重复利用
	local action = mActionRemotes[idx];
	mActionRemotes[idx] = nil;
	ActionFactory.DestroyAction(action);
	--通知服务器功能执行结束
	if action and action._dynamicID then
		local msg = NetCS_pb.CSExecuteGameActionOver();
		msg.actionTempId = action._actionData.id;
		msg.actionId = action._dynamicID;
		msg.roleId = action._entityID;
		msg.isGroup = false;
		GameNet.SendToGate(msg);
	end
end

local function UpdateAction()
	local deltaTime = GameTime.deltaTime_L;
	for idx,actionGroup in pairs(mActionGroups) do
		actionGroup:OnUpdate(deltaTime);
		if actionGroup:IsFinish() then
			RemoveGroup(idx);
		end
	end
	for idx,actionRemote in pairs(mActionRemotes) do
		actionRemote:OnUpdate(deltaTime);
		if actionRemote:IsFinish() then
			RemoveAction(idx);
		end
	end
end

--服务器通知执行功能
local function OnRemoteAction(msg)
	if msg.isGroup then
		ExecuteActionGroup(msg.actionTempId,true,msg.actionId,tonumber(msg.roleId));
	else
		local actionData = GameActionData.GetActionData(msg.actionTempId);
		if actionData then
			local actionRemote = ActionFactory.CreateAction(actionData,msg.actionId,tonumber(msg.roleId));
			if actionRemote then
				AddAction(actionRemote);
			else
				GameLog.LogError("client action undefine %s",actionData.actionType);
			end
		else
			GameLog.LogError("action data is null %s",msg.actionTempId);
		end
	end
end


--[[
执行一个功能组
groupID 	int32		功能组ID
serial		bool		是否串行执行
--]]
function ExecuteActionGroup(groupID,serial,dynamicID,playerID)
	local actionDatas = GameActionData.GetActionDatas(groupID);
	if actionDatas then
		AddGroup(ActionFactory.CreateGroup(actionDatas,serial,groupID,dynamicID,playerID));
	else
		GameLog.LogError("action group data is null %s",groupID);
	end
end

function InitModule()
	require("Logic/System/Action/ActionFactory").InitModule();
	GameNet.Reg(NetCS_pb.SCExecuteGameAction,OnRemoteAction);
	UpdateBeat:Add(UpdateAction);
end

return ActionMgr;