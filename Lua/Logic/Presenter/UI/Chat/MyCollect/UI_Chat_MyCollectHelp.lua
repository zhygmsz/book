module("UI_Chat_MyCollectHelp", package.seeall)

local ContentItemCheck = require("Logic/Presenter/UI/Shop/ContentItemCheck")
local ContentWidgetCheck = require("Logic/Presenter/UI/Shop/ContentWidgetCheck")

--组件
local mSelf
local mWidgetTrs
local mCollectDesLabel
local mRemainedDesLabel


--变量
local mEvents
local mMiddleWidget

local mMiddleEventIdBase = 0
local mMiddleEventIdSpan = 1

local mCollectDes = "我收藏的表情（%d）"
local mRemainedDes = "剩余可添加数量：%d张"


local MiddleItem = class("MiddleItem", ContentItemCheck)
function MiddleItem:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemCheck.ctor(self, trs, itemIdx, eventIdSpanOffset)
    --组件
    self._icon = trs:Find("icon"):GetComponent("UITexture")
    self._iconGo = self._icon.gameObject

    --变量
end

function MiddleItem:InitUIEvent()
    self._uiEvent = self._transform:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = self._eventIdSpanOffset + 1
end

function MiddleItem:Show(data, dataIdx)
    ContentItemCheck.Show(self, data, dataIdx)

    self:DoShowIcon()
end

function MiddleItem:OnLoadTex()
    self._iconGo:SetActive(true)

    --UIUtil.AdjustInSquare(self._icon, self._squareLen)
end

function MiddleItem:DoShowIcon()
    self._iconGo:SetActive(false)

    UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), self._data:GetUrl(), true, self.OnLoadTex, self)
end

--local方法
local function InvokeData()
    local data = CustomEmojiMgr.GetMyCollectHelpData()
    if data.func then
        data.func(mMiddleWidget:GetCheckedDic(), mMiddleWidget:GetDataList())
        --每次调用完，清空
        CustomEmojiMgr.ClearMyCollectHelpData()
    end
end

local function DoShowRemainedDes(remainedNum)
    mRemainedDesLabel.text = string.format(mRemainedDes, remainedNum)
end

local function DoShowMiddle()
    local myCollectEmojiList = CustomEmojiMgr.GetMyCollectEmojiListForCustom()
    mCollectDesLabel.text = string.format(mCollectDes, #myCollectEmojiList - 1)
    --去掉第一个
    local data = CustomEmojiMgr.GetMyCollectHelpData()
    DoShowRemainedDes(data.remainedNum)
    mMiddleWidget:Show(myCollectEmojiList, false, data.remainedNum, 2, #myCollectEmojiList)
end

local function OnMiddleWidgetClick(success, realIdx, checked, remainedNum)
    if success then
        --更新剩余可添加数量
        DoShowRemainedDes(remainedNum)
    else
        --提示勾选数量已达上限
        TipsMgr.TipByFormat("勾选数量已达上限")
    end
end

local function RegEvent(self)
    mEvents = {}
end

local function UnRegEvent(self)
    mEvents = nil
end

function OnCreate(self)
    mSelf = self

    mWidgetTrs = self:Find("Offset/middle/widget")
    mMiddleWidget = ContentWidgetCheck.new(mWidgetTrs, MiddleItem, mMiddleEventIdBase, mMiddleEventIdSpan, OnMiddleWidgetClick)

    mCollectDesLabel = self:FindComponent("UILabel", "Offset/collectdes")
    mRemainedDesLabel = self:FindComponent("UILabel", "Offset/remaindes")
end

function OnEnable(self)
    RegEvent()

    DoShowMiddle()
end

function OnDisable(self)
    UnRegEvent()
end

function OnDestroy(self)
    mMiddleWidget:OnDestroy()
end

function OnClick(go, id)
    if id == -100 then
        --确定按钮
        UIMgr.UnShowUI(AllUI.UI_Chat_MyCollectHelp)
        MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_MYCOLLECTHELP, false)
        --抛出数据
        InvokeData()
    elseif mMiddleWidget:CheckEventIdIsIn(id) then
        --落在middle区域
        mMiddleWidget:OnClick(id)
    end
end


