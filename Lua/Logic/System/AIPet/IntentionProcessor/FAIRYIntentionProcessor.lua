local BaseIntentionProcessor = require("Logic/System/AIPet/IntentionProcessor/BaseIntentionProcessor");
local FAIRYIntentionProcessor = class("FAIRYIntentionProcessor",BaseIntentionProcessor); 

function FAIRYIntentionProcessor:ctor()
    BaseIntentionProcessor.ctor(self);
end

function FAIRYIntentionProcessor:Process(jsonData,respondeTime)
    BaseIntentionProcessor:Process(jsonData,respondeTime);
    local cmd = tostring(jsonData["detail"]["cmd"]);
    AIPetMgr.NewAction(cmd);
end

return FAIRYIntentionProcessor;
