MapState = class("MapState",BaseState)

local MAP_STATE_STEP = 
{
    --开始进入副本
    STEP_BEGIN              = 1;
    --清理副本资源
    STEP_UNLOAD_ASSET       = 2;
    --加载副本场景
    STEP_LOAD_SCENE         = 3;
    --加载副本资源
    STEP_LOAD_ASSET         = 4;
    --创建副本对象
    STEP_CREATE_ENTITY      = 5;
    --副本更新
    STEP_MAP_TICK           = 6;
    --副本退出
    STEP_END                = 7;
}

function MapState:ctor(...)
    BaseState.ctor(self,...);
end

function MapState:OnEnter(mapID,mapUnitID)
    BaseState.OnEnter(self);

    --当前副本数据
    self._mapID = mapID;
    self._mapUnitID = mapUnitID;
    self._mapSceneID = MapData.GetSceneID(mapUnitID);
    self._mapData = MapData.GetMapInfo(mapID);
    self._mapUnitData = MapData.GetMapUnit(mapUnitID);
    self._mapPreloadData = MapData.GetMapPreload(mapID);
    self._mapEntityManager = self._mapEntityManager or EntityManager.new();

    --当前副本类型
    self._mapClientType = self._mapData.clientType;
    if self._mapClientTypePrev and self._mapSceneIDPrev then
        --从镜像副本内出来,当前进入类型仍然按照镜像处理
        local equalType = self._mapClientTypePrev == MapInfo_pb.SpaceConfig.Image;
        local equalScene = self._mapSceneIDPrev == self._mapSceneID;
        if equalType and equalScene then 
            self._mapClientType = MapInfo_pb.SpaceConfig.Image;
        end
    end
    self._mapClientTypePrev = self._mapClientType;
    self._mapSceneIDPrev = self._mapSceneID;

    --进入下一阶段
    self._mapStep = MAP_STATE_STEP.STEP_END;
    self:EnterNextStep();
end

function MapState:OnUpdate(deltaTime)
    BaseState.OnUpdate(self,deltaTime);
    if self._mapStep == MAP_STATE_STEP.STEP_MAP_TICK then
        --更新副本对象
        self._mapEntityManager:OnUpdate(deltaTime);
    elseif self._mapStep == MAP_STATE_STEP.STEP_CREATE_ENTITY then
        --等待加载进度结束,进入下一阶段
        if self._stateProgress >= 1 and self._loadingProgress >= 1 then
            self:EnterNextStep();
        end
    end
end

function MapState:OnLateUpdate(deltaTime)
    if self._mapStep == MAP_STATE_STEP.STEP_MAP_TICK then
        --处理一些依赖UPDATE的更新逻辑
        self._mapEntityManager:OnLateUpdate(deltaTime);
    end
end

function MapState:OnExit()
    BaseState.OnExit(self);
    --退出当前副本,只删除所有副本对象
    self._mapEntityManager:OnDestroy();
    self._mainPlayer = nil;
    TouchMgr.SetEnableEvent(true);
end

function MapState:EnterNextStep()
    if not self._mapStepData then
        self._mapStepData = {};
        self._mapStepData[MAP_STATE_STEP.STEP_BEGIN] = self.OnEnterStepBegin;
        self._mapStepData[MAP_STATE_STEP.STEP_UNLOAD_ASSET] = self.OnEnterStepUnLoadAssets;
        self._mapStepData[MAP_STATE_STEP.STEP_LOAD_SCENE] = self.OnEnterStepLoadScene;
        self._mapStepData[MAP_STATE_STEP.STEP_LOAD_ASSET] = self.OnEnterStepLoadAssets;
        self._mapStepData[MAP_STATE_STEP.STEP_CREATE_ENTITY] = self.OnEnterStepCreateEntity;
        self._mapStepData[MAP_STATE_STEP.STEP_MAP_TICK] = self.OnEnterStepTick;
    end
    if self._mapStep == MAP_STATE_STEP.STEP_END then self._mapStep = MAP_STATE_STEP.STEP_BEGIN - 1; end
    self._mapStep = self._mapStep + 1;
    self._stateProgress = self._stateProgress + 0.2;
    self._mapStepData[self._mapStep](self);
end

