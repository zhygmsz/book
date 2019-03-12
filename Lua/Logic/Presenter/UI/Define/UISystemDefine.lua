
--任务
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Task/UI_Task_Main");
--成就(uiLayer, uiPath, uiGroup, uiPanelDepth, uiBackBox)
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Achievement/UI_Achievement", nil,nil,1);
--称号
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/TitleSystem/UI_Title", nil,nil,1);
--排行榜
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Rank/UI_RankList");
--技能界面
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Skill/UI_Skill_Main");
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Skill/UI_Skill_Detail");
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Skill/UI_Skill_Base");
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Skill/UI_Skill_Common");
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Skill/UI_Skill_Interest");
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Skill/UI_Tip_SkillInfo");
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Practice/UI_Practice");
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Skill/UI_Skill_AotoSet");

--交易系列
local UIGROUP_EXCHANGE = AllUI.GetGroupID();
AllUI.DEFINE_UI(-3,"Logic/Presenter/UI/Exchange/UI_Exchange",UIGROUP_EXCHANGE,350);
AllUI.DEFINE_UI(-4,"Logic/Presenter/UI/Exchange/UI_Charge_Main",UIGROUP_EXCHANGE);--充值主界面
AllUI.DEFINE_UI(-4,"Logic/Presenter/UI/Exchange/UI_Charge_Recharge",UIGROUP_EXCHANGE);--充值
AllUI.DEFINE_UI(-4,"Logic/Presenter/UI/Exchange/UI_Charge_Rebate",UIGROUP_EXCHANGE);--累冲返利
AllUI.DEFINE_UI(-5,"Logic/Presenter/UI/Exchange/UI_Charge_Instruction",UIGROUP_EXCHANGE);--充值说明
AllUI.DEFINE_UI(-4,"Logic/Presenter/UI/Exchange/UI_ChargeFirst",UIGROUP_EXCHANGE,450);--首充奖励

--商店系列
local UIGROUP_SHOP = AllUI.GetGroupID();
--商店主界面
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Shop/UI_Shop_Main",UIGROUP_SHOP);
--商会
AllUI.DEFINE_UI(-4,"Logic/Presenter/UI/Shop/Commerce/UI_Shop_Commerce",UIGROUP_SHOP);

--摆摊
--AllUI.DEFINE_UI(3,"UI/UI_Shop_Stall",UIGROUP_SHOP);
--商城
AllUI.DEFINE_UI(-4,"Logic/Presenter/UI/Shop/Store/UI_Shop_Store",UIGROUP_SHOP);


--地图
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Map/UI_BigMap");

--福利界面
local UIGROUP_WELFARE = AllUI.GetGroupID();
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Welfare/UI_Welfare_Main",UIGROUP_WELFARE);
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Welfare/UI_Welfare",UIGROUP_WELFARE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Welfare/SevenDay/UI_SevenDayLogin",UIGROUP_WELFARE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Welfare/Puzzle/UI_Puzzle",UIGROUP_WELFARE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Welfare/DailySign/UI_Welfare_DailySign",UIGROUP_WELFARE);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Welfare/DailySign/UI_Welfare_SignResault",UIGROUP_WELFARE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Welfare/UI_Welfare_MonthCard",UIGROUP_WELFARE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Welfare/UI_Welfare_Weekly",UIGROUP_WELFARE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Welfare/UI_Welfare_Subscribe",UIGROUP_WELFARE);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Welfare/UI_Welfare_MonthCard_buy",UIGROUP_WELFARE,150);



--强化界面
local UIGROUP_INTENSIFY = AllUI.GetGroupID()
--强化主界面
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Intensify/UI_Intensify_Main", UIGROUP_INTENSIFY)
--宝石镶嵌
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/Intensify/Inlay/UI_Intensify_Inlay", UIGROUP_INTENSIFY)
--宝石升级
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/Intensify/GemLevelup/UI_Intensify_GemLevelup", UIGROUP_INTENSIFY)
--装备打造
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/Intensify/Make/UI_Intensify_Make", UIGROUP_INTENSIFY)

