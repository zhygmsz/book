module("GameTimer",package.seeall);

local UtilTimer = GameCore.UtilTimer;
local mCallBacks = {};

local function ON_RM_TIMER(id)
	mCallBacks[id] = nil;
end

local function ON_TICK_FINISH(id)
	local callback = mCallBacks[id];
	if callback and callback.func then
		if callback.self then
			callback.func(callback.self,unpack(callback.param))
		else	
			callback.func(unpack(callback.param));
		end
	end
end

--[[
添加一个定时器,返回定时器ID
duration float类型 单位:秒 n秒后执行函数func
count int类型 执行次数
func
self
--]]
function AddTimer(duration,count,func,self,...)
	local callback = {};
	callback.func = func;
	callback.self = self;
	callback.param = {...};

	local id = UtilTimer.AddTimer(duration,count);
	mCallBacks[id] = callback;
	return id;
end

function AddForeverTimer(duration,func,self,...)
	return AddTimer(duration,100000000,func,self,...);
end

function GetTimerLeftDuration(id)
	return UtilTimer.GetTimerLeftDuration(id);
end

function DeleteTimer(id)
	UtilTimer.DeleteTimer(id);
end

function PauseTimer(id,pause)
	UtilTimer.PauseTimer(id,pause);
end

function ResetTimer(id)
	UtilTimer.ResetTimer(id);
end

function InitModule()
	UtilTimer.ON_RM_TIMER = UtilTimer.TimerCallBack(ON_RM_TIMER);
	UtilTimer.ON_TICK_FINISH = UtilTimer.TimerCallBack(ON_TICK_FINISH);
end


return GameTimer;
