TASK_GOAL_OPENUI = class("TASK_GOAL_OPENUI", TASK_GOAL_BASE);

function TASK_GOAL_OPENUI:ctor(...)
	TASK_GOAL_BASE.ctor(self, ...);
	local conditionType = self._goalDynamicData.staticData.condition.conditionType;
	if conditionType == Condition_pb.MISSION_DIVINE then
		self._uiData = AllUI.UI_Divine_Shoot;
	elseif conditionType == Condition_pb.SELECT_GOAL then
		self._uiData = AllUI.UI_Equip_Selection;
	else
		self._uiData = nil;
	end
end

function TASK_GOAL_OPENUI:OnStart()
	TASK_GOAL_BASE.OnStart(self);
	if self._uiData == AllUI.UI_Equip_Selection then
		local taskId = self._goalConditionParams[1];
		local taskType = self._goalConditionParams[2];
		local selectType = self._goalConditionParams[3];
		local firstShowId = self._goalConditionParams[4];
		local secondShowId = self._goalConditionParams[5];
		UIMgr.ShowUI(self._uiData, self, nil, nil, nil, true, taskId, taskType, selectType, firstShowId, secondShowId);
	else
		UIMgr.ShowUI(self._uiData);
	end
end

function TASK_GOAL_OPENUI:IsFinish()
	return self._uiData and self._uiData.enable;
end

function TASK_GOAL_OPENUI:IsExecuting()
	return self._uiData and self._uiData.enable;
end 