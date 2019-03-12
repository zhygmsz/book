module("TouchMgr",package.seeall)

local mCountDown = 0;
local mCountDownTime = 0;

local function OnAppEvent(eventID)
    if eventID == 27 then
        --简单计时自己计时,减少定时器的C#回调
        if mCountDown <= 0 then
            --第一次点击
            mCountDown = mCountDown + 1;
            mCountDownTime = GameTime.time_L;
            GameEvent.Trigger(EVT.COMMON,EVT.APPBACK);
        elseif GameTime.time_L - mCountDownTime >= 2000 then
            --过了一段时间点击
            mCountDown = 1;
            mCountDownTime = GameTime.time_L;
        else
            --退出游戏 TODO弹出退出界面(安卓可以有,编辑器可以有,IOS不清楚)
            GameUtil.GameFunc.QuitGame();
        end
    elseif eventID == -1 then
        GameEvent.Trigger(EVT.COMMON,EVT.APPRESUME);
    elseif eventID == -3 then
        GameEvent.Trigger(EVT.COMMON,EVT.APPPAUSE);
    elseif eventID == -5 then
        GameEvent.Trigger(EVT.LIME, EVT.LIME_FADE)
	end
end

function InitEvent()
	GameCore.UtilEvent.Init(System.Action_int(OnAppEvent));
end

return TouchMgr;