AssetLoader = class("AssetLoader",BaseLoader)

function AssetLoader:ctor()
    BaseLoader.ctor(self);
end

function AssetLoader:LoadObject(loadResID,loadCallBack,isSelf,params)
    BaseLoader.LoadObject(self,loadResID,loadCallBack,false,isSelf,params);
end

function AssetLoader:OnLoadFinish(...)
    BaseLoader.OnLoadFinish(self,...)
    self:OnPostLoad();
end

return AssetLoader;