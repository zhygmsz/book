local WrapUIChatLabelNotice  = class("WrapUIChatLabelNotice",UICommonCollapseWrapUI);

function WrapUIChatLabelNotice:ctor(root,baseEventID,ui)
    local subItemTran = root:Find("LabelNotice");

    self._rawLabel = subItemTran:Find("Label"):GetComponent("UILabel");

    self._widget = subItemTran:GetComponent("UIWidget");
    self._gameObject = subItemTran.gameObject;

    self._contentBgWidget = subItemTran:Find("ContentBg"):GetComponent("UIWidget");
end

function WrapUIChatLabelNotice:OnRefresh()
    if not self._isActive then GameLog.Log("%s is not active", self.__cname);return; end
    local data = self._wrapData;
    local content = data:GetContent();
    self._rawLabel.text = content;

    self._widget.height = self._rawLabel.height+10;
    self._widget.width = self._rawLabel.width+10;
end

return WrapUIChatLabelNotice;