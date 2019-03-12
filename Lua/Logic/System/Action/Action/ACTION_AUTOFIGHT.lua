ACTION_AUTOFIGHT = class("ACTION_AUTOFIGHT",ACTION_BASE);

function ACTION_AUTOFIGHT:ctor(...)
    ACTION_BASE.ctor(self,...);
    self._autoFightFlag = self._actionData.intParams[1] == 1;
end

function ACTION_AUTOFIGHT:OnUpdate()
    self._actionDone = true;
    UserData.SetAutoFight(self._autoFightFlag);
end

return ACTION_AUTOFIGHT;