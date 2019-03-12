module("SdkMgr",package.seeall)

function InitModule()
    --文件转发
    require("Logic/System/Sdk/CosMgr").InitModule();
    --搜狗语音
    require("Logic/System/Sdk/SpeechMgr").InitModule();
    --实时语音
    require("Logic/System/Sdk/RealTimeSpeechMgr").InitModule();
    --百度翻译
    require("Logic/System/Sdk/TranslateMgr").InitModule();
    --图片审核
    require("Logic/System/Sdk/PornDetectMgr").InitModule();
    --图片选择
    require("Logic/System/Sdk/PhotoMgr").InitModule();
    --分享
    require("Logic/System/Sdk/ShareMgr").InitModule();
    --音频
    require("Logic/System/Sdk/AudioMgr").InitModule();
end

function InitModuleOnLogin(playerID)
    cyou.ldj.sdk.SDKCommon.UNIQUE_NAME = (tostring(playerID));
end

return SdkMgr;