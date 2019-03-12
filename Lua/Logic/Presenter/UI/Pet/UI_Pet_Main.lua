module("UI_Pet_Main", package.seeall)

local mToggleItemGroup

local mTargetBtnInfo = 
{
    { eventId = 1, content = WordData.GetWordStringByKey("Pet_show_label1") },
    { eventId = 2, content = WordData.GetWordStringByKey("Pet_show_label2") },
    { eventId = 3, content = WordData.GetWordStringByKey("Pet_show_label3") },
    { eventId = 4, content = WordData.GetWordStringByKey("Pet_show_label5") },
}
local mTargetBtn = 
{
    [mTargetBtnInfo[1].eventId] = AllUI.UI_Pet_Attr,
    [mTargetBtnInfo[2].eventId] = AllUI.UI_Pet_Affination,
    [mTargetBtnInfo[3].eventId] = nil,--AllUI.UI_Pet_PeiYang,
    [mTargetBtnInfo[4].eventId] = nil,--AllUI.UI_Pet_TuJian,
}

--节点变量
local mCloseBtn
local mPetName
local mChangeNameBtn
local mChangeColorBtn
local mPetFight
local mPetLevel
local mProgressBar
local mAddBtn
local mAddPointBtn
local mFightBtn
local mReleaseBtn

local function OnNoonePet()
    mToggleItemGroup:OnClick(4)
end

local function RegEvent(self)
    GameEvent.Reg(EVT.PET, EVT.PET_NOONE, OnNoonePet)
end

local function UnRegEvent(self)
    GameEvent.UnReg(EVT.PET, EVT.PET_NOONE, OnNoonePet)
end

local function SetAttrPanel()
    
end

local function SetPetInfo()
    
end

local function OnNorClick(eventId)
    if eventId and mTargetBtn[eventId] then
        UIMgr.UnShowUI(mTargetBtn[eventId])
    end
    if eventId == 2 then
        UIMgr.UnShowUI(AllUI.UI_Pet_Compose)
    end
end

local function OnSpecClick(eventId)
    if eventId and mTargetBtn[eventId] then
        UIMgr.ShowUI(mTargetBtn[eventId])
    end
end

local function CheckIsTargetBtn(id)
    for _, data in ipairs(mTargetBtnInfo) do
        if data.eventId == id then
            return true
        end
    end
    return false
end

function OnCreate(self)
    mToggleItemGroup = ToggleItemGroup.new(OnNorClick, OnSpecClick)

    for i = 1, 4 do
        local trs = self:Find("Offset/Bg/TargetBtn"..i)
        mToggleItemGroup:AddItem(trs, mTargetBtnInfo[i])
    end
    
end

function OnEnable()
    RegEvent()
    UIMgr.MaskUI(true, AllUI.GET_MIN_DEPTH(), AllUI.GET_UI_DEPTH(AllUI.UI_Pet_Main))
    local petlist = PetMgr.GetPetInfoList()
    if next(petlist) == nil then
        mToggleItemGroup:OnClick(4)
        return 
    end
    mToggleItemGroup:OnClick(1)
end

function OnDisable()
    UnRegEvent()
    UIMgr.MaskUI(false)
    mToggleItemGroup:OnDisable()

    PetMgr.SetIsChangeTarget(false)
end

function OnDestory()
    
end

function OnClick(go, id)
    if id == -1 then
        UIMgr.UnShowUI(AllUI.UI_Pet_Main)
        UIMgr.UnShowUI(AllUI.UI_Pet_Compose)
        UIMgr.UnShowUI(AllUI.UI_Pet_Tips)
    elseif CheckIsTargetBtn(id) then
        mToggleItemGroup:OnClick(id)
    end
end