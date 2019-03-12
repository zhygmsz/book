--自己的 玩家社交信息管理
module("SocialPlayerMgr",package.seeall);
local JSON = require "cjson"

--添加玩家的标签 gender，star，others
local function RequestReviseTag(tag,value,call,caller)
    local params = string.format("id=%s&optype=%s&value=%d",GetSelf():GetID(),tag,value);
    SocialNetworkMgr.RequestAction("AddPlayerTag",params,callback);
end
--修改性别请求
function RequestReviseGender(value)
    local function OnRevised(data)
        GetSelf():GetPrivateAttr():SetGender(value);
    end
    RequestReviseTag("gender", value, OnRevised);
end
--修改星座请求
function RequestReviseStar(value)
    local function OnRevised(data)
        GetSelf():GetPrivateAttr():SetStar(value);
    end
    RequestReviseTag("star", value, OnRevised);
end
--修改生日请求
function RequestReviseBirthday(value)
    local function OnRevised(data)
        GetSelf():GetPrivateAttr():SetBirthdayBySecond(value);
    end
    RequestReviseTag("others", value, OnRevised);
end

--照片墙添加照片
function RequestAddPhoto(h,m,l,is_appeal,photo_idx)
    local function callback(data)
        GetSelf():GetPhotoAttr():AddPhoto(data);
    end
    local params = string.format("highqualitysource=%s&mediumqualitysource=%s&lowqualitysource=%s&is_appeal=%s&photo_idx=%s",h,m,l,is_appeal,photo_idx);
    SocialNetworkMgr.RequestAction("AddPhoto",params,callback);
end

--照片墙删除照片
function RequestDelPhoto(ids)
    local function callback(data)
        GetSelf():GetPhotoAttr():DelPhoto(data);
    end
    local params = string.format("photoid=%s",table.concat( ids, ","));
    SocialNetworkMgr.RequestAction("DelPhoto",params,callback);
end

--修改用户自定义字段编辑
function RequestModifyUserDefinedFlag(tagsList)--['"%s":"%s","%s":"%s"']
    local function callback(data)
        GetSelf():GetUserAttr():Refresh(data);
    end
    local jsonInfo = JSON.encode(tagsList);
    local params = string.format("flag_data=%s",jsonInfo)
    SocialNetworkMgr.RequestAction("ModifyUserDefinedFlag",params,callback);
end

-- detailInfo = {"playerid","nickname","icon","location","selfintro","localicon","voicemsg","voicemsglen"},
-- userData = {"world_id","charmingpoint","flowercnt","game_svr_id","level","sex","home","mempai_id","guild_name","spouse_name","title_name"},

--修改玩家自己的社交服数据
function RequestSyncPlayerInfo(infoTable)
    local playerInfo = {};
    local userInfo = {};

    playerInfo.icon = infoTable.icon;
    playerInfo.location = JSON.encode(infoTable.locationStruct);
    playerInfo.selfintro = infoTable.selfintro;
    playerInfo.voicemsg = string.ToBase64(infoTable.voicemsg);
    playerInfo.voicemsglen = infoTable.voicemsglen;

    userInfo.home = infoTable.home;
    userInfo.sex = infoTable.sex;

    local function callback(data)
        local selfPlayerAttr = GetSelf():GetNormalAttr();
        selfPlayerAttr:SetHeadIcon(infoTable.icon);
        selfPlayerAttr:SetSelfintro(infoTable.selfintro);
        selfPlayerAttr:SetVoiceUrl(infoTable.voicemsg);
        selfPlayerAttr:SetVoiceLength(infoTable.voicemsglen);
        selfPlayerAttr:SetHomeTown(infoTable.home);

        selfPlayerAttr:SetLocation(infoTable.locationStruct);
        selfPlayerAttr:SetSex(infoTable.sex);
    end
    local params = string.format("playerinfo=%s&user_data=%s",JSON.encode(playerInfo),JSON.encode(userInfo));
    SocialNetworkMgr.RequestAction("ModifyPlayerMixedData",params,callback);
end

return SocialPlayerMgr