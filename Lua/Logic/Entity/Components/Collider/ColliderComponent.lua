ColliderComponent = class("ColliderComponent",EntityComponent);

function ColliderComponent:ctor(...)
    EntityComponent.ctor(self,...);
end

function ColliderComponent:OnEnable()
    if self._entity:IsNPC() and self._entity:GetNPCType() == Common_pb.NPC_FUNC then
        --功能交互NPC
        self._areaRadius = self._entity._entityAtt.npcData.interactRadius;
        self._areaPosition = self._entity._entityAtt.position;
        self._areaEnterFlag = false;
        self._areaMoveComponent = self._entity:GetMoveComponent();
        GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_POS_UPDATE,self.OnPlayerMove,self);
    end
end

function ColliderComponent:OnUpdate(deltaTime)
    if self._areaMoveComponent and self._areaMoveComponent:IsMoving() then
        self:OnPlayerMove(MapMgr.GetMainPlayer():GetPropertyComponent():GetPosition());
    end
end

function ColliderComponent:OnDisable()    
    if self._entity:IsNPC() and self._entity:GetNPCType() == Common_pb.NPC_FUNC then
        --功能交互NPC
        self:OnPlayerLeave();
        GameEvent.UnReg(EVT.PLAYER,EVT.PLAYER_POS_UPDATE,self.OnPlayerMove,self);
    end
end

function ColliderComponent:OnPlayerMove(position)
    if math.DistanceXZ(position,self._areaPosition) < self._areaRadius then
        self:OnPlayerEnter();
    else
        self:OnPlayerLeave();
    end
end

function ColliderComponent:OnPlayerEnter()
    if self._areaEnterFlag then return end
    --玩家进入了区域范围
    self._areaEnterFlag = true;
    GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_ENTER_NPC_AREA,self._entity._entityAtt.npcData);
end

function ColliderComponent:OnPlayerLeave()
    if not self._areaEnterFlag then return end
    --玩家离开了区域范围
    self._areaEnterFlag = false;
    GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_LEAVE_NPC_AREA,self._entity._entityAtt.npcData);

end

return ColliderComponent;