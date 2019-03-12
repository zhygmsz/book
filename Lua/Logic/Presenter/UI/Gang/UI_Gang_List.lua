module("UI_Gang_List", package.seeall)

local ContentItemClick = require("Logic/Presenter/UI/Shop/ContentItemClick")
local ContentWidgetClick = require("Logic/Presenter/UI/Shop/ContentWidgetClick")

--组件
local mSelf
local mGangListWidget
local mSearchInput
local mGangNoticeLabel
local mAdminListWidget

--变量
local mGangListEventIdBase = 0
local mGangListEventIdSpan = 1

local mAdminListEventIdBase = 100
local mAdminListEventIdSpan = 1

--每次从mgr读取数据时，多一个引用，后续方便使用
local mGangList = nil
local mCurGangData = nil


local GangItem = class("GangItem", ContentItemClick)
function GangItem:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemClick.ctor(self, trs, itemIdx, eventIdSpanOffset)
    --组件
    self._sameCityGo = trs:Find("SameCity").gameObject
    self._name = trs:Find("Name"):GetComponent("UILabel")
    self._dis = trs:Find("Distance"):GetComponent("UILabel")
    self._cityName = trs:Find("City"):GetComponent("UILabel")
    self._level = trs:Find("Grade"):GetComponent("UILabel")
    self._number = trs:Find("Number"):GetComponent("UILabel")
    self._activity = trs:Find("Activity"):GetComponent("UILabel")

    self._bg1Go = trs:Find("bg1").gameObject
    self._bg2Go = trs:Find("bg2").gameObject

    --变量
end

function GangItem:InitUIEvent()
    self._uiEvent = self._transform:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = self._eventIdSpanOffset + 1
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

    self:DoShowSameCity()
    self._name.text = data.name
    --调用接口返回格式化后的距离
    self._dis.text = "1000KM"
    --根据坐标调用接口返回地点
    self._cityName.text = "北京市"
    self._level.text = tostring(data.level)
    self._number.text = tostring(data.curNumber) .. "/" .. tostring(data.maxNumber)
    self._activity.text = tostring(data.activeValue)

end

function GangItem:DoShowSameCity()
    --调用接口，返回两个坐标是否同城
    local isSame = false
    self._sameCityGo:SetActive(isSame)
end


local AdminItem = class("AdminItem", ContentItemClick)
function AdminItem:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemClick.ctor(self, trs, itemIdx, eventIdSpanOffset)
    --组件
    self._profSp = trs:Find("prof"):GetComponent("UISprite")
    self._name = trs:Find("Name"):GetComponent("UILabel")
    self._level = trs:Find("Grade"):GetComponent("UILabel")
    self._duty = trs:Find("Position"):GetComponent("UILabel")
    
    --变量
end

function AdminItem:InitUIEvent()
    self._uiEvent = self._transform:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = self._eventIdSpanOffset + 1
end


function AdminItem:Show(data, dataIdx)
    ContentItemClick.Show(self, data, dataIdx)

    --调用接口获取该职业对应的图标
    --self._profSp.spriteName = ""
    self._name.text = data.name
    self._level.text = tostring(data.level)
    self._duty.text = GangMgr.GetGangDutyName(data.title)
end


--local方法

local function OnClickSearch()

end

local function OnClickJoin()
    if not mCurGangData then
        return
    end
    GangMgr.RequestJoin(mCurGangData.id)
end

local function DoShowGangNotice(content)
    mGangNoticeLabel.text = content
end

local function DoShowAdminList(list)
    mAdminListWidget:Show(list)
end

local function OnNor(dataIdx)

end

local function OnSpec(dataIdx)
    mCurGangData = mGangList[dataIdx]
    if not mCurGangData then
        return
    end
    DoShowGangNotice(mCurGangData.manifesto)
    DoShowAdminList(mCurGangData.admins)
end

local function OnGetMoreGangList()
    mGangList = GangMgr.GetGangList()
    mGangListWidget:Show(mGangList)

    --自动选中第一个
    mGangListWidget:AutoSelectRealIdx(1)
end

local function RegEvent()
    GameEvent.Reg(EVT.GANG, EVT.GETMOREGANGLIST, OnGetMoreGangList)
end

local function UnRegEvent()
    GameEvent.UnReg(EVT.GANG, EVT.GETMOREGANGLIST, OnGetMoreGangList)
end


function OnCreate(self)
    mSelf = self

    local gangListTrs = self:Find("Offset/Left/widget")
    mGangListWidget = ContentWidgetClick.new(gangListTrs, GangItem, mGangListEventIdBase, mGangListEventIdSpan, OnNor, OnSpec)

    mGangNoticeLabel = self:FindComponent("UILabel","Offset/Right/Content/label")

    local adminListTrs = self:Find("Offset/Right/widget")
    mAdminListWidget = ContentWidgetClick.new(adminListTrs, AdminItem, mAdminListEventIdBase, mAdminListEventIdSpan, nil, nil)

    mSearchInput = self:FindComponent("LuaUIInput", "Offset/Left/Input")
end

function OnEnable(self)
    RegEvent()

    GangMgr.RequestGangList(1, 20)
end

function OnDisable(self)
    UnRegEvent()
end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Gang_List)
    elseif id == -101 then
        --推荐帮会
        UIMgr.ShowUI(AllUI.UI_Gang_Recommend)
    elseif id == -102 then
        --创建帮会
        if GangMgr.CheckHaveGang() then
            TipsMgr.TipByFormat("已经有帮会，不能创建")
        else
            UIMgr.ShowUI(AllUI.UI_Gang_Create)
        end
    elseif id == -103 then
        --搜索
        OnClickSearch()
    elseif id == -104 then
        --申请加入
        OnClickJoin()
    elseif id == -105 then
        --地图
    elseif mGangListWidget:CheckEventIdIsIn(id) then
        --ganglist区域
        mGangListWidget:OnClick(id)
    elseif mAdminListWidget:CheckEventIdIsIn(id) then
        --adminlist区域
        mAdminListWidget:OnClick(id)
    end
end
