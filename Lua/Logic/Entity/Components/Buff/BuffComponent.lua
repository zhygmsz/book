BuffComponent = class("BuffComponent",EntityComponent);

function BuffComponent:ctor(...)
    EntityComponent.ctor(self,...);
    self._buffGroups = self._buffGroups or {};
end

function BuffComponent:OnStart()
    --出生时携带的有效BUFF
    for idx,bornBuff in ipairs(self._entity._entityAtt.bornBuffs) do
        if bornBuff.id then
            local buffGroup = BuffFactory.CreateBuffGroup(bornBuff.id,bornBuff.buffID,nil,self);
            buffGroup:SetLeftTime(bornBuff.startTime,bornBuff.lastTime)
            self._buffGroups[bornBuff.id] = buffGroup;
            table.clear(bornBuff);
            GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_ADD_BUFF,buffGroup);
        end
    end
end

function BuffComponent:OnUpdate(deltaTime)
    for id,buffGroup in pairs(self._buffGroups) do
        buffGroup:OnUpdate(deltaTime);
    end
end

function BuffComponent:OnDisable()
    for id,buffGroup in pairs(self._buffGroups) do
        self:DoRemoveBuff(id,buffGroup);
    end
end

function BuffComponent:OnModelLoad()
    for id,buffGroup in pairs(self._buffGroups) do
        buffGroup:OnModelLoad();
    end
end

function BuffComponent:OnModelReplace()
    for id,buffGroup in pairs(self._buffGroups) do
        buffGroup:OnModelReplace();
    end
end

function BuffComponent:AddBuff(dynamicID,buffID,attacker)
    local buffGroup = BuffFactory.CreateBuffGroup(dynamicID,buffID,attacker,self);
    self._buffGroups[dynamicID] = buffGroup;
    GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_ADD_BUFF,buffGroup);
end

function BuffComponent:UpdateBuff(dynamicID,startTime,lastTime)
    local buffGroup = self._buffGroups[dynamicID];
    if buffGroup then
        buffGroup:SetLeftTime(startTime,lastTime);
        GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_UPDATE_BUFF,buffGroup);
    else
        GameLog.Log("can't find buff %s",dynamicID);
    end
end

function BuffComponent:RemoveBuff(dynamicID)
    local buffGroup = self._buffGroups[dynamicID];
    if buffGroup then
        self:DoRemoveBuff(dynamicID,buffGroup);
    else
        GameLog.Log("can't find buff %s",dynamicID);
    end
end

function BuffComponent:RemoveAll()
    for id,buffGroup in pairs(self._buffGroups) do
        self:DoRemoveBuff(id,buffGroup);
    end
end

function BuffComponent:DoRemoveBuff(dynamicID,buffGroup)
    BuffFactory.DestroyBuffGroup(buffGroup);
    self._buffGroups[dynamicID] = nil;
    GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_REMOVE_BUFF,buffGroup);
end