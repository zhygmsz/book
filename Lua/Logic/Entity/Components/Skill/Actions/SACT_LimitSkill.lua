SACT_LimitSkill = class("SACT_LimitSkill",SACT_Base)

function SACT_LimitSkill:ctor(...)
    SACT_Base.ctor(self,...);
end

function SACT_LimitSkill:DoStartEffect()
    self._actionEntity:GetStateComponent():SyncClientState(Common_pb.ESOE_ADD,EntityDefine.CLIENT_STATE_TYPE.LIMIT_SKILL,self);
end

function SACT_LimitSkill:DoStopEffect()
    self._actionEntity:GetStateComponent():SyncClientState(Common_pb.ESOE_DEL,EntityDefine.CLIENT_STATE_TYPE.LIMIT_SKILL,self);
end

return SACT_LimitSkill;