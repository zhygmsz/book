local FriendGroupFriend = class("FriendGroupFriend",FriendGroupBase);

function FriendGroupFriend:ctor(id)
    self.super.ctor(self,id);
end

function FriendGroupFriend:IsInUse()
    return self._name and self._name ~= "";
end

function FriendGroupFriend:IsEditable()
    return self._id ~= 0;
end

function FriendGroupFriend:OnAddMember( member)
    if member:GetFriendAttr():GetIntimacy() == 0 then
        member:GetFriendAttr():SetIntimacy(1);
    end
end

return FriendGroupFriend;