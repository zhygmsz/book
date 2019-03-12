MainUIAIPet = class("MainUIAIPet", nil);

require ("Logic/Presenter/UI/Main/AIPetMain/UIAIPetDefine");


function MainUIAIPet:GetComponent(ctype)
    return self._componentTable[ctype];
end

function MainUIAIPet:EnterState(stype)
    --if self._statePool[stype] == self._currentState then return; end
    if self._currentState then
        self._currentState:OnExit();
        GameLog.Log("-----------Exit State "..self._currentState.__cname);
    end
    
    self._currentState= self._statePool[stype];
    GameLog.Log("-----------Enter State "..self._currentState.__cname);
    self._currentState:OnEnter();
end
--[[
    @desc: 
    author:{author}
    time:2019-02-18 10:32:41
    --@key:AIPetUIANIMATION
	--@default: 设置为默认动画
    @return:
]]
function MainUIAIPet:PlayAnimation(key,asDefault)
    self._componentTable[AIPetUICOM.Animation]:Play(key,asDefault);
end

function MainUIAIPet:MoveDefaultWorkPos()
    self._componentTable[AIPetUICOM.Drag]:MoveDefaultWorkPos();
end

function MainUIAIPet:DisableCom(...)
    local comKeys = {...};
    for i, key in ipairs(comKeys) do
        GameLog.Log("AIPetUICOM %s is Disable", key);
        self._componentTable[key]:OnDisable();
    end
end

function MainUIAIPet:EnableCom(...)
    local comKeys = {...};
    for i, key in ipairs(comKeys) do
        GameLog.Log("AIPetUICOM %s is Enable", key);
        self._componentTable[key]:OnEnable();
    end
end

function MainUIAIPet:DiableAllComs()
    for key, com in pairs(self._componentTable) do
        GameLog.Log("AIPetUICOM %s is Disable", key);
        com:OnDisable();
    end
end
function MainUIAIPet:EnableAllComs()
    for key, com in pairs(self._componentTable) do
        GameLog.Log("AIPetUICOM %s is Enable", key);
        com:OnEnable();
    end
end
function MainUIAIPet:ctor(ui)
    GameLog.Log("--------AIPet UI Open");
    local uiRootPath = "BottomRight/AIPetPanel";
    self._componentTable = {};
    for key,value in pairs(AIPetUICOM) do
        local comClass = require("Logic/Presenter/UI/Main/AIPetMain/Component/UIAIPetComponent"..key);
        self._componentTable[value] = comClass.new(ui, self, uiRootPath);
    end

    self._statePool = {};
    for key,value in pairs(AIPetUISTATE) do
        local stateClass = require("Logic/Presenter/UI/Main/AIPetMain/State/UIAIPetState"..key);
        self._statePool[value] = stateClass.new(self);
    end
end

function MainUIAIPet:OnDestroy()
    self._componentTable = nil;
    self._statePool = nil;
end

function MainUIAIPet:OnEnable(ui)
    self:RefreshState();
    GameEvent.Reg(EVT.AIPET,EVT.AIPET_SHOW_DESK,self.RefreshState,self);
    GameEvent.Reg(EVT.AIPET,EVT.AIPET_MAIN,self.RefreshState,self);
    GameEvent.Reg(EVT.AIPET,EVT.AIPET_FIRST_RECEIVE,self.OnFirstSelect,self);
end

function MainUIAIPet:OnDisable(ui)
    GameEvent.UnReg(EVT.AIPET,EVT.AIPET_SHOW_DESK,self.RefreshState,self);
    GameEvent.UnReg(EVT.AIPET,EVT.AIPET_MAIN,self.RefreshState,self);
    GameEvent.UnReg(EVT.AIPET,EVT.AIPET_FIRST_RECEIVE,self.OnFirstSelect,self);
    self:EnterState(AIPetUISTATE.Closed);
end

function MainUIAIPet:OnPress(id,pressed)
    GameLog.Log("OnPress AIPet %s, %s",id,pressed);
    self._currentState:OnPress(pressed,id);
end

function MainUIAIPet:OnClick(id)
    GameLog.Log("OnClick AIPet %s",id);
    self._currentState:OnClick(id);
end

function MainUIAIPet:OnDrag(delta,id)
    self._currentState:OnDrag(delta,id);
end

function MainUIAIPet:OnDragStart(id)
    self._currentState:OnDragStart(id);
end

function MainUIAIPet:OnDragEnd(id)
    self._currentState:OnDragEnd(id);
end

function MainUIAIPet:RefreshState()
    if AIPetMgr.GetPetInUse() and AIPetMgr.IsShowOnDesk() then--再次打开进入休眠状态
        self:EnterState(AIPetUISTATE.Inactive);
    else
        self:EnterState(AIPetUISTATE.Closed);--关闭状态
    end
end

function MainUIAIPet:OnFirstSelect()
    self:EnterState(AIPetUISTATE.Work);--开启状态
    AIPetMgr.NewAIDialog(WordData.GetWordStringByKey("AIPet_First_Pet"));--AIPet初次见面
end

return MainUIAIPet;








