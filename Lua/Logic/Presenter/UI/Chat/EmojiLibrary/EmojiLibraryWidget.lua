local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")

--该文件内的私有变量
--单品1，系列2
local mEmojiOrSerie = 1
--最火1，最新2，我的3
local mHotOrTimeOrMy = 1


local EmojiLibraryItem = class("EmojiLibraryItem", ContentItem)
function EmojiLibraryItem:ctor(trs, eventId)
    ContentItem.ctor(self, trs, eventId)

    --组件
    self._addBgGo = trs:Find("addbg").gameObject

    self._icon = trs:Find("icon"):GetComponent("UITexture")
    self._iconGo = self._icon.gameObject

    self._des = trs:Find("des"):GetComponent("UILabel")
    self._des.text = ""

    --变量
    self._squareLen = 146
end

--[[
    @desc: 
    --@data: 根据当前选中的页签不同，可能是一个表情信息，也可能是一个系列信息
	--@selectedRealIdx: 
]]
function EmojiLibraryItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx)

    if data:CheckIsAdd() then
        self._addBgGo:SetActive(true)
        self._iconGo:SetActive(false)

        if mEmojiOrSerie == 1 then
            self._des.text = CustomEmojiMgr.GetAddEmojiDes()
        elseif mEmojiOrSerie == 2 then
            self._des.text = CustomEmojiMgr.GetAddSerieDes()
        end
    else
        self._addBgGo:SetActive(false)
        self._iconGo:SetActive(true)

        self:DoShowIcon()
    end
end

function EmojiLibraryItem:OnLoadTex()
    self._iconGo:SetActive(true)
    UIUtil.AdjustInSquare(self._icon, self._squareLen)
end

--[[
    @desc: 请求系列的第一个表情图信息回调，需要判断回调回来的和当前显示的是否还是同一个
    --@emojiInfo: 
]]
function EmojiLibraryItem:OnGetEmojiList(pkgId, emojiList)
    if self._data:GetPkgId() ~= pkgId then
        return
    end
    local firstOne = emojiList[1]
    --可以保证emojiList是table，但不能保证其内部有元素
    if firstOne then
        UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), firstOne:GetUrl(), true, self.OnLoadTex, self)
    end
end

--[[
    @desc: 显示表情细节
]]
function EmojiLibraryItem:DoShowIcon()
    --EmojiInfo/PkgInfo都有GetName方法
    self._des.text = self._data:GetName()

    --显示之前先隐藏
    self._iconGo:SetActive(false)
    
    if mEmojiOrSerie == 1 then
        --加载单品
        UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), self._data:GetUrl(), true, self.OnLoadTex, self)
    elseif mEmojiOrSerie == 2 then
        --加载系列的第一个图，这里self._data即为PkgInfo
        self._data:RequestEmojiInfoList(self.OnGetEmojiList, self)
    end
end

function EmojiLibraryItem:OnDestroy()
    --卸载资源
    ContentItem.OnDestroy(self)
end


local EmojiLibraryWidget = class("EmojiLibraryWidget")
function EmojiLibraryWidget:ctor(trs, eventIdBase, funcOnClickItem)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._widgetTrs = trs:Find("widget")
    self._contentWidget = ContentWidget.new(self._widgetTrs, funcOnClickItem, eventIdBase, EmojiLibraryItem)

    --变量
    self._isShowed = false
    self._dataList = nil

    self:SetVisible(false)
end

function EmojiLibraryWidget:OnClick(eventId)
    self._contentWidget:OnClick(eventId)
end

function EmojiLibraryWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function EmojiLibraryWidget:Show(dataList, restorePos)
    self:SetVisible(true)

    self._dataList = dataList
    self._contentWidget:Show(dataList, restorePos)
end

function EmojiLibraryWidget:SetEmojiOrSerie(emojiOrSerie)
    mEmojiOrSerie = emojiOrSerie
end

function EmojiLibraryWidget:SetHotOrTimeOrMy(hotOrTimeOrMy)
    mHotOrTimeOrMy = hotOrTimeOrMy
end

function EmojiLibraryWidget:OnEnable()

end

function EmojiLibraryWidget:OnDisable()
    
end

function EmojiLibraryWidget:OnDestroy()
    self._contentWidget:OnDestroy()
end

return EmojiLibraryWidget