local GemIconItem = require("Logic/Presenter/UI/Intensify/Inlay/GemIconItem")
local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")

local GemItem = class("GemItem")
function GemItem:ctor(trs, gemPos, eventId, removeEventId)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._haveGo = trs:Find("have").gameObject
    self._gemTrs = trs:Find("have/gem")
    self._gem = GemIconItem.new(self._gemTrs)
    self._name = trs:Find("have/name"):GetComponent("UILabel")
    self._att = trs:Find("have/att"):GetComponent("UILabel")

    self._noneGo = trs:Find("none").gameObject
    self._noneDes = trs:Find("none/adddes"):GetComponent("UILabel")
    self._noneDesStr = WordData.GetWordStringByKey("gem_inlay") .. WordData.GetWordStringByKey("Shop_class1_1")
    self._noneDes.text = self._noneDesStr

    --
    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")

    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    --uievent
    self._uiEvent = trs:GetComponent("GameCore.UIEvent")
    self._removeUIEvent = trs:Find("have/remove"):GetComponent("GameCore.UIEvent")
    self._uiEvent.id = eventId
    self._removeUIEvent.id = removeEventId

    --变量
    self._isShowed = false
    self._data = {}

    self._gemPos = gemPos
    self._eventId = eventId
    self._removeEventId = removeEventId

    self._haveOrNone = -1

    self:ToNor()
    self:SetHaveOrNone(2)
end

function GemItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function GemItem:ToNor()
    if self._hasNorAndSpec then
        self._norGo:SetActive(true)
        self._specGo:SetActive(false)
    end
end

function GemItem:ToSpec()
    if self._hasNorAndSpec then
        self._specGo:SetActive(true)
        self._norGo:SetActive(false)
    end
end

function GemItem:DoShow()
    self._data.itemData = ItemData.GetItemInfo(self._data.equipGemInfo.gemDataInfo.gemId)

    --显示
    self._gem:Show(self._data.equipGemInfo.gemDataInfo.gemId)
    self._name.text = self._data.itemData.name

    --att
    local gemPro = self._data.tableData.gemProperties[1]
    if gemPro then
        local proData = AttDefineData.GetDefineData(gemPro.id)
        if proData then
            self._att.text = string.format("%s+%s", proData.name, gemPro.value)
        end
    end
end

function GemItem:SetHaveOrNone(haveOrNone)
    self._haveOrNone = haveOrNone

    self._haveGo:SetActive(haveOrNone == 1)
    self._noneGo:SetActive(haveOrNone == 2)
end

--[[
    @desc: 
    --@data: Item_pb.EquipGemInfo
]]
function GemItem:Show(data)
    self:SetVisible(true)

    if data then
        self._data.equipGemInfo = data
        self._data.tableData = GemData.GetGemDataById(data.gemDataInfo.gemId)

        self:SetHaveOrNone(1)
        self:DoShow()
    else
        self:SetHaveOrNone(2)
    end
end

function GemItem:Hide()
    self:SetVisible(false)
end

function GemItem:GetEquipGemInfo()
    return self._data.equipGemInfo
end

function GemItem:GetGemPos()
    --return self._data.equipGemInfo.gemPos
    return self._gemPos
end

function GemItem:OnDestroy()
    self._gem:OnDestroy()
    self._data = {}
    self._haveOrNone = -1
end


local GemList = class("GemList")
function GemList:ctor(trs, eventIdBase, funcOnRemoveGem)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    --
    self._funcOnRemoveGem = funcOnRemoveGem

    --
    self._eventIdBase = eventIdBase
    self._gemNum = 4
    self._gemItemList = {}
    self._eventIdDic = {}
    self._removeEventIdDic = {}

    local trans = nil
    local eventId = 0
    local removeEventId = 0
    for idx = 1, self._gemNum do
        trans = trs:Find("grid/item" .. tostring(idx))
        eventId = self._eventIdBase + idx
        removeEventId = self._eventIdBase + self._gemNum + idx
        self._gemItemList[idx] = GemItem.new(trans, idx, eventId, removeEventId)

        self._eventIdDic[eventId] = idx
        self._removeEventIdDic[removeEventId] = idx
    end

    --变量
    self._data = {}
    self._curEventId = nil
end

function GemList:GetGemItem(eventId)
    if eventId and self._eventIdDic[eventId] then
        return self._gemItemList[self._eventIdDic[eventId]]
    else
        return nil
    end
end

function GemList:ToNorGem(eventId)
    local gemItem = self:GetGemItem(eventId)
    if gemItem then
        gemItem:ToNor()
    end
end

