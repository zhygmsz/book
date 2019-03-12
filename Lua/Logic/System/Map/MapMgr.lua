module("MapMgr", package.seeall)

local mTmpCharactorTable = {};

local function GetEntityManager()
	return GameStateMgr.GetState()._mapEntityManager;
end

local function GetAllEntities()
	local entityMgr = GetEntityManager();
	if entityMgr then return entityMgr._entities end
end

local function CreateServerEntity(entityType, objAtts, isNoneAtt)
	for _, objAtt in ipairs(objAtts) do
		local dynamicID = isNoneAtt and objAtt.lifeNonAtt.entityAtt.entityId or objAtt.lifeOwnAtt.entityAtt.entityId;
		CreateEntity(entityType, tonumber(dynamicID), objAtt);
	end
end

function CreateEntity(entityType, entityID, entityAtt)
	local entityMgr = GetEntityManager();
	if entityMgr then return entityMgr:CreateEntity(entityType, entityID, entityAtt); end
end

function GetEntity(entityType, entityID)
	local entityMgr = GetEntityManager();
	if entityMgr then return entityMgr:FindEntity(entityType, tonumber(entityID)) end;
end

function DestroyEntity(entityType, entityID)
	local entityMgr = GetEntityManager();
	if entityMgr then entityMgr:DestroyEntity(entityType, entityID); end
end

--查找指定服务器类型、指定服务器ID的实体
function GetServerEntity(serverEntityType, serverEntityID)
	return GetEntity(EntityDefine.STC(serverEntityType, serverEntityID));
end

--查找指定ID的实体(只能查找玩家和NPC)
function GetEntityByID(entityID)
	if not entityID then return end
	entityID = tonumber(entityID);
	local entityMgr = GetEntityManager();
	return entityMgr and entityMgr:FindEntityByID(entityID) or nil;
end

--查找指定类型的所有实体
function GetAllEntityByType(entityType)
	local entityMgr = GetEntityManager();
	if entityMgr then return entityMgr:FindAllEntityByType(entityType); end
end

--查找指定阵营关系的一个实体
function GetEntityByCamp(attacker, campRelation)
	local allEntities = GetAllEntities();
	if not allEntities then return end
	for entityType, entities in pairs(allEntities) do
		local isNPC = entityType == EntityDefine.ENTITY_TYPE.NPC;
		local isPlayer = entityType == EntityDefine.ENTITY_TYPE.PLAYER;
		local isMainPlayer = entityType == EntityDefine.ENTITY_TYPE.PLAYER_MAIN;
		if isNPC or isPlayer or isMainPlayer then		
			for entityID, entity in pairs(entities) do
				if entity:GetCampComponent():GetCampRelation(attacker) == campRelation then return entity; end
			end
		end
	end
end

--查找指定地编NPCID的实体
function GetNPCByUnitID(npcUnitID)
	local allEntities = GetAllEntities();
	if not allEntities then return end
	local npcs = allEntities[EntityDefine.ENTITY_TYPE.NPC];
	if npcs then
		for _, npc in pairs(npcs) do
			if npc:GetPropertyComponent():GetUnitID() == npcUnitID then return npc; end
		end
	end
end

--查找指定NPC表ID的实体
function GetNPCByTempID(tempID)
	local allEntities = GetAllEntities();
	if not allEntities then return end
	local npcs = allEntities[EntityDefine.ENTITY_TYPE.NPC];
	if npcs then
		for _, npc in pairs(npcs) do
			if npc:GetPropertyComponent():GetTempID() == tempID then return npc; end
		end
	end
end

