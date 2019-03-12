--[[
    author:{hesinian}
    time:2019-01-21 18:24:38
]]
local PlayerNormalAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerNormalAttr");
local PlayerSelfNormalAttr = class("PlayerSelfNormalAttr",PlayerNormalAttr)

function PlayerSelfNormalAttr:ctor(player)
    PlayerBaseAttr.ctor(self, player);
    self._limitTime = TimeUtils.SystemTimeStamp(true)-1;--只触发一次
    self._detailparams = '"icon,selfintro,voicemsg,voicemsglen"';--社交头像，自我介绍，声音，声音长度
    self._userparams = '"sex,home"';--,社交性别,家乡，
end

function PlayerSelfNormalAttr:Refresh(data)
    PlayerBaseAttr.Refresh(self,data);
    self._proxy.icon = data.icon;
    self._proxy.selfintro = data.selfintro;
    self._proxy.locationStruct = self:ParseLocationInfo(data.location);
    self._proxy.voicemsgurl = string.FromBase64(data.voicemsg);
    self._proxy.voicemsglen = data.voicemsglen;
    self._proxy.home = data.home;
end

function PlayerSelfNormalAttr:GetName()
    return UserData.GetName();
end

--头像，在图片数组中的索引
function PlayerSelfNormalAttr:SetHeadIcon(value)
    if self._proxy.icon == value then return; end
    self._proxy.icon = value;
    GameEvent.Trigger(EVT.SOCIAL_SELF, EVT.PLAYER_ICON_INDEX, value);
end

function PlayerSelfNormalAttr:SetSelfintro(value)
    if self._proxy.selfintro == value then return; end
    self._proxy.selfintro = value;
    GameEvent.Trigger(EVT.SOCIAL_SELF, EVT.PLAYER_SELF_INTRO, value);
end
--游戏服头像
function PlayerSelfNormalAttr:GetLocalicon()
    return UserData.GetIcon();
end

function PlayerSelfNormalAttr:SetVoiceUrl(url)
    if self._proxy.voicemsgurl == url then return; end
    self._proxy.voicemsgurl = url;
    GameEvent.Trigger(EVT.SOCIAL_SELF, EVT.PLAYER_VOICEURL, url);
end

function PlayerSelfNormalAttr:SetVoiceLength(value)
    if self._proxy.voicemsglen == value then return; end
    self._proxy.voicemsglen = value;
    GameEvent.Trigger(EVT.SOCIAL_SELF, EVT.PLAYER_VOICELENGTH, value);
end

function PlayerSelfNormalAttr:GetServerId()
    return LoginMgr.GetCurrentServer():GetID();
end
--队伍信息
function PlayerSelfNormalAttr:GetTeamInfo()
    return "none";
end
--性别
function PlayerSelfNormalAttr:GetRoleGender()
    return UserData.IsMale() and 0 or 1;
end

--家乡
function PlayerSelfNormalAttr:SetHomeTown(value)
    if self._proxy.home == value then return; end
    self._proxy.home = value;
    GameEvent.Trigger(EVT.SOCIAL_SELF, EVT.PLAYER_HOME, value);
end
--门派
function PlayerSelfNormalAttr:GetMenpaiID()
    return 0;
end
function PlayerSelfNormalAttr:GetMenpaiName()
    return "menpai";
end
--帮会名
function PlayerSelfNormalAttr:GetGuildName()
    return GangMgr.GetGangName();
end
--伴侣名
function PlayerSelfNormalAttr:GetSpouseName()
    return "";
end
--称号名（有问题的）
function PlayerSelfNormalAttr:GetTitleName()
    return "";
end

--保存地理位置信息结构 {adcode=1,coordinate=Vector2(0,0),address=""}
function PlayerSelfNormalAttr:SetLocation(locationStruct)
    self._proxy.locationStruct = locationStruct;
    GameEvent.Trigger(EVT.SOCIAL_PLAYER, EVT.PLAYER_LOCATION, locationStruct);
end

--阵营
function PlayerSelfNormalAttr:GetFactionID()
    return 1;--没做
end
--阵营
function PlayerSelfNormalAttr:GetFactionNotice()
    return "none notice";
end

function PlayerSelfNormalAttr:GetAchieveStars()
    return UserData.GetAchieveStars();
end


return PlayerSelfNormalAttr;