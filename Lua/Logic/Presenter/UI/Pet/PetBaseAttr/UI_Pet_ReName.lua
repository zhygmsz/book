module("UI_Pet_ReName", package.seeall)

--local mTitle
local mTips
local mNewName
local mTxt

local function OnReName()
    UIMgr.UnShowUI(AllUI.UI_Pet_ReName)
end

local function Reg()
    GameEvent.Reg(EVT.PET, EVT.PET_RENAME, OnReName)
end

local function UnReg()
    GameEvent.UnReg(EVT.PET, EVT.PET_RENAME, OnReName)
end

function OnCreate(self)
    --mTitle = self:Find("Offset/Title"):GetComponent("UILabel")
    mTips = self:Find("Offset/Tips"):GetComponent("UILabel")
    mNewName = self:Find("Offset/Input/PetName"):GetComponent("LuaUIInput") 
    mTxt = self:Find("Offset/Input/PetName/PlaceHolder"):GetComponent("UILabel")   
end

function OnEnable()
    Reg()
    --mTitle.text = WordData.GetWordStringByKey("Pet_promess_rename")
    mTips.text = WordData.GetWordStringByKey("Pet_promess_rename1")
    mTxt.text = WordData.GetWordStringByKey("Pet_promess_rename2")
    mNewName.value = ""
end

function OnDisable()
    UnReg()
end

function OnDestory()
    
end

function OnClick(go, id)
    if id == -1 then
        UIMgr.UnShowUI(AllUI.UI_Pet_ReName)
    elseif id == 1 then
        local newName = mNewName.value
        local slotId = PetMgr.GetCurrShowPetSlotId()
        PetMgr.RequestCSPetRename(newName, slotId)
    elseif id == 2 then
        UIMgr.UnShowUI(AllUI.UI_Pet_ReName)
    end
end