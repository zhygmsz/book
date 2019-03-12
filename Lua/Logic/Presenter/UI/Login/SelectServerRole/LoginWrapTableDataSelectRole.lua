local LoginWrapTableDataSelectRole = class("LoginWrapTableDataSelectRole",UICommonCollapseWrapData);

function LoginWrapTableDataSelectRole:ctor(content)
    UICommonCollapseWrapData.ctor(self,"SelectRole",content);
end

function LoginWrapTableDataSelectRole:GetSize()
    if not self._content then return 0; end
    local server = self._content.server;
    local roleList = server:GetRoleList();
    local maxRoleCount = LoginMgr.GetMaxRoleCount();
    local count = #roleList;
    if count < maxRoleCount then
        count = count + 1;
    end
    count = math.ceil(count / 3);
    --每行UI的高度为117
    return count * 117 + 10;
end

return LoginWrapTableDataSelectRole;