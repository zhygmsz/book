module("UI_Tip_EquipItemInfo", package.seeall)
local ItemTipsStyle = EquipMgr.ItemTipsStyle

--组件
local mTipsParent
local mTips
local mDetail
local mMainEquipTips
local mTempEquipTips
local mDetailTips
local mBg

--数据
local mData		--tips需要的数据集合

local mMainPosLeft = Vector3(-408, 323, 0)
local mMainPosRight = Vector3(34, 323, 0)
local mMainPosEquiped = Vector3(34, 323, 0)
local mMainPosDetail = Vector3(34, 323, 0)
local mTempPos = Vector3(- 360, 323, 0)
local mDetailPosLeft = Vector3(- 360, 323, 0)
local mDetailPosRight = Vector3(134, 323, 0)
local mDetailPosRightWithNoBtnList = Vector3(-10, 323, 0)

--用于分享的msgcommon包装，复用
local mMsgCommonWrap = MsgCommonWrap.new()
mMsgCommonWrap:ResetMsgCommon()
mMsgCommonWrap:ResetRoomType(Chat_pb.CHAT_ROOM_WORLD)
mMsgCommonWrap:ResetContentStyle(Chat_pb.ChatContentStyle_Common)

--tips管理类
local EquipTips = class("EquipTips", nil)
function EquipTips:ctor(trs, isMain, ui, path)
	self._transform = trs
	self._gameObject = trs.gameObject
	self._isMain = isMain

	self._ui = ui
	path = path .. "/"
	self._path = path
	
	self._tips = self._gameObject
	self._tipsBg = trs:GetComponent("UISprite")
	
	self._table = ui:FindComponent("UITable", path .. "table")
	self._area1Bg = ui:FindComponent("UISprite", path .. "table/area1/bg")
	self._itemBg = ui:FindComponent("UISprite", path .. "table/area1/Item/ItemBg")
	self._itemIcon = ui:FindComponent("UISprite", path .. "table/area1/Item/ItemIcon")
	self._name = ui:FindComponent("UILabel", path .. "table/area1/name")
	self._name.color = Color.New(1, 1, 1, 1)
	self._type = ui:FindComponent("UILabel", path .. "table/area1/type")
	self._type.color = Color.New(1, 1, 1, 1)
	self._level = ui:FindComponent("UILabel", path .. "table/area1/level")
	self._level.color = Color.New(1, 1, 1, 1)
	self._equiped = ui:FindGo(path .. "table/area1/equiped")
	self._detail = ui:FindGo(path .. "table/area1/detail")
	self._detailUIEvent = self._detail:GetComponent("GameCore.UIEvent")
	self._detailUIEvent.id = 1
	self._share = ui:FindGo(path .. "table/area1/share")
	self._shareUIEvent = self._share:GetComponent("GameCore.UIEvent")
	self._shareUIEvent.id = 2

	--widget，滑动子区域
	self._widget = ui:FindComponent("UIWidget", path .. "table/widget")
	self._tempWidget = ui:FindComponent("UIWidget", path .. "table/widget/tempwidget")
	self._widgetPanel = ui:FindComponent("UIPanel", path .. "table/widget/panel")
	self._widgetTable = ui:FindComponent("UITable", path .. "table/widget/panel/table")
	--widget区域最大高度
	self._widgetHeight = 506
	
	--基础属性
	self._area2 = ui:FindComponent("UISprite", path .. "table/widget/panel/table/area2")
	self._area2Table = ui:FindComponent("UITable", path .. "table/widget/panel/table/area2/table")
	self._attItems = {}
	self._MaxAttItemNum = 12
	local childPath = nil
	local item = nil
	for i = 1, self._MaxAttItemNum do
		item = ui:FindGo(path .. "table/widget/panel/table/area2/table/attitem" .. tostring(i))
		childPath = path .. "table/widget/panel/table/area2/table/attitem" .. tostring(i) .. "/"
		local itemBg = item:GetComponent("UIWidget")
		local label = ui:FindComponent("UILabel", childPath .. "label")
		local arrow = ui:FindComponent("UISprite", childPath .. "arrow")
		self._attItems[i] = {item = item, label = label, arrow = arrow, itemBg = itemBg}
		item:SetActive(false)
	end

	--附加属性
	self._area3 = ui:FindComponent("UISprite", path .. "table/widget/panel/table/area3")
	self._area3Go = ui:FindGo(path .. "table/widget/panel/table/area3")
	self._area3Table = ui:FindComponent("UITable", path .. "table/widget/panel/table/area3/table")
	self._addAttItems = {}
	self._MaxAddAttItemNum = 12
	local addAttChildPath = nil
	local addAttItem = nil
	for idx = 1, self._MaxAddAttItemNum do
		addAttItem = ui:FindGo(path .. "table/widget/panel/table/area3/table/attitem" .. tostring(idx))
		addAttChildPath = path .. "table/widget/panel/table/area3/table/attitem" .. tostring(idx) .. "/"
		local itemBg = addAttItem:GetComponent("UIWidget")
		local label = ui:FindComponent("UILabel", addAttChildPath .. "label")
		local arrow = ui:FindComponent("UISprite", addAttChildPath .. "arrow")
		arrow.gameObject:SetActive(false)
		self._addAttItems[idx] = {addAttItem = addAttItem, label = label, arrow = arrow, itemBg = itemBg}
		addAttItem:SetActive(false)
	end
	
	self._area4 = ui:FindComponent("UISprite", path .. "table/widget/panel/table/area4")
	self._gemAtt = ui:FindComponent("UILabel", path .. "table/widget/panel/table/area4/gematt")
	
	self._area5 = ui:FindComponent("UISprite", path .. "table/widget/panel/table/area5")
	self._forge = ui:Find(path .. "table/widget/panel/table/area5/forge")
	self._forgeDes = ui:FindComponent("UILabel", path .. "table/widget/panel/table/area5/forge/des")
	self._durable = ui:Find(path .. "table/widget/panel/table/area5/durable")
	self._durableDes = ui:FindComponent("UILabel", path .. "table/widget/panel/table/area5/durable/des")
	self._score = ui:Find(path .. "table/widget/panel/table/area5/score")
	self._scoreDes = ui:FindComponent("UILabel", path .. "table/widget/panel/table/area5/score/des")
	self._exclusive = ui:Find(path .. "table/widget/panel/table/area5/exclusive")
	self._exclusiveDes = ui:Find(path .. "table/widget/panel/table/area5/exclusive/des")
	self._freeze = ui:Find(path .. "table/widget/panel/table/area5/freeze")
	self._freezeDes = ui:Find(path .. "table/widget/panel/table/area5/freeze/des")
	
	self._area6 = ui:FindComponent("UISprite", path .. "table/widget/panel/table/area6")
	self._des = ui:FindComponent("UILabel", path .. "table/widget/panel/table/area6/des")
	
	self._leftArrow = ui:Find(path .. "leftarrow")
	self._leftArrowUIEvent = self._leftArrow:GetComponent("GameCore.UIEvent")
	self._leftArrowUIEvent.id = 3
	self._rightArrow = ui:Find(path .. "rightarrow")
	self._rightArrowUIEvent = self._rightArrow:GetComponent("GameCore.UIEvent")
	self._rightArrowUIEvent.id = 4
	
	self._btnList = ui:Find(path .. "btnlist")
	self._btnListTable = self._btnList:GetComponent("UITable")
	self._btnList = self._btnList.gameObject
	self._decompose = ui:Find(path .. "btnlist/btn1")
	self._moreUIEvent = self._decompose:GetComponent("GameCore.UIEvent")
	self._moreUIEvent.id = 11
	self._decompose = self._decompose.gameObject
	self._demount = ui:Find(path .. "btnlist/btn2")
	self._demountLbl = self._demount:Find("label"):GetComponent("UILabel")
	self._demountUIEvent = self._demount:GetComponent("GameCore.UIEvent")
	self._demountUIEvent.id = 12
	self._demount = self._demount.gameObject
	
	self:Hide()
	
	--颜色
	self._colorBaseAtt = "dddddd"
	self._colorRandAtt = "c7d43c"
	self._colorEffect = "73f9d8"

	self._colorEnableType = "[ffddad]"
	self._colorDisableType = "[ff0000]"
	self._colorEnableLevel = "[ffddad]"
	self._colorDisableLevel = "[ff0000]"
	
	self._arrowUpName = "img_common_arrow01"
	self._arrowDownName = "img_common_arrow02"

	self._widgetPanelBaseClipRegion = Vector4(202, -253, 404, 506)
