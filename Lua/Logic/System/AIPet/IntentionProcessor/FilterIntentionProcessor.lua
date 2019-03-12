local BaseIntentionProcessor = require("Logic/System/AIPet/IntentionProcessor/BaseIntentionProcessor");
local FilterIntentionProcessor = class("FilterIntentionProcessor",BaseIntentionProcessor); 

function FilterIntentionProcessor:ctor()
    BaseIntentionProcessor.ctor(self);
end

function FilterIntentionProcessor:Process(jsonData,respondeTime)
    GameLog.Log("%s is Processing: %s", self.__cname,jsonData);
    local intentionType = jsonData["intention"]
    GameLog.LogError("No Intention Type: %s",intentionType);
    AIPetMgr.NewAIDialog(WordData.GetWordStringByKey("No_Intention_Processor"), respondeTime);--没办法回答的问题
end

return FilterIntentionProcessor;