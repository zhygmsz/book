local LimeCamera = class("LimeCamera")

function LimeCamera:ctor()
    self._go = UnityEngine.GameObject.New("EffectNode")
    self._go.transform.parent = UIMgr.GetUIRootTransform()

    self._go.transform.localPosition = Vector3.zero
    self._go.transform.localScale = Vector3.one

    self._cameraGO = UnityEngine.GameObject.New("Camera")
    self._cameraGO.transform.parent = self._go.transform;
    self._cameraGO.transform.localPosition = Vector3(0,0,-200);

    self._camera = self._cameraGO:AddComponent(typeof(UnityEngine.Camera)) 

    self._camera.cullingMask = CameraLayer.RenderTextureMaskLayer;
    self._camera.orthographic = true;
    self._camera.orthographicSize = 1;
    self._camera.depth = 200;
    self._camera.nearClipPlane = -1;
    self._camera.farClipPlane = 40;	
    self._camera.allowHDR = false;
    self._camera.allowMSAA = false;
    self._camera.clearFlags = UnityEngine.CameraClearFlags.SolidColor;
    self._camera.backgroundColor = UnityEngine.Color.New(0, 0, 0, 0)
end

function LimeCamera:Creat()
    local vec = UIMgr.ScreenRealSize();

    if self._renderTexture == nil then
        self._renderTexture = UnityEngine.RenderTexture.GetTemporary(vec.x, vec.y, 0);
    end

    self._camera.targetTexture = self._renderTexture;
end

function LimeCamera:Destory()
    if self._renderTexture then
        self._renderTexture:Release();
        self._renderTexture = nil;
    end

    if self._go then
        UnityEngine.GameObject.Destroy(self._go);
        self._go = nil;
    end

    if self._camera then
        self._camera.targetTexture = nil;
        self._camera = nil;
    end

    if self._effectLoader then
        LoaderMgr.DeleteLoader(self._effectLoader)
        self._effectLoader = nil
    end
end

function LimeCamera:AddEffect()
    local resId = ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_Shihui_eff.prefab")
    local effectCanve = UnityEngine.GameObject.Find("EffectNode")
    self._effectLoader = LoaderMgr.CreateEffectLoader()
    self._effectLoader:LoadObject(resId)
    self._effectLoader:SetParent(effectCanve.transform)
    self._effectLoader:SetLocalPosition(Vector3.zero)
    self._effectLoader:SetLocalScale(Vector3.one)
    self._effectLoader:SetLocalRotation(UnityEngine.Quaternion.identity)
    self._effectLoader:SetActive(true)
    self._effectLoader:SetSortOrder(1000)
    self._effectLoader:SetLayer(CameraLayer.RenderTextureLayer)
end

function LimeCamera:GetRT()
    return self._renderTexture
end

function LimeCamera:StopCamera()
    self._camera.enabled = false
end

return LimeCamera