end

function EquipTips:CheckType()
	local selfRacial = UserData.GetRacial()
	if self._data.itemData.useRacial <= 0 or (self._data.itemData.useRacial and self._data.itemData.useRacial == selfRacial) then
		return true
	else
		return false
	end
end

function EquipTips:CheckLevel()
	local selfLevel = UserData.GetLevel()
	return selfLevel >= self._data.itemData.useLevelDown
end

function EquipTips:Show(data)
	self._originData = data
	self._data = {}
	self._data.style = data.style
	if not self._isMain and data.equipedItemSlot then
		self._data.itemSlot = data.equipedItemSlot
	else
		self._data.itemSlot = data.itemSlot
	end
	
	self._gameObject:SetActive(true)
	
	--设置tips内容
	local itemData = ItemData.GetItemInfo(self._data.itemSlot.item.tempId)
	local equipData = ItemData.GetEquipmentInfo(self._data.itemSlot.item.tempId)
	self._data.itemData = itemData
	self._data.equipData = equipData
	local quality = itemData and itemData.quality or - 1
	self._area1Bg.color = EquipMgr.GetEquipTipsArea1Color(quality)
	self._itemBg.spriteName = UIUtil.GetItemQualityBgSpName(quality)
	--UIUtil.SetTexture(self._data.itemData.icon_big, self._itemIcon)
	self._itemIcon.spriteName =self._data.itemData.icon_big

	local qualityColor = UIUtil.GetItemQualityColorStr(quality)
	self._name.text = qualityColor .. self._data.itemData.name .. "[-]"
	if self:CheckType() then
		self._type.text = self._colorEnableType .. self._data.itemData.typedesc .. "[-]"
	else
		self._type.text = self._colorDisableType .. self._data.itemData.typedesc .. "[-]"
	end
	if self:CheckLevel() then
		self._level.text = self._colorEnableLevel .. self._data.itemData.coredesc .. "[-]"
	else
		self._level.text = self._colorDisableLevel .. self._data.itemData.coredesc .. "[-]"
	end
	
	if self._isMain then
		self._equiped:SetActive(false)
	else
		self._equiped:SetActive(true)
	end
	
	if self._isMain then
		self._detail:SetActive(true)
		self._share:SetActive(true)
		
		if self._originData.style == ItemTipsStyle.FromUseItem then
			self._leftArrow.gameObject:SetActive(false)
			self._rightArrow.gameObject:SetActive(false)			
		else
			self._leftArrow.gameObject:SetActive(true)
			self._rightArrow.gameObject:SetActive(true)
		end
		
		self._btnList:SetActive(true)
		if self._originData.style == ItemTipsStyle.FromBagOnEquip then
			self._decompose:SetActive(true)
		else
			self._decompose:SetActive(false)
		end

		if self._originData.style == ItemTipsStyle.FromUseItem then
			self._demount:SetActive(false)
		else
			self._demount:SetActive(true)
		end
	else
		self._detail:SetActive(false)
		self._share:SetActive(false)
		
		self._leftArrow.gameObject:SetActive(false)
		self._rightArrow.gameObject:SetActive(false)
		
		self._btnList:SetActive(false)
	end
	self._btnListTable:Reposition()
	
	--获取属性
	self:HideAllAttItem()
	self:HideAllAddAttItem()
	local attItemIdx = 0
	local equipInfo = self._data.itemSlot.item.equipInfo
	if self._originData.style == ItemTipsStyle.FromBagOnEquip and self._isMain
	and self._originData.equipedItemSlot then
		local comparedData = EquipMgr.GetComparedData(self._originData.itemSlot.item, self._originData.equipedItemSlot.item)
		for i = 1, #equipInfo.properties do
			local equipPro = equipInfo.properties[i]
			local proData = AttDefineData.GetDefineData(equipPro.id)
			local arrow = self._arrowUpName
			if comparedData[equipPro.id] < 0 then
				arrow = self._arrowDownName
			elseif comparedData[equipPro.id] == 0 then
				--属性相等
				arrow = ""
			end
			local str = string.format("[%s]%s  +%d[-]", self._colorBaseAtt, proData.name, equipPro.value)
			
			attItemIdx = attItemIdx + 1
			self._attItems[attItemIdx].item:SetActive(true)
			self._attItems[attItemIdx].itemBg.height = 28
			self._attItems[attItemIdx].label.gameObject:SetActive(true)
			self._attItems[attItemIdx].arrow.gameObject:SetActive(true)
			
			self._attItems[attItemIdx].label.text = str
			self._attItems[attItemIdx].label:Update()
			
			self._attItems[attItemIdx].arrow.spriteName = arrow
			self._attItems[attItemIdx].arrow:Update()
		end
	else
		for i = 1, #equipInfo.properties do
			local equipPro = equipInfo.properties[i]
			local proData = AttDefineData.GetDefineData(equipPro.id)
			local str = string.format("[%s]%s  +%d[-]", self._colorBaseAtt, proData.name, equipPro.value)
			
			attItemIdx = attItemIdx + 1
			self._attItems[attItemIdx].item:SetActive(true)
			self._attItems[attItemIdx].itemBg.height = 28
			self._attItems[attItemIdx].label.gameObject:SetActive(true)
			self._attItems[attItemIdx].arrow.gameObject:SetActive(true)
			
			self._attItems[attItemIdx].label.text = str
			self._attItems[attItemIdx].label:Update()
			
			self._attItems[attItemIdx].arrow.spriteName = arrow
			self._attItems[attItemIdx].arrow:Update()
		end
	end

	self._area2Table:Reposition()
	self._area2:Update()
	
	--随机属性
	local normalRandPro = {}
	local effects = {}
	for i = 1, #equipInfo.randProperties do
		local equipPro = equipInfo.randProperties[i]
		local proData = AttDefineData.GetDefineData(equipPro.id)
		if proData.showType == 3 then
			--显示类型为3的，都是特殊效果
			table.insert(effects, equipPro)
		else
			table.insert(normalRandPro, equipPro)
		end
	end

	--判断是否存在附加属性
	if #normalRandPro > 0 or #effects > 0 then
		self._area3Go:SetActive(true)
	else
		self._area3Go:SetActive(false)
	end
	
	local addAttItemIdx = 0
	if #normalRandPro > 0 then
		for i = 1, #normalRandPro do
			local equipPro = normalRandPro[i]
			local proData = AttDefineData.GetDefineData(equipPro.id)
			local str = string.format("[%s]%s  +%d[-]", self._colorRandAtt, proData.name, equipPro.value)
			addAttItemIdx = addAttItemIdx + 1
			self._addAttItems[addAttItemIdx].addAttItem:SetActive(true)
			self._addAttItems[addAttItemIdx].itemBg.height = 28
			self._addAttItems[addAttItemIdx].label.gameObject:SetActive(true)
			self._addAttItems[addAttItemIdx].label.text = str
		end
	end
	
	if #effects > 0 then
		if addAttItemIdx > 0 then
			addAttItemIdx = addAttItemIdx + 1
			self._addAttItems[addAttItemIdx].addAttItem:SetActive(true)
			self._addAttItems[addAttItemIdx].label.gameObject:SetActive(false)
			self._addAttItems[addAttItemIdx].itemBg.height = 5
		end
		
		for i = 1, #effects do
			local equipPro = effects[i]
			local proData = AttDefineData.GetDefineData(equipPro.id)
			local valueStr = AttrCalculator.CalculPropertyUI(equipPro.value, proData.showType, proData.showLength)
			local str = string.format("[%s]%s  +%s[-]", self._colorEffect, proData.name, valueStr)
			addAttItemIdx = addAttItemIdx + 1
			self._addAttItems[addAttItemIdx].addAttItem:SetActive(true)
			self._addAttItems[addAttItemIdx].itemBg.height = 28
			self._addAttItems[addAttItemIdx].label.gameObject:SetActive(true)
			self._addAttItems[addAttItemIdx].label.text = str
		end
	end

	self._area3Table:Reposition()
	self._area3:Update()
	
	--宝石属性
	--装备介绍
	self._des.text = itemData.clientdesc
	self._des:Update()
	self._area6:Update()
	--杂项
	if self._originData.style == ItemTipsStyle.FromUseItem then
	else
		if self._data.style == ItemTipsStyle.FromEquip then
			self._demountLbl.text = "卸 下"
		elseif self._data.style == ItemTipsStyle.FromBagOnEquip then
			self._demountLbl.text = "装 备"
		elseif self._data.style == ItemTipsStyle.FromBagOnDepot then
			self._demountLbl.text = "存入仓库"
			self._leftArrow.gameObject:SetActive(false)
			self._rightArrow.gameObject:SetActive(false)
		elseif self._data.style == ItemTipsStyle.FromDepot
		or self._data.style == ItemTipsStyle.FromTempBag then
			self._demountLbl.text = "取回背包"
			self._leftArrow.gameObject:SetActive(false)
			self._rightArrow.gameObject:SetActive(false)
		end
	end

	--处理滑动子区域
	self._widgetTable:Reposition()
	self._tempWidget:Update()
	local widgetHeight = self._tempWidget.height
	if widgetHeight > self._widgetHeight then
		widgetHeight = self._widgetHeight
	end
	self._widget.height = widgetHeight
	self._widgetPanelBaseClipRegion.y = -widgetHeight / 2
	self._widgetPanelBaseClipRegion.w = widgetHeight
	self._widgetPanel.baseClipRegion = self._widgetPanelBaseClipRegion
	
	self._table:Reposition()
	self._tipsBg:Update()
