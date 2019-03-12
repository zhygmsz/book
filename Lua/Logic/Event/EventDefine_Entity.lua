module("EventDefine_Entity", package.seeall)

local GEN_GROUP = GameEvent.GEN_GROUP;
local GEN_EVENT = GameEvent.GEN_EVENT;

function InitEvent()
	--副本对象
	GEN_GROUP("ENTITY");
    GEN_EVENT("ENTITY_CREATE");                 --对象创建
    GEN_EVENT("ENTITY_DELETE");         	    --对象删除
    GEN_EVENT("ENTITY_HP_UPDATE");              --HP刷新
    GEN_EVENT("ENTITY_UPDATE_BUFF");		    --BUFF刷新
    GEN_EVENT("ENTITY_ADD_BUFF");               --添加BUFF
    GEN_EVENT("ENTITY_REMOVE_BUFF");		    --移除BUFF
    GEN_EVENT("ENTITY_IMMUNE_BUFF");            --BUFF被免疫
    GEN_EVENT("ENTITY_MISS_BUFF");		        --BUFF未命中
	GEN_EVENT("ENTITY_CAST_SKILL");				--技能释放
    GEN_EVENT("ENTITY_RIDE_ON");                --上坐骑
    GEN_EVENT("ENTITY_RIDE_OFF");			    --下坐骑
    
	--实体属性刷新
	GEN_GROUP("ENTITY_ATT_UPDATE")
    GEN_EVENT("ENTITY_ATT_PET_NAME");           --宠物名称刷新
    GEN_EVENT("ENTITY_ATT_PET_MASTER"); 	    --宠物主人更新
    GEN_EVENT("ENTITY_ATT_LEVEL");              --等级刷新
    GEN_EVENT("ENTITY_ATT_EXP"); 			    --经验刷新
    GEN_EVENT("ENTITY_ATT_NAME");               --名字刷新
    GEN_EVENT("ENTITY_ATT_MAXHP");			    --最大血量
    GEN_EVENT("ENTITY_ATT_MAXMP");              --最大蓝量
    GEN_EVENT("ENTITY_ATT_CAMP"); 			    --阵营刷新
    GEN_EVENT("ENTITY_ATT_HEIGHT"); 			--高度刷新
    
	--副本事件
	GEN_GROUP("MAPEVENT");
    GEN_EVENT("MAP_ENTER_MSG_RET");             --副本进入消息返回
    GEN_EVENT("MAP_ENTER_LOAD");                --副本进入加载阶段
    GEN_EVENT("MAP_ENTER_FINISH");              --副本进入更新阶段(完全进入副本)
    
    --主角状态
	GEN_GROUP("PLAYER");
    GEN_EVENT("PLAYER_AUTOFIGHT");              --自动战斗
    GEN_EVENT("PLAYER_CASTSKILL");              --释放技能
    GEN_EVENT("PLAYER_CDENTER");                --技能冷却开始
    GEN_EVENT("PLAYER_CDUPDATE");               --技能冷却刷新
    GEN_EVENT("PLAYER_CDFINISH");               --技能冷却结束
    GEN_EVENT("PLAYER_CUSTOM_MOVE");            --主动移动
    GEN_EVENT("PLAYER_PATHFINDING");		    --玩家寻路中
    GEN_EVENT("PLAYER_REQ_RIDE_ON");            --请求上坐骑
    GEN_EVENT("PLAYER_REQ_RIDE_OFF");		    --请求下坐骑
    GEN_EVENT("PLAYER_OWNED_NPC_UPDATE");		--归属于玩家的NPC刷新
    GEN_EVENT("PLAYER_ATT_UPDATE");		        --玩家属性变化
    GEN_EVENT("PLAYER_POS_UPDATE");		        --玩家位置变化
    GEN_EVENT("PLAYER_ENTER_NPC_AREA");		    --玩家进入NPC交互范围
    GEN_EVENT("PLAYER_LEAVE_NPC_AREA");		    --玩家离开NPC交互范围
    GEN_EVENT("PLAYER_SHOWATTRTIPS")            --展示角色属性界面各种属性tips
    GEN_EVENT("PLAYER_EXP_ADD");                --经验增加
    GEN_EVENT("PLAYER_EXP_OVERFLOW");		    --经验获取
end

return EventDefine_Entity;