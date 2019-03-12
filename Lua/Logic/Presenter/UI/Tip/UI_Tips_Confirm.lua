module("UI_Tips_Confirm", package.seeall)

--组件
local mSelf
local mRoot
local mConfirmWidget

--变量
local mEvents = {}
local mOriginLayer
local mOriginDepth

local mOriginOkFunc
local mOriginCancelFunc

local ConfirmWidget = class("ConfirmWidget")
function ConfirmWidget:ctor(trs, onNewLayer, onResetLayer, ui, path)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._ui = ui
    path = path .. "/"
    self._path = path

    self._offset = trs:Find("offset")
    self._content = ui:FindComponent("UILabel", path .. "offset/content")
    self._ok = trs:Find("offset/okbtn")
    self._okDes = ui:FindComponent("UILabel", path .. "offset/okbtn/label")
    self._okBtn = self._ok.gameObject
    self._cancel = trs:Find("offset/cancelbtn")
    self._cancelDes = ui:FindComponent("UILabel", path .. "offset/cancelbtn/label")
    self._cancelBtn = self._cancel.gameObject
    self._closeBtn = ui:FindGo(path .. "offset/closebtn")
    self._closeBtn:SetActive(false)

    self._okLis = UIEventListener.Get(self._okBtn)
    self._okLis.onClick = UIEventListener.VoidDelegate(self.OnOkClick, self)
    self._cancelLis = UIEventListener.Get(self._cancelBtn)
    self._cancelLis.onClick = UIEventListener.VoidDelegate(self.OnCancelClick, self)
    self._closeLis = UIEventListener.Get(self._closeBtn)
    self._closeLis.onClick = UIEventListener.VoidDelegate(self.OnCloseClick, self)

    --变量
    self._isShowed = false
    self._okPos = self._okBtn.transform.localPosition
    self._cancelPos = self._cancelBtn.transform.localPosition
    self._middlePos = Vector3(0, self._okPos.y, self._okPos.z)
    self._data = {}
    self._waitList = {}
    self._onNewLayer = onNewLayer
    self._onResetLayer = onResetLayer
    self._layerChanged = false
    self._defaultOkText = "确定"
    self._defaultCancelText = "取消"
end

function ConfirmWidget:OnOkClick(eventData)
    if self._data and self._data.okFunc and type(self._data.okFunc) == "function" then
        self._data.okFunc()
    end
    self:ResetLayer()
    self:CheckNext()
end

function ConfirmWidget:OnCancelClick(eventData)
    if self._data and self._data.cancelFunc and type(self._data.cancelFunc) == "function" then
        self._data.cancelFunc()
    end
    self:ResetLayer()
    self:CheckNext()
end

function ConfirmWidget:OnCloseClick(eventData)
    if self._data and self._data.closeFunc and type(self._data.closeFunc) == "function" then
        self._data.closeFunc()
    end
    self:ResetLayer()
    self:CheckNext()
end

function ConfirmWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function ConfirmWidget:InitStyle()
    --如果style是nil，则按照all规则
    if not self._data.style then
        self._data.style = WordData_pb.TipTypeData.STYLE_ALL
    end
    if self._data.style == WordData_pb.TipTypeData.STYLE_OK then
        self._okBtn:SetActive(true)
        self._cancelBtn:SetActive(false)
        self._ok.localPosition = self._middlePos
    elseif self._data.style == WordData_pb.TipTypeData.STYLE_CANCEL then
        self._okBtn:SetActive(false)
        self._cancelBtn:SetActive(true)
        self._cancel.localPosition = self._middlePos
    elseif self._data.style == WordData_pb.TipTypeData.STYLE_ALL then
        self._okBtn:SetActive(true)
        self._cancelBtn:SetActive(true)
        self._ok.localPosition = self._okPos
        self._cancel.localPosition = self._cancelPos
    end

    --self._closeBtn:SetActive(self._data.showClose)

    self:InitBtnDes()
end

