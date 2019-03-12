--[[
    author:{hesinian}
    time:2018-12-28 12:52:59
]]
local UIFriendSetting = require("Logic/Presenter/UI/Friend/Setting/UIFriendSetting");
local UIFriendSettingOnline = class("UIFriendSettingOnline",UIFriendSetting)

function UIFriendSettingOnline:ctor(item,index)
    self.super.ctor(self, item,index);
end    

function UIFriendSettingOnline:GetTypeName()
    return "Online";
end

function UIFriendSettingOnline:GetDefaultValue()
    return true;
end

function UIFriendSettingOnline:OnChangeValue(value)
    self.super.OnChangeValue(self,value);
    --做自己相关的东西
end

return UIFriendSettingOnline;