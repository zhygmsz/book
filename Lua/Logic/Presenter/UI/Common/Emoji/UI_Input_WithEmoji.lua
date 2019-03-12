--在屏幕顶端打开一个带表情的输入框
module("UI_Input_WithEmoji",package.seeall);

local mInputWrap;
local mMsgCommon;
local mCallback;
local mLimitCount;

function Show(msgCommon,limitCount, callBack)
    mMsgCommon = msgCommon;
    mCallback = callBack;
    mLimitCount = limitCount or 20;
    UIMgr.ShowUI(AllUI.UI_Input_WithEmoji);
end

function OnCreate(ui)
    local input = ui:FindComponent("LuaUIInput","InputRoot/Input");
    mInputWrap = ChatInputWrap.new(input, ChatMgr.CommonLinkOpenType.FromChat);
    mInputWrap:ResetMsgCommon()
    mInputWrap:ResetLimitCount(mLimitCount)
end

function OnEnable(ui)
    mInputWrap:ResetMsgCommon(mMsgCommon, true);
    mInputWrap:ResetLimitCount(mLimitCount);
end

function OnClick(go,id)
    if id == 0 then
        if mCallback then
            local flag,re = xpcall(mCallback, traceback,mMsgCommon);
            if not flag then GameLog.LogError(re); end
        end
        UIMgr.UnShowUI(AllUI.UI_Input_WithEmoji);
    elseif id == 1 then
        mInputWrap:OnLinkBtnClick();
    end
end
