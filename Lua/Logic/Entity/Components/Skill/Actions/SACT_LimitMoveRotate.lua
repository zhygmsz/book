SACT_LimitMoveRotate = class("SACT_LimitMoveRotate",SACT_Base)

function SACT_LimitMoveRotate:ctor(...)
    SACT_Base.ctor(self,...);
end

function SACT_LimitMoveRotate:DoStartEffect()
    self._actionEntity:GetStateComponent():SyncClientState(Common_pb.ESOE_ADD,EntityDefine.CLIENT_STATE_TYPE.LIMIT_MOVE_ROTATE,self);
end

function SACT_LimitMoveRotate:DoStopEffect()
    self._actionEntity:GetStateComponent():SyncClientState(Common_pb.ESOE_DEL,EntityDefine.CLIENT_STATE_TYPE.LIMIT_MOVE_ROTATE,self);
end

return SACT_LimitMoveRotate;