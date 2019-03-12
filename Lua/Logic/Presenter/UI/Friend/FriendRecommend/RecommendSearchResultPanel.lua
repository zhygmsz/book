local RecommendSearchResultPanel = class("RecommendSearchResultPanel");
local RecommendSearchWrapContentUI = require("Logic/Presenter/UI/Friend/FriendRecommend/RecommendSearchWrapContentUI");
function RecommendSearchResultPanel:Show()

    -- if self._showState then
    --     return;
    -- end
    self._panelGo:SetActive(true);
    self._showState = true;

end

function RecommendSearchResultPanel:UnShow()
    -- if not self._showState then
    --     return;
    -- end
    self._panelGo:SetActive(false);
    self._showState = false;
end

function RecommendSearchResultPanel:DeletePlayer(player)
    for i=1,#self._wrapDatas do
        if self._wrapDatas[i] == player then
            table.remove(self._wrapDatas,i);
            break;
        end
    end
    self._wrapTable:ResetWithPosition(self._wrapDatas);
end

--添加好友
function RecommendSearchResultPanel:OnWrapUIClick(player)
    FriendMgr.RequestAskAddFriend(player,self.DeletePlayer,self);
end

function RecommendSearchResultPanel:ctor(uiFrame,context)
    self._context = context;
    local path = "Offset/Bg/SearchResultPanel";

    self._wrapTable = BaseWrapContentEx.new(uiFrame,path.."/Scroll View",8,RecommendSearchWrapContentUI);
    self._wrapTable:SetUIEvent(10000,5,{self.OnWrapUIClick},self);

    -- self._wrapTable = BaseWrapContent.new(uiFrame,path.."/Scroll View",8,RecommendSearchWrapContentUI);
    -- self._itemDataHelper = WrapContentDataHelper.new(10000,5);
    self._panelGo = uiFrame:Find(path).gameObject;
    self._events = {};
    self._showState = true;
end

function RecommendSearchResultPanel:NewResult()
    local players = FriendRecommendMgr.GetSearchResults();
    self._wrapDatas = players;
    self._wrapTable:ResetWithData(players);
end

function RecommendSearchResultPanel:OnEnable(uiFrame)
    self:NewResult();
end

function RecommendSearchResultPanel:OnClick(id)
    if not self._panelGo.activeInHierarchy then
        return;
    end
    if id >= 10000 then
        self._wrapTable:OnClick(id);
    end
end

function RecommendSearchResultPanel:OnDisable(uiFrame)
    self._panelGo:SetActive(true);
    self._wrapTable:ReleaseData();
end

function RecommendSearchResultPanel:OnDestroy(uiFrame)
    self._context = nil;
    self._searchInput = nil;
    self._searchDelegate = nil;
    self._wrapTable = nil;
end

return RecommendSearchResultPanel;