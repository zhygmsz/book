
module("AIPetMgr",package.seeall);
local AIPetClothInfo = require("Logic/System/AIPet/AIPetClothInfo");
local AIPetEntity = require("Logic/System/AIPet/AIPetEntity");
--当前桌面使用的宠物
local mPetInUse;

local mPetSelectedForClothes;

local mPetPool = {};

local mItemByID = {};

--检查是否是首次获得宠物
local function HasAnyActive()
    for _,pet in pairs(mPetPool) do
        if pet:IsActive() then
            return true;
        end
    end
    return false;
end

local function SetPetInUse(pet)
    if mPetInUse == pet then return; end
    mPetInUse = pet;
    GameEvent.Trigger(EVT.AIPET,EVT.AIPET_MAIN,pet);
end

--获得主界面上使用的宠物
function GetPetInUse()
    return mPetInUse;
end
--设置界面是否使用宠物
function IsShowOnDesk()
    local re = UserData.GetAIPetOnDesk();
    if re ~= nil then
        return re;
    end
    return true;
end

function SetShowOnDesk(value)
    UserData.SetAIPetOnDesk(value);
    GameEvent.Trigger(EVT.AIPET,EVT.AIPET_SHOW_DESK,value);
end

function GetModelSizeLevel()
    local size = UserData.GetAIPetSize();
    return size and tonumber(size) or 1;
end

function SetModelSizeLevel(level)
    UserData.SetAIPetSize(level);
end

function Init_Model()

    local allPets = AIPetData.GetAllAIPets();
    for _, petinfo in ipairs(allPets) do
        mPetPool[petinfo.aipetID] = AIPetEntity.new(petinfo);
        --mDressedInTable[pet.aipetID] = {};
    end
    --mPetInUse = allPets[1].aipetID;--默认使用第一个
    local categoriesByID = {};

    local allClothes = AppearanceData.GetAllAIPetItemList();
    for _,clothInfo in pairs(allClothes) do
        local cloth = AIPetClothInfo.new(clothInfo);
        mItemByID[clothInfo.id] = cloth;
        local ped = mPetPool[clothInfo.subType[1]];
        if ped then
            ped:AddCloth(cloth);
        end
    end
    
    RequestGetAllAIPetData();
end


----------------------------------------------------
--请求初始化宠物信息
function RequestGetAllAIPetData()
    local msg = NetCS_pb.CSAIpetGetData();
    GameNet.SendToGate(msg);

    -- local data = {};
    -- data.allAiPetData = {};
    -- data.allAiPetData.aipetInfo = {};
    -- local pet = {};
    -- data.allAiPetData.aipetInfo[2] = pet;
    -- pet.aipetID = 2;
    -- pet.displayState = AiPet_pb.DS_PLAY;
    -- pet.activeState = AiPet_pb.AS_ACTIVE;
    -- pet.clothesInfo = {};
    -- item = {};
    -- pet.clothesInfo[1] = item;
    -- item.clothesID = 1;
    -- item.expireTimes = TimeUtils.SystemTimeStamp()*0.001 + 1000000;
    -- item.clothesState = AiPet_pb.CS_DRESS;
    -- OnGetAllAIPetData(data);
end

function OnGetAllAIPetData(data)
    if (not data) or (not data.allAiPetData) then return; end

    for _,petInfo in ipairs(data.allAiPetData.aipetInfo) do
        local pet = mPetPool[petInfo.aipetID];
        --if not pid then return; end

        pet:SetActiveState(petInfo.activeState);

        if petInfo.displayState == AiPet_pb.DS_PLAY then
            SetPetInUse(pet);
        end

        for _,info in ipairs(petInfo.clothesInfo) do
            local cloth = mItemByID[info.clothesID];
            cloth:SetExpireTime(info.expireTimes);
            if info.clothesState == AiPet_pb.CS_DRESS then
                pet:DressCloth(cloth);
            end
        end
    end
end

--请求使用宠物
function RequestSetPetInUse(pet)

    local msg = NetCS_pb.CSAIpetState();
    msg.aipetID = pet:GetID();
    msg.playState = AiPet_pb.DS_PLAY;
    GameNet.SendToGate(msg);  
end

function OnSetPetInUse(data)
    if data.playState == AiPet_pb.DS_PLAY then
        SetPetInUse(mPetPool[data.aipetID]);
    end
end

--请求更新宠物穿戴信息,宠物ID, 所有穿戴类型
function RequestSetPetClothes(pet,clothesIDTable)
    local msg = NetCS_pb.CSAIpetClothes();
    msg.aipetID = pet:GetID();
    for index,cloth in ipairs(clothesIDTable) do
        local clothItem = AiPet_pb.PetClothes();
        clothItem.clothesID = cloth:GetID();
        clothItem.clothesState = AiPet_pb.CS_DRESS;
        table.insert(msg.clothes,clothItem);
    end
    GameNet.SendToGate(msg);
end

