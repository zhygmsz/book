module("UI_Friend_RemarkRegroup",package.seeall);
require("Logic/Presenter/UI/Friend/UI_Friend_EditGroup");

local mFid;
local mGid;
local mNameInput;
local mGroupPopList;
local mGroupValue;
local mEventIDs;
local mGroups;

local function SaveRemark()
    local remark = mNameInput:GetValue();
    if not mNameInput:CheckValid() then return false; end

    FriendMgr.RequestModifyGameFriendRemark(mFriend, remark);
    return true;
end

local function SaveRegroup()
    local gi = mGroupPopList:GetSelectedIndex();
    FriendMgr.RequestSetFriend2Group(mFriend,mGroups[gi]);
end

local function InitGroups()
    mGroups = FriendMgr.GetGroupFriends();
    local groupNames = {};   
    local myGI = 1;
    for i,group in ipairs(mGroups) do
        groupNames[#groupNames+1] =  group:GetName();
        if group == mFriend:GetFriendAttr():GetGroup() then
            myGI = i
        end
    end
    
    mGroupPopList:InitOptions(groupNames,myGI);
end

local function OnGroupCountChange()
    InitGroups();
end

function ShowFriend(friend)
    mFriend = friend;
    UIMgr.ShowUI(AllUI.UI_Friend_RemarkRegroup);
end
function OnCreate(self)
    mSelf = self;
    local limitCount = ConfigData.GetIntValue("friend_remark_name_count") or 6;--好友备注长度

    mNameInput = UICommonLuaInput.new(self:FindComponent("LuaUIInput","Offset/WithWidgetRoot/Content/Remark/Input"),limitCount);
    mGroupPopList = UICommonPopupScrollList.new(self,"Offset/WithWidgetRoot/Content/PopupListGroup",4,5);
    mGroupValue = self:FindComponent("UILabel","Offset/WithWidgetRoot/Content/Group/Label");
end

function OnEnable(self)
    
    mNameInput:SetInitText( mFriend:GetRemark());

    InitGroups();
    GameEvent.Reg(EVT.FRIEND,EVT.FRIEND_REGROUP_COUNT,OnGroupCountChange);
end


function OnDisable(self)
    GameEvent.UnReg(EVT.FRIEND,EVT.FRIEND_REGROUP_COUNT,OnGroupCountChange);
end

function OnClick(go, id)
    GameLog.Log("Click button "..go.name.." id "..tostring(id));
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_RemarkRegroup);
    elseif id == 1 then--确认
        SaveRegroup();
        if not SaveRemark() then return; end
        UIMgr.UnShowUI(AllUI.UI_Friend_RemarkRegroup);
    elseif id == 2 then--取消
        UIMgr.UnShowUI(AllUI.UI_Friend_RemarkRegroup);
    elseif id == 3 then--新建
        UI_Friend_EditGroup.ShowGroup();
    end
    mGroupPopList:OnClick(id);

end

