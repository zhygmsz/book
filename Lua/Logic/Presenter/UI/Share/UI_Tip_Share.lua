module("UI_Tip_Share",package.seeall);

local mEvents = {};

local mShareBgPanel;
local mShareInfoPanel;

local mPlatformList;

local mQRCodeTexture;
local mPlayerNameLabel;
local mPlayerLevleLabel;
local mPlayerServerLabel;

function OnCreate(self)
	mShareBgPanel = self:FindComponent("UIPanel","Offset/ShareBgPanel");
	mShareInfoPanel = self:FindComponent("UIPanel","Offset/ShareInfoPanel");
	mPlatformList = self:Find("Offset/PlatformList");

	mQRCodeTexture = self:FindComponent("UITexture","Offset/ShareInfoPanel/Panel/QRCodeTexture");
	ShareMgr.SetGenQRCodeTextureCallback(OnGenQRCodeTexture);
	ShareMgr.GenerateQRCodeTexture("www.baidu.com");

	mPlayerNameLabel = self:FindComponent("UILabel","Offset/ShareInfoPanel/NameLabel");
	mPlayerLevleLabel = self:FindComponent("UILabel","Offset/ShareInfoPanel/LevelLabel");
	mPlayerServerLabel = self:FindComponent("UILabel","Offset/ShareInfoPanel/ServerLabel");
	
	GameUtil.GameFunc.SetGameObjectLayer(mShareBgPanel.transform, CameraLayer.ShareLayer);
	GameUtil.GameFunc.SetGameObjectLayer(mShareInfoPanel.transform, CameraLayer.ShareLayer);
end

function OnEnable(self,...)
	mEvents[1] = MessageSub.Register(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_CAPTURE_FINISH, OnCaptureFinished);

	local shareUISortingOrder = ...;
	mShareBgPanel.sortingOrder = shareUISortingOrder - 1;
	mShareInfoPanel.sortingOrder = shareUISortingOrder + 1;
	
	local playerName = UserData.GetName();
	local playerLevelStr = tostring(UserData.GetLevel());
	local serverName = LoginMgr.GetCurrentServerName();
	mPlayerNameLabel.text = playerName;
	mPlayerLevleLabel.text = playerLevelStr;
	mPlayerServerLabel.text = serverName;

	mPlatformList.gameObject:SetActive(false);
	mLocalSaveFlag = false;
end

function OnDisable(self)
	MessageSub.UnRegister(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_CAPTURE_FINISH, mEvents[1]);
	ShareMgr.RemoveShareManagerParent();
	ShareMgr.DeleteCaptureImg();
end

function OnClick(go, id)
	if id == -1 then
		UIMgr.UnShowUI(AllUI.UI_Tip_Share);
	elseif id == 101 then
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

function OnCaptureFinished()
	mPlatformList.gameObject:SetActive(true);
end

function OnGenQRCodeTexture(qrcodeTexture)
	mQRCodeTexture.mainTexture = qrcodeTexture;
end


