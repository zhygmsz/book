MoveAction_Base = class("MoveAction_Base")

function MoveAction_Base:ctor(moveComponent)
    self._canMoveSpeedReduction = false;

    self._entity = moveComponent._entity;
    self._propertyComponent = self._entity:GetPropertyComponent();
    self._stateComponent = self._entity:GetStateComponent();
    self._movePathData = self._movePathData or {};
    table.clear(self._movePathData);
end

function MoveAction_Base:IsMoving()
    return self._movePathData.moveFlag or self._movePathData.followFlag or self._movePathData.rotateFlag or self._movePathData.dragMoveFlag;
end

function MoveAction_Base:OnMoveWithJoystick(dx,dz) end

function MoveAction_Base:OnMoveWithTarget() end

function MoveAction_Base:OnMoveWithSkill(position,forward)
    self._propertyComponent:SetPosition(position);
    self._propertyComponent:SetForward(forward);
end

function MoveAction_Base:OnMoveWithTeleport(position,forward)
    self:OnMoveStop(0);
    self._propertyComponent:SetPosition(position);
    self._propertyComponent:SetForward(forward);
end

function MoveAction_Base:OnUpdate(deltaTime)
    if self._canMoveFlag and self._movePathData.moveFlag then self:OnMoveUpdate(deltaTime); end
    if self._movePathData.rotateFlag then self:OnRotateUpdate(deltaTime); end
end

function MoveAction_Base:OnMoveStart()
    self._canMoveFlag = true;
    self._movePathData.moveDistance = self._movePathData.moveDistance or 0;
end

function MoveAction_Base:OnMoveStop(stopType)
    self._movePathData.moveDistance = nil;
end

function MoveAction_Base:OnMoveUpdate(deltaTime)
    local deltaTime = deltaTime * 0.001;
    --根据当前移动速度计算移动后目标点和移动距离
    local moveSpeed = self._propertyComponent:GetMoveSpeed();
    local deltaMove = self._movePathData.pathMoveDir * moveSpeed * deltaTime;
    local curPos = self._propertyComponent:GetPosition(true);  curPos.y = 0;
    local endPos = curPos + deltaMove;
    local endDist = Vector3.Distance(self._movePathData.pathSrc,endPos);
    local moveDeltaDis = deltaMove.magnitude;
    local nextDist = endDist + moveDeltaDis;
    self._movePathData.moveDistance = self._movePathData.moveDistance + moveDeltaDis;
    if endDist >= self._movePathData.pathDist then
        --本次移动超过了路点,需要做减速处理,因为超过路点可能不在寻路图上
        self._movePathData.moveDistance = self._movePathData.moveDistance - (endDist - self._movePathData.pathDist);
        self._propertyComponent:SetPosition(self._movePathData.pathDst);
        self:OnNextCorner();
    elseif nextDist >= self._movePathData.pathDist and not self._canMoveSpeedReduction then
        --下次移动超过了路点,不支持减速需要重新计算移动轨迹
        self._propertyComponent:SetPosition(endPos);
        self:OnNextCorner();
    else
        self._propertyComponent:SetPosition(endPos);
    end
end

function MoveAction_Base:OnRotateUpdate(deltaTime)
    local deltaTime = deltaTime * 0.001;
    local pathForward = self._movePathData.pathForward;
    if not pathForward or (pathForward.x == 0 and pathForward.z == 0) then
        --不合法的朝向
        GameLog.LogError("forward error %s %s %s",pathForward and pathForward.x,pathForward and pathForward.z,self._entity:GetName(),self._entity:GetID());
    else
        local turnSpeed = self._propertyComponent:GetTurnSpeed();
        local curForward = self._propertyComponent:GetForward(); curForward.y = 0;
        local angle = Vector3.Angle(curForward, pathForward);
        if angle > 0.1 then
            --Slerp圆形平滑插值
            local t = deltaTime / (angle / turnSpeed);
            local nextForward = Vector3.Slerp(curForward, pathForward, t);
            self._propertyComponent:SetForward(nextForward);
        else
            --低于0.1度忽略
            self._movePathData.rotateFlag = false;
        end
    end
end

return MoveAction_Base;