EntityHelper = class("EntityHelper",EntityCharacter);

function EntityHelper:ctor(...)
    EntityCharacter.ctor(self,...);
end

return EntityHelper;