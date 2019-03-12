local JSON = require "cjson"
--playerinfo 参数
local mPlayerInfoKeys = {
    detailInfo = {"playerid","nickname","icon","location","selfintro","localicon","voicemsg","voicemsglen"},
    userData = {"world_id","charmingpoint","flowercnt","game_svr_id","level","sex","home","mempai_id","guild_name","spouse_name","title_name"},
}

--添加标签 三个标签名任选其一（gender，star，others）
local function SaveTag(playerid,tag,value)
    SocialPlayerInfoMgr.RequestAddTag(nil,playerid,tag,value)
end

local function SaveCharacterTags(playerid,beginindex,tags)
    local kvpairs = {}
    for i,v in ipairs(tags) do
        kvpairs[beginindex+i] = v
    end
    SocialPlayerInfoMgr.RequestModifyUserDefinedFlag(function (data,code,jsonData)
        if code == 0 then
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_SETPLAYERTAGS,playerid,tags);
        end
    end,kvpairs)
end

--设置个人信息
local function SavePlayerInfo(playerId,kvpairs)
    local jsonInfo = ""
    local usrdata_fields= ""
    for key,value in pairs(kvpairs) do
        if table.contains_value(mPlayerInfoKeys.detailInfo,key) and key~="playerid" then
            jsonInfo = string.format('%s,"%s":"%s"',jsonInfo,key,value)
        end
        if table.contains_value(mPlayerInfoKeys.userData,key) then
            local comma =","
            if usrdata_fields== "" then
                comma=""
            end
            usrdata_fields = string.format('%s%s"%s":"%s"',usrdata_fields,comma,key,value)
        end
    end
    jsonInfo = string.format('{"playerid":"%s"%s}',playerId,jsonInfo)
    usrdata_fields = string.format('{%s}',usrdata_fields)
    SocialPlayerInfoMgr.RequestSyncPlayerInfo(function(data,code,jsonData)
        if code == 0 then
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_SETPLAYERINFO,playerId);
        end
    end,jsonInfo,usrdata_fields)
end

local function SavePhoto(playerId,h,m,l,is_appeal,photo_idx)
    SocialPlayerInfoMgr.RequestAddPhoto(function(data,code,jsonData)
        if code == 0 then
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_SETPLAYERINFO,playerId);
        end
    end,h,m,l,is_appeal,photo_idx)
end

local function DelPhoto(playerId,ids)
    SocialPlayerInfoMgr.RequestDelPhoto(function(data,code,jsonData)
        if code == 0 then
           -- GameEvent.Trigger(EVT.PSPACE,EVT.PS_SETPLAYERINFO,playerId);
        end
    end,ids)
end


--社交玩家信息类
local SocialPlayerInfo = class("SocialPlayerInfo",nil)

function SocialPlayerInfo:ctor(id,info,tag,photowall)
    self._id = tonumber(id)
    self._info ={playerid="",nickname="",icon="",location="",selfintro="",localicon="",voicemsg="",voicemsglen=0,level=1,flowercnt=0,charmingpoint=0,world_id=0,sex=2,home="",mempai_id=1,guild_name="",spouse_name="",title_name="",game_svr_id=""}
    self._info.playerid= self._id
    self._info.locationStruct = {adcode=1101,coordinate=Vector2(116.40,39.90),address=""}
    self._info.voicemsgurl=""
    if info then
        self:ParsePlayerInfo(info)
    end
    self._tag = {star = 1,gender =2,others =1}
    self._tag.birth = TimeUtils.TimeStamp2Date(self._tag.others,true);
    if tag then
        self:ParseTagInfo(tag)
    end
    self._photos ={}
    if photowall then
        self:ParsePhotoWall(photowall)
    end
    self.mGetInfoFuncs ={
        [1] = self.GetPlayerId,
        [2] = self.GetNickName,
        [3] = self.GetBirthdayString,
        [4] = self.GetConstellationName,
        [5] = self.GetLocationAddress,
        [6] = self.GetSpouseName,
        [7] = self.GetTitleName,
        [8] = self.GetGuildName,
        [9] = self.GetGuildName
    }
    self._characterTag ={}
    self._characterTagFromOther ={}
    self._systemTag ={}
    self._systemTagShowing ={}
end

