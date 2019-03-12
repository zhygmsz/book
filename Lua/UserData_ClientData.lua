---跨平台客户端数据管理，将所有的数据转换成字符串string,保存在网络hash表中
---每个玩家都有一个hash表
---在社交服初始化完成以后才初始化
module("UserData",package.seeall)

local mInited = false;
local mProxy = {};--代理
local mCacheTable;--真正的存储
local mGetParamTable;

local mObseleteKeys = {};

local function ParseBoolValue(value)
    if value == "false" then
        return false;
    elseif value == "true" then
        return true;
    else
        return value;
    end
end

local function RequestInitClientData()
    local function OnGetClientData(data)
        mCacheTable = data or {};
        mInited = true;
        GameInit.InitClientData();
        GameEvent.Trigger(EVT.CLIENT_DATA,EVT.CLIENT_DATA_INIT);
    end
    SocialNetworkMgr.RequestAction("XGetConfig",nil,OnGetClientData);
end

--保存客户端数据
local function RequestSaveClientData(t,key,value)
    value = tostring(value);
    if mCacheTable[key] == value then return; end

    mCacheTable[key] = value;

    mGetParamTable[1] = string.format("mtype=%s",key);
    mGetParamTable[2] = string.format("value=%s",value);
    local request = table.concat( mGetParamTable, "&");
    SocialNetworkMgr.RequestAction("XAddConfig",request);
end

local function InitProxyTable()
    mProxy = {};
    local mt = {};
    mt.__index = function(t,k)
        if not mInited then GameLog.LogError("UserData Not Inited"); return; end
        return mCacheTable[k];
    end
    mt.__newindex = RequestSaveClientData;
    setmetatable(mProxy,mt);
end

function InitSNS()
    mGetParamTable = {};    
    InitProxyTable();
    RequestInitClientData();
end

---------------数据接口---------------
--用mProxy来获取或存储数据

----------AIPet End
function GetAIPetChatFrequency()
    return mProxy.aipetChatFrequency;
end

function SetAIPetChatFrequency(value)
    mProxy.aipetChatFrequency = value;
end

function GetAIPetOnDesk()
    local re = mProxy.aiPetOnDesk;
    return ParseBoolValue(re);
end

function SetAIPetOnDesk(value)
    mProxy.aiPetOnDesk = value;
end

function GetAIPetSize()
    return mProxy.aiPetSize;
end

function SetAIPetSize(value)
    mProxy.aiPetSize = value;
end

function GetAIPetResume(pid,key)
    local key = "aipetResume"..pid..key;
    return mProxy[key];
end

function SetAIPetResume(pid, key, value)
    local key = "aipetResume"..pid..key;
    mProxy[key] = value;
end
----------AIPet End

----------充值
function GetOpenFirstChargeUIRecord()
    local re = mProxy.firstChargeEntryUI;
    return ParseBoolValue(re);
end

function SetOpenFirstChargeUIRecord(value)
    mProxy.firstChargeEntryUI = value;
end
----------充值End

----------好友设置
function GetFriendSettings(fType)
    local key = "friend_set_"..fType;
    return ParseBoolValue(mProxy[key]);
end

function SetFriendSettings(fType,value)
    local key = "friend_set_"..fType;
    mProxy[key] = value;
end

--好友快捷聊天
function GetFastChatterID(slot)
    local key = "fast_chat_"..slot;
    return tonumber(mProxy[key]);
end

function SetFastChatterID(slot,pid)
    local key = "fast_chat_"..slot;
    mProxy[key] = pid;
end
----------好友End

--点击开关
function GetScreenClickEnable()
    if mProxy["ClickFeedback"] == nil then 
        return true
    end
    return ParseBoolValue(mProxy["ClickFeedback"])
end

--点击反馈颜色 2是蓝色 3是粉色
function GetScreenClickColor()
    if mProxy["ClickScreenColor"] == nil then 
        local stype = UserData.IsMale() and 2 or 3
        return stype
    end
    return tonumber(mProxy["ClickScreenColor"]);
end

--聊天设置
function SetChatSetting(key, flag)
    mProxy[key] = flag
end

function GetChatSetting(key)
    if not mProxy[key] then
        return true
    end
    return ParseBoolValue(mProxy[key]) 
end
--系统设置
function SetSystemSetting(key, flag)
    mProxy[key] = flag
end

function GetSystemSetting(key,defaultValue)
    if not mProxy[key] then
        mProxy[key] = defaultValue
        return defaultValue
    end
    return ParseBoolValue(mProxy[key]) 
end
------------