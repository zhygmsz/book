local UIGiftBagWrapUIEx = class("UIGiftBagWrapUIEx",BaseWrapContentUI);

function UIGiftBagWrapUIEx:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._labelCount = wrapItemTrans:Find("LabelCount"):GetComponent("UILabel");
    local iconTexture = wrapItemTrans:Find("TextureIcon"):GetComponent("UITexture");
    self._iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);
    self._iconTexture = iconTexture;
    self._bellGo = wrapItemTrans:Find("SpriteBell").gameObject;
    self._deleteGo = wrapItemTrans:Find("BtnDelete").gameObject;

    self._uiEvent = wrapItemTrans:GetComponent("UIEvent");
    self._delUIEvent = wrapItemTrans:Find("BtnDelete"):GetComponent("UIEvent");
    self._context = context;
    self:InsertUIEvent(self._uiEvent);
    self:InsertUIEvent(self._delUIEvent);
end

function UIGiftBagWrapUIEx:OnRefresh()
    local gift = self._data;
    GameLog.Log("UIGiftBagWrapUIEx OnRefresh %s",gift:GetName());
    self._iconTextureLoader:LoadObject(gift:GetItemIcon());
    local selectCount = self._context.GetGiftSelectCount(gift);
    local totalCount = gift:GetItemCount();
    self._labelCount.text = string.format("%s/%s",selectCount,totalCount);
    self._bellGo:SetActive(gift:IsWithHorn());
    self._deleteGo:SetActive(selectCount > 0);
end


return UIGiftBagWrapUIEx;