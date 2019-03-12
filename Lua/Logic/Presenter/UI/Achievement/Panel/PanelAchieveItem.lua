local PanelAchieveItem = class("PanelAchieveItem");

function PanelAchieveItem:GetUIName(data)
    return  data == self._selectedItem and "WrapUIAchieveItemUnfold" or "WrapUIAchieveItemFold";
end
function PanelAchieveItem:GetUISize(data)
    return  data == self._selectedItem and 170 or 100;
end

function PanelAchieveItem:ctor(ui,path)
    self._rootGo = ui:Find(path).gameObject;
    local WrapUIAchieveItemFold = require("Logic/Presenter/UI/Achievement/WrapUI/WrapUIAchieveItemFold");
    local WrapUIAchieveItemUnfold = require("Logic/Presenter/UI/Achievement/WrapUI/WrapUIAchieveItemUnfold");
    local wrapUIs = {WrapUIAchieveItemFold,WrapUIAchieveItemUnfold};
    self._collapseTable = UICommonCollapseTableWrap.new(ui,path.."/ScrollView",10,wrapUIs,10000,5,self);
    self._collapseTable:RegisterData("AchieveItem",self.GetUIName,self.GetUISize,self);
end

function PanelAchieveItem:GetRootGo()
    return self._rootGo;
end

function PanelAchieveItem:OnEnable(dataList)
    self._rootGo:SetActive(true);
    self._tableDataList = dataList;

    self._selectedItem = nil;
    self._collapseTable:ResetAll(self._tableDataList);
end

function PanelAchieveItem:OnItemClick(data)
    if  self._selectedItem == data then
        self._selectedItem = nil;
    else
        self._selectedItem = data
    end
    
    local showIndex = 1;
    for i = 1, #self._tableDataList do
        if self._tableDataList[i] == data then
            showIndex = i;
            break;
        end
    end
    
    self._collapseTable:ResetAllWithShowData(self._tableDataList,showIndex);
end

function PanelAchieveItem:OnUpateItem(item)
    self._collapseTable:RefreshUIWithData(item);
end

function PanelAchieveItem:OnShareClick(item)
    TipsMgr.TipByFormat("分享到世界，帮会，门派，新手频道");
end
function PanelAchieveItem:OnRewardClick(item)
    AchievementMgr.RequestGetReward(item:GetID());
end
function PanelAchieveItem:OnRewardDescClick(item)
    TipsMgr.TipByFormat("奖励");
end

function PanelAchieveItem:OnClick(id)
    if not self._rootGo.activeInHierarchy then return; end
    self._collapseTable:OnClick(id);
end

return PanelAchieveItem