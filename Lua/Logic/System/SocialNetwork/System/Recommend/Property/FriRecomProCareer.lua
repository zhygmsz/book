--职业
local FriRecomProCareer = class("FriRecomProCareer",FriRecomProBase);

function FriRecomProCareer:ctor()
    FriRecomProBase.ctor(self);
    local list = {};
    local idCount = ProfessionData.GetAllProfessionNum();
    for i = 1,idCount do
        list[i] = {};
        list[i].name = ProfessionData.GetProfessionName(i);
        list[i].code = i;
    end
    local i = #list+1;
    list[i] = {};
    list[i].name = WordData.GetWordStringByKey("friend_recommend_property_whatever");--推荐设置 无所谓
    list[i].code = 0;
    self._list = list;

    self._serverKey = "career";
end

function FriRecomProCareer:GetMsgSubKeys()
    --监听
end

function FriRecomProCareer:GetUserValue()
    local isMarried = UserData.IsMarried();
    if isMarried then 
        return self._list[2].code;
    else
        return self._list[1].code;
    end
end

return FriRecomProCareer;