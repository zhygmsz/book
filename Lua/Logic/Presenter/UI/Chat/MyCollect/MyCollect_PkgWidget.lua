local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local UIPageAndGrid_ItemEx = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_ItemEx")
local UIPageAndGrid_WidgetEx = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid_WidgetEx")


local PkgItem = class("PkgItem", UIPageAndGrid_ItemEx)
function PkgItem:ctor(trs, eventIdBase, eventIdSpan)
    UIPageAndGrid_ItemEx.ctor(self, trs, eventIdBase, eventIdSpan)

    --组件
    self._icon = trs:Find("icon"):GetComponent("UITexture")
    self._iconGo = self._icon.gameObject

    self._addGo = trs:Find("add").gameObject

    self._tween = trs:GetComponent("ButtonTween")

    --变量

    self:Init()
end

function PkgItem:Show(data, dataIdx)
    UIPageAndGrid_ItemEx.Show(self, data, dataIdx)

    self._tween.enabled = data:CheckIsAdd()
    
    if data:CheckIsAdd() then
        self._addGo:SetActive(true)
        self._iconGo:SetActive(false)
    else
        self._addGo:SetActive(false)
        self._iconGo:SetActive(true)

        --加载系列的第一个图，这里self._data即为PkgInfo
        self:DoShowIcon()
    end
end

function PkgItem:DoShowIcon()
    self._iconGo:SetActive(false)
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
    UIUtil.AdjustInSquare(self._icon, self._squareLen)
end

-------------------------------------------------------------------------------

local PkgWidget = class("PkgWidget", UIPageAndGrid_WidgetEx)
function PkgWidget:ctor(trs, ui, eventIdBase, eventIdSpan)
    UIPageAndGrid_WidgetEx.ctor(self, trs, ui, eventIdBase, eventIdSpan)
    
    self._dataList = CustomEmojiMgr.GetMyCollectPkgListForCollect()
    self._numPerPage = CustomEmojiMgr.GetCollectPkgNumPerPage()

    self:CreatePageAndGrid(PkgItem, self._numPerPage)

    --
    self:Hide()
end

function PkgWidget:OnEnable()
    
end

function PkgWidget:OnDisable()
    
end

function PkgWidget:Show()
    UIPageAndGrid_WidgetEx.Show(self)

    self._dataList = CustomEmojiMgr.GetMyCollectPkgListForCollect()
    self._pageAndGrid:Show(self._dataList)
end

function PkgWidget:Hide()
    UIPageAndGrid_WidgetEx.Hide(self)
end

function PkgWidget:OnSpec(dataIdx)
    UIPageAndGrid_WidgetEx.OnSpec(self, dataIdx)

    local data = self._dataList[dataIdx]
    --data是PkgInfo
    if data:CheckIsAdd() then
        --打开表情库，选中系列 - 我的系列
        CustomEmojiMgr.OpenEmojiLibraryUI(2, 3)
    else
        --打开表情系列详情界面
        CustomEmojiMgr.OpenPkgInfoUI(data)
    end
end

function PkgWidget:OnSameIdClick(dataIdx)
    self:OnSpec(dataIdx)
end

return PkgWidget