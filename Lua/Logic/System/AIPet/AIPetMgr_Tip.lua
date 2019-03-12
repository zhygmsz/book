--[[
    function:带确认按钮的信息
    author:{hesinian}
    time:2019-02-15 16:30:14
]]

module("AIPetMgr",package.seeall)
local AIPetTipQuestionnaire = require("Logic/System/AIPet/Tips/AIPetTipQuestionnaire");
local AIPetTipSystem = require("Logic/System/AIPet/Tips/AIPetTipSystem");

local msgList = {};

function Init_Tip()
end

function TipAIPetSystemByStr(str, okStr,okFunc,cancelStr,cancelFunc, caller)
    local data = AIPetTipSystem.new(str, okStr,okFunc,cancelStr,cancelFunc, caller);
    table.insert(msgList,1,data);
    GameEvent.Trigger(EVT.AIPET, EVT.AIPET_CONFIRM);
end

function TipAIPetquestionnaireByStr(str, okStr,okFunc,cancelStr,cancelFunc, caller)
    local data = AIPetTipQuestionnaire.new(str, okStr,okFunc,cancelStr,cancelFunc, caller);
    table.insert(msgList,1,data);
    GameEvent.Trigger(EVT.AIPET, EVT.AIPET_QUESTIONNAIRE);
end

function GetUnReadTipsCount()
    return #msgList;
end

function GetOneTip()
    return msgList[1];
end

function SetTipRead(tip)
    if not tip then return; end
    for i=1,#msgList do
        if msgList[i] == tip then
            table.remove( msgList, i);
            return;
        end
    end
end