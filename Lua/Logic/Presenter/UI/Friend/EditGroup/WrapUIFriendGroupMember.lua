local WrapUIFriendGroupMember = class("WrapUIFriendGroupMember",BaseWrapContentUI);

function WrapUIFriendGroupMember:ctor(wrapItemTrans,context)
    BaseWrapContentUI.ctor(self,wrapItemTrans,context);

    self._iconTexture = wrapItemTrans:Find("IconInfo/HeadBg/IconTexture"):GetComponent("UITexture");
    self._iconSprite = wrapItemTrans:Find("IconInfo/HeadBg/IconSprite"):GetComponent("UISprite");
    self._levelLabel = wrapItemTrans:Find("IconInfo/Level"):GetComponent("UILabel");
    self._nickName = wrapItemTrans:Find("LabelInfo/LabelNickName"):GetComponent("UILabel");
    self._intimacy = wrapItemTrans:Find("LabelInfo/LabelGood"):GetComponent("UILabel");--30
    self._inGroupGo = wrapItemTrans:Find("ToggleSelect/Label").gameObject;
    self._selectedGo = wrapItemTrans:Find("ToggleSelect/Active").gameObject;
    self._uieventID = wrapItemTrans:GetComponent("UIEvent");
    self:InsertUIEvent(self._uieventID);
end

function WrapUIFriendGroupMember:OnRefresh()
    local player = self._data;
    self._gameObject:SetActive(true);
    self._nickName.text = player:GetRemark();
    self._intimacy.text = WordData.GetWordStringByKey("friend_intimacy_%s",player:GetIntimacy());--好感度:999
    self._levelLabel.text = player:GetLevel();
    player:SetHeadIcon(self._iconTexture,self._iconSprite);
    local isInGroup = self._context.IsPlayerInGroup(player);
    self._inGroupGo:SetActive(isInGroup);
    self._selectedGo:SetActive(self._context.IsPlayerSelected(player));
end

return WrapUIFriendGroupMember;