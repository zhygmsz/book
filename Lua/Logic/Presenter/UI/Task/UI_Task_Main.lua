module("UI_Task_Main",package.seeall);
local mSelf;

--有无数据ROOT结点
local mNoDataObj;
local mHasDataObj;
local mSubmitObj;
local mGiveupObj;
local mContentObj;

--左侧任务列表
local mTaskPanel;
local mTaskTable;
local mTaskPrefab;
local mTaskItems = {};

--内容区标题
local mContentTitleAObj;
local mContentTitleBObj;
local mContentTitleCObj;
local mContentTitleDes;
--内容区目标进度和目标描述
local mGoal1;
local mGoal2;
local mGoal3;
local mGoalDes;
--右侧分页标签
local mHasAcceptToggle;
local mCanAcceptToggle;
--简写
local SHOW_MAIN = Quest_pb.QuestInfo.SHOW_MAIN;
local SHOW_BRANCH = Quest_pb.QuestInfo.SHOW_BRANCH;
local SHOW_OTHER = Quest_pb.QuestInfo.SHOW_OTHER;
local SHOW_MAIN_STR = "";
local SHOW_BRANCH_STR = "";
local SHOW_OTHER_STR = "";

local GOAL_HEIGHT_OFF = 40; 
local BASE_EVENT_ID = 1000;

--定义
local TOGGLE_TYPE = 
{
    HAS_ACCEPT = 1;
    CAN_ACCEPT = 2;
}
local mSelectData = 
{
    selectType = TOGGLE_TYPE.HAS_ACCEPT;
    taskType = {};
    taskID = {};
}
local mTaskDatas = 
{
    [TOGGLE_TYPE.HAS_ACCEPT] = { open = {}, data = {} },
    [TOGGLE_TYPE.CAN_ACCEPT] = { open = {}, data = {} },
}

function OnCreate(self)
    mSelf = self;

    mNoDataObj = self:Find("Offset/NoTask").gameObject;
    mHasDataObj = self:Find("Offset/HasTask").gameObject;
    mSubmitObj = self:Find("Offset/HasTask/SubmitBtn").gameObject;
    mGiveupObj = self:Find("Offset/HasTask/GiveupBtn").gameObject;
    mContentObj = self:Find("Offset/HasTask/Content").gameObject;

    mTaskPanel = self:FindComponent("UIPanel","Offset/HasTask/DragParent/ScrollView");
    mTaskTable = self:FindComponent("UITable","Offset/HasTask/DragParent/ScrollView/Table");
    mTaskPrefab = self:Find("Offset/HasTask/DragParent/ScrollView/Table/Prefab").gameObject;
    mTaskPrefab:SetActive(false);
    mTaskItems = {}

    mContentTitleAObj = self:Find("Offset/HasTask/Content/Title/TitleA").gameObject;
    mContentTitleBObj = self:Find("Offset/HasTask/Content/Title/TitleB").gameObject;
    mContentTitleCObj = self:Find("Offset/HasTask/Content/Title/TitleC").gameObject;
    mContentTitleDes = self:FindComponent("UILabel","Offset/HasTask/Content/Title/Des");
    SHOW_MAIN_STR = self:FindComponent("UILabel","Offset/HasTask/Content/Title/TitleA").text;
    SHOW_BRANCH_STR = self:FindComponent("UILabel","Offset/HasTask/Content/Title/TitleB").text;
    SHOW_OTHER_STR = self:FindComponent("UILabel","Offset/HasTask/Content/Title/TitleC").text;

    mGoal1 = self:FindComponent("UILabel","Offset/HasTask/Content/Target/Goal1/Title");
    mGoal2 = self:FindComponent("UILabel","Offset/HasTask/Content/Target/Goal2/Title");
    mGoal3 = self:FindComponent("UILabel","Offset/HasTask/Content/Target/Goal3/Title");
    mGoalDes = self:FindComponent("UILabel","Offset/HasTask/Content/Target/Des");

    mHasAcceptToggle = self:FindComponent("UIToggle","Offset/Common/HasAccept");
    mCanAcceptToggle = self:FindComponent("UIToggle","Offset/Common/CanAccept");
end

function RegEvent(self)
    GameEvent.Reg(EVT.TASK,EVT.TASK_LIST,OnTaskList);
    GameEvent.Reg(EVT.TASK,EVT.TASK_ACCEPT,OnTaskAccept);
    GameEvent.Reg(EVT.TASK,EVT.TASK_UPDATE,OnTaskUpdate);
    GameEvent.Reg(EVT.TASK,EVT.TASK_CANCEL,OnTaskCancel);
    GameEvent.Reg(EVT.TASK,EVT.TASK_FINISH,OnTaskFinish);
