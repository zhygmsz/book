local BaseIntentionProcessor = class("BaseIntentionProcessor") 

function BaseIntentionProcessor:ctor()

end

function BaseIntentionProcessor:Process(jsonData,respondeTime)
    GameLog.Log("%s is Processing: %s", self.__cname,jsonData);

    local answer = tostring(jsonData["answer"]);
    AIPetMgr.NewAIDialog(answer,respondeTime);
end

return BaseIntentionProcessor;