module("UserData",package.seeall)

local mControlData = {};

local function OnEnterControl()
	TouchMgr.SetEnableDragJoyStick(false);
    TouchMgr.SetTouchEventEnable(false);
    local mainPlayer = MapMgr.GetMainPlayer();
    if mainPlayer then
        mainPlayer:GetAIComponent():ResetAI();
    end
end

local function OnLeaveControl()
    if not IsInControl() then
        TouchMgr.SetEnableDragJoyStick(true);
        TouchMgr.SetTouchEventEnable(true);
    end
end

local function OnStoryEnter()
    mControlData._isInStory = true;
    OnEnterControl();
end

local function OnStoryFinish()
    mControlData._isInStory = false;
    OnLeaveControl();
end

local function OnDialogEnter(dialogData)
    if dialogData.dialogType == Dialog_pb.DialogData.MODEL or
       dialogData.dialogType == Dialog_pb.DialogData.SELECT then
        mControlData._isInDialog = true;
        OnEnterControl();
    end
end

local function OnDialogFalseFinish(dialogData)
    if dialogData.dialogType == Dialog_pb.DialogData.MODEL or
       dialogData.dialogType == Dialog_pb.DialogData.SELECT then
        mControlData._isInDialog = false;
        OnLeaveControl();
    end
end

function InitControlModule()
    GameEvent.Reg(EVT.STORY,EVT.STORY_ENTER,OnStoryEnter);
    GameEvent.Reg(EVT.STORY,EVT.STORY_FINISH,OnStoryFinish);
    GameEvent.Reg(EVT.STORY,EVT.DIALOG_ENTER,OnDialogEnter);
    GameEvent.Reg(EVT.STORY,EVT.DIALOG_FALSE_FINISH,OnDialogFalseFinish);
end

function IsInControl()
    return mControlData._isInStory or mControlData._isInDialog;
end

return UserData;