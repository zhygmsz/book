local IMEItem = require("Logic/Presenter/UI/Shop/CommerceIME")

------------------------------------PanelItem------------------------------------
local PanelItem = class("PanelItem")
function PanelItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._des1 = trs:Find("table/des1"):GetComponent("UILabel")
    self._des2 = trs:Find("table/des2"):GetComponent("UILabel")
    self._des2Trs = self._des2.transform
    self._des3 = trs:Find("table/des3"):GetComponent("UILabel")
    self._timesDes = trs:Find("table/timesdes"):GetComponent("UILabel")
    self._times = trs:Find("table/timesdes/times"):GetComponent("UILabel")
    self._timesDesGo = self._timesDes.gameObject
    self._timesDesGo:SetActive(true)
    self._table = trs:Find("table"):GetComponent("UITable")

    self._cutdownNode = trs:Find("table/cutdown")
    if self._cutdownNode ~= nil then
        self._cutdownNodeObj = self._cutdownNode.gameObject
    end

    self._timeCutdownObj = trs:Find("table/cutdown/time")
    if self._timeCutdownObj ~= nil then
        self._timeCutdownTxt = self._timeCutdownObj:GetComponent("UILabel")
    end

    --变量
    self._buyOrSell = -1
    self._isShowed = false
    self._data = nil
    self._playerBuyCountLimitStr = WordData.GetWordStringByKey("Shop_buyinfo_show_1")
    self._playerBuyWeekCountLimitStr = WordData.GetWordStringByKey("Shop_buyinfo_show_8")
    self._serverBuyCountLimitStr = WordData.GetWordStringByKey("Shop_buyinfo_show_2")
    --self._playerSellCountLimitStr = "今日可出售:"
    self._des2BuyPos = Vector3(-145, 25, 0)
    self._des2SellPos = Vector3(-145, 65, 0)
    self.timer = nil
end

function PanelItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function PanelItem:DoShowTimes()
    if self._buyOrSell == 1 then
        if self._data.tableData.limitcounttype == 1 then
            --个人限购
            self._timesDesGo:SetActive(true) 
           
            self._times.text = tostring(self._data.info.leftbuycount) .. "/" .. tostring(self._data.tableData.player_maxcount)
            if self._data.tableData.limittype == 1 then
                self._timesDes.text = self._playerBuyCountLimitStr
            elseif self._data.tableData.limittype == 2 then
                self._timesDes.text = self._playerBuyWeekCountLimitStr
            end
        elseif self._data.tableData.limitcounttype == 2 then
            --服务器限购
            self._timesDesGo:SetActive(true) 
            self._timesDes.text = self._serverBuyCountLimitStr
            self._times.text = tostring(self._data.info.leftbuycount) .. "/" .. tostring(self._data.tableData.maxcount)
        elseif self._data.tableData.limitcounttype == 3 then
            --不限购
            self._timesDesGo:SetActive(false)
        end
    elseif self._buyOrSell == 2 then
        --self._timesDes.text = self._playerSellCountLimitStr
        self._times.text = tostring(self._data.info.leftsellcount) .. "/" .. tostring(self._data.tableData.player_maxcount)
        self._timesDesGo:SetActive(false)       
    else
        self._timesDesGo:SetActive(false)
    end

    local timer = nil
    local function SetTable()
        self._table:Reposition()
        if timer then
            timer:Stop()
        end
    end
    timer = Timer.New(SetTable, 0, 1)
    timer:Start()
end

