
module("FriendRecommendMgr",package.seeall);
local json = require "cjson"
local mBasicFriendInfoParam = "detailparams=playerid&usrdata_fields=level";
--推荐设置属性key表
local mFriRecomProNames = {"region","sex","marriage","level","career","star","purpose","preference"};
--推荐列表
local mRecommendList;
--推荐数量
local mHeadcount;

--搜索结果
local mSearchList;
--设置动态数据
local mSettingsDynamic;
--设置静态数据
local mSettingStatic;

--社交服务器信息同步
local mInitSelfProperty = false;
--初始化是否完成
local mInited = false;

local mInnerProperties ;

local function Ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

local function InitLocalProperties()
    mSettingStatic = {};
    require("Logic/System/SocialNetwork/System/Recommend/Property/FriRecomProBase");
    require("Logic/System/SocialNetwork/System/Recommend/FriendRecommendMgrUtil");
    for _,name in ipairs(mFriRecomProNames) do
        local file = string.format("Logic/System/SocialNetwork/System/Recommend/Property/FriRecomPro%s",Ucfirst(name));
        local ret,result = xpcall(require,traceback,file);
        if not ret then
            GameLog.LogError("Failed to load file %s",file);
        else
            mSettingStatic[name] = result.new();
        end
    end
end

--初始化
function InitSNS()
    --if mInited then return; end
    mInited = true;
    InitLocalProperties();
    RequestGetRemoteProperties();
    RequestGetCustomSettings();    

end

--从社交服务器拿到自己的相关属性
function OnGetRemoteProperties(data)
    if not data then return; end    if not data then return; end
    local fields = data;
    if not fields then return; end
    local selfProperties = nil;
    for key,value in pairs(fields) do
        local property = mSettingStatic[key];
        if not property:IsSameValue(value) then
            selfProperties = selfProperties or {};
            selfProperties[key] = property:GetUserValue();
        end
    end
    if selfProperties then
        local function Callback()
            mInitSelfProperty = true;
        end
        RequestSetPlayerProperty(selfProperties,Callback);
    else
        mInitSelfProperty = true;
    end
end

--请求获得远端用户属性
function RequestGetRemoteProperties()
    SocialNetworkMgr.RequestAction("GetRecommendCond",nil,OnGetRemoteProperties);
end


--上传玩家属性({field:value})
function RequestSetPlayerProperty(keyValues,callback)
    local params = string.format("keyfields=%s",json.encode(keyValues));
    SocialNetworkMgr.RequestAction("SetRecommendCond",params,callback);
end

--收到推荐设置
function OnGetCustomSettings(data)
    mSettingsDynamic = data;
end

--请求获得用户自定义设置
function RequestGetCustomSettings(callback)
    mSettingsDynamic = nil;

    SocialNetworkMgr.RequestAction("GetFRecDetailCond",nil,OnGetCustomSettings);
end

--返回修改设置,然后发送推荐请求

--请求批量修改推荐设置{key:{index},key:{index,index}}
function RequestSetRecommendSettings(settings)

    local jsonTable = {};
    mInnerProperties = {};
    for name,indexes in pairs(settings) do
        local property = mSettingStatic[name];
        
        local value = FriendRecommendMgrUtil.Value2String(indexes);
        jsonTable[name]  = value;
        if property:IsInnerProperty() then
            mInnerProperties[name]  = value;
        end
    end

    local function OnSetRecommendSettings()
        for key,value in pairs(jsonTable) do
            mSettingsDynamic[key] = value;
        end
        GameLog.Log("OnSetRecommendSettings--------");
        --修改系统内部属性，修改后再请求获得推荐
        RequestSetPlayerProperty(mInnerProperties,RequestGetRecommendPlayer);
        mInnerProperties = nil;
        GameEvent.Trigger(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_SETTINGS_CHANGE);
    end

    local params = string.format("condition=%s",json.encode(jsonTable));
    SocialNetworkMgr.RequestAction("SetFRecDetailCon",params,OnSetRecommendSettings);
end

local function RecomSort(a,b)
    if a.isNew == b.isNew then
        return a.player:GetID()<b.player:GetID();
    else
        return a.isNew;
    end
end