--获取所有实体(NPC和Player),注意返回后的table必须立即使用,因为是一个共用的table
function GetAllCharactor(filterFunc, sortFunc)
	--清空残留
	table.clear(mTmpCharactorTable);
	--重新查找
	local allEntities = GetAllEntities();
	if allEntities then
		for entityType, entities in pairs(allEntities) do
			local isNPC = entityType == EntityDefine.ENTITY_TYPE.NPC;
			local isPlayer = entityType == EntityDefine.ENTITY_TYPE.PLAYER;
			local isMainPlayer = entityType == EntityDefine.ENTITY_TYPE.PLAYER_MAIN;
			if isNPC or isPlayer or isMainPlayer then
				for entityID, entity in pairs(entities) do
					if not filterFunc or filterFunc(entity) then
						mTmpCharactorTable[#mTmpCharactorTable + 1] = entity;
					end
				end
			end
		end
	end
	if sortFunc then table.sort(mTmpCharactorTable, sortFunc); end
	return mTmpCharactorTable;
end

--查找指定ID的玩家
function GetPlayer(entityID)
	local player = GetEntity(EntityDefine.ENTITY_TYPE.PLAYER, tonumber(entityID));
	return player or GetEntity(EntityDefine.ENTITY_TYPE.PLAYER_MAIN, tonumber(entityID));
end

--获取主角
function GetMainPlayer()
	return GameStateMgr.GetState()._mainPlayer;
end

function GetMapUnitID()
	return GameStateMgr.GetState()._mapUnitID;
end

function GetSceneID()
	return GameStateMgr.GetState()._mapSceneID;
end

function GetMapInfo()
	return GameStateMgr.GetState()._mapData;
end

function GetMapChildInfo(mapUnitID)
	local mapUnitID = mapUnitID or GetMapUnitID();
	local mapData = GetMapInfo();
	if mapData then
		for k,v in ipairs(mapData.spaceMaps) do
			if v.mapUnitID == mapUnitID then return v; end
		end
	end
end

function GetMapUnit(mapUnitID)
	if not mapUnitID then
		return GameStateMgr.GetState()._mapUnitData;
	else
		return MapData.GetMapUnit(mapUnitID);
	end
end

function GetMapUnitNPCGroup(mapUnitID, npcGroupID)
	local mapUnitData = GetMapUnit(mapUnitID);
	local mapNPCGroups = mapUnitData and mapUnitData.entities.groups or table.emptyTable;
	for _, npcGroup in ipairs(mapNPCGroups) do
		if npcGroup.id == npcGroupID then return npcGroup; end
	end
end

function GetMapUnitNPC(mapUnitID, npcUnitID)
	local mapUnitData = GetMapUnit(mapUnitID);
	local mapNpcs = mapUnitData and mapUnitData.entities.npcs or table.emptyTable;
	for _, npcUnit in ipairs(mapNpcs) do
		if npcUnit.id == npcUnitID then return npcUnit; end
	end
end

function GetMapUnitArea(mapUnitID, areaUnitID)
	local mapUnitData = GetMapUnit(mapUnitID);
	local mapAreas = mapUnitData and mapUnitData.entities.triggers or table.emptyTable;
	for _, areaUnit in ipairs(mapAreas) do
		if areaUnit.id == areaUnitID then return areaUnit; end
	end
end

function GetMapUnitNode(mapUnitID, nodeID)
	local mapUnitData = GetMapUnit(mapUnitID);
	local mapNodes = mapUnitData and mapUnitData.entities.transmitNodes or table.emptyTable;
	for _, node in ipairs(mapNodes) do
		if node.id == nodeID then return node; end
	end
end

function GetMapUnitWall(mapUnitID, wallUnitID)
	local mapUnitData = GetMapUnit(mapUnitID);
	local mapWalls = mapUnitData and mapUnitData.entities.walls or table.emptyTable;
	for _, wallUnit in ipairs(mapWalls) do
		if wallUnit.id == wallUnitID then return wallUnit; end
	end
end

--指定某个怪物出生点
function GetNPCPoint(mapUnitID, npcUnitID)
	local npcUnit = GetMapUnitNPC(mapUnitID, npcUnitID);
	return npcUnit and Vector3(npcUnit.position.x, npcUnit.position.y, npcUnit.position.z) or nil;
end

--指定某个怪物组出生点
function GetNPCGroupPoint(mapUnitID, npcGroupID)
	local npcGroup = GetMapUnitNPCGroup(mapUnitID, npcGroupID);
	local npcUnitID = npcGroup and npcGroup.npcs[1] or -1;
	return GetNPCPoint(mapUnitID, npcUnitID);
end

--指定区域
function GetAreaPoint(mapUnitID, areaID)
	local areaUnit = GetMapUnitArea(mapUnitID, areaID);
	return areaUnit and Vector3(areaUnit.position.x, areaUnit.position.y, areaUnit.position.z) or nil;
end

--指定点-TransmitNode
function GetNode(mapUnitID, nodeID)
	local nodeUnit = GetMapUnitNode(mapUnitID, nodeID);
	return nodeUnit or nil;
end

--是否在大地图上
function IsInBigWorld()
	local mapData = GetMapInfo();
	return mapData and mapData.spaceType == MapInfo_pb.SpaceConfig.BigWorld;
end

--进入副本
local function OnEnterMap(msg, msgErrorCode)
	GameEvent.Trigger(EVT.MAPEVENT, EVT.MAP_ENTER_MSG_RET);
	if msgErrorCode then
		TipsMgr.TipErrorByID(msgErrorCode);
	else
		GameStateMgr.EnterMap(msg.spaceID, msg.mapUnitID);
	end
end

--场景加载
local function OnEndLoadScene()
end

--时间同步
local function OnSyncTime(msg)
	TimeUtils.OnSyncTime(msg);
end

--进入场景
local function OnEnterScene()
	GameStateMgr.GetState():EnterNextStep();
	TimeUtils.EnableTimeSync(true);
end

--离开场景
local function OnLeaveScene()
	TimeUtils.EnableTimeSync(false);
end

--移动同步
local function OnSyncMove(msg)
	local entity = GetEntityByID(msg.targetID);
	if entity then
		local position = math.ConvertProtoV3(msg.target);
		local forward = math.ConvertProtoV3(msg.forward);
		if msg.moveType == Common_pb.MoveType_Normal then
			entity:GetMoveComponent():MoveWithTarget(position, forward, msg.isStop, msg.speed);
			if entity:IsPlayer() and not entity:IsSelf() then
				entity:GetStateComponent():SyncClientState(Common_pb.ESOE_UPDATE, EntityDefine.CLIENT_STATE_TYPE.RUNFAST, msg.isRun);
			end
		elseif msg.moveType == Common_pb.MoveType_Skill then
			entity:GetMoveComponent():MoveWithSkill(position, forward);
		end
	end
end

--移动速度百分比同步
local function OnSyncMoveSpeedPercent(msg)
	UserData.OnMoveSpeedPercentUpdate(msg.moveSpeed);
end

--主角传送
local function OnSyncTransfer(msg)
	GameLog.LogError("no handler to transfer main player");
end

--实体创建
local function OnSyncObject(msg)
	for _, objID in ipairs(msg.delObjs) do
		local entity = GetEntityByID(tonumber(objID));
		if entity and not entity:IsDead() then DestroyEntity(entity:GetType(), entity:GetID()); end
	end
	CreateServerEntity(EntityDefine.ENTITY_TYPE.PLAYER, msg.addPlayerObjs, false);
	CreateServerEntity(EntityDefine.ENTITY_TYPE.NPC, msg.addNpcObjs, false);
	CreateServerEntity(EntityDefine.ENTITY_TYPE.PET, msg.addPetObjs, false);
	CreateServerEntity(EntityDefine.ENTITY_TYPE.HELPER, msg.addHelperObjs, false);
	CreateServerEntity(EntityDefine.ENTITY_TYPE.AREA, msg.addAreaObjs, true);
	CreateServerEntity(EntityDefine.ENTITY_TYPE.WALL, msg.addWallObjs, true);
end

--实体状态
local function OnSyncObjectStatus(msg)
	local entity = GetServerEntity(msg.targetType, msg.targetID) or GetEntityByID(msg.entityId);
	if entity then
		if msg.type == NetCS_pb.SCSyncDeath then
			local attacker = GetServerEntity(msg.attackerType, msg.attackerID);
			entity:GetActionComponent():PlayDeadAction(msg.animationId, attacker);
		elseif msg.type == NetCS_pb.SCSyncRevive then
			entity:GetActionComponent():PlayReviveAction(msg.animationId);
		elseif msg.type == NetCS_pb.SCSyncObjectStatus then
			entity:GetStateComponent():SyncServerState(msg);
		end
	end
end

--实体血量
local function OnSyncProperty(msg)
	local target = GetServerEntity(msg.targetType, msg.targetID);
	local attacker = GetServerEntity(msg.attackerType, msg.attackerID);
	local buffEffectID = msg.buffEffectID;
	local propertyType = msg.propertyType;
	if target and target:IsValid() then
		if propertyType == NetCS_pb.SCProperty.PROPERTY_Hp then
			target:GetPropertyComponent():SetHP(msg.deltaValue);
			target:GetActionComponent():PlayHitAction(msg.skillID);
			GameEvent.Trigger(EVT.ENTITY, EVT.ENTITY_HP_UPDATE, attacker, target, msg.deltaValue, msg.crit, buffEffectID);
		end
	end
end

--技能释放
local function OnSyncAttack(msg)
	local attacker = GetServerEntity(msg.attackerType, msg.attackerID);
	if attacker and not attacker:IsSelf() then
		local target = GetServerEntity(msg.targetType, msg.targetID);
		local targetPosition = math.ConvertProtoV3(msg.targetPosition);
		attacker:GetSkillComponent():CastSkill(msg.skillIndex, msg.skillLevel, msg.skillUnitID, target or targetPosition);
	end
end

--释放结果
local function OnSyncAttackEnd(msg,errorCode)
	if errorCode then
		local attacker = GetServerEntity(msg.attackerType, msg.attackerID);
		if attacker and not attacker:IsSelf() then
			attacker:GetSkillComponent():CancelSkill(errorCode);
		end
	end
end

--添加BUFF
local function OnBuffAdd(msg)
	local entity = GetServerEntity(msg.targetType, msg.targetID);
	if entity then
		local attacker = GetServerEntity(msg.attackerType, msg.attackerID);
		entity:GetBuffComponent():AddBuff(msg.dynamicID, msg.staticID, attacker);
	end
end

--更新BUFF
local function OnBuffUpdate(msg)
	local entity = GetServerEntity(msg.targetType, msg.targetID);
	if entity then
		entity:GetBuffComponent():UpdateBuff(msg.dynamicID,tonumber(msg.startTime),tonumber(msg.lastTime));
	end
end

--移除BUFF
local function OnBuffRemove(msg)
	local entity = GetServerEntity(msg.targetType, msg.targetID);
	if entity then entity:GetBuffComponent():RemoveBuff(msg.dynamicID); end	
end

--移除所有BUFF
local function OnBuffRemoveAll(msg)
	local entity = GetServerEntity(msg.targetType, msg.targetID);
	if entity then entity:GetBuffComponent():RemoveAll(); end
end

--免疫
local function OnBuffImmune(msg)
	local entity = GetServerEntity(msg.targetType, msg.targetID);
	local attacker = GetServerEntity(msg.attackerType, msg.attackerID);
	if entity then GameEvent.Trigger(EVT.ENTITY, EVT.ENTITY_IMMUNE_BUFF, attacker, entity, msg.immuneType); end	
end

--未命中
local function OnBuffMiss(msg)
	local entity = GetServerEntity(msg.targetType, msg.targetID);
	local attacker = GetServerEntity(msg.attackerType, msg.attackerID);
	if entity then GameEvent.Trigger(EVT.ENTITY, EVT.ENTITY_MISS_BUFF, attacker, entity); end	
end

-- 更新实体信息
local function OnEntityAttUpdate(msg)
	if msg.type == NetCS_pb.SCEntityAttUpdate then
		local entity = GetEntityByID(msg.entityId);
		if entity then
			if entity:IsPlayer() then
				EntityAttFactory.UpdateEntityAtt(msg.regionMask, msg.localMask, entity, entity._entityAtt, msg.roleInfo);
			elseif entity:IsNPC() then
				EntityAttFactory.UpdateEntityAtt(msg.regionMask, msg.localMask, entity, entity._entityAtt, msg.npcInfo);
			elseif entity:IsPet() then
				EntityAttFactory.UpdateEntityAtt(msg.regionMask, msg.localMask, entity, entity._entityAtt, msg.petInfo);
			end
		end
	else
	end
end

--怪物归属刷新
local function OnOwnedNpcUpdate(msg)
	local mainPlayerAtt = UserData.PlayerAtt;
	local npcDynamicID = tonumber(msg.npcid);
	if msg.type == NetCS_pb.SCAddOwnedNpc then
		mainPlayerAtt.ownedNPCs[npcDynamicID] = true;
	elseif msg.type == NetCS_pb.SCDeleteOwnedNpc then
		mainPlayerAtt.ownedNPCs[npcDynamicID] = nil;
	elseif msg.type == NetCS_pb.SCClearOwnedNpc then
		table.clear(mainPlayerAtt.ownedNPCs);
	end
	GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_OWNED_NPC_UPDATE);
