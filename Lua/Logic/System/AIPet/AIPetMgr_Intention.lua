-----主要用于语音回复结果json数据处理，和UI数据的管理
module("AIPetMgr", package.seeall)

local JSON = require("cjson");
local INTENTIONTYPE = {"BAIKE","CHAT","FAIRY","JOKE","WEATHER"};
local FILTERTYPE = {"TELEPHONE"};
local mIntentClassList = {};

function Init_Intention(debug)
    
    --无定义类型用BaseIntention来处理
    mIntentClassList["Default"] = require("Logic/System/AIPet/IntentionProcessor/DefaultIntentionProcessor").new();
    --已定义类型
    for i=1,#INTENTIONTYPE do
        local IntentionClass = require("Logic/System/AIPet/IntentionProcessor/"..INTENTIONTYPE[i].."IntentionProcessor");
        mIntentClassList[INTENTIONTYPE[i]] =IntentionClass.new();
    end
    --过滤类型用FilterIntention来处理
    local filterClass = require("Logic/System/AIPet/IntentionProcessor/FilterIntentionProcessor").new();
    for i=1,#FILTERTYPE do
        mIntentClassList[FILTERTYPE[i]] = filterClass;
    end
end


function ParseIntention(jsonData)
    local resultData = jsonData["semantic_result"];
    if not resultData then 
        GameLog.LogError("Wrong Intention Data ");
        return;
    end
    local respondeTime = resultData["sys_time"] or TimeUtils.SystemTimeStamp();
    local finalResult = resultData["final_result"];
    if (not finalResult) or #finalResult <= 0 then
        TipsMgr.TipByKey("AIPet_Responde_None_Answer");
        return;
    end
    --取第一个为最佳回复
    local typeStr = finalResult[1]["intention"];
    local intentionClass = mIntentClassList[typeStr] ;
    local ret = intentionClass and GameUtils.TryCatch(intentionClass.Process, intentionClass, finalResult[1],respondeTime) or false;
    if not ret then
        GameLog.LogError("Cann't be Processed by IntentionType:"..typeStr);
        intentionClass = mIntentClassList["Default"];
        GameUtils.TryCatch(intentionClass.Process, intentionClass, finalResult[1],respondeTime);
    end
end