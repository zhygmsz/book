module("EntityAttFactory", package.seeall)

local mEntityAttPool = {}

local function ParseCommonFromRemote(localAtt, remoteAtt, needDetail)
	--本地属性标记
	localAtt.localFlag = true;
	--新创建对象标记
	localAtt.newFlag = true;
	--动态ID、名称
	localAtt.id = tonumber(remoteAtt.lifeOwnAtt.entityAtt.entityId);
	localAtt.name = remoteAtt.lifeOwnAtt.entityAtt.entityName;
	
	--位置、朝向、移速
	local position = remoteAtt.lifeOwnAtt.entityAtt.position;
	localAtt.position = Vector3.New(position.x, position.y, position.z);
	localAtt.position.y = GameUtil.GameFunc.FindNavMeshHeight(position.x, position.y, position.z);
	localAtt.tmpPosition = Vector3.zero;
	local forward = remoteAtt.lifeOwnAtt.entityAtt.forward;
	if forward.x == 0 and forward.y == 0 and forward.z == 0 then
		GameLog.LogError("entity forward zero error id:%s name:%s",localAtt.id,localAtt.name)
		forward = Vector3.forward;
	end
	localAtt.forward = Vector3.New(forward.x, forward.y, forward.z);
	localAtt.tmpForward = Vector3.zero;
	localAtt.moveSpeed = remoteAtt.lifeOwnAtt.moveSpeed;
	
	--阵营
	localAtt.factions = localAtt.factions or {};
	for index, faction in ipairs(remoteAtt.lifeOwnAtt.entityAtt.factions) do
		localAtt.factions[index] = faction;
	end
	
	--血
	localAtt.hp = remoteAtt.lifeOwnAtt.hp;
	localAtt.maxHp = remoteAtt.lifeOwnAtt.maxHp;
	
	--蓝
	localAtt.mp = remoteAtt.lifeOwnAtt.mp;
	localAtt.maxMp = remoteAtt.lifeOwnAtt.maxHp;
	
	--怒
	localAtt.anger = 0;
	localAtt.maxAnger = 0;
	
	--等级、经验
	localAtt.level = remoteAtt.lifeOwnAtt.level;
	localAtt.experience = remoteAtt.lifeOwnAtt.experience;
	
	--出生表现
	localAtt.bornAnimID = remoteAtt.lifeOwnAtt.bornAnimationId;
	
	--状态
	localAtt.stateData = localAtt.stateData or {};
	localAtt.stateData.server = localAtt.stateData.server or EntityAtt_pb.EntityState();
	local stateDataFromRemote = needDetail and remoteAtt.lifeOwnAtt.entityAtt.detailInfo or remoteAtt.lifeOwnAtt.entityAtt.snapInfo;
	localAtt.stateData.server:ParseFrom(stateDataFromRemote);
	localAtt.stateData.client = localAtt.stateData.client or {};
	localAtt.stateData.client.animData = localAtt.stateData.client.animData or {};
	table.clear(localAtt.stateData.client.animData);
	localAtt.stateData.client.animData.AUTO_EXIT_ATTACK_TIME = ConfigData.GetValue("fight_auto_exit_time");
	localAtt.stateData.client.animData.curAnimName = EntityDefine.ANIM_NAME.ANIM_IDLE;
	
	--BUFF
	localAtt.bornBuffs = localAtt.bornBuffs or {};
	for k, v in ipairs(localAtt.bornBuffs) do table.clear(v); end
	for k, v in ipairs(remoteAtt.lifeOwnAtt.buffs) do
		local bornBuff = localAtt.bornBuffs[k] or {};
		bornBuff.dynamicID = tonumber(v.id);
		bornBuff.buffID = v.tempId;
		bornBuff.startTime = tonumber(v.startTime);
		bornBuff.lastTime = tonumber(v.lastTime);
		localAtt.bornBuffs[k] = bornBuff;
	end
	
	--模型类型
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.EFFECT;
	localAtt.modelLayer = CameraLayer.EffectLayer;
