local UIGiftCategoryWrapUIEx = class("UIGiftCategoryWrapUIEx",BaseWrapContentUI);

function UIGiftCategoryWrapUIEx:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._toggle = wrapItemTrans:GetComponent("UIToggle");
    self._labelActive = wrapItemTrans:Find("Active/Name"):GetComponent("UILabel");
    self._labelDeactive = wrapItemTrans:Find("DeActive/Name"):GetComponent("UILabel");
    self._uiEvent = wrapItemTrans:GetComponent("UIEvent");
    self._context = context;

    self:InsertUIEvent(self._uiEvent);
end

function UIGiftCategoryWrapUIEx:OnRefresh()
    local wrapData = self._data;
    local isSelected = self._context:IsCategorySelected(wrapData);
    self._toggle:Set(isSelected);
    self._labelActive.text = GiftMgr.GetCategoryName(wrapData.id);
    self._labelDeactive.text = GiftMgr.GetCategoryName(wrapData.id);
end

return UIGiftCategoryWrapUIEx;