--解析照片墙
--{"highqualitysource":"aaa","mediumqualitysource":"bbb","lowqualitysource":"ccc","createtime":1525783541,"photoid":"2","viewcnt":"0","likecnt":"0","verify":"2","likedbyme":0,"viewedbyme":0}
function SocialPlayerInfo:ParsePhotoWall(photowall)
    self._photos = {}
    self._basePth ="http://ldj-1255801262.file.myqcloud.com/"
    for i,v in ipairs(photowall) do
        self._photos[v.photoid] = v
    end
    return self._photos
end

--解析地理位置信息
function SocialPlayerInfo:ParseLocationInfo(playerInfo)
    local locationstruct = {adcode=1101,coordinate=Vector2(116.40,39.90),address=""}
    if type(playerInfo.location) == "string" and playerInfo.location ~= "" and playerInfo.location ~= "-1" then
        local flag,jsonData = xpcall(JSON.decode,traceback,string.FromBase64(playerInfo.location));
        if flag and jsonData~=nil and jsonData~=-1 then
            locationstruct = jsonData
        end
    end
    return locationstruct
end

--解析地理位置信息
function SocialPlayerInfo:ParseVoiceUrl(playerInfo)
    local voicemsgurl = string.FromBase64(playerInfo.voicemsg)
    return voicemsgurl
end

--解析玩家信息
function SocialPlayerInfo:ParsePlayerInfo(info)
    if info==nil then return self._info end
    self._info = info
    self._id = tonumber(self._info.playerid) or self._id
    self._info.playerid=info.playerid or self._id
    self._info.nickname=info.nickname or ""
    self._info.selfintro=info.selfintro or ""
    self._info.localicon=info.localicon or ""
    self._info.icon = info.icon or ""

    self._info.voicemsglen=info.voicemsglen or 0
    self._info.level= tonumber(info.level) or 1
    self._info.flowercnt=info.flowercnt or 0
    self._info.charmingpoint=info.charmingpoint or 0
    self._info.world_id=info.world_id or ""
    self._info.sex=info.sex or 2
    self._info.home=info.home or ""
    self._info.mempai_id=info.mempai_id or 1
    self._info.title_name=info.title_name or ""
    self._info.spouse_name=info.spouse_name or ""
    self._info.guild_name=info.guild_name or ""
    self._info.game_svr_id = info.game_svr_id or ""
    
    self._info.locationStruct = self:ParseLocationInfo(self._info)
    self._info.voicemsgurl = self:ParseVoiceUrl(self._info)
    self._info.onlineStatus = info.OnlineStatus

    return self._info
end

function SocialPlayerInfo:UpdatePlayerInfo(info)
    
end

--解析玩家标签信息
function SocialPlayerInfo:ParseTagInfo(tag)
    if tag==nil then return self._tag end
    self._tag.star = tag["61"]
    self._tag.gender = tag["60"]
    self._tag.others = tag["69"]
    self._tag.birth = TimeUtils.TimeStamp2Date(self._tag.others,true);
    return self._tag
end

--解析玩家个性标签信息
function SocialPlayerInfo:ParseCharacterTagInfo(characterTag)
    if characterTag==nil then return self._characterTag end
    self._characterTag ={}
    self._characterTagFromOther ={}
    self._systemTag ={}
    self._systemTagShowing ={}
    local datas = characterTag[tostring(self._id)]
    for k,v in pairs(datas) do
        local index = tonumber(k)
        if index>=10000 and index <=10009 then
            table.insert(self._characterTag,v)
        elseif index>=10010 and index <=10019 then
            table.insert(self._characterTagFromOther,v)
        elseif index>=10020 and index <=10029 then
            table.insert(self._systemTagShowing,v)
        elseif index>=10030 and index <=10054 then
            table.insert(self._systemTag,v)
        end
    end
    return self._characterTag
end


function SocialPlayerInfo:GetID()
    return tonumber(self._id)
end
--星座
function SocialPlayerInfo:GetPlayerId()
    return self._id
end
function SocialPlayerInfo:IsSelf()
    return self._id == UserData.PlayerID;
end

--星座
function SocialPlayerInfo:GetStar()
    return self._tag.star
end

