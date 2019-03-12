local UILoginRoleItem = class("UILoginRoleItem");

function UILoginRoleItem:ctor(texture,nameLabel,levelLabel)
    self._textureLoader = LoaderMgr.CreateTextureLoader(texture);
    self._nameLabel = nameLabel;
    self._levelLabel = levelLabel;
end

function UILoginRoleItem:Refresh(role)
    if not role then return; end
    if self._textureLoader then
        self._textureLoader:LoadObject(role:GetIcon());
    end
    if self._nameLabel then
        self._nameLabel.text = role:GetName();
    end
    if self._levelLabel then
        self._levelLabel.text = role:GetLevel();
    end
end

return UILoginRoleItem;