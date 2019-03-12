module("UI_AIPet_Clothes",package.seeall);

local UIAIPetClothItemWrapUI = require("Logic/Presenter/UI/AIPet/Clothes/UIAIPetClothItemWrapUI");
local UIAIPetClothCategoryWrapUI = require("Logic/Presenter/UI/AIPet/Clothes/UIAIPetClothCategoryWrapUI");
--选择的宠物
local mPet;
local mAllParts;
--选择的类别
local mSelectedCategory;
--分类UITableWrapContent相关
local mCategoryTable;
--物品UITableWrapContent相关
local mItemTable;

--当前宠物装扮试穿记录表，[cloth/false]
local mDressedInIDTable = {};
--左侧物品栏的初始化用
local mDressedInUITable;
local mDressedInPartyUIHashTable = {};

--供给子UI使用的方法
function IsItemDressedIn(cloth)
    local part = cloth:GetPart();
    return mDressedInIDTable[part] == cloth;
end

function GetSelectedCategory()
    return mSelectedCategory;
end

--辅助函数
local function UpdateClothesDressIn(part)

    local uiItem = mDressedInPartyUIHashTable[part];
    local cloth = mDressedInIDTable[part] or nil;
    
    if not cloth then
        uiItem.icon.spriteName = AIPetMgr.GetDefaultItemIcon(part);
        uiItem.label.text = WordData.GetWordStringByKey("AIPet_Clothes_State_notDressed");--未穿上
        uiItem.buttonGo:SetActive(false);
    else
        uiItem.icon.spriteName = cloth:GetIcon();
        uiItem.label.text = WordData.GetWordStringByKey("AIPet_Clothes_State_Dressed");--已穿上
        uiItem.buttonGo:SetActive(true);
    end
    uiItem.icon:MakePixelPerfect();
end

local function UpdateAllClothesDressedIn()    
    for i,part in ipairs(mAllParts) do
        local cloth = mPet:GetClothDressedByPart(part);
        mDressedInIDTable[part] = cloth or false;
        --local ui = mDressedInPartyUIHashTable[part];
        UpdateClothesDressIn(part);
    end
end

--收到服务器关于物品过期或者穿戴的消息
local function OnPetClothesInfoChange(pet)
    if pet ~= mPet then return; end
    
    UpdateAllClothesDressedIn();

    mItemTable:Update();
end

local function SetDressInIDTable(part,cloth)
    local oldCloth = mDressedInIDTable[part];
    mDressedInIDTable[part] = cloth or false;
    if oldCloth then
        mItemTable:RefreshWrapUI(oldCloth);
    end
    if cloth then
        mItemTable:RefreshWrapUI(cloth);
    end
    UpdateClothesDressIn(part);
end

-- local function OnClothesDressedInClick(cloth)
--     local part = cloth:GetPart();
--     SetDressInIDTable(part,false);
-- end

local function SaveSettings()
    local changed =false;
    local list = {};

    for i,part in ipairs(mAllParts) do
        local cloth = mPet:GetClothDressedByPart(part);

        if mDressedInIDTable[part] ~= cloth then
            changed = true;
        end
        if mDressedInIDTable[part] then
            table.insert(list,mDressedInIDTable[part]);
        end
    end
    if changed then
        AIPetMgr.RequestSetPetClothes(mPet,list);
    end
end

function OnItemUnavailableClick(cloth,wrapUI)
    --UI_Gift_ItemInfo.Show(tid, wrapUI:GetPosition());
    TipsMgr.TipByKey("AIPet_Clothes_Unavailable");
end

function OnItemDressedInClick(cloth,wrapUI)
    local part = cloth:GetPart();
    SetDressInIDTable(part, false);
end

function OnItemTakenOffClick(cloth,wrapUI)
    local part = cloth:GetPart();
    SetDressInIDTable(part,cloth);
end

function OnItemCategoryClick(part,wrapUI)
    mSelectedCategory = part;
    local itemDatas = mPet:GetAllClothByPart(mSelectedCategory);
    mItemTable:ResetWithData(itemDatas);
end

function OnCreate(ui)
    mDressedInUITable = {};
                                              --(ui,path,count,wrapUIClass,itemCountPerLine,context)
    mCategoryTable = BaseWrapContentEx.new(ui,"Offset/ClotherPanel/BagWidget/BagTitle/Scroll View",7,UIAIPetClothCategoryWrapUI,nil,UI_AIPet_Clothes);
    mCategoryTable:SetUIEvent(100,1,OnItemCategoryClick);
    mItemTable = BaseWrapContentEx.new(ui,"Offset/ClotherPanel/BagWidget/BagContent/Scroll View",14,UIAIPetClothItemWrapUI,2,UI_AIPet_Clothes);
    mItemTable:SetUIEvent(200,5,{OnItemUnavailableClick,OnItemDressedInClick,OnItemTakenOffClick});


    local path = "Offset/ClothesDressedIn/Sprite%s/"
    for index = 1,4 do
        local item = {};
        local path1 = string.format(path.."Icon",index);
        item.icon = ui:FindComponent("UISprite",path1);
        path1 = string.format(path.."Label",index);
        item.label = ui:FindComponent("UILabel",path1);
        path1 = string.format(path.."Button",index);
        item.buttonGo = ui:Find(path1).gameObject;
        ui:FindComponent("UIEvent",path1).id = 10 + index;

        mDressedInUITable[index] = item;
    end
end


function OnEnable(ui)
    --初始化数据
    mAllParts = mPet:GetAllParts();
    for i,part in ipairs(mAllParts) do--绑定UI
        mDressedInPartyUIHashTable[part] = mDressedInUITable[i];
    end

    UpdateAllClothesDressedIn();
    --初始化UI

    mSelectedCategory = mAllParts[1];
    mCategoryTable:ResetWithData(mAllParts);

    local itemDatas = mPet:GetAllClothByPart(mSelectedCategory);
    mItemTable:ResetWithData(itemDatas);

    GameEvent.Reg(EVT.AIPET,EVT.AIPET_CLOTH_DRESS,OnPetClothesInfoChange);

end

function OnDisable()
    GameLog.Log("Unshow ui ".."UI_GiftSend_FreddPanel");

    GameEvent.UnReg(EVT.AIPET,EVT.AIPET_CLOTH_DRESS,OnPetClothesInfoChange);
end

function OnDestroy()
    mItemTable = nil;
    mCategoryTable = nil;
    mDressedInUITable = nil;
end

function OnClick(go,id)
    GameLog.Log("OnClick %s, %s",go.name,id)
    if id >= 200 then
        mItemTable:OnClick(id);
    elseif id >= 100 then
        mCategoryTable:OnClick(id);
    elseif id >= 10 and id < 20 then
        id = id - 10;
        SetDressInIDTable(mAllParts[id],false);
    elseif id == 1 then
        SaveSettings();    
    elseif id == 0 then
        UIMgr.UnShowUI(AllUI.UI_AIPet_Clothes);
    elseif id == -1 then
        UIMgr.UnShowUI(AllUI.UI_AIPet_Clothes);
        UIMgr.UnShowUI(AllUI.UI_AIPet_Home);
    end
end

function ShowPet(pet)
    mPet = pet;
    UIMgr.ShowUI(AllUI.UI_AIPet_Clothes);
end