end

function UnRegEvent()
    GameEvent.UnReg(EVT.TASK,EVT.TASK_LIST,OnTaskList);
    GameEvent.UnReg(EVT.TASK,EVT.TASK_ACCEPT,OnTaskAccept);
    GameEvent.UnReg(EVT.TASK,EVT.TASK_UPDATE,OnTaskUpdate);
    GameEvent.UnReg(EVT.TASK,EVT.TASK_CANCEL,OnTaskCancel);
    GameEvent.UnReg(EVT.TASK,EVT.TASK_FINISH,OnTaskFinish);
end

function InitHasAcceptData()
    local hasAcceptDatas = TaskMgr.GetAcceptedTasks(-1);
    mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].data = {};
    if #mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].open <= 0 then
        mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].open[SHOW_MAIN] = true;
        mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].open[SHOW_BRANCH] = false;
        mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].open[SHOW_OTHER] = false;
    end
    mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].data[SHOW_MAIN] = {};
    mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].data[SHOW_BRANCH] = {};
    mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].data[SHOW_OTHER] = {};
    for _,data in ipairs(hasAcceptDatas) do
        if data.staticData.showType == SHOW_MAIN then
            table.insert(mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].data[SHOW_MAIN],data);
        elseif data.staticData.showType == SHOW_BRANCH then
            table.insert(mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].data[SHOW_BRANCH],data);
        elseif data.staticData.showType == SHOW_OTHER then
            table.insert(mTaskDatas[TOGGLE_TYPE.HAS_ACCEPT].data[SHOW_OTHER],data);
        end
    end
end

function InitCanAcceptData()
    local canAcceptDatas = TaskMgr.GetCanAcceptedTasks();
    mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].data = {};
    if #mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].open <= 0 then
        mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].open[SHOW_MAIN] = true;
        mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].open[SHOW_BRANCH] = false;
        mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].open[SHOW_OTHER] = false;
    end
    mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].data[SHOW_MAIN] = {};
    mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].data[SHOW_BRANCH] = {};
    mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].data[SHOW_OTHER] = {};
    for _,data in ipairs(canAcceptDatas) do
        if data.staticData.showType == SHOW_MAIN then
            table.insert(mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].data[SHOW_MAIN],data);
        elseif data.staticData.showType == SHOW_BRANCH then
            table.insert(mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].data[SHOW_BRANCH],data);
        elseif data.staticData.showType == SHOW_OTHER then
            table.insert(mTaskDatas[TOGGLE_TYPE.CAN_ACCEPT].data[SHOW_OTHER],data);
        end 
    end
end

function InitSelectData()
    local toProcess = mTaskDatas[mSelectData.selectType];
    local selectType = mSelectData.taskType[mSelectData.selectType] or -1;
    local selectID = mSelectData.taskID[mSelectData.selectType] or -1;
    if selectType ~= -1 then
        --检查当前打开的页签是否是有效数据,不是则修改为当前打开页签的数据
        local isValidData = false;
        for showType,datas in ipairs(toProcess.data) do
            for dataIndex,data in ipairs(datas) do
                if data.taskType == selectType and data.taskID == selectID then
                    isValidData = true;
                    break;
                end    
            end
        end  
        selectType = isValidData and selectType or -1;
        selectID = isValidData and selectID or -1;
    end
    if selectType == -1 then
        --在当前打开的页签内找一个可选中数据
        for showType,datas in ipairs(toProcess.data) do
            if #datas > 0 and toProcess.open[showType] then
                selectType = datas[1].taskType;
                selectID = datas[1].taskID;
                break;
            end
        end   
    end
    mSelectData.taskType[mSelectData.selectType] = selectType;
    mSelectData.taskID[mSelectData.selectType] = selectID;   
end

function InitData()
    --已接任务
    InitHasAcceptData();
    --可接任务
    InitCanAcceptData();
    --找出一个选中
    InitSelectData();
end

