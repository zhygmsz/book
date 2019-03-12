AIComponent = class("AIComponent",EntityComponent);

function AIComponent:ctor(...)
    EntityComponent.ctor(self,...);
end

function AIComponent:OnStart()
    self._aiController = self._aiController or AIMaker.MakePlayerAI(self);
    self._aiController:Reset();
end

function AIComponent:OnDestroy()
end

function AIComponent:OnUpdate(deltaTime)
    if not self._entity:IsDead() and not UserData.IsInControl() then
        self._aiController:Tick(deltaTime);
    end
end

--[[
释放指定技能槽位上的技能
skillIndex      int     技能槽位
--]]
function AIComponent:CastSkill(skillIndex)
    --立即释放主动技能
    self._aiController:Reset();
    self._aiController:Set("manualSkillIndex",skillIndex);
    self._aiController:Tick(0);
end

--[[
设置自动战斗状态
autoFight       bool        true表示开启
--]]
function AIComponent:AutoFight(autoFight)
    self._aiController:Reset();
    self._aiController:Set("autoIndex",Common_pb.SKILL_SLOT_6);
    self._aiController:Set("autoFightWaitTime",self._aiController:Get("SKILL_SWITCH_TIME"));
    self._aiController:Set("autoFightPosition",self._entity:GetPropertyComponent():GetPosition(true));
    self._aiController:Tick(0);
end

--[[
设置优先攻击目标
--]]
function AIComponent:SelectTarget(targetEntity)
end

--[[
摇杆拖拽移动
dx      float       x轴移动方向
dy      float       y轴移动方向
--]]
function AIComponent:MoveWithJoystick(dx,dy)
    self._aiController:Reset();
    self._aiController:Set("manualMoveDx",dx);
    self._aiController:Set("manualMoveDy",dy);
    self._aiController:Tick(0);
end

--[[
停止拖拽
--]]
function AIComponent:StopWithJoystick()
    self._aiController:Reset();
    self._aiController:Set("autoFightPosition",self._entity:GetPropertyComponent():GetPosition(true));
    self._entity:GetMoveComponent():StopMove(1);
    self._aiController:Tick(0);
end

--[[
朝目标点移动
destPos         v3          目标点坐标
--]]
function AIComponent:MoveWithDest(destPos)
    self._aiController:Reset();
    self._aiController:Set("manualMoveDest",destPos);
    self._aiController:Tick(0);
end

--[[
朝向目标点移动
taskMoveFlag    bool        是否为自动任务移动
destPos         v3          目标点坐标
destDes         string      目标点描述
callBack        function    移动结束回调
callObj
needMinDistance bool    是否需要移动到与目标点距离很小
--]]
function AIComponent:MoveWithCallBack(taskMoveFlag,destPos,destDes,callBack,callObj,needMinDistance)
    if not taskMoveFlag then GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_CUSTOM_MOVE) end
    --朝目标点移动
    self._aiController:Reset();
    self._aiController:Set("customMoveDest",destPos);
    self._aiController:Set("customMoveDes",destDes);
    self._aiController:Set("customMoveMinFlag",needMinDistance);
    self._aiController:Set("customMoveCallBack",callBack);
    self._aiController:Set("customMoveCallObj",callObj);
    self._aiController:Tick(0);
end

function AIComponent:ResetAI()
    self._aiController:Reset();
    self._entity:GetMoveComponent():StopMove(0);
end

return AIComponent;