function GemList:ToSpecGem(eventId)
    local gemItem = self:GetGemItem(eventId)
    if gemItem then
        gemItem:ToSpec()
    end
end

function GemList:OnClickGem(eventId)
    if not eventId then
        return
    end
    if self._curEventId and self._curEventId == eventId then
        return
    end
    self:ToNorGem(self._curEventId)
    self._curEventId = eventId
    self:ToSpecGem(self._curEventId)
end

function GemList:OnRemoveGem(eventId)
    if not eventId or not self._removeEventIdDic[eventId] then
        return
    end
    local gemItem = self._gemItemList[self._removeEventIdDic[eventId]]
    if not gemItem then
        return
    end
    if self._funcOnRemoveGem then
        self._funcOnRemoveGem(gemItem:GetEquipGemInfo())
    end
end

function GemList:OnClick(eventId)
    if not eventId then
        return
    end
    if self._eventIdDic[eventId] then
        self:OnClickGem(eventId)
    elseif self._removeEventIdDic[eventId] then
        self:OnRemoveGem(eventId)
    end
end

--[[
    @desc: 根据gemPos返回对应的eventid
    --@gemPos: 
]]
function GemList:GetEventIdByGemPos(gemPos)
    for eventId, v in pairs(self._eventIdDic) do
        if v == gemPos then
            return eventId
        end
    end
    return nil
end

--[[
    @desc: 默认选中规则
    --@gemPos: 1,2,3,4
]]
function GemList:AutoSelect(gemPos)
    local eventId = self:GetEventIdByGemPos(gemPos)
    if eventId then
        self:OnClickGem(eventId)
    end
end

--[[
    @desc: 返回当前选中的装备槽位
]]
function GemList:GetCurGemPos()
    local gemItem = self:GetGemItem(self._curEventId)
    if gemItem then
        return gemItem:GetGemPos()
    else
        return nil
    end
end

--[[
    @desc: 
    --@data: GemInlayMgr.GetCanInlayEquipList内数据结构
    --@isClear: 是否清空当前选中状态
]]
function GemList:Show(data, isClear)
    self._data = data

    --根据装备的宝石数据，显示
    local gemItem = nil
    local equipGemInfo = nil
    local gemCount = data.equipData.gemCount
    for idx = 1, gemCount do
        gemItem = self._gemItemList[idx]
        equipGemInfo = nil
        for _, info in ipairs(data.itemSlot.item.equipInfo.gems) do
            if info.gemPos == idx then
                equipGemInfo = info
                break
            end
        end
        gemItem:Show(equipGemInfo)
    end

    --隐藏剩余的UI格子
    for idx = gemCount + 1, self._gemNum do
        self._gemItemList[idx]:Hide()
    end

    if isClear then
        --取消选中
        self:ToNorGem(self._curEventId)
        self._curEventId = nil

        --默认选中逻辑，第一个pos
        self:AutoSelect(1)
    end
end

function GemList:OnDestroy()
    self._data = {}
end

local AttInfoItem = class("AttInfoItem")
function AttInfoItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._att = trs:GetComponent("UILabel")
    self._att.text = ""

    self._colorNor = Color(158 / 255, 103 / 255, 65 / 255, 1)
    self._colorRandom = Color(18 / 255, 176 / 255, 75 / 255, 1)
    self._colorEffect = Color(2 / 255, 126 / 255, 215 / 255, 1)

    --变量
    self._isShowed = false
    self._data = {}

    self:Hide()
end

function AttInfoItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

--[[
    @desc: 
    --@data.equipPro: Item_pb.EquipProperty
    --@data.showType: 1：基础属性，2：随机属性，3：特效
]]
function AttInfoItem:Show(data)
    self._data = data

    self:SetVisible(true)

    --显示
    local str = ""
    local proData = AttDefineData.GetDefineData(self._data.equipPro.id)
    if data.showType == 1 then
        self._att.color = self._colorNor
        str = string.format("%s  +%d", proData.name, self._data.equipPro.value)
    elseif data.showType == 2 then
        self._att.color = self._colorRandom
        str = string.format("%s  +%d", proData.name, self._data.equipPro.value)
    elseif data.showType == 3 then
        self._att.color = self._colorEffect
        local valueStr = AttrCalculator.CalculPropertyUI(self._data.equipPro.value, proData.showType, proData.showLength)
        str = string.format("%s  +%s", proData.name, valueStr)
    end
    self._att.text = str
end

function AttInfoItem:Hide()
    self:SetVisible(false)
end

function AttInfoItem:OnDestroy()
    self._data = {}
end

