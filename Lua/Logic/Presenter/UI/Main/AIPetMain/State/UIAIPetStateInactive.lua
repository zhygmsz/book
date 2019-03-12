local UIAIPetStateBase = require("Logic/Presenter/UI/Main/AIPetMain/State/UIAIPetStateBase");
local UIAIPetStateInactive = class("UIAIPetStateInactive",UIAIPetStateBase);

function UIAIPetStateInactive:ctor(context)
    self.super.ctor(self, context);
    self._dragCom = context:GetComponent(AIPetUICOM.Drag);
end

function UIAIPetStateInactive:OnEnter()
    self._context:EnableCom(
        AIPetUICOM.Drag,
        AIPetUICOM.Animation,
        AIPetUICOM.Notice
    );
    self._context:DisableCom(
        AIPetUICOM.BoxTip,
        AIPetUICOM.Message,
        AIPetUICOM.Record
    );
    self._context:PlayAnimation(AIPetUIANIMATION.InactiveIdle,true);
    self._dragCom:MoveDefaultInactivePos();
end

function UIAIPetStateInactive:OnExit()
    self._context:DisableCom(
        AIPetUICOM.Notice
    );
end

function UIAIPetStateInactive:OnClick(id)
    if id == 1008 then
        self._context:EnterState(AIPetUISTATE.Work);
        self._context:MoveDefaultWorkPos();
    end
end

return UIAIPetStateInactive;

