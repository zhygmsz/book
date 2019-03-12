--[[
    author:{hesinian}
    time:2018-12-28 12:52:59
]]
local UIFriendSetting = require("Logic/Presenter/UI/Friend/Setting/UIFriendSetting");
local UIFriendSettingApply = class("UIFriendSettingApply",UIFriendSetting)

function UIFriendSettingApply:ctor(item,index)
    self.super.ctor(self, item,index);
end    

function UIFriendSettingApply:GetTypeName()
    return "Apply";
end

function UIFriendSettingApply:GetDefaultValue()
    return true;
end

function UIFriendSettingApply:OnChangeValue(value)
    self.super.OnChangeValue(self,value);
    --做自己相关的东西
end

return UIFriendSettingApply;