EntityAIPet = class("EntityAIPet",EntityVisible);

function EntityAIPet:ctor(...)
    EntityVisible.ctor(self,...)
    self:AddComponent(EntityDefine.COMPONENT_TYPE.MOVE,MoveComponent.new(self));
end

function EntityAIPet:OnAwake()
    self._entityName = self._entityAtt:GetName();
    self._passedTime = 0;
    local birthID = self._entityAtt:GetBirthPoint();
    local node = MapMgr.GetNode(nil,birthID);
    self._birstPos = math.ConvertProtoV3(node.position);
    self._birstForward = math.ConvertProtoV3(Quaternion.Euler(node.rotation.x,node.rotation.y,node.rotation.z) * Vector3.forward)
end

function EntityAIPet:OnUpdate(deltaTime)
    EntityVisible.OnUpdate(self,deltaTime);
end

function EntityAIPet:GetPropertyComponent()
    return self:GetComponent(EntityDefine.COMPONENT_TYPE.PROPERTY);
end

return EntityAIPet;