MoveAction_Server = class("MoveAction_Server",MoveAction_Base);

function MoveAction_Server:ctor(moveComponent)
    MoveAction_Base.ctor(self,moveComponent);
    self._canMoveSpeedReduction = true;
end

function MoveAction_Server:OnMoveWithDest(position,forward)
    self._movePathData.destPosition = position;
    self._movePathData.destForward = forward;
    self:OnMoveStart();
end

function MoveAction_Server:OnMoveWithTarget(position,forward,stopFlag)
    self._movePathData.followFlag = (stopFlag == NetCS_pb.MOVE_SMOOTH);
    if stopFlag == NetCS_pb.STOP_TRANSFER then
        --立即传送至目标点
        self:OnMoveWithTeleport(position,forward);
    elseif stopFlag == NetCS_pb.STOP_NOW then
        --立即停止移动
        self:OnMoveStop(0);
    else
        --平滑朝向目标点移动,忽略位置不一致的误差
        self:OnMoveWithDest(position,forward);
    end
end

function MoveAction_Server:OnMoveStart()
    MoveAction_Base.OnMoveStart(self);
    self._movePathData.moveFlag = true;
    self._movePathData.rotateFlag = true;
    self:OnNextCorner();
    if self._movePathData.moveFlag then
        self._stateComponent:PlayAnim(EntityDefine.ANIM_NAME.ANIM_MOVE);
    else
        self._stateComponent:PlayAnim(EntityDefine.ANIM_NAME.ANIM_IDLE);
    end
end

function MoveAction_Server:OnMoveStop(stopType)
    if not self:IsMoving() then return end
    MoveAction_Base.OnMoveStop(self);
    --停止跟随
    if stopType == 0 then self._movePathData.followFlag = false; end
    --停止转身
    if stopType ~= 1 then self._movePathData.rotateFlag = false; end
    if self._movePathData.moveFlag then
        --停止移动
        self._movePathData.moveFlag = false;
        if not self._movePathData.followFlag then
            self._stateComponent:PlayAnim(EntityDefine.ANIM_NAME.ANIM_IDLE);
        else
            --等待同步下一目标点
        end
    end
end

function MoveAction_Server:OnNextCorner()
    local movePathData = self._movePathData;
    if movePathData.destPosition.x ~= 0 or movePathData.destPosition.z ~= 0 then
        --目标点合法,朝向目标点移动
        --轨迹起始点、长度、方向
        local pathSrc = self._entity:GetPropertyComponent():GetPosition(true);
        local pathDst = movePathData.destPosition;
        pathSrc.y = 0; pathDst.y = 0;
        local pathMoveDir = pathDst - pathSrc; pathMoveDir:SetNormalize();
        local pathDist = Vector3.Distance(pathSrc, pathDst);
        --与目标点距离超过一定阈值
        if pathDist > 0.1 then
            --修改当前轨迹状态
            movePathData.pathMoveDir = pathMoveDir;
            movePathData.pathDist = pathDist;
            movePathData.pathDst = pathDst;
            movePathData.pathSrc = pathSrc;
            movePathData.pathForward = pathMoveDir;
        else
            --距离太近,移动失败
            self:OnMoveStop(2);
        end
    elseif movePathData.destForward.x ~= 0 or movePathData.destForward.z ~= 0 then
        --朝向合法,原地转身
        movePathData.moveFlag = false;
        movePathData.pathForward = movePathData.destForward;
    else
        self:OnMoveStop(2);
    end
end

return MoveAction_Server;