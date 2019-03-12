SACT_LimitMove = class("SACT_LimitMove",SACT_Base)

function SACT_LimitMove:ctor(...)
    SACT_Base.ctor(self,...);
end

function SACT_LimitMove:DoStartEffect()
    self._actionEntity:GetStateComponent():SyncClientState(Common_pb.ESOE_ADD,EntityDefine.CLIENT_STATE_TYPE.LIMIT_MOVE,self);
end

function SACT_LimitMove:DoStopEffect()
    self._actionEntity:GetStateComponent():SyncClientState(Common_pb.ESOE_DEL,EntityDefine.CLIENT_STATE_TYPE.LIMIT_MOVE,self);
end

return SACT_LimitMove;