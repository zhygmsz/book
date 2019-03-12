module("UI_Achievement_Overview",package.seeall);
local PanelAchieveFriendRank = require("Logic/Presenter/UI/Achievement/Panel/PanelAchieveFriendRank");
local PanelAchieveItem = require("Logic/Presenter/UI/Achievement/Panel/PanelAchieveItem");

local mRootGo;
local mGeneralPanel = {};
local mLatestPanel;
local mCommingPanel;
local mRankPanel;

local mToggleGeneral;
local mToggleGroup;

local mOpenPanel;

function Show()
    mRootGo:SetActive(true);
end

function UnShow()
    mRootGo:SetActive(false);
end

function OnUpdateState(item)
    mLatestPanel:OnUpateItem(item);
    mCommingPanel:OnUpateItem(item);
end

function OnClick(go,id)--80<=id<1000
    if not mRootGo.activeSelf then
        return;
    end
    if id < 100 then
        mGeneralPanel.OnClick(go,id);
    else
        mRankPanel:OnClick(id);
        mLatestPanel:OnClick(id);
        mCommingPanel:OnClick(id);
    end
end

function OnCreate(ui)
    local path = "Offset/Center/OverViewPanel";
    local toggles = ui:Find(path.."/Toggles"):GetComponentsInChildren(typeof(UIToggle));
    mRootGo = ui:Find(path).gameObject;
    mGeneralPanel:OnCreate(ui);

    path = "Offset/Center/OverViewPanel/LatestPanel";
    mLatestPanel = PanelAchieveItem.new(ui,path);

    path = "Offset/Center/OverViewPanel/CommingPanel";
    mCommingPanel = PanelAchieveItem.new(ui,path);
    
    path = "Offset/Center/OverViewPanel/RankPanel";
    mRankPanel = PanelAchieveFriendRank.new(ui,path);

    mToggleGroup = UIToggleGroup.new();
    
    mToggleGroup:AddToggleObject(toggles[0],mGeneralPanel:GetRootGo());
    mToggleGroup:AddToggleObject(toggles[1],mLatestPanel:GetRootGo());
    mToggleGroup:AddToggleObject(toggles[2],mCommingPanel:GetRootGo());
    mToggleGroup:AddToggleObject(toggles[3],mRankPanel:GetRootGo());

    mToggleGeneral = toggles[0];
end

function OnEnable()
    mRootGo:SetActive(true);
    mGeneralPanel.OnEnable();

    local latestItems = AchievementMgr.GetLatestAchievements();
    mLatestPanel:OnEnable(latestItems);

    local commingItems = AchievementMgr.GetCommingAchievements();
    mCommingPanel:OnEnable(commingItems);

    mRankPanel:OnEnable();

    --mGeneralPanel:GetRootGo():SetActive(false);
    mLatestPanel:GetRootGo():SetActive(false);
    mCommingPanel:GetRootGo():SetActive(false);
    mRankPanel:GetRootGo():SetActive(false);

    mToggleGeneral.value = true;
    GameEvent.Reg(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_UPDATE_STATE,OnUpdateState);
end

function OnDisable()
    
    GameEvent.UnReg(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_UPDATE_STATE,OnUpdateState);
end

function mGeneralPanel:OnCreate(ui)
    local path = "Offset/Center/OverViewPanel/GeneralPanel";
    local rootGo = ui:Find(path).gameObject;
    local table = ui:FindComponent("UIGrid",path.."/MainCatalogue/ScrollView/Table");
    local itemPrefab = ui:Find(path.."/MainCatalogue/ScrollView/Table/ItemPrefab");

    local totalProgressLabel = ui:FindComponent("UILabel",path.."/SpriteProgressBg/SpriteProgress/Label");
    local totalProgressSprite = ui:FindComponent("UISprite",path.."/SpriteProgressBg/SpriteProgress/SpriteProgress");
    local totalLevelSprite = ui:FindComponent("UISprite",path.."/TextureLevelBg/TextureLevel");
    self.CatalogueIDs = AchievementMgr.GetFrontpageCatalogues();
    local count = #self.CatalogueIDs;
    local function OnItemCreate(item,i)
        local trans = item.transform;
        item.icon = trans:GetComponent("UISprite");
        item.iconTextureLoader = LoaderMgr.CreateTextureLoader(iconTextrue);
        item.progressLabel = trans:Find("SpriteProgress/Label"):GetComponent("UILabel");
        item.progressSprite = trans:Find("SpriteProgress/SpriteProgress"):GetComponent("UISprite");
        item.uiEvent = trans:GetComponent("UIEvent");
    end
    self.itemList = UIUtil.Duplicate(ui,itemPrefab,nil,count,OnItemCreate);
    table:Reposition();

    local Refresh = function()
        for i,id in ipairs(self.CatalogueIDs) do
            local cataInfo = AchievementMgr.GetCatalogueInfo(id);
            local item = self.itemList[i];
            item.icon.spriteName = cataInfo.frontPageIcon;
            local curStar, total = AchievementMgr.GetCatalogueStarInfo(id);
            item.progressLabel.text = string.format("%s/%s",curStar, total);
            item.progressSprite.fillAmount = curStar/total;
            item.uiEvent.id = 80 - 1 + i;
        end
        local current = AchievementMgr.GetFinishedStars();
        local totalCount = AchievementMgr.GetTotalStars();
        totalProgressLabel.text = string.format("%s/%s",current, totalCount);
        local percent = current/totalCount;
        totalProgressSprite.fillAmount = percent;
        local levelInfo = AchievementMgr.GetFinishLevelInfo(current);
        totalLevelSprite.spriteName = levelInfo.iconName;  
    end
    self.OnEnable = function()
        Refresh();
    end
    self.OnClick = function(go,id)--80< id <100
        if not rootGo.activeSelf then
            return;
        end
        id = (id-80);
        if id < 10 then
            id = id + 1;
            UI_Achievement.SelectCatalogue(self.CatalogueIDs[id]);
        end
    end
    self.GetRootGo = function()
        return rootGo;
    end

    return rootGo;
end


return UI_Achievement_Overview;