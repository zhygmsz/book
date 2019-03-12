module("UI_Login_Account",package.seeall);
local mRootGo;
local mSDKSimulatorGo;
local mAccountInput;

local mToggle;

local mAutoToggle;

local function OnAccountLogin()
	UI_Login.ShowGameIn();
end

function SetActive(state)
	mRootGo:SetActive(state);
end

--自动登录
local function OnAutoChange()
	LoginMgr.SetAutoLoginMode(mAutoToggle.value);
end

function OnCreate(self)
	mRootGo = self:Find("Account").gameObject;
	mSDKSimulatorGo = self:Find("Account/SDKSimulator").gameObject;
	local simulatorPath = "Account/SDKSimulator/Right/";
	mAccountInput = self:FindComponent("LuaUIInput",simulatorPath.."Account/Input");

	mToggle = {};
	mToggle[1] = self:FindComponent("UIToggle",simulatorPath.."ServerRoot/Option1");
	mToggle[2] = self:FindComponent("UIToggle",simulatorPath.."ServerRoot/Option2");
	mToggle[3] = self:FindComponent("UIToggle",simulatorPath.."ServerRoot/Option3");

	mAutoToggle = self:FindComponent("UIToggle",simulatorPath.."Option4");
	EventDelegate.Add(mAutoToggle.onChange, EventDelegate.Callback(OnAutoChange))


end

function OnEnable(self)

	mAccountInput.value = LoginMgr.GetLocalAccount();

	local serverSwitch =  LoginMgr.GetServerMode();

	if serverSwitch then
		mToggle[serverSwitch]:Set(true);
	end
	mSDKSimulatorGo:SetActive(false);

	mAutoToggle:Set(LoginMgr.GetAutoLoginMode());
	
	GameEvent.Reg(EVT.LOGIN, EVT.LOGIN_ACCOUNT_SUCCESS,OnAccountLogin);
end

function OnDisable(self)
	GameEvent.UnReg(EVT.LOGIN, EVT.LOGIN_ACCOUNT_SUCCESS,OnAccountLogin);
end

function OnClick(id)
	if id == 60 then
		local accStr = mAccountInput.value;
		local length = mAccountInput:GetValueLength();
		if length == 0 or length > 10 then
			TipsMgr.TipByKey("input_error_length_com",10);
			return;
		end
		LoginMgr.RequestAccountLogin(accStr);
	elseif id == 50 then--开启
		mSDKSimulatorGo:SetActive(false);
	elseif id == 51 then --外网
		LoginMgr.SetNetworkMode(1);
	elseif id == 52 then --内网
		LoginMgr.SetNetworkMode(2);
	elseif id == 53 then --单机
		LoginMgr.SetNetworkMode(3);
	elseif id >= 100 and id <= 103 then
		mSDKSimulatorGo:SetActive(true);
	end
	
end


