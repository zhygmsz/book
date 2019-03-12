module("PornDetectMgr",package.seeall)
local SDKPornDetect = cyou.ldj.sdk.SDKPornDetect;

local function OnPornDetectFinish()

end

function InitModule()
    local COS_APPID = "1255801262";
    local COS_BUCKET_NAME = "ldj";
    local COS_SECRET_ID = "AKID9FD3mJbqqibbVHrJZeg2FJCvY4Y4NZXJ";
    local COS_SECRET_KEY = "mjYFl7GGmJtNkw1v1xqcHk3FHJBvTp9K";
    SDKPornDetect.Instance:Init(COS_APPID,COS_SECRET_ID,COS_SECRET_KEY,COS_BUCKET_NAME);
    SDKPornDetect.Instance:InitCallBack(OnPornDetectFinish);
end

function PornDetectSingleFile(url)
    --TODO 鉴黄参数
    SDKPornDetect.Instance:BeginDetect(0,0,0);
    SDKPornDetect.Instance:Detect(url);
    SDKPornDetect.Instance:EndDetect();
end

function PornDetectMultiFile(urls)
    --TODO 鉴黄参数
    SDKPornDetect.Instance:BeginDetect(0,0,0);
    for _,url in ipairs(urls) do
        SDKPornDetect.Instance:Detect(url);
    end
    SDKPornDetect.Instance:EndDetect();
end

return PornDetectMgr;