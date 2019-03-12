ModelCharacter = class("ModelCharacter",ModelBase);

function ModelCharacter:ctor(...)
    ModelBase.ctor(self,...);
	self._modelLoader = LoaderMgr.CreateModelLoader();
end

function ModelCharacter:UpdateModel()
	--不会进行换装的对象只有一个模型和控制器	
	local pID = self._entity:IsRender() and self._entity._entityAtt.renderPhysiqueID or self._entity._entityAtt.physiqueID;
	local pData = PhysiqueData.GetPhysique(pID);
	ModelBase.LoadModel(self,pData.boneID,pData.controllerID,false,nil,nil,self.OnModelLoad,self);
end

return ModelCharacter;