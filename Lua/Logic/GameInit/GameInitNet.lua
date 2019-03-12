module("GameInit",package.seeall);

function InitNet()
    local GameNet = GameNet;

    --登录
    GameNet.Reg(NetCA_pb.ACLoginRe, LoginMgr.OnReceiveGateLoginRe, LoginMgr.OnReceiveGateLoginRe);
    GameNet.Reg(NetCW_pb.WCCreateRoleRe, LoginMgr.OnCreateRoleRe);
    GameNet.Reg(NetCW_pb.WCSelectRoleRe, LoginMgr.OnSelectRoleRe, LoginMgr.OnSelectRoleRe);
    GameNet.Reg(NetCL_pb.LCLoginRe, LoginMgr.OnLoginLoginRe, LoginMgr.OnLoginLoginRe);

    --登录数据同步
    GameNet.Reg(NetCS_pb.SCRoleClient, GameInit.InitPlayer);

    --引导
    --GameNet.Reg(NetCS_pb.SCSyncGuideProgress, GuideMgr.SyncGuideProgress);
    --解锁
    --GameNet.Reg(NetCS_pb.SCAddModule, ModuleMgr.OnAddModule);

    --排行榜
    GameNet.Reg(NetCT_pb.TCGetRankList, RankMgr.UpdateRankResault);
    
    --充值
    GameNet.Reg(NetCS_pb.SCAskPayInfo,ChargeMgr.OnInitCharge);

    --技能
    --GameNet.Reg(NetCS_pb.SCSkillLevelUp, SkillMgr.OnSkillLevelUp);
    --GameNet.Reg(NetCS_pb.SCSkillLevelUpNotify, SkillMgr.OnSkillLevelUpNotify);
    --GameNet.Reg(NetCS_pb.SCSkillMoveToPos, SkillMgr.OnSkillEquiped);
    GameNet.Reg(NetCS_pb.SCOrgSkillInfoRet, SkillMgr.OnGetCommonSkillInfo);               --获得江湖技能信息
    GameNet.Reg(NetCS_pb.SCAmusSkillInfoRet, SkillMgr.OnGetInterestSkillInfo);              --获得趣味技能信息
    GameNet.Reg(NetCS_pb.SCSkillSdShowInfoRet, SkillMgr.OnGetInterestSkillSlotInfo);            --获得趣味技能槽数据
    GameNet.Reg(NetCS_pb.SCComSkillLiftLevelRet, SkillMgr.OnNormalSkillLevelUp);               --普通技能升级
    GameNet.Reg(NetCS_pb.SCComSkillUpdate, SkillMgr.OnNormalSkillUpdate);                   --普通技能解锁/删除
    GameNet.Reg(NetCS_pb.SCOrgSkillLearnRet, SkillMgr.OnCommonSkillStudy);                     --江湖技能学习
    GameNet.Reg(NetCS_pb.SCOrgSkillFittingRet, SkillMgr.OnCommonSkillEquip);                    --江湖技能装备
    GameNet.Reg(NetCS_pb.SCOrgSkillLiftStarRet, SkillMgr.OnCommonSkillLevelUp);                 --江湖技能升星
    GameNet.Reg(NetCS_pb.SCAmusSkillUpdate, SkillMgr.OnInterestSkillUpdate);                    --趣味技能更新
    GameNet.Reg(NetCS_pb.SCAmusSkillFittingRet, SkillMgr.OnInterestSkillEquip);                 --趣味技能装配

    --活跃度
    GameNet.Reg(NetCS_pb.SCActivityInfo, VitalityMgr.OnSetAitalityInfo);
    GameNet.Reg(NetCS_pb.SCActivityDrawValue, VitalityMgr.OnGetVitalityAward);
    GameNet.Reg(NetCS_pb.SCActivityEnd, VitalityMgr.OnActivityComplete);
    GameNet.Reg(NetCS_pb.SCActivityUpdateRecommend, VitalityMgr.OnRecommendActivityUpdated);
    GameNet.Reg(NetCS_pb.SCActivityItemChange, VitalityMgr.OnInitColorItemList);
    GameNet.Reg(NetCS_pb.SCActivitySavePic, VitalityMgr.OnGetFillImageArea);
    GameNet.Reg(NetCS_pb.SCActivityChange, VitalityMgr.OnResetVitality);

    --背包
    GameNet.Reg(NetCS_pb.SCBagGetInfoRe, BagMgr.OnHandleBagData);                    --获取背包数据的回调
    GameNet.Reg(NetCS_pb.SCBagArrangeRe, BagMgr.OnHandleArrangeBag);                 --整理的回调
    GameNet.Reg(NetCS_pb.SCBagSyncItem, BagMgr.OnHandleBagItemUpdate);               --更新物品的回调
    GameNet.Reg(NetCS_pb.SCBagDepotUnlockRe, BagMgr.OnHandleUnlockDepot);            --解锁仓库的回调
    GameNet.Reg(NetCS_pb.SCBagUseItemRe, BagMgr.OnHandleUseBagItem);                 --使用物品的回调
    GameNet.Reg(NetCS_pb.SCBagDecomposeItemRe, BagMgr.OnHandleDecomposeBagItem);     --分解物品的回调
    GameNet.Reg(NetCS_pb.SCBagUnlockRe, BagMgr.OnHandleUnlockBagGrid);               --解锁物品的回调
    GameNet.Reg(NetCS_pb.SCBagTransferRe, BagMgr.OnHandleMoveBagItem);               --移动物品的回调
    GameNet.Reg(NetCS_pb.SCCoinGetInfoRe, BagMgr.OnHandleCoinInfo);                  --获取货币的回调
    GameNet.Reg(NetCS_pb.SCCoinSync, BagMgr.OnHandleCoinSync);                       --同步货币的回调
    GameNet.Reg(NetCS_pb.SCBagDepotRenameRe, BagMgr.OnHandleRenameDepot);            --仓库重命名的回调
    GameNet.Reg(NetCS_pb.SCCommPrize, BagMgr.OnHandleCurrencyItemPrize);             --奖励通知，包括货币，经验
    GameNet.Reg(NetCS_pb.SCBagCoinExchangeRe, BagMgr.OnHandleCoinExchange);          --货币兑换
    GameNet.Reg(NetCS_pb.SCBagUseItemReEx, BagMgr.OnHandleUseMultiBagItems);         --批量使用物品
    GameNet.Reg(NetCS_pb.SCGetBackFastRe, BagMgr.OnHandleClearTempBag);              --一键取回
    GameNet.Reg(NetCS_pb.SCBagSyncItemMessage, BagMgr.OnHandleBagSyncItemMessage);   --获得物品的通知
    GameNet.Reg(NetCS_pb.SCBagItemToMail, BagMgr.OnHandleBagItemToMail);             --获得物品进入邮件的通知
    GameNet.Reg(NetCS_pb.SCBagSyncCoinMessage, BagMgr.OnHandleCoinSyncItemMessage);             --获得物品进入邮件的通知

    --宝石
    GameNet.Reg(NetCS_pb.SCInsetGem, GemInlayMgr.SCInlayGem);
    GameNet.Reg(NetCS_pb.SCRemoveGem, GemInlayMgr.SCRemoveGem);
    GameNet.Reg(NetCS_pb.SCGemCompose,GemLevelupMgr.OnSCGemCompose);

    --签到
    GameNet.Reg(NetCS_pb.SCSignInfo, BenefitsMgr.InitDailySignInfo);
    GameNet.Reg(NetCS_pb.SCSign, BenefitsMgr.UpdateDailySignIn);
    GameNet.Reg(NetCS_pb.SCGetConsecutive, BenefitsMgr.UpdateConsecutive);
    GameNet.Reg(NetCS_pb.SCFillCheck, BenefitsMgr.UpdateFillCheck);
    GameNet.Reg(NetCS_pb.SCRefreshToday, BenefitsMgr.UpdateTodayPrize);

    --七日
    GameNet.Reg(NetCS_pb.SCSyncDaysSignInfo, SevenDayLoginMgr.OnGetSevenDayData);
    GameNet.Reg(NetCS_pb.SCGetDaysSignAwardRe, SevenDayLoginMgr.OnGetAward);
    GameNet.Reg(NetCS_pb.SCDoDaysSignWishRe, SevenDayLoginMgr.OnWish);
    GameNet.Reg(NetCS_pb.SCGetSignGiftPacksRe, SevenDayLoginMgr.OnGetGift);

    --拼图
    GameNet.Reg(NetCS_pb.SCPuzzleMapInit, PuzzleMgr.OnGetPieceIdNums);
    GameNet.Reg(NetCS_pb.SCPuzzleOnOff, PuzzleMgr.OnInset);
    GameNet.Reg(NetCS_pb.SCPuzzleTakeReward, PuzzleMgr.OnGetAward);
    GameNet.Reg(NetCS_pb.SCPuzzleChoseReward, PuzzleMgr.OnChoseAward);

    --商城
    GameNet.Reg(NetCW_pb.WCAskShopGoodsSpecialInfoRet, CommerceMgr.OnGoodsSpecInfo);
    GameNet.Reg(NetCS_pb.SCShopBuyRet, CommerceMgr.OnBuy);
    GameNet.Reg(NetCS_pb.SCShopSellRet, CommerceMgr.OnSell);

    --聊天
    GameNet.Reg(NetCW_pb.WCChatToken, ChatMgr.OnReceiveToken);
    GameNet.Reg(NetCW_pb.WCLoginSDKEnd, ChatMgr.OnLoginSDKEnd);
    GameNet.Reg(NetCW_pb.WCChatRoomSay, ChatMgr.OnChatRoomSay);
    GameNet.Reg(NetCW_pb.WCChatJoinRoom, ChatMgr.OnJoinRoom);
    GameNet.Reg(NetCS_pb.SCSystemInfo, ChatMgr.OnSystemInfo);
    GameNet.Reg(NetCW_pb.WCSendMessage, ChatMgr.OnErrorInfo);

    --好友
    GameNet.Reg(NetCS_pb.SCGiveGiftsRet, GiftMgr.OnSCGiveGiftsRet);

    --称号
    GameNet.Reg(NetCS_pb.SCTitleInfo, TitleMgr.RetTitleInfo);
    GameNet.Reg(NetCS_pb.SCSetTitle, TitleMgr.RetUseTitle);
    GameNet.Reg(NetCS_pb.SCAddTitle, TitleMgr.RetOpenTitleState);
    GameNet.Reg(NetCS_pb.SCAddCustomTitle, TitleMgr.RetAddUserDefineTitle);
    GameNet.Reg(NetCS_pb.SCUpdateCustomTitle, TitleMgr.RetUpdateUserDefineTitle);
    GameNet.Reg(NetCS_pb.SCDeleteTitle, TitleMgr.RetCloseTile);
    GameNet.Reg(NetCS_pb.SCBroadTitleInfo,TitleMgr.RetRefreshPlayerTitle);

    --成就
    GameNet.Reg(NetCS_pb.SCSyncAchievementInfo, AchievementMgr.OnReceiveSyncAchievementInfo);
    GameNet.Reg(NetCS_pb.SCFinishAchievement, AchievementMgr.OnReceiveFinishAchievement);
    GameNet.Reg(NetCS_pb.SCSyncAchievementSys, AchievementMgr.OnReceiveSyncAchievementSys);
    GameNet.Reg(NetCS_pb.SCGetAchievementReward,AchievementMgr.OnReceiveGetAchieveReward);

    --AI宠物
    GameNet.Reg(NetCS_pb.SCAIpetGetDataRet, AIPetMgr.OnGetAllAIPetData);
    GameNet.Reg(NetCS_pb.SCAIpetStateRet, AIPetMgr.OnSetPetInUse);
    GameNet.Reg(NetCS_pb.SCAIpetClothesRet, AIPetMgr.OnSetPetClothes);
    GameNet.Reg(NetCS_pb.SCAIpetClotheUpdate,AIPetMgr.OnUpdatePetClothes);
    GameNet.Reg(NetCS_pb.SCAIpetInfoUpdate,AIPetMgr.OnUpdatePetState);

    --宠物
    GameNet.Reg(NetCS_pb.SCPetsInfo, PetMgr.OnSCGetPetInfo);
    GameNet.Reg(NetCS_pb.SCPetRename, PetMgr.OnPetReName);
    GameNet.Reg(NetCS_pb.SCPetAddPoint, PetMgr.OnPetAddPoint);
    GameNet.Reg(NetCS_pb.SCPetUpdate, PetMgr.OnUpdateOnePet);
    GameNet.Reg(NetCS_pb.SCOptPet, PetMgr.OnSCOptPet);
    GameNet.Reg(NetCS_pb.SCPetSetPointRule, PetMgr.OnRuleChanged);
    GameNet.Reg(NetCS_pb.SCChangeSkill, PetMgr.OnSCChangeSkill);
    GameNet.Reg(NetCS_pb.SCPetAffinationRet, PetMgr.OnSCPetAffinationRet)
    GameNet.Reg(NetCS_pb.SCComposePetsRet,PetMgr.OnSCComposePetsRet)
    GameNet.Reg(NetCS_pb.SCPetResetPoint, PetMgr.OnPetResetPoint);
    GameNet.Reg(NetCS_pb.SCPetSkillStudyRet, PetMgr.OnSCPetSkillStudyRet);
    GameNet.Reg(NetCS_pb.SCOnPetLevelup,PetMgr.OnPetLevelup)
    --GameNet.Reg(NetCS_pb.SCBroadCastPetInfo, PetMgr.OnSCBroadCastPetInfo)

    --助战
    GameNet.Reg(NetCS_pb.SCFightAssistGetDataRet, FightHelpMgr.OnGetFightHelpInfo);
    GameNet.Reg(NetCS_pb.SCCombatElfLiftStarRet, FightHelpMgr.OnFightHelperStarLevelUp);
    GameNet.Reg(NetCS_pb.SCFtAtProjectCbEfOperRet, FightHelpMgr.OnFightHelperActive);
    GameNet.Reg(NetCS_pb.SCFtAtProjectCbEfSwapRet, FightHelpMgr.OnFightHelperActive);
    GameNet.Reg(NetCS_pb.SCFightAssistWeekGratisRet, FightHelpMgr.OnGetFreeFightHelperInfo);
    GameNet.Reg(NetCS_pb.SCFtAtProjectUsedRet, FightHelpMgr.OnSetFormationItemUsed);
    GameNet.Reg(NetCS_pb.SCCombatElfGetUtDataRet, FightHelpMgr.OnFightHelperStateChanged);
    GameNet.Reg(NetCS_pb.SCSyncCombatElfDebeisInfo, FightHelpMgr.OnFightHelperFragmentCountChanged);
    GameNet.Reg(NetCS_pb.SCCombatElfEnlistRet, FightHelpMgr.OnRecruitFightHelper);
    GameNet.Reg(NetCS_pb.SCUpdateCombatElfInfo, FightHelpMgr.OnGetNewFightHelper);

    --邮件
    GameNet.Reg(NetCS_pb.SCMailDel, MailMgr.OnSCMailDel)
    GameNet.Reg(NetCS_pb.SCMailGetAttach, MailMgr.OnSCMailGetAttach)
    GameNet.Reg(NetCT_pb.TCMailNew, MailMgr.OnTCMailNew)

    --帮会
    GameNet.Reg(NetCS_pb.SCCreateGuild, GangMgr.OnCreate)
    GameNet.Reg(NetCT_pb.TCAskGuildInfo, GangMgr.OnGetGangInfo)
    GameNet.Reg(NetCT_pb.TCAskGuildMember, GangMgr.OnGetGangMemberList)
    GameNet.Reg(NetCT_pb.TCAskGuildApplyList, GangMgr.OnGetApplyList)
    GameNet.Reg(NetCT_pb.TCAskGuildList, GangMgr.OnGetMoreGangList)
    GameNet.Reg(NetCT_pb.TCReplyGuildApply, GangMgr.OnReplyJoin)
    GameNet.Reg(NetCT_pb.TCAskEnterGuild, GangMgr.OnJoinResult)
    GameNet.Reg(NetCT_pb.TCQuickAskEnterGuild, GangMgr.OnQuickJoinResult)
    GameNet.Reg(NetCT_pb.TCEnterGuildSucceed, GangMgr.OnJoinGangSuccess)
    GameNet.Reg(NetCT_pb.TCKickMember, GangMgr.OnKickResult)
    GameNet.Reg(NetCT_pb.TCLeaveGuild, GangMgr.OnLeaveGang)
    GameNet.Reg(NetCT_pb.TCMemberChange, GangMgr.OnMemberChange)
    GameNet.Reg(NetCS_pb.SCGetRoleGuild, GangMgr.OnGetGangRoleInfo)
    GameNet.Reg(NetCT_pb.TCReplyApplyResult, GangMgr.OnReplyJoinToMe)
    GameNet.Reg(NetCT_pb.TCTaridKickMember, GangMgr.OnKickMe)
    GameNet.Reg(NetCT_pb.TCQuickReplyGuildApply, GangMgr.OnQuickReplyJoin)
    GameNet.Reg(NetCT_pb.TCGuildRecommend, GangMgr.OnGetRecommendList)
    GameNet.Reg(NetCT_pb.TCSetGuildCheck, GangMgr.OnSetGangCheck)

    --修炼
    GameNet.Reg(NetCS_pb.SCAskPracticeInfo, PracticeMgr.OnHandlePracticeInfo)

    --坐骑
    GameNet.Reg(NetCS_pb.SCRideOperate,RideMgr.OnRideOperate)

    --功能解锁
    GameNet.Reg(NetCS_pb.SCFuncUnlockInfo,FunUnLockMgr.OnInitFunUnlockInfo)
    GameNet.Reg(NetCS_pb.SCFuncUnlockEvent,FunUnLockMgr.OnUnlockFun)

    --装备打造
    GameNet.Reg(NetCS_pb.SCMakeEquip,EquipMakeModule.SCMakeEquipHandler)
    GameNet.Reg(NetCS_pb.SCAskMakeValueReward,EquipMakeModule.SCAskMakeValueRewardHandler)
    
end

return GameInit;