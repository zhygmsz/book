
local FriRecomProLevel = class("FriRecomProLevel",FriRecomProBase);

function FriRecomProLevel:ctor()
    FriRecomProBase.ctor(self);
    local list = {};
    for i = 1,2 do
        list[i] = {};
        list[i].name = WordData.GetWordStringByKey("friend_recommend_level_"..i);--推荐设置，等级
        list[i].code = i;
    end
    list[3] = {};
    list[3].name = WordData.GetWordStringByKey("friend_recommend_property_whatever");--好友推荐，无所谓
    list[3].code = 0;
    self._list = list;
    self._serverKey = "level";
end

function FriRecomProLevel:GetMsgSubKeys()
    --error("please use new event system")
    return EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_EXP;
end

function FriRecomProLevel:GetUserValue()
    return UserData.GetLevel();
end

return FriRecomProLevel;