end

--经验获取
local function OnPlayerExpUpdate(msg)
	local expValue = msg.expvalue;
	GameEvent.Trigger(EVT.PLAYER, EVT.PLAYER_EXP_ADD, expValue);
end

--经验溢出
local function OnPlayerExpOverflow()
	GameEvent.Trigger(EVT.PLAYER, EVT.PLAYER_EXP_OVERFLOW);
end

--请求进入副本
function RequestEnterMap(mapID, mapUnitID, nodeID)
	local mapID = MapData.GetSpaceID(mapUnitID);
	--已经在副本内
	if mapUnitID == GetMapUnitID() then TipsMgr.TipByKey("map_enter_already"); return; end
	--副本进入逻辑判断 TODO
	local msg = NetCS_pb.CSLoadScene();
	msg.spaceID = mapID;
	msg.mapUnitID = mapUnitID or 0;
	msg.nodeID = nodeID or 0;
	GameNet.SendToGate(msg);
end

--请求进入单机副本
function RequestEnterSingleMap()
end

--通知服务器场景加载完成
function RequestEndLoadScene()
	if not GameConfig.SINGLE then
		local msg = NetCS_pb.CSEndLoadScene();
		GameNet.SendToGate(msg, true);
	else
		OnEnterScene();
	end
end

