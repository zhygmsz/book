MoveComponent = class("MoveComponent",EntityComponent);

function MoveComponent:ctor(...)
    EntityComponent.ctor(self,...);
end

function MoveComponent:OnStart()
    if not self._moveAction then
        if self._entity:IsSelf() then
            self._moveAction = MoveAction_Client.new(self);
        else
            self._moveAction = MoveAction_Server.new(self);
        end
    else
        self._moveAction:ctor(self);
    end
end

function MoveComponent:OnUpdate(deltaTime)
    self._moveAction:OnUpdate(deltaTime);
end

--摇杆移动
function MoveComponent:MoveWithJoystick(dx,dz)
    self._moveAction:OnMoveWithJoystick(dx,dz);
end

--移动至指定地点
function MoveComponent:MoveWithDest(position,forward,deltaMoveFlag)
    self._moveAction:OnMoveWithDest(position,forward);
end

--传送
function MoveComponent:MoveWithTeleport(position,forward)
    self._moveAction:OnMoveWithTeleport(position,forward);
end

--跟随服务器位置和朝向
function MoveComponent:MoveWithTarget(position,forward,stopFlag,moveSpeed)
    --死亡状态
    if self._entity:IsDead() then return GameLog.LogError("entity %s is dead,can not move",self._entity:GetName()) end
    --移动速度
    self._entity:GetPropertyComponent():SetMoveSpeed(moveSpeed);
    --跟随状态
    self._moveAction:OnMoveWithTarget(position,forward,stopFlag);
end

--技能位移
function MoveComponent:MoveWithSkill(position,forward)
    self._moveAction:OnMoveWithSkill(position,forward);
end

--[[
停止移动
stopType    int     停止方式,默认为0
                    0 停止全部移动行为
                    1 停止移动
                    2 停止移动和旋转
--]]
function MoveComponent:StopMove(stopType)
    self._moveAction:OnMoveStop(stopType or 0);
end

--是否正在移动
function MoveComponent:IsMoving()
    return self._moveAction:IsMoving();
end

return MoveComponent;