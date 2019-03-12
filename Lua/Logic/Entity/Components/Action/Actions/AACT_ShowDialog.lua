AACT_ShowDialog = class("AACT_ShowDialog",AACT_Base);

function AACT_ShowDialog:ctor(...)
    AACT_Base.ctor(self,...);
    self._dialogData = self._dialogData or {};
    self._dialogData.dialogGroupID = self._actionArgs[1].intValue;
    self._dialogData.entityID = self._actionEntity:GetID();
end

function AACT_ShowDialog:DoStartEffect()
    GameEvent.Trigger(EVT.STORY,EVT.DIALOG_OPEN,self._dialogData);
end

function AACT_ShowDialog:DoUpdateEffect()
end

function AACT_ShowDialog:DoStopEffect()
end

return AACT_ShowDialog;