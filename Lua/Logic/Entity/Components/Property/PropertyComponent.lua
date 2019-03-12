PropertyComponent = class("PropertyComponent",EntityComponent);

function PropertyComponent:ctor(...)
    EntityComponent.ctor(self,...);
    self._dynamicProperty = nil;
end

function PropertyComponent:GetStaticProperty()
    return self._entity._entityAtt.staticProperty;
end

function PropertyComponent:GetDynamicProperty()
    return self._entity._entityAtt.dynamicProperty;
end

function PropertyComponent:GetShapeData()
    for _,stateData in ipairs(self._entity._entityAtt.stateData.server.params) do
        if stateData.id == Common_pb.ESE_CT_SHAPED then
            return ShapeData.GetShapeData(stateData.values[1]);
        end
    end
end

function PropertyComponent:GetEntityAtt()
    return self._entity._entityAtt;
end

function PropertyComponent:GetLevel()
    return self._entity._entityAtt.level;
end

function PropertyComponent:GetExp()
    return self._entity._entityAtt.experience;
end

function PropertyComponent:GetHP()
    return self._entity._entityAtt.hp;
end

function PropertyComponent:GetHPMax()
    return self._entity._entityAtt.maxHp;
end

function PropertyComponent:SetHP(deltaValue)
    local MAXHP,MINHP = self:GetHPMax(),0;   
	local curHP = self._entity._entityAtt.hp + deltaValue;
    curHP = math.max(MINHP,math.min(curHP,MAXHP));
	self._entity._entityAtt.hp = curHP;
end

function PropertyComponent:GetMP()
    return self._entity._entityAtt.mp;
end

function PropertyComponent:GetMPMax()
    return self._entity._entityAtt.maxMp;
end

function PropertyComponent:SetMP(deltaValue)
    local MAXMP,MINMP = self:GetMPMax(),0;   
	local curMP = self._entity._entityAtt.mp + deltaValue;
    curMP = math.max(MINMP,math.min(curMP,MAXMP));
	self._entity._entityAtt.mp = curMP;
end

function PropertyComponent:GetAP()
    return self._entity._entityAtt.anger;
end

function PropertyComponent:GetAPMax()
    return self._entity._entityAtt.maxAnger;
end

function PropertyComponent:SetAP(deltaValue)
    local MAXAP,MINAP = self:GetAPMax(),0;   
	local curAP = self._entity._entityAtt.anger + deltaValue;
    curAP = math.max(MINAP,math.min(curAP,MAXAP));
	self._entity._entityAtt.anger = curAP;
end

--角色高度
function PropertyComponent:GetHeight()
    local entityAtt = self._entity._entityAtt;
    local rideData = entityAtt.rideData;
    local shapeData = self:GetShapeData();
    local npcData = shapeData and NPCData.GetNPCInfo(shapeData.npcID);
    if rideData and rideData.enable then
        --坐骑身高
        return entityAtt.bindHeight + entityAtt.rideData.staticData.bindHeight;
    elseif shapeData and npcData then
        --变身身高
        return npcData.height;
    else
        --默认身高
        return entityAtt.height;
    end
end

--角色半径
function PropertyComponent:GetWidth()
    return self._entity._entityAtt.width;
end

--移动速度
function PropertyComponent:GetMoveSpeed()
    local baseSpeed = self._entity._entityAtt.moveSpeed;
    if self._entity:IsSelf() then
        return AttrCalculator.CalculMoveSpeed(baseSpeed,self:GetStaticProperty(),self:GetDynamicProperty());
    else
        return baseSpeed;
    end
end

--基础移动速度
function PropertyComponent:IsInRunSpeed()
    return self._entity._entityAtt.moveSpeed > self:GetStandardSpeed();
end

--标准移速
function PropertyComponent:GetStandardSpeed()
    local entityAtt = self._entity._entityAtt;
    local sMoveSpeed = 1; local sRunSpeed = 1; local sRideSpeed = 1;
	if entityAtt.petData then
		--宠物默认形体
		sMoveSpeed = entityAtt.petData.moveSpeed;
	elseif entityAtt.npcData then
		--NPC标准速度
        sMoveSpeed = entityAtt.npcData.moveSpeed;
    elseif entityAtt.helpData then
        --助战标准速度
        sMoveSpeed = entityAtt.helpData.moveSpeed;
    elseif entityAtt.playerData then
        --玩家标准速度
        sMoveSpeed,sRunSpeed,sRideSpeed = entityAtt.playerData.moveSpeed,entityAtt.playerData.runSpeed,entityAtt.rideData.moveSpeed;
    end
    if not sMoveSpeed or sMoveSpeed <= 0 then sMoveSpeed = 1; end
    if not sRunSpeed or sRunSpeed <= 0 then sRunSpeed = 1; end
    if not sRideSpeed or sRideSpeed <= 0 then sRideSpeed = 1; end
    return sMoveSpeed,sRunSpeed,sRideSpeed;
