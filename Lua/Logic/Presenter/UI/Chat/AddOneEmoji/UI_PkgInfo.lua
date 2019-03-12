module("UI_PkgInfo", package.seeall)

local ContentItemClick = require("Logic/Presenter/UI/Shop/ContentItemClick")
local ContentWidgetClick = require("Logic/Presenter/UI/Shop/ContentWidgetClick")

--组件
local mSelf
local mPkgNameLabel
local mPkgDesLabel
local mPkgHotNumLabel

local mCoverTex

local mPlayerIdLabel
local mPlayerNameLabel

local mRightBtnLabel

local mMiddleTrs

--变量
local mEvents = nil

local mShowingPkgId
local mShowingPkgInfo

--保存或使用选项
local mSaveOrUse = 1
local mRightBtnLblDes = {
    [1] = "保存",
    [2] = "使用表情"
}

local mMiddleWidget
local mMiddleEventIdBase = 0
local mMiddleEventIdSpan = 1

local mCoverTexSquareLen = 150

local MiddleItem = class("MiddleItem", ContentItemClick)
function MiddleItem:ctor(trs, itemIdx, eventIdSpanOffset)
    ContentItemClick.ctor(self, trs, itemIdx, eventIdSpanOffset)
    --组件
    self._icon = trs:Find("icon"):GetComponent("UITexture")
    self._iconGo = self._icon.gameObject

    --变量
    self._squareLen = 110
end

function MiddleItem:InitUIEvent()
    self._uiEvent = self._transform:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = self._eventIdSpanOffset + 1
end

--[[
    @desc: 
    --@data: PkgInfo._emojiInfoList[1]
]]
function MiddleItem:Show(data, dataIdx)
    ContentItemClick.Show(self, data, dataIdx)

    self:DoShowIcon()
end

function MiddleItem:OnLoadTex()
    self._iconGo:SetActive(true)

    UIUtil.AdjustInSquare(self._icon, self._squareLen, false)
end

function MiddleItem:DoShowIcon()
    self._iconGo:SetActive(false)

    UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), self._data:GetUrl(), true, self.OnLoadTex, self)
end

--local方法
local function OnLoadCoverTex()
    UIUtil.AdjustInSquare(mCoverTex, mCoverTexSquareLen, true)
end

local function SetCoverTex(url)
    if not url then
        return
    end
    UIUtil.LoadImage(mCoverTex, CustomEmojiMgr.GetEmojiSize(), url, true, OnLoadCoverTex, nil)
end

local function SetSaveOrUse(pkgInfo)
    local existIn = CustomEmojiMgr.CheckExistInMyCollectPkgList(mShowingPkgInfo:GetPkgId())
    if existIn then
        mSaveOrUse = 2
    else
        mSaveOrUse = 1
    end

    mRightBtnLabel.text = mRightBtnLblDes[mSaveOrUse]
end

local function DoShowHot()
    mPkgHotNumLabel.text = tostring(mShowingPkgInfo:GetHot())
end

--[[
    @desc: 显示文字类
]]
local function DoShowText()
    mPkgNameLabel.text = mShowingPkgInfo:GetName()
    mPkgDesLabel.text = mShowingPkgInfo:GetDes()
    DoShowHot()
end

--[[
    @desc: 
    --@state:
	--@jsonData: 内部含有系列id，和热度信息，同步本地并刷UI
]]
local function OnCollectFinish(state, jsonData)
    if state then
        if jsonData.result.serie_id == mShowingPkgInfo:GetPkgId() then
            --修改本地热度
            mShowingPkgInfo:SetHot(jsonData.result.hot)
            --同步到收藏列表
            CustomEmojiMgr.AddPkg2MyCollectListByPkgInfo(mShowingPkgInfo)
            --刷UI
            SetSaveOrUse(mShowingPkgInfo)
            DoShowHot()

            TipsMgr.TipByFormat("收藏成功")
        end
    else
        TipsMgr.TipByFormat("收藏失败")
    end
end

