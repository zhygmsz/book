StartState = class("StartState",BaseState)

function StartState:ctor(...)
    BaseState.ctor(self,...);
end

function StartState:OnEnter()
    BaseState.OnEnter(self);
    local function OnCreate(uiID,uiFrame)
        uiFrame:SetUILayer(-4,0,-1);
        uiFrame:SetPanelDepth(400);
        UI_LoadingUpdate.OnCreate(uiFrame);
    end
    local function OnEnable(uiID,uiFrame) 
        UI_LoadingUpdate.OnEnable(uiFrame); 
    end
    --打开加载界面
    require("Logic/Presenter/UI/Loading/UI_LoadingUpdate");
    GameStateMgr.UPDATE_UI_ID = -1;
    GameStateMgr.UPDATE_UI_RES_ID = GameCore.ResMgr.Instance:DefineAsset("Assets/Res/UI/Prefab/UI_LoadingUpdate.prefab");
    GameCore.UIMgr.Instance:Init(OnCreate,OnEnable);
    GameCore.UIMgr.Instance:ShowUI(GameStateMgr.UPDATE_UI_ID, GameStateMgr.UPDATE_UI_RES_ID, false);
    --播放开场视频
    local cgState = UnityEngine.PlayerPrefs.GetInt("cg_play_flag");
    if cgState == 0 then
        CGPlayer.PlayMovie("CG_LDJ.mp4", System.Action(self.EnterInitState,self));
    else
        self:EnterInitState();
    end
end

function StartState:OnUpdate(...)
    BaseState.OnUpdate(self,...);
end

function StartState:OnExit()
    BaseState.OnExit(self);
end

function StartState:EnterInitState()
    GameStateMgr.UpdateModule();
    GameStateMgr.EnterInit();
end

return StartState;