local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")
local GemIconItem = require("Logic/Presenter/UI/Intensify/Inlay/GemIconItem")
local ContentItem = require("Logic/Presenter/UI/Shop/ContentItem")
local ContentWidget = require("Logic/Presenter/UI/Shop/ContentWidget")

local GemList = class("GemList")
function GemList:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._gemItemList = {}
    self._gemNum = 4
    local trans = nil
    for idx = 1, self._gemNum do
        trans = trs:Find("gem" .. tostring(idx))
        self._gemItemList[idx] = GemIconItem.new(trans)
    end

    --变量
    self._data = {}
end

function GemList:GetEquipGemInfo(gemPos)
    for _, equipGemInfo in ipairs(self._data.gems) do
        if equipGemInfo.gemPos == gemPos then
            return equipGemInfo
        end
    end
    return nil
end

--[[
    @desc: 按宝石槽位排序好的EquipGemInfo数组
]]
function GemList:GetEquipGemInfoList()
    local equipGemInfoList = {}

    local equipGemInfo = nil
    for idx = 1, self._gemNum do
        equipGemInfo = self:GetEquipGemInfo(idx)
        if equipGemInfo then
            table.insert(equipGemInfoList, equipGemInfo)
        end
    end

    return equipGemInfoList
end

--[[
    @desc: 
    --@data: Item_pb.EquipInfo
]]
function GemList:Show(data)
    self._data = data

    --根据装备的宝石数据，显示
    local equipGemInfoList = self:GetEquipGemInfoList()
    local gemItem = nil
    local equipGemInfo = nil
    for idx = 1, self._gemNum do
        gemItem = self._gemItemList[idx]
        equipGemInfo = equipGemInfoList[idx]
        if equipGemInfo then
            gemItem:Show(equipGemInfo.gemDataInfo.gemId)
        else
            gemItem:Hide()
        end
    end
end

function GemList:AllGemItemOnDestroy()
    for _, gemItem in ipairs(self._gemItemList) do
        if gemItem then
            gemItem:OnDestroy()
        end
    end
end

function GemList:OnDestroy()
    self:AllGemItemOnDestroy()
    self._data = {}
end

local LeftItem = class("LeftItem", ContentItem)
function LeftItem:ctor(trs, eventId)
    ContentItem.ctor(self, trs, eventId)

    --左侧装备图标
    self._itemTrs = trs:Find("item")
    self._item = GeneralItem.new(self._itemTrs, nil)

    --已装备
    self._equipedGo = trs:Find("equiped").gameObject
    self._equipedGo:SetActive(false)

    --name
    self._name = trs:Find("name"):GetComponent("UILabel")
    
    --gemlist
    self._gemListTrs = trs:Find("gem")
    self._gemList = GemList.new(self._gemListTrs)

    --变量

end

function LeftItem:Show(data, selectedRealIdx)
    ContentItem.Show(self, data, selectedRealIdx)

    self._item:ShowByItemData(self._data.itemData)
    self._item:ShowBg(self._data.itemData.quality)

    self._name.text = self._data.itemData.name
    --显示gemlist
    self._gemList:Show(self._data.itemSlot.item.equipInfo)

    --
    self._equipedGo:SetActive(data.isEquiped)
end

function LeftItem:OnDestroy()
    ContentItem.OnDestroy(self)

    self._item:OnDestroy()
    self._gemList:OnDestroy()
end

local LeftWidget = class("LeftWidget")
function LeftWidget:ctor(trs, eventIdBase, funcOnClickItem)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    --
    self._noneDesGo = trs:Find("nonedes").gameObject
    self._noneDesGo:SetActive(false)

    self._widgetTrs = trs:Find("widget")
    self._contentWidget = ContentWidget.new(self._widgetTrs, funcOnClickItem, eventIdBase, LeftItem)

    --变量
    self._isShowed = false
    --控制整个区域的刷新，选择性重置
    self._needShow = true
    self._eventIds = {}
    self._canInlayEquipList = {}

    self:SetVisible(false)
end

function LeftWidget:OnClick(eventId)
    self._contentWidget:OnClick(eventId)
end

function LeftWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

--[[
    @desc: 显示左侧区域列表
]]
function LeftWidget:Show(dataList)
    self._contentWidget:Show(dataList)
end

function LeftWidget:AutoSelectRealIdx(realIdx)
    self._contentWidget:AutoSelectRealIdx(realIdx)
end

function LeftWidget:GetCurSelectData()
    return self._contentWidget:GetCurSelectData()
end

--[[
    @desc: 数据变动同步到该list
    --@newData: 
    --@msg: 
    @return: 返回被更新的数据的数组索引
]]
function LeftWidget:UpdateCanInlayEquipList(newData, msg)
    local existIdx = nil
    for key, equipData in ipairs(self._canInlayEquipList) do
        if msg.bagType == equipData.bagType 
            and msg.slotId == equipData.itemSlot.slotId then
            --
            self._canInlayEquipList[key] = newData
            existIdx = key
            break
        end
    end
    return existIdx
end

--[[
    @desc: 
    --@data: 新数据
]]
function LeftWidget:OnSCInlayGem(data, msg)
    local realIdx = self:UpdateCanInlayEquipList(data, msg)
    if realIdx then
        self._contentWidget:UpdateItem(realIdx, data)
    end
end

--[[
    @desc: 
    --@data: 
    --@msg: 
]]
function LeftWidget:OnSCRemoveGem(data, msg)
    local realIdx = self:UpdateCanInlayEquipList(data, msg)
    if realIdx then
        self._contentWidget:UpdateItem(realIdx, data)
    end
end

function LeftWidget:RegEvent()
    
end

function LeftWidget:UnRegEvent()
    self._eventIds = {}
end

function LeftWidget:OnEnable()
    self:RegEvent()

    self:SetVisible(true)

    --严控整个区域的刷新频率
    if self._needShow then
        self._needShow = false
        
        self._canInlayEquipList = GemInlayMgr.GetCanInlayEquipList()
        self:Show(self._canInlayEquipList)
    end
end

function LeftWidget:OnDisable()
    self:UnRegEvent()
    
    self:SetVisible(false)
    self._needShow = true
end

function LeftWidget:CheckIsNone()
    return #self._canInlayEquipList == 0
end

function LeftWidget:SetNoneDesVisible(visible)
    self._noneDesGo:SetActive(visible)
end

function LeftWidget:OnDestroy()
    self._needShow = true
end

return LeftWidget