function InitSelectItem()
    local hasSelect = mSelectData.taskType[mSelectData.selectType] ~= -1;
    mContentObj:SetActive(hasSelect);
    if hasSelect then
        local taskData = TaskMgr.GetTaskDynamicData(mSelectData.taskType[mSelectData.selectType],mSelectData.taskID[mSelectData.selectType]);
        mGiveupObj:SetActive(taskData.staticData.canAbandon);
        mContentTitleAObj:SetActive(taskData.staticData.showType == SHOW_MAIN);
        mContentTitleBObj:SetActive(taskData.staticData.showType == SHOW_BRANCH);
        mContentTitleCObj:SetActive(taskData.staticData.showType == SHOW_OTHER);
        mContentTitleDes.text = taskData.staticData.title;

        mGoal1.text = TaskMgr.GetTaskGoalContentWithIdx(taskData,1);
        mGoal2.text = TaskMgr.GetTaskGoalContentWithIdx(taskData,2);
        mGoal3.text = TaskMgr.GetTaskGoalContentWithIdx(taskData,3);
        mGoalDes.text = taskData.staticData.desc;
        local trans1 = mGoal1.transform.parent;
        local trans2 = mGoal2.transform.parent;
        local trans3 = mGoal3.transform.parent;
        local transD = mGoalDes.transform;
        trans2.gameObject:SetActive(false);
        trans3.gameObject:SetActive(false);
        transD.localPosition = Vector3.New(transD.localPosition.x,trans1.localPosition.y - GOAL_HEIGHT_OFF,0);
        if taskData.staticData.showMultiGoal then
            if #taskData.staticData.goals > 1 and mGoal2.text ~= "" then
                trans2.gameObject:SetActive(true);
                transD.localPosition = Vector3.New(transD.localPosition.x,trans2.localPosition.y - GOAL_HEIGHT_OFF,0);
            end
            if #taskData.staticData.goals > 2 and mGoal3.text ~= "" then
                trans3.gameObject:SetActive(true);
                transD.localPosition = Vector3.New(transD.localPosition.x,trans3.localPosition.y - GOAL_HEIGHT_OFF,0);
            end
        end
    end
end

function InitItem(showType,showData,showOpen,selectTaskType,selectTaskID)
    local item = mTaskItems[mTaskItems.nextIndex];
    if not item then
        local obj = mSelf:DuplicateAndAdd(mTaskPrefab.transform,mTaskTable.transform,mTaskItems.nextIndex).gameObject;
        obj.name = tostring(mTaskItems.nextIndex);
        item = {};
        item.gameObject = obj;
        item.transform = obj.transform;
        item.p_root = item.transform:Find("Parent").gameObject;
        item.p_bg = item.transform:Find("Parent/Bg"):GetComponent("UISprite");
        item.p_content = item.transform:Find("Parent/Content"):GetComponent("UILabel");
        item.p_dirOpen = item.transform:Find("Parent/Active").gameObject;
        item.p_dirClose = item.transform:Find("Parent/DeActive").gameObject;
        
        item.c_root = item.transform:Find("Child").gameObject;
        item.c_bg = item.transform:Find("Child/Bg"):GetComponent("UISprite");
        item.c_content = item.transform:Find("Child/Content"):GetComponent("UILabel");

        item.event = item.gameObject:GetComponent("GameCore.UIEvent");
        item.event.id = BASE_EVENT_ID + mTaskItems.nextIndex;
        mTaskItems[mTaskItems.nextIndex] = item;
    end
    mTaskItems.nextIndex = mTaskItems.nextIndex + 1;
    item.gameObject:SetActive(true);
    item.p_root:SetActive(showData == nil);
    item.c_root:SetActive(showData ~= nil);
    item.showData = showData;
    item.showType = showType;
    if showData then
        item.c_bg.spriteName = selectTaskType == showData.taskType and selectTaskID == showData.taskID and "button_common_13" or "button_common_12";
        item.c_content.color = selectTaskType == showData.taskType and selectTaskID == showData.taskID and Color.New(0.61, 0.40, 0.25) or Color.New(0.66, 0.53, 0.42);
        item.c_content.text = showData.staticData.title;
    else
        item.p_bg.spriteName = showOpen and "button_common_11" or "button_common_10";
        item.p_content.color = showOpen and Color.New(0.61, 0.40, 0.25) or Color.New(0.66, 0.53, 0.42);
        if showType == SHOW_MAIN then
            item.p_content.text = SHOW_MAIN_STR;
        elseif showType == SHOW_BRANCH then
            item.p_content.text = SHOW_BRANCH_STR;
        elseif showType == SHOW_OTHER then
            item.p_content.text = SHOW_OTHER_STR;
        end
        item.p_dirOpen:SetActive(showOpen);
        item.p_dirClose:SetActive(not showOpen);
    end 
end

