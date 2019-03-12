local TitleWrapUIContentItem  = class("TitleWrapUIContentItem",UICommonCollapseWrapUI);

function TitleWrapUIContentItem:ctor(root,baseEvent,context)
    local subItemTran = root:Find("Item");
    self._gameObject = subItemTran.gameObject;
    self._widget = subItemTran:GetComponent("UIWidget");
    self._context = context;
    self._nameLabel = subItemTran:Find("LabelTitle"):GetComponent("UILabel");
    self._inUseGo = subItemTran:Find("SpriteInUse").gameObject;
    self._isArtGo = subItemTran:Find("SpriteArt").gameObject;
    self._sprite = subItemTran:GetComponent("UISprite");
    subItemTran:GetComponent("UIEvent").id = baseEvent;
end

function TitleWrapUIContentItem:OnRefresh()
    local group = self._wrapData;
    local item = group:GetRepresentItem();
    local inUse = TitleMgr.IsItemInUse(item);
    local color = inUse and item:GetColor() or "59493C";
    self._nameLabel.text = string.format("[%s]<%s>[-]",color,item:GetName());
    self._inUseGo:SetActive(inUse);
    self._isArtGo:SetActive(item:IsArt());
    local selected = self._context:IsItemOfficialSelect(group);
    if selected then
        self._sprite.spriteName = "frame_common_youjian04";
    else
        if item:IsOpen() then
            self._sprite.spriteName = "frame_common_youjian01";
        else
            self._sprite.spriteName = "frame_common_youjian02";
        end
    end  
end
function TitleWrapUIContentItem:OnClick(bid)
    self._context:OnItemOfficialSelect(self._wrapData,self);
end

return TitleWrapUIContentItem;