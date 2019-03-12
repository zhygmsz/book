MoveAction_Client = class("MoveAction_Client",MoveAction_Base)

function MoveAction_Client:ctor(moveComponent)
    MoveAction_Base.ctor(self,moveComponent);
    self._RUN_START_DISTANCE = ConfigData.GetValue("move_speedup_distance");
    self._RIDE_ON_DISTANCE = ConfigData.GetValue("move_rideon_distance");
    self._RIDE_ON_DELTA_TIME = ConfigData.GetValue("move_rideon_deltatime");
end

function MoveAction_Client:OnMoveWithJoystick(dx,dz)
    --检查摇杆移动合法性
    local dx = math.floor(dx * 1000) * 0.001;
    local dz = math.floor(dz * 1000) * 0.001;
    if dx == 0 and dz == 0 then return end
    --检查是否方向相同
    local movePathData = self._movePathData;
    local dragMoveDir = self._movePathData.dragMoveDir or Vector3.zero;
    if movePathData.dragMoveFlag and dragMoveDir.x == dx and dragMoveDir.z == dz then return end
    --移动方向
    dragMoveDir:Set(dx,0,dz);
    self._movePathData.dragMoveDir = dragMoveDir;
    --移动距离
    local moveDistance = self._propertyComponent:GetMoveSpeed() * 0.5;
    local startPos = self._propertyComponent:GetPosition();
    local endPos = startPos + dragMoveDir * moveDistance;
    self:OnMoveWithDest(endPos,nil,true);
end

function MoveAction_Client:OnMoveWithDest(position,forward,dragMoveFlag)
    self._movePathData.hasValidPath = GameUtil.GameFunc.FindMovePath(self._propertyComponent:GetPosition(),position,dragMoveFlag);
    self._movePathData.dragMoveFlag = dragMoveFlag or false;
    if self._movePathData.hasValidPath or self._movePathData.dragMoveFlag then
        self:OnMoveStart();
    else
        self:OnMoveStop(0);
    end
end

function MoveAction_Client:OnMoveWithTarget(position,forward,stopFlag)
    if stopFlag == NetCS_pb.STOP_TRANSFER then
        --立即传送至目标点
        self:OnMoveWithTeleport(position,forward);
    end
end

function MoveAction_Client:OnMoveStateChange(stopFlag,isStart)
    if self._entity:IsSelf() then
        if stopFlag == NetCS_pb.MOVE_SMOOTH then
            if isStart then
                self._movePathData.lastSyncTime = GameTime.time_L;
                MapMgr.RequestSyncMove(self._entity,false,self._movePathData.pathDst);
            elseif (GameTime.time_L - self._movePathData.lastSyncTime) > 200 then
                --限制同步频率,每秒5次
                self._movePathData.lastSyncTime = GameTime.time_L;
                MapMgr.RequestSyncMove(self._entity,false,self._movePathData.pathDst);
            end
        elseif stopFlag == NetCS_pb.STOP_SMOOTH then
            --停止移动不考虑同步频率,如果转身未停止,则把目标朝向同步过去
            MapMgr.RequestSyncMove(self._entity,true,self._movePathData.rotateFlag and self._movePathData.pathForward or nil);
        end
    end
end

function MoveAction_Client:OnUpdate(deltaTime)
    MoveAction_Base.OnUpdate(self,deltaTime);
    if self._movePathData.moveFlag then 
        self:OnMoveStateChange(NetCS_pb.MOVE_SMOOTH);
        if self._movePathData.moveDistance >= self._RUN_START_DISTANCE then
            --进入奔跑状态
            self._stateComponent:SyncClientState(Common_pb.ESOE_UPDATE,EntityDefine.CLIENT_STATE_TYPE.RUNFAST,true);
        end
        if self._canMoveFlag and not self._movePathData.dragMoveFlag then
            --镜头进入跟随模式
            CameraMgr.EnterFollowMode();
        else
            --检查定身状态标志
            local canMoveFlag = self._stateComponent:CanMove();
            if canMoveFlag ~= self._canMoveFlag then
                self._canMoveFlag = canMoveFlag;
                self._stateComponent:PlayAnim(EntityDefine.ANIM_NAME.ANIM_MOVE);
            end
        end
        --检测坐骑
        self._movePathData.rideCheckTime = self._movePathData.rideCheckTime + deltaTime;
        if self._movePathData.rideCheckTime >= self._RIDE_ON_DELTA_TIME then
            self._movePathData.rideCheckTime = 0;
            self:RequestRideOn();
        end
    end
end

