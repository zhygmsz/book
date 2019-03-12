
local FriRecomProRegion = class("FriRecomProRegion",FriRecomProBase);

function FriRecomProRegion:ctor()
    FriRecomProBase.ctor(self);
    local list = {};
    --TODO，需要LBS模块支持
    self._list = list;
    self._serverKey = "region";
end

function FriRecomProRegion:GetMsgSubKeys()

end

function FriRecomProRegion:GetUserValue()
    return UserData.GetLocationCityCode();
end

--地理信息系统中，index就是用code来表示的
function FriRecomProRegion:GetCode(index)
    return index;
end

return FriRecomProRegion;