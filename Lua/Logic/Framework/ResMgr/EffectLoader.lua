EffectLoader = class("EffectLoader",TransformLoader)

function EffectLoader:ctor()
    TransformLoader.ctor(self);
end

function EffectLoader:LoadObject(loadResID,loadCallBack,isSelf,params)
    BaseLoader.LoadObject(self,loadResID,loadCallBack,true,isSelf,params);
end

function EffectLoader:OnLoadFinish(...)
    TransformLoader.OnLoadFinish(self,...)
    self:OnPostLoad();
end

return EffectLoader;