end

local function ParseNoneFromRemote(localAtt, remoteAtt)
	--本地属性标记
	localAtt.localFlag = true;
	--新创建对象标记
	localAtt.newFlag = true;
	--动态ID、名称
	localAtt.id = tonumber(remoteAtt.lifeNonAtt.entityAtt.entityId);
	localAtt.name = remoteAtt.lifeNonAtt.entityAtt.entityName;
	if localAtt.name == "" then localAtt.name = tostring(localAtt.id) end
	
	--位置、朝向、移速
	local position = remoteAtt.lifeNonAtt.entityAtt.position;
	localAtt.position = Vector3.New(position.x, position.y, position.z);
	localAtt.position.y = GameUtil.GameFunc.FindNavMeshHeight(position.x, position.y, position.z);
	local forward = remoteAtt.lifeNonAtt.entityAtt.forward;
	localAtt.forward = Vector3.New(forward.x, forward.y, forward.z);
	
	--阵营
	localAtt.factions = localAtt.factions or {};
	for index, faction in ipairs(remoteAtt.lifeNonAtt.entityAtt.factions) do
		localAtt.factions[index] = faction;
	end
	
	--状态
	localAtt.stateData = localAtt.stateData or {};
	localAtt.stateData.server = localAtt.stateData.server or EntityAtt_pb.EntityState();
	localAtt.stateData.server:ParseFrom(remoteAtt.lifeNonAtt.entityAtt.snapInfo);
	
	--模型类型
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.EFFECT;
	localAtt.modelLayer = CameraLayer.EffectLayer;
end

local function ParseNPCFromRemote(localAtt, remoteAtt)
	ParseCommonFromRemote(localAtt, remoteAtt);
	--地编配置
	localAtt.unitID = remoteAtt.unitID;
	localAtt.unitData = MapMgr.GetMapUnitNPC(nil, localAtt.unitID);
	localAtt.npcData = NPCData.GetNPCInfo(localAtt.unitData.tempID);
	--体型
	localAtt.width = localAtt.npcData.width;
	localAtt.height = localAtt.npcData.height;
	localAtt.name = localAtt.npcData.npcName;
	--模型类型
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER;
	localAtt.modelLayer = CameraLayer.EntityLayer;
	localAtt.physiqueID = localAtt.npcData.physiqueID;
end

local function ParsePetFromRemote(localAtt, remoteAtt)
	ParseCommonFromRemote(localAtt, remoteAtt);
	--数据
	localAtt.petData = PetData.GetPetDataById(remoteAtt.tempId);
	--体型
	localAtt.width = localAtt.petData.width;
	localAtt.height = localAtt.petData.height;
	localAtt.name = remoteAtt.lifeOwnAtt.entityAtt.entityName;
	--主人
	localAtt.masterEntityId = remoteAtt.lifeOwnAtt.entityAtt.masterId
	localAtt.masterName = remoteAtt.lifeOwnAtt.entityAtt.masterName
	--模型类型
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER;
	localAtt.modelLayer = CameraLayer.EntityLayer;
	localAtt.physiqueID = localAtt.petData.modelID;
end

local function ParseAreaFromRemote(localAtt, remoteAtt)
	ParseNoneFromRemote(localAtt, remoteAtt);
	--数据
	localAtt.unitID = remoteAtt.unitID;
	localAtt.unitData = MapMgr.GetMapUnitArea(nil, localAtt.unitID);
	--模型资源
	localAtt.modelID = ResConfigData.GetResConfigID(localAtt.unitData.effectID);
end

local function ParseWallFromRemote(localAtt, remoteAtt)
	ParseNoneFromRemote(localAtt, remoteAtt);
	--数据
	localAtt.unitID = remoteAtt.unitID;
	localAtt.unitData = MapMgr.GetMapUnitWall(nil, localAtt.unitID);
	localAtt.size = math.ConvertProtoV3(localAtt.unitData.size);
	--模型资源
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.WALL;
	localAtt.modelID = ResConfigData.GetResConfigID(localAtt.unitData.effectID);
