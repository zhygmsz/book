
local t = {};

t.LOG_FILTER = 
{
    "CSSyncTime","CSSyncMove","CSSyncObject",
    "SCSyncTimeRe","SCSyncMove","SCSyncObject",
}

t.SERVER_MODE = 1; --设置为1表示普通外网，2使用内网,3表示外网特别稳；

t.ALWAYS_OPEN_FUNCS = true;--设置为true，将打开所有功能UI

t.ENABLE_LOG = true;

t.SetServer = function(serverSwitch)
    t.SERVER_MODE = serverSwitch;
    t.SetURL();
end
t.GetServerMode = function()
    return t.SERVER_MODE;
end

t.LOGIN_SOCKET = 0; --login服务器
t.GATE_SOCKET = 1; --gate 服务器
t.SetURL = function()
    
    t.PHOTO_CLOUD_URL = "http://ldj-1255801262.file.myqcloud.com/";--图片墙
    t.SEMANTIC_URL = "http://154.8.217.11/semantic";
    if t.SERVER_MODE == 1 then
        t.HTTP_IP_PORT = "http://10.127.138.186:8080/";--名字服务器外网
    elseif t.SERVER_MODE == 2 then
        t.HTTP_IP_PORT = "http://10.2.9.177:8080/";--名字服务器内网        
    elseif t.SERVER_MODE == 3 then
        t.HTTP_IP_PORT = "http://211.159.168.182:8080/";--名字服务器外网特别稳      
    end

    t.SERVER_LIST_URL = t.HTTP_IP_PORT.."namesvr/serverlist.php";--服务器角色信息
    t.SDK_CHECKACCOUNT = t.HTTP_IP_PORT.."namesvr/CheckAccount.php";--服务器状态
    t.ROLE_LIST_URL = t.HTTP_IP_PORT.."namesvr/RoleList.php?account=%s";--角色列表
    t.SERVER_STATE_URL = t.HTTP_IP_PORT.."namesvr/svrliststate.php";--服务器状态
    t.FRIEND_SERVER_URL = t.HTTP_IP_PORT.."index.php";--社交服 "http://10.12.20.82:80/"
    t.CLIENT_DATA_URL = t.HTTP_IP_PORT.."index.php";--保存客户端数据
    t.SNS_VERSION_URL = t.HTTP_IP_PORT.."version.php";--服务器代码版本
    --t.FRIEND_SERVER_URL = "http://10.12.20.82:80/index.php";--社交服郭明
    --t.FRIEND_SERVER_URL = "http://10.12.20.32:80/index.php";  --张传凯
end
t.SetServer(1);

--msgsub only for lua-----------------

--聊天
t.SUB_G_CHAT = 7;
t.SUB_U_CHAT_DRAG = 2;          --聊天语音按钮拖拽
t.SUB_U_CHAT_STOP_VOICE = 3;    --聊天语音停止播放
t.SUB_U_CHAT_VOICE_FINISH = 4;  --聊天语音播放完毕
t.SUB_U_CHAT_VOICE_UPLOAD_FINISH = 5;--聊天语音文件上传完毕
t.SUB_U_CHAT_REALTIME_JOIN_FAIL = 6; --聊天实时语音房间进入失败
t.SUB_U_CHAT_CLICK_MESSAGE = 7; --主界面点击非链接消息
t.SUB_U_CHAT_ZAN_UPDATE = 11;   --点赞信息刷新
t.SUB_U_CHAT_ROOM_RECENT_MSG = 12;   --近期消息
t.SUB_U_CHAT_ROOM_RANGE_MSG = 13;     --历史消息
t.SUB_U_RECEIVE_SPEECH_TEXT = 14;     --收到语音文本消息
t.SUB_U_CHAT_REALTIME_JOIN_SUCCESS =15;--聊天实时语音房间进入成功
t.SUB_U_CHAT_BULLET_ADD_COMMENT = 17;   --添加评论
t.SUB_U_CHAT_BULLET_GET_COMMENT = 18;   --获取评论
t.SUB_U_CHAT_OFFLINE_MSG = 19;        --离线消息

t.SUB_U_CHAT_GROUP_GET_MSG_LIST = 20;--群聊天消息
t.SUB_U_CHAT_UPDATE_FRIEND_PRIVATE = 21; --更新好友私聊消息
t.SUB_U_CHAT_UPDATE_FRIEND_QUN = 22;    --更新群消息
t.SUB_U_CHAT_ROOM_NEWMSG = 23;  --房间新消息

t.SUB_U_CHAT_EMOJI_PACKAGE_GET = 40;    --获取表情包数据