--星座 send是否发送至服务器
function SocialPlayerInfo:SaveStar(star,send)
    self._tag.star = star
    if send then   SaveTag(self._id,"star",self._tag.star) end
end

--玩家性别
function SocialPlayerInfo:GetGender()
    return tonumber(self._tag.gender)
end

--保存性别
function SocialPlayerInfo:SaveGender(sex,send)
    self._tag.gender =sex
    if send then SaveTag(self._id,"gender",self._tag.gender) end
end

--在线状态
function SocialPlayerInfo:GetOnlineStatus()
    local ret = self._info.onlineStatus and self._info.onlineStatus or false
    return ret
end

--生日结构                                                            
function SocialPlayerInfo:GetBirthday()
    return self._tag.birth
end

--获取生日字符串
function SocialPlayerInfo:GetBirthdayString()
    local str= string.format("%s-%s-%s",self._tag.birth.year,self._tag.birth.month,self._tag.birth.day)
    return str 
end

--保存生日
function SocialPlayerInfo:SaveBirthday(ayear,amonth,aday,send)
    self._tag.birth = {year = ayear,month = amonth, day = aday}
    local str =  TimeUtils.Date2TimeStamp(self._tag.birth,true);
    self._tag.others = str
    if send then SaveTag(self._id,"others",str) end
end

--得到星座名称
function SocialPlayerInfo:GetConstellationName()
    return TipsMgr.GetTipByKey(string.format("system_constellation_name_%d",self._tag.star))
end

--星座提示
function SocialPlayerInfo:GetZodiacNotice()
    return "none notice";
end

--阵营
function SocialPlayerInfo:GetFactionID()
    return 1;--没做
end

--阵营
function SocialPlayerInfo:GetFactionNotice()
    return "none notice";
end

--共同好友数量
function SocialPlayerInfo:GetShareFriends()
    return table.emptyTable;
end

--保存头像
function SocialPlayerInfo:SaveHeadIcon(photoid,send)
    self._info.icon = photoid
    if send then SavePlayerInfo(self._id,{icon = self._info.icon}) end
end

function SocialPlayerInfo:GetHeadIcon()
    return self._info.icon
end

--获取照片墙数组
function SocialPlayerInfo:GetPhotoWall()
    local plist ={}
    for k,v in pairs(self._photos) do
        table.insert(plist,v)
    end
    return plist;
end

--本地头像
function SocialPlayerInfo:GetLocalicon()
    if self._info.localicon== "" then self._info.localicon = UserData.PlayerAtt.playerData.headIcon end
    return self._info.localicon
end

function SocialPlayerInfo:GetDefaultHeadIconURL()
    local key = self._info.icon
    local info = self._photos[key]
    local url  =""
    if info then
        url = string.format("%s%s",self._basePth,info.highqualitysource)
    end
    return url
end

--获取照片墙的第几个
function SocialPlayerInfo:GePhotoByPhotoId(photoid)
    return self._photos[photoid]
end

--获取照片墙的第几个
function SocialPlayerInfo:GePhotoURLByPhotoId(photoid)
    local info = self._photos[photoid]
    local url  =""
    if info then
        url = string.format("%s%s",self._basePth,info.highqualitysource)
    end
    return url
end
--获取照片数组
function SocialPlayerInfo:GePhotoURLs()
    local plist ={}
    for pid,info in pairs(self._photos) do
        if info then
            local url = string.format("%s%s",self._basePth,info.highqualitysource);
            table.insert(plist,url);
        end
    end
    return plist;
end

--保存
function SocialPlayerInfo:AddPhoto(largename,midname,smallname,is_appeal,index)
   -- SavePhoto(self._id,name,midname,smallname,0,index)
    SocialPlayerInfoMgr.RequestAddPhoto(function(data,code,jsonData)
        if code == 0 then
            self:ParsePhotoWall({data})
            if self._info.icon == "" then
               self:SaveHeadIcon(data.photoid,true)
            end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_SETPLAYERINFO,playerId);
        end
    end,largename,midname,smallname,is_appeal,index)
end

