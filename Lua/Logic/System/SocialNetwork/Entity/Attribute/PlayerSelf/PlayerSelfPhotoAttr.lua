--[[
    玩家照片
    author:{hesinian}
    time:2019-01-21 18:24:38
]]
local PlayerPhotoAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerPhotoAttr");
local PlayerSelfPhotoAttr = class("PlayerSelfPhotoAttr",PlayerPhotoAttr)

function PlayerSelfPhotoAttr:ctor(player)
    PlayerBaseAttr.ctor(self, player);
    self._limitTime = TimeUtils.SystemTimeStamp(true)-1;--只触发一次
end

function PlayerSelfPhotoAttr:Refresh(photowall)
    PlayerBaseAttr.Refresh(self);
    self._proxy.photos = {};
    for i,v in ipairs(photowall) do
        self._proxy.photos[v.photoid] = v;
    end
end

--保存照片
function PlayerSelfPhotoAttr:AddPhoto(photoStruct)
    self._proxy.photos[photoStruct.photoid] = photoStruct;
    GameEvent.Trigger(EVT.SOCIAL_SELF,EVT.PLAYER_PHOTO_ADD,photoStruct);
 end
 
 --删除
 function PlayerSelfPhotoAttr:DelPhoto(data)
    for i,id in ipairs(data.deletedlist) do
        self._photos[id] = nil
    end
    if data.icon_deleted == 1 then--删除了头像
        local normalAttr = self._player:GetNormalAttr();
        if data.delIcon == normalAttr:GetHeadIcon() then
            normalAttr:SetHeadIcon(); --data.delIcon删除的头衔photoid
        end
    end
    GameEvent.Trigger(EVT.SOCIAL_SELF,EVT.PLAYER_PHOTO_DEL);
 end

return PlayerSelfPhotoAttr;