--社交玩家类
--为了减小信息同步的数量，将信息分为若干组，按组别更新信息
local SocialPlayer = require("Logic/System/SocialNetwork/Entity/SocialPlayer");
local SocialPlayerSelf = class("SocialPlayerSelf", SocialPlayer)
local PlayerSelfFriendAttr = require("Logic/System/SocialNetwork/Entity/Attribute/PlayerSelf/PlayerSelfFriendAttr");
local PlayerSelfNormalAttr = require("Logic/System/SocialNetwork/Entity/Attribute/PlayerSelf/PlayerSelfNormalAttr");
local PlayerSelfPhotoAttr = require("Logic/System/SocialNetwork/Entity/Attribute/PlayerSelf/PlayerSelfPhotoAttr");
local PlayerSelfPrivateAttr = require("Logic/System/SocialNetwork/Entity/Attribute/PlayerSelf/PlayerSelfPrivateAttr");
local PlayerSelfUserDefineAttr = require("Logic/System/SocialNetwork/Entity/Attribute/PlayerSelf/PlayerSelfUserDefineAttr");
local PlayerSelfVolatileAttr = require("Logic/System/SocialNetwork/Entity/Attribute/PlayerSelf/PlayerSelfVolatileAttr");
local ChatRecordComponent = require("Logic/System/SocialNetwork/Entity/Chat/ChatRecordComponent");

function SocialPlayerSelf:ctor()
    self._id = UserData.PlayerID;
    self._volatileInfo = PlayerSelfVolatileAttr.new(self);--易变属性
    self._friendInfo = PlayerSelfFriendAttr.new(self);--好友属性
    self._normalInfo = PlayerSelfNormalAttr.new(self);--常规属性
    self._privateInfo = PlayerSelfPrivateAttr.new(self);--隐私属性
    self._photoInfo = PlayerSelfPhotoAttr.new(self);--照片墙属性
    self._userInfo = PlayerSelfUserDefineAttr.new(self);--自定义属性

    self._record = ChatRecordComponent.new(self);--聊天组件

end

--客户端搜索
function SocialPlayerSelf:FullfillSearch(str)
    if string.find(self._remark,str) then return true; end
    if string.find(self:GetNickName(),str) then return true; end
    if string.find(self._id,str) then return true; end
    return false;
end

function SocialPlayerSelf:GetLevel()
    return UserData.GetLevel();
end
function SocialPlayerSelf:IsOnline()
    return true;
end

--------- 常用属性----------------
function SocialPlayerSelf:GetName()
    return UserData.GetName();
end

-----------好友API----------------------------------------
--好友备注
function SocialPlayerSelf:GetRemark()
    return self:GetName();
end

function SocialPlayerSelf:IsInBlackList()
    return self:GetFriendAttr():IsInBlackList();
end
function SocialPlayer:IsMaster()--师
    return false;
end
function SocialPlayer:IsApprentice()--徒
    return false;
end
function SocialPlayerSelf:IsHusbandWife()
    return false;
end
function SocialPlayerSelf:IsSameBang()
    return false;
end
function SocialPlayerSelf:IsBrothers()
    return false;
end
--师徒/夫妻/结拜关系
function SocialPlayerSelf:HasSpecialRelation()
    return false;
end


return SocialPlayerSelf;