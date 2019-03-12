local BaseIntentionProcessor = require("Logic/System/AIPet/IntentionProcessor/BaseIntentionProcessor");
local WEATHERIntentionProcessor = class("WEATHERIntentionProcessor",BaseIntentionProcessor); 

function WEATHERIntentionProcessor:ctor()
    BaseIntentionProcessor.ctor(self);
end

function WEATHERIntentionProcessor:Process(jsonData,respondeTime)
    GameLog.Log("%s is Processing: %s", self.__cname,jsonData);
    local date = tostring(jsonData["responde"]["result"]["date"]);
    local low = tostring(jsonData["responde"]["result"]["low"]);
    local high = tostring(jsonData["responde"]["result"]["high"]);
    local wind = tostring(jsonData["responde"]["result"]["wind"]);
    local description = tostring(jsonData["responde"]["result"]["description"]);
    local text = tostring(jsonData["responde"]["result"]["text"]);
    AIPetMgr.NewAIDialog(text,respondeTime);
end

return WEATHERIntentionProcessor;