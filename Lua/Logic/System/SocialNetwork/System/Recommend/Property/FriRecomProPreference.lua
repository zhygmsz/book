--兴趣爱好
local FriRecomProPreference = class("FriRecomProPreference",FriRecomProBase);

function FriRecomProPreference:ctor()
    FriRecomProBase.ctor(self);
    local list = {};
    local count = ConfigData.GetIntValue("firend_recommend_preference_count");--??????,??
    for i = 1,count do
        list[i] = {};
        list[i].name = WordData.GetWordStringByKey("firend_recommend_preference_"..i);--???????
        list[i].code = i;
    end
    local i = count + 1;
    list[i] = {};
    list[i].name = WordData.GetWordStringByKey("friend_recommend_property_whatever");--?????????
    list[i].code = 0;
    self._list = list;
    self._serverKey = "preference";
    self._innerProperty = true;
end

function FriRecomProPreference:GetUserValue()
    return self._value;
end

return FriRecomProPreference;