local EquipIntoItem = class("EquipIntoItem")
function EquipIntoItem:ctor(trs)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._itemTrs = trs:Find("title/item")
    self._item = GeneralItem.new(self._itemTrs)

    self._name = trs:Find("title/name"):GetComponent("UILabel")
    self._type = trs:Find("title/type"):GetComponent("UILabel")
    self._level = trs:Find("title/level"):GetComponent("UILabel")

    self._attItemList = {}
    self._attItemNum = 15
    local trans = nil
    for idx = 1, self._attItemNum do
        trans = trs:Find("attlist/grid/attitem" .. tostring(idx))
        self._attItemList[idx] = AttInfoItem.new(trans)
    end

    --变量
    self._isShowed = false
    self._data = {}

    self:Hide()
end

function EquipIntoItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

--[[
    @desc: 
    --@equipItem: Item_pb.EquipInfo
]]
function EquipIntoItem:GetEquipAllPro(equipInfo)
    local allProList = {}

    for _, pro in ipairs(equipInfo.properties) do
        table.insert(allProList, { showType = 1, equipPro = pro })
    end

    local randomList = {}
    local effectList = {}
    local proData = nil
    for _, pro in ipairs(equipInfo.randProperties) do
        proData = AttDefineData.GetDefineData(pro.id)
        if proData and proData.showType == 3 then
            table.insert(effectList, pro)
        else
            table.insert(randomList, pro)
        end
    end

    for _, pro in ipairs(randomList) do
        table.insert(allProList, { showType = 2, equipPro = pro })
    end
    for _, pro in ipairs(effectList) do
        table.insert(allProList, { showType = 3, equipPro = pro })
    end

    return allProList
end

--[[
    @desc: 
    --@data: GemInlayMgr.GeLeftDataList方法内
]]
function EquipIntoItem:Show(data)
    self._data = data

    self:SetVisible(true)

    --显示title
    self._item:ShowByItemData(self._data.itemData)
    self._item:ShowBg(self._data.itemData.quality)
    self._name.text = self._data.itemData.name
    self._type.text = self._data.itemData.typedesc
    self._level.text = self._data.itemData.coredesc

    --显示属性条
    local allProList = self:GetEquipAllPro(self._data.itemSlot.item.equipInfo)
    local attItem = nil
    local equipPro = nil
    for idx = 1, self._attItemNum do
        attItem = self._attItemList[idx]
        equipPro = allProList[idx]
        if attItem and equipPro then
            attItem:Show(equipPro)
        else
            attItem:Hide()
        end
    end
end

function EquipIntoItem:Hide()
    self._gameObject:SetActive(false)
end

function EquipIntoItem:OnDestroy()
    self._item:OnDestroy()
    self._data = {}
end

local MiddleWidget = class("MiddleWidget")
function MiddleWidget:ctor(trs, eventIdBase, funcOnRemoveGem)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._equipInfoTrs = trs:Find("att")
    self._equipInfoItem = EquipIntoItem.new(self._equipInfoTrs)
    self._gemListTrs = trs:Find("gemlist")
    self._gemList = GemList.new(self._gemListTrs, eventIdBase, funcOnRemoveGem)

    --变量
    self._isShowed = false
    self._data = {}
    self._eventIdBase = eventIdBase

    self:Hide()
end

function MiddleWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

--[[
    @desc: 
    --@data: GemInlayMgr.GetCanInlayEquipList内数据结构
]]
function MiddleWidget:Show(data)
    self:SetVisible(true)

    self._data = data

    --显示
    self._equipInfoItem:Show(data)
    self._gemList:Show(data, true)
end

function MiddleWidget:Hide()
    self:SetVisible(false)
end

--[[
    @desc: 
    --@data: 新数据，同步给self._data
]]
function MiddleWidget:OnSCInlayGem(data)
    self._data = data
    self._gemList:Show(self._data, false)
end

--[[
    @desc: 
    --@data: 新数据，同步给self._data
]]
function MiddleWidget:OnSCRemoveGem(data)
    self._data = data
    self._gemList:Show(self._data, false)
end

function MiddleWidget:OnEnable()
    
end

function MiddleWidget:OnDisable()
    
end

--[[
    @desc: 获取当前选中的装备槽位
]]
function MiddleWidget:GetCurGemPos()
    return self._gemList:GetCurGemPos()
end

function MiddleWidget:OnDestroy()
    self._equipInfoItem:OnDestroy()
    self._gemList:OnDestroy()
    self._data = {}
end

function MiddleWidget:OnClick(eventId)
    self._gemList:OnClick(eventId)
end

return MiddleWidget