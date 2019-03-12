module("AIPetMgr", package.seeall);
local mDialogs = {};
local AIPetDialogPet = require("Logic/System/AIPet/Dialogs/AIPetDialogPet");
local AIPetDialogPlayer = require("Logic/System/AIPet/Dialogs/AIPetDialogPlayer");

local mReadIndex = 0;

--主动发起闲聊
local mChatFrequenceKey = "AIPet_ChatFrequence";

function Init_Dialog()

end

function GetChatFrequenceLevel()
    local frequence = UserData.GetAIPetChatFrequency();
    return frequence and tonumber(frequence) or 1;
end

function SetChatFrequenceLevel(level)
    UserData.SetAIPetChatFrequency(level);
    GameEvent.Trigger(EVT.AIPET, EVT.AIPET_JOKE_FREQUENCE,level);
end

--闲聊间隔默认时间
function GetChatFrequenceTime()
    local settime = 30;--ConfigData.GetIntValue("AIPet_chat_frequence_des"..GetChatFrequenceLevel());
    return settime;
end

function GetDialogs()
    return mDialogs;
end

function NewPlayerDialog(text)
    local dialog = AIPetDialogPlayer.new(text);
    table.insert(mDialogs, dialog);
    GameEvent.Trigger(EVT.AIPET, EVT.DIALOG_PLAYER,dialog);
end

function NewAIDialog(text,time)
    local dialog = AIPetDialogPet.new(text,time);
    table.insert(mDialogs, dialog);
    GameEvent.Trigger(EVT.AIPET, EVT.DIALOG_AIPET,dialog);
end

function GetUnreadAIDialog()
    mReadIndex = mReadIndex+1;
    return mDialogs[mReadIndex];
end

function SetAllMessageRead()
    mReadIndex = #mDialogs;
end

function ClearMessageRecord()
    mDialogs = {};
    GameEvent.Trigger(EVT.AIPET, EVT.DIALOG_CLEAR_ALL);
end
