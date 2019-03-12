BaseLoader = class("BaseLoader")

function BaseLoader:ctor()
    --加载出来的资源
    self._loadedObject = nil;
    --单独资源的加载ID
    self._loadIndex = -1;
    --单独资源的资源ID
    self._loadResID = -1;
    --资源加载完成回调
    self._loadCallBack = nil;
end

function BaseLoader:OnAwake()

end

function BaseLoader:dtor()
    if not tolua.isnull(self._loadedObject) then 
        --删除加载出来的资源
        ResMgr.UnloadObject(self._loadedObject);
    elseif self._loadIndex ~= -1 then
        --停止正在加载的资源
        ResMgr.StopLoading(self._loadIndex);
    end
    --清空引用状态
    self._loadedObject = nil;
    self._loadIndex = -1;
    self._loadResID = -1;
    self._loadCallBack = nil;
    self._loadCallBackParams = nil;
end

function BaseLoader:Clear()
    self:dtor();
end

function BaseLoader:GetType()
    return self._loaderType;
end

function BaseLoader:GetGUID()
    return self._loaderGuid;
end

function BaseLoader:GetObject()
    return self._loadedObject;
end

function BaseLoader:GetResID()
    return self._loadResID;
end

--[[
加载指定ID的资源
resID           int         资源ID
loadCallBack    function    资源加载回调
needInstance    bool        是否需要示例化
isSelf          bool        是否是自己的资源(与其他主角或者实体区分,用于控制加载优先级)
--]]
function BaseLoader:LoadObject(loadResID,loadCallBack,needInstance,isSelf,params)
    if self._loadResID == loadResID then
        --资源重复加载
        self._loadCallBack = loadCallBack;
        --资源尚未加载完成
        if not self._loadedObject then return end
        self._loadCallBackParams = params;
        self:OnPostLoad();
    else
        --清空旧资源
        self:Clear();
        --设置新资源状态
        self._loadResID = loadResID;
        self._loadCallBack = loadCallBack;
        self._loadPriority = isSelf and 1 or 0;
        self._needInstance = needInstance;
        self._loadCallBackParams = params;
        --加载新资源
        if self._needInstance then
            self._loadIndex = ResMgr.LoadInstantiateObjectAsync(self._loadResID,self._loadPriority,self);
        else
            self._loadIndex = ResMgr.LoadObjectAsync(self._loadResID,self._loadPriority,self);
        end
    end
end

function BaseLoader:OnLoadFinish(index,loadedObject)
    self._loadedObject = loadedObject;
end

function BaseLoader:OnPostLoad()
    if self._loadCallBack then
        local loadCallBack = self._loadCallBack;
        local localCallBackParams = self._loadCallBackParams;
        self._loadCallBack = nil;
        self._loadCallBackParams = nil;
        loadCallBack(self,localCallBackParams);
    end
end

return BaseLoader;