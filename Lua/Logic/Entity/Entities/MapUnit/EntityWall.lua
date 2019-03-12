EntityWall = class("EntityWall",EntityVisible);

function EntityWall:ctor(...)
    EntityVisible.ctor(self,...);
end

return EntityWall;