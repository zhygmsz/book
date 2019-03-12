--玩家信息管理
module("SocialPlayerInfoMgr",package.seeall);
local JSON = require "cjson"
--playerinfo 参数
mPlayerInfoKeys = {
    detailInfo = {"playerid","nickname","icon","location","selfintro","localicon","voicemsg","voicemsglen"},
    userData = {"game_svr_id","level","sex","home","mempai_id","guild_name","spouse_name","title_name"},
}

detailparams ='"playerid,playerid,nickname,icon,location,selfintro,localicon,voicemsg,voicemsglen,voicemsglen"'
--userdata 参数
usrdata_fields ='"level,game_svr_id,sex,home,mempai_id,level,guild_name,spouse_name,title_name,title_name"'

local SocialPlayerInfo = require("Logic/System/Social/SocialPlayerInfo")
--玩家信息表
local mPlayerInfoData = {}
--玩家个性标签表
mPlayerTags = {}
--本玩家是否初始化
--mPlayerInfoInited = false
--==============================--
--基础消息接口
--==============================--
--查询玩家数据
function RequestPlayerInfo(callback,playerid,detailparams, usrdata_fields)
    local params = string.format("id=%s&%s",playerid,SocialNetworkMgr.BasicPlayerInfoParam(detailparams,usrdata_fields))
    SocialNetworkMgr.RequestAction("AskPlayerIndex",params,callback);
end

--获取玩家的标签 gender，star，others
function RequestPlayerTag(callback,playerid)
    local params = string.format("id=%s",playerid);
    SocialNetworkMgr.RequestAction("GetPlayerTag",params,callback);
end

--添加玩家的标签 gender，star，others
function RequestAddTag(callback,playerid,tag,value)
    local params = string.format("id=%s&optype=%s&value=%d",playerid,tag,value);
    SocialNetworkMgr.RequestAction("AddPlayerTag",params,callback);
end

--修改玩家社交服数据
--jsonInfo = '{"nickname":"HAHAHA","location":"-1","icon":"aaa.jpg","is_appeal":"0","selfintro":"","localicon":"15","voicemsg":"","voicemsglen":"0"}'
function RequestSyncPlayerInfo(callback,jsonInfo,userInfo)
    local params = string.format("playerinfo=%s&user_data=%s",jsonInfo,userInfo);
    SocialNetworkMgr.RequestAction("ModifyPlayerMixedData",params,callback);
end

--获取玩家照片墙
function RequestAskPersonalPhotoWall(callback,playerid,start,cnt)
    local params = string.format("cmd=player_photowall&id=%s&start=%s&cnt=%s",playerid,start,cnt);
    SocialNetworkMgr.RequestAction("AskPersonalPhotoWall",params,callback);
end

--照片墙添加照片
function RequestAddPhoto(callback,h,m,l,is_appeal,photo_idx)
    local params = string.format("highqualitysource=%s&mediumqualitysource=%s&lowqualitysource=%s&is_appeal=%s&photo_idx=%s",h,m,l,is_appeal,photo_idx);
    SocialNetworkMgr.RequestAction("AddPhoto",params,callback);
end

--照片墙删除照片
function RequestDelPhoto(callback,ids)
    local params = string.format("photoid=%s",ids);
    SocialNetworkMgr.RequestAction("DelPhoto",params,callback);
end

--获取照片信息
function RequestAskPhoto(callback,photoid,ownerid)
    local params = string.format("photoid=%s%ownerid=%s",photoid,ownerid);
    SocialNetworkMgr.RequestAction("AskPhoto",params,callback);
end

--添加经纬度
function RequestAddPlayerLocationInfo(callback,playerid,lat,lng)
    local params = string.format("pid=%s%lat=%s&lng=%s",playerid,lat,lng);
    SocialNetworkMgr.RequestAction("AddPlayerLocationInfo",params,callback);
end

--删除经纬度
function RequestDelPlayerLocationInfo(callback,playerid)
    local params = string.format("pid=%s",playerid)
    SocialNetworkMgr.RequestAction("DelPlayerLocationInfo",params,callback);
end

