module("TimeUtils",package.seeall)

--时间戳同步间隔
local TIME_SYNC_INTERVAL = 2;
--最后一次同步服务器返回的时间戳
local mServerTimeStamp = 0;
--最后一次同步服务器返回的延迟时间
local mNetWorkDelayTime = 0;
--最后一次同步服务器返回时的应用运行时间
local mLastAckClientTime = 0;
--时间同步开关
local mSyncEnabled = false;

--请求与服务器同步时间戳
local function RequestSyncTime()
    if mSyncEnabled then
        local msg = NetCS_pb.CSSyncTime();
        msg.clientTime = math.floor(GameTime.realtime_L);
        msg.serverTime = mServerTimeStamp ~= 0 and SystemTimeStamp() or 0;
        GameNet.SendToGate(msg);
    end
end

--服务器时间戳同步消息
function OnSyncTime(msg)
    mServerTimeStamp = tonumber(msg.serverTime);
    mLastAckClientTime = math.floor(GameTime.realtime_L);
    mNetWorkDelayTime = (mLastAckClientTime - tonumber(msg.clientTime)) / 2;
end

function InitModule()
    GameTimer.AddForeverTimer(TIME_SYNC_INTERVAL,RequestSyncTime);
end

--开关时间同步
function EnableTimeSync(enable)
    mSyncEnabled = enable;
end

--首次登录时间戳同步
function SyncTimeStamp(timeStamp)
    --首次登录忽略网络延迟
    mServerTimeStamp = timeStamp or 0;
    mNetWorkDelayTime = 0;
    mLastAckClientTime = GameTime.realtime_L;
end

--时间戳转换为日期,返回table secondFlag标记输入是否为秒
function TimeStamp2Date(timeStamp,secondFlag)
    if secondFlag then timeStamp = timeStamp * 1000; end
    local seconds = math.floor((timeStamp or 0) / 1000);
    local date = os.date("*t",seconds);
    date.msec = timeStamp - seconds * 1000;
    return date;
end

--日期转换为时间戳,返回毫秒 secondFlag标记返回是否为秒
function Date2TimeStamp(date,secondFlag)
    local timeStamp = os.time(date) * 1000 + (date.msec or 0);
    return secondFlag and (timeStamp * 0.001) or timeStamp;
end

--yyyy-MM-dd_HH:mm:ss
function FormatDate2TimeStamp(formatDate,secondFlag)
    local tmpTable = table.tmpEmptyTable();
    tmpTable.year = string.sub(formatDate,1,4);
    tmpTable.month = string.sub(formatDate,6,7);
    tmpTable.day = string.sub(formatDate,9,10);
    tmpTable.hour = string.sub(formatDate,12,13);
    tmpTable.minute = string.sub(formatDate,15,16);
    tmpTable.second = string.sub(formatDate,18,19);
    return Date2TimeStamp(tmpTable,secondFlag);
end

--获取当前系统时间戳(网络时间),返回毫秒数 secondFlag标记返回是否为秒
function SystemTimeStamp(secondFlag)
    local timeStamp = 0;
    if mServerTimeStamp == 0 then
        timeStamp = math.floor(tolua.gettime() * 1000);
    else
        timeStamp = mServerTimeStamp + math.floor(GameTime.realtime_L) - mLastAckClientTime + mNetWorkDelayTime;
    end
    return secondFlag and (timeStamp * 0.001) or timeStamp; 
end

--获取当前系统时间(网络时间),返回日期详情表
function SystemDate()
    return TimeStamp2Date(SystemTimeStamp());
end

--获取日期对应星座
function SystemDate2Constellation(month,day)
    local birth =tonumber(month) * 100 + tonumber(day);
    if birth >= 321 and birth <= 419 then return 1 end      --白羊座
    if birth >= 420 and birth <= 520 then return 2 end      --金牛座
    if birth >= 521 and birth <= 621 then return 3 end      --双子座
    if birth >= 622 and birth <= 722 then return 4 end      --巨蟹座
    if birth >= 723 and birth <= 822 then return 5 end      --狮子座
    if birth >= 823 and birth <= 922 then return 6 end      --处女座
    if birth >= 923 and birth <= 1023 then return 7 end     --天秤座
    if birth >= 1024 and birth <= 1122 then return 8 end    --天蝎座
    if birth >= 1123 and birth <= 1221 then return 9 end    --射手座
    if birth >= 1222 or birth <= 119 then return 10 end     --摩羯座
    if birth >= 120 and birth <= 218 then return 11 end     --水瓶座
    if birth >= 219 and birth <= 320 then return 12 end     --双鱼座
