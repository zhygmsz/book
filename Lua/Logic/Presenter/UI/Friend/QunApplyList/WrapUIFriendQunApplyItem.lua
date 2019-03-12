local WrapUIFriendQunApplyItem = class("WrapUIFriendQunApplyItem",BaseWrapContentUI);

function WrapUIFriendQunApplyItem:ctor(subItemTran,context)
    BaseWrapContentUI.ctor(self,subItemTran,context);

    self._context = context;
    self._iconApplyTexture = subItemTran:Find("SpriteApplyIcon/Texture"):GetComponent("UITexture");
    self._iconApplySprite = subItemTran:Find("SpriteApplyIcon/Sprite"):GetComponent("UISprite");

    self._nameApplyLabel = subItemTran:Find("LabelApplyName"):GetComponent("UILabel");
    self._levelApplyLabel = subItemTran:Find("LabelApplyLevel"):GetComponent("UILabel");
    self._iconInviteTexture = subItemTran:Find("SpriteInviterIcon/Texture"):GetComponent("UITexture");
    self._iconInviteSprite = subItemTran:Find("SpriteInviterIcon/Sprite"):GetComponent("UISprite");

    self._nameInviteLabel = subItemTran:Find("LabelInviterName"):GetComponent("UILabel");
    self._selectedGo = subItemTran:Find("Option/Active").gameObject;
    self._UIEvent = subItemTran:GetComponent("UIEvent");

    self:InsertUIEvent(self._UIEvent);

end

function WrapUIFriendQunApplyItem:OnRefresh()
    local item = self._data;
    local applier = item.applier;
    local inviter = item.inviter;

    applier:SetHeadIcon(self._iconApplyTexture,self._iconApplySprite);
    self._nameApplyLabel.text = applier:GetRemark();
    self._levelApplyLabel.text = applier:GetLevel();

    inviter:SetHeadIcon(self._iconInviteTexture,self._iconInviteSprite);
    self._nameInviteLabel.text = inviter:GetMenpaiID();

    local selected = self._context.IsItemSelected(item);
    self._selectedGo:SetActive(selected);
end

return WrapUIFriendQunApplyItem;