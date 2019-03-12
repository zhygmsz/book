--星座
local FriRecomProStar = class("FriRecomProStar",FriRecomProBase);
require("Logic/System/Utils/UtilConstellation");
function FriRecomProStar:ctor()
    FriRecomProBase.ctor(self);
    local list = {};
    local count = UtilConstellation.GetMaxIndex();
    for i = 1,count do
        list[i] = {};
        list[i].name = UtilConstellation.GetName(i);
        list[i].code = i;
    end
    local i = count + 1;
    list[i] = {};
    list[i].name = WordData.GetWordStringByKey("friend_recommend_property_whatever");
    list[i].code = 0;
    self._list = list;
    self._serverKey = "star";
end

function FriRecomProStar:GetMsgSubKeys()

end

function FriRecomProStar:GetUserValue()
    return UserData.GetStarID();
end

return FriRecomProStar;