end

function EquipTips:HideAllAttItem()
	for i = 1, self._MaxAttItemNum do
		self._attItems[i].item:SetActive(false)
	end
end

function EquipTips:HideAllAddAttItem()
	for _, addAttItem in ipairs(self._addAttItems) do
		addAttItem.addAttItem:SetActive(false)
	end
end

function EquipTips:Hide()
	self._gameObject:SetActive(false)
end

function EquipTips:SetPos(pos)
	self._transform.localPosition = pos
end

--tips详情管理类
local EquipTipsDetail = class("EquipTipsDetail", nil)
function EquipTipsDetail:ctor(trs, ui, path)
	self._transform = trs
	self._gameObject = trs.gameObject
	self._isShowed = false

	self._ui = ui
	path = path .. "/"
	self._path = path
	
	self._tipsBg = trs:GetComponent("UISprite")
	self._table = ui:FindComponent("UITable", path .. "table")
	
	self._area1 = ui:FindComponent("UISprite", path .. "table/area1")
	self._baseAttRange = ui:FindComponent("UILabel", path .. "table/area1/baseattrange")
	self._area1AttTable = ui:FindComponent("UITable", path .. "table/area1/atttable")
	self._area1RangeTable = ui:FindComponent("UITable", path .. "table/area1/rangetable")
	self._MaxAttItemNum = 12
	self._attItems = {}
	local childPath = nil
	for i = 1, self._MaxAttItemNum do
		childPath = path .. "table/area1/atttable/attItem" .. tostring(i)
		local item = ui:FindGo(childPath)
		childPath = childPath .. "/"
		local itemBg = item:GetComponent("UISprite")
		local label = ui:FindComponent("UILabel", childPath .. "label")
		self._attItems[i] = {item = item, label = label, itemBg = itemBg}
		item:SetActive(false)
	end
	self._rangeItems = {}
	for i = 1, self._MaxAttItemNum do
		childPath = path .. "table/area1/rangetable/rangeItem" .. tostring(i)
		local item = ui:FindGo(childPath)
		childPath = childPath .. "/"
		local itemBg = item:GetComponent("UISprite")
		local label = ui:FindComponent("UILabel", childPath .. "label")
		self._rangeItems[i] = {item = item, label = label, itemBg = itemBg}
		item:SetActive(false)
	end
	self._area2 = ui:FindComponent("UISprite", path .. "table/area2")
	self._randomAtt = ui:FindComponent("UILabel", path .. "table/area2/randomatt")
	self._randomAttRange = ui:FindComponent("UILabel", path .. "table/area2/randomattrange")
	
	self._area3 = ui:FindComponent("UISprite", path .. "table/area3")
	self._area3Table = ui:FindComponent("UITable", path .. "table/area3/table")
	self._MaxEffectNum = 5
	self._effectItems = {}
	for i = 1, self._MaxEffectNum do
		childPath = path .. "table/area3/table/effectItem" .. tostring(i)
		local item = ui:FindGo(childPath)
		local itemBg = item:GetComponent("UISprite")
		local des = ui:FindComponent("UILabel", childPath .. "des")
		self._effectItems[i] = {item = item, itemBg = itemBg, des = des}
		item:SetActive(false)
	end
	
	self._area5 = ui:FindComponent("UISprite", path .. "table/area5")
	
	self:Hide()
	
	--颜色
	self._colorBaseAtt = "dddddd"
	self._colorRandAtt = "6bc547"
	self._colorEffect = "7ad8f4"
