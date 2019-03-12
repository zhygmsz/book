--管理AIPet的语音输入，文本输入；
--将文字发送给特定服务器进行自然语言处理

module("AIPetMgr", package.seeall);
local mHttpKeyValue = {};
local mFixedParam;
local mRecordGUID;

function Init_Fairy()
    mHttpKeyValue["text"] = nil;
    mHttpKeyValue["appid"] = "LYSH5515";
    mHttpKeyValue["city"] = "北京";--接入LBS
    mHttpKeyValue["imei_no"] = "test1111";
    mHttpKeyValue["clearHistory"] = "1";
    mHttpKeyValue["time"] = nil;
    local temp = {};
    for key, value in pairs(mHttpKeyValue) do
        if value then
            table.insert(temp, key.."="..value);
        end
    end
    mFixedParam = table.concat(temp,'&');
end

local function RequestSendFairyText(input)
    local function OnSendFairyText(jsonData)
        if jsonData then AIPetMgr.ParseIntention(jsonData); end
    end
    local requestParam = string.format("%s&text=%s&time=%s",mFixedParam,input,TimeUtils.SystemTimeStamp());
    GameNet.SendToHttp(GameConfig.SEMANTIC_URL, requestParam, OnSendFairyText);
end

--发送文字,文字内容,是否隐藏(不显示)
function CallFairyText(text,hide)
    if not text or text == "" then
        TipsMgr.TipByKey("AI_Pet_Empty_Input");
        return;
    end
    GameLog.Log("CallFairyText %s",text);
    RequestSendFairyText(text);
    if not hide then 
        AIPetMgr.NewPlayerDialog(text);
    end
end

local function OnRecordFinished(speechText,speechLength,speechPath)
    GameLog.Log("SpeechText: %s",speechText);
    CallFairyText(speechText);
end

--开始录音 
function StartRecord()
    local length = ConfigData.GetIntValue("AIPet_Record_TimeLimit") or 15;--语音最长时间 单位秒;
    mRecordGUID = SpeechMgr.StartRecord(OnRecordFinished,nil,length);
    return mRecordGUID ~= -1;
end

--取消录音
function PrepareCancel(state)
    SpeechMgr.PrepareCancel(mRecordGUID,state);
end

--停止录音
function StopRecord()
    SpeechMgr.StopRecord(mRecordGUID);
end