end

local function ParseBulletFromRemote(localAtt, remoteAtt)
	--释放者信息
	localAtt.caster = remoteAtt.skill._skillComponent._entity;
	localAtt.skillUnitID = remoteAtt.skill._skillUnitID;
	localAtt.particle = remoteAtt.particle;
	localAtt.pathData = remoteAtt.particle.path;
	localAtt.target = remoteAtt.skill._skillTarget;
	--位置朝向
	localAtt.position = Vector3.zero;
	localAtt.forward = Vector3.forward;
	localAtt.tmpPosition = Vector3.zero;
	localAtt.tmpForward = Vector3.zero;
	--模型资源
	localAtt.modelID = ResConfigData.GetResConfigID(localAtt.particle.effectID);
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.EFFECT;
	localAtt.modelLayer = CameraLayer.EffectLayer;
end

local function ParseAIPetFromRemote(localAtt, remoteAtt)
	--模型类型
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.AIPET;
	localAtt.modelLayer = CameraLayer.AIPetLayer;
end

local function ParseHelperFromRemote(localAtt, remoteAtt)
	ParseCommonFromRemote(localAtt, remoteAtt);
	--数据
	localAtt.helpData = FightHelpData.GetFihtHelperInfoById(remoteAtt.tempId);
	--体型
	localAtt.width = localAtt.helpData.width;
	localAtt.height = localAtt.helpData.height;
	localAtt.name = localAtt.helpData.name;
	--模型类型
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER;
	localAtt.modelLayer = CameraLayer.EntityLayer;
	localAtt.physiqueID = localAtt.helpData.physiqueId;
end

local function ParsePlayerCommonFromRemote(localAtt, remoteAtt, needDetail)
	ParseCommonFromRemote(localAtt, remoteAtt, needDetail);
	--种族、职业、职业数据、属性信息
	localAtt.racial = remoteAtt.racial;
	localAtt.profession = remoteAtt.profession;
	localAtt.playerData = ProfessionData.GetProfessionData(localAtt.racial, localAtt.profession);
	localAtt.bindHeight = localAtt.playerData.bindHeight;
	--动态和静态属性
	localAtt.staticProperty = PropertyData.GetPropertyAtt(localAtt.playerData.propertyID);
	localAtt.dynamicProperty = localAtt.dynamicProperty or {};
	for key, value in pairs(localAtt.dynamicProperty) do localAtt.dynamicProperty[key] = 0; end
	localAtt.physiqueID = remoteAtt.physiqueID;
	--基础称号
	localAtt.titleInfo = localAtt.titleInfo or Title_pb.TitleItem();
	localAtt.titleInfo:ParseFrom(remoteAtt.title);
	--体型
	localAtt.width = localAtt.playerData.width;
	localAtt.height = localAtt.playerData.height;
	--移动速度
	localAtt.dynamicProperty[PropertyInfo_pb.SP_MOVE_SPEED_PERCENT] = remoteAtt.lifeOwnAtt.moveSpeedPt;
	--外显信息
	localAtt.fashions = localAtt.fashions or {};
	for k, v in pairs(localAtt.fashions) do localAtt.fashions[k] = nil end
	for idx, fashionID in ipairs(remoteAtt.fashionIds) do
		localAtt.fashions[idx] = FashionData.GetFashionData(fashionID);
	end
	--坐骑信息(默认)
	localAtt.rideData = localAtt.rideData or {};
	localAtt.rideData.enable = math.ContainsBitMask(localAtt.stateData.server.mask1, Common_pb.ESE_CT_BIND);
	if localAtt.rideData.enable then
		for _, stateArg in ipairs(localAtt.stateData.server.params) do
			if stateArg.id == Common_pb.ESE_CT_BIND then
				localAtt.rideData.staticData = RideData.GetRideData(stateArg.values[1]);
				localAtt.rideData.moveSpeed = localAtt.rideData.staticData.moveSpeed;
				localAtt.moveSpeed = localAtt.rideData.moveSpeed;
				break;
			end
		end
	end
	localAtt.rideData.rideInfo = localAtt.rideData.rideInfo or Ride_pb.RideInitInfo();
	localAtt.rideData.rideInfo:ParseFrom(remoteAtt.ride);
	--模型类型
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER;
	localAtt.modelLayer = CameraLayer.PlayerLayer;
	localAtt.physiqueID = localAtt.playerData.physiqueID;
	--怪物归属
