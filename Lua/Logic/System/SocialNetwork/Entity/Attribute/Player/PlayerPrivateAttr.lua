--[[
    玩家性别，星座，生日信息
    author:{hesinian}
    time:2019-01-21 18:24:38
]]
local PlayerPrivateAttr = class("PlayerPrivateAttr",PlayerBaseAttr)

function PlayerPrivateAttr:ctor(player)
    self.super.ctor(self, player);
    self._limitTime = 60 * 1;
end

--获取玩家的标签 gender，star，others
function PlayerPrivateAttr:RequestSyncAttr()
    local function OnSyncAttr(data)
        self:Refresh(data);
        GameEvent.Trigger(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self._player);
    end
    
    local params = string.format("id=%s",self._id);
    SocialNetworkMgr.RequestAction("GetPlayerTag",params,OnSyncAttr);
end

function PlayerPrivateAttr:Refresh(data)
    self.super.Refresh(self);
    if data==nil then return  end
    self._realTable.star = tonumber(tag["61"]);
    self._realTable.gender = tonumber(tag["60"]);
    self._realTable.birth = tonumber(tag["69"]);
end


--社交生日                                                            
function PlayerPrivateAttr:GetBirthdayBySecond()
    return self._proxy.birth or TimeUtils.SystemTimeStamp(true);
end
--生日结构体 {year,month,day}
function PlayerPrivateAttr:GetBirthday()
    return TimeUtils.TimeStamp2Date(self:GetBirthdayBySecond(),true);
end

--获取生日字符串 00-00-00
function PlayerPrivateAttr:GetBirthdayString()
    local birthTime = self:GetBirthdayBySecond();
    return TimeUtils.FormatTime(birthTime,1,true);
end

--社交性别
function PlayerPrivateAttr:GetGender()
    return self._proxy.gender or 3;--1男2女3保密
end

--社交星座
function PlayerPrivateAttr:GetStar()
    return self._proxy.star or 1;
end

--得到星座名称
function PlayerPrivateAttr:GetConstellationName()
    return TipsMgr.GetTipByKey(string.format("system_constellation_name_%d",self:GetStar()))
end

--星座提示
function PlayerPrivateAttr:GetZodiacNotice()
    return "none notice";
end

return PlayerPrivateAttr;