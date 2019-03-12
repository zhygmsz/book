local UIAIPetClothCategoryWrapUI = class("UIAIPetClothCategoryWrapUI",BaseWrapContentUI);

function UIAIPetClothCategoryWrapUI:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);

    self._toggle = wrapItemTrans:GetComponent("UIToggle");
    self._labelActive = wrapItemTrans:Find("Active/Name"):GetComponent("UILabel");
    self._labelDeactive = wrapItemTrans:Find("DeActive/Name"):GetComponent("UILabel");
    local uiEvent = wrapItemTrans:GetComponent("UIEvent");
    self:InsertUIEvent(uiEvent);
end

function UIAIPetClothCategoryWrapUI:OnRefresh()
    local part = self._data;
    local isSelected = self._context.GetSelectedCategory();
    isSelected = isSelected and isSelected == part;
    self._toggle:Set(isSelected);
    self._labelActive.text = AIPetMgr.GetClothesCategoryName(part);
    self._labelDeactive.text = AIPetMgr.GetClothesCategoryName(part);
end


return UIAIPetClothCategoryWrapUI;