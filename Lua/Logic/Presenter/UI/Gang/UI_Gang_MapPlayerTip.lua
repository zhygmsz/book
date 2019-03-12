
module("UI_Gang_MapPlayerTip",package.seeall)

--玩家名字
local Name=nil
--所在服务器
local ServerName=nil
--等级
local Level=nil
--头像
local Icon=nil
--个性签名
local PersonLabel = nil

--发消息按钮标题
local SendMsgLabel=nil
--加好友按钮标题
local AddFriendLabel=nil
--邀请入队按钮标题
local AskBeTeamerLabel=nil
--邀请入帮按钮标题
local AskBeGangerLabel=nil
--个人空间按钮标题
local PrivateSpaceLabel=nil
--加入黑名单按钮标题
local AddBlackListLabel=nil
--当前玩家数据
local CurData={}
--背景对象
local BgObj=nil
--背景对象
local BgSprite=nil
local BgWidth=0
local BgHeight=0
local Show=false

function OnCreate(self)
    BgObj = self:Find("Offset/Bg").gameObject;
    BgSprite = self:FindComponent("UISprite","Offset/Bg");
    BgWidth=BgSprite.width
    BgHeight=BgSprite.height
    Name = self:FindComponent("UILabel","Offset/Bg/Name");
    ServerName = self:FindComponent("UILabel","Offset/Bg/ServerName");
    Level = self:FindComponent("UILabel","Offset/Bg/Level");
    Icon = self:FindComponent("UISprite","Offset/Bg/Icon");
    PersonLabel = self:FindComponent("UILabel","Offset/Bg/MsgBg/PersonLabel");
    SendMsgLabel = self:FindComponent("UILabel","Offset/Bg/SendMsg/Label");
    AddFriendLabel = self:FindComponent("UILabel","Offset/Bg/AddFriend/Label");
    AskBeTeamerLabel = self:FindComponent("UILabel","Offset/Bg/AskBeTeamer/Label");
    AskBeGangerLabel = self:FindComponent("UILabel","Offset/Bg/AskBeGanger/Label");
    PrivateSpaceLabel = self:FindComponent("UILabel","Offset/Bg/PrivateSpace/Label");
    AddBlackListLabel = self:FindComponent("UILabel","Offset/Bg/AddBlackList/Label");
end

function OnEnable(self)
    CurData=GangMgr.GetCurrentPlayerData()
    Show=true
    UpdateView()
end

function OnDisable(self)
    Show=false
end

function CheckShow()
    return Show
end
--更新显示
function UpdateView()
    Name.text = CurData.Name
    ServerName.text = CurData.ServerName
    Level.text = CurData.Level
    PersonLabel.text = CurData.PersonSign
    --Icon.sprite=""
    GlobalMapMgr.MapTipArchorPosition(BgObj,BgWidth,BgHeight,CurData.Coordinate)
end
function OnClick(go,id)
    GameLog.Log(" OnClick %d",id)
    if id ==-1 then--发消息
    elseif id == -2 then--加好友
    elseif id == -3 then--邀请入队
    elseif id == -4 then--邀请入帮
    elseif id == -5 then--个人空间
    elseif id == -6 then--加入黑名单
    elseif id == -100 then--关闭
        UIMgr.UnShowUI(AllUI.UI_Gang_MapPlayerTip)
    end
end
--endregion
