local LoginWrapTableDataSelectRole = require("Logic/Presenter/UI/Login/SelectServerRole/LoginWrapTableDataSelectRole");

local LoginWrapTableDataHelper = class("LoginWrapTableDataHelper");

function LoginWrapTableDataHelper:ctor(commonTableWrap,servers)
    self._commonTableWrap = commonTableWrap;
    self._cacheDatas = {};
    for i = 1, #servers, 2 do
        local item = {};
        item.server1 = servers[i];
        if i+1 <= #servers then
            item.server2 = servers[i+1];
        end
        local serverData = UICommonCollapseWrapData.new("SelectServer",item,110);
        table.insert(self._cacheDatas,serverData);
    end
    self._selectServerIndex = nil;
    self._cahceRoleData = LoginWrapTableDataSelectRole.new(nil);
end

function LoginWrapTableDataHelper:RefreshAllData()
    if self._selectServerIndex then
        table.remove(self._cacheDatas,self._selectServerIndex+1);
        self._selectServerIndex = nil;
    end
    
    self._commonTableWrap:ResetAll(self._cacheDatas);
end

function LoginWrapTableDataHelper:RefreshSelectedData()
    local oldIndex = self._selectServerIndex;
    if self._selectServerIndex then
        table.remove(self._cacheDatas,self._selectServerIndex+1);
    end
    self._selectServerIndex = nil;

    for i,item in ipairs(self._cacheDatas) do
        local servers = item:GetData();
        if LoginMgr.IsServerSelected(servers.server1) then
            self._selectServerIndex = i;
            local data = {};
            data.server = servers.server1;
            data.isLeft = true;
            self._cahceRoleData:ReSetData(data);
            break;
        elseif LoginMgr.IsServerSelected(servers.server2) then
            self._selectServerIndex = i;
            local data = {};
            data.server = servers.server2;
            data.isLeft = false;
            self._cahceRoleData:ReSetData(data);
            break;
        end
    end

    if not self._selectServerIndex then
        GameLog.LogError("Not find selected index");
    else
        local startIndex = oldIndex and oldIndex < self._selectServerIndex and oldIndex or self._selectServerIndex;
        table.insert(self._cacheDatas,self._selectServerIndex + 1,self._cahceRoleData);
        self._commonTableWrap:ResetPartialData(self._cacheDatas,startIndex,self._selectServerIndex);
    end
end

return LoginWrapTableDataHelper;