function PanelItem:Show(data, buyOrSell)
    self:SetVisible(true)
    self._buyOrSell = buyOrSell
    self._data = data

    self._des1.text = self._data.itemData.coredesc

    --[[
    if self._buyOrSell == 1 then
        self._timesDesGo:SetActive(true)
        self:DoShowTimes()
        self._des2Trs.localPosition = self._des2BuyPos
    elseif self._buyOrSell == 2 then
        self._timesDesGo:SetActive(false)
        self._des2Trs.localPosition = self._des2SellPos
    end
    --]]
    self:DoShowTimes()

    self._des2.text = self._data.itemData.fundesc
    self._des2:Update()
    self._des3.text = self._data.itemData.clientdesc
    self._des3:Update()

    if self.timer ~= nil then
        GameTimer.DeleteTimer(self.timer)
    end

    if self._data.info.endbuytime > 0 then
        local  function RefreshCutdown()
            if self._timeCutdownObj ~= nil then
                local leftTimeStamp = TimeUtils.TimeStampLeft(self._data.info.endbuytime)
                local timeTxt = TimeUtils.FormatTime(leftTimeStamp, 6)
                self._timeCutdownTxt.text = timeTxt
            end   
        end
        RefreshCutdown()
        self.timer = GameTimer.AddForeverTimer(1, RefreshCutdown)
    else
        if self._cutdownNodeObj then
            self._cutdownNodeObj.gameObject:SetActive(false)
        end
    end
end

function PanelItem:Hide()
    self:SetVisible(false)
    self._buyOrSell = -1
    self._data = nil
end
------------------------------------PanelItem------------------------------------

------------------------------------DiscountItem------------------------------------
local DiscountItem = class("DiscountItem")
function DiscountItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._originIcon = trs:Find("originicon"):GetComponent("UISprite")
    self._curIcon = trs:Find("curicon"):GetComponent("UISprite")
    self._originNum = trs:Find("originnum"):GetComponent("UILabel")
    self._curNum = trs:Find("curnum"):GetComponent("UILabel")
    self._discountNum = trs:Find("discount/num"):GetComponent("UILabel")
    
    --变量
    self._isShowed = false
    self._buyOrSell = -1
    self._data = nil
end

function DiscountItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function DiscountItem:Show(data, buyOrSell)
    self:SetVisible(true)
    self._buyOrSell = buyOrSell
    --对于出售来说，没有折扣类的商品
    self._data = data

    self._originIcon.spriteName = self._data.moneyItemData.icon_big
    self._curIcon.spriteName = self._data.moneyItemData.icon_big
    self._originNum.text = tostring(self._data.tableData.price)
    self._curNum.text = tostring(CommerceMgr.GetRealPrice(self._data.tableData, self._buyOrSell))
    self._discountNum.text = CommerceMgr.GetDiscountNumStr(self._data)
end

function DiscountItem:Hide()
    self:SetVisible(false)
    self._buyOrSell = -1
    self._data = nil
end
------------------------------------DiscountItem------------------------------------

------------------------------------UpdownItem------------------------------------
local UpdownItem = class("UpdownItem")
function UpdownItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    --变量
    self._isShowed = false
    self._buyOrSell = -1
    self._data = nil
end

function UpdownItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function UpdownItem:Show(data, buyOrSell)
    self:SetVisible(true)
    self._buyOrSell = buyOrSell
    self._data = data

    --目前没有动态价格，先不实现
end

function UpdownItem:Hide()
    self:SetVisible(false)
    self._buyOrSell = -1
    self._data = nil
end
------------------------------------UpdownItem------------------------------------

------------------------------------ItemShowItem------------------------------------
local ItemShowItem = class("ItemShowItem")
function ItemShowItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    --show
    self._showGo = trs:Find("show").gameObject
    self._showGo:SetActive(false)
    --hide
    self._hdieLbl = trs:Find("hide"):GetComponent("UILabel")
    self._hideGo = self._hdieLbl.gameObject
    self._hideGo:SetActive(true)

    self._name = trs:Find("show/name"):GetComponent("UILabel")

    --各种描述
    self._panelTrs = trs:Find("show/panel")
    self._panelItem = PanelItem.new(self._panelTrs)
    self._panelItem:Hide()

    --折扣价格
    self._discountTrs = trs:Find("show/discount")
    self._discountItem = DiscountItem.new(self._discountTrs)
    self._discountItem:Hide()
    --上下浮动价格
    self._updownTrs = trs:Find("show/updown")
    self._updownItem = UpdownItem.new(self._updownTrs)
    self._updownItem:Hide()

    --变量
    self._buyOrSell = -1
    self._data = nil
    self._hideDesBuy = WordData.GetWordStringByKey("Shop_buyinfo_show_3")
    self._hideDesSell = "在左侧选择想卖的物品吧"

    self:Show(nil)
