
--帮派
local UIGROUP_GANG = AllUI.GetGroupID();
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Gang/UI_Gang_Main");
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Gang/UI_Gang_Info",UIGROUP_GANG);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Gang/Member/UI_Gang_Member",UIGROUP_GANG);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gang/Member/UI_Gang_MemberList",UIGROUP_GANG);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gang/Member/UI_Gang_ApplyList",UIGROUP_GANG);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Gang/UI_Gang_Create",UIGROUP_GANG);
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Gang/UI_Gang_List",UIGROUP_GANG);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Gang/UI_Gang_Recommend",UIGROUP_GANG);
AllUI.DEFINE_UI(-2,"UI/UI_Race",0,200);
--个人空间
local UIGROUP_PSPACE = AllUI.GetGroupID();
AllUI.DEFINE_UI(2, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Main");
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Moments",UIGROUP_PSPACE);
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_MsgBoard",UIGROUP_PSPACE);
AllUI.DEFINE_UI(3, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Memory",UIGROUP_PSPACE);
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Info",UIGROUP_PSPACE);
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Tag",UIGROUP_PSPACE);
AllUI.DEFINE_UI(5, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_InfoSetting",UIGROUP_PSPACE);
AllUI.DEFINE_UI(6, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_AddTags",UIGROUP_PSPACE);
AllUI.DEFINE_UI(5, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_EditorMsg",UIGROUP_PSPACE);
AllUI.DEFINE_UI(6, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_ImageView",UIGROUP_PSPACE);
AllUI.DEFINE_UI(5, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Voice",UIGROUP_PSPACE);
AllUI.DEFINE_UI(5, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_HeadIcon",UIGROUP_PSPACE);

AllUI.DEFINE_UI(3, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Other",UIGROUP_PSPACE);
AllUI.DEFINE_UI(5, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_OtherInfo",UIGROUP_PSPACE);
AllUI.DEFINE_UI(5, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_OtherTag",UIGROUP_PSPACE);
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_OtherMoments",UIGROUP_PSPACE);
AllUI.DEFINE_UI(4, "Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_OtherMsgBoard",UIGROUP_PSPACE);
AllUI.DEFINE_UI(6, "Logic/Presenter/UI/PersonalSpace/UI_PickUpView",UIGROUP_PSPACE);



--好友----------uiLayer, uiPath, uiGroup, uiPanelDepth, uiBackBox)
local UIGROUP_FRIEND = AllUI.GetGroupID();
AllUI.DEFINE_UI(-2,"Logic/Presenter/UI/Friend/UI_Relation",nil,nil,1);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Friend/UI_Friend_Main",UIGROUP_FRIEND);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Friend/UI_Friend_Ask",UIGROUP_FRIEND,nil,1);
AllUI.DEFINE_UI(6,"Logic/Presenter/UI/Friend/UI_Shortcut_Player",UIGROUP_FRIEND);
AllUI.DEFINE_UI(5,"Logic/Presenter/UI/Friend/UI_Friend_EditGroup",UIGROUP_FRIEND,nil,1);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Friend/UI_Friend_Remark", UIGROUP_FRIEND,nil,1);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Friend/UI_Friend_FriendRecommend", UIGROUP_FRIEND,nil,1);
AllUI.DEFINE_UI(5,"Logic/Presenter/UI/Friend/UI_Friend_RecommendSetting", UIGROUP_FRIEND,nil,1);

AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Friend/UI_Friend_NewQun", UIGROUP_FRIEND,nil,1);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Friend/UI_Friend_QunAddPlayer", UIGROUP_FRIEND,nil,1);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Friend/UI_Shortcut_Qun", UIGROUP_FRIEND);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Friend/UI_Friend_QunInfo", UIGROUP_FRIEND,nil,1);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Friend/UI_Friend_QunApply", UIGROUP_FRIEND,nil,1);
AllUI.DEFINE_UI(5,"Logic/Presenter/UI/Friend/UI_Friend_Settings", UIGROUP_FRIEND,nil,1);

--聊天
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Chat/Main/UI_Chat_Main");
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Chat/UI_Chat_Setting");
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/UI_Chat_Bubble", 0, 20);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/Link/UI_Chat_CommonLink",0,700);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/MyCollect/UI_Chat_MyCollect",0,700);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/MyCollect/UI_Chat_MyCollectHelp",0,1000);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/UI_Chat_AddBtnList",0,1000);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/UI_Chat_EmojiOperList",0,800);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/UI_Chat_EmojiPic",0,1100);
AllUI.DEFINE_UI(-4,"Logic/Presenter/UI/Chat/UI_Chat_Paint");
AllUI.DEFINE_UI(-11,"Logic/Presenter/UI/Chat/UI_Chat_Bullet");
AllUI.DEFINE_UI(-11,"Logic/Presenter/UI/Chat/UI_Chat_Bullet_Tip");
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/EmojiLibrary/UI_EmojiLibrary",0,800);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/AddOneEmoji/UI_AddOneEmoji",0,900);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/AddOneEmoji/UI_AddOnePkg",0,900);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/AddOneEmoji/UI_EmojiInfo",0,900);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Chat/AddOneEmoji/UI_PkgInfo",0,900);

--送礼物
local UIGROUP_GIFT = AllUI.GetGroupID();
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Gift/UI_Gift_Main",UIGROUP_GIFT);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Gift/UI_GiftSend_Main",UIGROUP_GIFT);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gift/UI_GiftSend_FreePanel",UIGROUP_GIFT);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gift/UI_GiftSend_CostPanel",UIGROUP_GIFT);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gift/UI_GiftSend_CustomPanel",UIGROUP_GIFT);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gift/UI_GiftSend_MemorialPanel",UIGROUP_GIFT);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gift/UI_Gift_EditorLetter",UIGROUP_GIFT);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gift/UI_Gift_RecordReceive",UIGROUP_GIFT);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Gift/UI_Gift_RecordSend",UIGROUP_GIFT);