end

function EquipTipsDetail:HideAllAttItem()
	for i = 1, self._MaxAttItemNum do
		self._attItems[i].item:SetActive(false)
	end
end

function EquipTipsDetail:HideAllRangeItem()
	for i = 1, self._MaxAttItemNum do
		self._rangeItems[i].item:SetActive(false)
	end
end

function EquipTipsDetail:HideAllEffectItem()
	for i = 1, self._MaxEffectNum do
		self._effectItems[i].item:SetActive(false)
	end
end

function EquipTipsDetail:ShowAttItem(idx, equipPro, isRand, line)
	if line then
		self._attItems[idx].item:SetActive(true)
		self._attItems[idx].itemBg.height = 5
		self._attItems[idx].label.gameObject:SetActive(false)
	else
		local proData = AttDefineData.GetDefineData(equipPro.id)
		local color = isRand and self._colorRandAtt or self._colorBaseAtt
		local attStr = string.format("[%s]%s: %d[-]", color, proData.name, equipPro.value)
		
		self._attItems[idx].item:SetActive(true)
		self._attItems[idx].itemBg.height = 28
		self._attItems[idx].label.gameObject:SetActive(true)
		
		self._attItems[idx].label.text = attStr
		self._attItems[idx].label:Update()
	end
end

function EquipTipsDetail:ShowRangeItem(idx, equipPro, isRand, line)
	if line then
		self._rangeItems[idx].item:SetActive(true)
		self._rangeItems[idx].itemBg.height = 5
		self._rangeItems[idx].label.gameObject:SetActive(false)
	else
		local rangeData = EquipMgr.GetOneProMinMaxValue(equipPro, self._data.itemSlot.item)
		if isRand then
			rangeData = EquipMgr.GetOneRandProMinMaxValue(equipPro, self._data.itemSlot.item)
		end
		local color = isRand and self._colorRandAtt or self._colorBaseAtt
		local rangeStr = string.format("[%s]%d--%d[-]", color, rangeData.min, rangeData.max)
		
		self._rangeItems[idx].item:SetActive(true)
		self._rangeItems[idx].itemBg.height = 28
		self._rangeItems[idx].label.gameObject:SetActive(true)
		
		self._rangeItems[idx].label.text = rangeStr
		self._rangeItems[idx].label:Update()
	end
