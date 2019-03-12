module("EventDefine_System", package.seeall)

local GEN_GROUP = GameEvent.GEN_GROUP;
local GEN_EVENT = GameEvent.GEN_EVENT;

function InitEvent()
    --登录系统
	GEN_GROUP("LOGIN");
	GEN_EVENT("LOGIN_ACCOUNT_SUCCESS");         --账号登录成功
	GEN_EVENT("LOGIN_BULLET");                  --获得公告
	GEN_EVENT("LOGIN_CHANGE_ACCOUNT");          --更换账号
	--任务系统
	GEN_GROUP("TASK");
    GEN_EVENT("TASK_LIST");                     --任务列表
    GEN_EVENT("TASK_ACCEPT");                   --任务领取
    GEN_EVENT("TASK_UPDATE");                   --任务刷新
    GEN_EVENT("TASK_CANCEL");                   --任务取消
	GEN_EVENT("TASK_FINISH"); 		        	--任务结束  
    GEN_EVENT("TASK_GOTO_ACCEPT");              --前往领取
    GEN_EVENT("TASK_GOTO_FINISH");              --前往完成
    GEN_EVENT("TASK_AI_START");                 --自动执行
    GEN_EVENT("TASK_AI_STOP");                  --取消自动
	--充值系统
	GEN_GROUP("CHARGE")
	GEN_EVENT("CHARGE_HAS_ANY_CHARGE");--是否有首充
	GEN_EVENT("CHARGE_FIRST_REWARD_CHANGE");--首充奖励状态变化
	GEN_EVENT("CHARGE_FREE_DOUBLE");--设置为双倍赠送
	GEN_EVENT("CHARGE_GIFT_PACKAGE");--设置为送大礼包
	GEN_EVENT("CHARGE_FIRST_REWARD_ENTRY");--关闭首充入口
	GEN_EVENT("CHARGE_REBATE_STATE");--累充奖励状态变化
	GEN_EVENT("CHARGE_HAS_RECHARGE_UPDATEUI");--发生充值行为，刷新UI
end

return EventDefine_System;