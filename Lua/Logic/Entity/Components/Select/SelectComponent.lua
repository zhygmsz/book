SelectComponent = class("SelectComponent",EntityComponent);

function SelectComponent:ctor(...)
    EntityComponent.ctor(self,...);
    self._enemyEffect = LoaderMgr.CreateEffectLoader();
    self._enemyEffect:LoadObject(403000006);
    self._friendEffect = LoaderMgr.CreateEffectLoader();
    self._friendEffect:LoadObject(403000008);
    self._LOSS_DISTANCE = ConfigData.GetValue("fight_select_loss_distance");
end

function SelectComponent:OnEnable()
    self:OnTargetUpdate(true);

    GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_CASTSKILL,self.OnCastSkill,self);
    GameEvent.Reg(EVT.COMMON,EVT.CLICK_ENTITY,self.OnSelectTarget,self);
    GameEvent.Reg(EVT.ENTITY,EVT.ENTITY_DELETE,self.OnDeleteEntity,self);
    GameEvent.Reg(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_CAMP,self.OnUpdateCamp,self);
end

function SelectComponent:OnUpdate(deltaTime)
    if self._selectTarget and self._selectTarget:IsValid() then
        if not self._LOSS_DISTANCE then return end
        local selfPosition = self._entity:GetPropertyComponent():GetPosition();
        local selectPosition = self._selectTarget:GetPropertyComponent():GetPosition();
        if math.DistanceXZ(selfPosition,selectPosition) >= self._LOSS_DISTANCE then
            self:OnTargetUpdate(true);
        end
    end
end

function SelectComponent:OnDisable()
    self:OnTargetUpdate(true);

    GameEvent.UnReg(EVT.PLAYER,EVT.PLAYER_CASTSKILL,self.OnCastSkill,self);
    GameEvent.UnReg(EVT.COMMON,EVT.CLICK_ENTITY,self.OnSelectTarget,self);
    GameEvent.UnReg(EVT.ENTITY,EVT.ENTITY_DELETE,self.OnDeleteEntity,self);
    GameEvent.UnReg(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_CAMP,self.OnUpdateCamp,self);
end

function SelectComponent:OnCastSkill(skillTarget)
    local selectTarget = (skillTarget and skillTarget.IsValid) and skillTarget or nil;
    if self._selectTarget == selectTarget then return end
    self._selectTarget = selectTarget;
    self:OnTargetUpdate();
end

function SelectComponent:OnSelectTarget(selectTarget)
    if self._selectTarget == selectTarget then return end
    self._selectTarget = selectTarget;
    self:OnTargetUpdate();
    if MapMgr.IsInBigWorld() and self._entity:GetCampComponent():IsRed(self._selectTarget) then
        UserData.SetAutoFight(true);
    end
end

function SelectComponent:OnDeleteEntity(entity)
    if self._selectTarget and self._selectTarget == entity then
        self:OnTargetUpdate(true);
    end
end

function SelectComponent:OnUpdateCamp(entity)
    if self._selectTarget and self._selectTarget == entity then
        self:OnTargetUpdate(true);
    end
end

function SelectComponent:OnTargetUpdate(needClear)
    if needClear then self._selectTarget = nil end
    local entityRoot = self._entity:GetModelComponent():GetEntityRoot();
    if self._selectTarget then
        local selfCampComponent = self._entity:GetCampComponent();
        local targetRoot = self._selectTarget:GetModelComponent():GetEntityRoot();
        local targetRadius = self._selectTarget:GetPropertyComponent():GetWidth();
        if selfCampComponent:IsRed(self._selectTarget) then
            self._friendEffect:SetParent(entityRoot);
            self._friendEffect:SetActive(false);
            self._enemyEffect:SetParent(targetRoot,true);
            self._enemyEffect:SetLocalScale(Vector3(targetRadius,targetRadius,targetRadius),true);
            self._enemyEffect:SetActive(true,true);
        elseif selfCampComponent:IsGreen(self._selectTarget) then
            self._enemyEffect:SetParent(entityRoot);
            self._enemyEffect:SetActive(false);
            self._friendEffect:SetParent(targetRoot,true);
            self._friendEffect:SetLocalScale(Vector3(targetRadius,targetRadius,targetRadius),true);
            self._friendEffect:SetActive(true,true);
        else
            self:OnTargetUpdate(true);
        end
    else
        self._enemyEffect:SetParent(entityRoot);
        self._enemyEffect:SetActive(false);
        self._friendEffect:SetParent(entityRoot);
        self._friendEffect:SetActive(false);
    end
end

return SelectComponent;