--社交玩家类
--为了减小信息同步量，将信息分为若干组，按组别更新
local SocialPlayer = class("SocialPlayer")
require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerBaseAttr");
local PlayerFriendAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerFriendAttr");
local PlayerNormalAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerNormalAttr");
local PlayerPhotoAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerPhotoAttr");
local PlayerPrivateAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerPrivateAttr");
local PlayerUserDefineAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerUserDefineAttr");
local PlayerVolatileAttr = require("Logic/System/SocialNetwork/Entity/Attribute/Player/PlayerVolatileAttr");
local ChatRecordComponent = require("Logic/System/SocialNetwork/Entity/Chat/ChatRecordComponent");

function SocialPlayer:ctor(id)
    self._id = tonumber(id);
    self._volatileInfo = PlayerVolatileAttr.new(self);--易变属性
    self._friendInfo = PlayerFriendAttr.new(self);--好友属性
    self._normalInfo = PlayerNormalAttr.new(self);--常规属性
    self._privateInfo = PlayerPrivateAttr.new(self);--隐私属性
    self._photoInfo = PlayerPhotoAttr.new(self);--照片墙属性
    self._userInfo = PlayerUserDefineAttr.new(self);--自定义属性

    self._record = ChatRecordComponent.new(self);--聊天组件

end

function SocialPlayer:GetID()
    return self._id;
end
function SocialPlayer:GetPlayerId()
    return self._id
end
function SocialPlayer:IsSelf()
    return self._id == UserData.PlayerID;
end

function SocialPlayer:GetVolatileAttr()
    return self._volatileInfo;
end
function SocialPlayer:GetFriendAttr()
    return self._friendInfo;
end
function SocialPlayer:GetNormalAttr()
    return self._normalInfo;
end
function SocialPlayer:GetTagAttr()
    return self._privateInfo;
end
function SocialPlayer:GetPhotoAttr()
    return self._photoInfo;
end
function SocialPlayer:GetUserAttr()
    return self._userInfo;
end
function SocialPlayer:GetRecordCom()
    return self._record;
end

--客户端搜索
function SocialPlayer:FullfillSearch(str)
    if self._remark and string.find(self._remark,str) then return true; end
    if string.find(self:GetNickName(),str) then return true; end
    if string.find(self._id,str) then return true; end
    return false;
end

function SocialPlayer:GetLevel()
    return self:GetVolatileAttr():GetLevel() or 0;
end
function SocialPlayer:IsOnline()
    return self:GetVolatileAttr():IsOnline();
end

function SocialPlayer:GetOnlineStatus()
    return self:IsOnline();
end

--------- 常用属性----------------
function SocialPlayer:GetName()
    return self:GetNormalAttr():GetName() or self._id;
end

function SocialPlayer:GetNickName()
    return self:GetName();
end
function SocialPlayer:GetCityName()
    return self:GetNormalAttr():GetCityName();
end
--设置玩家头像的帮助办法
function SocialPlayer:SetHeadIcon(iconTexture,iconSprite)
    local url = self:GetPhotoAttr():GetDefaultHeadIconURL()
    if url and url ~="" then 
        iconTexture.gameObject:SetActive(true);
        UIUtil.LoadImage(iconTexture,{compressRatio=100,width=1024,height=1024},url,true);
    else
        local loadResID = self:GetNormalAttr():GetLocalicon();
        UIUtil.SetTexture(loadResID,iconTexture)
    end
    iconTexture.gameObject:SetActive(true);
    if iconSprite then
        iconSprite.gameObject:SetActive(false);
    end
end
-----------好友API----------------------------------------
--好友备注
function SocialPlayer:GetRemark()
    local remark = self:GetFriendAttr():GetRemark();
    return remark and remark ~= "" and remark or self:GetName();
end

function SocialPlayer:GetIntimacy()
    return self:GetFriendAttr():GetIntimacy();
end

function SocialPlayer:IsInBlackList()
    return self:GetFriendAttr():IsInBlackList();
end

function SocialPlayer:IsFriend()
    return self:GetFriendAttr():IsFriend();
end

function SocialPlayer:IsFollow()
    return self:GetFriendAttr():IsFollow();
end
function SocialPlayer:IsFan()
    return self:GetFriendAttr():IsFan();
end
function SocialPlayer:IsStranger()
    return self:GetFriendAttr():IsStranger();
end
function SocialPlayer:IsNPC()
    return self:GetFriendAttr():IsNPC();
end

---聊天---------
--清楚聊天记录
function SocialPlayer:ClearChatRecord()
    self._record:ClearMemory();
end

--是否屏蔽消息
function SocialPlayer:GetChatBlock()
    return self:GetFriendAttr():IsInBlackList();
end

------特殊关系
function SocialPlayer:IsMaster()--师
    return false;
end
function SocialPlayer:IsApprentice()--徒
--[[
    @desc: 
    author:{author}
    time:2019-02-27 15:33:57
    @return:
]]return false;
end
function SocialPlayer:IsHusbandWife()--夫妻
    return false;
end
function SocialPlayer:IsSameBang()--同门
    return false;
end
function SocialPlayer:IsBrothers()--结义
    return false;
end
function SocialPlayer:IsUnrequitedLover()--暗恋
    return self:GetFriendAttr():IsUnrequitedLover();
end

--师徒/夫妻/结拜关系
function SocialPlayer:HasSpecialRelation()
    return false;
end


return SocialPlayer;