end

function EquipTipsDetail:ShowEffectItem(idx, equipPro)
	self._effectItems[idx].item:SetActive(true)
	
	local proData = AttDefineData.GetDefineData(equipPro.id)
	--equipPro.value = 1111
	local valueStr = AttrCalculator.CalculPropertyUI(equipPro.value, proData.showType, proData.showLength)
	local str = string.format("[%s]%s: +%s[-]", self._colorEffect, proData.name, valueStr)
	self._effectItems[idx].des.text = str
	self._effectItems[idx].des:Update()
	self._effectItems[idx].itemBg:Update()
end

function EquipTipsDetail:Show(data)
	self._data = data
	self._gameObject:SetActive(true)
	self._isShowed = true
	
	self:HideAllAttItem()
	self:HideAllRangeItem()
	local attRangeItemIdx = 0
	local equipInfo = self._data.itemSlot.item.equipInfo
	for i = 1, #equipInfo.properties do
		local equipPro = equipInfo.properties[i]
		attRangeItemIdx = attRangeItemIdx + 1
		self:ShowAttItem(attRangeItemIdx, equipPro, false, false)
		self:ShowRangeItem(attRangeItemIdx, equipPro, false, false)
	end
	
	--随机属性
	local normalRandPro = {}
	local effects = {}
	for i = 1, #equipInfo.randProperties do
		local equipPro = equipInfo.randProperties[i]
		local proData = AttDefineData.GetDefineData(equipPro.id)
		if proData.showType == 3 then
			table.insert(effects, equipPro)
		else
			table.insert(normalRandPro, equipPro)
		end
	end
	
	--[[	if #normalRandPro > 0 then
		attRangeItemIdx = attRangeItemIdx + 1
        self:ShowAttItem(attRangeItemIdx, nil, nil, true)
		self:ShowRangeItem(attRangeItemIdx, nil, nil, true)
		
		for i = 1, #normalRandPro do
			local equipPro = normalRandPro[i]
			attRangeItemIdx = attRangeItemIdx + 1
			self:ShowAttItem(attRangeItemIdx, equipPro, true, false)
			self:ShowRangeItem(attRangeItemIdx, equipPro, true, false)
		end
	end
    ]]
	self._area1AttTable:Reposition()
	self._area1RangeTable:Reposition()
	self._area1:Update()
	
	--处理特效区域
	self:HideAllEffectItem()
	if #effects > 0 then
		local effectItemIdx = 0
		for i = 1, #effects do
			local equipPro = effects[i]
			effectItemIdx = effectItemIdx + 1
			self:ShowEffectItem(effectItemIdx, equipPro)
		end
	end
	self._area3Table:Reposition()
	self._area3:Update()
	
	self._table:Reposition()
	self._tipsBg:Update()