end

function ItemShowItem:DoShowPrice()
    if not self._data then
        self._discountItem:Hide()
        self._updownItem:Hide()
    end

    if self._data.tableData.selltype == Shop_pb.GoodsInfo.ORIGINAL_PRICE then
        --原价
        self._discountItem:Hide()
        self._updownItem:Hide()
    elseif self._data.tableData.selltype == Shop_pb.GoodsInfo.DISCOUNT_PRICE then
        --折扣
        self._updownItem:Hide()
        self._discountItem:Show(self._data, self._buyOrSell)
    elseif self._data.tableData.selltype == Shop_pb.GoodsInfo.FREE_PRICE then
        --免费
        self._discountItem:Hide()
        self._updownItem:Hide()
    elseif self._data.tableData.selltype == Shop_pb.GoodsInfo.DINAMIC_PRICE then
        --动态价格
        self._discountItem:Hide()
        self._updownItem:Show(self._data, self._buyOrSell)
    end
end

function ItemShowItem:DoShowNil()
    self._showGo:SetActive(false)
    self._hideGo:SetActive(true)

    if self._buyOrSell == 1 then
        self._hdieLbl.text = self._hideDesBuy
    elseif self._buyOrSell == 2 then
        self._hdieLbl.text = self._hideDesSell
    else
        self._hdieLbl.text = ""
    end
end

function ItemShowItem:DoShowData()
    if not self._data then
        self:DoShowNil()
        return
    end

    self._hideGo:SetActive(false)
    self._showGo:SetActive(true)

    --物品名字
    self._name.text = self._data.itemData.name
    --各种描述
    self._panelItem:Show(self._data, self._buyOrSell)

    --price
    self:DoShowPrice()
end

function ItemShowItem:Show(data, buyOrSell)
    self._gameObject:SetActive(true)
    self._buyOrSell = buyOrSell
    self._data = data

    if self._data then
        self:DoShowData()
    else
        self:DoShowNil()
    end
end

function ItemShowItem:Hide()
    self._panelItem:Hide()
    self._discountItem:Hide()
    self._updownItem:Hide()
    self._buyOrSell = -1
    self._data = nil
end
------------------------------------ItemShowItem------------------------------------

