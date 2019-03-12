local BaseIntentionProcessor = require("Logic/System/AIPet/IntentionProcessor/BaseIntentionProcessor");
local CHATIntentionProcessor = class("CHATIntentionProcessor",BaseIntentionProcessor) ;

function CHATIntentionProcessor:ctor(jsonData)
    BaseIntentionProcessor.ctor(self);
end

function CHATIntentionProcessor:Process(jsonData,respondeTime)
    BaseIntentionProcessor:Process(jsonData,respondeTime);
end

return CHATIntentionProcessor;
