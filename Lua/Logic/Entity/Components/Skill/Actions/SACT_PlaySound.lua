SACT_PlaySound = class("SACT_PlaySound",SACT_Base)

function SACT_PlaySound:ctor(...)
	SACT_Base.ctor(self,...);
	--音效ID
	self._soundID = self._actionAtt.args[1].intValue;
end

function SACT_PlaySound:DoStartEffect()
end

function SACT_PlaySound:DoStopEffect()
end

return SACT_PlaySound;