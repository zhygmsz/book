local PanelAchieveFriendRank = class("PanelAchieveFriendRank");
local WrapUIAchieveFriendRank = require("Logic/Presenter/UI/Achievement/WrapUI/WrapUIAchieveFriendRank");
local function Compare(a,b)
    return false; -- a:GetAchieveStars() > b:GetAchieveStars();
end

local function GetFriendRankList()
    local friendData = FriendMgr.GetAllFriends();
    table.insert( friendData,FriendMgr.GetSelf());

    table.sort(friendData,Compare);
    return friendData;
end

function PanelAchieveFriendRank:GetRank(role)
    for i,player in ipairs(self._wrapData) do
        if role == player then
            return i;
        end
    end
end

function PanelAchieveFriendRank:OnShareClick()
    TipsMgr.TipByFormat("Share My Achievement");
end

function PanelAchieveFriendRank:OnCompareClick(friend)
    TipsMgr.TipByFormat("Compare Achievement With %s",friend:GetRemark());
end

function PanelAchieveFriendRank:OnIconClick(friend)
    UI_Shortcut_Player.ShowPlayer(friend);
end

function PanelAchieveFriendRank:ctor(ui,path)
    self._rootGo = ui:Find(path).gameObject;
    self._wrapTable = BaseWrapContentEx.new(ui,path.."/ScrollView",8,WrapUIAchieveFriendRank,1,self);
    self._wrapTable:SetUIEvent(2010,5,{self.OnIconClick,self.OnCompareClick,self.OnShareClick},self);
    local selfTrans = ui:Find(path.."/WrapItemSelf");
    self._selfItem = WrapUIAchieveFriendRank.new(selfTrans,self);
    self._selfItem:SetOnClick(nil,nil,2000);
end

function PanelAchieveFriendRank:GetRootGo()
    return self._rootGo;
end
function PanelAchieveFriendRank:OnEnable()
    self._rootGo:SetActive(true);
    local friendData = GetFriendRankList();
    self._wrapData = friendData;
    self._wrapTable:ResetWithData(friendData);
    local selfData = FriendMgr.GetSelf();
    self._selfItem:DispatchData(selfData);
    self._selfItem:OnRefresh();
end

function PanelAchieveFriendRank:OnClick(id)
    if not self._rootGo.activeInHierarchy then
        return;
    end
    if id == 2000 then--分享
        self:OnShareClick();
    else
        self._wrapTable:OnClick(id);
    end
end

return PanelAchieveFriendRank;