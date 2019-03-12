module("UI_Gang_Recommend", package.seeall)

local ContentItemClick = require("Logic/Presenter/UI/Shop/ContentItemClick")
local ContentWidgetClick = require("Logic/Presenter/UI/Shop/ContentWidgetClick")

--组件
local mSelf
local mGangListWidget


--变量
local mGangListEventIdBase = 0
local mGangListEventIdSpan = 2


local mGangList = {}
--已申请的，该结构每次打开界面时重置
local mApplyedList = {}
local mNoCheckRange = { 0, 0 }
local mDisNearRange = { 0, 0 }
local mHighActiveRange = { 0, 0 }


local GangItem = class("GangItem", ContentItemClick)
function GangItem:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemClick.ctor(self, trs, itemIdx, eventIdSpanOffset)

    --组件
    self._name = trs:Find("Name"):GetComponent("UILabel")
    self._dis = trs:Find("Distance"):GetComponent("UILabel")
    self._city = trs:Find("City"):GetComponent("UILabel")
    self._level = trs:Find("Grade"):GetComponent("UILabel")
    self._number = trs:Find("Number"):GetComponent("UILabel")

    self._noCheckGo = trs:Find("ColorBg/Redbg").gameObject
    self._disNearGo = trs:Find("ColorBg/Bluebg").gameObject
    self._highActiveGo = trs:Find("ColorBg/Greenbg").gameObject

    self._bg1Go = trs:Find("bg1").gameObject
    self._bg2Go = trs:Find("bg2").gameObject

    self._applyBtnGo = trs:Find("ApplyBtn").gameObject
    self._applyedGo = trs:Find("Applyed").gameObject

    --变量
    self._numberStr = "%d/%d"
end

function GangItem:InitUIEvent()
    self._uiEvent = self._transform:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = self._eventIdSpanOffset + 1

    local applyUIEvent = self._transform:Find("ApplyBtn"):GetComponent("GameCore.UIEvent")
    applyUIEvent.id = self._eventIdSpanOffset + 2
end

--[[
    @desc: 
    --@colorState: 1免审批，2距离近，3高活跃
]]
function GangItem:InitColorBgGo(colorState)
    self._noCheckGo:SetActive(colorState == 1)
    self._disNearGo:SetActive(colorState == 2)
    self._highActiveGo:SetActive(colorState == 3)
end

function GangItem:DoShowBg()
    if self._dataIdx % 2 == 1 then
        --浅色
        self._bg1Go:SetActive(true)
        self._bg2Go:SetActive(false)
    else
        --深色
        self._bg1Go:SetActive(false)
        self._bg2Go:SetActive(true)
    end
end

function GangItem:Show(data, dataIdx)
    ContentItemClick.Show(self, data, dataIdx)

    self._name.text = data.name
    self._dis.text = "1111KM"
    self._city.text = "艾泽拉斯"
    self._level.text = tostring(data.level)
    self._number.text = string.format(self._numberStr, data.curNumber, data.maxNumber)

    self:DoShowBg()

    self._applyBtnGo:SetActive(true)
    self._applyedGo:SetActive(false)

    --根据dataIdx判断colorstate
    local colorState = self:DataIdx2ColorState(dataIdx)
    self:InitColorBgGo(colorState)

    --检测是否已申请
    if self:CheckIsApplyed() then
        self:SetApplyed()
    end
end

function GangItem:CheckIsApplyed()
    for _, gangId in ipairs(mApplyedList) do
        if gangId == self._data.id then
            return true
        end
    end
    return false
end

function GangItem:DataIdx2ColorState(dataIdx)
    if mNoCheckRange[1] <= dataIdx and dataIdx <= mNoCheckRange[2] then
        return 1
    elseif mDisNearRange[1] <= dataIdx and dataIdx <= mDisNearRange[2] then
        return 2
    elseif mHighActiveRange[1] <= dataIdx and dataIdx <= mHighActiveRange[2] then
        return 3
    end
end

--[[
    @desc: 设置已申请状态
]]
function GangItem:SetApplyed()
    self._applyBtnGo:SetActive(false)
    self._applyedGo:SetActive(true)

    table.insert(mApplyedList, self._data.id)
