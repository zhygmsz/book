module("UI_Login_SelectServerRole",package.seeall);

local LoginWrapGridUIServerCategory = require("Logic/Presenter/UI/Login/SelectServerRole/LoginWrapGridUIServerCategory");
local LoginWrapGridUIAllRole = require("Logic/Presenter/UI/Login/SelectServerRole/LoginWrapGridUIAllRole");
local LoginWrapTableUISelectServer = require("Logic/Presenter/UI/Login/SelectServerRole/LoginWrapTableUISelectServer");
local LoginWrapTableUISelectRole = require("Logic/Presenter/UI/Login/SelectServerRole/LoginWrapTableUISelectRole");
local LoginWrapTableDataHelper = require("Logic/Presenter/UI/Login/SelectServerRole/LoginWrapTableDataHelper");

local mCategoryTable;
local mAllRoleTable;

local mServerWrapTable;
local mServerWrapTableDataHelpers;

local mRoleContentGo;
local mServerContentGo;

local mSelectedCategory;
local mSelectedServer;

local mUIFrame;

--换账号时清理已选择的目录和服务器
local function OnAccountChange()
    mSelectedCategory = nil;
    mSelectedServer = nil;
end

function IsCategorySelected(cate)
    return mSelectedCategory == cate;
end

function IsServerSelected(server)
    return mSelectedServer == server;
end


function GetUIFrame()
    return mUIFrame;
end

function OnServerClick(server,wrapUI)
    mSelectedServer = server;
    LoginMgr.SetSelectServer(server);
    mServerWrapTableDataHelpers[mSelectedCategory]:RefreshSelectedData();
end

function OnCategoryClick(cate,wrapUI)
    if mSelectedCategory == cate then return; end
    mSelectedCategory = cate;
    
    mSelectedServer = nil;
    LoginMgr.SetSelectServer(nil);
    LoginMgr.SetSelectRole(nil);

    if not cate.servers then
        mRoleContentGo:SetActive(true);
        mServerContentGo:SetActive(false);
    else
        mRoleContentGo:SetActive(false);
        mServerContentGo:SetActive(true);
        mServerWrapTableDataHelpers[cate]:RefreshAllData();
    end
end

function OnRoleClick(role,wrapUI)
    local server = role:GetServer();
    LoginMgr.SetSelectServer(server);
    LoginMgr.SetSelectRole(role);
    LoginMgr.RequestConnectLogin();
end

function OnCreate(ui)
    mUIFrame = ui;
    local path = "Offset/LeftZone";
    mCategoryTable = BaseWrapContentEx.new(ui,path.."/Scroll View",10,LoginWrapGridUIServerCategory,nil,UI_Login_SelectServerRole);
    mCategoryTable:SetUIEvent(100,1,{OnCategoryClick});

    path = "Offset/RightZone";
    mAllRoleTable = BaseWrapContentEx.new(ui,path.."/RolePanel/Scroll View Role",12,LoginWrapGridUIAllRole);
    mAllRoleTable:SetUIEvent(200,1,{OnRoleClick});

    local wrapUIs = {LoginWrapTableUISelectServer,LoginWrapTableUISelectRole};
    mServerWrapTable = UICommonCollapseTableWrap.new(ui,path.."/ServerPanel/Scroll View Server",10,wrapUIs,300,10,UI_Login_SelectServerRole);
    mRoleContentGo = ui:Find(path.."/RolePanel").gameObject;
    mServerContentGo = ui:Find(path.."/ServerPanel").gameObject;
    GameEvent.Reg(EVT.LOGIN, EVT.LOGIN_CHANGE_ACCOUNT,OnAccountChange);
end

function OnEnable(ui)
    --mSelectedServer = nil;
    UI_Login.ShowBg();
    --清理已选的角色
    LoginMgr.SetSelectRole(nil);

    LoginMgr.SetSelectServer(mSelectedServer);
    --重新打开，依旧显示上次选择的记录
    if mSelectedCategory then return; end
    
    mRoleContentGo:SetActive(true);
    mServerContentGo:SetActive(true);

    local categories = LoginMgr.GetCategories();
    

    mSelectedCategory = categories[1];
    mCategoryTable:ResetWithData(categories);

    local roles = LoginMgr.GetAllRoles();
    mAllRoleTable:ResetWithData(roles);

    mServerWrapTableDataHelpers = {};
    for i,cate in ipairs(categories) do
        if cate.servers then
            mServerWrapTableDataHelpers[cate] = LoginWrapTableDataHelper.new(mServerWrapTable,cate.servers);
        end
    end

    local showServer = not mSelectedCategory.roles
    mRoleContentGo:SetActive(not showServer);
    mServerContentGo:SetActive(showServer);

    if showServer then
        mServerWrapTableDataHelpers[mSelectedCategory]:RefreshAllData();
    end
    
end

function OnDisable(ui)
    
end

function OnDestroy()
    GameEvent.UnReg(EVT.LOGIN, EVT.LOGIN_CHANGE_ACCOUNT,OnAccountChange);
end

function OnClick(go,id)
    GameLog.Log("on click "..go.name.. " "..id);
    if id < 0 then 
        return;
    elseif id == 0 then 
        UIMgr.UnShowUI(AllUI.UI_Login_SelectServerRole);
        UI_Login.ShowGameIn();
    elseif id < 200 then
        mCategoryTable:OnClick(id);
    elseif id < 300 then
        mAllRoleTable:OnClick(id);
    else
        mServerWrapTable:OnClick(id);
    end
end