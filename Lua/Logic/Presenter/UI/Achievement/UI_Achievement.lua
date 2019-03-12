module("UI_Achievement",package.seeall);
local mMessages;
local mCurrentPanel;
local OverViewPanel = require("Logic/Presenter/UI/Achievement/UI_Achievement_Overview");
local CataloguePanel = require("Logic/Presenter/UI/Achievement/UI_Achievement_Catalogue");
local OPEN_ROTATION = UnityEngine.Quaternion.Euler(0,0,90);
local CLOSE_ROTATION = UnityEngine.Quaternion.Euler(0,0,180);

local Catalogue = {};

local mUI;
function OnCreate(ui)
    mUI = ui;
    Catalogue.OnCreate(ui);
    OverViewPanel.OnCreate(ui);
    CataloguePanel.OnCreate(ui);
end

local function SubPanelOnEnable()

end

function OnEnable(ui)
    --AchievementMgr.SynDynamicInfo();
    Catalogue.OnEnable(ui);
    --SubPanelOnEnable();
    OverViewPanel.OnEnable(ui);
    CataloguePanel.OnEnable(ui);
    ShowOverview();
    --GameEvent.Reg(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_INIT,SubPanelOnEnable);
end

function OnDisable(ui)
    OverViewPanel.OnDisable();
    CataloguePanel.OnDisable();
    --GameEvent.UnReg(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_INIT,SubPanelOnEnable);
end

function OnClick(go,id)
    GameLog.Log("----------Onclick "..go.name.." "..tostring(id));
    if id < 80 then
        if id == 0 then
            UIMgr.UnShowUI(AllUI.UI_Achievement);
        end
    elseif id < 1000 then --通用面板
        OverViewPanel.OnClick(go,id);
    elseif id >= 1000 and id < 2000 then
        Catalogue.OnClick(go,id);
    elseif id >= 2000 and id < 5000 then -- 好友条目
        OverViewPanel.OnClick(go,id);
    elseif id>=10000 then
        mCurrentPanel.OnClick(go,id);--成就条目
    end
end

function ShowOverview()
    CataloguePanel.UnShow();
    OverViewPanel.Show();
    mCurrentPanel = OverViewPanel;
end

function ShowCatalogue(cataID)
    CataloguePanel.Show(cataID);
    OverViewPanel.UnShow();
    Catalogue.Show(cataID);
    mCurrentPanel = CataloguePanel;
end

function SelectCatalogue(cataID)
    ShowCatalogue(cataID)
end

