SACT_PlayAction = class("SACT_PlayAction",SACT_Base)

function SACT_PlayAction:ctor(...)
	SACT_Base.ctor(self,...);
	--动作名称
	self._actionName = self._actionAtt.args[1].strValue;
	--自动退出
	self._needAutoExit = self._actionAtt.args[2].intValue == 1;
	--强制播放
	self._needForcePlay = self._actionAtt.args[3].intValue == 1;
end

function SACT_PlayAction:DoStartEffect()
	--进入技能释放状态
	self._actionEntity:GetStateComponent():PlayAnim(self._actionName,self._needAutoExit,"",self._needForcePlay);
end

return SACT_PlayAction;