local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")

local StoreItem = class("StoreItem", ContentItem)

function StoreItem:ctor(trs, eventId)
    ContentItem.ctor(self, trs, eventId)
    --组件
    self._itemTrs = trs:Find("item")
    self._name = trs:Find("name"):GetComponent("UILabel")
    self._priceIcon = trs:Find("price/icon"):GetComponent("UISprite")
    self._priceNum = trs:Find("price/num"):GetComponent("UILabel")
    self._discountGo = trs:Find("discount").gameObject
    self._discountSp = trs:Find("discount"):GetComponent("UISprite")
    self._discountNumTxt = trs:Find("discount/num"):GetComponent("UILabel")
    self._itemIcon = trs:Find("item/icon"):GetComponent("UISprite")
    self._itemCount = trs:Find("item/count"):GetComponent("UILable")
    self._sellOut = trs:Find("nullbg").gameObject
    self._qualityBg = trs:Find("item/bg"):GetComponent("UISprite")

    --变量

    self._texLoader = LoaderMgr.CreateTextureLoader(self._itemIcon)

end

function StoreItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx)

    self._qualityBg.spriteName = UIUtil.GetItemQualityBgSpName(self._data.itemData.quality)
    
    local canBuy = true
    if self._data.tableData.player_maxcount == 0 then

    else
        canBuy = self._data.info.leftbuycount > 0
    end
    self._sellOut:SetActive(not canBuy)


    self._itemIcon.spriteName = self._data.itemData.icon_big

    local price = CommerceMgr.GetRealPrice(self._data.tableData, 1)
    self._name.text = self._data.itemData.name
    self._priceIcon.spriteName = self._data.moneyItemData.icon_big
    self._priceNum.text = string.NumberFormat(price, 0)

    self._discountGo:SetActive(self._data.tableData.selltype == 2 and  self._data.info.leftbuycount > 0)
    if self._data.tableData.selltype == 2 then
        self._discountNumTxt.text = WordData.GetWordStringByKey("Shop_discounts", (self._data.tableData.discount / 100))
    elseif self._data.tableData.selltype == 3 then
        self._priceNum.text = WordData.GetWordStringByKey("Shop_Free")
    end

    self:CheckIsSellOut()
end

function StoreItem:ShowByData(data)
    ContentItem.ShowByData(self, data)

    --刷新
    
end

function StoreItem:OnDestroy()
    ContentItem.OnDestroy(self)
end

--检测是否售空
function StoreItem:CheckIsSellOut()
    local leftBuyCount = CommerceMgr.GetLeftBuyCountByData(self._data)
    if leftBuyCount >= 1 then
        GameLog.Log("Not sell out !")
        --self._name.color = self._nameColor
        --待实现
        --图片或文字的置灰处理
        --self._priceBg
        --self._priceNum.color = self._priceNumColor
        --self._count.color = self._countColor
        --self._discountSp.spriteName = self._discountSpName
    else
        GameLog.Log("Sell out !")
        -- self._name.color = self._nameColorSellOut
        -- self._priceNum.color = self._priceNumColorSellOut
        -- --self._count.color = self._countColorSellOut
        -- self._discountGo:SetActive(true)
        -- self._discountSp.spriteName = self._discountSpNameGray
        -- self._discountNum.text = self._discountDesSellOut
    end
end

local StoreWidget = class("StoreWidget")
function StoreWidget:ctor(trs, eventIdBase, OnClickCallback)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    --
    self._eventIdBase = eventIdBase
    --
    self._funcOnClickItem = function(data)
        self._data = data
        self:OnClickItem(data)
    end

    self._widgetTrs = trs:Find("widget")
    self._contentWidget = ContentWidget.new(self._widgetTrs, self._funcOnClickItem, self._eventIdBase, StoreItem)

    --变量
    self._isShowed = false
    self._showIndex = 1
    self._dataList = {}

    self._clickCallBack = OnClickCallback

    self:Hide()
end

function StoreWidget:OnClick(eventId)
    --self:OnClickItem(self._data)
    self._contentWidget:OnClick(eventId)
end

function StoreWidget:OnClickItem(data)
    --刷新right区域
    self._clickCallBack(data)
end

function StoreWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function StoreWidget:Show(topIdx)
    self:SetVisible(true)

    --获取数据列表，刷新
    self._showIndex = topIdx
    self._dataList = CommerceMgr.GetFullDataList(2, topIdx, 0)
    self._contentWidget:Show(self._dataList)
end

function StoreWidget:Hide()
    self:SetVisible(false)
end

function StoreWidget:OnDestroy()
    self:Hide()
    self._contentWidget:OnDestroy()
    self._dataList = {}
end

function StoreWidget:GetDataByGoodsId(goodsId)
    local dataList = CommerceMgr.GetFullDataList(2, self._showIndex, 0)
    if dataList == nil or goodsId == nil then
        GameLog.LogError("Error !")
        return nil 
    end
    
    for _, data in ipairs(dataList) do
        if goodsId == data.tableData.id then
            return data
        end
    end

    return nil
end

function StoreWidget:OnBuy(goodsId)
    --根据dataList找到realIdx
    --再用realIdx找到item
    for idx, data in ipairs(self._dataList) do
        if data.tableData.id == goodsId then
            --idx就是realIdx + 1
            --准备realIdx,data
            --刷新ContentWidget
            self._contentWidget:UpdateItem(idx, data)
            break
        end
    end
end

return StoreWidget