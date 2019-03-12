--登录模块，滚屏提示错误消息，发生错误，重新开始流程；
--客户端与服务器需要版本号验证；
module("LoginMgr",package.seeall);
local JSON = require "cjson";
local RoleItem = require ("Logic/System/Login/Item/RoleItem");
local ServerItem = require ("Logic/System/Login/Item/ServerItem");
local mSDK = {};
local mGateInfo = {};

local mBulletAddress;
local mBulletContent;

local mSelectedServer;
local mSelectedRole;

local mCategories;
local mServers;
local mServersByID;

local mServerStatesByID;
local mRoles;

local mServerRoleRequestCount;

--初始化登录网络模式
local function InitServerMode()
    local serverSwitch = tonumber(UserData.ReadConfig("serverSwitch"));
	local initServerSwitch =  GameConfig.GetServerMode();
	if serverSwitch and initServerSwitch ~= serverSwitch then
		GameConfig.SetServer(serverSwitch);
    end
end
--最近登录的排在前面
local function RoleSortFunc(role1, role2)
    return role1:GetLoginTime() > role2:GetLoginTime();
end

--优先新服，其次推荐服，最后按照ID排序从大到小
local function ServerSortFunc(s1,s2)
    if s1:IsNew() and (not s2:IsNew()) then return true; end
    if s2:IsNew() and (not s1:IsNew()) then return false; end
    if s1:IsRecommend() and (not s2:IsRecommend()) then return true; end
    if s2:IsRecommend() and (not s1:IsRecommend()) then return false; end

    return s1:GetID() > s2:GetID();
end

local function OnNewRole(roleItem)
    mRoles[#mRoles+1] = roleItem;
    mSelectedServer:AddRole(roleItem);
    roleItem:SetServer(mSelectedServer);
end

local function GetRecommendRole()
    return mRoles and mRoles[1];
end
--优先ServerID最大的服务器
local function GetRecommendServer()
    if not mServers then return end
    local target = mServers and mServers[1];
    for _,server in ipairs(mServers) do
        if not target then 
            target = server; 
        else
            if server:GetID() > target:GetID() then
                target = server;
            end
        end
    end
    return target;
end

local function InitServerStateInfo()
    for sid,state in pairs(mServerStatesByID) do
        local server = mServersByID[sid];
        if server then
            server:SetOpenState(state);
        else
            GameLog.LogError("No Server Found by ID: %s",sid);
        end
    end
end

local function InitServerRoleInfo()
    for _,role in ipairs(mRoles) do
        local sid = role:GetServerID();
        local server = mServersByID[sid];
        if server then
            server:AddRole(role);
            role:SetServer(server);
        else
            GameLog.LogError("No Server Found by ID: %s",sid);
        end
    end
    for id, server in ipairs(mServersByID) do
        server:SortRole(RoleSortFunc);
    end
end
 
--将服务器分组
local function InitCategoryInfo()
    if #mRoles > 0 then
        local allRoleItem = {};
        allRoleItem.name = WordData.GetWordStringByKey("login_select_already_roles");
        allRoleItem.roles = mRoles;
        table.insert(mCategories,allRoleItem);
    end

    local recommendItem = {};
    recommendItem.name = WordData.GetWordStringByKey("login_select_recommend");
    recommendItem.servers = {};
    table.insert(mCategories,recommendItem);

    local tempTable = {};
    for index,server in pairs(mServers) do
        if server:IsRecommend() then
            table.insert(recommendItem.servers, server);
        end
        local gid = server:GetGroup();
        if not tempTable[gid] then 
            tempTable[gid] = {};
            tempTable[gid].name = WordData.GetWordStringByKey("login_select_category",gid);
            tempTable[gid].servers = {};
        end
        table.insert(tempTable[gid].servers, server);
    end
    for _, item in pairs(tempTable) do
        table.insert(mCategories,item);
    end

    table.sort(mRoles,RoleSortFunc);
    for _,cate in ipairs(mCategories) do
        if cate.servers then
            table.sort(cate.servers,ServerSortFunc);
        end
    end
end

local function OnServerRoleInitReceived()
    mServerRoleRequestCount = mServerRoleRequestCount + 1;

    if mServerRoleRequestCount == 2 then
        InitServerRoleInfo();
        InitCategoryInfo();
        LoginMgr.OnAccountLoginFinish();
        GameEvent.Trigger(EVT.LOGIN, EVT.LOGIN_ACCOUNT_SUCCESS);
    end
end

local function OnGetBulletContent(data)
    mBulletContent = data.info;
    GameEvent.Trigger(EVT.LOGIN, EVT.LOGIN_BULLET,mBulletContent);
end

--清理所有服务器角色相关数据
local function ClearAccountData()
    mServerRoleRequestCount = 0;
    mSelectedServer = nil;
    mSelectedRole = nil;
    
    mServers = {};
    mServersByID = {};

    mCategories = {};
    mServerStatesByID = {};
    mRoles = {};
    GameEvent.Trigger(EVT.LOGIN, EVT.LOGIN_CHANGE_ACCOUNT);
end

local function OnSocketError(socketIndex,arg)
    TipsMgr.TipByKey("Login_socket_error");--Socket错误
end
local function OnSocketConnect(socketIndex)
    if socketIndex == GameConfig.LOGIN_SOCKET then
        LoginMgr.RequestLoginLogin();
    elseif socketIndex == GameConfig.GATE_SOCKET then
        LoginMgr.RequestLoginGate();
    end
end
local function OnSocketDisconnect(socketIndex, passive)
    if passive then
        if socketIndex == GameConfig.LOGIN_SOCKET then
            TipsMgr.TipConfirmByKey("Login_socket_disconnected_passive");--客户端被动断开
        elseif socketIndex == GameConfig.GATE_SOCKET then
            TipsMgr.TipConfirmByKey("Gate_socket_disconnected_passive");--客户端被动断开
        end
    end
end

local function OnSocketConnectFailed(socketIndex,param)
    TipsMgr.TipByKey(param);--'network_connect_timeout'; 'network_connect_0'; network_connect_1'
end

local function OnSocketSendMsgFail(socketIndex)
    TipsMgr.TipByKey("socket_send_msg_fail");--Socket发送消息失败；
end

function InitModule()
    require("Logic/System/Login/LoginMgr_Auto");

    InitServerMode();

    GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_ERROR,OnSocketError);

    GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_CONNECT,OnSocketConnect);

    GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_DISCONNECT,OnSocketDisconnect);

    GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_DISCONNECT,OnSocketDisconnect);

    GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_CONNECT_FAIL,OnSocketConnectFailed);
    
    GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_CONNECT_FAIL,OnSocketConnectFailed);

    GameEvent.Reg(EVT.NETWORK,EVT.NETWORK_SEND_MSG_FAIL,OnSocketSendMsgFail);
