module("PetMgr", package.seeall)

local mPetInfoList = {}

--宠物加点
local mPoints = 
{
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
}

local mCurrShowPetSlotId = 1

local mComposeSlot = 0

local mTodayAffination = 0

local mIsAffinationSucceed = false

local mIsChangeTarget = false

local mIsUpdateInfo = false

local function InitData()
    
end

function InitModule()
    InitData()
end

function InitModuleOnLogin(count)
    mTodayAffination = count

    RequestCSPetsInfo(true, 0)
end

function GetPetInfoBySlotId(slotId)
    if next(mPetInfoList) == nil then
       return nil 
    end

    for _, v in ipairs(mPetInfoList) do
        if v.slotId == slotId then
            return v
        end
    end

    return nil
end

function SetCurrShowPetSlotId(slotId)
    mCurrShowPetSlotId = slotId
end

function GetCurrShowPetSlotId()
    return mCurrShowPetSlotId
end

--请求宠物数据
function RequestCSPetsInfo(isAll, slotId)
    local msg = NetCS_pb.CSPetsInfo()
    msg.isAll = isAll
    msg.slotId = slotId
    GameNet.SendToGate(msg)
end
--宠物数据返回 放生返回
function OnSCGetPetInfo(data)
    if data == nil then
        GameLog.LogError("Get pets info failed !")
        return 
    end

    mPetInfoList = {}

    for _, v in ipairs(data.infos) do
        local vo = {}
        vo.slotId = v.slotId
        vo.tempId = v.tempId
        vo.name = v.name
        vo.level = v.level
        vo.exp = v.exp
        vo.physicApt = v.physicApt --外功资质
        vo.magicApt = v.magicApt   --内共资质
        vo.hpApt = v.hpApt         --气血资质
        vo.physicDefApt = v.physicDefApt --外防资质
        vo.magicDefApt = v.magicDefApt --内防资质
        vo.growth = v.growth  -- 成长值
        vo.pointUnalloc = v.pointUnalloc --未分配的点数
        vo.strength = v.strength --一级属性力量
        vo.physical = v.physical --一级属性体质
        vo.stamina = v.stamina --一级属性耐力
        vo.intellect = v.intellect --一级属性智力
        vo.reAllocCount = v.reAllocCount --重新分配点数的次数
        vo.Current = v.Current --是否是当前出战的宠物
        vo.power = v.power --战力
        vo.attrs = v.attrs --二级属性
        vo.OwnSkills = v.OwnSkills
        vo.curHP = v.curHP
        vo.curMP = v.curMP
        vo.addPoints = v.addPoints
        vo.isPrecious = v.isPrecious --1 珍品 2 不是珍品
        vo.affinationCount = v.affinationCount --玩家洗练次数
        table.insert(mPetInfoList, vo)
    end
    SetIsUpdateInfo(true)
    --派发宠物信息初始化完成事件
    GameEvent.Trigger(EVT.PET, EVT.INFO_FINISHED, true)

end

--请求更改加点方案
function RequestCSPetSetPointRule(list)
    local slotId = mCurrShowPetSlotId

    local msg = NetCS_pb.CSPetSetPointRule()
    msg.slotId = slotId
    for _, v in ipairs(list) do
        msg.values:append(v)
    end

    GameNet.SendToGate(msg)
end

--加点方案修改
function OnRuleChanged(data)
    if data.ret == 0 then
        local tips = string.format( WordData.GetWordStringByKey("Pet_rejiadian"), data.values[1], data.values[2], data.values[3], data.values[4] )
        TipsMgr.TipByFormat(tips)

        for _, v in ipairs(mPetInfoList) do
            if data.slotId == v.slotId then
                for i, value in ipairs(data.values) do
                    v.addPoints[i] = value
                end
            end
        end
    end
end

--请求加点
function RequestCSPetAddPoint()
    local canSend = false
    for i, v in ipairs(mPoints) do
        if v > 0 then
            canSend = true
        end
    end

    if not canSend then
        return
    end

    local slotId = mCurrShowPetSlotId

    local  msg = NetCS_pb.CSPetAddPoint()
    msg.slotId = slotId
    for _, v in ipairs(mPoints) do
        msg.values:append(v)
    end

    GameNet.SendToGate(msg)
end

