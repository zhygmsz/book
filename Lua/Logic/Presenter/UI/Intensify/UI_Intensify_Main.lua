module("UI_Intensify_Main", package.seeall)

--组件
local mSelf

--变量
local mEventIds = {}
local mToggleItemGroup
local mRightBtnData = 
{
    { eventId = 1, content = WordData.GetWordStringByKey("equip_forge") },
    { eventId = 2, content = WordData.GetWordStringByKey("gem_inlay") },
    { eventId = 3, content = WordData.GetWordStringByKey("equip_repair") },
    { eventId = 4, content = WordData.GetWordStringByKey("equip_baptize") },
}
local mRightBtnNum = 4
local mRightBtn2UI = 
{
    [mRightBtnData[1].eventId] = AllUI.UI_Intensify_Make,  --打造
    [mRightBtnData[2].eventId] = AllUI.UI_Intensify_Inlay,  --镶嵌
    [mRightBtnData[3].eventId] = nil,  --修理
    [mRightBtnData[4].eventId] = nil,  --洗练
}

--local方法
local function OnNor(eventId)
    if eventId and mRightBtn2UI[eventId] then
        UIMgr.UnShowUI(mRightBtn2UI[eventId])
    end
end

local function OnSpec(eventId)
    if eventId and mRightBtn2UI[eventId] then
        UIMgr.ShowUI(mRightBtn2UI[eventId])
    end
end

local function CheckIsRightBtn(eventId)
    local isRightBtn = false

    for _, data in ipairs(mRightBtnData) do
        if data.eventId == eventId then
            isRightBtn = true
            break
        end
    end

    return isRightBtn
end

local function RegEvent(self)
    
end

local function UnRegEvent(self)
    
end

function OnCreate(self)
    mSelf = self

    mToggleItemGroup = ToggleItemGroup.new(OnNor, OnSpec)

    local trs = nil
    for idx = 1, mRightBtnNum do
        trs = self:Find("Offset/right/btn" .. tostring(idx))
        mToggleItemGroup:AddItem(trs, mRightBtnData[idx])
    end
end

function OnEnable(self)
    RegEvent(self)

    --默认打开镶嵌
    mToggleItemGroup:OnClick(2)
end

function OnDisable(self)
    UnRegEvent(self)
    mToggleItemGroup:OnDisable()
end

function OnClick(go, id)
    if id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Intensify_Main)
    elseif CheckIsRightBtn(id) then
        mToggleItemGroup:OnClick(id)
    end
end

function OnDestroy(self)
    
end