end

function EquipTipsDetail:Hide()
	self._gameObject:SetActive(false)
	self._isShowed = false
end

function EquipTipsDetail:IsShowed()
	return self._isShowed
end

function EquipTipsDetail:SetPos(pos)
	self._transform.localPosition = pos
end

--local方法
local function Show()
	if not mData then
		return
	end

	if mData.style == ItemTipsStyle.FromTempBag
	or mData.style == ItemTipsStyle.FromUseItem then
		mBg:SetActive(true)
	else
		mBg:SetActive(false)
	end
	
	mMainEquipTips:Hide()
	mTempEquipTips:Hide()
	mDetailTips:Hide()
	
	if mData.style == ItemTipsStyle.FromEquip 
	or mData.style == ItemTipsStyle.FromDepot then
		mMainEquipTips:SetPos(mMainPosRight)
		mDetailTips:SetPos(mDetailPosLeft)
		mMainEquipTips:Show(mData)
	elseif mData.style == ItemTipsStyle.FromBagOnEquip
	or mData.style == ItemTipsStyle.FromBagOnDepot  
	or mData.style == ItemTipsStyle.FromTempBag then
		if mData.equipedItemSlot then
			mMainEquipTips:SetPos(mMainPosEquiped)
			mDetailTips:SetPos(mDetailPosLeft)
			mTempEquipTips:SetPos(mTempPos)
			mMainEquipTips:Show(mData)
			mTempEquipTips:Show(mData)
		else
			mMainEquipTips:SetPos(mMainPosLeft)
			mDetailTips:SetPos(mDetailPosRight)
			mMainEquipTips:Show(mData)
		end
	elseif mData.style == ItemTipsStyle.FromUseItem then
		--没有右侧功能按钮列表
		mMainEquipTips:SetPos(mMainPosLeft)
		mDetailTips:SetPos(mDetailPosRightWithNoBtnList)
		mMainEquipTips:Show(mData)
	end
