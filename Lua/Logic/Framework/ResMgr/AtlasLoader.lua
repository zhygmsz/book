AtlasLoader = class("AtlasLoader",BaseLoader)

function AtlasLoader:ctor(uiSprite,spriteAnimation)
    BaseLoader.ctor(self);
    self._uiSprite = uiSprite;
    self._animation = spriteAnimation;
    self._config = nil;
    self._loading = false;
end

function AtlasLoader:dtor()
    if not tolua.isnull(self._uiSprite) then self._uiSprite.atlas = nil; end
    BaseLoader.dtor(self);
end

function AtlasLoader:LoadObject(loadResID,loadCallBack,isSelf,params)    
    self._loading = true;
    BaseLoader.LoadObject(self,loadResID,loadCallBack,false,isSelf,params);
end

function AtlasLoader:OnLoadFinish(...)
    BaseLoader.OnLoadFinish(self,...);
    if not tolua.isnull(self._uiSprite) then self._uiSprite.atlas = self._loadedObject:GetComponent("UIAtlas"); end
    if not tolua.isnull(self._animation) then 
        self._animation:RebuildSpriteList(); 
        self:Play();
    end

    self:OnPostLoad();
    self._loading = false;
end

function AtlasLoader:SetPlayConfig(config)
    self._config = config;
    if not self._loading then self:Play();  end
end

function AtlasLoader:Play()
    local ani = self._config;
    self._config = nil;
    if ani then
        self._animation:Play(ani.spriteName,ani.startIndex,ani.loop);
    end
end

return AtlasLoader;