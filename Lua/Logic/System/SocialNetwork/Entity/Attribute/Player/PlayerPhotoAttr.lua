--[[
    玩家照片
    author:{hesinian}
    time:2019-01-21 18:24:38
]]

local PlayerPhotoAttr = class("PlayerPhotoAttr",PlayerBaseAttr)

function PlayerPhotoAttr:ctor(player)
    self.super.ctor(self, player);
    self._limitTime = 60 * 10;
    self._realTable.photos = {};
end

function PlayerPhotoAttr:RequestSyncAttr()
    local function OnSyncAttr(data)
        self:Refresh(data);
        GameEvent.Trigger(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,self._player);
    end
    local params = string.format("cmd=player_photowall&id=%s&start=%s&cnt=%s",self._id,0,3);
    SocialNetworkMgr.RequestAction("AskPersonalPhotoWall",params,OnSyncAttr);
end

--{"highqualitysource":"aaa","mediumqualitysource":"bbb","lowqualitysource":"ccc","createtime":1525783541,"photoid":"2","viewcnt":"0","likecnt":"0","verify":"2","likedbyme":0,"viewedbyme":0}
function PlayerPhotoAttr:Refresh(photowall)
    self.super.Refresh(self);
    for i,v in ipairs(photowall) do
        self._realTable.photos[v.photoid] = v
    end
end

function PlayerPhotoAttr:GetAllPhotoesOnWall()
    return self._proxy.photos or table.emptyTable;
end
--获取照片墙数组
function PlayerPhotoAttr:GetPhotoWall()
    local plist ={}
    for k,v in pairs(self:GetAllPhotoesOnWall()) do
        table.insert(plist,v)
    end
    return plist;
end
--默认头像URL为玩家最大尺寸photo
function PlayerPhotoAttr:GetDefaultHeadIconURL()
    local key = self._player:GetNormalAttr():GetHeadIcon();
    local info = self:GetAllPhotoesOnWall()[key];
    if info then
        return GameConfig.PHOTO_CLOUD_URL..info.highqualitysource;
    end
    return "";
end
--获取照片墙的第几个
function PlayerPhotoAttr:GePhotoByPhotoId(photoid)
    return self:GetAllPhotoesOnWall()[photoid]
end

--获取照片墙的第几个
function PlayerPhotoAttr:GePhotoURLByPhotoId(photoid)
    local info = self:GePhotoByPhotoId();
    if info then
        return GameConfig.PHOTO_CLOUD_URL..info.highqualitysource;
    end
    return "";
end
--获取照片数组
function PlayerPhotoAttr:GePhotoURLs()
    local plist ={}
    for pid,info in pairs(self:GePhotoByPhotoId()) do
        if info then
            local url = GameConfig.PHOTO_CLOUD_URL..info.highqualitysource;
            table.insert(plist,url);
        end
    end
    return plist;
end

return PlayerPhotoAttr;