function InitItemList(curData)
    mTaskItems.nextIndex = 1;
    local selectTaskType = mSelectData.taskType[mSelectData.selectType];
    local selectTaskID = mSelectData.taskID[mSelectData.selectType];
    for showType,datas in ipairs(curData.data) do
        if #datas > 0 or mSelectData.selectType == TOGGLE_TYPE.HAS_ACCEPT then        
            InitItem(showType,nil,curData.open[showType]);
        end
        if curData.open[showType] then
            for _,data in ipairs(datas) do
                InitItem(showType,data,curData.open[showType],selectTaskType,selectTaskID);
            end
        end
    end   
    for i = mTaskItems.nextIndex,#mTaskItems do
        mTaskItems[i].gameObject:SetActive(false);
    end

    mTaskTable:Reposition();
end

function InitTable()
    local curData = mTaskDatas[mSelectData.selectType];
    local hasData = (#curData.data[SHOW_MAIN] + #curData.data[SHOW_BRANCH] + #curData.data[SHOW_OTHER]) > 0;
    mNoDataObj:SetActive(not hasData);
    mHasDataObj:SetActive(hasData);
    if hasData then
        --任务列表
        InitItemList(curData);
        --选中任务
        InitSelectItem();
    end
end

function InitToggle()
    if mHasAcceptToggle.value then
        mSelectData.selectType = TOGGLE_TYPE.HAS_ACCEPT;
    elseif mCanAcceptToggle.value then
        mSelectData.selectType = TOGGLE_TYPE.CAN_ACCEPT;
    end
end

function OnEnable(self)  
    RegEvent(self);
    InitToggle();
    InitData();
    InitTable();
end

function OnDisable(self)
    UnRegEvent();
end

function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Task_Main);
    elseif id == 1 then
        --放弃
        TipsMgr.TipConfirmByKey("task_giveup_confirm");
    elseif id == 2 then
        --前往
        local taskType = mSelectData.taskType[mSelectData.selectType];
        local taskID = mSelectData.taskID[mSelectData.selectType];
        local taskDynamicData = TaskMgr.GetTaskDynamicData(taskType,taskID);
        if taskDynamicData then
            if mSelectData.selectType == TOGGLE_TYPE.HAS_ACCEPT then
                TaskMgr.RequestGotoFinishGoal(taskDynamicData);
                UIMgr.UnShowUI(AllUI.UI_Task_Main);
            else
                TaskMgr.RequestGotoAcceptTask(taskDynamicData);
            end
        end
    elseif id == 3 then
        --已接
        InitToggle();
        InitTable();
    elseif id == 4 then
        --可接
        InitToggle();
        InitTable();
    elseif id >= BASE_EVENT_ID then  
        local item = mTaskItems[id - BASE_EVENT_ID];
        local oldTaskType = mSelectData.taskType[mSelectData.selectType];
        local oldTaskID = mSelectData.taskID[mSelectData.selectType];
        if item.showData then
            mSelectData.taskType[mSelectData.selectType] = item.showData.taskType;
            mSelectData.taskID[mSelectData.selectType] = item.showData.taskID;
        else
            --目前需求不同分页不同时显示,切换分页同时切换选中ITEM
            local curData = mTaskDatas[mSelectData.selectType];
            for i = 1,#curData.open do
                if i == item.showType then
                    curData.open[i] = not curData.open[i];
                else
                    curData.open[i] = false;
                end
            end
            local selectData = QuestData.GetData(oldTaskID);
            if #curData.data[item.showType] > 0 and (not selectData or selectData.showType ~= item.showType) then
                mSelectData.taskType[mSelectData.selectType] = -1;
                mSelectData.taskID[mSelectData.selectType] = -1;
                InitSelectData();
            end
        end
        if item.showData == nil or oldTaskType ~= item.showData.taskType or oldTaskID ~= item.showData.taskID then
            InitTable();
        end
    end
end

function OnTaskList()
    InitData();
    if mSelectData.selectType == TOGGLE_TYPE.HAS_ACCEPT then
        InitTable();
    end
end

function OnTaskAccept()
    InitData();
    if mSelectData.selectType == TOGGLE_TYPE.HAS_ACCEPT then
        InitTable();
    end
end

function OnTaskUpdate()
    InitData();
    if mSelectData.selectType == TOGGLE_TYPE.HAS_ACCEPT then
        InitTable();
    end
end

function OnTaskCancel()
    InitData();
    if mSelectData.selectType == TOGGLE_TYPE.HAS_ACCEPT then
        InitTable();
    end
end

function OnTaskFinish()
    InitData();
    if mSelectData.selectType == TOGGLE_TYPE.HAS_ACCEPT then
        InitTable();
    end
end

