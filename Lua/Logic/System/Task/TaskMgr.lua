module("TaskMgr", package.seeall);
local mTaskAcceptGroupDatas = {};
local mTaskFinishGroupDatas = {};
local mTaskCanAcceptGroupDatas = {};

--获取目标最大进度值
local function GetMaxProgress(goalStaticData)
	if goalStaticData then
		if goalStaticData.condition.conditionType == Condition_pb.FIGHT_NPC_KILL then
			return goalStaticData.condition.params[3];
		elseif goalStaticData.condition.conditionType == Condition_pb.FIGHT_NPC_GROUP_DEAD then
			return goalStaticData.condition.params[3];
		elseif goalStaticData.condition.conditionType == Condition_pb.MISSION_COUNT then
			return goalStaticData.condition.params[2];
		end
	end
	return 0;
end

local function CreateTaskDynamicData(taskType, taskID, goals, acceptTime, notAccept)
	local staticData = QuestData.GetData(taskID);
	if staticData then
		local taskDynamicData = {};
		taskDynamicData.taskType = taskType;
		taskDynamicData.taskID = taskID;
		taskDynamicData.staticData = staticData;
		taskDynamicData.hasAccept = not notAccept;
		taskDynamicData.acceptTime = acceptTime;
		taskDynamicData.goals = {};
		if not goals then
			goals = {};
			for i = 1, #taskDynamicData.staticData.goals do
				local goal = {};
				goal.goalIndex = i - 1;
				goal.staticData = staticData.goals[i];
				goal.goalProgress = 0;
				goal.maxProgress = GetMaxProgress(goal.staticData);
				goal.extraData = {};
				table.insert(taskDynamicData.goals, goal);
			end
		else
			for i = 1, #goals do
				local goal = {};
				goal.goalIndex = goals[i].goalIndex;
				goal.staticData = staticData.goals[i];
				goal.goalProgress = goals[i].conditionRecord.progress;
				goal.maxProgress = GetMaxProgress(goal.staticData);
				goal.extraData = {};
				goal.extraData.selectQuests = goals[i].selectQuests;
				table.insert(taskDynamicData.goals, goal);
			end
		end
		return taskDynamicData;
	else
		return nil;
	end
end

--判断目标是否结束
function IsGoalFinish(goalDynamicData)
	local maxProgress = goalDynamicData.maxProgress;
	local curProgress = goalDynamicData.goalProgress;
	return(maxProgress == 0 and curProgress >= 1) or(curProgress == maxProgress and maxProgress ~= 0);
end

--判断任务是否结束
function IsTaskFinish(taskDynamicData)
	return IsAllGoalFinish(taskDynamicData) and taskDynamicData.staticData.autoSubmit;
end

--判断是否所有目标全部达成
function IsAllGoalFinish(taskDynamicData)
	for i = 1, #taskDynamicData.goals do
		if not IsGoalFinish(taskDynamicData.goals[i]) then
			return false;
		end
	end
	return true;
end

--过滤已接任务
function GetAcceptedTasksByFilter(filterFunc, ...)
	local tasks = GetAcceptedTasks(- 1);
	local taskID = nil;
	local taskType = nil;
	local taskGoal = nil;
	local taskGoalIndex = nil;
	for _, taskDynamicData in ipairs(tasks) do
		for goalIndex, goal in ipairs(taskDynamicData.staticData.goals) do
			if filterFunc(goal, ...) then
				taskID = taskDynamicData.taskID;
				taskType = taskDynamicData.taskType;
				taskGoal = goal;
				taskGoalIndex = goalIndex;
				break;
			end
		end
		if taskID then break; end
	end
	return taskID, taskType, taskGoal, taskGoalIndex;
end

