AACT_ShowUI = class("AACT_ShowUI", AACT_Base);

function AACT_ShowUI:ctor(...)
	AACT_Base.ctor(self, ...);
	self.uiName = self._actionArgs[1].strValue;
end

function AACT_ShowUI:DoStartEffect()
	if self.uiName == "UI_Tip_LevelUp" then
		if self._actionEntity:IsSelf() then
			UIMgr.ShowUI(AllUI[self.uiName]);
		end
	end
end

function AACT_ShowUI:DoUpdateEffect()
end

function AACT_ShowUI:DoStopEffect()
end

return AACT_ShowUI; 