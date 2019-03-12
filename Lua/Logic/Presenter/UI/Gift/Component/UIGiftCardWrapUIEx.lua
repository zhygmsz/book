
local UIGiftCardWrapUIEx = class("UIGiftCardWrapUIEx",BaseWrapContentUI);

function UIGiftCardWrapUIEx:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._context = context;
    self._iconSprite = wrapItemTrans:GetComponent("UISprite");
    self._toggle = wrapItemTrans:GetComponent("UIToggle");

    self._uiEvent = wrapItemTrans:GetComponent("UIEvent");
    self:InsertUIEvent(self._uiEvent);
end

function UIGiftCardWrapUIEx:OnRefresh()
    local card = self._data;
    --self._iconSprite.spriteName = card:GetIconName();
    local isSelected = self._context.IsCardSelected(card);
    self._toggle:Set(isSelected);

end

return UIGiftCardWrapUIEx;