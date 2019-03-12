AINodeSkillSelect = class("AINodeSkillSelect",AINodeBase);

function AINodeSkillSelect:ctor()
    BTNodeLeaf.ctor(self);
end

function AINodeSkillSelect:dtor()
    BTNodeLeaf.dtor(self);
end

function AINodeSkillSelect:OnStart(aiData)
    self._selectState = 0;
end

function AINodeSkillSelect:OnUpdate(deltaTime,aiData)
    if self._selectState == 0 then
        --在控制状态下不执行技能逻辑
        if UserData.IsInControl() then return BTDefine.NODE_STATUS.FAILURE; end
        --在变身状态下不执行技能逻辑
        if aiData.stateComponent:HasServerState(Common_pb.ESE_CT_SHAPED) then return BTDefine.NODE_STATUS.FAILURE; end
        --选择主动技能或者自动技能
        if not self:SelectManualSkill(aiData) and not self:SelectAutoSkill(aiData) then return BTDefine.NODE_STATUS.FAILURE; end
        --主动技能需要缓存等待释放
        if not aiData.autoFlag and aiData.stateComponent:HasClientState(EntityDefine.CLIENT_STATE_TYPE.LIMIT_SKILL) then
            --检查正在释放的技能是否处于后摇阶段
            self._selectState = 1;
            return BTDefine.NODE_STATUS.RUNNING;
        end
        --选择宠物技能或者玩家技能
        if not self:SelectPlayerSkill(aiData) and not self:SelectPetSkill(aiData) then return BTDefine.NODE_STATUS.FAILURE; end
        return BTDefine.NODE_STATUS.SUCCESS;
    elseif self._selectState == 1 then
        --检查正在释放的技能是否处于后摇阶段
        if aiData.stateComponent:HasClientState(EntityDefine.CLIENT_STATE_TYPE.LIMIT_SKILL) then return BTDefine.NODE_STATUS.RUNNING; end
        --选择宠物技能或者玩家技能
        if not self:SelectPlayerSkill(aiData) and not self:SelectPetSkill(aiData) then return BTDefine.NODE_STATUS.FAILURE; end
        return BTDefine.NODE_STATUS.SUCCESS;
    else
        --无效
        return BTDefine.NODE_STATUS.FAILURE;
    end
end

function AINodeSkillSelect:OnAbort(aiData)
    BTNodeLeaf.OnAbort(self,aiData);
    aiData.manualSkillIndex = nil;
    aiData.autoFightWaitTime = aiData.AUTO_FIGHT_ENTER_TIME;
    aiData.autoIndex = Common_pb.SKILL_SLOT_6;

    aiData.skillDynamicData = nil;
    aiData.skillData = nil;
    aiData.skillLevelData = nil;
    aiData.skillUnitData = nil;
    aiData.skillCombo = nil;
end

function AINodeSkillSelect:SelectManualSkill(aiData)
    aiData.autoFlag = false;
    if aiData.manualSkillIndex then
        --主动释放技能
        aiData.skillIndex = aiData.manualSkillIndex;
        aiData.manualSkillIndex = nil;
        return true;
    else
        aiData.skillIndex = nil;
        return false;
    end
end

function AINodeSkillSelect:SelectAutoSkill(aiData)
    --自动技能标记
    aiData.autoFlag = true;
    --自动战斗状态
    if not UserData.GetAutoFight() then return false; end
    --自动战斗冷却
    aiData.autoFightWaitTime = aiData.autoFightWaitTime - GameTime.deltaTime_L;
    if aiData.autoFightWaitTime > 0 then return false; end
    --周围没有敌方
    if not MapMgr.GetEntityByCamp(aiData.attacker,Common_pb.CRE_RED) then return false; end
    --自动技能数据
    local autoSkillData = UserData.GetAutoSkill(aiData.autoIndex);
    if not autoSkillData then return self:OnFail("entity_skill_auto_null",aiData); end
    --勾选当前技能
    if not UserData.GetAutoSkillActiveFlag(autoSkillData.skillIndex) then return self:OnFail("entity_skill_auto_deactive",aiData); end
    --自动释放技能
    aiData.skillIndex = autoSkillData.skillIndex;
    return true;
