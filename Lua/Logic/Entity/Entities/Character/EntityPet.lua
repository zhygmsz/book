EntityPet = class("EntityPet",EntityCharacter);

function EntityPet:ctor(...)
    EntityCharacter.ctor(self,...);
end

return EntityPet;