--请求重置属性点
function RequestCSPetResetPoint()
    local info = GetPetInfoBySlotId(mCurrShowPetSlotId)
    local count = UserData.GetLevel() * ConfigData.GetIntValue("Pet_perLv_freequa")
    if info.pointUnalloc >= count then
        TipsMgr.TipByKey("Pet_ban_reatrr")
        return
    end
    local slotId = mCurrShowPetSlotId

    local msg = NetCS_pb.CSPetResetPoint()
    msg.slotId = slotId
    GameNet.SendToGate(msg)
end

--请求改名
function RequestCSPetRename(name, slotId)
    local msg = NetCS_pb.CSPetRename()
    msg.slotId = slotId
    msg.name = name

    GameNet.SendToGate(msg)
end

--改名返回
function OnPetReName(data)
    if data.ret ~= 0 then
        GameLog.LogError("Operate failed error code is : "..data.ret)
        return 
    end

    for _, info in ipairs(mPetInfoList) do
        if data.slotId == info.slotId then
            info.name = data.name
            break
        end
    end
    GameEvent.Trigger(EVT.PET, EVT.PET_RENAME, data.name) 
end

--出战 休息 请求
function RequestCSOptPet(opt)
    local slotId = mCurrShowPetSlotId

    local msg = NetCS_pb.CSOptPet()
    msg.slotId = slotId
    msg.opt = opt

    local level = UserData.GetLevel()
    local info = GetPetInfoBySlotId(slotId)
    local petData = PetData.GetPetDataById(info.tempId)

    if opt == NetCS_pb.CSOptPet.CALL_PET and level < petData.needRoleLevel then
        TipsMgr.TipByKey("Pet_banlv_join")
        return 
    end

    GameNet.SendToGate(msg)
end

--操作返回
function OnSCOptPet(data)
    if data.ret ~= 0 then
        GameLog.LogError("Operate failed error code is : "..data.ret)
        return 
    end

    local isSetFight = data.opt == NetCS_pb.CSOptPet.CALL_PET
    for _, info in ipairs(mPetInfoList) do
        if data.slotId == info.slotId then
            if data.opt == NetCS_pb.CSOptPet.CALL_PET then
                info.Current = 1
            else
                info.Current = 0
            end
        else
            if isSetFight then
                info.Current = 0
            end
        end
    end

    GameEvent.Trigger(EVT.PET, EVT.FIGHTSTATE_CHANGED)
end

function RequestCSChangeSkill(optType, slotId, skillInfo)
    local msg = NetCS_pb.CSChangeSkill()
    msg.opt = optType
    msg.slotId = slotId

    local skill = PetData_pb.PetOwnSkill()
    
    skill.tempSkillId = skillInfo.tempSkillId
    skill.skillSlot = skillInfo.skillSlot
    skill.skillStatus = skillInfo.skillStatus

    msg.skill:ParseFrom(skill)

    GameNet.SendToGate(msg)
end

function OnSCChangeSkill(data)
    for _, v in ipairs(mPetInfoList) do
        if data.slotId == v.slotId then
            v.OwnSkills = data.skills
            break
        end
    end

    GameEvent.Trigger(EVT.PET,EVT.PET_HANDSKILLCHANGE, data)
end

--宠物放生
function RequestCSReleasePet(slotId)
    local msg = NetCS_pb.CSReleasePet()
    msg.slotId = slotId
    GameNet.SendToGate(msg)
end

--宠物洗练，返回为SCPetAffinationRet
function RequestCSPetAffination(slotId)
    local msg = NetCS_pb.CSPetAffination()
    msg.slotId = slotId
    GameNet.SendToGate(msg)
end