------------------------------------RightItem------------------------------------
local RightItem = class("RightItem")
function RightItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    --itemshow
    self._itemShowTrs = trs:Find("itemshow")
    self._itemShowItem = ItemShowItem.new(self._itemShowTrs)
    --num
    self._countNum = trs:Find("num/num"):GetComponent("UILabel")
    self._reduceGo = trs:Find("num/reduce").gameObject
    self._addGo = trs:Find("num/add").gameObject
    self._lisReduce = UIEventListener.Get(self._reduceGo)
    self._lisReduce.onClick = UIEventListener.VoidDelegate(self.OnReduceClick, self)
    self._lisAdd = UIEventListener.Get(self._addGo)
    self._lisAdd.onClick = UIEventListener.VoidDelegate(self.OnAddClick, self)
    self._countNumGo = trs:Find("num/bg").gameObject
    self._lisCountNum = UIEventListener.Get(self._countNumGo)
    self._lisCountNum.onClick = UIEventListener.VoidDelegate(self.OnCountNumClick, self)

    --cost
    self._costLbl = trs:Find("cost/label"):GetComponent("UILabel")
    self._costIcon = trs:Find("cost/costicon"):GetComponent("UISprite")
    self._costNum = trs:Find("cost/costnum"):GetComponent("UILabel")

    --have
    self._haveIcon = trs:Find("have/haveicon"):GetComponent("UISprite")
    self._haveNum = trs:Find("have/havenum"):GetComponent("UILabel")
    self._exchangeGo = trs:Find("have/exchange").gameObject
    self._lisExchange = UIEventListener.Get(self._exchangeGo)
    self._lisExchange.onClick = UIEventListener.VoidDelegate(self.OnExchangeClick, self)

    --buy
    self._buyLbl = trs:Find("buybtn/label"):GetComponent("UILabel")
    self._buyGo = trs:Find("buybtn").gameObject
    self._lisBuy = UIEventListener.Get(self._buyGo)
    self._lisBuy.onClick = UIEventListener.VoidDelegate(self.OnBuySellClick, self)

    --ime
    self._funcOnNumClick = function(num)
        self:OnNumClick(num)
    end
    self._funcOnBackClick = function()
        self:OnBackClick()
    end
    self._funcOnOKClick = function()
        self:OnOKClick()
    end
    self._funcOnIMEAutoIdRollback = function()
        self:ResetIMEAutoId()
    end
    self._imeTrs = trs:Find("ime")
    self._imeItem = IMEItem.new(self._imeTrs, self._funcOnNumClick, self._funcOnBackClick, self._funcOnOKClick, self._funcOnIMEAutoIdRollback)

    --变量
    --该self._data隶属于哪个widget，1buy，2sell
    self._buyOrSell = -1
    self._data = nil
    self._events = {}
    --当前选择的数量
    self._curCount = 0
    self._enoughColor = Color(139 / 255, 86 / 255, 52 / 255, 1)
    self._notEnoughColorForBuy = Color(1, 0, 0, 1)
    self._notEnoughColorForSell = self._enoughColor
    --商会默认货币item
    self._commerceCoinItemData = CommerceMgr.GetCommerceCoinItemData()
    self._imeAutoId = -1
    --ime当前的输入字符串
    self._imeInputStr = ""
    --当前货币是否充足
    self._coinEnough = false
    self._costLblBuy = WordData.GetWordStringByKey("Shop_buyinfo_show_4")
    self._costLblSell = "售价："
    self._buyLblBuy = WordData.GetWordStringByKey("Shop_buyinfo_show_5")
    self._buyLblSell = "出售"
end

--重置该id意味着，下次的输入会清空旧字符串
function RightItem:ResetIMEAutoId()
    self._imeAutoId = -1
end

function RightItem:DoParseInputStr(inputStr)
    if not self._data then
        return
    end
    local num = tonumber(inputStr)
    self:UpdateCurCountWrap(num, true, true)
end

function RightItem:OnNumClick(numId)
    if self._imeAutoId == self._imeItem:GetAutoId() then
        self._imeInputStr = self._imeInputStr .. tostring(numId)
    else
        self._imeAutoId = self._imeItem:GetAutoId()
        if numId == 0 then
            self._imeInputStr = "1"
            self:ResetIMEAutoId()
        else
            self._imeInputStr = tostring(numId)
        end
    end

    self:DoParseInputStr(self._imeInputStr)
end

function RightItem:OnBackClick()
    if self._imeAutoId == self._imeItem:GetAutoId() then
        if string.len(self._imeInputStr) > 1 then
            self._imeInputStr = string.sub(self._imeInputStr, 1, -2)
        else
            self._imeInputStr = "1"
            self:ResetIMEAutoId()
        end
    else
        self._imeAutoId = self._imeItem:GetAutoId()
        self._imeInputStr = "1"
        self:ResetIMEAutoId()
    end

    self:DoParseInputStr(self._imeInputStr)
end

function RightItem:OnOKClick()
    self._imeItem:Hide()
end

