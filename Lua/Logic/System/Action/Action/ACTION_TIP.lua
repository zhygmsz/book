ACTION_TIP = class("ACTION_TIP",ACTION_BASE);

function ACTION_TIP:ctor(...)
    ACTION_BASE.ctor(self,...);
    self._tipID = self._actionData.intParams[1];
end

function ACTION_TIP:OnUpdate()
    self._actionDone = true;
    TipsMgr.TipByID(self._tipID);
end

return ACTION_TIP;