function OnSCPetAffinationRet(data)
    if data.ret == 0 then
        for _, info in ipairs(mPetInfoList) do
            if data.petInfo.slotId == info.slotId then
                info.slotId = data.petInfo.slotId
                info.tempId = data.petInfo.tempId
                info.name = data.petInfo.name
                info.level = data.petInfo.level
                info.exp = data.petInfo.exp
                info.physicApt = data.petInfo.physicApt --外功资质
                info.magicApt = data.petInfo.magicApt   --内共资质
                info.hpApt = data.petInfo.hpApt         --气血资质
                info.physicDefApt = data.petInfo.physicDefApt --外防资质
                info.magicDefApt = data.petInfo.magicDefApt --内防资质
                info.growth = data.petInfo.growth  -- 成长值
                info.pointUnalloc = data.petInfo.pointUnalloc --未分配的点数
                info.strength = data.petInfo.strength --一级属性力量
                info.physical = data.petInfo.physical --一级属性体质
                info.stamina = data.petInfo.stamina --一级属性耐力
                info.intellect = data.petInfo.intellect --一级属性智力
                info.reAllocCount = data.petInfo.reAllocCount --重新分配点数的次数
                info.Current = data.petInfo.Current --是否是当前出战的宠物
                info.power = data.petInfo.power --战力
                info.attrs = data.petInfo.attrs --二级属性
                info.OwnSkills = data.petInfo.OwnSkills
                info.curHP = data.petInfo.curHP
                info.curMP = data.petInfo.curMP
                info.addPoints = data.petInfo.addPoints
                info.isPrecious = data.petInfo.isPrecious --1 珍品 2 不是珍品
                info.affinationCount = data.petInfo.affinationCount -- 玩家洗练次数
                break
            end 
            
            local petData = PetData.GetPetDataById(info.tempId)
            local aData = PetData.GetPetAffinationData(petData.affinationID)

            local petData1 = PetData.GetPetDataById(data.petInfo.tempId)
            local aData1 = PetData.GetPetAffinationData(petData1.affinationID)

            if aData and aData1 then
                if aData.baseType == aData1.baseType then
                    info.affinationCount = data.petInfo.affinationCount -- 玩家洗练次数
                end
            end

        end
        mTodayAffination = mTodayAffination + 1
        GameEvent.Trigger(EVT.PET, EVT.PET_ONUPDATEONEINFO, false)
        SetIsAffinationSucceed(true)

        ShowTipsOnGetNewPet(data.petInfo)
    else
        GameLog.Log("Affination failed error code id : "..data.ret)
    end
end

--重置加點返回
function OnPetResetPoint(data)
    
end
--加點返回
function OnPetAddPoint(data)
    if data.ret ~= 0 then
        GameLog.LogError("Operate failed error code is : "..data.ret)
        return 
    end
end

function ShowTipsOnGetNewPet(dataInfo)
    local str = ""
    local petData = PetData.GetPetDataById(dataInfo.tempId)
    if dataInfo.isPrecious == 1 then
        if petData.petType2 == 1 then
            str = string.format( WordData.GetWordStringByKey("Pet_get_zp"), WordData.GetWordStringByKey("Pet_class_bb"), dataInfo.name)
        elseif petData.petType2 == 2 then
            str = string.format( WordData.GetWordStringByKey("Pet_get_zp"), WordData.GetWordStringByKey("Pet_class_by"), dataInfo.name)
        elseif petData.petType2 == 3 then
            str = string.format( WordData.GetWordStringByKey("Pet_get_zp"), WordData.GetWordStringByKey("Pet_class_ys"), dataInfo.name)
        elseif petData.petType2 == 3 then
            str = string.format( WordData.GetWordStringByKey("Pet_get_zp"), WordData.GetWordStringByKey("Pet_class_ss"), dataInfo.name)
        end
    else
        if petData.petType2 == 1 then
            str = string.format( WordData.GetWordStringByKey("Pet_get_showtype"), WordData.GetWordStringByKey("Pet_class_bb"), dataInfo.name)
        elseif petData.petType2 == 2 then
            str = string.format( WordData.GetWordStringByKey("Pet_get_showtype"), WordData.GetWordStringByKey("Pet_class_by"), dataInfo.name)
        elseif petData.petType2 == 3 then
            str = string.format( WordData.GetWordStringByKey("Pet_get_showtype"), WordData.GetWordStringByKey("Pet_class_ys"), dataInfo.name)
        end
    end
    TipsMgr.TipByFormat(str)
end

