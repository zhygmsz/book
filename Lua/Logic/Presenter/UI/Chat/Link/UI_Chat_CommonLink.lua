module("UI_Chat_CommonLink", package.seeall)

local FuncBtnWidget = require("Logic/Presenter/UI/Chat/Link/Chat_CommonLink_FuncBtn")
local SysEmojiWidget = require("Logic/Presenter/UI/Chat/Link/Chat_CommonLink_SysEmoji")
local ItemWidget = require("Logic/Presenter/UI/Chat/Link/Chat_CommonLink_Item")
local CustomEmojiWidget = require("Logic/Presenter/UI/Chat/Link/Chat_CommonLink_CustomEmoji")
local InputHistoryWidget = require("Logic/Presenter/UI/Chat/Link/Chat_CommonLink_InputHistory")
local EasyWordWidget = require("Logic/Presenter/UI/Chat/Link/Chat_CommonLink_EasyWord")


--组件
local mSelf
local mBg
local mFuncRoot
local mEmojiRoot
local mItemRoot
local mCustomEmojiRoot
local mInputHistoryRoot
local mEasyWordRoot

--变量
local mBgSize = { x = 0, y = 0 }
local mAddCustomEmojiWidgetSize = { x = 0, y = 0 }
local mEvents = {}
local mFuncBtnWidget
local mSysEmojiWidget
local mItemWidget
local mCustomEmojiWidget
local mInputHistoryWidget
local mEasyWordWidget

local mEventIdSpan = 10
local mEventIdBaseFunc = 10000
local mEventIdBaseSysEmoji = 20000
local mEventIdBaseItem = 30000
local mEventIdBaseCustomEmoji = 40000
local mEventIdBaseInputHistory = 50000
local mEventIdBaseEasyWord = 60000

local mFuncIdx2Widget = {}
local mCurFuncIdx = -1


--local方法
--[[
    @desc: 
    --@funcIdx: 功能id
]]
local function OnFuncBtnNor(funcIdx)
    if funcIdx and mFuncIdx2Widget[funcIdx] then
        mFuncIdx2Widget[funcIdx]:Hide()
    end
end

--[[
    @desc: 
    --@funcIdx: 功能id
]]
local function OnFuncBtnSpec(funcIdx)
    if funcIdx and mFuncIdx2Widget[funcIdx] then
        mFuncIdx2Widget[funcIdx]:Show()

        mCurFuncIdx = funcIdx
        ChatMgr.SetLastFuncIdx(funcIdx)
    end
end

local function RegEvent(self)
    TouchMgr.SetListenOnNGUIEvent(UI_Chat_CommonLink, true, false)
end

local function UnRegEvent(self)
    TouchMgr.SetListenOnNGUIEvent(UI_Chat_CommonLink, false, false)
end

function OnCreate(self)
    mSelf = self

    mBg = self:Find("offset/bg")
    local tex = mBg:GetComponent("UISprite")
    mBgSize.x = tex.width
    mBgSize.y = tex.height

    mFuncRoot = self:Find("offset/funcroot")
    mFuncBtnWidget = FuncBtnWidget.new(mFuncRoot, self, mEventIdBaseFunc, mEventIdSpan, OnFuncBtnNor, OnFuncBtnSpec)

    mEmojiRoot = self:Find("offset/emojiroot")
    mSysEmojiWidget = SysEmojiWidget.new(mEmojiRoot, self, mEventIdBaseSysEmoji, mEventIdSpan)
    --创建各个widget，然后注册进去，id可以定义枚举
    mFuncIdx2Widget[1] = mSysEmojiWidget

    mItemRoot = self:Find("offset/itemroot")
    mItemWidget = ItemWidget.new(mItemRoot, self, mEventIdBaseItem, mEventIdSpan)
    mFuncIdx2Widget[7] = mItemWidget

    mCustomEmojiRoot = self:Find("offset/customemojiroot")
    mCustomEmojiWidget = CustomEmojiWidget.new(mCustomEmojiRoot, self, mEventIdBaseCustomEmoji, mEventIdSpan)
    mFuncIdx2Widget[4] = mCustomEmojiWidget

    mInputHistoryRoot = self:Find("offset/historyroot")
    mInputHistoryWidget = InputHistoryWidget.new(mInputHistoryRoot, self, mEventIdBaseInputHistory, mEventIdSpan)
    mFuncIdx2Widget[3] = mInputHistoryWidget

    mEasyWordRoot = self:Find("offset/easyroot")
    mEasyWordWidget = EasyWordWidget.new(mEasyWordRoot, self, mEventIdBaseEasyWord, mEventIdSpan)
    mFuncIdx2Widget[2] = mEasyWordWidget
end

function OnEnable(self)
    RegEvent(self)
    
    --这里只处理功能按钮显式区域
    mFuncBtnWidget:OnEnable()
    for _, widget in pairs(mFuncIdx2Widget) do
        widget:OnEnable()
    end

    local lastOpenType = ChatMgr.GetCommonLinkOpenType()
    local dataList = ChatMgr.GetFuncDataListByOpenType(lastOpenType)
    if dataList then
        mFuncBtnWidget:Show(dataList)

        local lastFuncIdx = ChatMgr.GetLastFuncIdx()
        mFuncBtnWidget:OpenWidget(lastFuncIdx)
    else
        --报错
    end
end

function OnDisable(self)
    UnRegEvent(self)

    mFuncBtnWidget:OnDisable()
    for _, widget in pairs(mFuncIdx2Widget) do
        widget:OnDisable()
    end

    OnFuncBtnNor(mCurFuncIdx)
    mCurFuncIdx = -1
end

function OnDestroy(self)
    mFuncBtnWidget:OnDestroy()

    for _, widget in pairs(mFuncIdx2Widget) do
        widget:OnDestroy()
    end
end

function OnClick(go, id)
    if id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Chat_CommonLink)
    elseif id == 2503 then
        --打开我的收藏
        UIMgr.UnShowUI(AllUI.UI_Chat_CommonLink)
        CustomEmojiMgr.OpenMyCollectUI()
    elseif id == 2504 then
        --打开表情库
        UIMgr.UnShowUI(AllUI.UI_Chat_CommonLink)
        CustomEmojiMgr.OpenEmojiLibraryUI()
    elseif mEventIdBaseFunc < id and id <= mEventIdBaseSysEmoji then
        mFuncBtnWidget:OnClick(id)
    elseif mEventIdBaseSysEmoji < id and id <= mEventIdBaseItem then
        mSysEmojiWidget:OnClick(id)
    elseif mEventIdBaseItem < id and id <= mEventIdBaseCustomEmoji then
        mItemWidget:OnClick(id)
    elseif mEventIdBaseCustomEmoji < id and id <= mEventIdBaseInputHistory then
        mCustomEmojiWidget:OnClick(id)
    elseif mEventIdBaseInputHistory < id and id <= mEventIdBaseEasyWord then
        mInputHistoryWidget:OnClick(id)
    elseif mEventIdBaseEasyWord < id then
        mEasyWordWidget:OnClick(id)
    end
end

--[[
    @desc: 点击屏幕回调
]]
function OnPressScreen(go, state)
    if not ChatMgr.GetChatCommonLinkNeedCheckPress() then
        return
    end
    if not state then
        return
    end
    
    local localPos = mBg:InverseTransformPoint(UICamera.lastWorldPosition)
    if 0 <= localPos.x and localPos.x <= mBgSize.x and 0 <= localPos.y and localPos.y <= mBgSize.y then
        --
    else
        UIMgr.UnShowUI(AllUI.UI_Chat_CommonLink)
    end
end