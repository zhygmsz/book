SACT_LimitCancel = class("SACT_LimitCancel",SACT_Base)

function SACT_LimitCancel:ctor(...)
    SACT_Base.ctor(self,...);
end

function SACT_LimitCancel:DoStartEffect()
    self._actionEntity:GetStateComponent():SyncClientState(Common_pb.ESOE_ADD,EntityDefine.CLIENT_STATE_TYPE.LIMIT_CANCEL,self,self._actionOwner._skillUnitID);
end

function SACT_LimitCancel:DoStopEffect()
    self._actionEntity:GetStateComponent():SyncClientState(Common_pb.ESOE_DEL,EntityDefine.CLIENT_STATE_TYPE.LIMIT_CANCEL,self);
end

return SACT_LimitCancel;