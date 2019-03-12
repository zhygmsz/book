module("UI_Chat_EmojiPic", package.seeall)

--组件
local mSelf
local mOffsetGo
local mTex

--变量
local mEvents = {}

local mShowingEmojiInfo


--local方法
local function SetOffsetVisible(visible)
    mOffsetGo:SetActive(visible)

    if visible then

    else
        --模拟UI关闭
        CustomEmojiMgr.DoInvokeFunc(AllUI.UI_Chat_EmojiPic)
    end
end

local function OnLoadTex()
    UIUtil.AdjustInScreen(mTex, 0.6)
end

local function OnShowPic(emojiInfo)
    if not emojiInfo then
        return
    end
    mShowingEmojiInfo = emojiInfo
    SetOffsetVisible(true)

    UIUtil.LoadImage(mTex, CustomEmojiMgr.GetEmojiSize(), emojiInfo:GetUrl(), true, OnLoadTex, nil)
end

local function RegEvent()
    mEvents[1] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWEMOJIPIC, OnShowPic)
end

local function UnRegEvent()
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWEMOJIPIC, mEvents[1])
    mEvents = {}
end

function OnCreate(self)
    mSelf = self

    mOffsetGo = self:Find("Offset").gameObject
    mOffsetGo:SetActive(false)
    
    mTex = self:FindComponent("UITexture", "Offset/tex")
end

function OnEnable(self)
    RegEvent()
end

function OnDisable()
    UnRegEvent()
end

function OnDestroy()

end

function OnClick(go, id)
    if id == -100 then
        --mask
        SetOffsetVisible(false)
    elseif id == 1 then
        --放大
    elseif id == 2 then
        --缩小
    elseif id == 3 then
        --关闭
        SetOffsetVisible(false)
    end
end