--通知服务器当前主角位置
function RequestSyncMove(entity, isStop, target)
	if entity:IsSelf() then
		local msg = NetCS_pb.CSSyncMove();
		msg.time = TimeUtils.SystemTimeStamp();
		msg.speed = entity:GetPropertyComponent():GetMoveSpeed();
		msg.isStop = isStop and NetCS_pb.STOP_SMOOTH or NetCS_pb.MOVE_SMOOTH;
		msg.isRun = entity:GetPropertyComponent():IsInRunSpeed();
		msg.targetType = entity:GetServerType();
		msg.targetID = entity:GetID();
		math.AssignProtoV3(msg.position, entity:GetPropertyComponent():GetPosition());
		if isStop and target then
			--停止移动时如果还在转身(一般会在碰一下摇杆时发生)
			math.AssignProtoV3(msg.forward, target);
		else
			--没有转身操作
			math.AssignProtoV3(msg.forward, entity:GetPropertyComponent():GetForward());
			math.AssignProtoV3(msg.target, target or Vector3.zero);
		end
		msg.moveType = Common_pb.MoveType_Normal;
		GameNet.SendToGate(msg);
		--移动打断技能
		RequestCancelSkill(entity, EntityDefine.SKILL_CANCEL_TYPE.MOVE);
		--移动打断表现
		RequestCancelAction(entity,EntityDefine.ACTION_CANCEL_TYPE.MOVE);
	end
