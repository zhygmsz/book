local RoleItem = class("RoleItem");
--[{"1_10000013":"{\n\t\"serverID\":\t1,
                 --\n\t\"account\":\t\"1529415889\",
                 --\n\t\"roleID\":\t10000013,
                 --\n\t\"roleName\":\t\"\u671d\u9633\u82df\u5c14\u66fc\",
                 --\n\t\"icon\":\t\"\",
                 --\n\t\"level\":\t1\n}"}]
--登录时间
function RoleItem:ctor(item)
    item.serverID = tonumber(item.serverID);
    item.roleID = tonumber(item.roleID);
    local flag,level = xpcall(tonumber,traceback,item.level);
    if type(level) ~= "number" then
        level = 0;
    end
    item.level = level;
    item.race = tonumber(item.race) or 10;
    item.job = tonumber(item.job) or 4;
    item.login = tonumber(item.login) or 0;
    local resTable = ProfessionData.GetProfessionResByRacialProfession(item.race, item.job);
    self._icon = resTable and resTable.headIcon;

    self._basicInfo = item;
    self._server = nil;
end
function RoleItem:GetServerID()
    return self._basicInfo.serverID;
end
function RoleItem:GetID()
    return self._basicInfo.roleID;
end
function RoleItem:GetName()
    return self._basicInfo.roleName;
end
--头像
function RoleItem:GetIcon()
    return self._icon;
end
--等级信息
function RoleItem:GetLevel()
    return self._basicInfo.level;
end
function RoleItem:GetServer()
    return self._server;
end
function RoleItem:SetServer(server)
    self._server = server;
end
--最近一次登录时间
function RoleItem:GetLoginTime()
    return self._basicInfo.login;
end

return RoleItem;