function MapState:OnEnterStepBegin()
    --第一阶段,打开加载界面
    local CLIENT_TYPE_ENUM = MapInfo_pb.SpaceConfig;
    if self._mapClientType == CLIENT_TYPE_ENUM.Image then
        --镜像副本切换,显示过渡特效,然后进入下一阶段
        CameraMgr.PlayCameraEffect(CameraDefine.CAMERA_EFFECT.CE_WATER_WAVE,1.5);
        TouchMgr.SetEnableEvent(false);
        self:EnterNextStep();
    else
        --普通副本切换(先打开界面,再加载过渡场景,然后进入下一阶段)
        local function OnSwitchSceneOpen(selfObj)
            selfObj:EnterNextStep();
        end
        local function OnLoadingUIOpen(selfObj)
            UIMgr.UnShowAllUI(AllUI.UI_Loading);
            ResMgr.LoadSwitchScene(selfObj,OnSwitchSceneOpen);
        end
        UIMgr.ShowUI(AllUI.UI_Loading,self,OnLoadingUIOpen);
    end
end

function MapState:OnEnterStepUnLoadAssets()
    --第二阶段,清理副本资源
    local CLIENT_TYPE_ENUM = MapInfo_pb.SpaceConfig;
    --清理所有可以清理的资源,直接进入下一阶段

    --清理伤害跳字缓存
    GameCore.EntityDamage.Clear();
    
    if self._mapClientType == CLIENT_TYPE_ENUM.Image then
        --加一点延迟避免屏幕特效和对象创建同时开始导致的不平滑
        GameTimer.AddTimer(1.5,1,self.EnterNextStep,self);
    else
        UIMgr.UnloadUnusedAssets();
        ResMgr.UnloadUnusedAssets(true);
        ImageMgr.UnloadUnusedAssets();
        self:EnterNextStep();
    end
end

function MapState:OnEnterStepLoadScene()
    --第三阶段,加载副本场景
    local CLIENT_TYPE_ENUM = MapInfo_pb.SpaceConfig;
    if self._mapClientType == CLIENT_TYPE_ENUM.Image then
        --镜像副本不切换场景,直接进入下一阶段
        self:EnterNextStep();
    else
        --等待场景加载结束,进入下一阶段
        local function OnMapSceneLoad(selfObj)
            selfObj:EnterNextStep();
        end
        ResMgr.LoadSceneAsync(self._mapSceneID,self,OnMapSceneLoad);
    end
end

function MapState:OnEnterStepLoadAssets()
    --第四阶段,加载副本资源
    local CLIENT_TYPE_ENUM = MapInfo_pb.SpaceConfig;
    if self._mapClientType == CLIENT_TYPE_ENUM.Normal then
        --普通场景
        UIMgr.ShowUI(AllUI.UI_Main);
        UIMgr.ShowUI(AllUI.UI_HP_Main);
    elseif self._mapClientType == CLIENT_TYPE_ENUM.AIPetHome then
        --宠物家园
        UIMgr.ShowUI(AllUI.UI_AIPet_Home);
    elseif self._mapClientType == CLIENT_TYPE_ENUM.Image then
        if self._mapData.clientType ~= CLIENT_TYPE_ENUM.Image then
            --退出镜像副本
        else
            --进入镜像副本
        end
    end
    --触发资源加载事件
    GameEvent.Trigger(EVT.MAPEVENT,EVT.MAP_ENTER_LOAD,self._mapClientType);
    --通知服务器场景加载结束,可以创建对象了
    MapMgr.RequestEndLoadScene();
    --此时下一阶段需要等待服务器通知进入
end

function MapState:OnEnterStepCreateEntity()
    --第五阶段,创建副本对象
    local CLIENT_TYPE_ENUM = MapInfo_pb.SpaceConfig;
    if self._mapClientType == CLIENT_TYPE_ENUM.AIPetHome then
        --创建AI宠物,初始化摄像机
    else
        --创建主角,初始化摄像机
        self._mainPlayer = MapMgr.CreateEntity(EntityDefine.ENTITY_TYPE.PLAYER_MAIN,UserData.PlayerID,UserData.PlayerAtt,true);
        if self._mapClientType == CLIENT_TYPE_ENUM.Image then
            --镜像副本没有LOADING进度,直接进入下一阶段
            self:EnterNextStep();
        else
            CameraMgr.InitCamera(self._mainPlayer);
        end
    end
end

function MapState:OnEnterStepTick()
    --第六阶段,副本开始更新
    local CLIENT_TYPE_ENUM = MapInfo_pb.SpaceConfig;
    if self._mapClientType == CLIENT_TYPE_ENUM.Image then
        TouchMgr.SetEnableEvent(true);
    else
        UIMgr.UnShowUI(AllUI.UI_Loading);
    end
    GameEvent.Trigger(EVT.MAPEVENT,EVT.MAP_ENTER_FINISH);
end

return MapState;