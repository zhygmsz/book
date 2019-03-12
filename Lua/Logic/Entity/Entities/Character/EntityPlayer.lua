EntityPlayer = class("EntityPlayer",EntityCharacter);

function EntityPlayer:ctor(...)
    EntityCharacter.ctor(self,...);
end

function EntityPlayer:GetDebugInfo()
    local debugInfo = {};
    for factionLevel,factionValue in ipairs(self._entityAtt.factions) do
        table.insert(debugInfo,string.format("faction:%s_%s",factionLevel,factionValue));
    end
    return table.concat(debugInfo,"\n");
end

return EntityPlayer;