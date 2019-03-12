AACT_PlaySound = class("AACT_PlaySound",AACT_Base);

function AACT_PlaySound:ctor(...)
    AACT_Base.ctor(self,...);
end

function AACT_PlaySound:DoStartEffect()
end

function AACT_PlaySound:DoUpdateEffect()
end

function AACT_PlaySound:DoStopEffect()
end

return AACT_PlaySound;