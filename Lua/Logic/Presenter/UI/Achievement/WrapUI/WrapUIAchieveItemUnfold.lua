local WrapUIAchieveItemFold = require("Logic/Presenter/UI/Achievement/WrapUI/WrapUIAchieveItemFold");
local WrapUIAchieveItemUnfold = class("WrapUIAchieveItemUnfold",WrapUIAchieveItemFold);

function WrapUIAchieveItemUnfold:ctor(wrapItemTrans,baseEventID,context)
    WrapUIAchieveItemFold.ctor(self,wrapItemTrans,baseEventID,context);
    self._baseGo = self._gameObject;

    local subItemTran = wrapItemTrans:Find("Unfold");
    self._gameObject = subItemTran.gameObject;
    
    self._moreFinishedGo = subItemTran:Find("MoreFinished").gameObject;
    self._moreUnfinishedGo = subItemTran:Find("MoreUnfinished").gameObject;
    self._moreFinishedSprite = subItemTran:Find("MoreFinished/SpriteStar"):GetComponent("UISprite");
    self._moreFinishedLabel = subItemTran:Find("MoreFinished/SpriteStar/Label"):GetComponent("UILabel");
    self._moreFinishTimeLabel = subItemTran:Find("MoreFinished/LabelTime/LabelTime"):GetComponent("UILabel");
    self._moreUnfinishTimeLabel = subItemTran:Find("MoreUnfinished/Label"):GetComponent("UILabel");
end

function WrapUIAchieveItemUnfold:RefreshBg()
    self._bgSprite.height = 164;
end

function WrapUIAchieveItemUnfold:OnRefresh()
    self._baseGo:SetActive(true);
    WrapUIAchieveItemFold.OnRefresh(self);

    local item = self._wrapData;
    local moreInfo = item:GetMoreDetails();
    local finished = item:IsFinished();
    self._moreFinishedGo:SetActive(finished);
    self._moreUnfinishedGo:SetActive(not finished);

    if not finished then
        self._moreUnfinishTimeLabel.text = moreInfo.desc;
    else
        self._moreFinishedLabel.text = moreInfo.desc;
        self._moreFinishTimeLabel.text = moreInfo.finishTime;
        self._moreFinishedSprite.spriteName = moreInfo.iconName
    end
end

return WrapUIAchieveItemUnfold;