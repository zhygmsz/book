StateComponent = class("StateComponent",EntityComponent);

function StateComponent:ctor(...)
    EntityComponent.ctor(self,...);
    self._stateController = StateController.new(self);
    self._effectController = self._entity:IsSelf() and EffectController.new(self) or nil;
end

--初始化
function StateComponent:OnStart()
    self._stateController:ctor(self);
    if self._effectController then self._effectController:ctor(self); end
end

function StateComponent:OnEnable()
    if self._effectController then self._effectController:OnEnable(); end
end

function StateComponent:OnDisable()
    if self._effectController then self._effectController:OnDisable(); end
end

--更新动画
function StateComponent:OnUpdate(deltaTime)
    self._stateController:OnUpdate(deltaTime);
end

--加载结束
function StateComponent:OnModelLoad(modelObject)
    self._stateController:OnModelLoad(modelObject);
    if self._effectController then self._effectController:OnModelLoad(modelObject); end
end

--替换开始
function StateComponent:OnModelReplace()
    if self._effectController then self._effectController:OnModelReplace(); end
end

--播放动画
function StateComponent:PlayAnim(animName,autoExit,exitName,forcePlay)
    self._stateController:EnterState(animName,autoExit,exitName,forcePlay);
end

--移动速度
function StateComponent:UpdateMoveAnim()
    self._stateController:UpdateMoveAnim();
end

--同步服务器状态
function StateComponent:SyncServerState(stateData)
    local serverState = self._entity._entityAtt.stateData.server;
    if stateData.operType == Common_pb.ESOE_ADD then
        --添加状态
        if stateData.operType <= 31 then
            if math.ContainsBitMask(serverState.mask1,stateData.status.id) then
                GameLog.LogError("server state add repeat %s",stateData.status.id); return
            end
            serverState.mask1 = math.AddBitMask(serverState.mask1,stateData.status.id);
        else
            if math.ContainsBitMask(serverState.mask2,stateData.status.id - 32) then 
                GameLog.LogError("server state add repeat %s",stateData.status.id); return
            end
            serverState.mask2 = math.AddBitMask(serverState.mask2,stateData.status.id - 32);
        end
        -- 本地数据修改
        local stateParam = serverState.params:add();
        stateParam:ParseFrom(stateData.status);
        
        local stateType = stateData.status.id;
        if stateType == Common_pb.ESE_CT_FIXBODY then
            --定身
            self._entity:GetMoveComponent():StopMove(0);
        elseif stateType == Common_pb.ESE_CT_SKILL_NO then
            --沉默
        elseif stateType == Common_pb.ESE_CT_VERTIGO then
            --眩晕
            self._entity:GetMoveComponent():StopMove(0);
            MapMgr.RequestCancelSkill(self._entity,EntityDefine.SKILL_CANCEL_TYPE.DIZZY);
            MapMgr.RequestCancelAction(self._entity,EntityDefine.ACTION_CANCEL_TYPE.DIZZY);
            self._stateController:UpdateState(true);
        elseif stateType == Common_pb.ESE_CT_SHAPED then
            --变身
            self._entity:GetModelComponent():UpdateModel();
            --触发高度变化事件
            GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_HEIGHT,self._entity);
        elseif stateType == Common_pb.ESE_CT_BIND then
            --坐骑
            local rideData = self._entity._entityAtt.rideData;
            rideData.enable = true;
            rideData.staticData = RideData.GetRideData(stateData.status.values[1]);
            rideData.moveSpeed = rideData.staticData.moveSpeed;
            --停止加速跑
            self:SyncClientState(Common_pb.ESOE_UPDATE,EntityDefine.CLIENT_STATE_TYPE.RUNFAST,false);
            --修改移动速度
            self._entity:GetPropertyComponent():SetMoveSpeed(rideData.moveSpeed,true);
            --刷新模型显示和碰撞盒子
            self._entity:GetModelComponent():UpdateModel();
            --触发事件,刷新界面
            GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_RIDE_ON,self._entity);
            --触发高度变化事件
            GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_HEIGHT,self._entity);
        elseif stateType == Common_pb.ESE_CT_DEAD then
            --死亡
            self._entity._dead = true;
        end
    elseif stateData.operType == Common_pb.ESOE_DEL then
        --删除状态
        if stateData.operType <= 31 then
            if not math.ContainsBitMask(serverState.mask1,stateData.status.id) then 
                GameLog.LogError("server state remove repeat %s",stateData.status.id); return
            end
            serverState.mask1 = math.RemoveBitMask(serverState.mask1,stateData.status.id);
        else
            if not math.ContainsBitMask(serverState.mask2,stateData.status.id - 32) then 
                GameLog.LogError("server state remove repeat %s",stateData.status.id); return
            end
            serverState.mask2 = math.RemoveBitMask(serverState.mask2,stateData.status.id - 32);
        end
        for index,stateParam in ipairs(serverState.params) do
            if stateParam.id == stateData.status.id then
                serverState.params:remove(index); break;
            end
        end
        local stateType = stateData.status.id;
        if stateType == Common_pb.ESE_CT_DEAD then
            --死亡
            self._entity._dead = false;
        elseif stateType == Common_pb.ESE_CT_VERTIGO then
            --眩晕
            self._stateController:UpdateState(true);
        elseif stateType == Common_pb.ESE_CT_SHAPED then
            --变身
            self._entity:GetModelComponent():UpdateModel();
            --触发高度变化事件
            GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_HEIGHT,self._entity);
        elseif stateType == Common_pb.ESE_CT_BIND then
            --坐骑
            self._entity._entityAtt.rideData.enable = false;
            --修改移动速度
            self._entity:GetPropertyComponent():SetMoveSpeed(self._entity._entityAtt.playerData.moveSpeed);
            --刷新模型显示和碰撞盒子
            self._entity:GetModelComponent():UpdateModel();
            --触发事件,刷新界面
            GameEvent.Trigger(EVT.ENTITY,EVT.ENTITY_RIDE_OFF,self._entity);
            --触发高度变化事件
            GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE,EVT.ENTITY_ATT_HEIGHT,self._entity);
        end
    elseif stateData.operType == Common_pb.ESOE_UPDATE then
        --更新状态
        GameLog.LogError("invalid operation from entity state update");
    end