end

--通知服务器主角技能位移
function RequestSyncSkillMove(entity)
	if entity:IsSelf() then
		local msg = NetCS_pb.CSSyncMove();
		msg.time = TimeUtils.SystemTimeStamp();
		msg.speed = entity:GetPropertyComponent():GetMoveSpeed();
		msg.targetType = entity:GetServerType();
		msg.targetID = entity:GetID();
		math.AssignProtoV3(msg.position, entity:GetPropertyComponent():GetPosition());
		math.AssignProtoV3(msg.forward, entity:GetPropertyComponent():GetForward());
		msg.moveType = Common_pb.MoveType_Skill;
		GameNet.SendToGate(msg);
	end
end

--通知服务器主角释放技能
function RequestCastSkill(entity, skillIndex, skillLevel, skillUnitID, skillTarget, aiData)
	if entity and entity:IsSelf() then
		--表现优先
		entity:GetSkillComponent():CastSkill(skillIndex, skillLevel, skillUnitID, skillTarget);
		--发送消息
		local msg = NetCS_pb.CSAttack();
		msg.skillIndex = skillIndex;
		msg.skillLevel = skillLevel;
		msg.skillUnitID = skillUnitID;
		msg.attackerType = entity:GetServerType();
		msg.attackerID = entity:GetID();
		math.AssignProtoV3(msg.attackerPosition, entity:GetPropertyComponent():GetPosition());
		math.AssignProtoV3(msg.attackerForward, entity:GetPropertyComponent():GetForward());
		if skillTarget and skillTarget.IsValid then
			msg.targetType = skillTarget:GetServerType();
			msg.targetID = skillTarget:GetID();
		elseif skillTarget then
			math.AssignProtoV3(msg.targetPosition, skillTarget);
		end
		msg.time = TimeUtils.SystemTimeStamp();
		GameNet.SendToGate(msg);
	end
