--记录
FriRecomProBase = class("FriRecomProBase");

function FriRecomProBase:ctor()
    --保存属性的枚举类型{name,code}   --name为UI显示用，code为社交服务器用码
    self._list = nil;
    --上传服务器的属性key
    self._serverKey = nil;

    --是否是系统内部属性,内部属性的值保存在社交服务器，客户端保存在类内部（接口SetUserValue)，外部属性的值需要到外部获取(不能保存)
    self._innerProperty = false;
    --监听变化信息
    local msgG,msgU = self:GetMsgSubKeys();
    if msgG and msgU then
        --MessageSub.Register(msgG,msgU,self.OnValueChange,self);
        GameEvent.Reg(msgG,msgU,self.OnValueChange,self);
    end
end

function FriRecomProBase:IsInnerProperty()
    return self._innerProperty;
end

--获取需要监听的MessageSub的key值，当值发生变化时，上传给推荐服务器
function FriRecomProBase:GetMsgSubKeys()
end

function FriRecomProBase:OnValueChange()
    local userValue = self:GetUserValue();
    local keyValue = {};
    keyValue[self._serverKey] = userValue;
    FriendRecommendMgr.RequestSetPlayerProperty(keyValue);
end

function FriRecomProBase:IsSameValue( value)
    local selfValue = self:GetUserValue();
    selfValue = FriendRecommendMgrUtil.Value2String(selfValue);
    return tostring(value) == tostring(selfValue);
end

function FriRecomProBase:SynRemoteValue(remoteValue)
    if self:IsInnerProperty() then --内部数据保存在本地即可
        self:SetUserValue(remoteValue);
    elseif not self:IsSameValue(remoteValue)  then--如果远端数据不同步本地数据，则上传本地数据
        self:OnValueChange();
    end
end

function FriRecomProBase:SetUserValue(value)
    if not self._innerProperty then
        GameLog.LogError("Error:Can't save value %s in %s, which is an external property.",value,self._serverKey);
        if value ~= -1 then
            self._value = FriendRecommendMgrUtil.String2List(value);
        end
    end
end

--获得最大索引
function FriRecomProBase:GetMaxIndex()
    return #self._list;
end
--根据索引获得名字
function FriRecomProBase:GetName(index)
    return self._list[index] and self._list[index].name;
end
--根据索引获得 协议码
function FriRecomProBase:GetCode(index)
    return self._list[index] and self._list[index].code;
end
--服务器key
function FriRecomProBase:GetServerKey()
    return self._serverKey;
end

--根据协议码获得索引
function FriRecomProBase:GetIndex(code)
    for i,item in ipairs(self._list) do
        if code == item.code then
            return i;
        end
    end
end

--获取本地玩家的数据，转换为推荐服务器需要的格式
function FriRecomProBase:GetUserValue()

end

return FriRecomProBase;