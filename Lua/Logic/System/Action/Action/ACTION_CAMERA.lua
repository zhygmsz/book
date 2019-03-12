ACTION_CAMERA = class("ACTION_CAMERA",ACTION_BASE);

function ACTION_CAMERA:ctor(...)
    ACTION_BASE.ctor(self,...);
    self._pitch = self._actionData.intParams[1] * 0.0001;
    self._yaw = self._actionData.intParams[2] * 0.0001;
    self._distance = self._actionData.intParams[3] * 0.0001;
    self._fixedMode = self._actionData.intParams[4] == 1;
    self._npcUnitID = self._actionData.intParams[5];
    self._npcEntity = MapMgr.GetNPCByUnitID(self._npcUnitID) or MapMgr.GetMainPlayer();
    self._npcTransform = self._npcEntity:GetModelComponent():GetEntityRoot();
end

function ACTION_CAMERA:OnUpdate()
    self._actionDone = true; 
    if self._fixedMode then
        CameraMgr.EnterFixedMode(self._pitch,self._yaw,self._distance,self._npcTransform);
    else
        CameraMgr.EnterFreeMode(self._pitch,self._yaw,self._distance,self._npcTransform);
    end
end

return ACTION_CAMERA;