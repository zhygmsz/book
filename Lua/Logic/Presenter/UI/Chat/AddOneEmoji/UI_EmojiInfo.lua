module("UI_EmojiInfo", package.seeall)

--组件
local mSelf
local mIcon
local mEmojiName

local mPlayerName
local mPlayerId

local mRightBtnLbl

--变量
local mRightBtnLblDes = 
{
    [1] = "保存",
    [2] = "使用表情",
}

local mShowingEmojiInfo
--保存或使用选项
local mSaveOrUse = 1

local mSquareLen = 100


--local方法
local function SetSaveOrUse(emojiInfo)
    local existIn = CustomEmojiMgr.CheckExistInMyCollectEmojiList(emojiInfo:GetPicId())
    if existIn then
        mSaveOrUse = 2
    else
        mSaveOrUse = 1
    end

    mRightBtnLbl.text = mRightBtnLblDes[mSaveOrUse]
end

--[[
    @desc: 玩家信息回调，用playerId判断回来的是否和当前显示的是一个
]]
local function OnGetPlayerInfo(playerId, playerInfo)
    playerId = tonumber(playerId)
    if playerId == mShowingEmojiInfo:GetPlayerId() and playerInfo then
        mPlayerName.text = playerInfo:GetNickName()
    end
end

local function OnLoadTex()
    UIUtil.AdjustInSquare(mIcon, mSquareLen)
end

local function DoShowInfo(emojiInfo)
    mShowingEmojiInfo = emojiInfo

    UIUtil.LoadImage(mIcon, CustomEmojiMgr.GetEmojiSize(), emojiInfo:GetUrl(), true, OnLoadTex, nil)
    mEmojiName.text = emojiInfo:GetName()
    mPlayerId.text = emojiInfo:GetPlayerId()
    mPlayerName.text = "玩家名字六个字"
    SocialPlayerInfoMgr.GetPlayerInfoById(emojiInfo:GetPlayerId(), OnGetPlayerInfo)

    SetSaveOrUse(emojiInfo)
end

local function OnClickShare()
    
end

--[[
    @desc: 收藏成功回调
]]
local function OnCollectFinish(state, picId)
    if state then
        --同步收藏列表
        CustomEmojiMgr.AddEmoji2MyCollectListByEmojiInfo(mShowingEmojiInfo)
        --刷UI
        SetSaveOrUse(mShowingEmojiInfo)

        TipsMgr.TipByFormat("收藏成功")
    else
        TipsMgr.TipByFormat("收藏失败")
    end
end

local function OnClickRightBtn()
    if mSaveOrUse == 1 then
        --保存
        --发送收藏请求
        SNSCustomEmojiMgr.RequestCollectEmoji(mShowingEmojiInfo:GetPicId(), OnCollectFinish, nil)
    elseif mSaveOrUse == 2 then
        --使用表情
    end
end

local function OnClickHome()
    
end

local function OnClickIcon()
    MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWEMOJIPIC, mShowingEmojiInfo)
end

local function RegEvent(self)
    
end

local function UnRegEvent(self)

end

function OnCreate(self)
    mSelf = self

    mIcon = self:FindComponent("UITexture", "Offset/icon")
    mEmojiName = self:FindComponent("UILabel", "Offset/middle/name/name")

    mPlayerName = self:FindComponent("UILabel", "Offset/middle/playername/name")
    mPlayerId = self:FindComponent("UILabel", "Offset/middle/playername/id")

    mRightBtnLbl = self:FindComponent("UILabel", "Offset/middle/right/label")
end

function OnEnable(self)
    RegEvent(self)

    local emojiInfo = CustomEmojiMgr.GetShowingEmojiInfo()
    DoShowInfo(emojiInfo)
end

function OnDisable(self)
    UnRegEvent(self)

    CustomEmojiMgr.DoInvokeFunc(AllUI.UI_EmojiInfo)
end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == -100 then
        --关闭按钮
        UIMgr.UnShowUI(AllUI.UI_EmojiInfo)
    elseif id == 1 then
        --表情图
        OnClickIcon()
    elseif id == 2 then
        --home按钮
        OnClickHome()
    elseif id == 3 then
        --保存/使用
        OnClickRightBtn()
    elseif id == 4 then
        --分享
        OnClickShare()
    end
end

