
local UIGiftFriendWrapUIEx = class("UIGiftFriendWrapUIEx",BaseWrapContentUI);

function UIGiftFriendWrapUIEx:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);
    self._context = context;
    self._labelName = wrapItemTrans:Find("LabelName"):GetComponent("UILabel");
    self._labelIntimacy = wrapItemTrans:Find("LabelGood"):GetComponent("UILabel");

    local iconTexture = wrapItemTrans:Find("IconBg/TextureIcon"):GetComponent("UITexture");
    self._iconTexture = iconTexture;
    self._iconSprite = wrapItemTrans:Find("IconBg/SpriteIcon"):GetComponent("UISprite");

    self._loveGo = wrapItemTrans:Find("IconLove/SpriteIcon").gameObject;
    self._toggle = wrapItemTrans:GetComponent("UIToggle");

    self._uiEvent = wrapItemTrans:GetComponent("UIEvent");
    self:InsertUIEvent(self._uiEvent);

end

function UIGiftFriendWrapUIEx:OnRefresh()
    local friend = self._data;

    friend:SetHeadIcon(self._iconTexture,self._iconSprite);

    self._labelName.text = friend:GetRemark();
    local isSelected = self._context.IsFriendSelected(friend);
    self._toggle:Set(isSelected);

    self._labelIntimacy.text = friend:GetIntimacy();
    self._loveGo:SetActive(friend:IsUnrequitedLover());
end

return UIGiftFriendWrapUIEx;