EntityArea = class("EntityArea",EntityVisible);

function EntityArea:ctor(...)
    EntityVisible.ctor(self,...);
end

return EntityArea;