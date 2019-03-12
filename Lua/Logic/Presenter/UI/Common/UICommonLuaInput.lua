--LuaInput的封装
UICommonLuaInput = class("UICommonLuaInput");

function UICommonLuaInput:ctor(luaUIInput,maxLength)
    self._input = luaUIInput;
    self._maxLength = maxLength;
    self._boxCollider = luaUIInput.transform:GetComponent("BoxCollider");
    self._label = luaUIInput.label;
    self._invalidStr = nil;
end
--InitText会用来进行重名检查
function UICommonLuaInput:SetInitText(text)
    self._initText = text;
    self._input.value = text;
end
--[[
@desc: 设置自定义的非法字符
author:{author}
time:2019-03-07 14:52:16
--@str:支持Lua.string的模式匹配 以,分隔 例如str = "a,%d,%s,%p"表示字母a 和 所有数字，空白符及标点都是非法字符
@return:
]]
function UICommonLuaInput:SetInvalidChars(str)
    self._invalidStr = string.split(str,",");
end

function UICommonLuaInput:SetSelect(state)
    self._input.isSelected = state;
end

function UICommonLuaInput:SetEnable(state)
    self._boxCollider.enabled = state;
end

function UICommonLuaInput:SetCallback(onSelect,onDeselect,caller)
    if onSelect then
        EventDelegate.Set(self._input.onSelect,EventDelegate.Callback(onSelect,caller));
    end
    if onDeselect then
        EventDelegate.Set(self._input.onDeSelect,EventDelegate.Callback(onDeselect,caller));
    end
end

function UICommonLuaInput:CheckValid()
    local str = self._input.value;
    if (str == nil) or (str == "") then 
        TipsMgr.TipByKey("input_error_length_zero");--字符长度为0 
        return false;
    end
    if self._input:HasIllegalChar() or self:HasInvalidChar(str) then
        TipsMgr.TipByKey("input_error_invalid_char");--非法字符
        return false;
    end
    local length = self._input:GetValueLength();
    if length>self._maxLength then
        TipsMgr.TipByKey("input_error_length_com",self._maxLength);--字符超过最大长度
        return false;
    end
    if self._initText and self._initText == self._input.value then
        TipsMgr.TipByKey("input_error_same_input");--重复输入
        return false;
    end 
    return true;
end

function UICommonLuaInput:HasInvalidChar(input)
    if not self._invalidStr then return false; end
    for i, char in ipairs(self._invalidStr) do
        local i,j = string.find(input, char);
        if i then return true; end
    end
    return false;
end
function UICommonLuaInput:SetValue(text)
    self._input:SetValue(text);
end

function UICommonLuaInput:GetValue()
    return self._input.value;
end