function MoveAction_Client:OnMoveStart()
    MoveAction_Base.OnMoveStart(self);
    --减速标志
    self._canMoveSpeedReduction = not self._movePathData.dragMoveFlag;
    --轨迹重置
    self._canMoveFlag = self._stateComponent:CanMove();
    self._movePathData.moveFlag = true;
    self._movePathData.rotateFlag = true;
    self._movePathData.rideCheckTime = self._RIDE_ON_DELTA_TIME;
    for i = 1,#self._movePathData do self._movePathData[i] = nil; end
    if self._movePathData.hasValidPath then
        local corners = GameUtil.GameFunc.NMPath.corners;
        local cornerCount = corners.Length - 1;
        for i = 0,cornerCount do self._movePathData[#self._movePathData + 1] = corners[i]; end
        self._movePathData.pathIndex = 1;
        self:OnNextCorner();
    else
        self._movePathData.moveFlag = false;
        self._movePathData.pathForward = self._movePathData.dragMoveDir;
    end
    if self._canMoveFlag then self._stateComponent:PlayAnim(EntityDefine.ANIM_NAME.ANIM_MOVE); end
end

function MoveAction_Client:OnMoveStop(stopType)
    if not self:IsMoving() then return end
    MoveAction_Base.OnMoveStop(self);
    --移动状态发生变化,同步当前位置
    if self._movePathData.moveFlag then self:OnMoveStateChange(NetCS_pb.STOP_SMOOTH); end
    self._movePathData.moveFlag = false;
    if stopType == 0 then self._movePathData.rotateFlag = false; end
    self._movePathData.dragMoveFlag = false;
    self._movePathData.moveDistance = nil;
    self._stateComponent:SyncClientState(Common_pb.ESOE_UPDATE,EntityDefine.CLIENT_STATE_TYPE.RUNFAST,false);
    --待机动作
    self._stateComponent:PlayAnim(EntityDefine.ANIM_NAME.ANIM_IDLE);
    --如果当前镜头处于跟随模式,则退出跟随模式
    if CameraMgr.IsInFollowMode() then CameraMgr.EnterFreeMode(); end
end

function MoveAction_Client:OnNextCorner()
    local movePathData = self._movePathData;
    --检查是否存在下一个拐点
    if movePathData.hasValidPath then
        if movePathData.pathIndex < #movePathData then
            --轨迹起始点、长度、方向
            local pathIndex = movePathData.pathIndex + 1;
            local pathSrc = self._propertyComponent:GetPosition(true);
            local pathDst = movePathData[pathIndex];
            pathSrc.y = 0; pathDst.y = 0;
            local pathMoveDir = pathDst - pathSrc; pathMoveDir:SetNormalize();
            local pathDist = Vector3.Distance(pathSrc, pathDst);
            --修改当前轨迹状态
            movePathData.pathIndex = pathIndex;
            movePathData.pathSrc = pathSrc;
            movePathData.pathDist = pathDist;
            movePathData.pathDst = pathDst;
            movePathData.pathMoveDir = pathMoveDir;
            --目标点发生变化,同步当前位置和目标点位置
            self:OnMoveStateChange(NetCS_pb.MOVE_SMOOTH,true);
        elseif movePathData.dragMoveFlag then
            --如果摇杆持续拖拽,方向不变,继续下一次移动
            movePathData.dragMoveFlag = false;
            self:OnMoveWithJoystick(movePathData.dragMoveDir.x,movePathData.dragMoveDir.z);
            return;
        else
            --已到达路径终点
            self:OnMoveStop(1);
            return;
        end
    end
    --如果处于摇杆状态,则保持朝向和摇杆方向一致
    self._movePathData.rotateFlag = true;
    if movePathData.dragMoveFlag then
        movePathData.pathForward = movePathData.dragMoveDir;
    else
        movePathData.pathForward = movePathData.pathMoveDir;
    end
end

--检测是否需要上坐骑
function MoveAction_Client:RequestRideOn()
    --计算与目标点距离
    if not self._movePathData.dragMoveFlag and not RideMgr.IsOnRide() then
        local totalDistance = 0;
        local pathIndex = self._movePathData.pathIndex;
        for i = pathIndex + 1,#self._movePathData do
            totalDistance = totalDistance + math.DistanceXZ(self._movePathData[i],self._movePathData[i-1]);
        end
        if pathIndex > 1 then
            local selfPosition = self._propertyComponent:GetPosition();
            totalDistance = totalDistance + math.DistanceXZ(self._movePathData[pathIndex],selfPosition);
        end
        if totalDistance >= self._RIDE_ON_DISTANCE then GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_REQ_RIDE_ON); end
    end
end

return MoveAction_Client;