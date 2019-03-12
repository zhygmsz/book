MainUITask = class("MainUITask");

function MainUITask:ctor(uiFrame)
	self._taskChangeLevel = 2;
	self._TASK_EVT_BASE = 350;
	self._DEFAULT_HEIGHT = 77;
	self._autoTaskType = - 1;
	self._autoTaskID = - 1;
	
	self._taskDatas = {};
	self._taskItems = {};
	
	self._uiFrame = uiFrame;
	self._tweenObj = uiFrame:Find("TopLeft/TaskInfo/TweenObj").gameObject;
	self._taskPrefab = uiFrame:Find("TopLeft/TaskInfo/TweenObj/Task/DragParent/ScrollView/Wrap/TaskItem").transform;
	self._taskTable = uiFrame:FindComponent("UITable", "TopLeft/TaskInfo/TweenObj/Task/DragParent/ScrollView/Wrap");
	self._taskPanel = uiFrame:FindComponent("UIPanel", "TopLeft/TaskInfo/TweenObj/Task/DragParent/ScrollView");
	self._mainToggle = uiFrame:FindComponent("UIToggle", "TopLeft/TaskInfo/TweenObj/Task/Toggle/Main");
	self._branchToggle = uiFrame:FindComponent("UIToggle", "TopLeft/TaskInfo/TweenObj/Task/Toggle/Branch");
	self._otherToggle = uiFrame:FindComponent("UIToggle", "TopLeft/TaskInfo/TweenObj/Task/Toggle/Other");
	self._taskToggle = uiFrame:FindComponent("UIToggle", "TopLeft/TaskInfo/Toggle/Task");
	self._teamToggle = uiFrame:FindComponent("UIToggle", "TopLeft/TaskInfo/Toggle/Team");

	local taskTypeCallBack = EventDelegate.Callback(self.OnToggleTaskType,self);
	EventDelegate.Add(self._mainToggle.onChange, taskTypeCallBack);
	EventDelegate.Add(self._branchToggle.onChange, taskTypeCallBack);
	EventDelegate.Add(self._otherToggle.onChange, taskTypeCallBack);

	local teamOrTaskCallBack = EventDelegate.Callback(self.OnToggleTeamOrTask,self);
	EventDelegate.Add(self._taskToggle.onChange, teamOrTaskCallBack);
	EventDelegate.Add(self._teamToggle.onChange, teamOrTaskCallBack);
	
	self._taskPrefab.gameObject:SetActive(false);
	
	GameEvent.Reg(EVT.TASK, EVT.TASK_LIST, self.OnTaskList, self);
	GameEvent.Reg(EVT.TASK, EVT.TASK_ACCEPT, self.OnTaskAccept, self);
	GameEvent.Reg(EVT.TASK, EVT.TASK_UPDATE, self.OnTaskUpdate, self);
	GameEvent.Reg(EVT.TASK, EVT.TASK_CANCEL, self.OnTaskCancel, self);
	GameEvent.Reg(EVT.TASK, EVT.TASK_FINISH, self.OnTaskFinish, self);
	GameEvent.Reg(EVT.TASK, EVT.TASK_AI_START, self.OnAIStart, self);
	GameEvent.Reg(EVT.TASK, EVT.TASK_AI_STOP, self.OnAIStop, self);
end

function MainUITask:OnEnable()
	self._active = true;
	self:OnToggleTeamOrTask();
end

function MainUITask:OnDisable()
	self._active = false;
end

function MainUITask:OnDestroy()
	
end

function MainUITask:OnClick(id)
    if id == 0 then
        --弹出弹回
    elseif id == 301 then
        --跟随
    elseif id == 302 then
        --取消跟随
    elseif id == 303 then
        --任务主界面
        UIMgr.ShowUI(AllUI.UI_Task_Main);
    elseif id == 304 then
        --队伍主界面

    elseif id >= self._TASK_EVT_BASE and id < 400 then
        --任务、队友
        if self._taskToggle.value then
            local idx = id - self._TASK_EVT_BASE;
            local item = self._taskItems[idx];
            if item then
                TaskMgr.RequestGotoFinishGoal(item.dynamicData);
            end
        elseif self._teamToggle.value then

        end
    end
end