--更新指定寵物信息返回   增加新宠物， 宠物加点， 宠物重置点  会发
function OnUpdateOnePet(data)
    if data.updateType == NetCS_pb.ePETUPDATETYPE_ADD then --新增
        if #mPetInfoList >= 8 then
            TipsMgr.TipByKey("Pet_get_banbag")
            return
        end
        table.insert(mPetInfoList, data.petInfo)
        --ShowTipsOnGetNewPet(data.petInfo)
    elseif data.updateType == NetCS_pb.ePETUPDATETYPE_DATA then --加点 重置点
        for _, info in ipairs(mPetInfoList) do
            if data.petInfo.slotId == info.slotId then
                info.slotId = data.petInfo.slotId
                info.tempId = data.petInfo.tempId
                info.name = data.petInfo.name
                info.level = data.petInfo.level
                info.exp = data.petInfo.exp
                info.physicApt = data.petInfo.physicApt --外功资质
                info.magicApt = data.petInfo.magicApt   --内共资质
                info.hpApt = data.petInfo.hpApt         --气血资质
                info.physicDefApt = data.petInfo.physicDefApt --外防资质
                info.magicDefApt = data.petInfo.magicDefApt --内防资质
                info.growth = data.petInfo.growth  -- 成长值
                info.pointUnalloc = data.petInfo.pointUnalloc --未分配的点数
                info.strength = data.petInfo.strength --一级属性力量
                info.physical = data.petInfo.physical --一级属性体质
                info.stamina = data.petInfo.stamina --一级属性耐力
                info.intellect = data.petInfo.intellect --一级属性智力
                info.reAllocCount = data.petInfo.reAllocCount --重新分配点数的次数
                info.Current = data.petInfo.Current --是否是当前出战的宠物
                info.power = data.petInfo.power --战力
                info.attrs = data.petInfo.attrs --二级属性
                info.OwnSkills = data.petInfo.OwnSkills
                info.curHP = data.petInfo.curHP
                info.curMP = data.petInfo.curMP
                info.addPoints = data.petInfo.addPoints
                info.isPrecious = data.petInfo.isPrecious --1 珍品 2 不是珍品
                info.affinationCount = data.petInfo.affinationCount -- 玩家洗练次数
            end
        end
    end

    SetIsUpdateInfo(true)
    GameEvent.Trigger(EVT.PET, EVT.PET_ONUPDATEONEINFO, false)
end

--请求 宠物合成
function RequestCSComposePets(slot1, slot2)
    local msg = NetCS_pb.CSComposePets()
    msg.petSlotId1 = slot1
    msg.petSlotId2 = slot2
    GameNet.SendToGate(msg)
end

--宠物合成返回
function OnSCComposePetsRet(data)
    if data.ret ~= 0 then
        GameLog.Log("Pet compose failed , error code is : "..data.ret)
        return 
    end

    mPetInfoList = {}

    for _, v in ipairs(data.infos) do
        local vo = {}
        vo.slotId = v.slotId
        vo.tempId = v.tempId
        vo.name = v.name
        vo.level = v.level
        vo.exp = v.exp
        vo.physicApt = v.physicApt --外功资质
        vo.magicApt = v.magicApt   --内共资质
        vo.hpApt = v.hpApt         --气血资质
        vo.physicDefApt = v.physicDefApt --外防资质
        vo.magicDefApt = v.magicDefApt --内防资质
        vo.growth = v.growth  -- 成长值
        vo.pointUnalloc = v.pointUnalloc --未分配的点数
        vo.strength = v.strength --一级属性力量
        vo.physical = v.physical --一级属性体质
        vo.stamina = v.stamina --一级属性耐力
        vo.intellect = v.intellect --一级属性智力
        vo.reAllocCount = v.reAllocCount --重新分配点数的次数
        vo.Current = v.Current --是否是当前出战的宠物
        vo.power = v.power --战力
        vo.attrs = v.attrs --二级属性
        vo.OwnSkills = v.OwnSkills
        vo.curHP = v.curHP
        vo.curMP = v.curMP
        vo.addPoints = v.addPoints
        vo.isPrecious = v.isPrecious --1 珍品 2 不是珍品
        vo.affinationCount = v.affinationCount --玩家洗练次数
        table.insert(mPetInfoList, vo)
    end
    mComposeSlot = data.newSlot
    GameEvent.Trigger(EVT.PET, EVT.PET_COMPOSESUCCEED, data.newSlot)

    -- for i, v in ipairs(mPetInfoList) do
    --     if v.slotId == data.newSlot then
    --         ShowTipsOnGetNewPet(v)
    --     end
    -- end
end

