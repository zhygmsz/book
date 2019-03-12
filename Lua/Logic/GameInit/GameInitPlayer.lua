module("GameInit",package.seeall)

function InitPlayer(playerData)
	if not UserData.PlayerAtt then
		TimeUtils.SyncTimeStamp(tonumber(playerData.roleInfo.serverTime));
		UserData.PlayerAtt = EntityAttFactory.AllocEntityAtt(EntityDefine.ENTITY_TYPE.PLAYER_MAIN,playerData.roleInfo);
		UserData.PlayerID = UserData.PlayerAtt.id;

		
		--[[
			这里的初始化是针对各个依赖玩家数据的模块初始化,这个时候玩家数据已经获取到了
			规范
				函数名统一 InitModuleOnLogin
				一个模块占一行,结尾加上模块名字简单注释
		--]]
		SdkMgr.InitModuleOnLogin(UserData.PlayerID);		--SDK		
		BagMgr.InitData();									--背包
		SocialNetworkMgr.Init();							--社交服
		GiftMgr.Init();										--送礼
		AchievementMgr.Init();								--成就
		
		ChargeMgr.Init();									--充值
		AllPackageMgr.Init();								--每周特惠、月卡、订阅

		PetMgr.InitModuleOnLogin(playerData.todayFirstPetAffiantion) --玩家每日洗练次数
		GangMgr.InitModuleOnLogin();						--帮派
		--修炼初始化数据
		PracticeMgr.InitData();
		EquipMakeModule.SetCurrentMakeValue(playerData.makeValue);
	else
		EntityAttFactory.UpdatePlayerAtt(UserData.PlayerAtt,playerData.roleInfo);
	end
end

--[[
@desc: SNS社交服初始化完成后
author:{hesinian}
time:2019-01-04 16:47:23
@return:
]]
function InitSNS()
	UserData.InitSNS();

	SocialPlayerInfoMgr.InitSNS();
	
	SocialPlayerMgr.InitSNS();
	FriendMgr.InitSNS();
	FriendRecommendMgr.InitSNS();
	FriendAskMgr.InitSNS();
	SNSCustomEmojiMgr.InitSNS();
	PersonSpaceMgr.InitSNS();
	FastChatMgr.InitSNS();
	MailMgr.InitSNS();
end

--[[
@desc: 初始化客户端数据管理完成后
author:{hesinian}
time:2019-01-04 16:47:23
@return:
]]
function InitClientData()
	AIPetMgr.InitClientData();
	ChatMgr.InitClientData();
	SettingMgr.InitClientData();
end

--[[
@desc: 销毁玩家数据
author:{author}
time:2019-01-10 18:59:12
@return:
]]
function DestroyPlayer()
	UserData.PlayerAtt = nil;
	UserData.PlayerID = nil;
	AchievementMgr.DestroyPlayer();
end


