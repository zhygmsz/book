TransformLoader = class("TransformLoader",BaseLoader);

function TransformLoader:ctor()
    BaseLoader.ctor(self);
end

function TransformLoader:dtor()
    self._name = nil;
    self._layer = nil;
    self._active = nil;
    self._parent = nil;
    self._localPosition = nil;
    self._position = nil;
    self._forward = nil;
    self._localRotation = nil;
    self._rotation = nil;
    self._localEulerAngles = nil;
    self._eulerAngles = nil;
    self._localScale = nil;
    self._isLocalEffect = nil;
    self._isFullScreen = nil;
    self._go = nil;
    self._transform = nil;
    BaseLoader.dtor(self);
end

function TransformLoader:OnLoadFinish(...)
    BaseLoader.OnLoadFinish(self,...);
    if tolua.isnull(self._loadedObject) then
        GameLog.LogModuleError("LOAD_OBJECT","loaded object is nil");
    else
        self._go = self._loadedObject.gameObject;
        self._transform = self._go.transform;
        self._transform.parent = self._parent;
        self._transform.localScale = self._localScale or Vector3.one;
        --缩放
        if self._isLocalEffect then GameUtil.GameFunc.SetLocalParticleScale(self._go,self._localScale); end
        --名字
        if self._name then self._go.name = self._name; end
        --层级
        if self._layer then GameUtil.GameFunc.SetGameObjectLayer(self._go.transform,self._layer); end
        --渲染顺序
        if self._sortOrder then GameUtil.GameFunc.SetRendererSortOrder(self._go,self._sortOrder); end
        --有父结点则设置局部坐标
        if self._parent then
            if self._forward then
                self._transform.forward = self._forward;
            elseif self._localEulerAngles then
                self._transform.localEulerAngles = self._localEulerAngles;
            elseif self._localRotation then
                self._transform.localRotation = self._localRotation;
            else
                self._transform.localEulerAngles = Vector3.zero;
            end
            self._transform.localPosition = self._localPosition or Vector3.zero;
        else
            if self._forward then
                self._transform.forward = self._forward;
            elseif self._eulerAngles then
                self._transform.eulerAngles = self._eulerAngles;
            elseif self._rotation then
                self._transform.rotation = self._rotation;
            else
                self._transform.eulerAngles = Vector3.zero;
            end
            self._transform.position = self._position or Vector3.zero;
        end
        if self._isFullScreen then GameUtil.GameFunc.SetFullScreenParticle(self._go); end
        --显隐
        self._go:SetActive(false);
        if self._active then self._go:SetActive(true); end
    end
end

function TransformLoader:SetLayer(layer)
    if not layer then return end
    self._layer = layer;
    if not tolua.isnull(self._go) then GameUtil.GameFunc.SetGameObjectLayer(self._go.transform,layer); end
end

function TransformLoader:SetPosition(position)
    if not position then return end
    self._position = position;
    if not tolua.isnull(self._transform) then self._transform.position = position; end
end

function TransformLoader:SetLocalPosition(localPosition)
    if not localPosition then return end
    self._localPosition = localPosition;
    if not tolua.isnull(self._transform) then self._transform.localPosition = localPosition; end
end

function TransformLoader:SetForward(forward)
    if not forward then return end
    self._forward = forward;
    if not tolua.isnull(self._transform) then self._transform.forward = forward; end
end

function TransformLoader:SetRotation(rotation)
    if not rotation then return end
    self._rotation = rotation;
    if not tolua.isnull(self._transform) then self._transform.rotation = rotation; end
end

function TransformLoader:SetLocalRotation(localRotation)
    if not localRotation then return end
    self._localRotation = localRotation;
    if not tolua.isnull(self._transform) then self._transform.localRotation = localRotation; end
end

function TransformLoader:SetEulerAngles(eulerAngles)
    if not eulerAngles then return end
    self._eulerAngles = eulerAngles;
    if not tolua.isnull(self._transform) then self._transform.eulerAngles = eulerAngles; end
end

function TransformLoader:SetLocalEulerAngles(localEulerAngles)
    if not localEulerAngles then return end
    self._localEulerAngles = localEulerAngles;
    if not tolua.isnull(self._transform) then self._transform.localEulerAngles = localEulerAngles; end
end

function TransformLoader:SetLocalScale(localScale,isLocalEffect)
    if not localScale then return end
    self._localScale = localScale;
    if not tolua.isnull(self._transform) then self._transform.localScale = localScale; end
    self._isLocalEffect = isLocalEffect;
    if isLocalEffect and not tolua.isnull(self._go) then GameUtil.GameFunc.SetLocalParticleScale(self._go,self._localScale); end
end

function TransformLoader:SetFullScreen()
    self._isFullScreen = true;
    if not tolua.isnull(self._go) then GameUtil.GameFunc.SetFullScreenParticle(self._go); end
end

function TransformLoader:SetSortOrder(sortOrder)
    if not sortOrder then return end
    self._sortOrder = sortOrder;
    if not tolua.isnull(self._go) then GameUtil.GameFunc.SetRendererSortOrder(self._go,sortOrder); end
end

function TransformLoader:SetParent(parent,resetTransform)
    self._parent = parent;
    if not tolua.isnull(self._transform) then self._transform.parent = parent; end
    if resetTransform then
        self:SetLocalPosition(Vector3.zero);
        self:SetLocalScale(Vector3.one);
        self:SetLocalEulerAngles(Vector3.zero);
    end
end

function TransformLoader:SetActive(active,needReActive)
    self._active = active;
    if not tolua.isnull(self._go) then
        if needReActive then self._go:SetActive(false); end
        self._go:SetActive(active);
    end
end

function TransformLoader:SetName(name)
    self._name = name or "";
    if not tolua.isnull(self._go) then self._go.name = name; end
end

function TransformLoader:SetTransform(parent,localPosition,localScale,localRotation,sortOrder)
    self:SetParent(parent);
    self:SetLocalPosition(localPosition);
    self:SetLocalScale(localScale);
    self:SetLocalRotation(localRotation);
    self:SetSortOrder(sortOrder);
end

return TransformLoader;