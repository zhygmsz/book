module("RealTimeSpeechMgr",package.seeall)
local SDKGCloud = cyou.ldj.sdk.SDKGCloud;

local function OnGCloudEvent(eventID,errCode)

end

function InitModule()
    local GCLOUD_APPID = "1258696522";
    local GCLOUD_APPKEY = "65b59522c72b3fd9fd353fb4e65dbd49";
    local GCLOUD_APPURL = "udp://cn.voice.gcloudcs.com:10001";
    SDKGCloud.Instance:Init(GCLOUD_APPID,GCLOUD_APPKEY,GCLOUD_APPURL);
    SDKGCloud.Instance:InitCallBack(OnGCloudEvent);
end

--进入队伍实时语音
function JoinTeamRoom(roomName)
    SDKGCloud.Instance:JoinTeamRoom(roomName);
end

--进入帮派实时语音
function JoinNationalRoom(roomName,canSpeak)
    SDKGCloud.Instance:JoinNationalRoom(roomName,canSpeak);
end

--退出实时语音
function QuitRoom()
    SDKGCloud.Instance:QuitRoom();
end

--打开扬声器
function OpenSpeaker()
    SDKGCloud.Instance:OpenSpeaker();
end

--关闭扬声器
function CloseSpeaker()
    SDKGCloud.Instance:CloseSpeaker();
end

--打开麦克风
function OpenMic()
    SDKGCloud.Instance:OpenMic();
end

--关闭麦克风
function CloseMic()
    SDKGCloud.Instance:CloseMic();
end

return RealTimeSpeechMgr;