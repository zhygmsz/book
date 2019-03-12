RenderCamera = class("RenderCamera")

function RenderCamera:ctor(renderComponent)
    self._renderComponent = renderComponent;
    --UI模型渲染摄像机根结点
    self._cameraRootObj = UnityEngine.GameObject.New("RenderCameraRoot");
    self._cameraRootTransform = self._cameraRootObj.transform;
    --UI模型渲染摄像机结点
    self._cameraObj = UnityEngine.GameObject.New("RenderCamera");
    self._cameraTransform = self._cameraObj.transform;
    self._cameraTransform.parent = self._cameraRootTransform;
    --UI模型渲染摄像机组件
    self._camera = self._cameraObj:AddComponent(typeof(UnityEngine.Camera));
    self._camera.clearFlags = UnityEngine.CameraClearFlags.SolidColor;
    self._camera.cullingMask = CameraLayer.RenderTextureMaskLayer;
    self._camera.orthographic = true;
    self._camera.nearClipPlane = -10;
    self._camera.farClipPlane = 10;
    self._camera.allowHDR = false;
    self._camera.allowMSAA = false;
    --拖拽时转动速度
    self._dragSpeed = ConfigData.GetIntValue("model_rotate_speed") or 0.5;
end

function RenderCamera:OnRender(cameraData)
    self._renderTexture = UnityEngine.RenderTexture.GetTemporary(1024,1024,16);
    --摄像机属性
    self._camera.targetTexture = self._renderTexture;
    self._camera.depth = cameraData.depth;
    self._camera.orthographicSize = cameraData.size;
    --摄像机位置
    self._cameraRootTransform.parent = cameraData.parent;
    self._cameraRootTransform.localPosition = Vector3.zero;
    self._cameraRootTransform.localRotation = Quaternion.identity;
    self._cameraTransform.localPosition = cameraData.localPosition;
    self._cameraTransform.localRotation = cameraData.localRotation;
    --打开摄像机
    self._cameraObj:SetActive(true);
    --刷新UI纹理
    self._uiTexture = cameraData.uiTexture;
    self._uiTexture.mainTexture = self._renderTexture;
    NGUITools.MarkParentAsChanged(self._uiTexture.gameObject);
end

function RenderCamera:OnDrag(delta)
    local eul = delta.x * self._dragSpeed + self._cameraRootTransform.eulerAngles.y;
    self._cameraRootTransform.rotation = Quaternion.Euler(0, eul, 0);
end

function RenderCamera:OnDestroy()
    self._cameraObj:SetActive(false);
    UnityEngine.RenderTexture.ReleaseTemporary(self._renderTexture);
    self._renderTexture = nil;
    self._camera.targetTexture = nil;
    self._uiTexture.mainTexture = nil;
end