end

--移动速度
function PropertyComponent:SetMoveSpeed(moveSpeed,dontUpdateAnim,forceUpdateAnim)
    local oldSpeed = self._entity._entityAtt.moveSpeed;
    if oldSpeed ~= moveSpeed or forceUpdateAnim then
        --修改基础速度
        self._entity._entityAtt.moveSpeed = moveSpeed;
        --是否刷新动作
        if dontUpdateAnim then return end
        --刷新移动动作
        self._entity:GetStateComponent():UpdateMoveAnim();
    end
end

--转身速度
function PropertyComponent:GetTurnSpeed()
    return self:GetMoveSpeed() * 150;
end

--位置
function PropertyComponent:GetPosition(needCopy)
    local curPos = self._entity._entityAtt.position;
    if needCopy then
        return Vector3(curPos.x,curPos.y,curPos.z);
    else
        local tmpPos = self._entity._entityAtt.tmpPosition;
        tmpPos:Set(curPos.x,curPos.y,curPos.z);
        return tmpPos;
    end
end

--位置
function PropertyComponent:SetPosition(position)
    local oldY = self._entity._entityAtt.position.y;
    local newY = GameUtil.GameFunc.FindNavMeshHeight(position.x, oldY, position.z);
    position.y = newY >= 9999 and oldY or newY;
    self._entity._entityAtt.position:Set(position.x,position.y,position.z);
    self._entity:GetModelComponent():SetPosition(position);
    
    if self._entity:IsSelf() then
        --玩家移动事件
        GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_POS_UPDATE,self:GetPosition());
    end
end

--朝向
function PropertyComponent:GetForward(needCopy)
    local curForward = self._entity._entityAtt.forward;
    if needCopy then
        return Vector3(curForward.x,curForward.y,curForward.z);
    else
        local tmpForward = self._entity._entityAtt.tmpForward;
        tmpForward:Set(curForward.x,curForward.y,curForward.z);
        return tmpForward;
    end
end

--朝向
function PropertyComponent:SetForward(forward)
    self._entity._entityAtt.forward = forward;
    self._entity:GetModelComponent():SetForward(forward);
end

--朝向
function PropertyComponent:LookTarget(targetEntity)
    if not targetEntity then return end
    local lookDirection = nil;
    if targetEntity.IsValid then
        lookDirection = targetEntity:GetPropertyComponent():GetPosition() - self:GetPosition();
    else
        lookDirection = targetEntity - self:GetPosition();
    end
    if lookDirection.x == 0 and lookDirection.z == 0 then return end
    lookDirection.y = 0;
    self:SetForward(lookDirection);
end

--NPC地编ID
function PropertyComponent:GetUnitID()
    return self._entity._entityAtt.unitID;
end

--称号
function PropertyComponent:GetTitle()
    return self._entity._entityAtt.titleInfo;
end

--称号
function PropertyComponent:SetTitle(tid,tname)
    local title = self._entity._entityAtt.titleInfo;
    title.titleid = tid or 0;
    title.titlestr = tname or "";
end

--受击表现组ID
function PropertyComponent:GetHitGroupID()
    if self._entity:IsPlayer() then
        return self._entity._entityAtt.playerData.hitGroupID;
    elseif self._entity:IsNPC() then
        return self._entity._entityAtt.npcData.hitGroupID;
    else
        return -1;
    end
end

--头像
function PropertyComponent:GetIcon()
    if self._entity:IsNPC() then
        return self._entity._entityAtt.npcData.npcIcon;
    elseif self._entity:IsPlayer() then
        local racial, profes = self:GetRacialProfess();
        local resTable = ProfessionData.GetProfessionResByRacialProfession(racial, profes);
        return resTable and resTable.headIcon;
    end
end

--种族，职业
function PropertyComponent:GetRacialProfess()
    if self._entity:IsPlayer() then
        return self._entity._entityAtt.playerData.racial,self._entity._entityAtt.playerData.profession;
    end
end
--npc技能列表
function PropertyComponent:GetSkillList()
    if self._entity:IsNPC() then
        return self._entity._entityAtt.npcData.skills;
    end
end

return PropertyComponent;