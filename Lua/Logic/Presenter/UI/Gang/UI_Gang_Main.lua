--帮会主界面，右侧有四个功能按钮
module("UI_Gang_Main", package.seeall)

--组件
local mSelf


--变量
local mToggleGroup
local mRightBtnData = 
{
    { eventId = 1, content = "信息" },
    { eventId = 2, content = "成员" },
    { eventId = 3, content = "福利" },
    { eventId = 4, content = "活动" },
}
local mRightBtnNum = #mRightBtnData
local mRightBtn2UI = 
{
    [mRightBtnData[1].eventId] = AllUI.UI_Gang_Info,  --信息
    [mRightBtnData[2].eventId] = AllUI.UI_Gang_Member,  --成员
    [mRightBtnData[3].eventId] = nil,  --福利
    [mRightBtnData[4].eventId] = nil,  --活动
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
    return 1 <= eventId and eventId <= mRightBtnNum
end

local function RegEvent(self)
    
end

local function UnRegEvent(self)
    
end


function OnCreate(self)
    mSelf = self

    mToggleGroup = ToggleItemGroup.new(OnNor, OnSpec)

    local trs = nil
    for idx = 1, mRightBtnNum do
        trs = self:Find("Offset/TabList/btn" .. tostring(idx))
        mToggleGroup:AddItem(trs, mRightBtnData[idx])
    end
end

function OnEnable(self)
    RegEvent()

    --默认打开信息界面，可以做成OnEnable携带参数形式
    mToggleGroup:OnClick(mRightBtnData[1].eventId)
end

function OnDisable(self)
    UnRegEvent()
    mToggleGroup:OnDisable()
end

function OnDestroy(self)
    mToggleGroup:OnDestroy()
end

function OnClick(go, id)
    if id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Gang_Main)
    elseif CheckIsRightBtn(id) then
        mToggleGroup:OnClick(id)
    end
end