local function OnClickRightBtn()
    if mSaveOrUse == 1 then
        --保存，发送收藏请求
        SNSCustomEmojiMgr.RequestCollectPkg(mShowingPkgInfo:GetPkgId(), OnCollectFinish, nil)
    elseif mSaveOrUse == 2 then
    --使用表情
    end
end

--[[
    @desc: 玩家信息回调，用playerId判断回来的是否和当前显示的是一个
]]
local function OnGetPlayerInfo(playerId, playerInfo)
    playerId = tonumber(playerId)
    if playerId == mShowingPkgInfo:GetPlayerId() and playerInfo then
        mPlayerNameLabel.text = playerInfo:GetNickName()
    end
end

--[[
    @desc: 显示home按钮区域
--]]
local function DoShowHome()
    local playerId = mShowingPkgInfo:GetPlayerId()
    mPlayerIdLabel.text = playerId
    SocialPlayerInfoMgr.GetPlayerInfoById(playerId, OnGetPlayerInfo)
end

local function OnGetEmojiList(pkgId, emojiList)
    if mShowingPkgInfo:GetPkgId() == pkgId then
        mMiddleWidget:Show(emojiList)
        --默认点中第一个表情
        mMiddleWidget:AutoSelectRealIdx(1)
    end
end

local function DoShowMiddle()
    --表情图列表单独异步请求
    mShowingPkgInfo:RequestEmojiInfoList(OnGetEmojiList, nil)
end

--[[
    @desc: 依据完整数据刷新方法
    --@pkgInfo: 
]]
local function OnGetPkgInfo(pkgInfo)
    mShowingPkgInfo = pkgInfo
    --
    DoShowText()
    DoShowHome()
    SetSaveOrUse(pkgInfo)
    DoShowMiddle()
end

local function OnNor(realIdx)
end

local function OnSpec(realIdx)
    local emojiInfo = mShowingPkgInfo:GetEmojiInfoByIdx(realIdx)
    if emojiInfo then
        SetCoverTex(emojiInfo:GetUrl())
    end
end

local function RegEvent()
    mEvents = {}
end

local function UnRegEvent()
    mEvents = nil
end

function OnCreate(self)
    mSelf = self

    mPkgNameLabel = self:FindComponent("UILabel", "Offset/middle/name")
    mPkgDesLabel = self:FindComponent("UILabel", "Offset/middle/des")
    mPkgHotNumLabel = self:FindComponent("UILabel", "Offset/middle/hot/num")

    mCoverTex = self:FindComponent("UITexture", "Offset/icon/tex")

    mPlayerIdLabel = self:FindComponent("UILabel", "Offset/playername/id")
    mPlayerNameLabel = self:FindComponent("UILabel", "Offset/playername/name")

    mRightBtnLabel = self:FindComponent("UILabel", "Offset/right/label")

    mMiddleTrs = self:Find("Offset/middle/list/widget")
    mMiddleWidget = ContentWidgetClick.new(mMiddleTrs, MiddleItem, mMiddleEventIdBase, mMiddleEventIdSpan, OnNor, OnSpec)
end

function OnEnable(self)
    RegEvent()

    local data = CustomEmojiMgr.GetShowingPkgInfoData()
    --判断data是pkgId还是pkgInfo
    if type(data) == "string" then
        --根据一个系列id，请求该系列的信息，不包含表情图列表
        --SNSCustomEmojiMgr.RequestEmojiListByPkgId(mShowingPkgId, OnGetPkgInfo, nil)
        mShowingPkgId = data
    elseif type(data) == "table" then
        OnGetPkgInfo(data)
    end
end

function OnDisable(self)
    UnRegEvent()

    CustomEmojiMgr.DoInvokeFunc(AllUI.UI_PkgInfo)
end

function OnDestroy(self)
end

function OnClick(go, id)
    if id == -100 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_PkgInfo)
    elseif id == -101 then
        --分享
    elseif id == -102 then
        --保存或使用
        OnClickRightBtn()
    elseif id == -103 then
        --home
    elseif mMiddleWidget:CheckEventIdIsIn(id) then
        --middle区域
        mMiddleWidget:OnClick(id)
    end
end
