AACT_PlayAction = class("AACT_PlayAction",AACT_Base);

function AACT_PlayAction:ctor(...)
    AACT_Base.ctor(self,...);
    self._actionName = self._actionArgs[1].strValue;
    self._needAutoExit = self._actionArgs[2] and self._actionArgs[2].intValue == 1;
    self._autoExitName = self._actionArgs[3] and self._actionArgs[3].strValue;
end

function AACT_PlayAction:DoStartEffect()
    self._actionEntity:GetStateComponent():PlayAnim(self._actionName,self._needAutoExit,self._autoExitName);
end

function AACT_PlayAction:DoUpdateEffect()
end

function AACT_PlayAction:DoStopEffect()
end

return AACT_PlayAction;