function RightItem:CheckIMECanShow()
    local canShow = false

    --当前剩余数量为0时，不显示
    if self._buyOrSell == 1 then
        if self._data.info.isLimitBuyCount then
            local leftBuyCount = CommerceMgr.GetLeftBuyCountByData(self._data)
            canShow = leftBuyCount > 0
        else
            canShow = true
        end
    elseif self._buyOrSell == 2 then
        if self._data.info.isLimitSellCount then
            local leftSellCount = CommerceMgr.GetLeftSellCountByData(self._data)
            canShow = leftSellCount > 0
        else
            canShow = true
        end
    end

    return canShow
end

function RightItem:OnCountNumClick(eventData)
    if not self._data then
        return
    end

    if self._imeItem:IsShowed() then
        return
    else
        if self:CheckIMECanShow() then
            self._imeItem:Show()
        end
    end
end

--点击屏幕监听
function RightItem:OnPressScreen(go, state)
    if go == self._countNumGo then
        return
    end
    if self._imeItem:CheckPressInIME(go) then
        return
    end
    if state then
        if self._imeItem:IsShowed() then
            self._imeItem:Hide()
        end
    end
end

--根据self._curCount和真实价格计算出总花费
function RightItem:GetCostNum()
    local costNum = 0
    if self._data then
        local realPrice = CommerceMgr.GetRealPrice(self._data.tableData, self._buyOrSell)
        costNum = self._curCount * realPrice
    end
    return costNum
end

--根据当前costNum和haveNum修改costNum文本颜色
function RightItem:SetCostNumColor(enough)
    if enough then
        self._costNum.color = self._enoughColor
    else
        if self._buyOrSell == 1 then
            self._costNum.color = self._notEnoughColorForBuy
        elseif self._buyOrSell == 2 then
            self._costNum.color = self._notEnoughColorForSell
        end
    end
end

--检查货币是否充足
function RightItem:CheckCoinEnouth(costNum, haveNum)
    self._coinEnough = costNum <= haveNum

    self:SetCostNumColor(self._coinEnough)
end

--更新self._curCount字段，并刷新costNum
--更改self._curCount唯一入口
function RightItem:UpdateCurCount(curCount)
    self._curCount = curCount
    self._countNum.text = tostring(self._curCount)
    self._imeInputStr = tostring(self._curCount)

    self:UpdateCostNum()
end

--更新当前显示数量的通用接口
--isClamp：是否调整curCount到[1, leftBuyCount/leftsellcount]区间内，leftBuyCount/leftsellcount可能为0
--isTips：超出最大数量是否给提示
function RightItem:UpdateCurCountWrap(curCount, isClamp, isTips)
    if isClamp then
        if curCount < 1 then
            curCount = 1
        elseif curCount > 999 then
            curCount = 999
        end
        if self._buyOrSell == 1 then
            if self._data.info.isLimitBuyCount then
                local leftBuyCount = CommerceMgr.GetLeftBuyCountByData(self._data)
                if curCount > leftBuyCount then
                    curCount = leftBuyCount
                    if isTips then
                        TipsMgr.TipByFormat(WordData.GetWordStringByKey("Shop_count_exRange"))
                    end
                end
            else
                --不限购买次数
            end
        elseif self._buyOrSell == 2 then
            if self._data.info.isLimitSellCount then
                local leftSellCount = CommerceMgr.GetLeftSellCountByData(self._data)
                local itemCount = CommerceMgr.GetItemCountByGoodsId(self._data.tableData.id)
                if leftSellCount <= itemCount then
                    if curCount > leftSellCount then
                        curCount = leftSellCount
                        if isTips then
                            TipsMgr.TipByFormat(WordData.GetWordStringByKey("Shop_count_exLimit"))
                        end
                    end
                else
                    if curCount > itemCount then
                        curCount = itemCount
                        if isTips then
                            TipsMgr.TipByFormat(WordData.GetWordStringByKey("Shop_count_exhold"))
                        end
                    end
                end
            else
               --不限制出售次数 
            end
        end
    end

    self:UpdateCurCount(curCount)
end

