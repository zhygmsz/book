local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local UIPageAndGrid_Item = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Item")
local UIPageAndGrid_Widget = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_Widget")


local EmojiItem = class("EmojiItem", UIPageAndGrid_Item)
function EmojiItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_Item.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._icon = trs:Find("icon"):GetComponent("UITexture")
    self._iconGo = self._icon.gameObject

    self._addGo = trs:Find("add").gameObject

    self._tween = trs:GetComponent("ButtonTween")

    --变量
    self._squareLen = 88

    self:Init()
end

function EmojiItem:Show(data, dataIdx)
    UIPageAndGrid_Item.Show(self, data, dataIdx)

    self._tween.enabled = data:CheckIsAdd()

    if data:CheckIsAdd() then
        self._iconGo:SetActive(false)
        self._addGo:SetActive(true)
    else
        self._iconGo:SetActive(true)
        self._addGo:SetActive(false)

        --显示
        self:DoShowIcon()
    end
end

function EmojiItem:OnLoadTex()
    UIUtil.AdjustInSquare(self._icon, self._squareLen)
end

function EmojiItem:DoShowIcon()
    UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), self._data:GetUrl(), true, self.OnLoadTex, self)
end

-------------------------------------------------------------------------------

local EmojiWidget = class("EmojiWidget", UIPageAndGrid_Widget)
function EmojiWidget:ctor(trs, ui, eventIdBase, eventIdSpan)
    UIPageAndGrid_Widget.ctor(self, trs, ui, eventIdBase, eventIdSpan)

    self._numPerPage = CustomEmojiMgr.GetCustomEmojiNumPerPage()

    self:CreatePageAndGrid(EmojiItem, self._numPerPage)

    --
    self:Hide()

    --用于发送消息的Chat_pb.ChatMsgCommon结构缓存一份，不至于每次发送表情都创建一个
    self._msgCommon = Chat_pb.ChatMsgCommon()
    self._msgCommon.contentStyle = Chat_pb.ChatContentStyle_Emoji
    ChatMgr.SetSenderInfo(self._msgCommon.sender)
    self._emojiLink = self._msgCommon.links:add()
end

function EmojiWidget:OnSpec(dataIdx)
    UIPageAndGrid_Widget.OnSpec(self, dataIdx)

    local data = self._dataList[dataIdx]
    if data:CheckIsAdd() then
        UIMgr.UnShowUI(AllUI.UI_Chat_CommonLink)
        CustomEmojiMgr.OpenMyCollectUI()
    else
        --直接发送消息
        self._msgCommon.roomType = ChatMgr.GetChatMainRoomType()
        MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.EMOJI_CUSTOM, self._emojiLink, data:GetPicId())

        ChatMgr.RequestSendRoomMessage(self._msgCommon.roomType, "", Chat_pb.CHATMSG_COMMON, self._msgCommon:SerializeToString())
    end
end

function EmojiWidget:OnSameIdClick(dataIdx)
    self:OnSpec(dataIdx)
end

function EmojiWidget:Show(dataList)
    UIPageAndGrid_Widget.Show(self)

    self._dataList = dataList
    self._pageAndGrid:Show(dataList)
end

-------------------------------------------------------------------------------

local PkgItem = class("PkgItem", UIPageAndGrid_Item)
function PkgItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_Item.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._icon = trs:Find("icon"):GetComponent("UITexture")
    self._iconGo = self._icon.gameObject

    self._heartGo = trs:Find("heart").gameObject

    --变量
    self._squareLen = 50

    self:Init()
end

function PkgItem:Show(data, dataIdx)
    UIPageAndGrid_Item.Show(self, data, dataIdx)

    if data:CheckIsAdd() then
        self._heartGo:SetActive(true)
        self._iconGo:SetActive(false)
    else
        self._heartGo:SetActive(false)
        self._iconGo:SetActive(true)

        --显示表情包的缩略图
        self:DoShowIcon()
    end
end

function PkgItem:DoShowIcon()
    self._iconGo:SetActive(false)
    --加载系列的第一个图，这里self._data即为PkgInfo
    self._data:RequestEmojiInfoList(self.OnGetEmojiList, self)
end

--[[
    @desc: 请求系列的第一个表情图信息回调，需要判断回调回来的和当前显示的是否还是同一个
    --@emojiInfo: 
]]
function PkgItem:OnGetEmojiList(pkgId, emojiList)
    if self._data:GetPkgId() ~= pkgId then
        return
    end
    local firstOne = emojiList[1]
    --可以保证emojiList是table，但不能保证其内部有元素
    if firstOne then
        UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), firstOne:GetUrl(), true, self.OnLoadTex, self)
    end
