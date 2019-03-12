module("GameInit",package.seeall)

function InitSystem()
	--[[
		这里的初始化是针对各个模块基础代码的初始化,这个时候玩家还没有登录,表数据也没读取结束
		规范
			一个模块占一行,结尾加上模块名字简单注释
	--]]

	--战斗逻辑
	RequireModule("Logic/System/Map/MapMgr");
	RequireModule("Logic/Entity/EntityModule");

	--表现逻辑
	RequireModule("Logic/Presenter/Tip/TipsMgr");					--游戏通用提示
	RequireModule("Logic/Presenter/HP/HpNameMgr");					--血条姓名版

	RequireModule("Logic/Presenter/Story/SequenceMgr");				--游戏剧情管理 
	RequireModule("Logic/Presenter/Story/QTEMgr");					--快速反应事件(在一定情况下监听玩家即时行为)
	RequireModule("Logic/Presenter/Story/DialogMgr")				--对话
	RequireModule("Logic/Presenter/Story/VideoMgr")					--游戏内视频
	RequireModule("Logic/Presenter/Story/CGMgr")					--启动CG视频
	
	--系统逻辑
	RequireModule("Logic/System/Sdk/SdkMgr");						--SDK
	RequireModule("Logic/System/Login/LoginMgr");					--登录
	RequireModule("Logic/System/Action/ActionMgr");					--功能
	RequireModule("Logic/System/Task/TaskMgr");						--任务
	RequireModule("Logic/System/Rank/RankMgr");						--排行
	RequireModule("Logic/System/Skill/SkillMgr");					--技能
	RequireModule("Logic/System/Vitality/VitalityMgr");				--活跃度
	RequireModule("Logic/System/BigMap/BigMapMgr");					--大地图

	RequireModule("Logic/System/Bag/BagMgr");						--背包
	RequireModule("Logic/System/Equip/EquipMgr"); 					--装备
	RequireModule("Logic/System/Intensify/IntensifyMgr")			--强化
	RequireModule("Logic/System/Intensify/GemInlayMgr");			--宝石镶嵌
	RequireModule("Logic/System/Intensify/GemLevelupMgr")			--宝石升级

	RequireModule("Logic/System/Welfare/WelfareMgr");				--福利
	RequireModule("Logic/System/Welfare/BenefitsMgr");				--签到
	RequireModule("Logic/System/Welfare/SevenDayLoginMgr");			--七日
	RequireModule("Logic/System/Welfare/PuzzleMgr");				--拼图
	RequireModule("Logic/System/Shop/CommerceMgr");					--商会
	RequireModule("Logic/System/Welfare/AllPackageMgr")				--周礼包、月卡、订阅

	RequireModule("Logic/System/SocialNetwork/SocialNetworkMgr");	--SNS网络管理
	RequireModule("Logic/System/Social/SocialPlayerInfoMgr");		--SNS玩家信息同步	
	RequireModule("Logic/System/Chat/ChatMgr");						--聊天
	RequireModule("Logic/System/Social/PersonSpaceMgr");			--个人空间(朋友圈)
	RequireModule("Logic/System/SocialNetwork/PlayerMgr/FriendMgr"); 						--好友关系管理
	RequireModule("Logic/System/SocialNetwork/System/Recommend/FriendRecommendMgr");		--好友推荐
	RequireModule("Logic/System/SocialNetwork/System/FriendAskMgr");		--好友申请
	RequireModule("Logic/System/SocialNetwork/PlayerMgr/SocialPlayerMgr");--社交玩家信息管理
	RequireModule("Logic/System/SocialNetwork/System/SocialChatMgr");--社交服聊天
	RequireModule("Logic/System/SocialNetwork/System/FastChatMgr");--快捷聊天
	
	RequireModule("Logic/System/Gift/GiftMgr");						--好友赠送礼物

	RequireModule("Logic/System/Title/TitleMgr");					--称号系统
	RequireModule("Logic/System/Achievement/AchievementMgr");		--成就
	RequireModule("Logic/System/AIPet/AIPetMgr");					--AI语音宠物

	RequireModule("Logic/System/Pet/PetMgr");						--宠物
	RequireModule("Logic/System/GlobalMap/GlobalMapMgr");			--地图
	RequireModule("Logic/System/FightHelp/FightHelpMgr");			--助战
	
	RequireModule("Logic/System/Charge/ChargeMgr");					--充值，首充
	RequireModule("Logic/System/Mail/MailMgr")    					--邮件

	RequireModule("Logic/System/Gang/GangMgr")						--帮派
	RequireModule("Logic/System/Practice/PracticeMgr")				--帮派

	RequireModule("Logic/System/ItemFlying/ItemFlyingMgr")   		--飞图标
	RequireModule("Logic/System/Ride/RideMgr")   					--坐骑

	RequireModule("Logic/System/FunUnLock/FunUnLockMgr")   		--功能解锁
	RequireModule("Logic/Presenter/UI/Intensify/Make/EquipMakeModule")   		--装备打造
	RequireModule("Logic/System/Setting/SettingMgr")				--设置
end

return GameInit;