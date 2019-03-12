local LoginWrapTableUISelectRole = class("LoginWrapTableUISelectRole",UICommonCollapseWrapUI);
local UILoginRoleItem = require("Logic/Presenter/UI/Login/UILoginRoleItem");

local function CacheRoleItem(cache,roleTrans)
    cache.transform = roleTrans;
    cache.gameObject = roleTrans.gameObject;
    local roleTex = roleTrans:Find("SpriteKuang/SpriteRole"):GetComponent("UITexture");
    local roleName = roleTrans:Find("LabelName"):GetComponent("UILabel");
    local roleLevel = roleTrans:Find("SpriteKuang/SpriteRole/LabelLevel"):GetComponent("UILabel");
    cache.roleItem = UILoginRoleItem.new(roleTex,roleName,roleLevel);
end

local function UpdataWidget(widget)
    widget.enabled = false;
    widget.enabled = true;--刷新箭头位置
    widget:Update();
end

function LoginWrapTableUISelectRole:ctor(itemTran,baseEventID,context)
    self.super.ctor(self,itemTran,baseEventID);
    self._gameObject = itemTran:Find("RolesOfServer").gameObject;
    self._type = "SelectRole";
    self._ui = context.GetUIFrame();
    --self._widget = itemTran:Find("RolesOfServer/WithPlayerContainer"):GetComponent("UIWidget");

    self._grid = itemTran:Find("RolesOfServer/Grid"):GetComponent("UIGrid");

    self._rolePrefab = itemTran:Find("RolesOfServer/Grid/RolePrefab");
    self._roleuiCache = {};
    self._roleuiCache[1] = {};
    CacheRoleItem(self._roleuiCache[1],self._rolePrefab );
    self._addRoleTran = itemTran:Find("RolesOfServer/Grid/AddRole");
    self._addRoleGo = self._addRoleTran.gameObject;
    itemTran:Find("RolesOfServer/Grid/AddRole"):GetComponent("UIEvent").id = baseEventID;

    self._bgWidget = itemTran:Find("RolesOfServer/SpriteBg"):GetComponent("UIWidget");
    self._arrowTrans = itemTran:Find("RolesOfServer/SpriteBg/SpriteArrow");
    self._arrowWidget = self._arrowTrans:GetComponent("UIWidget");
end

function LoginWrapTableUISelectRole:GetType()
    return self._type;
end

function LoginWrapTableUISelectRole:OnRefresh()
    local data = self._wrapData:GetData();
    local server = data.server;
    self._server = server;
    local roleList = server:GetRoleList();
    self._roleList = roleList;
    if #roleList < #self._roleuiCache then
        for i = #roleList+1 , #self._roleuiCache do
            self._roleuiCache[i].gameObject:SetActive(false);
        end
    end
    if #roleList > #self._roleuiCache then
        for i = #self._roleuiCache+1 , #roleList do
            local trans = self._ui:DuplicateAndAdd(self._rolePrefab,self._rolePrefab.parent,i); 
            self._roleuiCache[i] = {};
            CacheRoleItem(self._roleuiCache[i],trans);
        end
    end 
    for i = 1, #roleList do
        self._roleuiCache[i].gameObject:SetActive(true);
        self._roleuiCache[i].roleItem:Refresh(roleList[i]);
        self._roleuiCache[i].transform:GetComponent("UIEvent").id = self._baseEvent + i;
    end 

    if #roleList == 0 then
        self._rolePrefab.localPosition = self._addRoleTran.localPosition;--用来调整背景大小
    end
    
    local currentRoleCount = self._server:GetRoleCount();
    local maxRoleCount = LoginMgr.GetMaxRoleCount();
    if currentRoleCount<maxRoleCount then
        self._addRoleGo:SetActive(true);
        maxRoleCount = #roleList + 1;
        self._addRoleTran:SetSiblingIndex(#self._roleuiCache+1);
    else
        self._addRoleGo:SetActive(false);
    end
    self._grid:Reposition();

    local count = math.ceil(maxRoleCount / 3);
    self._bgWidget.height = count * 117;
    --UpdataWidget(self._bgWidget);--刷新背景图片大小
    UpdataWidget(self._arrowWidget);--刷新箭头位置
    --UpdataWidget(self._widget);--刷新Widget大小
    local pos = self._arrowTrans.localPosition;
    pos.x = data.isLeft and -200 or 200;
    self._arrowTrans.localPosition = pos;
end

function LoginWrapTableUISelectRole:OnClick(bid)
    if bid == 0 then
        --if LoginMgr.CheckCreateRole() then
            LoginMgr.SetSelectRole(nil);
            LoginMgr.RequestConnectLogin();
        --else
            --TipsMgr.TipByKey("login_role_limit_tip");--每个服务器创角数量限制
        --end
    else
        local role = self._roleList[bid];
        LoginMgr.SetSelectRole(role);
        LoginMgr.RequestConnectLogin();
    end
end

return LoginWrapTableUISelectRole;