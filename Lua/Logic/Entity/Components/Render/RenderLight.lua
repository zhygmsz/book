RenderLight = class("RenderLight")

function RenderLight:ctor(renderComponent)
    self._renderComponent = renderComponent;
    self._lightObj = UnityEngine.GameObject.Find("RenderLight");
    if tolua.isnull(self._lightObj) then
        self._lightObj = UnityEngine.GameObject.New("RenderLight"); 
        self._light = self._lightObj:AddComponent(typeof(UnityEngine.Light));
        self._light.type = UnityEngine.LightType.Directional;
        self._light.intensity = 0.8;
        self._light.cullingMask = CameraLayer.RenderTextureMaskLayer;
        self._light.transform.rotation = Quaternion.Euler(45,145,0);
    end
end

function RenderLight:OnRender(cameraData)
    self._lightObj:SetActive(true);
    self._lightObj.transform.parent = cameraData.parent;
end

function RenderLight:OnDrag(delta)
end

function RenderLight:OnDestroy()
    self._lightObj:SetActive(false);
end