module("TranslateMgr",package.seeall)
local SDKTranslate = cyou.ldj.sdk.SDKTranslate;

function InitModule()
    local BAIDU_APPID = "20160524000021917";
    local BAIDU_APPKEY = "rVK7DZap0nwSS5XVCEtA";
    SDKTranslate.Instance:Init(BAIDU_APPID,BAIDU_APPKEY);
end

return TranslateMgr;