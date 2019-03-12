module("PetData", package.seeall)

DATA.PetData.mPetDataDic = nil
DATA.PetData.mPetDataList = nil

DATA.PetData.mPetExpDataDic = nil

DATA.PetData.mPetTalentDataDic = nil

DATA.PetData.mPetSkillDataDic = nil

DATA.PetData.mPetAffinationInfoDic = nil

DATA.PetData.mPetSkillGroupDic = nil

local function OnLoadedPet(data)
    if not data then
        return 
    end

    local pb = PetData_pb.AllPets()
    pb:ParseFromString(data)

    local petInfo = {}

    for i, v in ipairs(pb.pets) do
        petInfo[v.id] = v
    end

    DATA.PetData.mPetDataDic = petInfo
    DATA.PetData.mPetDataList = pb.pets
end

local function OnLoadedPetExp(data)
    if not data then
        return 
    end

    local pb = PetData_pb.AllPetExps()
    pb:ParseFromString(data)

    local  petExpInfo = {}
    for i, v in ipairs(pb.petExps) do
        petExpInfo[v.id] = v
    end

    DATA.PetData.mPetExpDataDic = petExpInfo
end

local function OnLoadedPetTalent(data)
    if not data then
        return 
    end

    local pb = PetData_pb.AllPetAptitudeGrows()
    pb:ParseFromString(data)

    local petTalentInfo = {}
    for i, v in ipairs(pb.petAptitudeGrows) do
        petTalentInfo[v.id] = v
    end

    DATA.PetData.mPetTalentDataDic = petTalentInfo
end

local function OnLoadedPetSkill(data)
    if not data then
        return 
    end

    local pb = PetData_pb.AllPetSkillProps()
    pb:ParseFromString(data)

    local petSkill = {}
    for i, v in ipairs(pb.petSkillProps) do
        petSkill[v.id] = v
    end

    DATA.PetData.mPetSkillDataDic = petSkill
end

local function OnLoadPetAffination(data)
    if not data then
        return 
    end

    local pb = PetData_pb.AllPetAffinations()
    pb:ParseFromString(data)

    local petAffination = {}
    for i, v in ipairs(pb.petsAffination) do
        petAffination[v.id] = v
    end

    DATA.PetData.mPetAffinationInfoDic = petAffination
end

local function OnLoadPetSkillGroup(data)
    if not data then
        return 
    end

    local pb = PetData_pb.AllPetSkills()
    pb:ParseFromString(data)

    local skillGroup = {}
    for i, v in ipairs(pb.petSkills) do
        skillGroup[v.id] = v
    end

    DATA.PetData.mPetSkillGroupDic = skillGroup
end

function InitModule()
    local argData1 = 
	{
		keys = { mPetDataDic = true, mPetDataList = true},
		fileName = "Pet.bytes",
		callBack = OnLoadedPet,
    }

    local argData2 = 
    {
        keys = {mPetExpDataDic = true},
        fileName = "PetExp.bytes",
        callBack = OnLoadedPetExp,
    }
    local argData3 = 
    {
        keys = {mPetTalentDataDic = true},
        fileName = "PetAptitudeGrow.bytes",
        callBack = OnLoadedPetTalent,
    }
    local argData4 = 
    {
        keys = {mPetSkillDataDic = true},
        fileName = "PetSkillProp.bytes",
        callBack = OnLoadedPetSkill,
    }
    local argData5 = 
    {
        keys = {mPetAffinationInfoDic = true},
        fileName = "PetAffination.bytes",
        callBack = OnLoadPetAffination,
    }
    local argData6 = 
    {
        keys = {mPetSkillGroupDic = true},
        fileName = "PetSkill.bytes",
        callBack = OnLoadPetSkillGroup,
    }

    DATA.CREATE_LOAD_TRIGGER(DATA.PetData, argData1, argData2, argData3, argData4, argData5, argData6)
end

function GetPetDataList()
    return DATA.PetData.mPetDataList
end

function GetPetDataById(id)
    if id then
        return  DATA.PetData.mPetDataDic[id]
    end
end

function GetPetExpDataByLevel(level)
    if level then
        return DATA.PetData.mPetExpDataDic[level]
    end
end

function GetPetTalentDataById(id)
    if id then
        return DATA.PetData.mPetTalentDataDic[id]
    end
end

function GetPetSkillDataBySkillId(id)
    if id then
        return DATA.PetData.mPetSkillDataDic[id]
    end
end

function GetPetAffinationData(id)
    if id then
        return DATA.PetData.mPetAffinationInfoDic[id]
    end
end

function GetPetSkillGroupDataByGroupId(id)
    if id then
        return DATA.PetData.mPetSkillGroupDic[id]
    end
end

return PetData