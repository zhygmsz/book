module("UI_Shop_Main", package.seeall)

--组件
local mSelf
local mLeftTitleSp

--变量
local mEvents = {}
--当前右侧列表选中的按钮id
local mCurRightBtnId = -1
local mRightBtnNum = 4
local mRightBtnItemList = {}

local mLeftTitles = {
    [1] = "logo_biaoti_shanghui",
    [2] = "logo_biaoti_shanghui",
    [3] = "logo_biaoti_shanghui",
    [4] = "logo_biaoti_shanghui",
}

local mRightBtnNames = {
    [1] = { id = 1, content = "商会" },
    [2] = { id = 2, content = "摆摊" },
    [3] = { id = 3, content = "商城" },
    [4] = { id = 4, content = "充值" },
}

local mRightBtn2UI = {
    [1] = AllUI.UI_Shop_Commerce,  --商会
    --[2] = AllUI.UI_Shop_Stall,  --摆摊
    [3] = AllUI.UI_Shop_Store,  --商城
    --[4] = AllUI.UI_Shop_Pay,  --充值
}

local RightBtnItem = class("RightBtnItem")
function RightBtnItem:ctor(trs, funcOnClick)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._norLbl = trs:Find("nor/label"):GetComponent("UILabel")
    self._specLbl = trs:Find("spec/label"):GetComponent("UILabel")
    self._norLbl.text = ""
    self._specLbl.text = ""
    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")
    self._norGo:SetActive(true)
    self._specGo:SetActive(false)
    self._lis = UIEventListener.Get(self._gameObject)
    self._lis.onClick = UIEventListener.VoidDelegate(self.OnClick, self)

    --
    self._funcOnClick = funcOnClick

    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    --变量
    self._isShowed = false
    self._data = {}

    self:Hide()
end

function RightBtnItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

--[[
data = {
    id = 1, content = "商会"
}
--]]
function RightBtnItem:Show(data)
    self:SetVisible(true)

    self._data = data

    self._norLbl.text = self._data.content
    self._specLbl.text = self._data.content
end

function RightBtnItem:Hide()
    self:SetVisible(false)
end

function RightBtnItem:ToNor()
    if self._hasNorAndSpec then
        self._specGo:SetActive(false)
        self._norGo:SetActive(true)
    end
end

function RightBtnItem:ToSpec()
    if self._hasNorAndSpec then
        self._norGo:SetActive(false)
        self._specGo:SetActive(true)
    end
end

function RightBtnItem:OnClick(eventData)
    if self._funcOnClick then
        self._funcOnClick(self._data.id)
    end
end

function RightBtnItem:GetId()
    return self._data.id
end

--local方法
local function CheckRightBtnRange(id)
    if id and type(id) == "number" and 1 <= id and id <= mRightBtnNum then
        return true
    else
        return false
    end
end

local function ShowUI(id)
    if CheckRightBtnRange(id) then
        --打开UI
        if mRightBtn2UI[id] then
            UIMgr.ShowUI(mRightBtn2UI[id])
        end
    end
end

local function HideUI(id)
    if CheckRightBtnRange(id) then
        --关闭UI
        if mRightBtn2UI[id] then
            UIMgr.UnShowUI(mRightBtn2UI[id])
        end
    end
end

local function NorBtn(id)
    if CheckRightBtnRange(id) then
        if mRightBtnItemList[id] then
            mRightBtnItemList[id]:ToNor()
        end

        HideUI(id)
    end
end

local function SpecBtn(id)
    if CheckRightBtnRange(id) then
        if mRightBtnItemList[id] then
            mRightBtnItemList[id]:ToSpec()
        end

        ShowUI(id)
        --更改左侧title
        mLeftTitleSp.spriteName = mLeftTitles[id]
    end
end

local function OnClickRightBtn(id)
    if not CheckRightBtnRange(id) then
        return
    end
    if mCurRightBtnId == id then
        return
    end
    NorBtn(mCurRightBtnId)
    mCurRightBtnId = id
    SpecBtn(mCurRightBtnId)
end

local function RegEvent(self)
end

local function UnRegEvent(self)

end

function OnCreate(self)
    mSelf = self

    mLeftTitleSp = self:FindComponent("UISprite", "Offset/left/title")
    local trs = nil
    for idx = 1, mRightBtnNum do
        trs = self:Find("Offset/right/btn" .. tostring(idx))
        mRightBtnItemList[idx] = RightBtnItem.new(trs, OnClickRightBtn)
        mRightBtnItemList[idx]:Show(mRightBtnNames[idx])
    end
end

function OnEnable(self)
    RegEvent(self)

    --暂时先打开第一个按钮
    OnClickRightBtn(1)
end

function OnDisable(self)
    --关闭当前打开的界面
    NorBtn(mCurRightBtnId)
    mCurRightBtnId = -1

    UnRegEvent(self)
end

function OnClick(go, id)
    if id == -1 then
        --关闭按钮
        UIMgr.UnShowUI(AllUI.UI_Shop_Main)
    end
end