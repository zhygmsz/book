TextureLoader = class("TextureLoader",BaseLoader)

function TextureLoader:ctor(uiTexture)
    BaseLoader.ctor(self);
    self._uiTexture = uiTexture;
    self._pixelPerfect = nil;
end

function TextureLoader:dtor()
    if not tolua.isnull(self._uiTexture) then self._uiTexture.mainTexture = nil; end
    BaseLoader.dtor(self);
    self._pixelPerfect = nil;
end

function TextureLoader:LoadObject(loadResID,loadCallBack,isSelf,params)
    BaseLoader.LoadObject(self,loadResID,loadCallBack,false,isSelf,params);
end

function TextureLoader:OnLoadFinish(...)
    BaseLoader.OnLoadFinish(self,...);
    if not tolua.isnull(self._uiTexture) then 
        self._uiTexture.mainTexture = self._loadedObject;
        if self._pixelPerfect then
            self._uiTexture:MakePixelPerfect();
        end
    end
    self:OnPostLoad();
end

function TextureLoader:SetPixelPerfect(pixelPerfect)
    self._pixelPerfect = pixelPerfect;
    if self._pixelPerfect and not tolua.isnull(self._uiTexture) then self._uiTexture:MakePixelPerfect(); end 
end

return TextureLoader;