function ConfirmWidget:InitBtnDes()
    if self._data.style == WordData_pb.TipTypeData.STYLE_OK then
        if self._data.okStr and type(self._data.okStr) == "string" then
            self._okDes.text = self._data.okStr
        else
            self._okDes.text = self._defaultOkText
        end
    elseif self._data.style == WordData_pb.TipTypeData.STYLE_CANCEL then
        if self._data.cancelStr and type(self._data.cancelStr) == "string" then
            self._cancelDes.text = self._data.cancelStr
        else
            self._cancelDes.text = self._defaultCancelText
        end
    elseif self._data.style == WordData_pb.TipTypeData.STYLE_ALL then
        if self._data.okStr and type(self._data.okStr) == "string" then
            self._okDes.text = self._data.okStr
        else
            self._okDes.text = self._defaultOkText
        end
        if self._data.cancelStr and type(self._data.cancelStr) == "string" then
            self._cancelDes.text = self._data.cancelStr
        else
            self._cancelDes.text = self._defaultCancelText
        end
    end
end

function ConfirmWidget:ResetLayer()
    if self._layerChanged and self._onResetLayer and type(self._onResetLayer) == "function" then
        self._onResetLayer()
    end
end

--检测是否需要修改layer
function ConfirmWidget:CheckNewLayer()
    self._layerChanged = false

    if self._data.newLayer and type(self._data.newLayer) == "number" 
    and self._data.newDepth and type(self._data.newDepth) == "number" then
        if self._onNewLayer and type(self._onNewLayer) == "function" then
            self._onNewLayer(self._data.newLayer, self._data.newDepth)
            self._layerChanged = true
        end
    end
end

function ConfirmWidget:DoShow(data)
    self:SetVisible(true)
    self._data = data

    self:CheckNewLayer()

    self:InitStyle()
    self._content.text = self._data.content
end

--[[
data =
{
    content = content,
    style = style,
    okFunc = okFunc,
    cancelFunc = cancelFunc,
    okStr = okStr,
    cancelStr = cancelStr,
    newLayer = newLayer,
    newDepth = newDepth,
    --closeFunc = closeFunc,
    --showClose = showClose,
}
--]]
function ConfirmWidget:Show(data)
    if self:IsShowed() then
        table.insert(self._waitList, data)
    else
        self:DoShow(data)
    end
end

function ConfirmWidget:CheckNext()
    if #self._waitList > 0 then
        local data = table.remove(self._waitList, 1)
        self:DoShow(data)
    else
        self:Hide()
    end
end

function ConfirmWidget:Hide()
    self:SetVisible(false)
end

function ConfirmWidget:IsShowed()
    return self._isShowed
end

--local方法
local function ResetLayer()
    UIMgr.ChangeLayer(AllUI.UI_Tips_Confirm, mOriginLayer, mOriginDepth)
end

local function NewLayer(newLayer, newDepth)
    UIMgr.ChangeLayer(AllUI.UI_Tips_Confirm, newLayer, newDepth)
end

local function OnShowConfirm(data)
    if data then
        mConfirmWidget:Show(data)
    end
end

--强制关闭当前显示的确认框
local function OnCloseConfirm()
    mConfirmWidget:OnCloseClick()
end

local function RegEvent(self)
    GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_SHOWCONFIRM, OnShowConfirm)
    GameEvent.Reg(EVT.UITIPS, EVT.UITIPS_CLOSECONFIRM, OnCloseConfirm)
end

local function UnRegEvent(self)
    GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_SHOWCONFIRM,OnShowConfirm)
    GameEvent.UnReg(EVT.UITIPS, EVT.UITIPS_CLOSECONFIRM,OnCloseConfirm)
end

function OnCreate(self)
    mSelf = self
    mRoot = self:Find("confirmroot")
    mConfirmWidget = ConfirmWidget.new(mRoot, NewLayer, ResetLayer, self, "confirmroot")
    mConfirmWidget:Hide()

    mOriginLayer = AllUI.UI_Tips_Confirm.layer
    mOriginDepth = AllUI.UI_Tips_Confirm.depth
end

function OnEnable(self)
    RegEvent(self)
end

function OnDisable(self)
    UnRegEvent(self)
end