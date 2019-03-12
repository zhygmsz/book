--[[
    des: 属性被读取就会触发更新检测，如果距离上次更新时间超过阈值就发起更新
    author:{hesinian}
    time:2019-01-21 18:24:38
]]

PlayerBaseAttr = class("PlayerBaseAttr")

function PlayerBaseAttr:ctor(player)
    self._id = player:GetID();
    self._player = player;
    self._refreshTime = 0;
    self._limitTime = 1000;
    
    self._realTable = {};
    self._proxy = {};

    local function Get(t, key)

        if self:NeedSync() then
            self:RefreshTime();
            self:RequestSyncAttr();
        end
        return self._realTable[key];
    end

    -- local function Set(t,key,value)
    --     self._realTable.key = value;
    -- end

    local meta = {__index = Get};

    setmetatable(self._proxy, meta);
end

function PlayerBaseAttr:CheckNil(value,name)
        GameLog.LogError(" %s is %s", name, value);
end
--刷新记录时间
function PlayerBaseAttr:RefreshTime()
    self._refreshTime = TimeUtils.SystemTimeStamp(true);
end

function PlayerBaseAttr:NeedSync()
    local current = TimeUtils.SystemTimeStamp(true);
    return current > self._limitTime + self._refreshTime;
end

--发起更新申请
function PlayerBaseAttr:RequestSyncAttr()
    GameLog.LogError("%s Not Implementated Function RequestSyncAttr ", self.__cname);
end

--更新数据，
--如果不需要网络同步，则用 self._proxy保存，
--如果需要网络同步，用self._realTable保存
function PlayerBaseAttr:Refresh()
    self:RefreshTime();
end

--获得代理数据
function PlayerBaseAttr:GetAttrs()
    return self._proxy;
end

return PlayerBaseAttr;