function Catalogue.OnCreate(ui)
    local self = {};--私有数据
    local path = "Offset/Left/CatalogueScrollView";
    self.firstTable = ui:FindComponent("UITable", path.."/TableFirstLevel");
    local firstPrefab = ui:Find(path.."/TableFirstLevel/Prefab");
    self.secondTable = ui:FindComponent("UITable", path.."/TableSecondLevel");
    self.secondTrans = ui:Find(path.."/TableSecondLevel");
    self.secondGo = self.secondTrans.gameObject;
    local secondPrefab = ui:Find(path.."/TableSecondLevel/Prefab");
    local OnFirstItemCreate = function(item,i)
        local notSelectTrans = item.transform:Find("SpriteNotSelected");
        item.notSelectGo = notSelectTrans.gameObject;
        item.notSelectLabel = notSelectTrans:Find("Title"):GetComponent("UILabel"); 
        local selectTrans = item.transform:Find("SpriteSelected");
        item.selectedGo = selectTrans.gameObject;
        item.selectedLabel = selectTrans:Find("Title"):GetComponent("UILabel");

        item.openSprite = item.transform:Find("SpriteOpen");

        item.uiEvent = item.transform:GetComponent("UIEvent");

        item.uiEvent.id = 1000 + (i-1)*100 + 0;
        item.notSelectLabel.text =  self.mainContents[i].name;
        item.selectedLabel.text = self.mainContents[i].name;

        item.openSprite.localRotation = CLOSE_ROTATION;
        if self.mainContents[i].id then
            self.mainID_index[self.mainContents[i].id] = i;
        end
    end
    self.mainContents = AchievementMgr.GetMainContents();
    self.mainID_index = {};
    local overview = {};
    overview.name = "总览";
    table.insert(self.mainContents,1,overview);
    local firstCount = self.mainContents and #self.mainContents or 4;--根据配置文件初始化
    self.firstList = UIUtil.Duplicate(ui,firstPrefab,nil,firstCount,OnFirstItemCreate);
    self.firstList[1].openSprite.gameObject:SetActive(false);--第一个总览不显示三角标
    
    local OnSecondItemCreate = function(item,i)
        local notSelectTrans = item.transform:Find("SpriteNotSelected");
        item.notSelectGo = notSelectTrans.gameObject;
        item.notSelectLabel = notSelectTrans:Find("Title"):GetComponent("UILabel"); 
        local selectTrans = item.transform:Find("SpriteSelected");
        item.selectedGo = selectTrans.gameObject;
        item.selectedLabel = selectTrans:Find("Title"):GetComponent("UILabel");

        item.uiEvent = item.transform:GetComponent("UIEvent");
    end
    local secondCount = 10;--获得最大的子项数目
    self.secondList = UIUtil.Duplicate(ui,secondPrefab,nil,secondCount,OnSecondItemCreate);
    self.secondGo:SetActive(false);
    local function OpenMainCatalogue(i)
        if i == 0 then return end
        local subContents = AchievementMgr.GetSubContents(self.mainContents[i].id);
        self.subContents = subContents;
        self.secondGo:SetActive(true);
        local count = #subContents;
        for k = 1, count do
            local content = subContents[k];
            local item = self.secondList[k];
            item.gameObject:SetActive(true);
            item.notSelectLabel.text = content and content.name or "分类"..k;
            item.selectedLabel.text = content and content.name or "分类"..k;
            item.uiEvent.id = 1000 + (i-1)*100 + k;
        end
        for k = count+1, #self.secondList do
            self.secondList[k].gameObject:SetActive(false);
        end
        self.secondTrans.parent = self.firstList[i].transform;
        self.secondTrans.localPosition = Vector3.New(0,-40,0);
        self.secondTable:Reposition();
        self.firstList[i].openSprite.localRotation = OPEN_ROTATION;
        self.firstTable:Reposition();
    end
    local function CloseMainCatalogue(i)
        if i == 0 then return end
        self.secondGo:SetActive(false);
        self.firstList[i].openSprite.localRotation = CLOSE_ROTATION;
        self.firstTable:Reposition();
    end

    local function SelectCatalogue(id)
        id = id - 1000;
        if id == 0 then --直接打开总览界面
            ShowOverview();
            if self.openIndex then
                CloseMainCatalogue(self.openIndex);
                self.openIndex = nil;
            end
            return;
        end
        local mainIndex = math.floor(id *0.01) + 1;
        local subIndex = id - 100*(mainIndex -1);
        local isMain = subIndex == 0;
        local catalogue = nil;
        if isMain then--主类别
            if not self.selectID or self.selectID == id then
                if self.openIndex == mainIndex then
                    CloseMainCatalogue(mainIndex);
                    self.openIndex = nil;
                else
                    OpenMainCatalogue(mainIndex);
                    self.openIndex = mainIndex;
                end
            else
                if self.openIndex then
                    CloseMainCatalogue(self.openIndex);
                end
                self.openIndex = mainIndex;
                OpenMainCatalogue(self.openIndex);
            end
            catalogue = self.mainContents[mainIndex];
        else
            catalogue = self.subContents[subIndex];
        end
        self.selectID = id;
        ShowCatalogue(catalogue.id);
    end

    function Catalogue.OnEnable()
        self.firstList[1].transform:GetComponent("UIToggle").value = true;
        SelectCatalogue(1000);
    end
    function Catalogue.OnClick(go,id) --1000 <= id <2000
        SelectCatalogue(id);
    end

    function Catalogue.Show(cataID)
        local index = self.mainID_index[cataID];
        if index then
            self.firstList[index].transform:GetComponent("UIToggle").value = true;
        end
    end
end