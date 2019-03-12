--[[
    author:{hesinian}
    time:2018-12-28 12:52:59
]]

local UIFriendSetting = class("UIFriendSetting")

function UIFriendSetting:ctor(item,index)
    self._toggle = item:GetComponent("UIToggle");
    self._ActiveGo = item:Find("Active").gameObject;
    self._desc = item:Find("Name"):GetComponent("UILabel");
    item:GetComponent("UIEvent").id = index;
    
    self:Refresh();
end    

function UIFriendSetting:Refresh()
    local setType = self:GetTypeName();
    self._setType = setType;
    local key = string.format("friend_setting_%s_desc",setType);
    local desc = WordData.GetWordStringByKey(key);
    self._desc.text = desc;

    local set = UserData.GetFriendSettings(setType);
    if set==nil then
        set = self:GetDefaultValue();
    end
    self._value = set;
    self._ActiveGo:SetActive(set);
end

function UIFriendSetting:OnClick()
    self._value = not self._value;
    self:OnChangeValue(self._value);
end

function UIFriendSetting:OnChangeValue(value)
    self._value = value;
    self._ActiveGo:SetActive(value);
    UserData.SetFriendSettings(self._setType,value);
end

return UIFriendSetting;