end

--获取到达指定时间戳剩余多少,返回剩余毫秒数(>=0) secondFlag标记返回是否为秒
function TimeStampLeft(timeStamp,secondFlag)
    local leftStamp = math.max(0,timeStamp - SystemTimeStamp());
    return secondFlag and (leftStamp * 0.001) or leftStamp;
end

--获取到达下一个时间点剩余多少时间,返回剩余毫秒数(>=0) secondFlag标记返回是否为秒
function TimeStampLeft2NextTime(nextTime,secondFlag)
    local date = SystemDate();
    nextTime.year = nextTime.year or date.year;
    nextTime.month = nextTime.month or date.month;
    nextTime.day = nextTime.day or date.day;

    nextTime.hour = nextTime.hour or date.hour;
    nextTime.minute = nextTime.minute or 0;
    nextTime.second = nextTime.second or 0;
    nextTime.msec = nextTime.msec or 0;

    local dateStamp = SystemTimeStamp();
    local nextStamp = Date2TimeStamp(nextTime);
    local deltaStamp = nextStamp - dateStamp;
    if deltaStamp <= 0 then
        --当前时间点已经超过了指定时间点,计算下一个时间点(跨天计算)
        nextStamp = nextStamp + math.ceil(math.abs(deltaStamp) / 86400000) * 86400000;
        deltaStamp = nextStamp - dateStamp;
    end
    return deltaStamp * (secondFlag and 0.001 or 1);
end

--获取指定时间戳经过了多少,返回经过毫秒数 secondFlag标记返回是否为秒
function TimeStampPass(timeStamp,secondFlag)
    local passStamp = math.max(0,SystemTimeStamp() - timeStamp);
    return secondFlag and (passStamp * 0.001) or passStamp;
end

--毫秒时间转换为时、分、秒、毫秒,needDay控制是否需要把小时转换为天数
function Time2Units(millseconds,needDay,needMonth)
    local t = {};
    local totalSecond = math.floor(millseconds / 1000);
    t.hour = math.floor(totalSecond / 3600);
    t.minute = math.fmod(math.floor(totalSecond / 60),60);
    t.second = math.fmod(totalSecond,60);
    t.millsecond = math.fmod(millseconds, 1000);
    t.day = 0;
    if needDay then
        t.day = math.floor(totalSecond / 86400);
        t.hour = math.fmod(t.hour,24);
        if needMonth then
            t.month = math.floor(t.day / 30);
            t.day = math.fmod(t.day,30);
        end
    end
    return t;
end

--second 毫秒
--返回格式化时间字符串
function GetDateTimeByMillisecond( second )
    if second < 0 then
        GameLog.LogError("param error !")
        return ""
    end
    local day,hour,minutes,seconds = 0
    local dayL,hourL,minutesL = 0
    day,dayL = math.modf((((second/1000)/60)/60)/24)
    hour,hourL = math.modf(dayL*24)
    minutes,minutesL = math.modf(hourL*60)
    seconds = math.modf(minutesL*60)

    local secondsStr = ""
    secondsStr = tostring(seconds)
    if seconds < 10 then
        secondsStr = "0"..tostring(seconds)
    end

    local minutesStr = ""
    minutesStr = tostring(minutes)
    if minutes < 10 then
        minutesStr = "0"..tostring(minutesStr)
    end
    if day > 0 then
        local str = string.format(WordData.GetWordStringByKey("Shop_time_day"), day, hour, minutesStr, secondsStr)
        return str
    elseif hour > 0 then
        local str = string.format(WordData.GetWordStringByKey("Shop_time_hour"), hour, minutesStr, secondsStr)
        return str
    else
        local str = string.format(WordData.GetWordStringByKey("Shop_time_min"), minutesStr, secondsStr)
        return str
    end
end

