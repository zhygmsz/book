local Base = require("Logic/Presenter/UI/Friend/Main/UIPanelChat/PanelChatTableBase")
local PanelChatNPC = class("PanelChatNPC",Base);

function PanelChatNPC:ctor(ui,path,basicPath,inputPath)
    self.super.ctor(self,ui,path,basicPath,inputPath);

end

function PanelChatNPC:OnEnable(id)
    self.super.OnEnable(self);

    self._inputGo:SetActive(false);
    self._basicPrivateGo:SetActive(true);
end

function PanelChatNPC:OnClick(id)
    if not self._rootGo.activeSelf then
        return;
    end

    if id == 40 then
        --Clear();
    end
end

return PanelChatNPC;


