local WrapUIAchieveItemFold = class("WrapUIAchieveItemFold",UICommonCollapseWrapUI);

function WrapUIAchieveItemFold:ctor(wrapItemTrans,baseEventID,context)

    local subItemTran = wrapItemTrans:Find("Fold");
    self._bgSprite = wrapItemTrans:GetComponent("UISprite");
    self._gameObject = subItemTran.gameObject;
    self._context = context;
    self._starLabel = subItemTran:Find("Icon/Label"):GetComponent("UILabel");
    self._nameLabel = subItemTran:Find("InfoTable/LabelTitle"):GetComponent("UILabel");
    self._desLabel = subItemTran:Find("InfoTable/LabelDes"):GetComponent("UILabel");

    self._hasAwardGo = subItemTran:Find("SpriteAwardBg").gameObject;
    self._hasAchievedGo  = subItemTran:Find("SpriteAchieved").gameObject;
    self._shareGo = subItemTran:Find("ButtonShare").gameObject;
    self._achieveGo = subItemTran:Find("ButtonAchieve").gameObject;
    self._progressGo = subItemTran:Find("SpriteProgress").gameObject;

    self._propressLabel = subItemTran:Find("SpriteProgress/Label"):GetComponent("UILabel");
    self._progressSprite = subItemTran:Find("SpriteProgress/SpriteProgress"):GetComponent("UISprite");

    self._closeUIEvent = wrapItemTrans:GetComponent("UIEvent");
    self._shareUIEvent = subItemTran:Find("ButtonShare"):GetComponent("UIEvent");
    self._achieveUIEvent = subItemTran:Find("ButtonAchieve"):GetComponent("UIEvent");
    self._awardUIEvent = subItemTran:Find("SpriteAwardBg"):GetComponent("UIEvent");

    self._closeUIEvent.id = baseEventID+0;
    self._shareUIEvent.id = baseEventID+1;
    self._achieveUIEvent.id = baseEventID+2;
    self._awardUIEvent.id = baseEventID+3;
end

function WrapUIAchieveItemFold:RefreshBg()
    self._bgSprite.height = 94;
end

function WrapUIAchieveItemFold:OnRefresh()
    local item = self._wrapData;
    self._hasAwardGo:SetActive(item:HasAward());
    self._hasAchievedGo:SetActive(item:IsFinished());
    self._shareGo:SetActive(item:HasFinalFinish());
    self._achieveGo:SetActive(item:NextToReward());
    self._progressGo:SetActive(not item:IsFinished());

    self._starLabel.text = item:GetStaticStar();
    self._nameLabel.text = item:GetName();
    self._desLabel.text = item:GetDesc();

    local moreInfo = item:GetMoreDetails();
    if not item:IsFinished() then
        self._progressSprite.fillAmount = item:GetProgress();
        self._propressLabel.text = string.format("%s/%s",item:GetProgress(), item:GetTotalProgress());
    end
    self:RefreshBg();
end

function WrapUIAchieveItemFold:OnClick(bid)
    if bid == 0 then
        self._context:OnItemClick(self._wrapData);
    elseif bid == 1 then
        self._context:OnShareClick(self._wrapData);
    elseif bid == 2 then
        self._context:OnRewardClick(self._wrapData);
    elseif bid == 3 then
        self._context:OnRewardDescClick(self._wrapData);
    end
end
return WrapUIAchieveItemFold;