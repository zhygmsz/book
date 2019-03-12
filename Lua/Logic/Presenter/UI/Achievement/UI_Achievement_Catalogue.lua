module("UI_Achievement_Catalogue",package.seeall);
local PanelAchieveItem = require("Logic/Presenter/UI/Achievement/Panel/PanelAchieveItem");
local mRootGo;
local mScrollPanel;
local mTitlePanel = {};

local mCatalogueID;

function OnUpdateState(item)
    mScrollPanel:OnUpateItem(item);
end

function Show(catalogueID)
    mRootGo:SetActive(true);
    if mCatalogueID == catalogueID then
        return;
    end
    mCatalogueID = catalogueID;
    mTitlePanel:Refresh();

    local items = AchievementMgr.GetAchievementList(mCatalogueID);
    mScrollPanel:OnEnable(items);
end

function UnShow()
    mRootGo:SetActive(false);
end

function OnCreate(ui)
    mRootGo = ui:Find("Offset/Center/CataloguePanel").gameObject;

    local path = "Offset/Center/CataloguePanel/offset";
    mScrollPanel = PanelAchieveItem.new(ui,path);

    mTitlePanel:OnCreate(ui);
end

function OnEnable()
    mRootGo:SetActive(true);
    -- if mCatalogueID == catalogueID then
    --     return;
    -- end
    -- mCatalogueID = catalogueID;

    -- mTitlePanel:Refresh();

    -- local items = AchievementMgr.GetAchievementList(mCatalogueID);
    -- mScrollPanel:OnEnable(items);

    GameEvent.Reg(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_UPDATE_STATE,OnUpdateState);
end

function OnDisable()
    mRootGo:SetActive(false);
    GameEvent.UnReg(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_UPDATE_STATE,OnUpdateState);
end

function OnClick(go,id)--id>=10000
    if not mRootGo.activeSelf then
        return;
    end
    mScrollPanel:OnClick(id);
end

function mTitlePanel:OnCreate(ui)
    local path = "Offset/Center/CataloguePanel/offset/Title";
    self._labelTitle = ui:FindComponent("UILabel",path.."/LabelTitle");
    self._labelProgress = ui:FindComponent("UILabel",path.."/LabelProgress");
    self._spriteProgress = ui:FindComponent("UISprite",path.."/SpriteProgress/SpriteProgress");
end
function mTitlePanel:Refresh()
    local catalogueInfo = AchievementMgr.GetCatalogueInfo(mCatalogueID);
    self._labelTitle.text = catalogueInfo.name;
    local curStar, total = AchievementMgr.GetCatalogueStarInfo(mCatalogueID);
    self._labelProgress.text = string.format("%s/%s",curStar,total);
    self._spriteProgress.fillAmount = curStar/total;
end

return UI_Achievement_Catalogue;
