module("UI_Shortcut_Player",package.seeall);
require("Logic/Presenter/UI/Gift/UI_Gift_Main");
require("Logic/Presenter/UI/Friend/UI_Friend_Remark");
require("Logic/Presenter/UI/Friend/UI_Friend_Main");

local mLabels;
local mFuncs;
local mPanel;
local mIsNPC;

local mPlayer;

local function QuickTalk()
    UI_Friend_Main.TryChat(mPlayer);
end

local function SendGift2Friend()
    UI_Gift_Main.ShowSendFriend(mPlayer:GetID());
end

local function ConfirmDeleteFriend()
    FriendMgr.RequestDelFriend(mPlayer);
end

local function DeleteFriend()
    TipsMgr.TipConfirmPlayerByKey("friend_delete_friend_ensure",mPlayer:GetID(),ConfirmDeleteFriend,nil,mPlayer:GetRemark());--删除好友确认
end
local function ConfirmDeleteFollow()
    FriendMgr.RequestDelFollow(mPlayer);
end
local function DeleteFollow()
    TipsMgr.TipConfirmPlayerByKey("friend_delete_follow_ensure",mPlayer:GetID(),ConfirmDeleteFollow,nil,mPlayer:GetRemark());--删除关注确认
end

local function AddFriend()
    FriendMgr.RequestAskAddFriend(mPlayer);
end

local function ConfirmDeleteFan()
    FriendMgr.RequestDelFan(mPlayer);
end
local function RemoveFan()
    TipsMgr.TipConfirmPlayerByKey("friend_delete_fan_ensure",mPlayer:GetID(),ConfirmDeleteFan,nil,mPlayer:GetRemark());--删除粉丝确认
end

local function ConfirmBlack()
    FriendMgr.RequestAddBlackList(mPlayer);
end

local function AddinBlackList()
    if mPlayer:HasSpecialRelation() then
        TipsMgr.TipByKey("friend_black_fail_operation");--添加黑名单失败提醒，特殊关系
        return;
    end
    TipsMgr.TipConfirmPlayerByKey("friend_add_blacklist_ensure",mPlayer:GetID(),ConfirmBlack,nil,mPlayer:GetRemark());--添加黑名单确认
end 

local function RemoveBlack()
    FriendMgr.RequestDelBlackList(mPlayer);
end

-----------------------
local function VisitSpaceDynamic()--点击动态
end

local function VisitHome()--访问家园

end


local function OpenFriendCircle()--朋友圈
    PersonSpaceMgr.OpenPSpaceOnlyOnePerson(mPlayer:GetID());
end

local function OpenEquipment()--查看装备
end

local function ShowMore() --更多
    -- local show = not mUITable.mMoreBtnPad.transform.gameObject.activeSelf
    -- mUITable.mMoreBtnPad.transform.gameObject:SetActive(show)
end
local function ReportPlayer() --举报

end

local function AddFastChat()
    if FastChatMgr.IsInFastChat(mPlayer) then
        FastChatMgr.RemoveFastChatter(mPlayer);
    else
        FastChatMgr.AddFastChatter(mPlayer);
    end
end

local BlackLabels = {"sc_moveout_black","sc_space_dynamic","sc_visit_home","sc_friend_circle","sc_show_equipment","sc_report_player"};--这里都是好友快捷界面的按钮名称
local BlackFuncs =  {RemoveBlack,        VisitSpaceDynamic, VisitHome,      OpenFriendCircle,  OpenEquipment,      ReportPlayer};

local FriendLabels = {"sc_delete_friend","sc_putin_black","sc_send_gift", "sc_quick_talk","sc_space_dynamic","sc_visit_home","sc_friend_circle","sc_show_equipment","sc_report_player","Add_Fast"};
local FriendFuncs =  {DeleteFriend,      AddinBlackList,  SendGift2Friend,QuickTalk,      VisitSpaceDynamic, VisitHome,      OpenFriendCircle,  OpenEquipment,      ReportPlayer,       AddFastChat};

local StrangerLabels = {"sc_add_friend", "sc_putin_black","sc_quick_talk","sc_space_dynamic","sc_visit_home","sc_friend_circle","sc_show_equipment","sc_report_player"};
local StrangerFuncs =  {AddFriend,   AddinBlackList,      QuickTalk,      VisitSpaceDynamic, VisitHome,      OpenFriendCircle,  OpenEquipment,      ReportPlayer};

local FanLabels = {"sc_moveout_list", "sc_putin_black",    "sc_add_friend","sc_quick_talk","sc_space_dynamic","sc_visit_home","sc_friend_circle","sc_show_equipment","sc_report_player"};
local FanFuncs =  {RemoveFan,         AddinBlackList,      AddFriend,      QuickTalk,      VisitSpaceDynamic, VisitHome,      OpenFriendCircle,  OpenEquipment,      ReportPlayer};

local FollowLabels = {"sc_delete_follow",   "sc_putin_black",  "sc_quick_talk","sc_space_dynamic","sc_visit_home","sc_friend_circle","sc_show_equipment","sc_report_player"};
local FollowFuncs =  {DeleteFollow,         AddinBlackList,    QuickTalk,      VisitSpaceDynamic, VisitHome,      OpenFriendCircle,  OpenEquipment,      ReportPlayer};

local NPCFriendLabels = {"sc_delete_friend","sc_quick_talk"};
local NPCFriendFuncs =  {DeleteFriend};

local NPCStrangerLabels = {"sc_add_friend","sc_quick_talk"};
local NPCStrangerFuncs =  {AddFriend};