end

--通知服务器取消技能释放
function RequestCancelSkill(entity, cancelType)
	if entity then
		entity:GetSkillComponent():CancelSkill(cancelType);
	end
end

--通知服务器取消表现播放
function RequestCancelAction(entity, cancelType)
	if entity then
		entity:GetActionComponent():CancelAnimAction(cancelType);
	end
end

--通知服务器客户端发生的事件
function RequestSendMapEvent(eventType)
	local msg = NetCS_pb.CSSceneEvent();
	msg.eventType = eventType;
	GameNet.SendToGate(msg);
end

function InitModule()
	require("Logic/System/Map/MapEvent");
	--场景事件
	local function OnLoadingFinish() RequestSendMapEvent(MapEvent.MAP_ENTER_FINISH_EVENT); end
	GameEvent.Reg(EVT.MAPEVENT, EVT.MAP_ENTER_FINISH, OnLoadingFinish);
	
	--副本切换流程
	GameNet.Reg(NetCS_pb.SCLoadSceneRe, OnEnterMap, OnEnterMap);
	GameNet.Reg(NetCS_pb.SCEndLoadSceneRe, OnEndLoadScene);
	GameNet.Reg(NetCS_pb.SCEnterScene, OnEnterScene);
	GameNet.Reg(NetCS_pb.SCSyncTimeRe, OnSyncTime);
	GameNet.Reg(NetCS_pb.SCLeaveScene, OnLeaveScene);
	
	--移动
	GameNet.Reg(NetCS_pb.SCSyncMove, OnSyncMove);
	GameNet.Reg(NetCS_pb.SCSyncMoveSpeed, OnSyncMoveSpeedPercent);
	--GameNet.Reg(NetCS_pb.SCSyncTransfer, OnSyncTransfer);
	--实体
	GameNet.Reg(NetCS_pb.SCSyncObject, OnSyncObject);
	GameNet.Reg(NetCS_pb.SCSyncObjectStatus, OnSyncObjectStatus);
	GameNet.Reg(NetCS_pb.SCSyncDeath, OnSyncObjectStatus);
	GameNet.Reg(NetCS_pb.SCSyncRevive, OnSyncObjectStatus);
	GameNet.Reg(NetCS_pb.SCProperty, OnSyncProperty);
	GameNet.Reg(NetCS_pb.SCEntityAttUpdate, OnEntityAttUpdate);
    GameNet.Reg(NetCS_pb.SCRoleLvExpUpdate, OnPlayerExpUpdate);
	GameNet.Reg(NetCS_pb.SCRoleLvExpTooMany, OnPlayerExpOverflow);
	
	--技能和BUFF相关
	GameNet.Reg(NetCS_pb.SCAttack, OnSyncAttack);
	GameNet.Reg(NetCS_pb.SCAttackEnd, OnSyncAttackEnd, OnSyncAttackEnd);
	GameNet.Reg(NetCS_pb.SCBuffAdd, OnBuffAdd);
	GameNet.Reg(NetCS_pb.SCBuffUpdate, OnBuffUpdate);
	GameNet.Reg(NetCS_pb.SCBuffRemove, OnBuffRemove);
	GameNet.Reg(NetCS_pb.SCBuffRemoveAll, OnBuffRemoveAll);
	GameNet.Reg(NetCS_pb.SCBuffImmune, OnBuffImmune);
	GameNet.Reg(NetCS_pb.SCBuffMiss, OnBuffMiss);	

	--怪物归属
	GameNet.Reg(NetCS_pb.SCAddOwnedNpc, OnOwnedNpcUpdate);
	GameNet.Reg(NetCS_pb.SCDeleteOwnedNpc, OnOwnedNpcUpdate);
	GameNet.Reg(NetCS_pb.SCClearOwnedNpc, OnOwnedNpcUpdate);
end

return MapMgr; 