--成员列表
module("UI_Gang_MemberList", package.seeall)

local ContentItemClick = require("Logic/Presenter/UI/Shop/ContentItemClick")
local ContentWidgetClick = require("Logic/Presenter/UI/Shop/ContentWidgetClick")

--组件
local mSelf
local mMemberWidget

--变量
local mMemberEventIdBase = 0
local mMemberEventIdSpan = 1


local MemberItem = class("MemberItem", ContentItemClick)
function MemberItem:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemClick.ctor(self, trs, itemIdx, eventIdSpanOffset)
    --组件
    self._profSp = trs:Find("SameCity"):GetComponent("UISprite")
    self._name = trs:Find("Name"):GetComponent("UILabel")
    self._level = trs:Find("Grade"):GetComponent("UILabel")
    self._sect = trs:Find("Sects"):GetComponent("UILabel")
    self._duty = trs:Find("Post"):GetComponent("UILabel")
    self._week = trs:Find("Week"):GetComponent("UILabel")
    self._now = trs:Find("Now"):GetComponent("UILabel")
    self._history = trs:Find("History"):GetComponent("UILabel")    

    self._bg1Go = trs:Find("bg1").gameObject
    self._bg2Go = trs:Find("bg2").gameObject

    --变量

end

function MemberItem:InitUIEvent()
    self._uiEvent = self._transform:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = self._eventIdSpanOffset + 1
end

function MemberItem:DoShowBg()
    if self._dataIdx % 2 == 1 then
        --深色
        self._bg1Go:SetActive(true)
        self._bg2Go:SetActive(false)
    else
        --浅色
        self._bg1Go:SetActive(false)
        self._bg2Go:SetActive(true)
    end
end

function MemberItem:Show(data, dataIdx)
    ContentItemClick.Show(self, data, dataIdx)

    --self._profSp.spriteName = ""
    self._name.text = data.memInfo.name
    self._level.text = tostring(data.memInfo.level)
    self._sect.text = "门派"
    self._duty.text = GangMgr.GetGangDutyName(data.memInfo.title)
    self._week.text = tostring(data.memInfo.weekcontribution)
    self._now.text = tostring(data.memInfo.curcontribution)
    self._history.text = tostring(data.memInfo.curcontribution)

    self:DoShowBg()
end


--local方法
local function OnNor(dataIdx)

end

local function OnSpec(dataIdx)

end

--[[
    @desc: 获取到帮会成员列表
]]
local function OnGetMemberList()
    local memList = GangMgr.GetGangMemberList()
    mMemberWidget:Show(memList)

    --自动选择第一个
    mMemberWidget:AutoSelectRealIdx(1)
end

local function RegEvent()
    GameEvent.Reg(EVT.GANG, EVT.GETGANGMEMBERLIST, OnGetMemberList)
end

local function UnRegEvent()
    GameEvent.UnReg(EVT.GANG, EVT.GETGANGMEMBERLIST, OnGetMemberList)
end


function OnCreate(self)
    mSelf = self

    local memberTrs = self:Find("Offset/Right/widget")
    mMemberWidget = ContentWidgetClick.new(memberTrs, MemberItem, mMemberEventIdBase, mMemberEventIdSpan, OnNor, OnSpec)

end

function OnEnable(self)
    RegEvent()

    GangMgr.RequestGangMemberList()
end

function OnDisable(self)
    UnRegEvent()
end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == -100 then
        --脱离帮会
        GangMgr.RequestLeaveGang()
    elseif id == -101 then
        --我要换帮
    elseif id == -102 then
        --弹劾帮主
    elseif mMemberWidget:CheckEventIdIsIn(id) then
        mMemberWidget:OnClick(id)
    end
end