end

local function OnMoveItem(data)
	
end

local function OnUseItem(data)

end

local function OnUseItemCloseBtn()
	if mData and mData.style == ItemTipsStyle.FromUseItem then
		EquipMgr.HideEquipTips()
	end
end

local function OnUIClosed(uiData)
	if uiData == AllUI.UI_Tip_UseItem then
		if mData.style == ItemTipsStyle.FromUseItem then
			EquipMgr.HideEquipTips()
		end
	end
end

--[[
    @desc: 分享
]]
local function OnClickShare()
	mMsgCommonWrap:ClearMsgLinks()
	local msgLink = mMsgCommonWrap:CreateMsgLink()
	MsgLinkHelper.FillMsgLink(Chat_pb.ChatMsgLink.ITEM, msgLink, mData.itemSlot, false)
	if mMsgCommonWrap:TryAppendMsgLink(msgLink) then
		--目前只支持发送到世界频道
		ChatMgr.RequestSendRoomMessage(Chat_pb.CHAT_ROOM_WORLD, "", Chat_pb.CHATMSG_COMMON, mMsgCommonWrap:GetMsgCommonStr())
		TipsMgr.TipByFormat("分享成功")
	else
		TipsMgr.TipByFormat("分享失败")
	end
end

local function RegEvent(self)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM, OnMoveItem)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_USE_ITEM, OnUseItem)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_USEITEM_CLOSEBTN, OnUseItemCloseBtn)
	GameEvent.Reg(EVT.COMMON, EVT.CLICKGROUD, OnUIClosed)
end

local function UnRegEvent(self)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM,OnMoveItem);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_USE_ITEM, OnUseItem);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_USEITEM_CLOSEBTN, OnUseItemCloseBtn);
	GameEvent.UnReg(EVT.COMMON, EVT.CLICKGROUD,OnUIClosed);
