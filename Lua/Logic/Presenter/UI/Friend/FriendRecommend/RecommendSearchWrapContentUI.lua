local RecommendSearchWrapContentUI = class("RecommendSearchWrapContentUI",BaseWrapContentUI);

function RecommendSearchWrapContentUI:ctor(wrapItemTrans)
    BaseWrapContentUI.ctor(self,wrapItemTrans);
    self._iconTexture = wrapItemTrans:Find("IconInfo/HeadBg/IconTexture"):GetComponent("UITexture");
    self._iconSprite = wrapItemTrans:Find("IconInfo/HeadBg/IconSprite"):GetComponent("UISprite");
    self._professionTexture = wrapItemTrans:Find("IconInfo/Profession"):GetComponent("UITexture");
    self._levelLabel = wrapItemTrans:Find("IconInfo/Level"):GetComponent("UILabel");
    self._labelNick = wrapItemTrans:Find("LabelInfo/LabelNickName"):GetComponent("UILabel");
    self._labelGangster = wrapItemTrans:Find("LabelInfo/LabelGangster"):GetComponent("UILabel");
    self._labelLocation = wrapItemTrans:Find("LabelInfo/LabelLocation"):GetComponent("UILabel");
    local askEvent = wrapItemTrans:Find("ButtonAsk"):GetComponent("UIEvent");
    self:InsertUIEvent(askEvent);
end

function RecommendSearchWrapContentUI:OnRefresh()
    local player = self._data;
    player:SetHeadIcon(self._iconTexture,self._iconSprite);
    self._levelLabel.text = player:GetLevel();
    self._labelNick.text = player:GetRemark();
    self._labelGangster.text = player:GetNormalAttr():GetMenpaiName();
    self._labelLocation.text = player:GetCityName();
end

return RecommendSearchWrapContentUI;