--获取已领取任务列表
function GetAcceptedTasks(showType)
	local function SetTaskWeight(data)
		--计算权值,用于任务排序
		--副、主、支、引、节、活、帮、战、师、日
		if data.majorType == Quest_pb.QuestInfo.SCENE then
			data.weight = 1;
		elseif data.majorType == Quest_pb.QuestInfo.MAIN then
			data.weight = 2;
		elseif data.majorType == Quest_pb.QuestInfo.BRANCH then
			data.weight = 3;
		end
	end
	
	local function SortAcceptedTask(a, b)
		if a == b then return false end;
		if a.weight ~= b.weight then return a.weight < b.weight end;
		if a.acceptTime ~= b.acceptTime then return a.acceptTime > b.acceptTime end;
		return a.taskID < b.taskID;
	end
	
	local ret = {};
	for _, acceptGroup in pairs(mTaskAcceptGroupDatas) do
		if acceptGroup then
			for taskID, taskDynamicData in pairs(acceptGroup) do
				repeat 
					--数据无效
					if not taskDynamicData then break end
					--不显示该类型
					if showType ~= -1 and taskDynamicData.staticData.showType ~= showType then break end
					--任务已经完成
					if IsTaskFinish(taskDynamicData) then break end
					--副本内只显示副本任务
					local mapData = MapMgr.GetMapInfo();
					if mapData and mapData.spaceType == MapInfo_pb.SpaceConfig.Instance and taskDynamicData.staticData.majorType ~= Quest_pb.QuestInfo.SCENE then break end
					
					--设置当前任务显示权重
					SetTaskWeight(taskDynamicData);
					table.insert(ret, taskDynamicData);

					break;
				until true;
			end
		end
	end
	table.sort(ret, SortAcceptedTask);
	return ret;
end

--获取可接任务列表
function GetCanAcceptedTasks()
	return {};
end

--获取结束任务列表
function GetFinishedTasks(taskType)
	return mTaskFinishGroupDatas[taskType] or {};
end

--获取目标描述
function GetTaskGoalContent(taskDynamicData)
	local goalDesList = string.split(taskDynamicData.staticData.mainDesc, ';');
	local finalDes = {};
	--目标全部达成,返回最后一句主动提交描述
	if IsAllGoalFinish(taskDynamicData) then
		return not taskDynamicData.staticData.autoSubmit and taskDynamicData.staticData.submitDes or "";
	end
	if taskDynamicData.staticData.goalRelation == Quest_pb.QuestInfo.AND then
		--多目标会配置前置描述
		local goalDesOffset = #taskDynamicData.goals > 1 and 1 or 0;
		local hasMultiGoalPrefix = #taskDynamicData.goals > 1 and goalDesList[1] ~= "";
		local multiGoalFormatWithProgress = hasMultiGoalPrefix and "\n%s (%s/%s)" or "%s (%s/%s)";
		local multiGoalFormatNoProgress = hasMultiGoalPrefix and "\n%s (%s/%s)" or "%s (%s/1)";
		if hasMultiGoalPrefix then table.insert(finalDes, goalDesList[1]); end
		for i = 1, #taskDynamicData.goals do
			local maxProgress = taskDynamicData.goals[i].maxProgress;
			local curProgress = taskDynamicData.goals[i].goalProgress;
			local goalFinish = IsGoalFinish(taskDynamicData.goals[i]);
			--显示多目标或者当前目标未结束,则加入该目标的描述
			if not goalFinish or taskDynamicData.staticData.showMultiGoal then
				if maxProgress > 0 then
					table.insert(finalDes, string.format(multiGoalFormatWithProgress, goalDesList[i + goalDesOffset], curProgress, maxProgress));
				else
					table.insert(finalDes, string.format(multiGoalFormatNoProgress, goalDesList[i + goalDesOffset], goalFinish and 1 or 0));
				end
			end
			--不显示多目标并且当前目标已结束,则退出
			if not taskDynamicData.staticData.showMultiGoal and not goalFinish then break; end
		end
		return table.concat(finalDes);
	elseif #taskDynamicData.goals >= 1 then
		local maxProgress = taskDynamicData.goals[1].maxProgress;
		local curProgress = taskDynamicData.goals[1].goalProgress;
		if maxProgress > 0 then
			return string.format("%s (%s/%s)", goalDesList[1], curProgress, maxProgress);
		else
			return string.format("%s (0/1)", goalDesList[1]);
		end
	else
		return "task goal is null";
	end
end

--获取指定目标描述
function GetTaskGoalContentWithIdx(taskDyamicData, goalIndex)
	if goalIndex <= #taskDyamicData.goals and #taskDyamicData.goals > 0 then
		local goalDesList = string.split(taskDyamicData.staticData.mainDesc, ';');
		if taskDyamicData.staticData.goalRelation == Quest_pb.QuestInfo.AND then
			--与目标检查是否同时显示,多个目标时第一句描述一定存在
			local maxProgress = taskDyamicData.goals[goalIndex].maxProgress;
			local curProgress = taskDyamicData.goals[goalIndex].goalProgress;		
			local goalOffset = #taskDyamicData.goals > 1 and 1 or 0;
			if not IsGoalFinish(taskDyamicData.goals[goalIndex]) or taskDyamicData.staticData.showMultiGoal then
				if maxProgress ~= 0 then
					return string.format("%s (%s/%s)", goalDesList[goalIndex + goalOffset], curProgress, maxProgress);
				else
					return string.format("%s (%s/1)", goalDesList[goalIndex + goalOffset], curProgress);
				end
			else
				return "";
			end
		else
			--或目标三个目标是一样的,只返回第一句描述
			if goalIndex == 1 then
				local maxProgress = taskDyamicData.goals[1].maxProgress;
				local curProgress = taskDyamicData.goals[1].goalProgress;			
				if maxProgress > 0 then
					return string.format("%s (%s/%s)", goalDesList[1], curProgress, maxProgress);
				else
					return string.format("%s (0/1)", goalDesList[1])
				end
			else
				return "";
			end
		end
	end
