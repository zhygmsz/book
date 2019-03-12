EffectController = class("EffectController")

function EffectController:ctor(stateComponent)
    self._playerData = stateComponent._entity._entityAtt.playerData;
    self._stateComponent = stateComponent;
    self._modelComponent = stateComponent._entity:GetModelComponent();
    self._modelObject = nil;
end

function EffectController:OnEnable()
    if not self._runEffects then
        --移动特效每个状态都是一个特效组
        self._runEffects = {};
        self._runEffects.start = 
        {
            LoaderMgr.CreateEffectLoader(),
            LoaderMgr.CreateEffectLoader(),
        };
        self._runEffects.run = 
        {
            LoaderMgr.CreateEffectLoader(),
            LoaderMgr.CreateEffectLoader(),
        };
        self._runEffects.stop = 
        {
            LoaderMgr.CreateEffectLoader(),
        };
        --加速开始
        self._runEffects.start[1]:LoadObject(self._playerData.runStartEffect1ID);
        self._runEffects.start[2]:LoadObject(self._playerData.runStartEffect2ID);
        --加速中
        self._runEffects.run[1]:LoadObject(self._playerData.handEffectID);
        self._runEffects.run[2]:LoadObject(self._playerData.spineEffectID);
        --加速结束
        self._runEffects.stop[1]:LoadObject(self._playerData.runStopEffectID);
    end
    for _,effectGroups in pairs(self._runEffects) do
        for __,effectLoader in ipairs(effectGroups) do
            effectLoader:SetActive(false);
        end
    end
    if self._modelObject then self:OnModelReady(); end
end

function EffectController:OnDisable()
    for _,effectGroups in pairs(self._runEffects) do
        for __,effectLoader in ipairs(effectGroups) do
            effectLoader:SetActive(false);
            effectLoader:SetParent(LoaderMgr.LoaderNullRoot());
        end
    end
end

function EffectController:OnModelLoad(modelObject)
    self._modelObject = modelObject;
    self:OnModelReady();
end

function EffectController:OnModelReplace()
    local rootGo = self._modelComponent:GetEntityRoot();
    self._runEffects.run[1]:SetParent(rootGo,true);
    self._runEffects.run[2]:SetParent(rootGo,true);
end

function EffectController:OnModelReady()
    local rootGo = self._modelComponent:GetEntityRoot();
    for _,effectLoader in ipairs(self._runEffects.start) do
        effectLoader:SetParent(rootGo,true);
    end
    for _,effectLoader in ipairs(self._runEffects.stop) do
        effectLoader:SetParent(rootGo,true);
    end
    local handBone = self._modelComponent:GetEntityBone("Bip001 L Hand");
    self._runEffects.run[1]:SetParent(handBone,true);
    self._runEffects.run[1]:SetLayer(CameraLayer.EffectLayer);
    local spineBone = self._modelComponent:GetEntityBone("Bip001 Spine1");
    self._runEffects.run[2]:SetParent(spineBone,true);
    self._runEffects.run[2]:SetLayer(CameraLayer.EffectLayer);
end

function EffectController:OnRunStateChange(isRun)
    for _,effectLoader in ipairs(self._runEffects.start) do
        effectLoader:SetActive(isRun);
    end
    for _,effectLoader in ipairs(self._runEffects.run) do
        effectLoader:SetActive(isRun);
    end
    for _,effectLoader in ipairs(self._runEffects.stop) do
        effectLoader:SetActive(not isRun);
    end
end