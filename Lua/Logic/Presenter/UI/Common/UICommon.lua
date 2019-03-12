--注册通用组件
require("Logic/Presenter/UI/UIUtil");

--table Grid相关辅助
require("Logic/Presenter/UI/Common/UIScrollGridTable");
require("Logic/Presenter/UI/Common/UIGridTableUtil");
require("Logic/Presenter/UI/Common/UIScrollDropItemGrid");--掉落可拖拽Item Grid
require("Logic/Presenter/UI/Common/UICommonDropItemGrid");--掉落不可拖拽Item Grid
require("Logic/Presenter/UI/Common/UICommonItemListGrid");--Item列表展示

-- UITableWrapContentEx.cs 的封装，多用在聊天相关界面
require("Logic/Presenter/UI/Common/UITableWrap/BaseWrapTableEx");

--UIWrapContent相关
require("Logic/Presenter/UI/Common/UIWrapContent/BaseWrapContent");
require("Logic/Presenter/UI/Common/UIWrapContent/BaseWrapContentEx");
require("Logic/Presenter/UI/Common/UIWrapContent/BaseWrapContentData");
require("Logic/Presenter/UI/Common/UIWrapContent/WrapContentDataHelper");
require("Logic/Presenter/UI/Common/UIWrapContent/BaseWrapContentUI");

--for collapse table wrap content
require("Logic/Presenter/UI/Common/UICollapseTableWrap/UICommonCollapseTableWrap");
require("Logic/Presenter/UI/Common/UICollapseTableWrap/UICommonCollapseWrapData");
require("Logic/Presenter/UI/Common/UICollapseTableWrap/UICommonCollapseWrapUI");

--wrapData
require("Logic/Presenter/UI/Common/UITableWrap/BaseWrapData");
require("Logic/System/SocialNetwork/Entity/Chat/ChatData/FriendChatDataBase");
require("Logic/System/SocialNetwork/Entity/Chat/ChatData/FriendChatVoiceData");

--common input panel with emoji;
require("Logic/Presenter/UI/Common/Emoji/UI_Input_WithEmoji");
--common label with emoji;
require("Logic/Presenter/UI/Common/Emoji/UILabel_WithEmoji");
require("Logic/Presenter/UI/Common/Emoji/UIMsgCommonFactory");
--Chat UIInput With Emoji
require("Logic/Presenter/UI/Chat/ChatInputWrap");
require("Logic/Presenter/UI/Chat/MsgCommonWrap");

--PopupScrollList
require("Logic/Presenter/UI/Common/UICommonPopupScrollList");
require("Logic/Presenter/UI/Common/UITweenOutBack");
require("Logic/Presenter/UI/Common/UICommonLuaInput");

--UIToggle--基于UIToggle的封装
require("Logic/Presenter/UI/Common/UIToggle/UIToggleGroup");
--基于UIEvent的自定义UIToggle
require("Logic/Presenter/UI/Common/UIToggle/ToggleItemGroup");
require("Logic/Presenter/UI/Common/UIToggle/ToggleGroupGo")
require("Logic/Presenter/UI/Common/UIToggle/ToggleGroupUIMgr")

--数字图片
require("Logic/Presenter/UI/Common/UISpriteNumber");

require("Logic/Presenter/UI/Common/UITimePoll");

--需要提前注册的UI
require("Logic/Presenter/UI/Exchange/UI_Exchange");
require("Logic/Presenter/UI/Gift/UI_Gift_Main");
require("Logic/Presenter/UI/Friend/UI_Shortcut_Player");
require("Logic/Presenter/UI/Friend/UI_Shortcut_Qun");
require("Logic/Presenter/UI/Friend/UI_Relation");



