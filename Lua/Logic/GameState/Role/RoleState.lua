
RoleState = class("RoleState",BaseState)

function RoleState:ctor(...)
    BaseState.ctor(self,...);
    
end

function RoleState:GetCr()
    if self._cr==nil then
        local CrViewModel= require("Logic/Presenter/UI/CreateRole/CrViewModel")
        self._cr = CrViewModel.new()
    end
    return self._cr
end

function RoleState:OnEnter()
    BaseState.OnEnter(self);
    self._enterFinish = false
    self._sceneLoaded = false
    UIMgr.ShowUI(AllUI.UI_Loading,self,self.OnLoadingOpen);
    self:GetCr():Enter()
end

function RoleState:OnUpdate(...)
    BaseState.OnUpdate(self,...);
    if not self._enterFinish and self._stateProgress >= 1 and self._loadingProgress >= 1 then
        self._enterFinish = true;
        --UIMgr.UnShowUI(AllUI.UI_Loading);
        self:LoadFinish()
    end
end

function RoleState:OnExit()
    BaseState.OnExit(self);
    self:GetCr():Destory()
    self._cr=nil
end

function RoleState:OnLoadingOpen()
    self:GetCr():OnLoadingOpen(self)
end

local function CloseLoadingUI()
    UIMgr.UnShowUI(AllUI.UI_Login);
    UIMgr.UnShowUI(AllUI.UI_Loading);
end

function RoleState:LoadFinish()
    if  self._enterFinish and self._stateProgress >= 1 and  self._sceneLoaded then
        self:GetCr():LoadFinish(self,CloseLoadingUI)
    end
end

function RoleState:OnSceneLoad()
    self._stateProgress = 0.8;
    self:GetCr():OnSceneLoad(self)
    self._sceneLoaded = true
    self._stateProgress = 1;
    self:LoadFinish()
    --UIMgr.ShowUI(AllUI.UI_Login_CreateRole,self,self.OnCreateRoleOpen);
end

function RoleState:OnCreateRoleOpen()
    self._stateProgress = 1;
    self:LoadFinish()
    --self:GetCr():OnCreateRoleOpen()
end

return RoleState;
        