end

--获取指定任务
function GetTaskDynamicData(taskType, taskID)
	local acceptGroup = mTaskAcceptGroupDatas[taskType];
	return acceptGroup and acceptGroup[taskID] or nil;
end

--完成指定目标
function RequestGotoFinishGoal(taskDyamicData)
	GameEvent.Trigger(EVT.TASK, EVT.TASK_GOTO_FINISH, taskDyamicData.taskType, taskDyamicData.taskID);
end

--前往领取指定任务
function RequestGotoAcceptTask(taskDyamicData)
	GameEvent.Trigger(EVT.TASK, EVT.TASK_GOTO_ACCEPT, taskDyamicData.taskType, taskDyamicData.taskID);
end

--领取指定任务
function RequestTaskAccept(taskType, taskID)
	local msg = NetCS_pb.CSAcceptQuest();
	msg.sysType = taskType;
	msg.questID = taskID;
	GameNet.SendToGate(msg);
end

--领取随机任务
function RequestTaskSelect(taskType, taskID, goalIndex, selectIndex)
	local taskDynamicData = GetTaskDynamicData(taskType, taskID);
	local msg = NetCS_pb.CSSelectQuest();
	msg.sysType = taskType;
	msg.questID = taskID;
	msg.goalIndex = goalIndex - 1;
	msg.selectQuestID = taskDynamicData.goals[goalIndex].extraData.selectQuests[selectIndex];
	GameNet.SendToGate(msg);
end

--放弃指定任务
function RequestTaskGiveUp(taskType, taskID)
	
end

--提交指定任务
function RequestTaskSubmit(taskType, taskID)
	
end

--任务对话结束
function RequestTaskTalkOver(dialogGroupID, dialogDescID)
	local msg = NetCS_pb.CSTalkOver();
	msg.dialogID = dialogGroupID;
	msg.selectID = dialogDescID;
	GameNet.SendToGate(msg);
end

--任务剧情结束
function RequestTaskStoryOver(storyID)
	local msg = NetCS_pb.CSStoryOver();
	msg.storyID = storyID;
	GameNet.SendToGate(msg);
end

--提交指定道具
function RequestSubmitItem(itemStaticID, itemCount)
	local msg = NetCS_pb.CSSubmitItem();
	msg.itemID = itemStaticID;
	msg.itemCount = itemCount;
	GameNet.SendToGate(msg);
end

--进入指定区域
function RequestEnterArea(mapID, areaID, entityType, entityID)
	local msg = NetCS_pb.CSEnterArea();
	GameNet.SendToGate(msg);
end

--打开手相占卜界面
function RequestOpenDivineUI()
	local msg = NetCS_pb.CSDivine();
	GameNet.SendToGate(msg);
end

--更换初始套装
function RequestChangeSuit(physiqueID, suitId)
	local msg = NetCS_pb.CSSuitChange();
	msg.physique = tonumber(physiqueID);
	msg.suitId = tonumber(suitId);
	GameNet.SendToGate(msg);
end

--二选一任务
function RequestSelectGoal(taskType, taskID, selectIndex)
	local msg = NetCS_pb.CSSelectGoal();
	msg.questID = taskID;
	msg.sysType = taskType;
	msg.goalIndex = selectIndex;
	GameNet.SendToGate(msg);
end

