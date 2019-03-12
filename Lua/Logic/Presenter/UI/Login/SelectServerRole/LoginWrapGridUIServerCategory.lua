local LoginWrapGridUIServerCategory = class("LoginWrapGridUIServerCategory",BaseWrapContentUI);

function LoginWrapGridUIServerCategory:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._labelName1 = wrapItemTrans:Find("Deactive/Label"):GetComponent("UILabel");
    self._labelName2 = wrapItemTrans:Find("Active/Label"):GetComponent("UILabel");
    self._isAllRoleGo = wrapItemTrans:Find("SpriteIcon").gameObject;
    self._toggle = wrapItemTrans:GetComponent("UIToggle");
    self._context = context;
    self._event = wrapItemTrans:GetComponent("UIEvent");
    self:InsertUIEvent(self._event);
end

function LoginWrapGridUIServerCategory:OnRefresh()
    local cate = self._data;
    local cname = cate.name;
    self._labelName1.text = cname;
    self._labelName2.text = cname;
    local isSelected = self._context.IsCategorySelected(cate);
    self._toggle.value = isSelected;
    local showRole = not cate.servers;
    self._isAllRoleGo:SetActive(showRole);
end

return LoginWrapGridUIServerCategory;