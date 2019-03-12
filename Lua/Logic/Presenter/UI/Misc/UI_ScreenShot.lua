module("UI_ScreenShot",package.seeall);

local mTexture;
local mImage;
function OnCreate(ui)
    mTexture = ui:FindComponent("UITexture","ScreenShot");
end

function OnEnable(ui)
    mTexture.mainTexture = mImage;
    mTexture:MakePixelPerfect();
end

function OnDisable(ui)
    mTexture.mainTexture = nil;
    UnityEngine.Object.Destroy(mImage);
end

function OnClick(go, id)
    if id == 1 then
        ScreenShotUtils.Instance:SaveTexture2Png(mImage);
    elseif id == 2 then
        TipsMgr.TipByFormat("Share 模块正在开发");
    end
    UIMgr.UnShowUI(AllUI.UI_ScreenShot);
end

function ScreenCapture()
    ScreenShotUtils.Instance:CaptureFullScreenWithUnityCamera(AterCapture);
end

function AterCapture(texture2d)
    mImage = texture2d;
    UIMgr.ShowUI(AllUI.UI_ScreenShot);
end