--获得推荐玩家
function OnGetRecommendPlayer(data)
    if not data then return; end

    for id, info in pairs(data) do
        local id = tonumber(info.device_id);       
        local item = {};
        item.id = id;
        item.isNew = tonumber(info.recommendPlayerStatus) == 1 and true or false;
        item.player = SocialPlayerMgr.FindMemberByID(id);
        mHeadcount = mHeadcount - 1;
        table.insert(mRecommendList,item);
    end
    table.sort(mRecommendList,RecomSort);
    GameEvent.Trigger(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_HEAD_COUNT,mHeadcount);
    GameEvent.Trigger(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_PLAYER_CHANGE);
end
--请求推荐
function RequestGetRecommendPlayer()
    mRecommendList = {};
    mHeadcount = ConfigData.GetIntValue("friend_recommend_headcount") or 7;--好友推荐数量
    if not HasCustomerSet() then return; end
    SocialNetworkMgr.RequestAction("RecommendFriend",mBasicFriendInfoParam,OnGetRecommendPlayer);
end

--获得搜索结果
function OnSearchPlayer(data)
    mSearchList = {};
    for id, _ in pairs(data) do
        table.insert(mSearchList,SocialPlayerMgr.FindMemberByID(id));
    end
    GameEvent.Trigger(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_SEARCH_RESULT);
end
--请求搜索
function RequestSearchPlayer(content)
    GameLog.Log("Search Player Content: "..content);
    local params = string.format("queryKey=%s&%s",content, mBasicFriendInfoParam);
    SocialNetworkMgr.RequestAction("QueryPlayerData",params,OnSearchPlayer);
end

local function OnAskSucess(item)
    for i=1,#mRecommendList do
        if item == mRecommendList[i] then
            table.remove(mRecommendList,i);
            GameEvent.Trigger(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_DELETE_ITEM,item);
            break;
        end
    end
end

function RequestAskAddFriend(item)
    FriendMgr.RequestAskAddFriend(item.player,OnAskSucess,item);
end

--==============================--
--desc:设置与属性
--time:2018-10-18 05:58:33
--@return 
--==============================---
function GetKeyLocation()
    return mFriRecomProNames[1];
end
function GetKeySex()
    return mFriRecomProNames[2];
end
function GetKeyMarriage()
    return mFriRecomProNames[3];
end
function GetKeyLevel()
    return mFriRecomProNames[4];
end
function GetKeyCareer()
    return mFriRecomProNames[5];
end
function GetKeyStar()
    return mFriRecomProNames[6];
end
function GetKeyPurpose()
    return mFriRecomProNames[7];
end
function GetKeyPreperence()
    return mFriRecomProNames[8];
end

--是否进行了设置
function HasCustomerSet()
    if not mSettingsDynamic then return false; end
    for key, value in pairs(mSettingsDynamic) do
        if value  and (value~= -1 and value ~="") then
            return true;
        end
    end
    return false;
end

--获取属性最大索引
function GetPropertyMaxIndex(key)
    if mSettingStatic[key] then
        return mSettingStatic[key]:GetMaxIndex();
    end
end
--获取属性名;属性名,索引
function GetPropertyName(key,index)
    if mSettingStatic[key] then
        return mSettingStatic[key]:GetName(index);
    end
end
--获取协议代码;属性名,索引
function GetPropertyCode(key,...)
    if mSettingStatic[key] then
        return mSettingStatic[key]:GetCode(...);
    end
end
--获取索引;属性名,协议代码
function GetPropertyIndex(key,code)
    if mSettingStatic[key] then
        return mSettingStatic[key]:GetIndex(code);
    end
end

--获取用户的推荐设置
function GetCustomSelectedIndexes(key)
    local list = {};
    if mSettingsDynamic then
        local selectedTable = mSettingsDynamic[key];
        if selectedTable then
            selectedTable = FriendRecommendMgrUtil.String2List(selectedTable);
            for i,code in ipairs(selectedTable) do
                local index =  GetPropertyIndex(key,code);
                if index  then
                    table.insert( list,index );
                end
            end
        end
    end
    return list;
end

--==============================--
--desc:推荐和搜索相关
--time:2018-10-18 05:27:39
--@return 
--==============================--

function GetHeadCount()
    return mHeadcount;
end

function GetSearchResults()
    return mSearchList or table.emptyTable;
end

function GetRecommendList()
    return mRecommendList or table.emptyTable;
end

function GetRecommendCount()
    if mRecommendList then
        return #mRecommendList;
    else
        return 0;
    end
end

--已经进行了推荐设置
function HasSetting()
    return true;
end

return FriendRecommendMgr;