end
--==============================--
--desc: GET SET 方法
--==============================-------------
--获得服务器分类
function GetCategories()
    if #mCategories == 0  then
        InitCategoryInfo();
    end
    return mCategories;
end

function GetAllRoles()
    return mRoles;
end

function IsServerSelected(server)
    return mSelectedServer == server;
end

function SetSelectServer(server)
    mSelectedServer = server;
end

function SetSelectRole(role)
    mSelectedRole = role;
end
--根据登录时间获得最近登录的角色，没有的话就选择推荐服
function GetRecommendServerRole()

    local reRole = mRoles and mRoles[1];
    if reRole then 
        SetSelectRole(reRole);
        mSelectedServer = reRole:GetServer();
    else
        SetSelectRole(nil);
        mSelectedServer = GetRecommendServer();
    end
    return mSelectedServer,mSelectedRole;
end

function GetServerByID(sid)
    return mServersByID[sid];
end

--设置服务器模式（单机，内网，外网），开发时的功能-----
function GetServerMode()
    return GameConfig.GetServerMode();
end

function SetNetworkMode(b)
	GameConfig.SetServer(b);
	UserData.WriteConfig("serverSwitch",b);
end

function GetCurrentServerName()
    return mSelectedServer:GetName();
end

function GetCurrentServer()
    return mSelectedServer;
end

function GetMaxRoleCount()
    return ConfigData.GetIntValue("login_role_limit_count") or 3;--每个服务器创角数量限制
end

function GetBulletNotice()
    if not mBulletContent then RequestGetBulletContent(); else
        return mBulletContent;
    end
end

function CloseGateSocket()
    GameNet.CloseSocket(GameConfig.GATE_SOCKET);
end

--==============================--
--desc: 网络请求
--==============================-------------
-- 登录账号，获得login服的账号和token-------------
function RequestAccountLogin(accountName)
    if GameConfig.SINGLE then
        --单机模式
        MapMgr.RequestEnterSingleMap();
    else
        --连接服务器
        local function OnAccountLogin(jsonData)   
            if not jsonData then LoginMgr.OnAutoLoginFail(); return; end
            mSDK.LoginAccount = tostring(jsonData["content"]["UserOpenID"]);
            mSDK.LoginToken = tostring(jsonData["content"]["token"]);
            
            RequestServerRoleInfo();
            LoginMgr.SaveAccount(accountName);
        end
        local request = string.format("account=%s&password=%s", accountName, "xx");
        GameNet.SendToHttp(GameConfig.SDK_CHECKACCOUNT, request, OnAccountLogin);
    end
