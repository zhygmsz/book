--娓告垙鐩?鐨?
local FriRecomProPurpose = class("FriRecomProPurpose",FriRecomProBase);

function FriRecomProPurpose:ctor()
    FriRecomProBase.ctor(self);
    local list = {};
    local count = ConfigData.GetIntValue("firend_recommend_purpose_count");--推荐目的数量，已填
    for i = 1,count do
        list[i] = {};
        list[i].name = WordData.GetWordStringByKey("firend_recommend_purpose_"..i);--推荐设置，目的
        list[i].code = i;
    end
    local i = count + 1;
    list[i] = {};
    list[i].name = WordData.GetWordStringByKey("friend_recommend_property_whatever");
    list[i].code = 0;
    self._list = list;
    self._serverKey = "purpose";
    self._innerProperty = true;
end

function FriRecomProPurpose:GetUserValue()
    return self._value;
end


return FriRecomProPurpose;