--删除
function SocialPlayerInfo:DelPhoto(photoids)
    local photoidstring = ""
    for i,v in ipairs(photoids) do
        local comma =","
        if photoidstring== "" then
            comma=""
        end
        photoidstring = string.format('%s%s%d',photoidstring,comma,v)
    end
    SocialPlayerInfoMgr.RequestDelPhoto(function(data,code,jsonData)
        if code == 0 then
            for i,v in ipairs(data.deletedlist) do
                self._photos[v] = nil
            end
            if data.icon_deleted == 1 then--删除了头像
                if data.delIcon == self._info.icon then
                    self._info.icon = "" --data.delIcon删除的头衔photoid
                end
            end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_SETPLAYERINFO,playerId);
        end
    end,photoidstring)
end

--获取地理位置信息结构 {adcode=1,coordinate=Vector2(0,0),address=""}
function SocialPlayerInfo:GetLocation()
    return self._info.locationStruct
end

--获取地理位置信息结构 {adcode=1,coordinate=Vector2(0,0),address=""}
function SocialPlayerInfo:GetLocationAddress()
    return self._info.locationStruct.address
end

function SocialPlayerInfo:GetCityCode()
    return self._info.locationStruct.adcode
end

function SocialPlayerInfo:GetProvinceCode()
    return LocationData.GetProvinceID(self._info.locationStruct.adcode)
end

function SocialPlayerInfo:GetProvinceName()
    local pid = LocationData.GetProvinceID(self._info.locationStruct.adcode)
    return LocationData.GetProvinceName(pid)
end

function SocialPlayerInfo:GetCityName()
    return LocationData.GetCityName(self._info.locationStruct.adcode)
end
function SocialPlayerInfo:GetLocationNotice()
    return "LocationNotice";
end
function SocialPlayerInfo:GetCoordinate()
    return self._info.locationStruct.coordinate
end

function SocialPlayerInfo:SaveCoordinate(lat,lon,send)
    self._info.locationStruct.coordinate = Vector2(lat,lon)
    self:SaveLocation(self._info.locationStruct,send)
end

function SocialPlayerInfo:SaveAddress(address,send)
    self._info.locationStruct.address = address
    self:SaveLocation(self._info.locationStruct,send)
end

function SocialPlayerInfo:SaveCityCode(code,send)
    self._info.locationStruct.adcode=code
    self:SaveLocation(self._info.locationStruct,send)
end


--保存地理位置信息结构 {adcode=1,coordinate=Vector2(0,0),address=""}
function SocialPlayerInfo:SaveLocation(locationStruct,send)
    self._info.locationStruct=locationStruct
    local locationData = JSON.encode(self._info.locationStruct)
    local content = string.ToBase64(locationData)
    self._info.location = content
    if send then SavePlayerInfo(self._id,{location = self._info.location}) end
end

--获取签名 
function SocialPlayerInfo:GetSelfintro()
    return self._info.selfintro
end

--获取签名 
function SocialPlayerInfo:SaveSelfintro(intro,send)
    self._info.selfintro=intro
    if send then SavePlayerInfo(self._id,{selfintro = self._info.selfintro}) end
end

--获取语音留言链接
function SocialPlayerInfo:GetVoiceUrl()
    return self._info.voicemsgurl
end

--获取语音留言链接
function SocialPlayerInfo:SaveVoiceUrl(url,send)
    self._info.voicemsgurl = url
    self._info.voicemsg = string.ToBase64(url)
    if send then SavePlayerInfo(self._id,{voicemsg = self._info.voicemsg}) end
end

--获取语音签名长度
function SocialPlayerInfo:GetVoiceLength()
   return self._info.voicemsglen
end

--语音签名长度
function SocialPlayerInfo:SaveVoiceLength(len,send)
    self._info.voicemsglen=len
    if send then SavePlayerInfo(self._id,{voicemsglen = self._info.voicemsglen}) end
end
--昵称
function SocialPlayerInfo:GetNickName()
    return self._info.nickname
end
--昵称
function SocialPlayerInfo:SaveNickName(newnickname,send)
    self._info.nickname=newnickname
    if send then SavePlayerInfo(self._id,{nickname = self._info.nickname}) end
end
--等级
function SocialPlayerInfo:GetLevel()
    return tonumber(self._info.level) or 1
end
 
 --等级
function SocialPlayerInfo:SaveLevel(newlevel,send)
    self._info.level=tonumber(newlevel)
    if send then SavePlayerInfo(self._id,{level = self._info.level}) end
end