end

--同步客户端状态
function StateComponent:SyncClientState(operType,stateType,arg1,arg2)
    local clientState = self._entity._entityAtt.stateData.client;
    if operType == Common_pb.ESOE_ADD then
        --限制类状态
        local limits = clientState[stateType] or {};
        clientState[stateType] = limits;
        limits[arg1] = arg2 or true;
    elseif operType == Common_pb.ESOE_DEL then
        --限制类状态
        local limits = clientState[stateType] or {};
        clientState[stateType] = limits;
        limits[arg1] = nil;
    elseif operType == Common_pb.ESOE_UPDATE then
        --客户端状态
        local oldState = clientState[stateType] or false;
        clientState[stateType] = arg1;
        if oldState == arg1 then return end
        if stateType == EntityDefine.CLIENT_STATE_TYPE.RUNFAST then
            if self._entity:IsSelf() then
                if arg1 and not self:CanMoveQuick() then
                    --无法进入加速跑状态
                    clientState[stateType] = false;
                else
                    --自己加速跑状态发生变化
                    local moveStandardSpeed,runStandardSpeed = self._entity:GetPropertyComponent():GetStandardSpeed();
                    self._entity:GetPropertyComponent():SetMoveSpeed(arg1 and runStandardSpeed or moveStandardSpeed);
                    if self._effectController then self._effectController:OnRunStateChange(arg1); end
                end
            end
        end
    end
end

--是否包含某个客户端状态
function StateComponent:HasClientState(stateType)
    local limits = self._entity._entityAtt.stateData.client[stateType];
    if type(limits) == "table" then return not table.empty(limits); end
    return limits;
end

--是否包含某个服务器状态
function StateComponent:HasServerState(stateType,onlyServer)
    if not onlyServer and stateType == Common_pb.ESE_CT_INCOMBAT and self:HasClientState(EntityDefine.CLIENT_STATE_TYPE.COMBAT) then return true end
    local serverState = self._entity._entityAtt.stateData.server;
    if stateType <= 31 then return math.ContainsBitMask(serverState.mask1,stateType); end
    return math.ContainsBitMask(serverState.mask2,stateType);
end

--是否可以加速移动
function StateComponent:CanMoveQuick()
    --只有玩家可以加速移动
    if not self._entity:IsPlayer() then return false; end
    --变身状态不可以加速
    if self:HasServerState(Common_pb.ESE_CT_SHAPED) then return end
    --坐骑状态不可以加速
    if self:HasServerState(Common_pb.ESE_CT_BIND) then return end
    --TODO 地图限制
    --加速跑状态
    return self:HasClientState(EntityDefine.CLIENT_STATE_TYPE.RUNFAST);
