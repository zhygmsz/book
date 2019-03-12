module("CosMgr",package.seeall)
local SDKCos = cyou.ldj.sdk.SDKCos;
local mCallBacks = {};

local function OnCosEvent(eventName,errCode,localPath,remotePath)
    local call = mCallBacks[1];
    table.remove(mCallBacks,1);
    --错误码
    if errCode == "-1" then
        TipsMgr.TipByKey("cos_upload_maxsize");
    elseif errCode == "-2" then
        TipsMgr.TipByKey("cos_upload_not_exist");
    end
    --下载或者上传完成回调
    if call.self then
        call.onFinish(call.self,localPath,remotePath,errCode == "0");
    else
        call.onFinish(localPath,remotePath,errCode == "0");
    end
    --检查是否有等待中的
    local next = mCallBacks[1];
    if next then
        if next.remoteDir then SDKCos.Instance:UploadFile(next.localPath,next.remoteDir); 
        else SDKCos.Instance:DownloadFile(next.remoteURL,next.localDir); end
    end
end

function InitModule()
    local COS_APPID = "1255801262";
    local COS_BUCKET_NAME = "ldj";
    local COS_SECRET_ID = "AKID9FD3mJbqqibbVHrJZeg2FJCvY4Y4NZXJ";
    local COS_SECRET_KEY = "mjYFl7GGmJtNkw1v1xqcHk3FHJBvTp9K";
    local COS_REGION = "bj";
    local COS_DEBUG = false;
    local COS_SIZE = 1024 * 1024 * 2;
    SDKCos.Instance:Init(COS_APPID,COS_BUCKET_NAME,COS_SECRET_ID,COS_SECRET_KEY,COS_REGION,COS_DEBUG,COS_SIZE);
    SDKCos.Instance:InitCallBack(OnCosEvent);
end

--[[
上传文件到云服务器,同时只有一个文件在上传
localPath           本地相对路径,相对于Application.persistentDataPath
remoteDir           文件保存目录
onFinish            上传完成回调(localPath,remotePath,successFlag)
self                回调所属对象
--]]
function UploadFile(localPath,remoteDir,onFinish,self)
    local call = {};
    call.localPath = localPath;
    call.remoteDir = remoteDir;
    call.onFinish = onFinish;
    call.self = self;
    table.insert(mCallBacks,call);
    if #mCallBacks > 1 then return end
    SDKCos.Instance:UploadFile(localPath,remoteDir);
end

--[[
上传进度
localPath           目标文件相对路径
return              -1等待中 0-1上传中
--]]
function UploadProgress(localPath)
    local call = mCallBacks[1];
    if call and call.localPath ~= localPath then return -1 end
    return SDKCos.Instance:UploadProgress();
end

--[[
从云服务器下载文件,同时只有一个文件在下载
remoteURL           目标文件URL
localDir            本地保存目录
onFinish            下载完成回调(localPath,remotePath,successFlag)
self                回调所属对象
--]]
function DownloadFile(remoteURL,localDir,onFinish,self)
    local call = {};
    call.remoteURL = remoteURL;
    call.localDir = localDir;
    call.onFinish = onFinish;
    call.self = self;
    table.insert(mCallBacks,call);
    if #mCallBacks > 1 then return end
    SDKCos.Instance:DownloadFile(remoteURL,localDir);
end

--[[
从云服务器删除文件
remoteURL           目标文件URL
--]]
function DeleteFile(remoteURL)
    SDKCos.Instance:DeleteFile(remoteURL);
end

return CosMgr;