local function InitPanel()

    if mPlayer:IsInBlackList() then
        mLabels = BlackLabels;
        mFuncs = BlackFuncs;
    elseif not mPlayer:IsNPC() then
        if mPlayer:IsFriend() then
            mLabels = FriendLabels;
            mFuncs = FriendFuncs;
        elseif mPlayer:IsFollow() then
            mLabels = FollowLabels;
            mFuncs = FollowFuncs;
        elseif mPlayer:IsFan() then
            mLabels = FanLabels;
            mFuncs = FanFuncs;
        elseif mPlayer:IsStranger() then
            mLabels = StrangerLabels;
            mFuncs = StrangerFuncs;
        end
    else
        if mPlayer:IsFriend() then
            mLabels = NPCFriendLabels;
            mFuncs = NPCFriendFuncs;
        else
            mLabels = NPCStrangerLabels;
            mFuncs = NPCStrangerFuncs;
        end
    end
    for i,v in ipairs(mPanel.labels) do
        if mLabels[i] then
            mPanel.goes[i]:SetActive(true);
            v.text = WordData.GetWordStringByKey(mLabels[i]);
        else
            mPanel.goes[i]:SetActive(false);
        end
    end
end
local mRelationLabel;
local function InitBasicInfoWithRole()
    --PersonSpaceMgr.LoadHeadIcon(mPanel.iconTexture,mPlayer:GetDefaultHeadIconURL());
    mPlayer:SetHeadIcon(mPanel.iconTexture,mPanel.iconSprite);
    mPanel.nicknameLabel.text = mPlayer:GetNickName();
    mPanel.levelLabel.text = mPlayer:GetLevel();--玩家快捷界面 [等级]--删除了"friend_%s_short_Level"
    mPanel.teamLabel.text = mPlayer:GetNormalAttr():GetTeamInfo();
    mPanel.IDLabel.text = mPlayer:GetID();
    mPanel.gangsterLabel.text = mPlayer:GetNormalAttr():GetGuildName();
    if mPlayer:IsFriend() then
        mPanel.remarkGo:SetActive(true);
        mPanel.remarkLabel.text = mPlayer:GetRemark();
    else
        mPanel.remarkGo:SetActive(false);
    end
    mRelationLabel.text = mPlayer:GetFriendAttr():GetGroup():GetName();
end


function OnCreate(self)
    mRelationLabel = self:FindComponent("UILabel","Offset/Bg/BaseInfo/LabelRelation");
    mPanel = {};
    local iconTexture = self:FindComponent("UITexture","Offset/Bg/HeadBg/Texture");
    mPanel.iconTexture = iconTexture;
    mPanel.iconSprite = self:FindComponent("UISprite","Offset/Bg/HeadBg/Sprite");
    local factionTexture = self:FindComponent("UITexture","Offset/Bg/Faction");
    mPanel.factionTextureLoader = LoaderMgr.CreateTextureLoader(factionTexture);
    mPanel.nicknameLabel = self:FindComponent("UILabel","Offset/Bg/BaseInfo/LabelNickName");
    mPanel.levelLabel = self:FindComponent("UILabel","Offset/Bg/BaseInfo/LabelLevel");
    
    mPanel.IDLabel = self:FindComponent("UILabel","Offset/Bg/BaseInfo/Grid/Label (0)");
    mPanel.teamLabel = self:FindComponent("UILabel","Offset/Bg/BaseInfo/Grid/Label (1)");
    mPanel.gangsterLabel = self:FindComponent("UILabel","Offset/Bg/BaseInfo/Grid/Label (2)");
    mPanel.remarkLabel = self:FindComponent("UILabel","Offset/Bg/BaseInfo/Grid/Label (3)");
    mPanel.labels = {};
    mPanel.goes = {};
    mPanel.remarkGo = self:Find("Offset/Bg/BaseInfo/Grid/Label (3)").gameObject;
    local grid = self:Find("Offset/Bg/ButtonGrid");
    for i=0,grid.childCount-1 do
        local button = grid:GetChild(i);
        button:GetComponent("UIEvent").id = 11+i;
        mPanel.labels[i+1] = button:Find("Label"):GetComponent("UILabel");
        mPanel.goes[i+1] = button.gameObject;
    end
end

local function OnGetRoleInfo (id,roleInfo)
    if roleInfo then
        InitBasicInfoWithRole(roleInfo);
        GameLog.Log("OnGetRoleInfo "..id);
    end
end

function OnEnable(self)
    InitBasicInfoWithRole();
    InitPanel();
    GameEvent.Reg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,InitBasicInfoWithRole);     --改变好友基本数据；
end

function OnDisable(self)
    GameEvent.UnReg(EVT.SOCIAL,EVT.SOCIAL_ATTRIBUTE,InitBasicInfoWithRole);     --改变好友基本数据；
end

function OnClick(go, id)
    GameLog.Log("Click button "..go.name.." id "..tostring(id));
    UIMgr.UnShowUI(AllUI.UI_Shortcut_Player);
    if id == 1 then
    UI_Friend_Remark.ShowFriend(mPlayer);
    elseif mFuncs[id-10] then
        mFuncs[id-10]();
    end
end


function ShowPlayer(player)
    if not player or player:IsSelf() then return; end
    mPlayer = player;
    UIMgr.ShowUI(AllUI.UI_Shortcut_Player);
end

function ShowPlayerByID(pid)
    ShowPlayer(SocialPlayerMgr.FindMemberByID(pid));
end
--==============================--

