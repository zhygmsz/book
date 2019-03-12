local LoginWrapTableUISelectServer = class("LoginWrapTableUISelectServer",UICommonCollapseWrapUI);
local UILoginRoleItem = require("Logic/Presenter/UI/Login/UILoginRoleItem");
local UILoginServerItem = require("Logic/Presenter/UI/Login/UILoginServerItem");

local function InitServer(itemTran,transName)
    local server = {};
    local trans = itemTran:Find(transName); 
    server.gameObject = trans.gameObject;
    server.uievent = trans:GetComponent("UIEvent");
    
    server.activeGo = trans:Find("Active").gameObject;
    server.deactiveGo = trans:Find("Deactive").gameObject;
    local spriteState = trans:Find("SpriteState"):GetComponent("UISprite");
    local newGo = trans:Find("SpriteNew").gameObject;
    local labelName = trans:Find("LabelName"):GetComponent("UILabel");
    server.serverItem = UILoginServerItem.new(labelName,spriteState,newGo);

    server.goRole = trans:Find("SpriteKuang").gameObject;
    
    local roleTex = trans:Find("SpriteKuang/SpriteRole"):GetComponent("UITexture");
    server.roleItem = UILoginRoleItem.new(roleTex);

    return server;
end

local function RefreshServer(context, serverUI,serverData)
    if not serverData then
        serverUI.gameObject:SetActive(false);
        return;
    end
    serverUI.gameObject:SetActive(true);

    local roleList = serverData:GetRoleList();
    local isSelected = context.IsServerSelected(serverData);
    serverUI.activeGo:SetActive(isSelected);
    serverUI.deactiveGo:SetActive(not isSelected);
    serverUI.serverItem:Refresh(serverData);

    local role = serverData:GetRecommendRole();
    serverUI.goRole:SetActive(role ~= nil);
    if role then
        serverUI.roleItem:Refresh(role);
    end
end

function LoginWrapTableUISelectServer:ctor(itemTran,baseEventID,context)
    self.super.ctor(self,itemTran,baseEventID);
    self._context = context;
    self._type = "SelectServer";
    self._gameObject = itemTran:Find("Servers").gameObject;
    self._server1 = InitServer(itemTran,"Servers/Server1");
    self._server1.uievent.id = baseEventID;
    self._server2 = InitServer(itemTran,"Servers/Server2");
    self._server2.uievent.id = baseEventID + 1;
end

function LoginWrapTableUISelectServer:GetType()
    return self._type;
end

function LoginWrapTableUISelectServer:OnRefresh()
    local data = self._wrapData:GetData();
    self._data = data;
    RefreshServer(self._context,self._server1,data.server1);
    RefreshServer(self._context,self._server2,data.server2);
end

function LoginWrapTableUISelectServer:OnClick(bid)
    if bid == 0 then
        self._context.OnServerClick(self._data.server1);
    elseif bid == 1 then
        self._context.OnServerClick(self._data.server2);
    end
end

return LoginWrapTableUISelectServer;