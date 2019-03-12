--[[
    author:{hesinian}
    time:2018-12-28 10:38:37
]]
module("UI_Friend_Settings",package.seeall);

local mToggleStranger;
local mToggleOnline;
local mToggleLeave;
local mToggleClear;
local mInputReply;
local mDisableGo

-- mSettings.refuseAddFriend =;
-- mSettings.leaveStatus = false;
-- mSettings.msg = settings.msg;
-- mSettings.autoClearFriends = false;
local mSettings;

--只能保存所有的。
local function SaveSettings()
    mSettings.refuseAddFriend = mToggleStranger.value;
    mSettings.leaveStatus = not mToggleOnline.value;
    mSettings.autoClearFriends = mToggleClear.value;
    mSettings.msg = mInputReply.value;
    mDisableGo:SetActive(not mSettings.leaveStatus);
    FriendMgr.RequestSetFriendSettings();
end

local function SaveMsg()
    if mInputReply:HasIllegalChar() then
        TipsMgr.TipBykey("input_error_invalid_char");
        return;
    end
    local length = mInputReply:GetValueLength();
    local maxLength = ConfigData.GetIntValue("friend_auto_reply_length") or 20;--自动回复字数限制
    if length>maxLength then
        TipsMgr.TipByKey("input_error_length_com",maxLength);
        return;
    elseif length <= 0 then
        TipsMgr.TipByKey("friend_auto_reply_zero_default");--自动回复字数为0时采用默认回复
    end
    if mSettings.msg and mSettings.msg == mInputReply.value then return; end
    SaveSettings();
end

local function GetSettings()
    mSettings = FriendMgr.GetSettings();
    mToggleStranger.value = mSettings.refuseAddFriend;
    mToggleOnline.value = not mSettings.leaveStatus;
    mToggleLeave.value = mSettings.leaveStatus;
    mToggleClear.value = mSettings.autoClearFriends;
    mInputReply.value = mSettings.msg;
    mDisableGo:SetActive(not mSettings.leaveStatus);
end

function OnCreate(ui)
    mToggleStranger = ui:FindComponent("UIToggle","Offset/Tog_Refuse");
    mToggleOnline = ui:FindComponent("UIToggle","Offset/Tog_Online");
    mToggleLeave = ui:FindComponent("UIToggle","Offset/Tog_Leave");
    mToggleClear = ui:FindComponent("UIToggle","Offset/Tog_AutoClean");
    mInputReply = ui:FindComponent("LuaUIInput", "Offset/InputInfo");
    mDisableGo = ui:FindGo("Offset/InputInfo/DisableForground");
    GetSettings();
end

function OnEnable()
    EventDelegate.Set(mToggleStranger.onChange, EventDelegate.Callback(SaveSettings));
    EventDelegate.Set(mToggleOnline.onChange, EventDelegate.Callback(SaveSettings));
    EventDelegate.Set(mToggleClear.onChange, EventDelegate.Callback(SaveSettings));
    EventDelegate.Set(mInputReply.onDeSelect, EventDelegate.Callback(SaveMsg));
end

function OnDisable()

end

function OnDestroy()
    mToggleStranger = nil;
    mToggleOnline = nil;
    mToggleLeave = nil;
    mToggleClear = nil;
    mInputReply = nil;
end

function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_Settings);
    elseif id ~= 4 then
        SaveSettings();
    end
end


