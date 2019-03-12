--图片相关
module("PersonSpaceMgr",package.seeall);

mUploadData = {}

function ResetUploadState()
    mUploadData.localPath = "";
    mUploadData.url = "";
    mUploadData.self = nil
    mUploadData.onFinish = nil;
    mUploadData.uploading = false;
    mUploadData.uploadFile = false;
    mUploadData.uploadPackage = false;
    mUploadData.pornDetecting = false;
    mUploadData.progressFunc = UploadingProgress
end

function UploadingProgress()
    -- -1等待中 0-1上传中 2审核中
    if mUploadData.pornDetecting then 
        return 2;
    else
        return CosMgr.UploadProgress(mUploadData.localPath);
    end
end

function OnPornDetect(remotePath,successFlag)
    mUploadData.uploading = false;
    if successFlag then
        if mUploadData.onFinish then
            if mUploadData.self then
                mUploadData.onFinish(mUploadData.self,mUploadData.url,mUploadData.localPath);
            else
                mUploadData.onFinish(mUploadData.url,mUploadData.localPath);
            end
        end
        TipsMgr.TipByKey("image_upload_upload_success");
    else
        TipsMgr.TipByKey("image_upload_porndetect_fail");
    end
end

function OnUpload(localPath,remotePath,successFlag)
    if successFlag then
        mUploadData.pornDetecting = true;
        mUploadData.url = remotePath
        --PornDetectMgr.PornDetectSingleFile(remotePath,OnPornDetect);
        OnPornDetect(remotePath,true);
    else
        TipsMgr.TipByKey("image_upload_upload_fail");
        mUploadData.uploading = false;
        if mUploadData.onFinish then
            if mUploadData.self then
                mUploadData.onFinish(mUploadData.self,nil,localPath);
            else
                mUploadData.onFinish(nil,localPath);
            end
        end
    end
end

--添加图片
function UpLoadImage(localrelativepath,uploadpath,onfinish,self)
    if mUploadData.uploading then 
       TipsMgr.TipByKey("image_upload_multiadd_not_support");--不支持多图片上传
    else
        ResetUploadState()
        mUploadData.localPath = localrelativepath;
        mUploadData.onFinish = onfinish;
        mUploadData.self = self
        mUploadData.uploading = true;
        mUploadData.uploadFile = true;
        mUploadData.uploadPackage = false;
        mUploadData.pornDetecting = false;
        CosMgr.UploadFile(mUploadData.localPath,uploadpath.."/".. UserData.PlayerID,OnUpload);
    end
end

--选取头像图片
function ChooseHeadImage(fromcamera,onFinish,self)
    if fromcamera then
        PhotoMgr.OpenCamera(100,1024,1024,onFinish,nil,_self)
    else
        PhotoMgr.OpenPhotoLibrary(100,1024,1024,onFinish,nil,_self)
    end
end

--加载头像
function LoadHeadIcon(uitexture,url)
    if mImageMode then
        UIUtil.LoadImage(uitexture,{compressRatio=100,width=1024,height=1024},url,true)
    else
        uitexture.mainTexture = nil
    end
end

--上传头像
function UpLoadHeadIcon(localrelativepath,onfinish,self)
    UpLoadImage(localrelativepath,"headIcons",onfinish,self)
end

--选取头像图片
function ChooseMomentImage(fromcamera,onFinish,self)
    if fromcamera then
        PhotoMgr.OpenCamera(100,1024,1024,onFinish,nil,_self)
    else
        PhotoMgr.OpenPhotoLibrary(100,1024,1024,onFinish,nil,_self)
    end
end


--加载朋友圈图片
function LoadMomentImage(uitexture,url)
    if mImageMode then
        UIUtil.LoadImage(uitexture,{compressRatio=100,width=512,height=512},url,true)
    else
        uitexture.mainTexture = nil
    end
end

--上传朋友圈图片
function UpLoadMomentImage(localrelativepath,onfinish,self)
    UpLoadImage(localrelativepath,"momentImages",onfinish,self)
end

