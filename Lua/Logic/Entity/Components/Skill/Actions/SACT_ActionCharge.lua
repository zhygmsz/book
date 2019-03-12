SACT_ActionCharge = class("SACT_ActionCharge",SACT_Base)

function SACT_ActionCharge:ctor(...)
    SACT_Base.ctor(self,...);
    self._chargeType = self._actionAtt.args[1].intValue;
    self._chargeDuration = self._actionAtt.args[2].intValue;
    self._chargeDistance = self._actionAtt.args[3].floatValue;
    self._chargeSpeed = self._chargeDistance / self._chargeDuration;
    self._actionEntityPropertyComponent = self._actionEntity:GetPropertyComponent();
end

function SACT_ActionCharge:DoStartEffect()
    self._chargedDistance = 0;
end

function SACT_ActionCharge:DoUpdateEffect(deltaTime)
    --非主角技能位移等待同步,不做处理
    if not self._actionEntity or not self._actionEntity:IsSelf() or not self._actionEntity:IsValid() then return end
    if self._chargeType == 1 then
        --固定距离
        local deltaDistance = self._chargeSpeed * deltaTime;
        local selfForward = self._actionEntityPropertyComponent:GetForward();
        local selfPosition = self._actionEntityPropertyComponent:GetPosition();
        local targetPosition = selfPosition + selfForward.normalized * deltaDistance;
        local validPosition = GameUtil.GameFunc.FindValidTarget(selfPosition,targetPosition);
        self._actionEntityPropertyComponent:SetPosition(validPosition);
        --同步位移
        MapMgr.RequestSyncSkillMove(self._actionEntity);
    elseif self._chargeType == 2 then
    
    elseif self._chargeType == 3 then
        
    end
end

function SACT_ActionCharge:DoStopEffect()      
end

function SACT_ActionCharge:DoDestroyEffect()
end

return SACT_ActionCharge;