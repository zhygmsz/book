module("PhotoMgr",package.seeall)
local SDKPhoto = cyou.ldj.sdk.SDKPhoto;

local mOnTakeFinish = {};
local mOnClipFinish = {};

local function OnPhotoEvent(eventType,relativePath,fullPath)
    if eventType == 1 then
        local func = mOnTakeFinish.func;
        local self = mOnTakeFinish.self;
        mOnTakeFinish.func = nil;
        mOnTakeFinish.self = nil;
        if relativePath ~= "" and fullPath ~= "" then
            if self then
                func(self,relativePath, fullPath)
            else
                func(relativePath, fullPath)
            end 
        end
    elseif eventType == 2 then
        local call = mOnClipFinish[1];
        table.remove(mOnClipFinish,1);
        if call.self then
            call.onFinish(call.self,call.relativePath,relativePath,fullPath);
        else
            call.onFinish(call.relativePath,relativePath,fullPath);
        end
        local next = mOnClipFinish[1];
        if next then
            SDKPhoto.Instance:MakeClipImage(next.relativePath,next.compressRatio,next.clipWidth,next.clipHeight);
        end
    end
end

--[[
Caches/Images/tmp目录下的图片只在某一次操作时有效,存储选择的图片
Caches/Images/clip目录下存储缩略图
--]]
function InitModule()
    SDKPhoto.Instance:Init("Caches/Images/tmp", "Caches/Images/clip");
    SDKPhoto.Instance:InitCallBack(OnPhotoEvent);
end

--[[
拍摄一张图片
compressRatio       int         原始图压缩率 100不压缩
standardWidth       int         原始图最大宽度
standardHeight      int         原始图最大高度
onFinish            function    获得原始图后的回调(texturePath)
self                class       onFinish所属对象 
--]]
function OpenCamera(compressRatio,maxWidth,maxHeight,onFinish,self)
    if mOnTakeFinish.func then return end
    mOnTakeFinish.func = onFinish;
    mOnTakeFinish.self = self;

    SDKPhoto.Instance:SetCrop(true);
    SDKPhoto.Instance:SetRatio(compressRatio);
    SDKPhoto.Instance:SetSize(maxWidth,maxHeight);
    SDKPhoto.Instance:OpenCamera(true);
end

--[[
从相册选择一张图片
compressRatio       int         原始图压缩率 100不压缩
standardWidth       int         原始图最大宽度
standardHeight      int         原始图最大高度
onFinish            function    获得原始图后的回调(texturePath)
self                class       onFinish所属对象
--]]
function OpenPhotoLibrary(compressRatio,maxWidth,maxHeight,onFinish,self)
    if mOnTakeFinish.func then return end
    mOnTakeFinish.func = onFinish;
    mOnTakeFinish.self = self;

    SDKPhoto.Instance:SetCrop(true);
    SDKPhoto.Instance:SetRatio(compressRatio);
    SDKPhoto.Instance:SetSize(maxWidth,maxHeight);
    SDKPhoto.Instance:OpenPhotoLibrary(true);
end

--[[
获取指定图片的缩略图,小于最大宽高时返回原图大小
relativePath        string      原始图本地相对路径
compressRatio       int         缩略图压缩率 100不压缩
clipWidth           int         缩略图最大宽度
clipHeight          int         缩略图最大高度
onFinish            function    获得原始图后的回调(texturePath)
self                class       onFinish所属对象
--]]
function MakeClipImage(relativePath,compressRatio,clipWidth,clipHeight,onFinish,self)
    local call = {};
    call.relativePath = relativePath;
    call.compressRatio = compressRatio;
    call.clipWidth = clipWidth;
    call.clipHeight = clipHeight;
    call.onFinish = onFinish;
    call.self = self;
    table.insert(mOnClipFinish,call);
    if #mOnClipFinish > 1 then return end
    SDKPhoto.Instance:MakeClipImage(relativePath,compressRatio,clipWidth,clipHeight);
end

--[[
将本地图片保存按到相册
fileName为图片在Caches\Images\tmp目录下的文件名
--]]
function SaveToPhoto(fileName)
    SDKPhoto.Instance:SaveToPhoto(fileName);
end

return PhotoMgr;