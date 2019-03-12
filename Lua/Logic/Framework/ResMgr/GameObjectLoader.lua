GameObjectLoader = class("GameObjectLoader",TransformLoader)

function GameObjectLoader:ctor()
    TransformLoader.ctor(self);
end

function GameObjectLoader:LoadObject(loadResID,loadCallBack,isSelf,params)
    BaseLoader.LoadObject(self,loadResID,loadCallBack,true,isSelf,params);
end

function GameObjectLoader:OnLoadFinish(...)
    TransformLoader.OnLoadFinish(self,...)
    self:OnPostLoad();
end

return GameObjectLoader;