--活跃度
local UIGROUP_VITALITY = AllUI.GetGroupID()
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Vitality/UI_Vitality_Main", UIGROUP_VITALITY);
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/Vitality/UI_Vitality_News", UIGROUP_VITALITY);
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/Vitality/UI_Vitality_Calendar", UIGROUP_VITALITY);
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/Vitality/UI_Vitality_Week", UIGROUP_VITALITY);
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/Vitality/UI_Tip_Activity", UIGROUP_VITALITY);

--AIPet宠物
local UIGROUP_AIPET = AllUI.GetGroupID()
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/AIPet/UI_AIPet_Home",UIGROUP_AIPET);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/AIPet/UI_AIPet_Clothes",UIGROUP_AIPET);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/AIPet/UI_AIPet_Settings",UIGROUP_AIPET);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/AIPet/UI_AIPet_Select",UIGROUP_AIPET,nil,0);

--宠物
local UIGROUP_PET = AllUI.GetGroupID()
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Pet/UI_Pet_Main", UIGROUP_PET, nil, 1)
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/Pet/PetBaseAttr/UI_Pet_Attr", UIGROUP_PET)
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/Pet/PetBaseAttr/UI_Pet_AddPoint", UIGROUP_PET)
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/Pet/PetBaseAttr/UI_Pet_ReName", UIGROUP_PET)
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/Pet/PetBaseAttr/UI_Pet_Tips", UIGROUP_PET)

AllUI.DEFINE_UI(3 ,"Logic/Presenter/UI/Pet/Affination/UI_Pet_Affination", UIGROUP_PET)
AllUI.DEFINE_UI(3 ,"Logic/Presenter/UI/Pet/Compose/UI_Pet_Compose", UIGROUP_PET)
AllUI.DEFINE_UI(3 ,"Logic/Presenter/UI/Pet/Compose/UI_Pet_ComposeResult", UIGROUP_PET)

--助战
local UIGROUP_FIGHTHELP = AllUI.GetGroupID();
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/FightHelp/UI_FightHelp_Main", UIGROUP_FIGHTHELP);
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/FightHelp/UI_FightHelp_Config", UIGROUP_FIGHTHELP);
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/FightHelp/UI_FightHelp_Handbook", UIGROUP_FIGHTHELP);
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/FightHelp/UI_FightHelp_Info", UIGROUP_FIGHTHELP);
AllUI.DEFINE_UI(5, "Logic/Presenter/UI/FightHelp/UI_Tip_FightHelpSkill", UIGROUP_FIGHTHELP);
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/FightHelp/UI_FightHelp_Recruit", UIGROUP_FIGHTHELP);

--邮件
local UIGROUP_MAIL = AllUI.GetGroupID()
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/Mail/UI_Mail",UIGROUP_MAIL)

--设置
local UIGROUP_SETTING = AllUI.GetGroupID()
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Setting/UI_Setting",UIGROUP_SETTING)
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Setting/UI_Setting_Basis",UIGROUP_SETTING,201)
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Setting/UI_Setting_Basis_Voice",UIGROUP_SETTING,202)
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Setting/UI_Setting_Basis_Picture",UIGROUP_SETTING,202)
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Setting/UI_Setting_Basis_Fight",UIGROUP_SETTING,202)
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/Setting/UI_Setting_Basis_Other",UIGROUP_SETTING,202)

--飞图标
local UIGROUP_FLYITEM = AllUI.GetGroupID()
AllUI.DEFINE_UI(-8, "Logic/Presenter/UI/ItemFlying/UI_Item_Flying", UIGROUP_FLYITEM)

--信封
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Envelope/UI_Envelope");

--锁屏
AllUI.DEFINE_UI(10,"Logic/Presenter/UI/LockScreen/UI_LockScreen");
