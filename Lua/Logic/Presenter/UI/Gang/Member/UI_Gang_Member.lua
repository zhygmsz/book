module("UI_Gang_Member", package.seeall)

--组件
local mSelf


--变量
local mLeftToggleGroup
local mLeftBtnData = 
{
    { eventId = 1, content = "成员列表" },
    { eventId = 2, content = "申请列表" },
    { eventId = 3, content = "招募成员" },
    { eventId = 4, content = "帮会事件" },
    { eventId = 5, content = "团队管理" },
    { eventId = 6, content = "组队平台" },
}
local mLeftBtnNum = #mLeftBtnData
local mLeftBtn2UI = 
{
    [mLeftBtnData[1].eventId] = AllUI.UI_Gang_MemberList,
    [mLeftBtnData[2].eventId] = AllUI.UI_Gang_ApplyList,
    [mLeftBtnData[3].eventId] = nil,
    [mLeftBtnData[4].eventId] = nil,
    [mLeftBtnData[5].eventId] = nil,
    [mLeftBtnData[6].eventId] = nil,
}


--local方法
local function OnNor(eventId)
    if eventId and mLeftBtn2UI[eventId] then
        UIMgr.UnShowUI(mLeftBtn2UI[eventId])
    end
end

local function OnSpec(eventId)
    if eventId and mLeftBtn2UI[eventId] then
        UIMgr.ShowUI(mLeftBtn2UI[eventId])
    end
end

local function CheckIsLeftBtn(eventId)
    return 1 <= eventId and eventId <= mLeftBtnNum
end

local function RegEvent()
    
end

local function UnRegEvent()

end


function OnCreate(self)
    mSelf = self

    mLeftToggleGroup = ToggleItemGroup.new(OnNor, OnSpec)

    local trs = nil
    for idx = 1, mLeftBtnNum do
        trs = self:Find("Offset/Left/RoomRoot/btn" .. tostring(idx))
        mLeftToggleGroup:AddItem(trs, mLeftBtnData[idx])
    end

end

function OnEnable(self)
    RegEvent()

    --默认选中成员列表
    mLeftToggleGroup:OnClick(mLeftBtnData[1].eventId)
end

function OnDisable(self)
    UnRegEvent()

    mLeftToggleGroup:OnDisable()
end

function OnDestroy(self)
    mLeftToggleGroup:OnDestroy()
end

function OnClick(go, id)
    if CheckIsLeftBtn(id) then
        --左侧按钮列表
        mLeftToggleGroup:OnClick(id)
    end
end