end

--是否可以移动
function StateComponent:CanMove()
    --死亡->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_DEAD) then return false; end
    --定身->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_FIXBODY) then return false; end
    --眩晕->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_VERTIGO) then return false; end
    --禁止移动和旋转->技能添加
    if self:HasClientState(EntityDefine.CLIENT_STATE_TYPE.LIMIT_MOVE_ROTATE) then return false end
    --禁止移动->技能添加
    if self:HasClientState(EntityDefine.CLIENT_STATE_TYPE.LIMIT_MOVE) then return false end
    return true;
end

--是否可以转身
function StateComponent:CanRotate()
    --死亡->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_DEAD) then return false; end
    --眩晕->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_VERTIGO) then return false; end
    --禁止移动和旋转->技能添加
    if self:HasClientState(EntityDefine.CLIENT_STATE_TYPE.LIMIT_MOVE_ROTATE) then return false end
    return true;
end

--是否可以释放技能 第一个返回是或否,第二个返回是否为服务器状态限制
function StateComponent:CanCastSkill(skillData)
    --死亡->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_DEAD) then return false,true; end
    --沉默->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_SKILL_NO) then return false,true; end
    --眩晕->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_VERTIGO) then return false,true; end
    --定身->服务器控制(定身不能释放持续位移技能)
    if self:HasServerState(Common_pb.ESE_CT_FIXBODY) then
        if skillData and skillData.displaceType == SkillInfo_pb.SkillInfo.SDT_CONTINUE then
            return false,true;
        end
    end
    --禁止释放技能->技能添加
    if self:HasClientState(EntityDefine.CLIENT_STATE_TYPE.LIMIT_SKILL) then return false,false; end
    return true;
end

--是否可以打断某个技能
function StateComponent:CanCancelSkill(skillUnitID,cancelType,cancelMask)
    --服务器技能打断
    if cancelType == EntityDefine.SKILL_CANCEL_TYPE.S_SKILL then return true; end
    --服务器死亡打断
    if cancelType == EntityDefine.SKILL_CANCEL_TYPE.S_DEATH then return true; end
    --死亡打断
    if cancelType == EntityDefine.SKILL_CANCEL_TYPE.DEAD then return true; end
    --眩晕打断
    if cancelType == EntityDefine.SKILL_CANCEL_TYPE.DIZZY then return true; end
    --技能连击取消上一段
    if cancelType == EntityDefine.SKILL_CANCEL_TYPE.CAST_COMBO then return true; end
    --LIMIT_SKILL  强制取消当前技能
    if cancelType == EntityDefine.SKILL_CANCEL_TYPE.LIMIT_SKILL then return true; end
    --LIMIT_CANCEL 禁止取消当前技能
    local limits = self._entity._entityAtt.stateData.client[EntityDefine.CLIENT_STATE_TYPE.LIMIT_CANCEL] or table.emptyTable;
    for limitKey,limitData in pairs(limits) do
        if limitData == skillUnitID then return false; end
    end
    --可以被任何操作打断
    if math.ContainsBitMask(cancelMask,Skill_pb.Skill.CANCEL_BY_AUTO) then return true; end
    --可以被移动打断
    if math.ContainsBitMask(cancelMask,Skill_pb.Skill.CANCEL_BY_MOVE) and cancelType == EntityDefine.SKILL_CANCEL_TYPE.MOVE then return true; end
    --被新技能打断
    if math.ContainsBitMask(cancelMask,Skill_pb.Skill.CANCEL_BY_SKILL) and cancelType == EntityDefine.SKILL_CANCEL_TYPE.CAST_SKILL then return true; end
    --不能打断
    return false;
end

--是否可以进入受击状态
function StateComponent:CanEnterHit()
    --眩晕->服务器控制
    if self:HasServerState(Common_pb.ESE_CT_VERTIGO) then return false; end

    if self._entity:IsPlayer() or self._entity:IsPet() or self._entity:IsHelper() then
        --玩家、助战、宠物只有在待机或者受击时才可以播放受击表现
        local curAnimName = self._entity._entityAtt.stateData.client.animData.curAnimName;
        return self._stateController:IsHitAnim(curAnimName) or self._stateController:IsIdleAnim(curAnimName);
    else
        return true;
    end
end

return StateComponent;