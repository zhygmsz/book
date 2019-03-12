module("ShareMgr", package.seeall);
local SDKShare = cyou.ldj.sdk.SDKShare;

SharePlatformType =
{
	Platform_QQ = 1,
	Platform_Sinaweibo = 2,
	Platform_WechatMoments = 3,
	Platform_Wechat = 4
}

local mGameCaptureTexture;
local mCurrentSharePlatform;
local mCameraCaptureImgPath = "";
local mSdkObject;

local mQRCodeGenCallback = nil;

function InitModule()
	local appKey_Qq_Android = "aed9b0303e3ed1e27bae87c33761161d";
	local appId_Qq_Android = "100371282";
	
	local appKey_Qq_Ios = "aed9b0303e3ed1e27bae87c33761161d";
	local appId_Qq_Ios = "100371282";
	
	local appKey_QZone_Android = "ae36f4ee3946e1cbb98d6965b0b2ff5c";
	local appId_QZone_Android = "100371282";
	
	local appKey_QZone_Ios = "aed9b0303e3ed1e27bae87c33761161d";
	local appId_QZone_Ios = "100371282";
	
	local appKey_SinaWeibo_Android = "568898243";
	local appSecret_SinaWeibo_Android = "38a4f8204cc784f81f9f0daaf31e02e3";
	
	local appKey_SinaWeibo_Ios = "568898243";
	local appSecret_SinaWeibo_Ios = "38a4f8204cc784f81f9f0daaf31e02e3";
	
	local appId_WeChat_Android = "wx4868b35061f87885";
	local appSecret_WeChat_Android = "64020361b8ec4c99936c0e3999a9f249";
	
	local appId_WeChat_Ios = "wx4868b35061f87885";
	local appSecret_WeChat_Ios = "64020361b8ec4c99936c0e3999a9f249";
	
	local appId_WeChatMoments_Android = "wx4868b35061f87885";
	local appSecret_WeChatMoments_Android = "64020361b8ec4c99936c0e3999a9f249";
	
	local appId_WeChatMoments_Ios = "wx4868b35061f87885";
	local appSecret_WeChatMoments_Ios = "64020361b8ec4c99936c0e3999a9f249";
	
	SDKShare.Instance:InitQQ(appKey_Qq_Android, appId_Qq_Android, appKey_Qq_Ios, appId_Qq_Ios);
	SDKShare.Instance:InitQZone(appKey_QZone_Android, appId_QZone_Android, appKey_QZone_Ios, appId_QZone_Ios);
	SDKShare.Instance:InitSinaWeibo(appKey_SinaWeibo_Android, appSecret_SinaWeibo_Android, appKey_SinaWeibo_Ios, appSecret_SinaWeibo_Ios);
	SDKShare.Instance:InitWeChat(appId_WeChat_Android, appSecret_WeChat_Android, appId_WeChat_Ios, appSecret_WeChat_Ios);
	SDKShare.Instance:InitWeChatMoments(appId_WeChatMoments_Android, appSecret_WeChatMoments_Android, appId_WeChatMoments_Ios, appSecret_WeChatMoments_Ios);
	
	SDKShare.Instance:InitCallBack();
	SDKShare.Instance:InitCallBack(OnShareEvent);
	mSdkObject = UnityEngine.GameObject.Find("SDK_OBJECT");
end

function SetGenQRCodeTextureCallback(callbackFUn)
	mQRCodeGenCallback = callbackFUn;
end

function CaptureGame()
	SDKShare.Instance:CaptureGameScreenShoot();
end

function GetGameCaptureTexture()
	return mGameCaptureTexture;
end

function GenerateQRCodeTexture(url)
	SDKShare.Instance:GenerateQRCodeTexture(url);
end

function ShareCaptureImgToPlatform(platformType)
	--暂时封锁功能接口
	TipsMgr.TipByKey("equip_share_not_support");
	--[[
	mCurrentSharePlatform = platformType;
	if mCurrentSharePlatform == SharePlatformType.Platform_QQ then
		SDKShare.Instance:ShareImgToQQ();
	elseif mCurrentSharePlatform == SharePlatformType.Platform_Sinaweibo then
		SDKShare.Instance:ShareImgToSinaWeibo();
	elseif mCurrentSharePlatform == SharePlatformType.Platform_WechatMoments then
		SDKShare.Instance:ShareImgToWeChatMoments();
	elseif mCurrentSharePlatform == SharePlatformType.Platform_Wechat then
		SDKShare.Instance:ShareImgToWeChat();
	end
	]]
end

function CaptureCamera()
	SDKShare.Instance:CaptureCameraScreenShoot();
end

function SetShareManagerParent(parentTransform)
	SDKShare.Instance:SetShareManagerParent(parentTransform);
end

function RemoveShareManagerParent()
	SDKShare.Instance:SetShareManagerParent(mSdkObject.transform);
end

function DeleteCaptureImg()
	SDKShare.Instance:DeleteCaptureImg(mCameraCaptureImgPath);
	mCameraCaptureImgPath = "";
end

function GetCameraCaptureImgName()
	return mCameraCaptureImgPath;
end

function OnShareEvent(eventType, arg1, arg2, arg3)
	if eventType == 2 then
		--分享失败
		TipsMgr.TipByKey("share_fail_system");
	elseif eventType == 3 then
		--分享取消
		TipsMgr.TipByKey("share_fail_system");
	elseif eventType == 4 then
		--相机截屏
		mCameraCaptureImgPath = arg1;
		local cameraCaptureTexture = arg2;
		MessageSub.SendMessage(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_SWITCHSHARELAYER, false);
		MessageSub.SendMessage(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_CAPTURE_FINISH, cameraCaptureTexture);
	elseif eventType == 5 then
		--游戏截屏
		mGameCaptureTexture = arg1;
		UIMgr.ShowUI(AllUI.UI_Share_Capture);
	elseif eventType == 6 then
		--生成二维码
		mQRCodeGenCallback(arg1);
	end
end

return ShareMgr; 