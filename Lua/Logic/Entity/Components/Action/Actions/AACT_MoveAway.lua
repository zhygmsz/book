AACT_MoveAway = class("AACT_MoveAway",AACT_Base);

function AACT_MoveAway:ctor(...)
    AACT_Base.ctor(self,...);
end

function AACT_MoveAway:DoStartEffect()
    if not self._attacker then
        self._moveDir = -self._actionEntity:GetPropertyComponent():GetForward();
    else
        self._attackerPosition = self._attacker:GetPropertyComponent():GetPosition();
        self._defenderPosition = self._actionEntity:GetPropertyComponent():GetPosition();
        --沿着远离攻击者的方向逃跑
        self._moveDir = self._defenderPosition - self._attackerPosition;
        if self._moveDir.magnitude < 0.01 then  
            self._moveDir = -self._attacker:GetPropertyComponent():GetForward();
        end 
    end
    self._moveDir.y = 0;
    self._moveDir:SetNormalize();
    --计算可以跑到的NAVMESH目标点
    self._distance = self._totalTime * self._actionEntity:GetPropertyComponent():GetMoveSpeed() * 0.001; 
    --开始朝目标点移动
    local destPosition = self._defenderPosition + self._moveDir  * self._distance; 
    self._actionEntity:GetMoveComponent():MoveWithDest(destPosition);
end

function AACT_MoveAway:DoUpdateEffect()
end

function AACT_MoveAway:DoStopEffect()
end

return AACT_MoveAway;