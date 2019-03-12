--==============================--
--desc: 个人空间社区服务器登录中心
--time:2018-07-18 02:27:07
--@args:hesinian
--==============================----------------
module("SocialNetworkMgr",package.seeall);
local JSON = require "cjson"
local mRoleId;
local mAccID;
local mToken;
local mFirstTime =true;
local mLogined = false;
--通用请求参数
local mSNSCommonArg = "";

local function Table2String(keyValue)
    local flag,str = xpcall(JSON.encode,traceback,keyValue);
    if not flag then return ""; end
    return str;
end

--断线重连
local function OnAuthenticationExpired(code)
    TipsMgr.TipByFormat("SNS Server Token Expried or Valid "..code);
    mLogined = false;
    RequestAuthentication(successCallback);
end

--发送请求
local function SendRequest(request,action,callback,caller)
    local function OnAction(jsonData,code)
        --收到消息判定
        if (code == 1000021 or code == 1000022) then return OnAuthenticationExpired(code); end
        --非0错误码
        if code ~= 0 then return; end
        if (not jsonData) then return; end
        
        local data = jsonData["result"];
        GameUtils.TryInvokeCallback(callback,caller,data,code,jsonData);
    end
    
    GameNet.SendToHttp(GameConfig.FRIEND_SERVER_URL, request, OnAction);
end

function Init()
    mRoleId = UserData.PlayerID;    
    RequestAuthentication();
    RequestSNSVersion();
end

--登录服务器，获取Token
function RequestAuthentication(successCallback)

    local function OnAuthenticationFinished(jsonData,code)
        if (not code) or code ~= 0 then GameLog.LogError("SNS Autoentication Failed") return; end
        if not jsonData then return; end

        --登录成功
        mAccID = jsonData["result"]["accid"];
        mToken = jsonData["result"]["token"];
        mSNSCommonArg = string.format("accid=%s&token=%s&pid=%s",mAccID,mToken,mRoleId);
        mLogined = true;
        GameLog.Log("SNS Authentication Success");
        if successCallback then
            successCallback();
        end

        --首次登陆初始化社交服
        if mFirstTime then--应该是服务器返回
            mFirstTime = false;
            GameInit.InitSNS();
            
        end
    end

    local request = string.format("action=GuestLogin&deviceid=%s&clientversion=101000&sync=1",mRoleId);
    GameNet.SendToHttp(GameConfig.FRIEND_SERVER_URL, request, OnAuthenticationFinished);
end

function RequestSNSVersion()
    local function OnVersion(data)
        if not data then GameLog.LogError("No SNS Version");end
        local localVersion = VersionData.GetSNSVersion();
        if data.version ~= localVersion then
            GameLog.LogError("SNS Version not Match, server:%s, local:%s",data.version,localVersion);
        end
    end
    GameNet.SendToHttp(GameConfig.SNS_VERSION_URL, "", OnVersion);
end
--[[
@desc: 发送社交服Action请求,默认带有 accid=%s&token=%s&pid=%s
author:{hesinian}
time:2018-12-29 11:37:53
--@action:string，Ex:"GetEmoticonPictureCollect"
--@params:三种参数：或者是字符串；或者 nil；table数组，Ex:{"start=0","cnt=100"};
--@callback:回调，只有errorCode == 0才会调用，如果errorCode ~= 0 则调用提示信息
--@caller: 回调对象
@return:void
]]
function RequestAction(action,params,callback,caller)
    --发送前检验
    if not mLogined then TipsMgr.TipByFormat("SocialNetwork doesn't login");  return; end 
    if not action or action == "" then GameLog.LogError("Action is Null"); return; end
    
    --装配参数
    local request = nil;
    local typeParam = type(params);
    if typeParam == "nil" then
        request = string.format("action=%s&%s",action,mSNSCommonArg);
    elseif typeParam == "string" and params ~= "" then
        request = string.format("action=%s&%s&%s",action,mSNSCommonArg,params);
    elseif typeParam == "table" then
        if #params == 0 then
            request = string.format("action=%s&%s",action,mSNSCommonArg);
        else
            local paramStr = table.concat(params, "&");
            request = string.format("action=%s&%s&%s",action,mSNSCommonArg,paramStr);
        end
    else
        GameLog.LogError("Error params = %s, Type = %s", params, typeParam);
    end

    --发送请求
    SendRequest(request,action,callback,caller);
end

----------------------以下方法移动到个人空间相关的模块----------------------------
--3.	查询多个玩家的信息
function RequestAskMultiPlayerIndex(callback, ids, detailparams,usrdata_fields)
    if type(ids) == "table" then
        ids = table.concat(ids,",");
    end
    if ids == "" then 
        if callback then callback();end
        return;
    end
    local params = string.format("ids=%s&detailparams=%s&usrdata_fields=%s",ids,detailparams,usrdata_fields)
    SocialNetworkMgr.RequestAction("AskMultiPlayerIndex",params,callback);
end

--[[   
action=AskRelatedMoment
cmd=moment_mymoments_custom
start=起始索引
cnt=数量
cmtcnt=留言数量
player_detailparams=玩家基本信息字段列表，按需求填写。具体字段请参照基本信息字段表。
usrdata_fields=玩家自定义信息字段列表，按需求填写。具体字段请参照自定义数据字段表。
]] 
--	玩家本人状态首页
function RequestAskRelatedMoment(callback,start,cnt,cmtcnt,playerdetailparams,usrdata_fields,detailparams)
    local params = string.format("cmd=moment_mymoments_custom&start=%s&cnt=%s&cmtcnt=%s&player_detailparams=%s&usrdata_fields=%s,detailparams=%s",start,cnt,cmtcnt,playerdetailparams,usrdata_fields,detailparams);
    SocialNetworkMgr.RequestAction("AskRelatedMoment",params,callback);
end

--	其他状态首页
function RequestAskMomentHistory(callback,playerid,start,cnt,cmtcnt,detailparams,usrdata_fields)
    local params = string.format("cmd=moment_playermoments_custom&id=%s&start=%s&cnt=%s&cmtcnt=%s&player_detailparams=%s&usrdata_fields=%s",playerid,start,cnt,cmtcnt,detailparams,usrdata_fields);
    SocialNetworkMgr.RequestAction("AskMomentHistory",params,callback);
end

--默认玩家参数信息
function BasicPlayerInfoParam(detailparams,usrdata_fields)
    --playerinfo 参数
    detailparams = detailparams or '"playerid"'
    --userdata 参数
    usrdata_fields = usrdata_fields or '"level"'
    return string.format("detailparams=%s&usrdata_fields=%s",detailparams,usrdata_fields);
end
--默认玩家参数信息，个人空间版
function BasicPlayerDetailParam(detailparams,usrdata_fields)
    detailparams = detailparams or '"playerid,nickname,icon,location"'
    usrdata_fields = usrdata_fields or "";
    return string.format("player_detailparams=%s&usrdata_fields=%s",detailparams,usrdata_fields);
end
