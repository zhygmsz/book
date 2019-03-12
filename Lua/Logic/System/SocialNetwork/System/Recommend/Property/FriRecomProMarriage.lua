
local FriRecomProMarriage = class("FriRecomProMarriage",FriRecomProBase);

function FriRecomProMarriage:ctor()
    FriRecomProBase.ctor(self);
    local list = {};

    for i = 1,2 do
        list[i] = {};
        list[i].name = WordData.GetWordStringByKey("friend_recommend_marriage_"..i);--推荐设置 婚姻
        list[i].code = i;
    end
    list[3] = {};
    list[3].name = WordData.GetWordStringByKey("friend_recommend_property_whatever");
    list[3].code = 0;
    self._list = list;
    self._serverKey = "marriage";
end

function FriRecomProMarriage:GetMsgSubKeys()
    --等待监听婚姻系统
end

function FriRecomProMarriage:GetUserValue()
    local isMarried = UserData.IsMarried();
    if isMarried then 
        return self._list[2].code;
    else
        return self._list[1].code;
    end
end

return FriRecomProMarriage;