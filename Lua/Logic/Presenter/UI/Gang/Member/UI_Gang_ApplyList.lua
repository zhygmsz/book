--申请列表
module("UI_Gang_ApplyList", package.seeall)

local ContentItemClick = require("Logic/Presenter/UI/Shop/ContentItemClick")
local ContentWidgetClick = require("Logic/Presenter/UI/Shop/ContentWidgetClick")

--组件
local mSelf
local mApplyWidget
local mWidgetGo

local mNoApplyListGo

--变量
local mApplyEventIdBase = 0
local mApplyEventIdSpan = 5

--每次刷新数据，备份
local mApplyList
--一键处理后，使用该结构刷新UI
local mApplyEmptyList = {}


local ApplyItem = class("ApplyItem", ContentItemClick)
function ApplyItem:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemClick.ctor(self, trs, itemIdx, eventIdSpanOffset)
    --组件
    self._profSp = trs:Find("SameCity"):GetComponent("UISprite")
    self._name = trs:Find("Name"):GetComponent("UILabel")
    self._level = trs:Find("Grade"):GetComponent("UILabel")
    self._sect = trs:Find("Sects"):GetComponent("UILabel")
    
    self._bg1Go = trs:Find("bg1").gameObject
    self._bg2Go = trs:Find("bg2").gameObject

    --变量

end

function ApplyItem:InitUIEvent()
    self._uiEvent = self._transform:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = self._eventIdSpanOffset + 1
    
    local refuseUIEvent = self._transform:Find("RefuseBtn"):GetComponent("GameCore.UIEvent")
    refuseUIEvent.id = self._eventIdSpanOffset + 2

    local agreeUIEvent = self._transform:Find("AgreeBtn"):GetComponent("GameCore.UIEvent")
    agreeUIEvent.id = self._eventIdSpanOffset + 3
end

function ApplyItem:DoShowBg()
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

function ApplyItem:Show(data, dataIdx)
    ContentItemClick.Show(self, data, dataIdx)

    --self._profSp.spriteName = ""
    self._name.text = data.name
    self._level.text = data.level
    self._sect.text = "门派"

    self:DoShowBg()
end


--local方法
local function OnNor(dataIdx)

end

local function OnSpec(dataIdx)

end

--[[
    @desc: 
    --@dataIdx:
	--@spanIdx: 1item，2拒绝，3同意
]]
local function OnClickSpan(dataIdx, spanIdx)
    --根据spanIdx判断触发的是哪一个事件

    local applyData = mApplyList[dataIdx]
    if not applyData then
        return
    end
    local targetRoleId = applyData.roleid
    local reply = 0
    if spanIdx == 2 then
        reply = 2
    elseif spanIdx == 3 then
        reply = 1
    end
    GangMgr.RequestReplyJoin(targetRoleId, reply)
end

local function DoShowWidget(applyList)
    mApplyList = applyList
    if not applyList then
        return
    end
    if #applyList > 0 then
        mWidgetGo:SetActive(true)
        mNoApplyListGo:SetActive(false)
        mApplyWidget:Show(applyList)
    else
        mWidgetGo:SetActive(false)
        mNoApplyListGo:SetActive(true)
    end
end

local function OnGetApplyList(applyList)
    if not applyList then
        return
    end
    DoShowWidget(applyList)
end

--[[
    @desc: 根据targetroleid，从申请列表删除
]]
local function RemoveFromApplyList(data)
    local existIdx = nil
    for idx, applyData in ipairs(mApplyList) do
        if applyData.roleid == data.tarroleid then
            existIdx = idx
            break
        end
    end
    if existIdx then
        table.remove(mApplyList, existIdx)
    else
        GameLog.LogError("UI_Gang_ApplyList.RemoveFromApplyList -> existIdx is nil")
    end
end

--[[
    @desc: 收到一个入会申请处理返回，同步mApplyList列表，并刷UI
    --@data: 
]]
local function OnGetReplyJoinData(data)
    RemoveFromApplyList(data)
    --刷新UI
    DoShowWidget(mApplyList)
end

--[[
    @desc: 一键处理入会请求成功
    使用空表刷新UI，空表复用
]]
local function OnQuickReplyJoin()
    DoShowWidget(mApplyEmptyList)
end

local function RegEvent()
    GameEvent.Reg(EVT.GANG, EVT.GETGANGAPPLYLIST, OnGetApplyList)
    GameEvent.Reg(EVT.GANG, EVT.GETREPLYJOINDATA, OnGetReplyJoinData)
    GameEvent.Reg(EVT.GANG, EVT.ONQUICKREPLYJOIN, OnQuickReplyJoin)
end

local function UnRegEvent()
    GameEvent.UnReg(EVT.GANG, EVT.GETGANGAPPLYLIST, OnGetApplyList)
    GameEvent.UnReg(EVT.GANG, EVT.GETREPLYJOINDATA, OnGetReplyJoinData)
    GameEvent.UnReg(EVT.GANG, EVT.ONQUICKREPLYJOIN, OnQuickReplyJoin)
end


function OnCreate(self)
    mSelf = self

    local applyTrs = self:Find("Offset/widget")
    mApplyWidget = ContentWidgetClick.new(applyTrs, ApplyItem, mApplyEventIdBase, mApplyEventIdSpan, OnNor, OnSpec, OnClickSpan)

    mWidgetGo = self:Find("Offset/widget").gameObject
    mNoApplyListGo = self:Find("Offset/NoApplication").gameObject
end

function OnEnable(self)
    RegEvent()

    GangMgr.RequestApplyList()
end

function OnDisable(self)
    UnRegEvent()
end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == -100 then
        --刷新列表
        GangMgr.RequestApplyList()
    elseif id == -101 then
        --一键拒绝
        GangMgr.RequestQuickReplyJoin(2)
    elseif id == -102 then
        --一键同意
        GangMgr.RequestQuickReplyJoin(1)
    elseif mApplyWidget:CheckEventIdIsIn(id) then
        mApplyWidget:OnClick(id)
    end
end