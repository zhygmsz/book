local RecommendBasicPanel = class("RecommendBasicPanel");

function RecommendBasicPanel:SearchPlayer()
    
    local length = self._searchInput:GetValueLength();

    if length==0 then return; end
    --     self._context.ShowRecommend();
        
    -- else
    local inputStr = self._searchInput.value;
    self._inputStr = inputStr;
    FriendRecommendMgr.RequestSearchPlayer(inputStr);
    self._context.ShowSearchResult();
    --end
end
function RecommendBasicPanel:OnInputChange(force)
    local inputStr = self._searchInput.value;
    if not inputStr or inputStr == "" then
        self._context.ShowRecommend();
    end
end


function RecommendBasicPanel:ctor(uiFrame,context)
    self._context = context;
    local searchInput = uiFrame:FindComponent("LuaUIInput","Offset/Bg/Basic/SearchInput/InputName");
    self._searchInput = searchInput;
    self._searchDelegate = nil;
end

function RecommendBasicPanel:OnEnable(uiFrame)
    local function AutoSearch()
        self:OnInputChange();
    end
    self._searchDelegate = EventDelegate.New(AutoSearch);
    self._searchInput.onChange:Add(self._searchDelegate);
end

function RecommendBasicPanel:OnClick(id)
    self:SearchPlayer(true);
end

function RecommendBasicPanel:OnDisable(uiFrame)
    self._searchInput.onChange:Remove(self._searchDelegate);
    self._searchDelegate = nil;
end

function RecommendBasicPanel:OnDestroy(uiFrame)
    self._context = nil;
    self._searchInput = nil;
    self._searchDelegate = nil;
end

return RecommendBasicPanel;