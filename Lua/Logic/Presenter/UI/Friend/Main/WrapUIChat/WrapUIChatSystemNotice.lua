local WrapUIChatSystemNotice  = class("WrapUIChatSystemNotice",UICommonCollapseWrapUI);

function WrapUIChatSystemNotice:ctor(root,baseEventID,ui)
    local subItemTran = root:Find("SystemNotice");

    --self._rawLabel = subItemTran:Find("Label"):GetComponent("UILabel");

    local contentRoot = root:Find("SystemNotice/Root");
    self._labelWithEmoji = UILabel_WithEmoji.new{uiFrame = ui,maxHeadLineWidth = 480,rootTrans = contentRoot};
    
    subItemTran:GetComponent("UIEvent").id = baseEventID;

    self._widget = subItemTran:GetComponent("UIWidget");
    self._gameObject = subItemTran.gameObject;
    self._trans = subItemTran;
    self._contentBgWidget = subItemTran:Find("ContentBg"):GetComponent("UIWidget");
end

function WrapUIChatSystemNotice:OnRefresh()
    if not self._isActive then GameLog.Log("%s is not active", self.__cname);return; end
    local data = self._wrapData;
    local content = data:GetContent();
    self._labelWithEmoji:UpdateLabel(content);
    local width = self._labelWithEmoji:GetItemWidth();
    local height = self._labelWithEmoji:GetItemHeight();
    self._widget.height = height+30;
    self._widget.width = width;
    local pos = self._trans.localPosition;
    pos.x = -0.5*width;
    self._trans.localPosition = pos;
    self._contentBgWidget.height = height+20;
    self._contentBgWidget.width = width+20;
end

function WrapUIChatSystemNotice:OnClick()
    self._labelWithEmoji:OnClick();
end

return WrapUIChatSystemNotice;