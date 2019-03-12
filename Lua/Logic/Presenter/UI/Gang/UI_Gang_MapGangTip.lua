
module("UI_Gang_MapGangTip",package.seeall)

--帮会名字
local NameLabel=nil
--帮主
local HeadMan=nil
--帮主标题
local HeadManLabel=nil
--人数标题
local CountLabel=nil
--人数
local Count = nil
--财富标题
local MoneyLabel=nil
--财富
local Money=nil
--工会标志
local Icon=nil
--申请按钮标题
local ApplyLabel=nil
--公告
local Notice=nil
--当前帮派数据
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
    NameLabel = self:FindComponent("UILabel","Offset/Bg/Name");
    HeadManLabel = self:FindComponent("UILabel","Offset/Bg/HeadManLabel");
    HeadMan = self:FindComponent("UILabel","Offset/Bg/HeadMan");
    CountLabel = self:FindComponent("UILabel","Offset/Bg/CountLabel");
    Count = self:FindComponent("UILabel","Offset/Bg/Count");
    MoneyLabel = self:FindComponent("UILabel","Offset/Bg/MoneyLabel");
    Money = self:FindComponent("UILabel","Offset/Bg/Money");
    Icon = self:FindComponent("UISprite","Offset/Bg/Icon");
    ApplyLabel = self:FindComponent("UILabel","Offset/Bg/Apply/Label");
    Notice = self:FindComponent("UILabel","Offset/Bg/MsgBg/Notice");
end

function OnEnable(self)
    RegEvent(self)
    CurData=GangMgr.GetCurrentGangData()
    UpdateView()
    Show=true
end

function OnDisable(self)
    UnRegEvent(self)
    Show=false
end

local mEvents = {};
function RegEvent(self)
    table.insert(mEvents,MessageSub.Register(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_JOIN,OnJoinedGang));
end

function UnRegEvent(self)
    MessageSub.UnRegister(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_JOIN,mEvents[1]);
    mEvents = {};
end


function CheckShow()
    return Show
end

--更新显示
function UpdateView()
    NameLabel.text = CurData.Name
    HeadMan.text = CurData.HeadMan
    Count.text = GangMgr.GetCountLabelString(CurData.Index)-- string.format( "%s/%s",CurData.OnlineCount,CurData.OnlineCount)
    Money.text = "1500"
    Notice.text=CurData.Notice
    --Icon.sprite=""
    GlobalMapMgr.MapTipArchorPosition(BgObj,BgWidth,BgHeight,CurData.Coordinate)
end

function OnClick(go,id)
    if id ==-1 then--申请加入
        GangMgr.ApplyForGang(CurData.Index)
    elseif id == -100 then--关闭
        UIMgr.UnShowUI(AllUI.UI_Gang_MapGangTip)
    end
end

--加入帮派回调
function OnJoinedGang( gangindex )
    UIMgr.UnShowUI(AllUI.UI_Gang_MapGangTip)
end
