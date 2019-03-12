ModelPlayerMain = class("ModelPlayerMain",ModelPlayer);

function ModelPlayerMain:ctor(...)
    ModelPlayer.ctor(self,...);
    if self._cacheModelLoader then
        --使用上一次的玩家模型
        LoaderMgr.DeleteLoader(self._modelLoader);
        self._modelLoader = self._cacheModelLoader;
        self._cacheModelLoader = nil;
    end
end

function ModelPlayerMain:dtor()
    --不删除玩家模型
    self._cacheModelLoader = self._modelLoader;
    self._modelLoader = nil;
end

function ModelPlayerMain:OnEnable()
    self._rootGameObject:SetActive(true);
end

function ModelPlayerMain:OnDisable()
    --self._rootGameObject:SetActive(false);
end

return ModelPlayerMain;