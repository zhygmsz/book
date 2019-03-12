module("GameTime",package.seeall)

local rawset = rawset;
local function OnUpdate()
	rawset(GameTime, "deltaTime_L", Time.deltaTime * 1000);
	rawset(GameTime, "fixedDeltaTime_L", Time.fixedDeltaTime * 1000);
	rawset(GameTime, "realtime_L", Time.realtimeSinceStartup * 1000);
	rawset(GameTime, "time_L", Time.time * 1000);
	rawset(GameTime, "frameCount", Time.frameCount);
end

function InitModule()
	GameTime.__newindex = function(t, k, v) error("perperty is read only->%s", k); end
	GameTime.deltaTime_L = 0;
	GameTime.fixedDeltaTime_L = 0;
	GameTime.realtime_L = 0;
	GameTime.time_L = 0;
	GameTime.frameCount = 0;
	UpdateBeat:Add(OnUpdate);
end

return GameTime;