end

function OnCreate(self)
	mTipsParent = self:Find("Offset")
	
	mTips = self:Find("Offset/tips")
	mDetail = self:Find("Offset/detail")
	mTips.gameObject:SetActive(false)
	mDetail.gameObject:SetActive(false)
	mBg = self:FindGo("Offset/bg")
	
	local mainTrs = self:DuplicateAndAdd(mTips, mTipsParent, 0)
	mainTrs.name = "tips_main"
	mMainEquipTips = EquipTips.new(mainTrs, true, self, "Offset/tips_main")
	local tempTrs = self:DuplicateAndAdd(mTips, mTipsParent, 0)
	tempTrs.name = "tips_temp"
	mTempEquipTips = EquipTips.new(tempTrs, false, self, "Offset/tips_temp")
	local detailTrs = self:DuplicateAndAdd(mDetail, mTipsParent, 0)
	detailTrs.name = "tips_detail"
	mDetailTips = EquipTipsDetail.new(detailTrs, self, "Offset/tips_detail")
end

function OnEnable(self)
	RegEvent(self)
	Show()
end

function OnDisable(self)
	UnRegEvent(self)
end

function SetData(data)
	mData = data
end

function OnClick(go, id)
	if id == -100 then
		--空白区域
		EquipMgr.HideEquipTips()
	elseif id == - 10 then
		
	elseif id == 1 then
		--详情
		if mDetailTips:IsShowed() then
			mDetailTips:Hide()
			if mData.equipedItemSlot then
				mTempEquipTips:Show(mData)
			end
		else
			if mData.equipedItemSlot then
				mTempEquipTips:Hide()
			end
			mDetailTips:Show(mData)
		end
	elseif id == 2 then
		--分享
		TipsMgr.TipByKey("equip_share_not_support")
		--OnClickShare()
	elseif id == 3 then
		--向左
		if mData.style == ItemTipsStyle.FromEquip then
			UI_Bag_Equip.OnLeftOnEquipTips()
		elseif mData.style == ItemTipsStyle.FromBagOnEquip then
			--背包里的
			UI_Bag_Package.OnLeftOnEquipTips()
		end
	elseif id == 4 then
		--向右
		if mData.style == ItemTipsStyle.FromEquip then
			UI_Bag_Equip.OnRightOnEquipTips()
		elseif mData.style == ItemTipsStyle.FromBagOnEquip then
			--背包里的
			UI_Bag_Package.OnRightOnEquipTips()
		end
	elseif id == 11 then
		--分解
		BagMgr.RequestDecomposeBagItem(Bag_pb.NORMAL, mData.itemSlot.slotId, mData.itemSlot.item.id, 1)
	elseif id == 12 then
		if mData.style == ItemTipsStyle.FromEquip then
			--卸下
			BagMgr.RequestMoveBagItem(Bag_pb.EQUIP, mData.itemSlot.slotId, mData.itemSlot.item.id, Bag_pb.NORMAL, - 1)
		elseif mData.style == ItemTipsStyle.FromBagOnEquip then
			--装备
			BagMgr.RequestMoveBagItem(Bag_pb.NORMAL, mData.itemSlot.slotId, mData.itemSlot.item.id, Bag_pb.EQUIP, - 1)
		elseif mData.style == ItemTipsStyle.FromBagOnDepot then
			--存入仓库
			if UI_Bag_Main.mCurSelectR == 102 then
				BagMgr.RequestMoveBagItem(Bag_pb.NORMAL, mData.itemSlot.slotId, mData.itemSlot.item.id, UI_Bag_Storage.mCurSelectDEPOT, - 1)
			end
		elseif mData.style == ItemTipsStyle.FromDepot then
			--取回背包
			if UI_Bag_Main.mCurSelectR == 102 then
				BagMgr.RequestMoveBagItem(UI_Bag_Storage.mCurSelectDEPOT, mData.itemSlot.slotId, mData.itemSlot.item.id, Bag_pb.NORMAL, - 1)
			end
		elseif mData.style == ItemTipsStyle.FromTempBag then
			--从临时背包取回背包
			BagMgr.RequestMoveBagItem(Bag_pb.TEMP, mData.itemSlot.slotId, mData.itemSlot.item.id, Bag_pb.NORMAL, - 1)
		end
	end
end

function ShowTips()
	Show()
end
--endregion
