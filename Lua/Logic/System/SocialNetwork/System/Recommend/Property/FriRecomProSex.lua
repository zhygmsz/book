local FriRecomProSex = class("FriRecomProSex",FriRecomProBase);

function FriRecomProSex:ctor()
    FriRecomProBase.ctor(self);
    local list = {};
    for i = 1,2 do
        list[i] = {};
        list[i].name = WordData.GetWordStringByKey("friend_recommend_sex_"..i);
        list[i].code = i;
    end
    list[3] = {};
    list[3].name = WordData.GetWordStringByKey("friend_recommend_property_whatever");
    list[3].code = 0;
    self._list = list;
    self._serverKey = "sex";
end

function FriRecomProSex:GetUserValue()
    local isMale = UserData.IsMale();
    if isMale then
        return self._list[1].code;
    else
        return self._list[2].code;
    end
end

return FriRecomProSex;