end

local function ParsePlayerFromRemote(localAtt, remoteAtt)
	ParsePlayerCommonFromRemote(localAtt, remoteAtt);
end

local function ParsePlayerMainFromRemote(localAtt, remoteAtt)
	ParsePlayerCommonFromRemote(localAtt, remoteAtt, true);
	--主角数据
	localAtt.mainPlayerFlag = true;
	--技能装配信息
	localAtt.skillSlots = localAtt.skillSlots or {};
	for i = Common_pb.SKILL_SLOT_0, Common_pb.SKILL_SLOT_5 do
		local localSlotData = localAtt.skillSlots[i] or {};
		localSlotData.skillSlot = i;
		localSlotData.skillID = - 1;
		for idx, remoteSlotData in ipairs(remoteAtt.skillSlots) do
			if remoteSlotData.skillSlot == i then
				localSlotData.skillID = remoteSlotData.skillID; break;
			end
		end
		localAtt.skillSlots[i] = localSlotData;
	end
	--技能解锁信息
	localAtt.skillOpens = localAtt.skillOpens or {};
	for i = 1, math.max(#localAtt.skillOpens, #remoteAtt.skills) do
		local localSkill = localAtt.skillOpens[i] or {};
		local remoteSkill = remoteAtt.skills[i];
		localSkill.skillID = remoteSkill and remoteSkill.skillID or - 1;
		localSkill.skillLevel = remoteSkill and remoteSkill.skillLevel or - 1;
		localAtt.skillOpens[i] = localSkill;
	end
	--技能冷却信息
	localAtt.skillCDs = localAtt.skillCDs or {};
	for k,v in pairs(localAtt.skillCDs) do GameTimer.DeleteTimer(v.skillCDTimerID); end
	for i = 1, #remoteAtt.skillCds do
		local remoteCDData = remoteAtt.skillCds[i];
		local skillCDTotalTime = TimeUtils.TimeStampLeft(tonumber(remoteCDData.startTime));
		local skillCDData = localAtt.skillCDs[remoteCDData.unitId] or {};
		localAtt.skillCDs[remoteCDData.unitId] = skillCDData;

		skillCDData.skillCDTotalTime = skillCDTotalTime;
		skillCDData.skillCDLeftTime = skillCDTotalTime;
		skillCDData.skillCDLastTime = TimeUtils.SystemTimeStamp();
		skillCDData.skillCDTimerID = GameTimer.AddTimer(0.02, skillCDTotalTime * 0.05, UserData.OnSkillCDUpdate, remoteCDData.unitId);
		skillCDData.skillCDFinish = false;
	end
	--自动技能列表
	localAtt.autoSkills = localAtt.autoSkills or {};
	for i = Common_pb.SKILL_SLOT_0, Common_pb.SKILL_SLOT_6 do
		local skillAutoData = localAtt.autoSkills[i] or {};
		skillAutoData.skillIndex = i;
		localAtt.autoSkills[i] = skillAutoData;
	end
	--主角AI数据
	localAtt.aiData = localAtt.aiData or {};
	localAtt.aiData.SKILL_SWITCH_TIME = ConfigData.GetValue("fight_skill_switch_time");
	localAtt.aiData.AUTO_FIGHT_ENTER_TIME = ConfigData.GetValue("fight_autofight_enter_time");
	localAtt.aiData.SEARCH_DISTANCE = ConfigData.GetIntValue("fight_target_search_distance");
	localAtt.aiData.LOSS_DISTANCE = ConfigData.GetIntValue("fight_target_loss_distance");
	localAtt.aiData.AUTOFIGHT_DISTANCE = ConfigData.GetIntValue("fight_autofight_range");
	--主角怪物归属
	localAtt.ownedNPCs = localAtt.ownedNPCs or {};
	--次日首次登陆标记
	localAtt.roleflag = remoteAtt.roleflag;
	--玩家模型处理
	localAtt.modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER_MAIN;
end

local function NeedConvertAtt(entityType, entityAtt)
	if entityType == EntityDefine.ENTITY_TYPE.PLAYER_MAIN then return true; end
	if entityType == EntityDefine.ENTITY_TYPE.PLAYER then return true; end
	if entityType == EntityDefine.ENTITY_TYPE.NPC then return true; end
	if entityType == EntityDefine.ENTITY_TYPE.PET then return true; end
	if entityType == EntityDefine.ENTITY_TYPE.AREA then return true; end
	if entityType == EntityDefine.ENTITY_TYPE.WALL then return true; end
	if entityType == EntityDefine.ENTITY_TYPE.BULLET then return true; end
	if entityType == EntityDefine.ENTITY_TYPE.AIPET then return true; end
	if entityType == EntityDefine.ENTITY_TYPE.HELPER then return true; end
end

function AllocEntityAtt(entityType, entityAtt)
	if NeedConvertAtt(entityType) and not entityAtt.localFlag then
		local entityAttCaches = mEntityAttPool[entityType];
		if not entityAttCaches then
			entityAttCaches = {};
			mEntityAttPool[entityType] = entityAttCaches;
		end
		local entityAttCache = entityAttCaches[#entityAttCaches];
		if entityAttCache then
			entityAttCaches[#entityAttCaches] = nil;
		else
			entityAttCache = {};
		end
		if entityType == EntityDefine.ENTITY_TYPE.PLAYER_MAIN then
			ParsePlayerMainFromRemote(entityAttCache, entityAtt);
		elseif entityType == EntityDefine.ENTITY_TYPE.PLAYER then
			ParsePlayerFromRemote(entityAttCache, entityAtt);
		elseif entityType == EntityDefine.ENTITY_TYPE.NPC then
			ParseNPCFromRemote(entityAttCache, entityAtt);
		elseif entityType == EntityDefine.ENTITY_TYPE.PET then
			ParsePetFromRemote(entityAttCache, entityAtt);
		elseif entityType == EntityDefine.ENTITY_TYPE.AREA then
			ParseAreaFromRemote(entityAttCache, entityAtt);
		elseif entityType == EntityDefine.ENTITY_TYPE.WALL then
			ParseWallFromRemote(entityAttCache, entityAtt);
		elseif entityType == EntityDefine.ENTITY_TYPE.BULLET then
			ParseBulletFromRemote(entityAttCache, entityAtt);
		elseif entityType == EntityDefine.ENTITY_TYPE.AIPET then
			ParseAIPetFromRemote(entityAttCache, entityAtt);
		elseif entityType == EntityDefine.ENTITY_TYPE.HELPER then
			ParseHelperFromRemote(entityAttCache, entityAtt);
		end
		return entityAttCache;
	else
		return entityAtt;
	end
end

function FreeEntityAtt(entityType, entityAtt)
	--玩家数据是全局共享数据,不需要释放
	if entityAtt.mainPlayerFlag then return end
	--渲染模型数据不需要释放
	if entityType == EntityDefine.ENTITY_TYPE.RENDER then return end
	if entityAtt.localFlag then
		local entityAttCaches = mEntityAttPool[entityType];
		entityAttCaches[#entityAttCaches + 1] = entityAtt;
	end
end

function UpdatePlayerAtt(localAtt, remoteAtt)
	--位置、朝向
	local position = remoteAtt.lifeOwnAtt.entityAtt.position;
	localAtt.position = Vector3.New(position.x, position.y, position.z);
	localAtt.position.y = GameUtil.GameFunc.FindNavMeshHeight(position.x, position.y, position.z);
	localAtt.tmpPosition = Vector3.zero;
	local forward = remoteAtt.lifeOwnAtt.entityAtt.forward;
	localAtt.forward = Vector3.New(forward.x, forward.y, forward.z);
	localAtt.tmpForward = Vector3.zero;
	--BUFF
	localAtt.bornBuffs = localAtt.bornBuffs or {};
	for k, v in ipairs(localAtt.bornBuffs) do table.clear(v); end
	for k, v in ipairs(remoteAtt.lifeOwnAtt.buffs) do
		local bornBuff = localAtt.bornBuffs[k] or {};
		bornBuff.dynamicID = tonumber(v.id);
		bornBuff.buffID = v.tempId;
		bornBuff.startTime = tonumber(v.startTime);
		bornBuff.lastTime = tonumber(v.lastTime);
		localAtt.bornBuffs[k] = bornBuff;
	end
end

local function UpdateEntityLocalMask(localMask, entity, localAtt, remoteAtt)
	if localMask ~= 0 then
		local function UpdateEntityMaxMP(_entity, _localAtt, _remoteAtt)
			--血量
			_localAtt.maxMp = _remoteAtt.lifeOwnAtt.maxMp;
			GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_MAXMP);
		end
		local function UpdateEntityExp(_entity, _localAtt, _remoteAtt)
			--经验
			_localAtt.experience = _remoteAtt.lifeOwnAtt.experience;
			GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_EXP);
		end
		local function UpdateEntitySpeed(_entity, _localAtt, _remoteAtt)
			--速度
			--LifeOwnAtt.moveSpeed LifeOwnAtt.runSpeed LifeOwnAtt.moveSpeedPt
		end
		local function UpdateEntityRide(_entity, _localAtt, _remoteAtt)
			--坐骑
			_localAtt.rideData.rideInfo:ParseFrom(_remoteAtt.ride);
		end
		--定义每个掩码的处理函数
		if not mEntityAttPool.localMaskFunc then
			local localMaskFunc = {};
			localMaskFunc[EntityAtt_pb.ENLM_LO_MAXMP] = UpdateEntityMaxMP;
			localMaskFunc[EntityAtt_pb.ENLM_LO_EXP] = UpdateEntityExp;
			localMaskFunc[EntityAtt_pb.ENLM_LO_SPEED] = UpdateEntitySpeed;
			localMaskFunc[EntityAtt_pb.ENLM_LO_RIDE] = UpdateEntityRide;
			mEntityAttPool.localMaskFunc = localMaskFunc;
		end
		--遍历每一个定义好的掩码,检查是否包含有效数据
		for maskID, maskFunc in pairs(mEntityAttPool.localMaskFunc) do
			local maskValue = bit.lshift(1, maskID);
			if bit.band(maskValue, localMask) > 0 then
				if maskFunc then maskFunc(entity, localAtt, remoteAtt) end
			end
		end
	end
end

local function UpdateEntityRegionMask(regionMask, entity, localAtt, remoteAtt)
	if regionMask ~= 0 then
		local function UpdateEntityName(_entity, _localAtt, _remoteAtt)
			--名字
			_localAtt.name = _remoteAtt.lifeOwnAtt.entityAtt.entityName;
			GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_NAME, _entity);
		end
		local function UpdateEntityMaxHP(_entity, _localAtt, _remoteAtt)
			--最大血量
			_localAtt.maxHp = _remoteAtt.lifeOwnAtt.maxHp;
			GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_MAXHP, _entity);
		end
		local function UpdateEntityLevel(_entity, _localAtt, _remoteAtt)
			--等级
			local newLevel = _remoteAtt.lifeOwnAtt.level;
			if newLevel ~= _localAtt.level then
				local upLevelCount = newLevel - _localAtt.level;
				--_entity:GetActionComponent():PlayAction(ConfigData.GetValue("Cha_Lvup_show"));
				_entity:GetActionComponent():PlayRepeatAction(ConfigData.GetValue("Cha_Lvup_show"), upLevelCount, 300);
				_localAtt.level = newLevel;	
				GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_LEVEL, _entity);
			end
		end
		local function UpdateEntityTitle(_entity, _localAtt, _remoteAtt)
			--称号      PlayerAtt.title
		end
		local function UpdateEntityGuildID(_entity, _localAtt, _remoteAtt)
			--帮派ID    PlayerAtt.guildId
		end
		local function UpdateEntityPetName(_entity, _localAtt, _remoteAtt)
			--宠物名称
			_localAtt.name = _remoteAtt.lifeOwnAtt.entityAtt.entityName;
			GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_PET_NAME, _entity);
		end
		local function UpdateEntityPetMaster(_entity, _localAtt, _remoteAtt)
			--宠物主人
			_localAtt.masterName = remoteAtt.lifeOwnAtt.entityAtt.masterName;
			GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_PET_MASTER, _entity);
		end
		local function UpdateEntityFashion(_entity, _localAtt, _remoteAtt)
			--时装刷新
			for idx, _ in ipairs(_localAtt.fashions) do
				_localAtt.fashions[idx] = nil;
			end
			for idx, fashionID in ipairs(_remoteAtt.fashionIds) do
				_localAtt.fashions[idx] = FashionData.GetFashionData(fashionID);
			end
			_entity:GetModelComponent():UpdateModel();
		end
		local function UpdateEntityCamp(_entity, _localAtt, _remoteAtt)
			--阵营刷新
			local selfCamps = _localAtt.factions;
			for idx, campValue in ipairs(_remoteAtt.lifeOwnAtt.entityAtt.factions) do
				selfCamps[idx] = campValue;
			end
			GameEvent.Trigger(EVT.ENTITY_ATT_UPDATE, EVT.ENTITY_ATT_CAMP, _entity);
		end
		--定义每个掩码的处理函数
		if not mEntityAttPool.regionMaskFunc then
			local regionMaskFunc = {};
			regionMaskFunc[EntityAtt_pb.ENRM_ET_NAME] = UpdateEntityName;
			regionMaskFunc[EntityAtt_pb.ENRM_LO_MAXHP] = UpdateEntityMaxHP;
			regionMaskFunc[EntityAtt_pb.ENRM_LO_LEVEL] = UpdateEntityLevel;
			regionMaskFunc[EntityAtt_pb.ENRM_ROLE_TITLE] = UpdateEntityTitle;
			regionMaskFunc[EntityAtt_pb.ENRM_ROLE_GUILDID] = UpdateEntityGuildID;
			regionMaskFunc[EntityAtt_pb.ENRM_PET_NAME] = UpdateEntityPetName;
			regionMaskFunc[EntityAtt_pb.ENRM_ET_MASTER] = UpdateEntityPetMaster;
			regionMaskFunc[EntityAtt_pb.ENRM_ROLE_FASHION] = UpdateEntityFashion;	
			regionMaskFunc[EntityAtt_pb.ENRM_OBJ_CAMP] = UpdateEntityCamp;	
			mEntityAttPool.regionMaskFunc = regionMaskFunc;
		end
		--遍历每一个定义好的掩码,检查是否包含有效数据
		for maskID, maskFunc in pairs(mEntityAttPool.regionMaskFunc) do
			local maskValue = bit.lshift(1, maskID);
			if bit.band(maskValue, regionMask) > 0 then
				if maskFunc then maskFunc(entity, localAtt, remoteAtt) end
			end
		end
	end
end

function UpdateEntityAtt(regionMask, localMask, entity, localAtt, remoteAtt)
	UpdateEntityLocalMask(localMask, entity, localAtt, remoteAtt);
	UpdateEntityRegionMask(regionMask, entity, localAtt, remoteAtt);
end 