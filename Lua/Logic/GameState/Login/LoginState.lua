LoginState = class("LoginState",BaseState)

function LoginState:ctor(...)
    BaseState.ctor(self,...);
end

function LoginState:OnEnter()
    BaseState.OnEnter(self);
    LoginMgr.StartLogin(true);
    GameInit.DestroyPlayer();
end

function LoginState:OnUpdate(...)
    BaseState.OnUpdate(self,...);
end

function LoginState:OnExit()
    BaseState.OnExit(self);
end

return LoginState;