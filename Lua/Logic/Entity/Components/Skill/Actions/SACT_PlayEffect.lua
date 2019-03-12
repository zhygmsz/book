SACT_PlayEffect = class("SACT_PlayEffect",SACT_Base)

function SACT_PlayEffect:ctor(...)
    SACT_Base.ctor(self,...);
    self._effectName = self._actionAtt.args[1].strValue;
    self._boneName = self._actionAtt.args[2].strValue;
    self._localPos = math.ConvertProtoV3(self._actionAtt.args[3].vector3Value);
    self._offsetType = self._actionAtt.args[4] and self._actionAtt.args[4].intValue or 0;

    self._effectLoader = LoaderMgr.CreateEffectLoader();
    self._effectLoader:LoadObject(ResConfigData.GetResConfigID(self._effectName));
    self._effectLoader:SetParent(EntityDefine.ENTITY_ROOT.effect);
    self._effectLoader:SetLayer(CameraLayer.EffectLayer);
    self._effectLoader:SetActive(false);
end

function SACT_PlayEffect:OffsetFromBone()
    local effectBone = self._actionEntity:GetModelComponent():GetEntityBone(self._boneName);
    if effectBone then
        self._effectLoader:SetParent(effectBone);
        self._effectLoader:SetLocalPosition(self._localPos);
        self._effectLoader:SetForward(Vector3.forward);
    else
        self:OffsetFromRoot();
    end
end

function SACT_PlayEffect:OffsetFromRoot()
    local position = self._actionEntity:GetPropertyComponent():GetPosition() + self._localPos;  
    local forward = self._actionEntity:GetPropertyComponent():GetForward();
    self._effectLoader:SetParent(EntityDefine.ENTITY_ROOT.effect);
    self._effectLoader:SetLocalPosition(position);
    self._effectLoader:SetForward(forward);
end

function SACT_PlayEffect:OffsetFromTarget()
    if self._actionOwner._skillTarget then
        local forward = self._actionEntity:GetPropertyComponent():GetForward();
        self._effectLoader:SetParent(EntityDefine.ENTITY_ROOT.effect);
        self._effectLoader:SetLocalPosition(self._actionOwner._skillTarget);
        self._effectLoader:SetForward(forward);
    else
        self:OffsetFromRoot();
    end
end

function SACT_PlayEffect:DoStartEffect()
    if self._offsetType == 0 then
        self:OffsetFromBone();
    elseif self._offsetType == 1 then
        self:OffsetFromTarget();
    end
    self._effectLoader:SetActive(false);
    self._effectLoader:SetActive(true);
end

function SACT_PlayEffect:DoStopEffect()
    self._effectLoader:SetParent(EntityDefine.ENTITY_ROOT.effect);
    self._effectLoader:SetActive(false);
end

function SACT_PlayEffect:DoDestroyEffect()
    LoaderMgr.DeleteLoader(self._effectLoader); 
    self._effectLoader = nil;
end

function SACT_PlayEffect:DoModelLoadEffect()
    if self._offsetType == 0 then
    
    end
end

function SACT_PlayEffect:DoModelReplaceEffect()
    if self._offsetType == 0 then
        
    end
end

return SACT_PlayEffect;