end

---WebServer 获得服务器相关数据----------------
function RequestServerRoleInfo()
    --清理已有数据
    ClearAccountData();
    LoginMgr.RequestServerList();
    LoginMgr.RequestRoleList();

end

function RequestServerList()
    if GameConfig.SINGLE then
        return;
    end
    local function OnReceiveServerData(jsonData)
        if not jsonData then LoginMgr.OnAutoLoginFail(); return; end
        local list = jsonData["ServerList"];
        --mServers = {};
        for i = 1,1 do
            local temp = {};
            temp.ID = -1*i;
            temp.Name = "本地服"..i;
            temp.Group = "1";
            temp.Busy = false;
            temp.IsHot = false;
            temp.IsNew = false;
            temp.IP = "127.0.0.1";
            temp.Port = "8888";
            local server = ServerItem.new(temp);
            mServers[#mServers + 1] = server;
            mServersByID[temp.ID] = server;
        end
        for k,v in pairs(list) do
            v.ID = tonumber(v.ID);
            v.IsHot = tonumber(v.IsHot)==1;
            v.IsNew = tonumber(v.IsNew)==1;
            local server = ServerItem.new(v);
            mServers[#mServers + 1] = server;
            mServersByID[v.ID] = server;
        end

        local states = jsonData["state"][1];
        local now = tonumber(states["now"]);
        for key, item in pairs(states) do
            if key ~= "now" then
                item = JSON.decode(item);
                local sid = tonumber(key);
                local lastTime = tonumber(item.time);
                local server = mServersByID[sid];
                if server then
                    server:SetOpenState(now-lastTime < 10);
                    server:SetState(item.state or 0);
                end
            end
        end
        mBulletAddress = jsonData["notice"];

        OnServerRoleInitReceived();
    end

    local request = "action=ServerAll&CurrAreaID=1&UserOpenID=bbsbbs";
    GameNet.SendToHttp(GameConfig.SERVER_LIST_URL, request, OnReceiveServerData);
end

--[{"1_10000013":"{\n\t\"serverID\":\t1,
                 --\n\t\"account\":\t\"1529415889\",
                 --\n\t\"roleID\":\t10000013,
                 --\n\t\"roleName\":\t\"\u671d\u9633\u82df\u5c14\u66fc\",
                 --\n\t\"icon\":\t\"\",
                 --\n\t\"level\":\t1\n}"}]

---WebServer 获得角色列表数据，需要SDK的账号----------------
function RequestRoleList()
    local function OnReceiverRoleData(jsonData)
        if not jsonData then LoginMgr.OnAutoLoginFail(); return; end
        for i = 1, #jsonData do
            local obj = jsonData[i]
            for k, v in pairs(obj) do
                GameLog.Log(tostring(k) .. "k---v" .. obj[k] .. type(obj[k]))
                local item = JSON.decode(v)
                mRoles[#mRoles + 1] = RoleItem.new(item);
            end
        end
        OnServerRoleInitReceived();
    end
    GameNet.SendToHttp(string.format(GameConfig.ROLE_LIST_URL, mSDK.LoginAccount), "", OnReceiverRoleData);
end

--请求公告
function RequestGetBulletContent()
    if not mBulletAddress then     GameLog.LogError("No Bullet Adress");    return;  end

    GameNet.SendToHttp(mBulletAddress, "", OnGetBulletContent);
end
------ login服登录，建立socket连接-------
function RequestConnectLogin()
    if not mSelectedServer then
        GameLog.LogError("SelectedServer is null ");
        return;
    end
    local ip = mSelectedServer:GetIP();
    local port = mSelectedServer:GetPort();
    GameLog.Log("begin connect login server ip = %s, port = %s",ip, port);
    GameNet.ConnectSocket(GameConfig.LOGIN_SOCKET,ip, port);
end

---------验证Login账户信息-------------
function RequestLoginLogin()
    GameLog.Log("begin login login server %s:%s",mSDK.LoginAccount,mSDK.LoginToken)
    local msg = NetCL_pb.CLLogin();
    msg.account = mSDK.LoginAccount;
    msg.password = mSDK.LoginToken;
    GameNet.SendToLogin(msg);	
end

---获得gate服务器ip和port,账号和token
function OnLoginLoginRe(msg)
	if msg.ret == 0 then --success
		mGateInfo.GateLoginAccount = tostring(msg.account);
		mGateInfo.GateLoginToken = tostring(msg.token);
		RequestConnectGate(msg.hosts,msg.port);
    else
        --断开socket，再次点击登录重新发起连接
        GameNet.CloseSocket(GameConfig.LOGIN_SOCKET);
        TipsMgr.TipErrorByID(msg.ret);
        GameLog.Log("msg name = %s, ret = %d", getmetatable(msg)._descriptor.name, msg.ret);
		LoginMgr.OnAutoLoginFail();
	end
end

----和gate服务器 建立socket连接请求,并断开login服务器连接
function RequestConnectGate(ip,port)
    GameLog.Log("begin connect gate server->%s, %s",ip, port);
    GameNet.CloseSocket(GameConfig.LOGIN_SOCKET);
    GameNet.ConnectSocket(GameConfig.GATE_SOCKET, ip, port);
end

--验证Gate服务器的账户
function RequestLoginGate()
    GameLog.Log("begin login gate server->%s, %s",mGateInfo.GateLoginAccount, mGateInfo.GateLoginToken);
    local msg = NetCA_pb.CALogin();
    msg.account = mGateInfo.GateLoginAccount;
    msg.token = mGateInfo.GateLoginToken;
    
    msg.majorVersionNumber = VersionData.GetMajorVer();
    msg.minorVersionNumber = VersionData.GetMinorVer();
    msg.revisionVersionNumber = VersionData.GetRevisionNumber();
    GameNet.SendToGate(msg);
end

--根据是否选择角色进入创角，或者进入游戏
function OnReceiveGateLoginRe(msg)
	if msg.ret == 0 then --success
		if not mSelectedRole then
            GameStateMgr.EnterRole();
		else
			LoginMgr.RequestSelectRole();
		end
    else
        --断开socket，再次点击登录重新发起连接
        GameNet.CloseSocket(GameConfig.GATE_SOCKET);
        TipsMgr.TipErrorByID(msg.ret);
        GameLog.Log("msg name = %s, ret = %d", getmetatable(msg)._descriptor.name, msg.ret);
		LoginMgr.OnAutoLoginFail();
	end
end

local mCreateRoleRecord;--服务器应该返回创角信息
--请求创角
function RequestCreateRole(name,racial,profes)
    GameLog.Log("begin Request Create Role roleName"..name);
    local msg_createrole = NetCW_pb.CWCreateRole();
    msg_createrole.roleName = name;
    msg_createrole.racial = racial;--角色
    msg_createrole.profes = profes;--职业
    mCreateRoleRecord = msg_createrole;

    GameNet.SendToGate(msg_createrole);
end

-- serverID\":\t1,
--                  --\n\t\"account\":\t\"1529415889\",
--                  --\n\t\"roleID\":\t10000013,
--                  --\n\t\"roleName\":\t\"\u671d\u9633\u82df\u5c14\u66fc\",
--                  --\n\t\"icon\":\t\"\",
--                  --\n\t\"level\":\t1\n}"}]
--创角成功，请求进入游戏
function OnCreateRoleRe(msg)

    GameLog.Log("recv create role %s",tostring(msg.roleID));

    local roleInfo = {};
    roleInfo.roleID = tonumber(msg.roleID);
    roleInfo.roleName = mCreateRoleRecord.roleName;
    roleInfo.level = 0;
    roleInfo.icon = "";
    
    local roleItem = RoleItem.new(roleInfo);
    OnNewRole(roleItem);

    LoginMgr.SetSelectRole(roleItem);
    LoginMgr.RequestSelectRole();
end

--发送选择角色信息
function RequestSelectRole()
    local msg = NetCW_pb.CWSelectRole();
    msg.roleId = mSelectedRole:GetID();
    GameNet.SendToGate(msg);
    GameLog.Log("Request select role, roleId ->%s",msg.roleId);
end
--收到选角请求，登录结束，等待进入游戏
function OnSelectRoleRe(msg)
	if msg.ret == 0 then
		GameLog.Log("recv select role "..msg.roleId);
        UserData.PlayerID = tonumber(msg.roleId);
        LoginMgr.OnAutoLoginSuccess(mSelectedServer, mSelectedRole);

    else
        --滚屏提示
        TipsMgr.TipErrorByID(msg.ret);
        GameLog.Log("msg name = %s, ret = %d", getmetatable(msg)._descriptor.name, msg.ret);
        --mSelectedRole = nil;
        GameNet.CloseSocket(GameConfig.GATE_SOCKET);
        LoginMgr.OnAutoLoginFail();
	end
end


return LoginMgr;

--end ==============================--