module("SpeechMgr",package.seeall)
local SDKSpeech = cyou.ldj.sdk.SDKSpeech;

--录音时状态参数
local mOnRecording = {};            
mOnRecording.guid = -1;            --本次录音的guid
mOnRecording.cancel = false;        --本次录音是否取消
mOnRecording.length = 0;            --最长录音时间
mOnRecording.func = nil;            --录音回调
mOnRecording.self = nil;            --录音回调对象

--播放时状态参数
local mOnPlaying = {};
mOnPlaying.guid = -1;               --本次播放的guid
mOnPlaying.func = nil;              --录音回调
mOnPlaying.self = nil;              --录音回调对象


local function OnSpeechEvent(eventType,arg1,arg2,arg3)
    if eventType == 2 then
        --没有录音机权限
        TipsMgr.TipByKey("speech_record_no_permission");
    elseif eventType == 3 then
        --无效语音
        TipsMgr.TipByKey("speech_record_invalid");
    elseif eventType == 4 then
        --说话时间太短
        TipsMgr.TipByKey("speech_record_time_too_short");
    elseif eventType == 5 then
        --有效语音
        --arg1表示录音识别出的文本
        --arg2表示录音识别出的长度,秒
        --arg3表示录音文件本地相对路径
        local speechText = arg1 or "";--nil
        local speechLength = arg2 or 0;
        local speechPath = arg3;
        local func = mOnRecording.func;
        local self = mOnRecording.self;
        local guid = mOnRecording.guid;
        mOnRecording.func = nil;
        mOnRecording.self = nil;
        mOnRecording.guid = -1;
        if func and self then
            func(self,speechText,speechLength,speechPath,guid);
        elseif func then
            func(speechText,speechLength,speechPath,guid);
        end
    elseif eventType == 6 then
        --录音取消
        TipsMgr.TipByKey("speech_record_cancel");
    elseif eventType == 7 then
        --播放结束
        local func = mOnPlaying.func;
        local self = mOnPlaying.self;
        local guid = mOnPlaying.guid;
        mOnPlaying.func = nil;
        mOnPlaying.self = nil;
        mOnPlaying.guid = -1;
        GameTimer.DeleteTimer(mOnPlaying.timerID)
        --arg1表示取消的方式, 0正常结束 1被打断
        if func and self then
            func(self,arg1,guid);
        elseif func then
            func(arg1,guid);
        end
    end
end

local function IsPlatformValid()
    if UnityEngine.Application.isMobilePlatform then
        return true;
    else
        return false;
    end
end

local function IsRecordGuidValid(guid)
    if not guid then 
        GameLog.LogError("stop record need guid"); 
        return false; 
    end
    if guid ~= mOnRecording.guid then 
        GameLog.LogError("your guid %s doesn't match %s", guid, mOnRecording.guid); 
        return false;
    end
    return true;
end

local function IsPlayGuidValid(guid)
    if not guid then 
        GameLog.LogError("stop audio need guid"); 
        return false; 
    end
    if guid ~= mOnPlaying.guid then 
        GameLog.LogError("your guid %s doesn't match %s", guid, mOnPlaying.guid); 
        return false;
    end
    return true;
end

function InitModule()
    local SG_APPID = "RDKO602";
    local SG_APPKEY = "zxb8w4q5";
    SDKSpeech.Instance:Init(SG_APPID,SG_APPKEY,"Caches/Voices/tmp");
    SDKSpeech.Instance:InitCallBack(OnSpeechEvent);
end

--开始录音
function StartRecord(func, self, length)
    local ret = SDKSpeech.Instance:StartRecord();
    if ret ~= -1 then
        --录音失败
        if ret == 4 then
            --当前正在播放其它录音
            SDKSpeech.Instance:StopAudio();
            return StartRecord(func, self, length);
        else
            --上次录音状态尚未结束
            TipsMgr.TipByKey("speach_record_all_to_often");
            return -1;
        end
    else
        --录音成功,修改当前录音状态
        mOnRecording.guid = mOnRecording.guid + 1;
        mOnRecording.cancel = false;
        mOnRecording.length = length or ConfigData.GetIntValue("speech_record_max_length") or 30;--秒
        mOnRecording.func = func;
        mOnRecording.self = self;
        --打开录音UI
        if AllUI.UI_Tip_Speech.enable then UIMgr.UnShowUI(AllUI.UI_Tip_Speech); end
        UIMgr.ShowUI(AllUI.UI_Tip_Speech,false,nil,nil,nil,true, mOnRecording.guid, mOnRecording.length);
        --返回本次录音GUID
        return mOnRecording.guid;
    end
end

--设置取消录音状态(手指在录音按钮上滑动时调用,修改取消状态)
function PrepareCancel(guid, state)
    if not IsRecordGuidValid(guid) or mOnRecording.cancel == state then return; end
    mOnRecording.cancel = state;
    GameEvent.Trigger(EVT.SPEECH, EVT.SPEECH_PREPARE_CANCEL, state);
end

--取消录音(直接取消,适用于强制打断录音的情况)
function CancelRecord(guid)
    if not IsRecordGuidValid(guid) then return; end
    SDKSpeech.Instance:CancelRecord();
end

--强制取消录音
function ForceCancelRecord()
    SDKSpeech.Instance:CancelRecord();
end

--停止录音
function StopRecord(guid)
    if not IsRecordGuidValid(guid) then return; end
    if mOnRecording.cancel then
        SDKSpeech.Instance:CancelRecord();
    else
        SDKSpeech.Instance:StopRecord();
    end
    UIMgr.UnShowUI(AllUI.UI_Tip_Speech);
end

--播放录音
function StartAudio(localPath,func,self)
    local ret = SDKSpeech.Instance:StartAudio(localPath);
    if ret ~= -1 then
        --播放失败
        if ret == -2 then
            --语音文件不存在
            TipsMgr.TipByKey("speech_play_file_not_exist");
            return -1;
        elseif ret == -3 then
            mOnPlaying.guid = mOnPlaying.guid + 1;
            mOnPlaying.func = func;
            mOnPlaying.self = self;
            mOnPlaying.timerID = GameTimer.AddTimer(0.1,1,OnSpeechEvent,nil,7,0)
            return mOnPlaying.guid;
        elseif ret == 4 then
            --正在播放其它语音
            SDKSpeech.Instance:StopAudio();
            return StartAudio(localPath,func,self);
        else
            --正在录音,无法播放语音
            TipsMgr.TipByKey("speech_play_conflict_with_record");
            return -1;
        end
    else
        --播放成功,修改播放状态
        mOnPlaying.guid = mOnPlaying.guid + 1;
        mOnPlaying.func = func;
        mOnPlaying.self = self;
        mOnPlaying.timerID = -1;
        return mOnPlaying.guid;
    end
end

--停止播放
function StopAudio(guid)
    if not IsPlayGuidValid(guid) then return end
    SDKSpeech.Instance:StopAudio();
end

--强制停止播放语音
function ForceStopAudio()
    SDKSpeech.Instance:StopAudio();
end

return SpeechMgr;