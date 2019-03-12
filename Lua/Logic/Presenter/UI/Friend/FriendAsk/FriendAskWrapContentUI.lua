local FriendAskWrapContentUI = class("FriendAskWrapContentUI",BaseWrapContentUI);

function FriendAskWrapContentUI:ctor(wrapItemTrans)
    BaseWrapContentUI.ctor(self,wrapItemTrans);
    local iconTexture = wrapItemTrans:Find("IconInfo/HeadBg/TextureIcon"):GetComponent("UITexture");
    self._iconTexture = iconTexture;
    self._iconSprite = wrapItemTrans:Find("IconInfo/HeadBg/SpriteIcon"):GetComponent("UISprite");

    local professionTexture = wrapItemTrans:Find("IconInfo/Profession"):GetComponent("UITexture");
    self._professionTextureLoader = LoaderMgr.CreateTextureLoader(professionTexture);
    self._levelLabel = wrapItemTrans:Find("IconInfo/Level"):GetComponent("UILabel");
    self._labelNick = wrapItemTrans:Find("LabelInfo/LabelNickName"):GetComponent("UILabel");
    self._labelGangster = wrapItemTrans:Find("LabelInfo/LabelGangster"):GetComponent("UILabel");
    self._labelLocation = wrapItemTrans:Find("LabelInfo/LabelLocation"):GetComponent("UILabel");
    self._labelSource = wrapItemTrans:Find("LabelSource"):GetComponent("UILabel");
    self._ignoreEvent = wrapItemTrans:Find("ButtonGrid/ButtonIgnore"):GetComponent("UIEvent");
    self._agreeEvent = wrapItemTrans:Find("ButtonGrid/ButtonAgree"):GetComponent("UIEvent");
    
    self:InsertUIEvent(self._ignoreEvent);
    self:InsertUIEvent(self._agreeEvent);
    self._processGo = wrapItemTrans:Find("ButtonGrid").gameObject;
    self._agreedGo = wrapItemTrans:Find("Agreed").gameObject;
    self._ignoredGo = wrapItemTrans:Find("Ignored").gameObject;
end

function FriendAskWrapContentUI:OnRefresh()

    local player = self._data.player;
    player:SetHeadIcon(self._iconTexture,self._iconSprite);
    --self._professionTextureLoader:LoadObject(player:GetFactionID());

    self._levelLabel.text = player:GetLevel(rid);
    self._labelNick.text = player:GetNickName(rid);
    self._labelGangster.text = player:GetNormalAttr():GetTeamInfo();
    self._labelLocation.text = player:GetNormalAttr():GetCityName();
    self._labelSource.text = self._data.source;
    self._processGo:SetActive(true);
    self._agreedGo:SetActive(false);
    self._ignoredGo:SetActive(false);
end

return FriendAskWrapContentUI;