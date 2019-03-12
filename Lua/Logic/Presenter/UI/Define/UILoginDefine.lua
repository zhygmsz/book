--登录界面
local UIGROUP_LOGIN = AllUI.GetGroupID();
AllUI.DEFINE_UI(1,"Logic/Presenter/UI/Login/UI_Login",UIGROUP_LOGIN);
AllUI.DEFINE_UI(2,"Logic/Presenter/UI/Login/UI_Login_SelectServerRole",UIGROUP_LOGIN);
AllUI.DEFINE_UI(1,"Logic/Presenter/UI/CreateRole/UI_Login_CreateRole");
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Login/UI_Login_RoleQueue",UIGROUP_LOGIN);
AllUI.DEFINE_UI(3,"Logic/Presenter/UI/Login/UI_Login_GameBulletin",UIGROUP_LOGIN);