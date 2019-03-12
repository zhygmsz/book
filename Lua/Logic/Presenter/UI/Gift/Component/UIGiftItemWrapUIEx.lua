local UIGiftItemWrapUIEx = class("UIGiftItemWrapUIEx",BaseWrapContentUI);

function UIGiftItemWrapUIEx:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._labelCount = wrapItemTrans:Find("LabelCount"):GetComponent("UILabel");
    self._iconSprite = wrapItemTrans:Find("SpriteIcon"):GetComponent("UISprite");
    self._bellGo = wrapItemTrans:Find("SpriteBell").gameObject;

    self._uiEvent = wrapItemTrans:GetComponent("UIEvent");

    self._context = context;
    self:InsertUIEvent(self._uiEvent);
end

function UIGiftItemWrapUIEx:OnRefresh()
    local gift = self._data;
    GameLog.Log("UIGiftItemWrapUIEx OnRefresh %s",gift:GetName());
    self._iconSprite.spriteName = gift:GetItemIconName();
    local selectCount = self._context.GetGiftSelectCount(gift);
    self._labelCount.text = string.format("%s",selectCount);
    self._bellGo:SetActive(gift:IsWithHorn());
end


return UIGiftItemWrapUIEx;