--任务列表
local function OnTaskList(msg)
	if msg.questSysRecord then
		mTaskAcceptGroupDatas = mTaskAcceptGroupDatas or {};
		mTaskFinishGroupDatas = mTaskFinishGroupDatas or {};
		local acceptGroup = {};
		local finishGroup = {};
		for _, questListRecord in ipairs(msg.questSysRecord.questLists) do
			--已领取任务列表
			for __, questRecord in ipairs(questListRecord.runQuests) do
				local taskDynamicData = CreateTaskDynamicData(msg.questSysRecord.sysType, questRecord.questID, questRecord.goals, questRecord.acceptTime, false);
				if taskDynamicData then
					acceptGroup[questRecord.questID] = taskDynamicData;
				end
			end
			--已完成任务列表
			for __, finishQuestID in ipairs(questListRecord.finishQuests) do
				local taskStaticData = QuestData.GetData(finishQuestID);
				if taskStaticData then
					finishGroup[finishQuestID] = taskStaticData;
				end
			end
		end
		mTaskFinishGroupDatas[msg.questSysRecord.sysType] = finishGroup;
		mTaskAcceptGroupDatas[msg.questSysRecord.sysType] = acceptGroup;
		GameEvent.Trigger(EVT.TASK, EVT.TASK_LIST);
	end
end

--领取任务
local function OnTaskAccept(msg)
	--构造任务信息
	local taskDynamicData = CreateTaskDynamicData(msg.sysType, msg.questID, msg.goalInfos, msg.acceptTime, false);
	if taskDynamicData then
		--任务组
		local acceptGroup = mTaskAcceptGroupDatas[msg.sysType] or {};
		mTaskAcceptGroupDatas[msg.sysType] = acceptGroup;
		
		acceptGroup[msg.questID] = taskDynamicData;
		GameEvent.Trigger(EVT.TASK, EVT.TASK_ACCEPT, msg.sysType, msg.questID);
	end
end

--任务刷新
local function OnTaskGoalUpdate(msg)
	local acceptGroup = mTaskAcceptGroupDatas[msg.sysType];
	if acceptGroup then
		local taskDynamicData = acceptGroup[msg.questID];
		if taskDynamicData then
			for i = 1, #taskDynamicData.goals do
				local goal = taskDynamicData.goals[i];
				if goal.goalIndex == msg.goalRecord.goalIndex then
					goal.goalProgress = msg.goalRecord.conditionRecord.progress;
					break;
				end
			end
		end
		GameEvent.Trigger(EVT.TASK, EVT.TASK_UPDATE, msg.sysType, msg.questID);
	end
end

--任务取消
local function OnTaskGiveUp(msg)
	local acceptGroup = mTaskAcceptGroupDatas[msg.sysType];
	if acceptGroup then
		acceptGroup[msg.questID] = nil;
		GameEvent.Trigger(EVT.TASK, EVT.TASK_CANCEL, msg.sysType, msg.questID);
	end
end

--任务结束
local function OnTaskFinish(msg)
	local acceptGroup = mTaskAcceptGroupDatas[msg.sysType];
	local finishGroup = mTaskFinishGroupDatas[msg.sysType] or {};
	finishGroup[msg.questID] = QuestData.GetData(msg.questID);
	mTaskFinishGroupDatas[msg.sysType] = finishGroup;
	if acceptGroup then
		local task = acceptGroup[msg.questID];
		acceptGroup[msg.questID] = nil;
		GameEvent.Trigger(EVT.TASK, EVT.TASK_FINISH, msg.sysType, msg.questID);
		if task and task.staticData.showTaskFinish then TipsMgr.TipByKey("task_finish"); end
	end
end

--任务清理
local function OnTaskClear(msg)
	local acceptGroup = mTaskAcceptGroupDatas[msg.sysType];
	if acceptGroup then
		for questID,taskDynamicData in pairs(acceptGroup) do
			if taskDynamicData and taskDynamicData.staticData.questType == msg.questType then
				acceptGroup[questID] = nil;
				GameEvent.Trigger(EVT.TASK, EVT.TASK_CANCEL, msg.sysType, questID);
			end
		end
	end
end

--初始化
function InitModule()
	--任务目标自动执行
	require("Logic/System/Task/TaskGoalFactory").InitModule();
	require("Logic/System/Task/TaskAuto").InitModule();
	--任务
	GameNet.Reg(NetCS_pb.SCAcceptQuest, OnTaskAccept);           --领取任务
	GameNet.Reg(NetCS_pb.SCSyncGoalRecord, OnTaskGoalUpdate);    --目标进度变化
	GameNet.Reg(NetCS_pb.SCQuestFinish, OnTaskFinish);           --任务完成
	GameNet.Reg(NetCS_pb.SCSyncQuestSystem, OnTaskList);         --同步任务数据
	GameNet.Reg(NetCS_pb.SCGiveUpQuest, OnTaskGiveUp);           --任务放弃
	GameNet.Reg(NetCS_pb.SCClearQuests, OnTaskClear);            --任务清理
end

return TaskMgr; 