t.SUB_U_CHAT_READYTO_UPLOAD = 41;    --准备好上传自定义表情
t.SUB_U_CHAT_SHOWBTNLIST = 42;    --显示按钮列表
t.SUB_U_CHAT_ONGETMYADDEMOJI = 43;    --获取到我的添加表情列表
t.SUB_U_CHAT_ADDONEEMOJIWITHNAME = 44;    --添加一个表情
t.SUB_U_CHAT_COLLECTONEEMOJI = 45;    --收藏一个表情
t.SUB_U_CHAT_ONGETMYCOLLECTEMOJI = 46;    --获取到我的收藏表情列表
t.SUB_U_CHAT_GETMOREHOTEMOJI = 47;    --获取到更多最火单品
t.SUB_U_CHAT_GETMORETIMEEMOJI = 48;    --获取到更多最新单品
t.SUB_U_CHAT_SHOWEMOJIOPERLIST = 49;    --显示聊天框内自定义表情操作列表
t.SUB_U_CHAT_SHOWEMOJIPIC = 50;    --显示表情图片大图
t.SUB_U_CHAT_ONGETMYADDPKG = 51;    --获取到我添加的系列列表
t.SUB_U_CHAT_ADDONEPKG = 52;    --添加一个系列
t.SUB_U_CHAT_MYCOLLECTHELP = 53;    --UI_MyCollectHelp界面开关回调
t.SUB_U_CHAT_COLLECTONEPKG = 54;    --收藏一个系列

--帮派
t.SUB_G_GANG= 24;
t.SUB_U_GANG_UPDATELOCATION = 1; --更新位置
t.SUB_U_GANG_JOIN = 2; --玩家加入帮会
t.SUB_U_GANG_LEAVE = 3; --玩家离开帮会
t.SUB_U_GANG_CREATE = 4; --玩家创建帮会
t.SUB_U_GANG_ZOOMENDTO = 5; --地图缩放完毕
t.SUB_U_GANG_POITOCOORDINATE = 6; --地址转换坐标的回调
t.SUB_U_GANG_COORDINATETOPOI = 7; --坐标转为地址的回调
t.SUB_U_GANG_POIBYKEY = 8; --关键词获取地域信息的回调
t.SUB_U_GANG_DISTRICTINCHINA = 9; --获取中国地域信息的回调
t.SUB_U_GANG_CHILDRENDISTRICTIN = 10; --根据地区编码获取子集地域的回调
t.SUB_U_GANG_DISTRICTBYWORD =11; --关键词查询地区信息的回调

--排行榜
t.SUB_G_RANK = 29;
t.SUB_U_RANK_UPDATERESAULT = 1;  --更新排行结果


--分享
t.SUB_G_SHARE = 32;
t.SUB_U_SHARE_SWITCHSHARELAYER = 1; --UI分享Layer切换
t.SUB_U_SHARE_CAPTURE_FINISH = 2; --显示分享截屏结果

--商会
t.SUB_G_SHOP = 33;
t.SUB_G_SHOP_GOTSPECINFO = 1;  --获取商品特殊信息
t.SUB_G_SHOP_BUY = 2;  --购买返回
t.SUB_G_SHOP_SELL = 3;  --出售返回

--射箭
t.SUB_G_ARROW_SHOOT = 34;
t.SUB_G_ARROW_SHOOT_SETAIM = 1;     --瞄准镜偏移


--宝石
t.SUB_G_GEM = 36;
t.SUB_U_GEM_INLAY = 1;  --镶嵌返回
t.SUB_U_GEM_REMOVE = 2;  --卸下返回
t.SUB_U_GEM_MATCHANGE = 3; --升级材料改变
t.SUB_U_GEM_LEVELUP = 4; --宝石升级返回
t.SUB_U_GEM_CANCEL = 5; --取消选中

--活跃度
t.SUB_G_VITALITY = 37;
t.SUB_U_VITALITY_VALUE_CHANGE = 1; --活跃度数值变化
t.SUB_U_VITALITY_GET_AWARD = 2; --获得活跃度奖励
t.SUB_U_VITALITY_RECOMMEND_UPDATE = 3; --更新推荐活动
t.SUB_U_VITALITY_IMAGE_INIT = 4; --活跃度图片初始化
t.SUB_U_VITALITY_FILL_IMAGE = 5; --填充活跃度图片
t.SUB_U_VITALITY_UPDATE_SELECT_FLAG = 6; --更新当前选定颜色的可填充区域
t.SUB_U_VITALITY_UPDATE_COLOR_COUNT = 7; --更新色块数量
t.SUB_U_VITALITY_RESET_VITALITY = 8; --重置活跃度

GameConfig = t;