--获取游戏服务器
function SocialPlayerInfo:GetServerId()
    return self._info.game_svr_id
end

--保存游戏服务器
function SocialPlayerInfo:SaveServerId(id)
    self._info.game_svr_id=newworldid
    if send then SavePlayerInfo(self._id,{game_svr_id = self._info.game_svr_id}) end
end

--世界服务器
function SocialPlayerInfo:GetWorldId()
    return self._info.world_id or ""
end

 --世界服务器
function SocialPlayerInfo:SaveWorldId(newworldid,send)
    self._info.world_id=newworldid
    if send then SavePlayerInfo(self._id,{world_id = self._info.world_id}) end
end
--队伍信息
function SocialPlayerInfo:GetTeamInfo()
    return "none";
end

--门派
function SocialPlayerInfo:GetMenpaiID()
    return self._info.mempai_id or ""
end
 --门派
function SocialPlayerInfo:SaveMenpaiID(newmempaiid,send)
    self._info.mempai_id=newmempaiid
    if send then SavePlayerInfo(self._id,{mempai_id = self._info.mempai_id}) end
end
function SocialPlayerInfo:GetMenpaiName()
    return "menpai";
end
--工会
function SocialPlayerInfo:GetGuildName()
    return self._info.guild_name or ""
end
 --工会
function SocialPlayerInfo:SaveGuildName(newguildname,send)
    self._info.guild_name=newguildname
    if send then SavePlayerInfo(self._id,{guild_name = self._info.guild_name}) end
end
--伴侣
function SocialPlayerInfo:GetSpouseName()
    return self._info.spouse_name or ""
end
--伴侣
function SocialPlayerInfo:SaveSpouseName(newSpouseName,send)
    self._info.spouse_name=newSpouseName
    if send then SavePlayerInfo(self._id,{spouse_name = self._info.spouse_name}) end
end
--称号
function SocialPlayerInfo:GetTitleName()
    return self._info.title_name or ""
end
--称号
function SocialPlayerInfo:SaveTitleName(newtitlename,send)
    self._info.title_name=newtitlename
    if send then SavePlayerInfo(self._id,{title_name = self._info.title_name}) end
end
--家乡
function SocialPlayerInfo:GetHomeTown()
    return self._info.home or ""
end
--家乡
function SocialPlayerInfo:SaveHomeTown(HomeTown,send)
    self._info.home=HomeTown
    if send then SavePlayerInfo(self._id,{home = self._info.home}) end
end
--角色性别
function SocialPlayerInfo:GetRoleGender()
    return tonumber(self._info.sex or 2)
end
--角色性别
function SocialPlayerInfo:SaveRoleGender(newsex,send)
    self._info.sex=newsex
    if send then SavePlayerInfo(self._id,{sex = self._info.sex}) end
end

--好友亲密度
function SocialPlayerInfo:GetIntimacy()
    return self._info.intimacy;
end
--聊天热度
function SocialPlayerInfo:GetIntimacy()
    return self._info.heat;
end

--个人信息显示按顺序获取
function SocialPlayerInfo:GetInfoByIndex(index)
    return self.mGetInfoFuncs[index](self)
end

--个性标签
function SocialPlayerInfo:GetCharacterTags()
    local allnum =table.getn(self._characterTag)
    local temptags ={}
    for i=1,allnum do
        if self._characterTag[i]>0 then
            table.insert(temptags,self._characterTag[i])
        end
    end
    return temptags
end

function SocialPlayerInfo:SaveCharacterTags(newtags,send)
    local n=table.count(self._characterTag)
    for i=1,n do
        if newtags[i] then
            self._characterTag[i]=newtags[i]
        else
            self._characterTag[i]=0
        end
    end
    if send then SaveCharacterTags(self._id,9999,self._characterTag) end
end

--别人给的个性标签
function SocialPlayerInfo:GetCharacterTagsFromOther()
    local allnum =table.getn(self._characterTagFromOther)
    local temptags ={}
    for i=1,allnum do
        if self._characterTagFromOther[i]>0 then
            table.insert(temptags,self._characterTagFromOther[i])
        end
    end
    return temptags
end