function OnPetLevelup(data)
    GameEvent.Trigger(EVT.PET, EVT.PET_ONPETLEVELUP, data.level)
end

function RequestCSPetSkillStudy(petSlotId, skillBookSlotId)
    local msg = NetCS_pb.CSPetSkillStudy()
    msg.petSlotId = petSlotId
    msg.skillBookSlotId = skillBookSlotId
    GameNet.SendToGate(msg)
end

function OnSCPetSkillStudyRet(data)
    if data.ret ~= 0 then
        GameLog.LogError("skill study fail  error code is :"..data.ret)
        return 
    end

    for _, info in ipairs(mPetInfoList) do
        if data.slotId == info.slotId then
            info.OwnSkills = data.skills
        end
    end

    GameEvent.Trigger(EVT.PET, EVT.PET_STUDYSKILLSUCCEED)
end

-- function OnSCBroadCastPetInfo(data)
--     GameEvent.Trigger(EVT.PET, EVT.PET_BROADCASTPETINFO, data)
-- end

function GetPetInfoList()
    return mPetInfoList
end

function GetPetDataList()
    local petDataList = {}
    local count = ConfigData.GetIntValue("Pet_bag_content")
    for i = 1, count do
        if mPetInfoList[i] ~= nil then
            local vo = {}
            vo.petId = mPetInfoList[i].tempId
            vo.level = mPetInfoList[i].level
            vo.slotId = mPetInfoList[i].slotId
            table.insert(petDataList, vo)
        else
            local vo = {}
            vo.petId = 0
            vo.level = 0
            vo.slotId = 0
            table.insert(petDataList, vo)
        end
    end

    return petDataList
end