--更新costnum，并检查是否足够,并修改文本颜色
function RightItem:UpdateCostNum()
    local costNum = self:GetCostNum()
    self._costNum.text = string.NumberFormat(costNum, 0) --tostring(costNum)

    --更新其文本颜色状态
    if self._data then
        local haveNum = CommerceMgr.GetHaveNum(self._data.moneyItemData.childType)
        self:CheckCoinEnouth(costNum, haveNum)
    else
        self:CheckCoinEnouth(0, 1)
    end
end

--更新拥有货币数量
function RightItem:UpdateHaveNum()
    local haveNum = 0
    if self._data then
        haveNum = CommerceMgr.GetHaveNum(self._data.moneyItemData.childType)
    else
        haveNum = CommerceMgr.GetHaveNum(self._commerceCoinItemData.childType)
    end
    self._haveNum.text =  string.NumberFormat(haveNum, 0)--tostring(haveNum)
end

--货币更新
function RightItem:OnCoinUpdate()
    self:UpdateHaveNum()

    --刷新costnum状态
    self:UpdateCostNum()
end

function RightItem:RegEvent()
    if #self._events > 0 then
        return
    end
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_GETCOIN, self.OnCoinUpdate, self)
    TouchMgr.SetListenOnNGUIEvent(self, true, true)
end

function RightItem:UnRegEvent()
    if #self._events == 0 then
        return
    end
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_GETCOIN, self.OnCoinUpdate, self)
    TouchMgr.SetListenOnNGUIEvent(self, false, true)
    self._events = {}
end

--根据self._buyOrSell修改文本显示
function RightItem:InitLabel()
    if self._buyOrSell == 1 then
        self._costLbl.text = self._costLblBuy
        self._buyLbl.text = self._buyLblBuy
    elseif self._buyOrSell == 2 then
        self._costLbl.text = self._costLblSell
        self._buyLbl.text = self._buyLblSell
    else
        self._costLbl.text = ""
        self._buyLbl.text = ""
    end
end

--一种固定显示的待机状态
function RightItem:DoShowNil()
    self._itemShowItem:Show(nil, self._buyOrSell)
    self:UpdateCurCountWrap(0, false, false)
    self:UpdateHaveNum()

    self._costIcon.spriteName = self._commerceCoinItemData.icon_big
    self._haveIcon.spriteName = self._commerceCoinItemData.icon_big

    if self._buyOrSell == 1 then
        CommerceMgr.SetLastGoodsId(-1)
    end
end

--根据data显示
--isSameGoodsId：是否是相同的商品id
function RightItem:DoShowData(isSameGoodsId)
    if not self._data then
        self:DoShowNil()
        return
    end
    
    if isSameGoodsId then
        if self._buyOrSell == 1 then
            --相同的商品id，则只自增数量，不再刷新显示
            self:OnAddClick()
        end
    else
        self._itemShowItem:Show(self._data, self._buyOrSell)
        self:UpdateCurCountWrap(1, true, false)
        self:UpdateHaveNum()
    
        self._costIcon.spriteName = self._data.moneyItemData.icon_big
        self._haveIcon.spriteName = self._data.moneyItemData.icon_big
    
        if self._buyOrSell == 1 then
            CommerceMgr.SetLastGoodsId(self._data.tableData.id)
        end
    end
end

--购买返回刷新
function RightItem:IsOnBuyShow()
    if not self._data then
        self:DoShowNil()
        return
    end

    self._itemShowItem:Show(self._data, self._buyOrSell)
    self:UpdateCurCountWrap(self._curCount, true, false)
    self:UpdateHaveNum()

    self._costIcon.spriteName = self._data.moneyItemData.icon_big
    self._haveIcon.spriteName = self._data.moneyItemData.icon_big
end

--根据一个MiddleItemData数据显示
function RightItem:Show(data, buyOrSell)
    self._gameObject:SetActive(true)
    self:RegEvent()

    self._buyOrSell = buyOrSell
    self:InitLabel()

    local isSameGoodsId = self._data and data and self._data.tableData.id == data.tableData.id
    self._data = data

    self._imeItem:Hide()

    if self._data then
        self:DoShowData(isSameGoodsId)
    else
        --data为nil时，为特殊待机状态
        self:DoShowNil()
    end
