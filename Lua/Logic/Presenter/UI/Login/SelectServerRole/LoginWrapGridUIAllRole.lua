local LoginWrapGridUIAllRole = class("LoginWrapGridUIAllRole",BaseWrapContentUI);
local UILoginRoleItem = require("Logic/Presenter/UI/Login/UILoginRoleItem");
local UILoginServerItem = require("Logic/Presenter/UI/Login/UILoginServerItem");

function LoginWrapGridUIAllRole:ctor(wrapItemTrans)
    BaseWrapContentUI.ctor(self,wrapItemTrans);
    local iconTex = wrapItemTrans:Find("SpriteKuang/SpriteRole"):GetComponent("UITexture");
    local labelRoleName = wrapItemTrans:Find("LabelName"):GetComponent("UILabel");
    local levelLabel = wrapItemTrans:Find("SpriteKuang/SpriteRole/LabelLevel"):GetComponent("UILabel");
    self._roleItem = UILoginRoleItem.new(iconTex,labelRoleName,levelLabel);

    local labelServerName = wrapItemTrans:Find("LabelServer"):GetComponent("UILabel");
    local spriteServerState = wrapItemTrans:Find("LabelServer/SpriteState"):GetComponent("UISprite");
    self._serverItem = UILoginServerItem.new(labelServerName,spriteServerState);

    self._event = wrapItemTrans:GetComponent("UIEvent");
    self:InsertUIEvent(self._event);
end

function LoginWrapGridUIAllRole:SetActive(b)
    self._gameObject:SetActive(b);
end

function LoginWrapGridUIAllRole:OnRefresh()
    local role = self._data;
    self._roleItem:Refresh(role);
    local server = role:GetServer();
    self._serverItem:Refresh(server);
end

return LoginWrapGridUIAllRole;