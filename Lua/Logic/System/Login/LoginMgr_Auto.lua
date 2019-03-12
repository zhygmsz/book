--[[
自动登录管理，同一角色登录三次则自动登录
author:{hesinian}
time:2019-01-09 14:14:25
]]

module("LoginMgr",package.seeall)
local mLogined;--当前是否已经登录
local mAutoMode ;
local mIsAuto;
local mCount;
local mAccount;
local mServerID;
local mRoleID;

function GetAutoLoginMode()
    mAutoMode = mAutoMode or UserData.ReadBoolConfig("login_auto");
    return mAutoMode;
end

function SetAutoLoginMode(value)
    if mAutoMode == value then return;end
    mAutoMode = value;
    UserData.WriteBoolConfig("login_auto",value);
end

local function GetLoginCount()
    mCount = mCount or UserData.ReadIntConfig("login_repeate_count");
    return mCount;
end
local function SaveLoginCount(count)
    if count == mCount then return; end
    mCount = count;
    UserData.WriteIntConfig("login_repeate_count",count);
end

function GetLocalAccount()
    mAccount = mAccount or UserData.ReadConfig("login_account");
    return mAccount;
end
function SaveAccount(account)
    
    if mAccount == account then return; end
    mAccount = account;
    SaveLoginCount(0);
    UserData.WriteConfig("login_account",account);
end

local function GetLocalServerID()
    mServerID = mServerID or UserData.ReadIntConfig("login_serverID");
    return mServerID;
end
local function SaveServerID(id)
    mServerID = GetLocalServerID();
    if id == mServerID then return; end
    mServerID = id;
    SaveLoginCount(0);
    UserData.WriteIntConfig("login_serverID",id);
end


local function GetLocalRoleID()
    mRoleID = mRoleID or UserData.ReadIntConfig("login_roleID");
    return mRoleID;
end
local function SaveRoleID(id)
    mRoleID = GetLocalRoleID();
    if id == mRoleID then return; end
    mRoleID = id;
    SaveLoginCount(0);
    UserData.WriteIntConfig("login_roleID",id);
end

local function StartManualLogin()
    --强制登录界面立即打开
    AllUI.UI_Login.autoOpen = false;
    UIMgr.ShowUI(AllUI.UI_Login);
end

--被动断开socket连接时中断自动登录
local function OnSocketDisconnect(socketIndex, needConcern)
    if not needConcern then return; end    
    OnAutoLoginFail();
end

--当前未登录，且用同一个账号已经连续登录三次
local function CheckAutoLogin()

    local count = GetLoginCount();
    local countLimt = ConfigData.GetIntValue("login_repeate_count_limit") or 3;--连续登录次数
    return (not mLogined) and (count >= countLimt);
end

--登录结束
local function OnAutoLoginEnd()
    if mIsAuto then
        GameEvent.UnReg(EVT.NETWORK,EVT.NETWORK_DISCONNECT,OnSocketDisconnect);
        GameEvent.UnReg(EVT.NETWORK,EVT.NETWORK_CONNECT_FAIL,OnAutoLoginFail);
        mIsAuto = false;
    end
end

function StartLogin(auto)
    LoginMgr.CloseGateSocket();
    --检测可以自动登录
    if false and auto and CheckAutoLogin() and GetAutoLoginMode() then
        mIsAuto = true;
        GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_DISCONNECT,OnSocketDisconnect);
        GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_CONNECT_FAIL,OnAutoLoginFail);

        local account = GetLocalAccount();
        LoginMgr.RequestAccountLogin(account);
    else
        StartManualLogin();
    end
end

--账号登录完成
function OnAccountLoginFinish()

    if mIsAuto then
        local server, role = LoginMgr.GetRecommendServerRole();
        if (not server) or (not role) then OnAutoLoginFail(); return; end
        
        local rid = GetLocalRoleID();
        local sid = GetLocalServerID();
        if server:GetID() ~= sid  then OnAutoLoginFail(); return; end
        if role:GetID() ~= rid  then OnAutoLoginFail(); return; end

        LoginMgr.RequestConnectLogin();
    end
end

--游戏服登录成功
function OnAutoLoginSuccess(server,role)
    mLogined = true;
    SaveServerID(server:GetID());
    SaveRoleID(role:GetID());

    local count = GetLoginCount();
    count = count<3 and count+1 or count; 
    SaveLoginCount(count);

    OnAutoLoginEnd();
end

--登录失败
function OnAutoLoginFail()
    if mIsAuto then
        --选择按钮
        StartManualLogin();
        --TipsMgr.TipConfirmByStr("login_auto_fail",StartManualLogin,StartManualLogin);--自动登录失败提示
    end
    OnAutoLoginEnd();

end
