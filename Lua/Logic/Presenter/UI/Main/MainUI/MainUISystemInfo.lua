MainUISystemInfo = class("MainUISystemInfo");

function MainUISystemInfo:ctor(uiFrame)
	self._TIME_UPDATE_DURATION = 5;
	
	self._batteryInfoBar = uiFrame:FindComponent("UISlider", "TopLeft/SystemInfo/Battery");
	self._batteryBg = uiFrame:FindComponent("UISprite", "TopLeft/SystemInfo/Battery/Bg");
	self._batteryContent = uiFrame:FindComponent("UISprite", "TopLeft/SystemInfo/Battery/Foreground");
	self._timeLabel = uiFrame:FindComponent("UILabel", "TopLeft/SystemInfo/Time");
	self._WifiSprite = uiFrame:FindComponent("UILabel", "TopLeft/SystemInfo/Wifi");
	self._mapNameLabel = uiFrame:FindComponent("UILabel", "TopRight/SystemInfo/MapName");
	self:RegEvent();
end

function MainUISystemInfo:OnEnable()
	self:InitView();
	self._timer = GameTimer.AddForeverTimer(self._TIME_UPDATE_DURATION, self.UpdateSystemInfo, self);
end

function MainUISystemInfo:OnDisable()
	GameTimer.DeleteTimer(self._timer);
end

function MainUISystemInfo:OnDestroy()
	self:UnRegEvent();
end

function MainUISystemInfo:RegEvent()
	GameEvent.Reg(EVT.MAPEVENT, EVT.MAP_ENTER_FINISH, self.OnEnterMap, self);
end

function MainUISystemInfo:UnRegEvent()
	GameEvent.UnReg(EVT.MAPEVENT, EVT.MAP_ENTER_FINISH, self.OnEnterMap, self);
end

function MainUISystemInfo:InitView()
	self:UpdateSystemTime();
	self:UpdateBatteryInfo();
	self:UpdateMapName();
end

function MainUISystemInfo:UpdateSystemInfo()
	self:UpdateSystemTime();
	self:UpdateBatteryInfo();
end

function MainUISystemInfo:UpdateSystemTime()
	local timeInfo = TimeUtils.SystemDate();
	
	local horStr = tostring(timeInfo.hour);
	if timeInfo.hour < 10 then
		horStr = "0" .. tostring(timeInfo.hour);
	end
	
	local minStr = tostring(timeInfo.min);
	if timeInfo.min < 10 then
		minStr = "0" .. tostring(timeInfo.min);
	end
	
	local timeStr = horStr .. ":" .. minStr;
	self._timeLabel.text = timeStr;
end

function MainUISystemInfo:UpdateBatteryInfo()
	local batteryValue = SystemInfo.GetBatteryLevel();
	self._batteryInfoBar.value = batteryValue;
	if batteryValue == - 1 then
		self._batteryBg.color = Color.New(0, 1, 0, 1);
		self._batteryContent.color = Color.New(0, 1, 0, 1);
		self._batteryInfoBar.value = 1;
	elseif batteryValue > 0.2 then
		self._batteryBg.color = Color.New(0, 1, 0, 1);
		self._batteryContent.color = Color.New(0, 1, 0, 1);
	else
		self._batteryBg.color = Color.New(1, 0, 0, 1);
		self._batteryContent.color = Color.New(1, 0, 0, 1);
	end
end

function MainUISystemInfo:UpdateMapName()
	local sceneId = MapMgr.GetSceneID();
	local detailMapInfo = BigMapMgr.GetAreaMapInfoById(sceneId);
	if detailMapInfo == nil then return; end
	self._mapNameLabel.text = detailMapInfo.name;
end

function MainUISystemInfo:OnEnterMap()
	self:UpdateMapName();
end

return MainUISystemInfo; 