--petId 宠物id count 一般要显示的技能数量 num 每一行要显示的技能的数量
function GetPetSkillListByPetId(slotId, count, num)
    local petSkillDataList = {}

    local petInfo = GetPetInfoBySlotId(slotId)

    for _, v in ipairs(petInfo.OwnSkills) do
        if PetData.GetPetSkillDataBySkillId(v.tempSkillId) then
            local vo = {}

            if PetData.GetPetSkillDataBySkillId(v.tempSkillId).skillType ~= 4 then
                vo.tempSkillId = v.tempSkillId
                vo.skillSlot = v.skillSlot
                vo.skillStatus = v.skillStatus
                local skillData = PetData.GetPetSkillDataBySkillId(vo.tempSkillId)
                if SkillData.skillType ~= 4 then
                    table.insert(petSkillDataList, vo)
                end
            end
        end
    end

    table.sort(petSkillDataList, function (a, b)
        local aData = PetData.GetPetSkillDataBySkillId(a.tempSkillId)
        local bData = PetData.GetPetSkillDataBySkillId(b.tempSkillId)
        return aData.skillType < bData.skillType
    end)

    if #petSkillDataList > count then
        local add = math.ceil((#petSkillDataList - count) / num ) 
        local newCount = count + add * num
        for i = 1, newCount - #petSkillDataList do
            local vo = {}
            vo.tempSkillId = 0
            vo.skillSlot = 0
            vo.skillStatus = 0
            table.insert(petSkillDataList, vo)
        end
    else
        for i = 1, count - #petSkillDataList do
            local vo = {}
            vo.tempSkillId = 0
            vo.skillSlot = 0
            vo.skillStatus = 0
            table.insert(petSkillDataList, vo)
        end
    end

    return petSkillDataList
end

function GetEmptySkillList(count)
    local petSkillDataList = {}
    for i = 1, count do
        local vo = {}
        vo.tempSkillId = 0
        vo.skillSlot = 0
        vo.skillStatus = 0
        table.insert(petSkillDataList, vo)
    end
    return petSkillDataList
end

--加点
function SetPoints(index, isAdd)
    local petInfo = GetPetInfoBySlotId(mCurrShowPetSlotId)
    local remain = petInfo.pointUnalloc
    local total = 0
    for i = 1, 4 do
        total = total + mPoints[i]
    end
    if isAdd then
        if total >= petInfo.pointUnalloc then
            return    
        end
        mPoints[index] = mPoints[index] + 1
        total = total + 1
    else
        if mPoints[index] <= 0 then
            return
        end
        mPoints[index] = mPoints[index] - 1
        total = total - 1
    end
    
    remain = petInfo.pointUnalloc - total
    GameEvent.Trigger(EVT.PET, EVT.POINT_CHANGED, mPoints[1], mPoints[2], mPoints[3], mPoints[4], remain)
end

function ResetPoins()
     mPoints = 
    {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
    }
end

function GetPetMaxTalent(petData)
    local talentData = PetData.GetPetTalentDataById(petData.zzczGroupID)

    if talentData == nil then return end

    local outerAckMax = 0
    local insideAckMax = 0
    local outerDefMax = 0
    local insideDefMax = 0
    local phyPowerMax = 0

    if petData.petType2 == 1 then
        outerAckMax = talentData.outerAttackAptitude * ConfigData.GetFloatValue("Pet_apti_bbratio")
        outerAckMax = math.floor(outerAckMax)

        insideAckMax = talentData.insideAttackAptitude * ConfigData.GetFloatValue("Pet_apti_bbratio")
        insideAckMax = math.floor(insideAckMax)

        outerDefMax = talentData.outerDefendAptitude * ConfigData.GetFloatValue("Pet_apti_bbratio")
        outerDefMax = math.floor(outerDefMax)

        insideDefMax = talentData.insideDefendAptitude * ConfigData.GetFloatValue("Pet_apti_bbratio")
        insideDefMax = math.floor(insideDefMax)

        phyPowerMax = talentData.hpAptitude * ConfigData.GetFloatValue("Pet_apti_bbratio")
        phyPowerMax = math.floor(phyPowerMax)

    elseif petData.petType2 == 2 then
        outerAckMax = talentData.outerAttackAptitude * ConfigData.GetFloatValue("Pet_apti_byratio")
        outerAckMax = math.floor(outerAckMax)

        insideAckMax = talentData.insideAttackAptitude * ConfigData.GetFloatValue("Pet_apti_byratio")
        insideAckMax = math.floor(insideAckMax)

        outerDefMax = talentData.outerDefendAptitude * ConfigData.GetFloatValue("Pet_apti_byratio")
        outerDefMax = math.floor(outerDefMax)

        insideDefMax = talentData.insideDefendAptitude * ConfigData.GetFloatValue("Pet_apti_byratio")
        insideDefMax = math.floor(insideDefMax)

        phyPowerMax = talentData.hpAptitude * ConfigData.GetFloatValue("Pet_apti_byratio")
        phyPowerMax = math.floor(phyPowerMax)

    elseif petData.petType2 == 3 then
        outerAckMax = talentData.outerAttackAptitude * ConfigData.GetFloatValue("Pet_apti_ysratio")
        outerAckMax = math.floor(outerAckMax)

        insideAckMax = talentData.insideAttackAptitude * ConfigData.GetFloatValue("Pet_apti_ysratio")
        insideAckMax = math.floor(insideAckMax)

        outerDefMax = talentData.outerDefendAptitude * ConfigData.GetFloatValue("Pet_apti_ysratio")
        outerDefMax = math.floor(outerDefMax)

        insideDefMax = talentData.insideDefendAptitude * ConfigData.GetFloatValue("Pet_apti_ysratio")
        insideDefMax = math.floor(insideDefMax)

        phyPowerMax = talentData.hpAptitude * ConfigData.GetFloatValue("Pet_apti_ysratio")
        phyPowerMax = math.floor(phyPowerMax)

    elseif petData.petType2 == 4 then
        outerAckMax = talentData.outerAttackAptitude * ConfigData.GetFloatValue("Pet_apti_shratio")
        outerAckMax = math.floor(outerAckMax)

        insideAckMax = talentData.insideAttackAptitude * ConfigData.GetFloatValue("Pet_apti_shratio")
        insideAckMax = math.floor(insideAckMax)

        outerDefMax = talentData.outerDefendAptitude * ConfigData.GetFloatValue("Pet_apti_shratio")
        outerDefMax = math.floor(outerDefMax)

        insideDefMax = talentData.insideDefendAptitude * ConfigData.GetFloatValue("Pet_apti_shratio")
        insideDefMax = math.floor(insideDefMax)

        phyPowerMax = talentData.hpAptitude * ConfigData.GetFloatValue("Pet_apti_shratio")
        phyPowerMax = math.floor(phyPowerMax)
    end

    return outerAckMax, insideAckMax, outerDefMax, insideDefMax, phyPowerMax
end

function GetAttrListBySlotId(slotId)
    local attrList = 
    {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {},
    }
    local petInfo = GetPetInfoBySlotId(slotId)
    if petInfo == nil then return end
    local petData = PetData.GetPetDataById(petInfo.tempId);
    local level = petInfo.level;
    local properAtt = PropertyData.GetPropertyAtt(petData.propCallID);
    local addAtt = table.emptyTable;
    local proType = EntityDefine.ENTITY_TYPE.PET;
    local ATTTYPE = PropertyInfo_pb;

    local maxHp = AttrCalculator.CalculUIValue(ATTTYPE.SP_HP_BASE,level,properAtt,addAtt,proType,petInfo);
    attrList[1].key = ATTTYPE.SP_HP_BASE
    attrList[1].value = maxHp

    local maxMp = AttrCalculator.CalculUIValue(ATTTYPE.SP_MP_MAX_BASE,level,properAtt,addAtt,proType,petInfo);
    attrList[2].key = ATTTYPE.SP_MP_MAX_BASE
    attrList[2].value = maxMp

    local pAtt = AttrCalculator.CalculUIValue(ATTTYPE.SP_PHYSIC_ATT_BASE,level,properAtt,addAtt,proType,petInfo);
    attrList[3].key = ATTTYPE.SP_PHYSIC_ATT_BASE
    attrList[3].value = pAtt

    local mAtt = AttrCalculator.CalculUIValue(ATTTYPE.SP_MAGIC_ATT_BASE,level,properAtt,addAtt,proType,petInfo);
    attrList[4].key = ATTTYPE.SP_MAGIC_ATT_BASE
    attrList[4].value = mAtt

    local pDef = AttrCalculator.CalculUIValue(ATTTYPE.SP_PHYSIC_DEF_BASE,level,properAtt,addAtt,proType,petInfo);
    attrList[5].key = ATTTYPE.SP_PHYSIC_DEF_BASE
    attrList[5].value = pDef

    local mDef = AttrCalculator.CalculUIValue(ATTTYPE.SP_MAGIC_DEF_BASE,level,properAtt,addAtt,proType,petInfo);
    attrList[6].key = ATTTYPE.SP_MAGIC_DEF_BASE
    attrList[6].value = mDef

    return attrList;
end

function ResetData()
    mPetInfoList = {}
end

function GetTodayIsFirstAffination()
    return mTodayAffination
end

function GetComposeList()
    local list = {}
    for i, v in ipairs(mPetInfoList) do
        local data = PetData.GetPetDataById(v.tempId)
        if data.petType2 == 1 and data.bindType == 0 and v.Current ~= 1 then
            table.insert(list, v)
        end
    end
    return list
end

function GetComposeResultData()
    for i, v in ipairs(mPetInfoList) do
        if v.slotId == mComposeSlot then
            return v
        end
    end
    return nil
end

function SetIsAffinationSucceed(isAffination)
    mIsAffinationSucceed = isAffination
end

function GetIsAffinationSucceed()
    return mIsAffinationSucceed
end

function GetCurrHandSkill()
    local petInfo = nil
    local skillId = 0
    for i, v in ipairs(mPetInfoList) do
        if v.Current == 1 then
            petInfo = v
        end
    end

    if petInfo then
        for i, v in ipairs(petInfo.OwnSkills) do
            if v.skillStatus == 1 then
                skillId = v.tempSkillId
            end
        end
    end

    return skillId
end

function SetIsChangeTarget(b)
    mIsChangeTarget = b
end

function GetIsChangeTarget()
    return mIsChangeTarget
end

function GetCurrFightPet()
    for i, v in ipairs(mPetInfoList) do
        if v.Current == 1 then
            return  v
        end
    end

    return nil
end

function GetPetMaxHPBySlotId(slotId)
    local attrList = GetAttrListBySlotId(slotId)
    for i, v in ipairs(attrList) do
        if v.key == PropertyInfo_pb.SP_HP_BASE then
            return tonumber(v.value)
        end
    end
    return 0
end

function GetIsUpdateInfo()
    return mIsUpdateInfo
end

function SetIsUpdateInfo(b)
    mIsUpdateInfo = b
end

return PetMgr