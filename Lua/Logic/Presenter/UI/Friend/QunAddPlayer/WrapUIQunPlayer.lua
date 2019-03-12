local WrapUIQunPlayer  = class("WrapUIQunPlayer",UICommonCollapseWrapUI);
require("Logic/Presenter/UI/Friend/UI_Shortcut_Player");
function WrapUIQunPlayer:ctor(root,baseEventID,context)
    self.super.ctor(self,root,baseEventID,context);
    local subItemTran = root:Find("Player");
    self._context = context;
    self._gameObject = subItemTran.gameObject;
    self._nickNameLabel = subItemTran:Find("LabelNick"):GetComponent("UILabel");--
    self._intimacyLabel = subItemTran:Find("LabelIntimacy"):GetComponent("UILabel");--
    self._levelLabel = subItemTran:Find("LabelLevel"):GetComponent("UILabel");--
    local iconTexture = subItemTran:Find("SpriteIcon/Texture"):GetComponent("UITexture");--
    --self._iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTexture);
    self._iconTexture = iconTexture;
    self._iconSprite = subItemTran:Find("SpriteIcon/Sprite"):GetComponent("UISprite");--
    self._tuGo = subItemTran:Find("SpriteTu").gameObject;--
    self._selectedGo = subItemTran:Find("Option/Active").gameObject;
    --self._spriteAlreadyInGo = subItemTran:Find("SpriteAlreadyIn").gameObject;

    subItemTran:GetComponent("UIEvent").id = baseEventID;

end

function WrapUIQunPlayer:OnRefresh()

    local friend = self._wrapData;
    
    self._nickNameLabel.text = friend:GetRemark();
    self._intimacyLabel.text = friend:GetIntimacy();
    self._levelLabel.text = friend:GetLevel();
    friend:SetHeadIcon(self._iconTexture,self._iconSprite);
    self._tuGo:SetActive((friend:IsMaster() or friend:IsApprentice()));

    local isSelected = self._context.IsFriendSelected(friend);
    self._selectedGo:SetActive(isSelected);
    --self._spriteAlreadyInGo:SetActive(false);

end

function WrapUIQunPlayer:OnClick(bid)
    self._context.OnFriendSelected(self._wrapData,self);
end

return WrapUIQunPlayer;