module("UI_Login_GameIn", package.seeall)

local UILoginServerItem = require("Logic/Presenter/UI/Login/UILoginServerItem");
local UILoginRoleItem = require("Logic/Presenter/UI/Login/UILoginRoleItem");
local mShortServerRole;
local mLongServerRole;
local mContractToggle;

local mServerRoleAlready;

local mRootGo;

local mGameVersionLabel;
local mResVersionLabel;


local function InitServerRole()
    local server,role = LoginMgr.GetRecommendServerRole();
    if server then
        mServerRoleAlready = true;
    end
    if server and role then
        mShortServerRole.gameObject:SetActive(true);
        mLongServerRole.gameObject:SetActive(false);
        mShortServerRole.serverItem:Refresh(server);
        --mLongServerRole.roleItem:Refresh(role);
    elseif server then
        mShortServerRole.gameObject:SetActive(true);
        mLongServerRole.gameObject:SetActive(false);
        mShortServerRole.serverItem:Refresh(server);
    else
        mShortServerRole.gameObject:SetActive(false);
        mLongServerRole.gameObject:SetActive(false);
    end
end

function SetActive(state)
    mRootGo:SetActive(state);
    if state then 
        InitServerRole();
    end
end

function OnCreate(self)
    mRootGo = self:Find("GameIn").gameObject;

    mGameVersionLabel = self:FindComponent("UILabel", "GameIn/version");
    mResVersionLabel = self:FindComponent("UILabel", "GameIn/version_res");
    mGameVersionLabel.text = WordData.GetWordStringByKey("version_tip","1.0.0");
    mResVersionLabel.text = WordData.GetWordStringByKey("res_version_tip","1.0.0");--资源ID
    
    local gameNotice = self:FindComponent("UILabel","GameIn/Buttom/Label");
    gameNotice.text = TipsMgr.GetTipByKey("login_gameIn_notice");   

    mShortServerRole =  {};
    mShortServerRole.gameObject = self:Find("GameIn/dlBtn/Short").gameObject;
    local shortServerState = self:FindComponent("UISprite","GameIn/dlBtn/Short/CurServerState");
    local shortServerName = self:FindComponent("UILabel","GameIn/dlBtn/Short/CurServer");
    mShortServerRole.serverItem = UILoginServerItem.new(shortServerName,shortServerState);

    mLongServerRole =  {};
    mLongServerRole.gameObject = self:Find("GameIn/dlBtn/Long").gameObject;
    local longServerState = self:FindComponent("UISprite","GameIn/dlBtn/Long/CurServerState");
    local longServerName = self:FindComponent("UILabel","GameIn/dlBtn/Long/CurServer");
    mLongServerRole.serverItem = UILoginServerItem.new(longServerName,longServerState);    
    local longRoleName = self:FindComponent("UILabel","GameIn/dlBtn/Long/RoleName");
    local longRoleIcon = self:FindComponent("UITexture","GameIn/dlBtn/Long/HeadIcon");
    mLongServerRole.roleItem = UILoginRoleItem.new(longRoleIcon,longRoleName);

    mContractToggle = self:FindComponent("UIToggle","GameIn/dlBtn/Contract/Toggle");
end

function OnEnable(self)
    mServerRoleAlready = false;
    InitServerRole();
    GameEvent.Reg(EVT.LOGIN, EVT.LOGIN_ACCOUNT_SUCCESS,InitServerRole);
end

function OnDisable(self)
    GameEvent.UnReg(EVT.LOGIN, EVT.LOGIN_ACCOUNT_SUCCESS,InitServerRole);
end

function OnClick(id)
    if id == 0 then
        if not mServerRoleAlready then
            TipsMgr.TipByKey("login_tishi_33");
            return;
        end
        if not mContractToggle.value then
            TipsMgr.TipByKey("login_read_contract_notice");
            return;
        end
        LoginMgr.RequestConnectLogin();
    elseif id == 1 then
        if not mServerRoleAlready then
            TipsMgr.TipByKey("login_tishi_33");
            return;
        end
        if not mContractToggle.value then
            TipsMgr.TipByKey("login_read_contract_notice");
            return;
        end
        UIMgr.ShowUI(AllUI.UI_Login_SelectServerRole);
    elseif id == 2 then
        TipsMgr.TipByKey("open_contract");
    elseif id == 10 then
    --账户
        UI_Login.ShowAccount();
    elseif id == 11 then--修复       
        TipsMgr.TipByKey("Function_Not_Finished");
    elseif id == 12 then--扫码
        TipsMgr.TipByKey("Function_Not_Finished");
    elseif id == 13 then--反馈
        TipsMgr.TipByKey("Function_Not_Finished");
    elseif id == 14 then--公告
        UIMgr.ShowUI(AllUI.UI_Login_GameBulletin);
    elseif id == 15 then--动画
        CGMgr.PlayCG();
    end
end


