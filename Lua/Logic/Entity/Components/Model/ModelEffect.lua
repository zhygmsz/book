ModelEffect = class("ModelEffect",ModelBase);

function ModelEffect:ctor(...)
    ModelBase.ctor(self,...);
    self._modelLoader = LoaderMgr.CreateEffectLoader();
end

function ModelEffect:UpdateModel()
    ModelBase.LoadModel(self,self._entity._entityAtt.modelID);
end

return ModelEffect;