--[[
时间格式化
timeToFormat     int   被格式化的时间值,默认为毫秒
formatType       int   格式化类型
                        0   00:00:00
                        1   年-月-日
                        2   
                        3   返回XX前,详情见具体注释
                        4   返回XX前,详情见具体注释
                        6   如果有一天X天00：00：00 如果没有 00：00：00
isSecond         bool  输入是否为秒
]]
function FormatTime(timeToFormat,formatType,isSecond)
    local formatType = formatType or 0;
    local millSeconds = timeToFormat * (isSecond and 1000 or 1);
    local formatedTime = nil;
    if formatType == 0 then
        local tu = Time2Units(millSeconds);
        formatedTime = string.format("%02d:%02d:%02d",tu.hour,tu.minute,tu.second);
    elseif formatType == 1 then
        local date = TimeUtils.TimeStamp2Date(millSeconds,false);
        formatedTime = string.format("%d-%02d-%02d",date.year,date.month,date.day)
    elseif formatType == 2 then
    
    elseif formatType == 3 then
        --30天以上的，至显示月数，超过30天不足60天的，算1个月前，依次类推。即显示为“XX个月前
        --24小时以上，不到30天的，只显示天数，24小时-47小时59分59秒算1天前，48小时-71小时59分59秒算2天前，依次类推。即显示为“XX天前”
        --1小时以上，不到24小时，只显示小时不限时分钟，30分钟进一位。即显示为“XX小时前”
        --1小时以内：显示精确到分钟，四舍五入，30秒进一位，如1分30秒记为2分钟。即显示为“XX分钟前”
        local passedmillseconds =TimeUtils.TimeStampPass(millSeconds,false)
        local tu = Time2Units(passedmillseconds,true,true);
        local key = tu.month > 0 and "Mail_time_month" or tu.day > 0 and "Mail_time_day" or tu.hour > 0 and "Mail_time_hour" or "Mail_time_minute"
        local value =  tu.month > 0 and tu.month or tu.day > 0 and tu.day or tu.hour > 0 and (tu.hour + math.floor(tu.minute/30)) or (tu.minute + math.floor(tu.second/30))
        formatedTime = TipsMgr.GetTipByKey(key,value)
    elseif formatType == 4 then
        --一天之内返回 最大单位时间+“前” 如： xx小时前 xx分钟前 xx秒前 一天以上返回日期： 2018-12-01
        local passedmillseconds =TimeUtils.TimeStampPass(millSeconds,false)
        local t = TimeUtils.Time2Units(passedmillseconds,true,false)
        if t.day >= 1 then
            local date = TimeUtils.TimeStamp2Date(millSeconds,false);
            formatedTime = string.format("%d-%02d-%02d",date.year,date.month,date.day)
        else
            local shownum = t.hour > 0 and t.hour or t.minute > 0 and t.minute or t.second
            local showunit = t.hour > 0 and "Time_before_hour" or t.minute > 0 and "Time_before_min" or "Time_before_just"
            formatedTime = TipsMgr.GetTipByKey(showunit,shownum)
        end
    elseif formatType == 5 then
         --返回日期 同一年 今天 昨天 xx月xx日 非同一年  xxxx年xx月xx日
        local date = TimeUtils.TimeStamp2Date(millSeconds,false);
        local date0 = TimeUtils.SystemDate();
        if date0.year == date.year and date0.month == date.month and date0.day <= (date.day + 1) then
            formatedTime = date0.day == date.day and TipsMgr.GetTipByKey("Time_today") or TipsMgr.GetTipByKey("Time_yesterday")
        else
            formatedTime = date0.year == date.year and TipsMgr.GetTipByKey("Time_dates_mouth",date.month,date.day) or TipsMgr.GetTipByKey("Time_dates_year",date.year,date.month,date.day)
        end
    elseif formatType == 6 then
        formatedTime = GetDateTimeByMillisecond(timeToFormat)
    end
    return formatedTime;
end

--==============================--
--desc:获取指定时间的时间戳
--time:2019-03-07 07:49:11
--@day:当天0，下一天1...
--@hour:
--@mins:
--@second:
--@secondFlag:
--@return 
--==============================--
function GetSpecifiedTimeInFutureOrPast(day,hour,mins,second,secondFlag)
    local curTimestamp = SystemTimeStamp(true)
    local oneDayTimestamp = 24*60*60
    local tempTime = curTimestamp + oneDayTimestamp * day
    local tempDate = os.date("*t", tempTime)
    local futureTime = {year=tempDate.year,month=tempDate.month,day=tempDate.day,hour=hour or 0,min=mins or 0,sec=second or 0}
    return Date2TimeStamp(futureTime,secondFlag)
end

return TimeUtils;