AACT_PlayEffect = class("AACT_PlayEffect",AACT_Base);

function AACT_PlayEffect:ctor(...)
    AACT_Base.ctor(self,...);
    self._effectID = self._actionArgs[1].intValue;
    self._effectLoader = LoaderMgr.CreateEffectLoader();
    self._effectLoader:LoadObject(self._effectID);
    self._effectLoader:SetParent(EntityDefine.ENTITY_ROOT.effect);
    self._effectLoader:SetLayer(CameraLayer.EffectLayer);
end

function AACT_PlayEffect:DoStartEffect()
    local position = self._actionEntity:GetPropertyComponent():GetPosition();  
    local forward = self._actionEntity:GetPropertyComponent():GetForward();
    local root = self._actionEntity:GetModelComponent():GetEntityRoot();
    self._effectLoader:SetParent(root);
    self._effectLoader:SetPosition(position);
    self._effectLoader:SetForward(forward);
    self._effectLoader:SetActive(true,true);
end

function AACT_PlayEffect:DoUpdateEffect()
end

function AACT_PlayEffect:DoStopEffect()
    LoaderMgr.DeleteLoader(self._effectLoader); 
    self._effectLoader = nil;
end

return AACT_PlayEffect;