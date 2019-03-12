module("EventDefine_Common", package.seeall)

local GEN_GROUP = GameEvent.GEN_GROUP;
local GEN_EVENT = GameEvent.GEN_EVENT;

function InitEvent()
	GEN_GROUP("COMMON");
    GEN_EVENT("CLICKGROUD");                --点地移动
    GEN_EVENT("CLICK_ENTITY");				--点中实体
    GEN_EVENT("DRAGJOYSTICK");              --移动摇杆      
    GEN_EVENT("ITEMDROP");                  --物品掉落
    GEN_EVENT("UICLOSED");                  --界面关闭                 
    GEN_EVENT("APPBACK");                   --点击安卓后退按钮
    GEN_EVENT("APPPAUSE");                  --点击安卓暂停
    GEN_EVENT("APPRESUME");                 --点击安卓从后台返回
    
    --网络状态
	GEN_GROUP("NETWORK");
    GEN_EVENT("NETWORK_CONNECT");           --网络连接成功
    GEN_EVENT("NETWORK_CONNECT_FAIL");      --网络连接失败
    GEN_EVENT("NETWORK_DISCONNECT");        --网络连接断开
    GEN_EVENT("NETWORK_SEND_MSG_FAIL");     --消息发送失败
    GEN_EVENT("NETWORK_ERROR");             --网络发生错误
    
    --剧情对话
	GEN_GROUP("STORY");
    GEN_EVENT("STORY_ENTER");               --剧情开始
    GEN_EVENT("STORY_FINISH");              --剧情结束
    GEN_EVENT("STORY_TEXT");                --剧情文本
    GEN_EVENT("STORY_SETTIME");             --剧情时间
    GEN_EVENT("STORY_PAUSE");               --剧情暂停
    GEN_EVENT("STORY_RESUME");              --剧情继续
    GEN_EVENT("STORY_DIVINE");              --手相结束
    GEN_EVENT("DIALOG_OPEN");               --开启对话
    GEN_EVENT("DIALOG_CLOSE");              --关闭对话
    GEN_EVENT("DIALOG_ENTER");              --对话开始
	GEN_EVENT("DIALOG_FINISH");             --对话结束
	GEN_EVENT("DIALOG_FALSE_FINISH");       --对话结束
    GEN_EVENT("BULLET_ENTER");              --开启弹幕
    GEN_EVENT("BULLET_FINISH");             --关闭弹幕
end

return EventDefine_Common;