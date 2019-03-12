ACTION_DIALOG = class("ACTION_DIALOG",ACTION_BASE);

function ACTION_DIALOG:ctor(...)
    ACTION_BASE.ctor(self,...);
    self._dialogBegin = false;
    self._dialogData = self._dialogData or {};
    self._dialogData.dialogGroupID = self._actionData.intParams[1];
end

function ACTION_DIALOG:OnUpdate()
    if not self._dialogBegin then
        self._dialogBegin = true;
        GameEvent.Reg(EVT.STORY,EVT.DIALOG_FINISH,self.class.OnDialogFinish,self);
        GameEvent.Trigger(EVT.STORY,EVT.DIALOG_OPEN,self._dialogData);
    end
end

function ACTION_DIALOG:OnDialogFinish(dialogData)
    if dialogData.groupID == self._dialogData.dialogGroupID then
        self._actionDone = true;
        GameEvent.UnReg(EVT.STORY,EVT.DIALOG_FINISH,self.class.OnDialogFinish,self);
    end
end

return ACTION_DIALOG;