end


--local方法


local function OnNor(dataIdx)

end

local function OnSpec(dataIdx)

end

local function OnClickSpan(dataIdx, spanIdx)
    --根据spanIdx判断触发的是哪一个事件
    local gangData = mGangList[dataIdx]
    if not gangData then
        return
    end
    if spanIdx == 2 then
        --申请
        GangMgr.RequestJoin(gangData.id)
    end
end

local function ClearApplyedList()
    local len = #mApplyedList
    for idx = 1, len do
        table.remove(mApplyedList)
    end
end

local function ClearGangList()
    local len = #mGangList
    for idx = 1, len do
        table.remove(mGangList)
    end
end

local function InitGangList(data)
    ClearGangList()

    --免审批
    local noCheckList = data.guildList3
    local noCheckLen = #noCheckList
    for idx = 1, noCheckLen do
        table.insert(mGangList, noCheckList[idx])
    end

    --距离近
    local disNearList = data.guildList1
    local disNearLen = #disNearList
    for idx = 1, disNearLen do
        table.insert(mGangList, disNearList[idx])
    end

    --高活跃
    local highActiveList = data.guildList2
    local highActiveLen = #highActiveList
    for idx = 1, highActiveLen do
        table.insert(mGangList, highActiveList[idx])
    end

    --计算三个区间
    mNoCheckRange[1] = 1
    mNoCheckRange[2] = noCheckLen

    mDisNearRange[1] = mNoCheckRange[2] + 1
    mDisNearRange[2] = mNoCheckRange[2] + disNearLen

    mHighActiveRange[1] = mDisNearRange[2] + 1
    mHighActiveRange[2] = mDisNearRange[2] + highActiveLen
end

--[[
    @desc: 获取到帮会推荐列表
    --@data: 
]]
local function OnGetRecommendList(data)
    if not data then
        return
    end
    InitGangList(data)
    if #mGangList > 0 then
        mGangListWidget:Show(mGangList)
    else
        --显示，没有帮会
    end
end

--[[
    @desc: 从gangid，找到对应的数据索引
    --@gangId: 
]]
local function GangId2DataIdx(gangId)
    for idx, gangData in ipairs(mGangList) do
        if gangData.id == gangId then
            return idx
        end
    end
    return -1
end

--[[
    @desc: 设置帮会的已申请状态
    --@gangId: 
]]
local function SetApplyed(gangId)
    local dataIdx = GangId2DataIdx(gangId)
    local gangItem = mGangListWidget:RealIdx2Item(dataIdx)
    if gangItem then
        gangItem:SetApplyed()
    end
end

--[[
    @desc: 申请成功，
    --@gangId: 帮会id
]]
local function OnJoinResult(gangId)
    if not gangId then
        return
    end
    SetApplyed(gangId)
end

local function RegEvent()
    GameEvent.Reg(EVT.GANG, EVT.GETRECOMMENTLIST, OnGetRecommendList)
    GameEvent.Reg(EVT.GANG, EVT.ONJOINRESULT, OnJoinResult)
end

local function UnRegEvent()
    GameEvent.UnReg(EVT.GANG, EVT.GETRECOMMENTLIST, OnGetRecommendList)
    GameEvent.UnReg(EVT.GANG, EVT.ONJOINRESULT, OnJoinResult)
end


function OnCreate(self)
    mSelf = self

    local gangListTrs = self:Find("Offset/temp/All/widget")
    mGangListWidget = ContentWidgetClick.new(gangListTrs, GangItem, mGangListEventIdBase, mGangListEventIdSpan, OnNor, OnSpec, OnClickSpan)
end

function OnEnable(self)
    RegEvent()

    ClearApplyedList()

    GangMgr.RequestRecommendList()
end

function OnDisable()
    UnRegEvent()


end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Gang_Recommend)
    elseif id == -101 then
        --一键申请
        GangMgr.RequestQuickJoin()
    elseif mGangListWidget:CheckEventIdIsIn(id) then
        mGangListWidget:OnClick(id)
    end
end


