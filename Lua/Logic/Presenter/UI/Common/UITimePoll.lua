--[[
    author:{hesinian}
    time:2018-12-25 10:59:06
]]

UITimePoll = class("UITimePoll")

local function FindIndex(self, data)
    for i,d in ipairs(self._dataList) do
        if d == data then
            return i;
        end
    end
    GameLog.LogError("Not　Found Data %s in UITimeRoll",tostring(data));
end

local function OnTime(self)
    self._select = self._select == #self._dataList and 1 or self._select + 1;
    if self._caller then
        self._call(self._caller,self._dataList[self._select]);
    else
        self._call(self._dataList[self._select]);
    end
end

--[[
    @desc: 
    author:{author}
    time:2018-12-25 11:30:14
    --@dataList:轮询调用方法数据的数组
	--@interval:时间间隔 s
	--@call:轮询调用的方法
	--@caller: 
    @return:
]]
function UITimePoll:ctor(dataList,interval,call,caller)
    self._dataList = dataList;
    self._interval = interval;
    self._call = call;
    self._caller = caller;
end
--[[
    @desc: 开始轮询
    author:{author}
    time:2018-12-25 11:31:07
    --@data: 开始的数据项
    @return:
]]
function UITimePoll:Start(data)
    if #self._dataList <= 0 then return; end
    local index = FindIndex(self,data);
    self._select = index or 1;
    self._timeIndex = GameTimer.AddForeverTimer(self._interval,OnTime,self);
end

function UITimePoll:End()
    if self._timeIndex then
        GameTimer.DeleteTimer(self._timeIndex);
    end
    self._timeIndex = nil;
end

function UITimePoll:Disturb(data)
    if self._timeIndex then
        self:End();
        self:Start(data);
    end
end

return UITimePoll;

