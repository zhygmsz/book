module("UI_Friend_NewQun",package.seeall)
 
local mNameInput;
local mNameLabel;
local mLabelNotice;
local mVacantCount;
local mMaxCount;
local mCurrentCount;
function OnCreate(ui)
    local contentPath = "Offset/WithWidgetRoot/Content";
    local limitCount = ConfigData.GetIntValue("friend_qun_name_limit") or 6;--好友群名长度
    mNameInput = UICommonLuaInput.new(ui:FindComponent("LuaUIInput", contentPath.."/InputName/Input"),limitCount);
    mLabelNotice = ui:FindComponent("UILabel", contentPath.."/SpriteNotice/LabelNotice");
    mNameLabel = ui:FindComponent("UILabel", contentPath.."/InputName/Label");
end

function OnEnable(ui)
     
    mCurrentCount, mMaxCount = ChatMgr.GetFriendQunCountInfo();
    mVacantCount =  mMaxCount - mCurrentCount;
    
    mLabelNotice.text = WordData.GetWordStringByKey("friend_qun_new_%s_capacity_%s", mVacantCount, ChatMgr.GetQunCapacity());--好友群数量提示
    local defaultName = WordData.GetWordStringByKey("friend_qun_default_name");--好友群默认名字
    mNameInput:SetValue(defaultName);
end

function OnDisable(ui)
     
end

function OnClick(go, id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_NewQun);
    elseif id == 1 then
        if ChatMgr.CheckCreateQunCondition() then 
            if mNameInput:CheckValid() then
                local name = mNameInput:GetValue();
                ChatMgr.RequestCreateCligroup({""},name);--players = {"1","2"};
                UIMgr.UnShowUI(AllUI.UI_Friend_NewQun);
            end
        end
        
    end
end
