EntityNPC = class("EntityNPC",EntityCharacter);

function EntityNPC:ctor(...)
    EntityCharacter.ctor(self,...);
    self:AddComponent(EntityDefine.COMPONENT_TYPE.COLLIDER,ColliderComponent.new(self));
end

--NPC类型
function Entity:GetNPCType()
    return self._entityAtt.npcData.npcType;
end

--NPC静态ID
function Entity:GetNPCStaticID()
    return self._entityAtt.npcData.id;
end

function EntityNPC:GetDebugInfo()
    local debugInfo = {};
    table.insert(debugInfo,string.format("unitID:%s",self._entityAtt.unitID));
    for factionLevel,factionValue in ipairs(self._entityAtt.factions) do
        table.insert(debugInfo,string.format("faction:%s_%s",factionLevel,factionValue));
    end
    return table.concat(debugInfo,"\n");
end

return EntityNPC;