module("UI_Welfare_Main", package.seeall)

--组件
local mSelf
local mLeftItemTemp
local mLeftPanel
local mLeftGrid
local mLeftScrollView

--变量
local mLastLeftItem  --上一个选中的leftitem
local mLeftItemList = {}
local mEvents = {}

--LeftItem
local LeftItem = class("LeftItem")
function LeftItem:ctor(trs, clickHandler)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._bg = trs:Find("bg"):GetComponent("UISprite")
    self._des = trs:Find("des"):GetComponent("UILabel")
    self._des.color = Color(1, 1, 1, 1)
    self._lis = UIEventListener.Get(self._bg.gameObject)
    self._lis.onClick = UIEventListener.VoidDelegate(self.OnClick, self)
    self._clickHandler = clickHandler

    --变量
    self._isShowed = false
    self._data = {}
    self._bgNameNormal = "button_qitian_1"
    self._bgNameSelected = "button_qitian_2"
    self._nameColorNormal = Color(57 / 255, 25 / 255, 22 / 255, 1)
    self._nameColorSelected = Color(1, 244 / 255, 216 / 255, 1)

    self:Hide()
end

function LeftItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function LeftItem:IsShowed()
    return self._isShowed
end

function LeftItem:Hide()
    self:SetVisible(false)
end

function LeftItem:Show(data)
    self._data = data

    self:SetVisible(true)
    self:SetId()
    self:SetName()
    self:OnSelected(false)
end

function LeftItem:SetId()
    self._transform.name = "item" .. tostring(self._data.id)
end

function LeftItem:SetName()
    self._des.text = self._data.name
end

function LeftItem:OnClick(eventData)
    if self._clickHandler then
        self._clickHandler(self._data.id)
    end
end

function LeftItem:OnSelected(selected)
    if selected then
        self._bg.spriteName = self._bgNameSelected
        self._des.color = self._nameColorSelected
    else
        self._bg.spriteName = self._bgNameNormal
        self._des.color = self._nameColorNormal
    end
end

function LeftItem:OnDisable()
    self:OnSelected(false)
    self:Hide()
end

function LeftItem:GetUI()
    return self._data.ui
end

function LeftItem:GetId()
    return self._data.id
end

--local方法
local function GetLeftItem(id)
    if not id then
        return
    end
    for _, item in ipairs(mLeftItemList) do
        if item and item:IsShowed() and item:GetId() == id then
            return item
        end
    end
end

local function ClickLeftItemHandler(id)
    local item = GetLeftItem(id)
    if item then
        local ui = item:GetUI()
        if not ui then
            TipsMgr.TipByKey("equip_share_not_support")
            return
        end

        if mLastLeftItem then
            if mLastLeftItem:GetId() == item:GetId() then
                return
            else
                UIMgr.UnShowUI(mLastLeftItem:GetUI())
                mLastLeftItem:OnSelected(false)
                mLastLeftItem = nil
            end
        end
        
        if ui then
            UIMgr.ShowUI(ui)
            item:OnSelected(true)
            mLastLeftItem = item
        end
    end
end

local function CreateItem()
    local trs = mSelf:DuplicateAndAdd(mLeftItemTemp, mLeftGrid.transform, 0)
    mLeftItemList[#mLeftItemList + 1] = LeftItem.new(trs, ClickLeftItemHandler)
    return mLeftItemList[#mLeftItemList]
end

local function GetUnShowedItem()
    for _, item in ipairs(mLeftItemList) do
        if item and not item:IsShowed() then
            return item
        end
    end
    return nil
end

local function GetItem()
    local item = GetUnShowedItem()
    if item then
        return item
    else
        return CreateItem()
    end
end

local function ShowLeftList()
    local list = WelfareMgr.GetLeftItemDataList()
    local item = nil
    for _, data in ipairs(list) do
        item = GetItem()
        if item then
            item:Show(data)
        end
    end

    mLeftGrid:Reposition()
end

local function AllLeftItemOnDisable()
    for _, item in ipairs(mLeftItemList) do
        if item and item:IsShowed() then
            item:OnDisable()
        end
    end
end

local function RegEvent(self)
end

local function UnRegEvent(self)

end

local function CustomUIGridSort(left, right)
    local leftName = left.name
    local rightName = right.name
    local leftNum = tonumber(string.sub(leftName, 5))
    local rightNum = tonumber(string.sub(rightName, 5))
    if leftNum < rightNum then
        return -1
    elseif leftNum > rightNum then
        return 1
    else
        return 0
    end
end

function OnCreate(self)
    mSelf = self

    mLeftItemTemp = self:Find("Offset/left/item")
    mLeftItemTemp.gameObject:SetActive(false)
    mLeftPanel = self:FindComponent("UIPanel", "Offset/left/scrollview")
    mLeftScrollView = self:FindComponent("UIScrollView", "Offset/left/scrollview")
    mLeftGrid = self:FindComponent("UIGrid", "Offset/left/scrollview/grid")
    mLeftGrid.onCustomSort = System.Comparison_UnityEngine_Transform(CustomUIGridSort)
end

function OnEnable(self)
    RegEvent(self)
    ShowLeftList()

    --目前，打开七天登录
    ClickLeftItemHandler(2)
end

function OnDisable(self)
    UnRegEvent(self)
    AllLeftItemOnDisable()
end

function OnClick(go, id)
    if id == -1 then
        --关闭按钮
        --先关闭当前打开的嵌套界面
        if mLastLeftItem then
            UIMgr.UnShowUI(mLastLeftItem:GetUI())
            mLastLeftItem:OnSelected(false)
            mLastLeftItem = nil
        end
        UIMgr.UnShowUI(AllUI.UI_Welfare_Main)
    elseif id == -11 then
        --mask

    end
end