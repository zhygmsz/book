--基于UIEvent的自定义UIToggle
ToggleItemGroup = class("ToggleItemGroup")

local ToggleBtnItem = require("Logic/Presenter/UI/Common/UIToggle/ToggleBtnItem")

function ToggleItemGroup:ctor(funcOnNor, funcOnSpec,caller)
    --变量
    self._funcOnNor = funcOnNor
    self._funcOnSpec = funcOnSpec
    self._caller = caller;

    self._itemList = {}
    --当前选中的id
    self._curEventId = nil
end

function ToggleItemGroup:AddItem(trs, data)
    self._itemList[data.eventId] = ToggleBtnItem.new(trs, data)
    self._itemList[data.eventId]:Show()
end

function ToggleItemGroup:InvokeOnNor(eventId)
    if self._funcOnNor then
        if self._caller then
            self._funcOnNor(self._caller,eventId);
        else
            self._funcOnNor(eventId)
        end
    end
end

function ToggleItemGroup:InvokeOnSpec(eventId)
    if self._funcOnSpec then
        if self._caller then
            self._funcOnSpec(self._caller,eventId);
        else
            self._funcOnSpec(eventId)
        end
    end
end

function ToggleItemGroup:ToNor(eventId, throwEvent)
    if eventId and self._itemList[eventId] then
        self._itemList[eventId]:ToNor()

        if throwEvent then
            self:InvokeOnNor(eventId)
        end
    end
end

function ToggleItemGroup:ToSpec(eventId, throwEvent)
    if eventId and self._itemList[eventId] then
        self._itemList[eventId]:ToSpec()

        if throwEvent then
            self:InvokeOnSpec(eventId)
        end
    end
end

--[[
    @desc: 刷新
    --@data: 
]]
function ToggleItemGroup:UpdateItem(data)
    if data and data.eventId and self._itemList[data.eventId] then
        self._itemList[data.eventId]:ResetData(data)
    end
end

function ToggleItemGroup:CheckIsValid(eventId)
    local isValid = false

    if eventId and self._itemList[eventId] then
        isValid = true
    end

    return isValid
end

--[[
    @desc: 来自UI.OnClick方法的eventid
]]
function ToggleItemGroup:OnClick(eventId)
    if not self:CheckIsValid(eventId) then
        return
    end
    
    if self._curEventId and self._curEventId == eventId then
        return
    end

    self:ToNor(self._curEventId, true)
    self._curEventId = eventId
    self:ToSpec(self._curEventId, true)
end

--[[
    @desc: 外部手动清空当前选中状态
]]
function ToggleItemGroup:ClearCurEventId(silence)

    self:ToNor(self._curEventId, not silence);

    self._curEventId = nil
end

--[[
    @desc: 来自于UI.OnDisable
]]
function ToggleItemGroup:OnDisable()
    self:ClearCurEventId()
end

--[[
    @desc: 来自于UI.OnDestroy
]]
function ToggleItemGroup:OnDestroy()
    self._itemList = {}
end

return ToggleItemGroup
