ACTION_ANIMATION = class("ACTION_ANIMATION",ACTION_BASE);

function ACTION_ANIMATION:ctor(...)
    ACTION_BASE.ctor(self,...);
    self._entity = MapMgr.GetNPCByUnitID(self._actionData.intParams[2]);
    self._entity = self._entity or MapMgr.GetEntityByID(self._entityID);
    self._animGroupID = self._actionData.intParams[3];
    self._actionBegin = false;
end

function ACTION_ANIMATION:OnUpdate()
    if not self._actionBegin then
        self._actionBegin = true;
        if self._entity then
            local playSuccess,totalTime = self._entity:GetActionComponent():PlayAnimAction(self._animGroupID);
            if not self._playSuccess then
                self._actionDone = true;
            else
                self._endTime = GameTime.time_L + totalTime;
            end
        else
            self._actionDone = true;
        end
    elseif GameTime.time_L >= self._endTime then
        self._actionDone = true;
    end
end

return ACTION_ANIMATION;