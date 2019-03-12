local BaseIntentionProcessor = require("Logic/System/AIPet/IntentionProcessor/BaseIntentionProcessor");
local DefaultIntentionProcessor = class("DefaultIntentionProcessor",BaseIntentionProcessor); 

function DefaultIntentionProcessor:ctor()
    BaseIntentionProcessor.ctor(self);
end

function DefaultIntentionProcessor:Process(jsonData,respondeTime)
    BaseIntentionProcessor:Process(jsonData,respondeTime);
end

return DefaultIntentionProcessor;