module("UI_Friend_Remark",package.seeall);
require("Logic/Presenter/UI/Friend/UI_Friend_EditGroup");

local mNameInput;
local mTipPlease;

local function SaveRemark()
    local remark = mNameInput:GetValue();
    if not mNameInput:CheckValid() then return false; end

    FriendMgr.RequestModifyGameFriendRemark(mFriend, remark);
    return true;
end

function ShowFriend(friend)
    mFriend = friend;
    UIMgr.ShowUI(AllUI.UI_Friend_Remark);
end
function OnCreate(self)
    mSelf = self;
    local limitCount = ConfigData.GetIntValue("friend_remark_name_count") or 6;--好友备注长度

    mNameInput = UICommonLuaInput.new(self:FindComponent("LuaUIInput","Offset/WithWidgetRoot/Content/Remark/Input"),limitCount);
    mNameInput:SetInvalidChars(WordData.GetWordStringByKey("friend_remark_invaid_chars"));--"%s, ,%d"非法字符
    mTipPlease = self:FindComponent("UILabel", "Offset/WithWidgetRoot/Content/NameLabel");
end

function OnEnable(self)
    
    mNameInput:SetInitText( mFriend:GetRemark());
    mTipPlease.text = WordData.GetWordStringByKey("Friend_Remark_%s_Please",mFriend:GetName());--请输入[c][6bc547]大飞哥你好帅[-][/c]的备注名称
end


function OnDisable(self)

end

function OnClick(go, id)
    GameLog.Log("Click button "..go.name.." id "..tostring(id));
    if id == 1 then--确认
        if not SaveRemark() then return; end
        UIMgr.UnShowUI(AllUI.UI_Friend_Remark);
    elseif id == 2 then--取消
        UIMgr.UnShowUI(AllUI.UI_Friend_Remark);
    end
end