function MainUITask:InitTask(uiFrame)
	--检查当前选择的是哪种类型
	local showType = nil;
	if self._mainToggle.value then
		showType = Quest_pb.QuestInfo.SHOW_MAIN;
	elseif self._branchToggle.value then
		showType = Quest_pb.QuestInfo.SHOW_BRANCH;
	elseif self._otherToggle.value then
		showType = Quest_pb.QuestInfo.SHOW_OTHER;
	else
		return
	end
	
	if self._taskChangeLevel == 2 then
		--任务有增减,需要刷新整个列表
		self._taskDatas = TaskMgr.GetAcceptedTasks(showType);
		--创建足够的ITEM
		for i = #self._taskItems + 1, #self._taskDatas do
			local obj = uiFrame:DuplicateAndAdd(self._taskPrefab.transform, self._taskTable.transform, i).gameObject;
			local item = {};
			obj.name = tostring(i+10000);
			item.gameObject = obj;
			item.transform = obj.transform;
			item.widget = obj:GetComponent("UIWidget");
			item.bg = obj.transform:Find("Bg"):GetComponent("UISprite");
			item.icon = obj.transform:Find("icon"):GetComponent("UISprite");
			item.title = obj.transform:Find("Title"):GetComponent("UILabel");
			item.content = obj.transform:Find("Text"):GetComponent("UILabel");
			item.select = obj.transform:Find("Select").gameObject;
			item.selectWidget = item.select:GetComponent("UISprite");
			item.finishFlag = obj.transform:Find("Get").gameObject;
			item.finishFlag:SetActive(false);
			item.select:SetActive(false);
			obj:GetComponent("GameCore.UIEvent").id = self._TASK_EVT_BASE + i;
			self._taskItems[i] = item;
		end		
		--初始化ITEM
		for i = 1, #self._taskItems do
			local data = self._taskDatas[i];
			local item = self._taskItems[i];
			item.gameObject:SetActive(data and true or false);
			if data then
				item.dynamicData = data;
				item.title.text = data.staticData.mainTitle;
				item.icon.spriteName = data.staticData.typeIcon;
				item.content.text = TaskMgr.GetTaskGoalContent(data);
				item.content:ProcessText();
				item.content:Update();
				item.bg.height = self._DEFAULT_HEIGHT + item.content.height - 18;
				item.widget.height = item.bg.height;
				item.selectWidget.height = item.bg.height;
				item.select:SetActive(data.taskType == self._autoTaskType and data.taskID == self._autoTaskID);
			end
		end		
		--重置位置
		self._taskTable:Reposition();
		self._taskPanel.clipOffset = Vector2.zero;
		self._taskPanel.transform.localPosition = Vector3.zero;
		--任务进度变化
	elseif self._taskChangeLevel == 1 then
		--某个任务的目标进度发生变化
		local changedList = self._taskDatas.ChangedList;
		local heightChanged = false;
		for i = 1, #changedList do
			local data = changedList[i];
			for j = 1, #self._taskItems do
				local item = self._taskItems[j];
				if data == item.dynamicData then
					item.content.text = TaskMgr.GetTaskGoalContent(data);
					item.content:ProcessText();
					item.content:Update();
					local oldHeight = item.bg.height;
					item.bg.height = self._DEFAULT_HEIGHT + item.content.height - 18;
					item.widget.height = item.bg.height;
					item.selectWidget.height = item.bg.height;
					if oldHeight ~= item.bg.height then heightChanged = true; end
					item.select:SetActive(data.taskType == self._autoTaskType and data.taskID == self._autoTaskID);
				end
			end			
		end
		if heightChanged then self._taskTable:Reposition(); end
		self._taskDatas.ChangedList = {};
	elseif self._taskChangeLevel == 0 then
		if self._taskDatas.showType ~= showType then
			self._taskChangeLevel = 2;
			self:InitTask(uiFrame);
		end
	end
	self._taskChangeLevel = 0;
end

function MainUITask:InitTeam(uiFrame)
	
end

function MainUITask:OnToggleTeamOrTask()
	if self._taskToggle.value then
		self:InitTask(self._uiFrame);
	elseif self._teamToggle.value then
		self:InitTeam(self._uiFrame);
	end
end

function MainUITask:OnToggleTaskType()
	self:InitTask(self._uiFrame);
end

function MainUITask:OnTaskList()
	self._taskChangeLevel = 2;
	if self._active then
		self:InitTask(self._uiFrame);
	end
end

function MainUITask:OnTaskAccept(taskType, taskID)
	self._taskChangeLevel = 2;
	if self._active then
		self:InitTask(self._uiFrame);
	end
end

function MainUITask:OnTaskUpdate(taskType, taskID)
	local dynamicData = TaskMgr.GetTaskDynamicData(taskType, taskID);
	if dynamicData then
		if TaskMgr.IsTaskFinish(dynamicData) then
			self._taskChangeLevel = 2;
			if self._active then
				self:InitTask(self._uiFrame);
			end
		else
			self._taskChangeLevel = 1;
			if not self._taskDatas.ChangedList then
				self._taskDatas.ChangedList = {};
			end
			table.insert(self._taskDatas.ChangedList, TaskMgr.GetTaskDynamicData(taskType, taskID));
			if self._active then
				self:InitTask(self._uiFrame);
			end
		end
	end
end

function MainUITask:OnTaskCancel(taskType, taskID)
	self._taskChangeLevel = 2;
	if self._active then
		self:InitTask(self._uiFrame);
	end
end

function MainUITask:OnTaskFinish(taskType, taskID)
	self._taskChangeLevel = 2;
	if self._active then
		self:InitTask(self._uiFrame);
	end
end

function MainUITask:OnAIStart(taskType, taskID)
	for j = 1, #self._taskItems do
		local data = self._taskItems[j].dynamicData;
		if data and data.taskType == taskType and data.taskID == taskID then
			self._taskItems[j].select:SetActive(true);
		else
			if data and data.taskType == self._autoTaskType and data.taskID == self._autoTaskID then
				self._taskItems[j].select:SetActive(false);
			end
		end
	end
	self._autoTaskType = taskType;
	self._autoTaskID = taskID;
end

function MainUITask:OnAIStop()
	for j = 1, #self._taskItems do
		local data = self._taskItems[j].dynamicData;
		if data and data.taskType == self._autoTaskType and data.taskID == self._autoTaskID then
			self._taskItems[j].select:SetActive(false);
		end
	end
	self._autoTaskType = - 1;
	self._autoTaskID = - 1;
end

return MainUITask; 