end

function AINodeSkillSelect:SelectPlayerSkill(aiData)
    --检查技能槽位是否合法
    local skillIndex = aiData.skillIndex;
    if not skillIndex then return false; end
    if skillIndex >= Common_pb.SKILL_SLOT_6 then return false; end
    --检查槽位是否解锁
    local isUnlocked = FunUnLockMgr.GetSkillSlotIsUnlock(skillIndex);
    if not isUnlocked then return self:OnFail("skill_slot_Locked",aiData); end
    --检查当前技能槽是否有装配技能
    local skillDynamicData = UserData.GetSkill(skillIndex);
    if not skillDynamicData then return self:OnFail("entity_skill_dynamic_data_is_null",aiData); end
    --检查技能表信息是否有效
    local skillData = SkillData.GetSkillInfo(skillDynamicData.skillID);
    if not skillData then return self:OnFail("entity_skill_static_data_is_null",aiData); end
    --检查技能等级表信息是否有效
    local skillLevelData = SkillData.GetSkillLevelInfo(skillDynamicData.skillID,skillDynamicData.skillLevel);
    if not skillLevelData then return self:OnFail("entity_skill_level_data_is_null",aiData); end
    --检查技能表现配置是否存在
    local skillUnitData = SkillData.GetSkillUnitData(skillLevelData.unit);
    if not skillUnitData then return self:OnFail("entity_skill_unit_data_is_null",aiData); end
    --记录当前所选技能信息
    aiData.skillDynamicData = skillDynamicData;
    aiData.skillData = skillData;
    aiData.skillLevelData = skillLevelData;
    aiData.skillUnitData = skillUnitData;
    aiData.skillCombo = nil;
    --检查当前技能是否可以在当前场景释放 TODO
    --当前技能槽是否支持连击,如果支持连击那么更改为连击技能
    local slotSkill = aiData.skillComponent:GetCastingSkillByIndex(skillIndex);
    if slotSkill and slotSkill:HasComboSkill() then aiData.skillCombo = slotSkill; return true; end
    --检查当前技能是否正在冷却
    if UserData.GetSkillCD(skillLevelData.unit) > 0 then return self:OnFail("entity_skill_cd",aiData); end
    --检查技能消耗是否足够 TODO
    --检查是否禁止释放技能
    local canCast,serverLimit = aiData.stateComponent:CanCastSkill(skillData);
    if not canCast then return self:OnFail("entity_skill_limit",aiData,serverLimit); end
    --打断可以取消的所有技能
    MapMgr.RequestCancelSkill(aiData.attacker,EntityDefine.SKILL_CANCEL_TYPE.CAST_SKILL);
    --打断可以取消的所有表现
    MapMgr.RequestCancelAction(aiData.attacker,EntityDefine.ACTION_CANCEL_TYPE.SKILL);
    --如果在坐骑上,需要下坐骑
    GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_REQ_RIDE_OFF);
    --检查技能并存
    local castingCount = aiData.skillComponent:GetCastingSkillCount();
    if not skillUnitData.castForce and castingCount > 0 then return self:OnFail("entity_skill_casting",aiData); end
    --检查技能联动
    return BTDefine.NODE_STATUS.SUCCESS;
end

function AINodeSkillSelect:SelectPetSkill(aiData)
    --检查技能槽位是否合法
    local skillIndex = aiData.skillIndex;
    if not skillIndex then return false; end
    if skillIndex ~= Common_pb.SKILL_SLOT_6 then return false; end
    --检查是否有出战宠物
    local skillID = PetMgr.GetCurrHandSkill();
    if skillID == 0 then self:OnFail("entity_skill_pet_null",aiData); end
    --检查宠物技能状态
    return false;
end