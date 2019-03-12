local TitlePlayerRenderPanel = class("TitlePlayerRenderPanel")

function TitlePlayerRenderPanel:ctor(ui)
    local path = "Offset/Center/ModelPanel";
    self._renderTexture = ui:FindComponent("UITexture",path.."/RenderTexture");
    self._nameLabel = ui:FindComponent("UILabel",path.."/LabelName");
end

function TitlePlayerRenderPanel:OnEnable()
    self._nameLabel.text = UserData.GetName();
    CameraRender.RenderEntity(AllUI.UI_Title,self._renderTexture,UserData.PlayerAtt);
end
function TitlePlayerRenderPanel:OnDisable()
    CameraRender.DeleteEntity(AllUI.UI_Title);
end

function TitlePlayerRenderPanel:OnDrag(delta,id)
    if id == -1 then
        CameraRender.DragEntity(AllUI.UI_Title, delta);
    end
end

return TitlePlayerRenderPanel;