--用户自定义字段查询
function RequestAskUserDefinedFlag(callback,playerid,flagids)
    local flags = ""
    local comma = ","
    for i,v in ipairs(flagids) do
        if flags=="" then
            comma = ""
        else
            comma = ","
        end
        flags = string.format("%s%s%s",flags,comma,v)
    end
    local params = string.format("id=%s&flag_ids=%s",playerid,flags);
    SocialNetworkMgr.RequestAction("AskUserDefinedFlag",params,callback);
end

--用户自定义字段编辑
function RequestModifyUserDefinedFlag(callback,kvpairs)
    local jsonInfo = ""
    local comma = ","
    for key,value in pairs(kvpairs) do
        if jsonInfo== "" then
            comma=""
        else
            comma = ","
        end
        jsonInfo = string.format('%s%s"%s":"%s"',jsonInfo,comma,key,value)
    end
    
    jsonInfo = string.format('{%s}',jsonInfo)
    local params = string.format("flag_data=%s",jsonInfo)
    SocialNetworkMgr.RequestAction("ModifyUserDefinedFlag",params,callback);
end
--==============================--
--消息函数
--==============================--
--解析玩家数据保存
function AddPlayerInfo(playerid,data)
    if data == nil then return end
    playerid = tonumber(playerid)
    if mPlayerInfoData[playerid]==nil then
        mPlayerInfoData[playerid] = SocialPlayerInfo.new(playerid)
    end
    mPlayerInfoData[playerid]:ParsePlayerInfo(data)
end

--解析玩家标签 保存
function AddPlayerTag(playerid,data)
    if data == nil then return end
    playerid = tonumber(playerid)
    if mPlayerInfoData[playerid]==nil then
        mPlayerInfoData[playerid] = SocialPlayerInfo.new(playerid)
    end
    mPlayerInfoData[playerid]:ParseTagInfo(data)
end

--解析玩家照片墙 保存
function AddPlayerPhotoWall(playerid,data)
    if data == nil then return end
    playerid = tonumber(playerid)
    if mPlayerInfoData[playerid]==nil then
        mPlayerInfoData[playerid] = SocialPlayerInfo.new(playerid)
    end
    mPlayerInfoData[playerid]:ParsePhotoWall(data)
end

--解析玩家个性标签 保存
function AddPlayerCharacterTag(playerid,data)
    if data == nil then return end
    playerid = tonumber(playerid)
    if mPlayerInfoData[playerid]==nil then
        mPlayerInfoData[playerid] = SocialPlayerInfo.new(playerid)
    end
    mPlayerInfoData[playerid]:ParseCharacterTagInfo(data)
end

--添加多个玩家信息到玩家数据列表
function AddPlayerInfos(list)
    if list==nil then return end
    for k,v in pairs(list) do
        AddPlayerInfo(v.playerid,v)
    end
end

 --更新自己玩家信息
function UpdateSelfPlayerInfo()
    UpdatePlayerInfo(UserData.PlayerID)
end

--更新玩家信息
function UpdatePlayerInfo(playerid,callback,caller)
    if playerid==nil or tonumber(playerid)<=0 then return end
    playerid = tonumber(playerid)
    RequestPlayerInfo(function (data,code,jsonData)
        AddPlayerInfo(playerid,data)
        UpdatePlayerTagInfo(playerid,callback,caller)
    end,playerid,detailparams,usrdata_fields)
end

--添加标签 三个标签名任选其一（gender，star，others）
function UpdatePlayerTagInfo(playerid,callback,caller)
    if playerid==nil or tonumber(playerid)<=0  then return end
    playerid = tonumber(playerid)
    RequestPlayerTag(function(data,code,jsonData)
        AddPlayerTag(playerid,data)
        UpdatePersonalPhotoWall(playerid,callback,caller)
    end,playerid)
end

--获取玩家照片墙
function UpdatePersonalPhotoWall(playerid,callback,caller)
    RequestAskPersonalPhotoWall(function(data,code,jsonData)
        AddPlayerPhotoWall(playerid,data)
        UpdatePlayerCharacterTagInfo(playerid,callback,caller)
    end,playerid,0,3)
end

