InitState = class("InitState",BaseState)

function InitState:ctor(...)
    BaseState.ctor(self,...);
end

function InitState:OnEnter()
    BaseState.OnEnter(self);
    require("Logic/GameInit/GameInit");
    GameInit.Begin();
end

function InitState:OnUpdate(...)
    BaseState.OnUpdate(self,...);
    self._stateProgress = GameInit.Update();
    if self._stateProgress >= 1 and self._loadingProgress >= 1 then
        GameInit.Finish();
        UI_LoadingUpdate.OnDisable();
        GameCore.UIMgr.Instance:UnLoadUI(GameStateMgr.UPDATE_UI_ID);
        GameStateMgr.EnterLogin();
    end
end

function InitState:OnExit()
    BaseState.OnExit(self);
end

function InitState:GetStateProgressDes()
    return GameInit.State();
end

return InitState;