end

function PkgItem:OnLoadTex()
    self._iconGo:SetActive(true)
    UIUtil.AdjustInSquare(self._icon, self._squareLen, false)
end

-------------------------------------------------------------------------------

local PkgWidget = class("PkgWidget", UIPageAndGrid_Widget)
function PkgWidget:ctor(trs, ui, OnClickCallback, eventIdBase, eventIdSpan)
    UIPageAndGrid_Widget.ctor(self, trs, ui, eventIdBase, eventIdSpan)

    self._numPerPage = CustomEmojiMgr.GetCustomPkgNumPerPage()
    self._dataList = CustomEmojiMgr.GetMyCollectPkgListForCustom()
    
    self:CreatePageAndGrid(PkgItem, self._numPerPage)
    --
    self._onClickCallback = OnClickCallback

    self:Hide()
end

function PkgWidget:Show()
    UIPageAndGrid_Widget.Show(self)

    self._dataList = CustomEmojiMgr.GetMyCollectPkgListForCustom()
    self._pageAndGrid:Show(self._dataList)
end

function PkgWidget:OnSpec(dataIdx)
    UIPageAndGrid_Widget.OnSpec(self, dataIdx)

    if self._onClickCallback then
        self._onClickCallback(self._dataList[dataIdx])
    end
end

function PkgWidget:AutoSelect(dataIdx)
    self._interactClick:OnClick(dataIdx)
end

-------------------------------------------------------------------------------

local CustomEmojiWidget = class("CustomEmojiWidget")
function CustomEmojiWidget:ctor(trs, ui, eventIdBase, eventIdSpan)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._emojiTrs = trs:Find("emojiroot")
    self._pkgTrs = trs:Find("packageroot")

    self._eventIdBase = eventIdBase
    self._eventIdSpan = eventIdSpan

    self._emojiEventIdBase = self._eventIdBase + 1000
    self._pkgEventIdBase = self._eventIdBase

    self._funcOnClickPkgItem = function(data)
        self:OnClickPkgItem(data)
    end

    self._emojiWidget = EmojiWidget.new(self._emojiTrs, ui, self._emojiEventIdBase, self._eventIdSpan)
    self._pkgWidget = PkgWidget.new(self._pkgTrs, ui, self._funcOnClickPkgItem, self._pkgEventIdBase, self._eventIdSpan)

    --变量
    self._isShowed = false
    --当前点中的pkgInfo
    self._showingPkgInfo = nil
    
    self:Hide()
end

function CustomEmojiWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function CustomEmojiWidget:Show()
    self:SetVisible(true)

    self._pkgWidget:Show()
    self._pkgWidget:AutoSelect(1)
end

function CustomEmojiWidget:Hide()
    self:SetVisible(false)

    self._emojiWidget:Hide()
    self._pkgWidget:Hide()
end

function CustomEmojiWidget:OnGetEmojiList(pkgId, emojiList)
    if self._showingPkgInfo:GetPkgId() == pkgId then
        self._emojiWidget:Show(emojiList)
    end
end

function CustomEmojiWidget:DoShowOnePkg(pkgInfo)
    if pkgInfo then
        self._showingPkgInfo = pkgInfo
        pkgInfo:RequestEmojiInfoList(self.OnGetEmojiList, self)
    end
end

function CustomEmojiWidget:OnClickPkgItem(data)
    --先清空emojiwidget区域，再显示新的，pageandgrid组件每次show时，自带清理
    --切换表情包显示
    if data:CheckIsAdd() then
        --我的收藏
        local emojiList = CustomEmojiMgr.GetMyCollectEmojiListForCustom()
        self._emojiWidget:Show(emojiList)
    else
        self:DoShowOnePkg(data)
    end
end

function CustomEmojiWidget:OnEnable()
    self._emojiWidget:OnEnable()
    self._pkgWidget:OnEnable()
end

function CustomEmojiWidget:OnDisable()
    self._emojiWidget:OnDisable()
    self._pkgWidget:OnDisable()
end

function CustomEmojiWidget:OnDestroy()
    self._emojiWidget:OnDestory()
    self._pkgWidget:OnDestory()
end

function CustomEmojiWidget:OnClick(id)
    if self._pkgEventIdBase < id and id <= self._emojiEventIdBase then
        self._pkgWidget:OnClick(id)
    elseif self._emojiEventIdBase < id then
        self._emojiWidget:OnClick(id)
    end
end

return CustomEmojiWidget