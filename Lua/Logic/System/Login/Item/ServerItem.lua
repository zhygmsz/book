local ServerItem = class("ServerItem");

-- temp.ID = -1*i;
-- temp.Name = "本地服"..i;
-- temp.Group = "1";
-- temp.Busy = false;
-- temp.IsHot = false;
-- temp.IsNew = false;
-- temp.IP = "127.0.0.1";
-- temp.Port = "8888";
-- 四种状态，分别为：火爆、拥挤、空闲、维护
function ServerItem:ctor(info)
    self._basicInfo = info;
    self._roleList = {};
    self._isopen = nil;
    self._isRecommend = nil;
end
function ServerItem:GetID()
    return self._basicInfo.ID;
end
function ServerItem:GetName()
    return self._basicInfo.Name;
end
function ServerItem:GetGroup()
    return self._basicInfo.Group;
end
function ServerItem:IsOpen()
    return self._isopen;
end
function ServerItem:IsBusy()
    return self._state==1;
end
function ServerItem:IsFull()
    return self._state==2;
end
function ServerItem:IsNew()
    return self._basicInfo.IsNew;
end
function ServerItem:GetIP()
    return self._basicInfo.IP;
end
function ServerItem:GetPort()
    return self._basicInfo.Port;
end

function ServerItem:SetOpenState(state)
    self._isopen = state;
end

function ServerItem:IsRecommend()
    return self._basicInfo.IsHot;
end
function ServerItem:SetState(state)
    self._state = state;
end

function ServerItem:AddRole(role)
    table.insert(self._roleList,role);
end

function ServerItem:SortRole(func)
    table.sort(self._roleList,func);
end
function ServerItem:GetRoleList()
    return self._roleList;
end
function ServerItem:GetRoleCount()
    return #self._roleList;
end
function ServerItem:GetRoleByID(rid)
    for _,role in ipairs(self._roleList) do
        if role:GetID() == rid then
            return role;
        end
    end
end
function ServerItem:GetRecommendRole()

    return self._roleList[1];

end

return ServerItem;