--[[
    author:{hesinian}
    time:2019-01-21 18:24:38
]]

local PlayerNormalAttr = class("PlayerNormalAttr",PlayerBaseAttr)

function PlayerNormalAttr:ctor(player)
    self.super.ctor(self, player);
    self._limitTime = 60 * 10;
    self._racialID = nil;
    self._profesID = nil;

    --'world_id'???????
    self._detailparams = 'nickname,icon,location,selfintro,voicemsg,voicemsglen';--昵称，社交头像，位置，自我介绍，声音，声音长度
    self._userparams = 'role_id,game_svr_id,sex,home,mempai_id,guild_name,spouse_name,title_name';--服务器id,社交性别,家乡，门派id，工会名，伴侣名，称号名
    --userData = {"world_id","charmingpoint","flowercnt","game_svr_id","level","sex","home","mempai_id","guild_name","spouse_name","title_name"},
    --需要的 role_id=racialID, profesID, spouseID, 
end

function PlayerNormalAttr:RequestSyncAttr()
    local function OnSyncFriendAttr(data)
        self:Refresh(data);
        GameEvent.Trigger(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self._player);
    end
    local params = string.format("id=%s&detailparams=%s&usrdata_fields=%s",self._id, self._detailparams,self._userparams)
    SocialNetworkMgr.RequestAction("AskPlayerIndex",params,OnSyncFriendAttr);
end

function PlayerNormalAttr:Refresh(data)
    self.super.Refresh(self);
    self._proxy.nickname = data.nickname;--不更新
    self._racialID = tonumber(data.role_id);
    self:CheckNil(self._racialID, "role_id");
    self._profesID = tonumber(data.mempai_id);
    self:CheckNil(self._profesID, "mempai_id");
    if self._racialID and self._profesID then
        self._localIcon = nil;
    end
    self._realTable.icon = data.icon;
    self._realTable.locationStruct = self:ParseLocationInfo(data.location);
    self._realTable.selfintro = data.selfintro;
    
    self._realTable.voicemsgurl = string.FromBase64(data.voicemsg);
    self._realTable.voicemsglen = data.voicemsglen;

    self._proxy.game_svr_id = data.game_svr_id;
    self._realTable.sex = tonumber(data.sex or 2);
    self._realTable.home = data.home;

    self._realTable.guild_name = data.guild_name;
    self._realTable.spouse_name = data.spouse_name;
    self._realTable.title_name = data.title_name;
end


function PlayerNormalAttr:ParseLocationInfo(locationInfo)
    if type(locationInfo) == "string" and locationInfo ~= "" and locationInfo ~= "-1" then
        local flag,jsonData = xpcall(JSON.decode,traceback,string.FromBase64(locationInfo));
        if flag and jsonData~=nil and jsonData~=-1 then
            return jsonData;
        end
    end
end

function PlayerNormalAttr:GetName()
    return self._proxy.nickname or self._id;
end
function PlayerNormalAttr:SetName(name)
    self._proxy.nickname = name;
end

function PlayerNormalAttr:SetRacialProfess(racialID,profesID)
    self._racialID = racialID;
    self._profesID = profesID;
end

function PlayerNormalAttr:GetNickName()
    return self:GetName();
end
--头像，在图片数组中的索引,nil表示没有设置头像
function PlayerNormalAttr:GetHeadIcon()
    return self._proxy.icon;
end

function PlayerNormalAttr:GetSelfintro()
    return self._proxy.selfintro;
end
--游戏服头像
function PlayerNormalAttr:GetLocalicon()
    if not self._localIcon then
        local resTable = ProfessionData.GetProfessionResByRacialProfession(self._racialID, self._profesID);
        self._localIcon = resTable and resTable.headIcon;
    end
    if not self._localIcon then return ConfigData.GetIntValue("social_player_default_icon_id"); end--默认头像
    return self._localIcon;

end

function PlayerNormalAttr:GetVoiceUrl()
    return self._proxy.voicemsgurl;
end

function PlayerNormalAttr:GetVoiceLength()
    return self._proxy.voicemsglen or 0;
end
function PlayerNormalAttr:GetServerId()
    return self._proxy.game_svr_id or 0;
end
--是否同服，非跨服,后期还有合服的变动
function PlayerNormalAttr:IsSameServer( )
    return self:GetServerId() == UserData.GetServer():GetID();
end
--队伍信息
function PlayerNormalAttr:GetTeamInfo()
    return "none";
end
--性别
function PlayerNormalAttr:GetRoleGender()
    return self._proxy.sex or 2;
end
function PlayerNormalAttr:GetHomeTown()
    return self._proxy.home or "";
end
--门派
function PlayerNormalAttr:GetMenpaiID()
    return self._profesID;
end
function PlayerNormalAttr:GetMenpaiName()
    return "menpai";
end
--工会
function PlayerNormalAttr:GetGuildName()
    return self._proxy.guild_name or 0;
end
--伴侣名
function PlayerNormalAttr:GetSpouseName()
    return self._proxy.spouse_name or "";
end
--称号名（有问题的）
function PlayerNormalAttr:GetTitleName()
    return self._proxy.title_name or "";
end


--获取地理位置信息结构 {adcode=1,coordinate=Vector2(0,0),address=""}
function PlayerNormalAttr:GetLocation()
    return self._proxy.locationStruct or {adcode=1101,coordinate=Vector2(116.40,39.90),address=""};
end

--获取地理位置信息结构 {adcode=1,coordinate=Vector2(0,0),address=""}
function PlayerNormalAttr:GetLocationAddress()
    return self:GetLocation().address
end
function PlayerNormalAttr:GetCityCode()
    return self:GetLocation().adcode
end
function PlayerNormalAttr:GetProvinceCode()
    return LocationData.GetProvinceID(self:GetLocation().adcode)
end
function PlayerNormalAttr:GetProvinceName()
    local pid = LocationData.GetProvinceID(self:GetLocation().adcode)
    return LocationData.GetProvinceName(pid)
end
function PlayerNormalAttr:GetCityName()
    return LocationData.GetCityName(self:GetLocation().adcode)
end
function PlayerNormalAttr:GetLocationNotice()
    return "LocationNotice";
end
function PlayerNormalAttr:GetCoordinate()
    return self:GetLocation().coordinate
end
--阵营
function PlayerNormalAttr:GetFactionID()
    return 1;--没做
end
--阵营
function PlayerNormalAttr:GetFactionNotice()
    return "none notice";
end

function PlayerNormalAttr:GetAchieveStars()
    return 0;
end

return PlayerNormalAttr;