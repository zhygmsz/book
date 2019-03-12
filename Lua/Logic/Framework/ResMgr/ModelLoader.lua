ModelLoader = class("ModelLoader",TransformLoader)

function ModelLoader:ctor()
    TransformLoader.ctor(self);
    self._loadHelpList = self._loadHelpList or GameCore.EntityModel.GetHelpList();
    self._loadScript = self._loadScript or GameCore.EntityModel.GetHelpLoader();
    self._LoadCallBack = self._LoadCallBack or GameCore.EntityModel.OnModelLoad(self.class.OnLoadFinish,self);
    self._replaceCallBack = self._replaceCallBack or GameCore.EntityModel.OnModelReplace(self.class.OnReplaceBegin,self);
    self._loadScript:InitCallBack(self._LoadCallBack,self._replaceCallBack);
end

function ModelLoader:dtor()
    self._renderOffScreen = nil;
    self._loadedObject = nil;
    self._replaceCallBackLua = nil;
    self._replaceObjLua = nil;
    TransformLoader.dtor(self);
    --清空模型资源
    if not tolua.isnull(self._loadScript) then self._loadScript:UnloadAssets(); end
end

function ModelLoader:LoadObject(modelID,controllerID,isSelf,bodyIDs,animIDs,loadCallBack,loadCallParams)
    --加载新的模型资源
    self._loadCallBack = loadCallBack;
    self._loadCallBackParams = loadCallParams;
    self._loadPriority = isSelf and 1 or 0;
    self._loadScript:LoadBaseAssets(modelID,controllerID or -1,self._loadPriority);
    if bodyIDs then
        self._loadHelpList:Clear();
        for _,bodyID in ipairs(bodyIDs) do self._loadHelpList:Add(bodyID); end
        self._loadScript:LoadBodyAssets(self._loadPriority,self._loadHelpList);
    end
    if animIDs then
        self._loadHelpList:Clear();
        for _,animID in ipairs(animIDs) do self._loadHelpList:Add(animID); end
        self._loadScript:LoadAnimAssets(self._loadPriority,self._loadHelpList);
    end
end

function ModelLoader:OnLoadFinish(object)
    TransformLoader.OnLoadFinish(self,nil,object);
    self:OnPostLoad();
    if self._renderOffScreen and self._loadedObject then GameUtil.GameFunc.SetRenderOffScreen(self._loadedObject); end
end

function ModelLoader:OnReplaceBegin()
    if self._replaceCallBackLua then
        self._replaceCallBackLua(self._replaceObjLua);
    end
end

function ModelLoader:GetBone(boneName)
    if self._loadedObject then return self._loadScript:GetBone(boneName); end
end

function ModelLoader:SetAnimationMode(alwaysAnimate)
    if self._loadScript then self._loadScript:SetAnimationMode(alwaysAnimate); end
end

function ModelLoader:SetRenderOffScreen()
    self._renderOffScreen = true;
    if self._loadedObject then GameUtil.GameFunc.SetRenderOffScreen(self._loadedObject); end
end

function ModelLoader:SetReplaceCallBack(callBack,callObj)
    self._replaceCallBackLua = callBack;
    self._replaceObjLua = callObj;
end

return ModelLoader;