end

--购买成功后刷新方法，同一个商品id，该方法不改变self._buyOrSell
function RightItem:UpdateOnBuy(data)
    --待实现
    --检测新的data和旧的data是否商品id一致，不一致给个报错log
    self._data = data

    self:IsOnBuyShow()
end

--出售成功后刷新方法，同一个商品id，该方法不改变self._buyOrSell
function RightItem:UpdateOnSell(data)
    self._data = data

    self:DoShowData(false)
end

function RightItem:Hide()
    self:UnRegEvent()
    self._itemShowItem:Hide()
    self._data = nil
    self._buyOrSell = -1
    self._curCount = 0
    self._coinEnough = false
end

--减号按钮点击
function RightItem:OnReduceClick(eventData)
    if not self._data then
        return
    end
    self:UpdateCurCountWrap(self._curCount - 1, true, false)
end

--加号按钮点击
function RightItem:OnAddClick(eventData)
    if not self._data then
        return
    end

    if self._buyOrSell == 1 then
        self:UpdateCurCountWrap(self._curCount + 1, true, false)
    elseif self._buyOrSell == 2 then
        self:UpdateCurCountWrap(self._curCount + 1, true, true)
    end
end

--兑换按钮点击
function RightItem:OnExchangeClick(eventData)
    --先不做
    TipsMgr.TipByFormat("先不做，后期走统一的兑换充值流程")
end

--检测是否满足提示条件
function RightItem:CheckMeet()
    local isMeet = true
    --过滤提示，职业不符或性别不符给提示，但还可以买
    local selfRacil = UserData.GetRacial()
    local selfProf = UserData.GetProfession()
    local selfIsMale = UserData.IsMale()
    local racilMeet = true
    local profMeet = true
    local sexMeet = true

    if self._data.tableData.sex ~= 0 then
        if selfIsMale then
            sexMeet = self._data.tableData.sex == 2
        else
            sexMeet = self._data.tableData.sex == 1
        end
    end
    if self._data.tableData.racial ~= 0 then
        racilMeet = self._data.tableData.racial == selfRacil
    end
    if self._data.tableData.profession ~= 0 then
        profMeet = self._data.tableData.profession == selfProf
    end

    isMeet = racilMeet and profMeet and sexMeet

    return isMeet
end

function RightItem:CheckNeedBuyOutTips()
    local needTips = false

    if self._data.info.isLimitBuyCount then
        --售空提前提示，不管货币是否充足，不管是否能穿
        local leftBuyCount = CommerceMgr.GetLeftBuyCountByData(self._data)
        needTips = leftBuyCount < 1
    end

    return needTips
end

function RightItem:Buy()
    if self:CheckNeedBuyOutTips() then
        TipsMgr.TipByFormat(WordData.GetWordStringByKey("Shop_buyinfo_show_6"))
        return
    end
    --货币不足时，购买弹不足提示，以后走兑换充值统一流程
    if self._coinEnough then
        if self:CheckMeet() then
            CommerceMgr.SendBuy(self._data.tableData.id, self._curCount)
        else
            --弹出确认框
            local str = WordData.GetWordStringByKey("Shop_cue_unavailable")
            local okFunc = function()
                CommerceMgr.SendBuy(self._data.tableData.id, self._curCount)
            end
            TipsMgr.TipConfirmByStr(str, okFunc)
        end
    else
        TipsMgr.TipByFormat("货币不足，以后做统一兑换流程")
    end
end

function RightItem:Sell()
    CommerceMgr.SendSell(self._data.itemData.id, self._curCount)
end

--购买按钮点击
function RightItem:OnBuySellClick(eventData)
    if not self._data then
        return
    end
    if self._buyOrSell == 1 then
        self:Buy()
    elseif self._buyOrSell == 2 then
        self:Sell()
    end
end

return RightItem
------------------------------------RightItem------------------------------------