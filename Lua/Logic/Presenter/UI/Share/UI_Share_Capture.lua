module("UI_Share_Capture", package.seeall);

local mEvents = {};
local mSelf;
local mOffset;

local mPlatformList;
local mGameCaptureTextrue;
local mPlayerNameLabel;
local mPlayerLevleLabel;
local mPlayerServerLabel;
local mQRCodeTexture;
local mSharePanel;

local mResaultTexture;
local mCaptureResault;

local FIXED_TEXTURE_WIDTH = 1023;

function OnCreate(self)
	mSelf = self;
	mOffset = self:Find("Offset");
	mPlatformList = self:Find("Offset/PlatformList");
	mSharePanel = self:FindComponent("UIPanel", "Offset/ShareUI");
	mGameCaptureTextrue = self:FindComponent("UITexture", "Offset/ShareUI/CaptureResTextrue");
	mQRCodeTexture = self:FindComponent("UITexture", "Offset/ShareUI/Panel/QRCodeTexture");
	mPlayerNameLabel = self:FindComponent("UILabel", "Offset/ShareUI/PlayerInfo/PlayerNameLabel");
	mPlayerLevleLabel = self:FindComponent("UILabel", "Offset/ShareUI/PlayerInfo/PlayerLevelLabel");
	mPlayerServerLabel = self:FindComponent("UILabel", "Offset/ShareUI/PlayerInfo/PlayerServerLabel");
	
	mResaultTexture = self:FindComponent("UITexture", "Offset/CaptureResault/ResalutTexture");
	mCaptureResault = self:Find("Offset/CaptureResault");
	
	GameUtil.GameFunc.SetGameObjectLayer(mSharePanel.transform, CameraLayer.ShareLayer);
	
	ShareMgr.SetGenQRCodeTextureCallback(OnGenQRCodeTexture);
end

function OnEnable(self)
	mEvents[1] = MessageSub.Register(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_CAPTURE_FINISH, ShowCaptureResault);
	
	local captureTexture = ShareMgr.GetGameCaptureTexture();
	if captureTexture ~= nil then
		mGameCaptureTextrue.mainTexture = captureTexture;
	end
	local playerName = UserData.GetName();
	local playerLevelStr = tostring(UserData.GetLevel());
	local serverName = LoginMgr.GetCurrentServerName();
	mPlayerNameLabel.text = playerName;
	mPlayerLevleLabel.text = playerLevelStr;
	mPlayerServerLabel.text = serverName;
	
	mCaptureResault.gameObject:SetActive(false);
	mPlatformList.gameObject:SetActive(false);
	
	ShareMgr.GenerateQRCodeTexture("www.baidu.com");
	ShareMgr.SetShareManagerParent(mOffset.transform);
end

function OnDisable(self)
	MessageSub.UnRegister(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_CAPTURE_FINISH, mEvents[1]);
	
	ShareMgr.RemoveShareManagerParent();
	ShareMgr.DeleteCaptureImg();
end

function OnGenQRCodeTexture(qrcodeTexture)
	mQRCodeTexture.mainTexture = qrcodeTexture;
	--相机截屏执行
	--SwitchToShareLayer(true);
	ShareMgr.CaptureCamera();
end

function OnClick(go, id)
	if(id == 0) then
		UIMgr.UnShowUI(AllUI.UI_Share_Capture);
	elseif(id == 101) then
		ShareMgr.ShareCaptureImgToPlatform(ShareMgr.SharePlatformType.Platform_QQ);
	elseif(id == 102) then
		ShareMgr.ShareCaptureImgToPlatform(ShareMgr.SharePlatformType.Platform_Sinaweibo);
	elseif(id == 103) then
		ShareMgr.ShareCaptureImgToPlatform(ShareMgr.SharePlatformType.Platform_WechatMoments);
	elseif(id == 104) then
		ShareMgr.ShareCaptureImgToPlatform(ShareMgr.SharePlatformType.Platform_Wechat);
	elseif(id == 105) then
		local imgName = ShareMgr.GetCameraCaptureImgName();
		if imgName ~= "" then
			PhotoMgr.SaveToPhoto(imgName);
			TipsMgr.TipByKey("share_success_local");
		end
	end
end

function ShowCaptureResault(captureTexture)
	local width = captureTexture.width;
	local height = captureTexture.height;
	mResaultTexture.mainTexture = captureTexture;
	local textureHeight = FIXED_TEXTURE_WIDTH * height / width;
	mResaultTexture.height = textureHeight;
	mCaptureResault.gameObject:SetActive(true);
	mPlatformList.gameObject:SetActive(true);
	--打开屏幕点击特效
	TouchMgr.EnableClickEffect(true);
end 