RenderPostProcess = class("RenderPostProcess")

function RenderPostProcess:ctor(renderComponent)
    self._renderComponent = renderComponent;
    self._renderPostProcessObj = UnityEngine.GameObject.New("RenderPostProcess");
    self._renderPostProcessTransform = self._renderPostProcessObj.transform;
end

function RenderPostProcess:OnRender(cameraData)
    self._renderPostProcessObj:SetActive(true);
    self._renderPostProcessTransform.parent = cameraData.parent;
    self._renderPostProcessTransform.localPosition = Vector3.zero;
    self._renderPostProcessTransform.localRotation = Quaternion.identity;
    self._renderPostProcessTransform.localScale = Vector3.one;
end

function RenderPostProcess:OnDrag(delta)
end

function RenderPostProcess:OnDestroy()
    self._renderPostProcessObj:SetActive(false);
end