function OnSetPetClothes(data)

    local pet = mPetPool[data.aipetID];
    pet:UndressAllClothes();
    --mDressedInTable[pid] = {};

    for _,info in ipairs(data.clothes) do
        local cloth = mItemByID[info.clothesID];
        if info.clothesState == AiPet_pb.CS_DRESS then
            pet:DressCloth(cloth);
        end

        -- local cid = mItemByID[tid].subType[3];
        -- mDressedInTable[pid][cid] = tid;
    end
    GameEvent.Trigger(EVT.AIPET,EVT.AIPET_CLOTH_DRESS,pet);--更新宠物着装
end

--物品获取或者过期
function OnUpdatePetClothes(data)
    local pid = data.aipetID;
    local pet = mPetPool[pid];
    local tid = data.clothes.clothesID;
    local cloth = mItemByID[tid];

    if data.UpdateType == AiPet_pb.OP_ADD or data.UpdateType == AiPet_pb.OP_UPE then
        --mClothesExpireTable[tid] = data.clothes.expireTimes;
        cloth:SetExpireTime(data.clothes.expireTimes);
        if data.clothes.clothesState == AiPet_pb.CS_DRESS then
            -- local cid = mItemByID[tid].subType[3];
            -- mDressedInTable[pid][cid] = tid;
            pet:DressCloth(cloth);
            GameEvent.Trigger(EVT.AIPET,EVT.AIPET_CLOTH_DRESS,pet);--更新宠物着装
        end
    elseif data.UpdateType == AiPet_pb.OP_DEL then
        --mClothesExpireTable[tid] = nil;
        cloth:SetExpireTime(nil);
    end 
end

--更新宠物状态
function OnUpdatePetState(data)
    local info = data.aipetInfo;
    if not info then return; end

    local pid = info.aipetID;
    local pet = mPetPool[pid];
    GameLog.Log("----------Update AIPet Active State "..pid);
    
    local anyActive = HasAnyActive();
    pet:SetActiveState(info.activeState);
    if info.displayState == AiPet_pb.DS_PLAY then
        SetPetInUse(pet);
        if (not anyActive) and pet:IsActive() then--第一次获得宠物
            GameEvent.Trigger(EVT.AIPET, EVT.AIPET_FIRST_RECEIVE,pet);
        end
    end
end
-------------------------------------------------
function GetAllPets()
    local list = {};
    for pid,_ in pairs(mPetPool) do
        table.insert(list,pid);
    end
    return list;
end

function GetAllActivePets()
    local list = {};
    for _,pet in ipairs(mPetPool) do
        if pet:IsActive() then
            table.insert(list,pet);
        end
    end
    return list;
end

function GetPetByID(pid)
    for _,pet in ipairs(mPetPool) do
        if pet:GetID() == pid then
            return pet;
        end
    end
end

function GetPetByNPCID(npcid)
    for _,pet in ipairs(mPetPool) do
        if pet:GetNPCID() == npcid then
            return pet;
        end
    end
end

function GetPetInfo(pid)
    return mPetPool[pid];
end

function GetPetResume(pid)
    return mPetResumeByID[pid];
end

function SavePetResume(pid)
    UserData.SetAIPetResume(pid, mPetResumeByID[pid]);
end

function GetPetStaticInfo(pid)
    return mPetPool[pid];
end

function SetClothesSelectedPet(pid)
    mPetSelectedForClothes = pid;
end

function GetClothesSelectedPet()
    return mPetSelectedForClothes or 1;
end

function GetClothesCategoryName(part)
    return WordData.GetWordStringByKey("AIPet_Category_Name_"..part);--头上，背部等位置信息，part = subType-2
end

function GetDefaultItemIcon(part)
    return WordData.GetWordStringByKey("AIPet_clothes_default_"..part);
end

function GetAllClothesCategories()
    return mCategoryArray;
end

function GetClothesDefaultCategory()
    return mCategoryArray[1];
end

function GetAllClothesItems()
    local list = {};
    for tid,_ in pairs(mItemByID) do
        table.insert(list,tid);
    end
    return list;
end

function GetClothesCategory(tid)
    return  mItemByID[tid].subType[3];
end

function GetClothesAIPetID(tid)
    return mItemByID[tid].subType[1];
end

function GetClothItemInfo(tid)
    return mItemByID[tid];
end

function GetClothesDressedIn(pid,cid)
    return mDressedInTable[pid][cid];
end

function IsClothesAvailable(tid)
    return mClothesExpireTable[tid] ~= nil;
end

function GetClothesExpireTime(tid)
    return mClothesExpireTable[tid];
end

function GetClothesItemIcon(tid)
    local itemData = ItemData.GetItemInfo(mItemByID[tid].itemID);
    return itemData and itemData.icon_big;
end

function GetClothesItemName(tid)
    local itemData = ItemData.GetItemInfo(mItemByID[tid].itemID);
    return itemData and itemData.name;
end

