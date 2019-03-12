
local TitleWrapUIContentBase  = class("TitleWrapUIContentBase",UICommonCollapseWrapUI);

function TitleWrapUIContentBase:ctor(root,baseEvent,context)
    local subItemTran = root:Find("Classify");
    self._gameObject = subItemTran.gameObject;
    self._widget = subItemTran:GetComponent("UIWidget");
    self._context = context;
    self._selectedNameLabel = subItemTran:Find("SpriteSelected/Title"):GetComponent("UILabel");
    self._notselectedNameLabel = subItemTran:Find("SpriteNotSelected/Title"):GetComponent("UILabel");
    self._selectedGo = subItemTran:Find("SpriteSelected").gameObject;
    self._notselectedGo = subItemTran:Find("SpriteNotSelected").gameObject;
    self._openSprite = subItemTran:Find("SpriteOpen");
    self._openGo = subItemTran:Find("SpriteOpen").gameObject;
    subItemTran:GetComponent("UIEvent").id = baseEvent;
    self._subItemTran = subItemTran;
end

function TitleWrapUIContentBase:OnRefresh(name,selected)
    self._selectedNameLabel.text = name;
    self._notselectedNameLabel.text = name;
    self._selectedGo:SetActive(selected);
    self._notselectedGo:SetActive(not selected);
end

return TitleWrapUIContentBase;