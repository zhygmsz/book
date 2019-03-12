--背包物品通用ITEM
local UIGROUP_PACKAGE = AllUI.GetGroupID();
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Bag/UI_Bag_Main",nil,nil,80);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Bag/UI_Bag_Package",UIGROUP_PACKAGE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Bag/UI_Bag_Equip",UIGROUP_PACKAGE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Bag/UI_Bag_Storage",UIGROUP_PACKAGE);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Bag/UI_Bag_TempPackage",UIGROUP_PACKAGE,nil,1);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Bag/UI_Bag_PlayerAtt",UIGROUP_PACKAGE);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Bag/UI_Bag_ModifyName",nil,nil,3);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Bag/UI_Bag_StorageList",nil,nil,3);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Bag/UI_Bag_GoldExchange",nil,nil,3);
AllUI.DEFINE_UI(-1,"Logic/Presenter/UI/Bag/UI_Tip_UseItem",0,160);
AllUI.DEFINE_UI(-6,"Logic/Presenter/UI/Bag/UI_Tip_ItemInfoEx");
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Bag/UI_Tip_UseMultiItems",nil,nil,3);
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Bag/UI_Tip_EquipItemInfo");
AllUI.DEFINE_UI(4,"Logic/Presenter/UI/Bag/UI_Tip_UnLockBag",nil,nil,3);
AllUI.DEFINE_UI(6,"Logic/Presenter/UI/Bag/UI_Tip_ExchangeWarning",nil,nil,3);
AllUI.DEFINE_UI(6,"Logic/Presenter/UI/Bag/UI_Tip_EnsureSupplyExchange",nil,nil,3);


