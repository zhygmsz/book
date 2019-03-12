module("SystemInfo", package.seeall)

function InitSystemModule()
	--TODO 启动时把信息读取到LUA
end

NetState = {
	NoNetConnect = 0;
	Mobile = 1;
	Wifi = 2;
}

function ScreenWidth() return UnityEngine.Screen.width; end

function ScreenHeight() return UnityEngine.Screen.height; end

function IsEditor() return UnityEngine.Application.isEditor; end

function IsMobilePlatform() return UnityEngine.Application.isMobilePlatform; end

function GetBatteryLevel() return UnityEngine.SystemInfo.batteryLevel; end

function IsIosPlatform() return UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer or UnityEngine.Application.platform == UnityEngine.RuntimePlatform.OSXEditor; end

function GetNetState()
	local internetReachability = UnityEngine.Application.internetReachability;
	if internetReachability == UnityEngine.NetworkReachability.NotReachable then
		return NetState.NoNetConnect;
	elseif internetReachability == UnityEngine.NetworkReachability.ReachableViaCarrierDataNetwork then
		return NetState.Mobile;
	elseif internetReachability == UnityEngine.NetworkReachability.ReachableViaLocalAreaNetwork then
		return NetState.Wifi;
	end
end

return SystemInfo;


