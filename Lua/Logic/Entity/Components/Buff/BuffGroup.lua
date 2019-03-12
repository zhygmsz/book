BuffGroup = class("BuffGroup");

function BuffGroup:ctor(dynamicID,buffID,attacker,buffComponent)
    self._dynamicID = dynamicID;
    self._buffID = buffID;
    self._buffData = BuffData.GetBuffData(self._buffID);
    self._layerData = BuffData.GetBuffLayerData(self._buffData.layer);
    self._attacker = attacker;
    self._buffComponent = buffComponent;
    self._buffEffects = self._buffEffects or {};
    self._buffEffectLoader = LoaderMgr.CreateEffectLoader();
    self:OnStart();
end

function BuffGroup:dtor()
    self:OnDestroy();
end

function BuffGroup:OnStart()
    --创建BUFF组拥有的效果
    for index,effectID in ipairs(self._buffData.effects) do
        local buffEffect = BuffFactory.CreateBuffEffect(self,effectID);
        if buffEffect then
            self._buffEffects[#self._buffEffects + 1] = buffEffect;
        end
    end
    --BUFF特效
    if self._buffData.effectID ~= 0 then
        local ownerEntity = self._buffComponent._entity;
        self._buffEffectLoader:LoadObject(self._buffData.effectID);
        self._buffEffectLoader:SetParent(ownerEntity:GetModelComponent():GetEntityRoot(),true);
        self._buffEffectLoader:SetActive(true,true);
        self:OnModelLoad();
    end
end

function BuffGroup:OnUpdate(deltaTime)
    for _,buffEffect in ipairs(self._buffEffects) do
        buffEffect:OnUpdate(deltaTime);
    end
end

function BuffGroup:OnDestroy()
    LoaderMgr.DeleteLoader(self._buffEffectLoader);
    for id,buffEffect in ipairs(self._buffEffects) do
        BuffFactory.DestroyBuffEffect(buffEffect);
        self._buffEffects[id] = nil;
    end
end

function BuffGroup:OnModelLoad()
    if self._buffData.effectID ~= 0 and self._buffData.boneID ~= 0 then
        --TODO 根据不同体型设置不同偏移和缩放
        local ownerEntity = self._buffComponent._entity;
        local bindBoneData = BuffData.GetBuffBoneData(self._buffData.boneID);
        local bineBoneTrans = bindBoneData.transform[1];
        local bindBoneTran = ownerEntity:GetModelComponent():GetEntityBone(bindBoneData.boneName) or ownerEntity:GetModelComponent():GetEntityRoot();
        self._buffEffectLoader:SetParent(bindBoneTran,true);
        self._buffEffectLoader:SetLocalScale(Vector3(bineBoneTrans.scale,bineBoneTrans.scale,bineBoneTrans.scale));
        self._buffEffectLoader:SetLocalPosition(Vector3(0,bineBoneTrans.offset,0));
    end
end

function BuffGroup:OnModelReplace()
    if self._buffData.effectID ~= 0 and self._buffData.boneID ~= 0 then
        --变身或者其它状态导致模型发生变化
        local ownerEntity = self._buffComponent._entity;
        local bindBoneTran = ownerEntity:GetModelComponent():GetEntityRoot();
        self._buffEffectLoader:SetParent(bindBoneTran,true);
    end
end

function BuffGroup:IsFinished()
    for _,buffEffect in ipairs(self._buffEffects) do
        if not buffEffect:IsFinished() then return false; end
    end
    return true;
end

function BuffGroup:GetLeftTime()
    local finalLeftTime = -1;
    for k,buffEffect in ipairs(self._buffEffects) do
        local leftTime = buffEffect:GetLeftTime();
        --剩余时间为-1表示BUFF为永久不限时
        if leftTime == -1 then return -1 end
        finalLeftTime = math.max(leftTime,finalLeftTime)
    end
    return finalLeftTime;
end

function BuffGroup:SetLeftTime(startTime,lastTime)
    local passedTime = TimeUtils.TimeStampPass(startTime);
    for k,buffEffect in ipairs(self._buffEffects) do
        buffEffect:SetLeftTime(passedTime,lastTime);
    end
end