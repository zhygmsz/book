
local UIPanelChatBase = class("UIPanelChatBase",nil);

function UIPanelChatBase:ctor(ui,path,basicPath,inputPath)
    self._rootGo = ui:Find(path).gameObject;
    self._inputGo = ui:Find(inputPath).gameObject;
    self._basicGo = ui:Find(basicPath).gameObject;
end

function UIPanelChatBase:OnEnable()
    self._rootGo:SetActive(true);
    self._inputGo:SetActive(false);
    self._basicGo:SetActive(false);
end

function UIPanelChatBase:OnDisable()
    self._rootGo:SetActive(false);
end

return UIPanelChatBase;
