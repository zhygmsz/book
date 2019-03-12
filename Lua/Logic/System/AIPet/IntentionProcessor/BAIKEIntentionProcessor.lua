local BaseIntentionProcessor = require("Logic/System/AIPet/IntentionProcessor/BaseIntentionProcessor");
local BAIKEIntentionProcessor = class("BAIKEIntentionProcessor",BaseIntentionProcessor) ;

function BAIKEIntentionProcessor:ctor(jsonData)
    BaseIntentionProcessor.ctor(self);
end

function BAIKEIntentionProcessor:Process(jsonData,respondeTime)
    BaseIntentionProcessor:Process(jsonData,respondeTime);
end

return BAIKEIntentionProcessor;