--个性标签
function UpdatePlayerCharacterTagInfo(playerid,callback,caller)
    if playerid==nil or tonumber(playerid)<=0  then return end
    playerid = tonumber(playerid)
    RequestAskUserDefinedFlag(function (data,code,jsonData)
        AddPlayerCharacterTag(playerid,data)
        GameUtils.TryInvokeCallback(callback,caller,playerid,mPlayerInfoData[playerid]);
        GameEvent.Trigger(EVT.PSPACE,EVT.PS_UPDATEPLAYERINFO,playerid,mPlayerInfoData[playerid]);
    end,playerid,{10000,10001,10002,10003,10004,10005,10006,10007,10008,10009,
    10010,10011,10012,10013,10014,10015,10016,10017,10018,10019,
    10020,10021,10022,10023,10024,10025,10026,10027,10028,10029,
    10030,10031,10032,10033,10034,10035,10036,10037,10038,10039,
    10040,10041,10042,10043,10044,10045,10046,10047,10048,10049,
    10050,10051,10052,10053,10054
})
end

--获取多个玩家信息
function UpdateMultiPlayerInfo(ids,callback,caller)
    SocialNetworkMgr.RequestAskMultiPlayerIndex(function (data,code,jsonData)
        if data then
            for _, item in pairs(data) do
                if item.playerid then 
                    AddPlayerInfo(item.playerid,item);
                end
            end
            local datas = {}
            for i=1,#ids do
                datas[i]=mPlayerInfoData[tonumber(ids[i])]
            end
            GameUtils.TryInvokeCallback(callback,caller,ids,datas);
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_UPDATEPLAYERINFOLIST,ids);
        end
    end,ids,detailparams,usrdata_fields)
end
--==============================--
--调用函数
--==============================--
--初始化
function InitModule()
    
end

function InitSNS()
    mCurrentShowPlayerId = tonumber(UserData.PlayerID)
  --  local key = string.format("PlayerInfoInited-%s",tostring(UserData.PlayerID))
  --  mPlayerInfoInited =UserData.HasConfig(key) and UserData.ReadBoolConfig(key) or false
   -- if mPlayerInfoInited == false then
        local nickName = UserData.GetName();
        local playerId=tonumber(UserData.PlayerID)
        local level = UserData.GetLevel()
        local game_svr_id = UserData.GetServerId()
        local localicon = UserData.PlayerAtt.playerData.headIcon;
        local jsonInfo = string.format('{"playerid":"%s","nickname":"%s","localicon":"%s"}',playerId,nickName,localicon)
        local fields =string.format('{"level":%d,"game_svr_id":"%s"}',level,game_svr_id)

        RequestSyncPlayerInfo(function ()
           -- SocialPlayerInfoMgr.mPlayerInfoInited = true
         --   UserData.WriteBoolConfig(key,true)
            UpdatePlayerInfo(UserData.PlayerID)
        end,jsonInfo,fields)
   -- else
    --    UpdatePlayerInfo(UserData.PlayerID)
   -- end
   --服务器处理了信息同步
   --GameEvent.Reg(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL,OnPlayerLevelUp);
end

-- function OnPlayerLevelUp()
--     GetSelfPlayerInfo(function (playerid,playerInfo)
--         local level = UserData.GetLevel()
--         playerInfo:SaveLevel(level,true)
--     end)
-- end

--获取个人玩家信息 返回值类型SocialPlayerInfo 回调函数 callback(playerid,SocialPlayerInfo)
function GetSelfPlayerInfo(callback)
    return GetPlayerInfoById(UserData.PlayerID,callback)
end

--获取玩家信息 返回值类型SocialPlayerInfo 回调函数 callback(playerid,SocialPlayerInfo)
--不传回调函数 直接返回缓存的数据 
--传了回调函数 若缓存数据为空 拉去服务器数据调用回电函数 否者直接调用回调函数传入缓存数据
function GetPlayerInfoById(playerid,callback,caller)
    if playerid==nil  or tonumber(playerid)<=0 then return end
    playerid = tonumber(playerid)
    if mPlayerInfoData[playerid] and callback == nil then return mPlayerInfoData[playerid] end
    if mPlayerInfoData[playerid] and callback then
        GameUtils.TryInvokeCallback(callback,caller,playerid,mPlayerInfoData[playerid]);
        return;
    end
    UpdatePlayerInfo(playerid,callback,caller)
end

function Clear()
    local selfinfo ={}
    selfinfo = mPlayerInfoData[tonumber(UserData.PlayerID)]
    mPlayerInfoData={}
    mPlayerInfoData[tonumber(UserData.PlayerID)] = selfinfo
end

return SocialPlayerInfoMgr