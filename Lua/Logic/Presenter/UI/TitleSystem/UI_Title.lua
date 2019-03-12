module("UI_Title",package.seeall);
local TitleContentPanel = require("Logic/Presenter/UI/TitleSystem/Panels/TitleContentPanel");
local TitleOfficialInfoPanel = require("Logic/Presenter/UI/TitleSystem/Panels/TitleOfficialInfoPanel");
local TitleUserDefinePanel = require("Logic/Presenter/UI/TitleSystem/Panels/TitleUserDefinePanel");
local TitleBasicPanel = require("Logic/Presenter/UI/TitleSystem/Panels/TitleBasicPanel");
local TitlePlayerRenderPanel = require("Logic/Presenter/UI/TitleSystem/Panels/TitlePlayerRenderPanel");


local mContentPanel;
local mOfficialInfoPanel;
local mUserdefineInfoPanel;
local mBasicInfoPanel;
local mPlayerRenderPanel;

function SelectUserItem(item)
    mOfficialInfoPanel:OnDisable();
    mUserdefineInfoPanel:OnEnable(item);
    mBasicInfoPanel:OnEnable(item);
end
function SelectOfficialItem(item)
    mOfficialInfoPanel:OnEnable(item);
    mUserdefineInfoPanel:OnDisable();
    mBasicInfoPanel:OnEnable(item);
end
function SelectInUseItem()
    local item = TitleMgr.GetItemInUse();
    SelectItem(item);
end
function SelectItem(item)
    if not item then
        mOfficialInfoPanel:OnDisable();
        mUserdefineInfoPanel:OnDisable();
        mBasicInfoPanel:OnDisable();
    elseif item.__cname == "TitleItemUserDefine" then
        SelectUserItem(item);
    else
        SelectOfficialItem(item);
    end
end
function OnCreate(ui)
    mContentPanel = TitleContentPanel.new(ui,UI_Title);
    mOfficialInfoPanel = TitleOfficialInfoPanel.new(ui,UI_Title);
    mUserdefineInfoPanel = TitleUserDefinePanel.new(ui,UI_Title);
    mBasicInfoPanel = TitleBasicPanel.new(ui,UI_Title);
    mPlayerRenderPanel = TitlePlayerRenderPanel.new(ui,UI_Title);
end

function OnEnable(ui)
    mPlayerRenderPanel:OnEnable();
    mContentPanel:OnEnable();
end

function OnDisable(ui)
    mContentPanel:OnDisable();
    mPlayerRenderPanel:OnDisable();
end

function OnDestroy()
    mContentPanel = nil;
    mOfficialInfoPanel = nil;
    mUserdefineInfoPanel = nil;
    mBasicInfoPanel = nil;
    mPlayerRenderPanel = nil;
end

function OnClick(go,id)
    GameLog.Log("on Click id "..id);
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Title);
        return;
    elseif id >= 1000 then
        mContentPanel:OnClick(id);
    else
        mUserdefineInfoPanel:OnClick(id);
        mBasicInfoPanel:OnClick(id);
    end
end

function OnDrag(delta,id)
    mPlayerRenderPanel:OnDrag(delta,id);
end