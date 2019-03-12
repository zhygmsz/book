ModelPlayer = class("ModelPlayer",ModelCharacter);

function ModelPlayer:ctor(...)
	ModelCharacter.ctor(self,...);
	self._boneID = nil;
	self._controllerID = nil;
	self._modelBodys = self._modelBodys or {};
	self._modelAnims = self._modelAnims or {};
end

function ModelPlayer:FillBodyWithPhysique()
	--默认模型
	local pID = self._entity:IsRender() and self._entity._entityAtt.renderPhysiqueID or self._entity._entityAtt.physiqueID;
	local pData = PhysiqueData.GetPhysique(pID);
	--主骨骼
	self._boneID = pData.boneID;
	--控制器
	self._controllerID = pData.controllerID;
	--旧数据
	for i = Fashion_pb.SLOT_MIN + 1,Fashion_pb.SLOT_MAX - 1 do self._modelBodys[i] = -1; end
	--身体部位
	for idx,fashionID in ipairs(pData.bodyIDs) do
		local fashionData = FashionData.GetFashionData(fashionID);
		self._modelBodys[fashionData.slotType + 1] = fashionData.resID;
	end
end

function ModelPlayer:FillBodyWithFashion()
	--使用时装部位替换掉对应部位的默认模型
	for idx,fashionData in ipairs(self._entity._entityAtt.fashions) do
		self._modelBodys[fashionData.slotType + 1] = fashionData.resID;
	end
end

function ModelPlayer:FillBodyWithShape()
	--检测变身状态信息
	if self._entity:IsRender() then
	
	else
		local shapeData = self._entity:GetPropertyComponent():GetShapeData();
		if shapeData then
			local npcData = NPCData.GetNPCInfo(shapeData.npcID);
			local pID = npcData and npcData.physiqueID;
			local pData = PhysiqueData.GetPhysique(pID);
			if pData then
				for i = Fashion_pb.SLOT_MIN + 1,Fashion_pb.SLOT_MAX - 1 do self._modelBodys[i] = -1; end
				self._boneID = pData.boneID;
				self._controllerID = pData.controllerID;
			end
		end
	end
end

function ModelPlayer:FillAnimWithPhysique()
	--根据形体信息动态替换动画信息 TODO
end

function ModelPlayer:UpdateModel(physiqueID)
	--填充当前角色默认模型部件信息
	self:FillBodyWithPhysique();
	--根据穿戴装备填充模型部件信息
	self:FillBodyWithFashion();
	--根据变身状态修改模型部件信息
	self:FillBodyWithShape();
	--开始加载模型相关资源
	ModelBase.LoadModel(self,self._boneID,self._controllerID,self._entity:IsSelf(),self._modelBodys,self._modelAnims,self.OnModelLoad,self);
	if self._entity:IsPlayer() then
		--如果当前角色在坐骑上
		local rideData = self._entity._entityAtt.rideData;
		if rideData.enable then
			local pData = PhysiqueData.GetPhysique(rideData.staticData.physiqueID);
			self._modelLoader._loadScript:LoadRideAssets(pData.boneID,pData.controllerID,self._entity:IsSelf() and 1 or 0);
		else
			self._modelLoader._loadScript:LoadRideAssets(-1,-1,0);
		end
		--修改模型身高
		if self._rootCollider then
			local realHeight = self._entity:GetPropertyComponent():GetHeight();
			self._rootCollider.center = Vector3(0,realHeight * 0.5,0);
			self._rootCollider.height = realHeight;
		end
	end
	--检查是否加载结束
	self._modelLoader._loadScript:LoadAssetsEnd();
end

return ModelPlayer;