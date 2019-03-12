RenderComponent = class("RenderComponent",EntityComponent);

function RenderComponent:ctor(...)
    EntityComponent.ctor(self,...);
    self._renders = { RenderCamera.new(self), RenderLight.new(self), RenderPostProcess.new(self)};
    self._cameraData = {};
    self._cameraData.depth = nil;
    self._cameraData.size = nil;
    self._cameraData.parent = nil;
    self._cameraData.localPosition = nil;
    self._cameraData.localRotation = nil;
    self._cameraData.uiTexture = nil;
end

function RenderComponent:OnRender(uiTex,renderID)
    --立绘显示信息
    local renderInfoData = RenderInfoData.GetRenderInfo(renderID or 1);
    if not renderInfoData then renderInfoData = RenderInfoData.GetRenderInfo(1); end
    --立绘摄像机数据
    self._cameraData.depth = -10;
    self._cameraData.size = renderInfoData.renderCameraSize;
    self._cameraData.parent = self._entity:GetModelComponent():GetEntityRoot();
    self._cameraData.localPosition = Vector3(renderInfoData.renderCameraOffsetX,renderInfoData.renderCameraOffsetY,renderInfoData.renderCameraOffsetZ);
    self._cameraData.localRotation = Quaternion.Euler(renderInfoData.renderCameraEulerX,renderInfoData.renderCameraEulerY,renderInfoData.renderCameraEulerZ);
    self._cameraData.uiTexture = uiTex;
    self._cameraData.uiTexture.width = renderInfoData.renderTextureSize;
    self._cameraData.uiTexture.height = renderInfoData.renderTextureSize;
    --刷新显示
    for _,render in ipairs(self._renders) do
        render:OnRender(self._cameraData);
    end
end

function RenderComponent:OnDrag(delta)
    for _,render in ipairs(self._renders) do
        render:OnDrag(delta);
    end
end

function RenderComponent:OnDestroy()
    for _,render in ipairs(self._renders) do
        render:OnDestroy();
    end
end

return RenderComponent;