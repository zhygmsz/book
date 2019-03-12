module("GameStateMgr",package.seeall)

local mStateMap = {};
local mCurrentState = nil;
local mStateRoot = nil;

local STATE_TYPE = 
{
    START       = 100,      --启动状态
    INIT        = 200,      --初始化状态
    LOGIN       = 300,      --登录状态
    ROLE        = 400,      --创建角色
    MAP         = 500,      --游戏副本状态
}

local function EnterState(nextStateType,...)
    if mCurrentState then mCurrentState:OnExit() end
    mCurrentState = mStateMap[nextStateType];
    mCurrentState:OnEnter(...);
end

local function RegisterState(statePath,stateType)
    local state = require(statePath);
    if stateType then mStateMap[stateType] = state.new(mStateRoot); end
end

local function UpdateState()
    if mCurrentState then mCurrentState:OnUpdate(UnityEngine.Time.deltaTime * 1000); end
end

local function LateUpdateState()
    if mCurrentState then mCurrentState:OnLateUpdate(UnityEngine.Time.deltaTime * 1000); end
end

--启动时初始化
function InitModule()
    mStateRoot = UnityEngine.GameObject.New("GAME_STATE").transform;
    UnityEngine.GameObject.DontDestroyOnLoad(mStateRoot.gameObject);
    RegisterState("Logic/GameState/BaseState");
    RegisterState("Logic/GameState/Start/StartState",STATE_TYPE.START);
    UpdateBeat:Add(UpdateState);
    LateUpdateBeat:Add(LateUpdateState);
end

--更新后初始化
function UpdateModule()
    RegisterState("Logic/GameState/Init/InitState",STATE_TYPE.INIT);
    RegisterState("Logic/GameState/Login/LoginState",STATE_TYPE.LOGIN);
    RegisterState("Logic/GameState/Role/RoleState",STATE_TYPE.ROLE);
    RegisterState("Logic/GameState/Map/MapState",STATE_TYPE.MAP);
end

function EnterStart()
    EnterState(STATE_TYPE.START);
end

function EnterInit()
    EnterState(STATE_TYPE.INIT);
end

function EnterLogin()
    EnterState(STATE_TYPE.LOGIN);
end

function EnterRole()
    EnterState(STATE_TYPE.ROLE);
end

function EnterMap(mapID,mapUnitID)
    EnterState(STATE_TYPE.MAP,mapID,mapUnitID);
end

function GetState()
    return mCurrentState;
end

return GameStateMgr;