function SocialPlayerInfo:SaveCharacterTagsFromOther(newtags,send)
    local n=table.count(self._characterTagFromOther)
    for i=1,n do
        if newtags[i] then
            self._characterTagFromOther[i]=newtags[i]
        else
            self._characterTagFromOther[i]=0
        end
    end
    if send then SaveCharacterTags(self._id,10009,self._characterTagFromOther) end
end

--系统给的个性标签
function SocialPlayerInfo:GetCharacterTagsFromSystem()
    local allnum =table.getn(self._systemTag)
    local temptags ={}
    for i=1,allnum do
        if self._systemTag[i]>0 then
            table.insert(temptags,self._systemTag[i])
        end
    end
    return temptags
end

function SocialPlayerInfo:SaveCharacterTagsFromSystem(newtags,send)
    local n=table.count(self._systemTag)
    for i=1,n do
        if newtags[i] then
            self._systemTag[i]=newtags[i]
        else
            self._systemTag[i]=0
        end
    end
    if send then SaveCharacterTags(self._id,10029,self._systemTag) end
end

--系统给的个性标签
function SocialPlayerInfo:GetCharacterTagsFromSystemShowing()
    local allnum =table.getn(self._systemTagShowing)
    local temptags ={}
    for i=1,allnum do
        if self._systemTagShowing[i]>0 then
            table.insert(temptags,self._systemTagShowing[i])
        end
    end
    return temptags
end

function SocialPlayerInfo:SaveCharacterTagsFromSystemShowing(newtags,send)
    local n=table.count(self._systemTagShowing)
    for i=1,n do
        if newtags[i] then
            self._systemTagShowing[i]=newtags[i]
        else
            self._systemTagShowing[i]=0
        end
    end
    if send then SaveCharacterTags(self._id,10019,self._systemTagShowing) end
end

--保存角色信息
function SocialPlayerInfo:Save()
    local locationData = JSON.encode(self._info.locationStruct)
    local content = string.ToBase64(locationData)
    self._info.location = content
    self._info.voicemsg =string.ToBase64(self._info.voicemsgurl)
    SavePlayerInfo(self._id,self._info)
    SaveTag(self._id,"star",self._tag.star)
    SaveTag(self._id,"gender",self._tag.gender)
    local str = TimeUtils.Date2TimeStamp(self._tag.birth,true);
    self._tag.others = str
    SaveTag(self._id,"others",str)
    local temp = {}
    local index  =1
    for i=1,#self._characterTag do
        temp[index] = self._characterTag[i]
        index=index+1
    end
    for i=1,#self._characterTagFromOther do
        temp[index] = self._characterTagFromOther[i]
        index=index+1
    end
    for i=1,#self._systemTagShowing do
        temp[index] = self._systemTagShowing[i]
        index=index+1
    end
    for i=1,#self._systemTag do
        temp[index] = self._systemTag[i]
        index=index+1
    end
    SaveCharacterTags(self._id,9999,temp)
    -- SaveCharacterTags(self._id,9999,self._characterTag)
    -- SaveCharacterTags(self._id,10009,self._characterTagFromOther)
    -- SaveCharacterTags(self._id,10019,self._systemTagShowing)
    -- SaveCharacterTags(self._id,10029,self._systemTag)
end

function SocialPlayerInfo:SaveAchieveScore(score)
end
function SocialPlayerInfo:GetAchieveStars()
    if self:IsSelf() then
        return AchievementMgr.GetFinishedStars();
    else
        return self._achieveScore or 0;
    end
end
--获得好友相关组件
function SocialPlayerInfo:GetFriendCom()
    return FriendMgr.FindMemberByID(self._id,self);
end
--设置玩家头像的帮助办法
function SocialPlayerInfo:SetHeadIcon(iconTexture,iconSprite)
    local url = self:GetDefaultHeadIconURL()
    if url and url ~="" then 
        iconTexture.gameObject:SetActive(true);
        --iconSprite.gameObject:SetActive(false);
        UIUtil.LoadImage(iconTexture,{compressRatio=100,width=1024,height=1024},url,true);
    else
        iconTexture.gameObject:SetActive(true);
        --iconSprite.gameObject:SetActive(false);
        --iconSprite.spriteName = self:GetLocalicon();
        local loadResID = self:GetLocalicon();
        UIUtil.SetTexture(loadResID,iconTexture)
    end
end

return SocialPlayerInfo