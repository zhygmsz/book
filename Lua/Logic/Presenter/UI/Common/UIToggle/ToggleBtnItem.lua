--基于UIEvent的自定义UIToggle
local ToggleBtnItem = class("ToggleBtnItem")

function ToggleBtnItem:ctor(trs, data)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    local norLabel = trs:Find("nor/label");
    if norLabel then
        self._norLbl = norLabel:GetComponent("UILabel");
    end
    local speLabel = trs:Find("spec/label");
    if speLabel then
        self._specLbl = speLabel:GetComponent("UILabel");
    end

    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")

    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    self._uiEvent = trs:GetComponent("GameCore.UIEvent")

    --变量
    self:ResetData(data)
    self._isShowed = false
    self._isNor = true

    --初始化
    self:ToNor()
    self:Hide()
end

--[[
data = {
    eventId = 1, content = "btnName"
}
--]]
function ToggleBtnItem:ResetData(data)
    self._data = data

    self._uiEvent.id = data.eventId
    if self._norLbl then
        if self._data.content then
            self._norLbl.text = self._data.content
        end
    end
    if self._specLbl then
        if self._data.content then
            self._specLbl.text = self._data.content
        else
            self._data.content = self._specLbl.text;
        end
    end
end

function ToggleBtnItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function ToggleBtnItem:Show()
    self:SetVisible(true)
end

function ToggleBtnItem:Hide()
    self:SetVisible(false)
end

function ToggleBtnItem:ToNor()
    if self._hasNorAndSpec then
        self._specGo:SetActive(false)
        self._norGo:SetActive(true)
    end

    self._isNor = true
end

function ToggleBtnItem:ToSpec()
    if self._hasNorAndSpec then
        self._norGo:SetActive(false)
        self._specGo:SetActive(true)
    end

    self._isNor = false
end

function ToggleBtnItem:GetEventId()
    return self._data.eventId
end

function ToggleBtnItem:GetData()
    return self._data
end

function ToggleBtnItem:IsNor()
    return self._isNor
end

function ToggleBtnItem:OnDestroy()
    self:Hide()
end

return ToggleBtnItem