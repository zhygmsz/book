

--CommonTipItem
local CommonTipItem = class("CommonTipItem")
function CommonTipItem:ctor(ui, path, finishFuncOnHide)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._bg = ui:FindComponent("UISprite", path .. "bg")
	self._icon = ui:FindComponent("UISprite", path .. "icon")
	self._icongo = self._icon.gameObject
	self._iconbg = ui:FindComponent("UISprite", path .. "icon/iconbg")
	self._content = ui:FindComponent("UILabel", path .. "content")
	self._contentTrs = self._content.transform
	self._finishFuncOnHide = finishFuncOnHide
	
	--变量
	self._data = {}
	self._isShowed = false
	self._contentPosForItem = Vector3(25, 0, 0)
	self._contentPos = Vector3.zero
	self._timerIdx = nil
	self._duration = 1.3
	self._curPos = Vector3.zero
	
	self:Hide()
end

function CommonTipItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function CommonTipItem:Show(content, itemData)
	self:Reset()
	
    self._data = {content = content, itemData = itemData}
    self:SetVisible(true)
	
	self._content.text = self._data.content
	if self._data.itemData then
		self._icongo:SetActive(true)
		--UIUtil.SetTexture(self._data.itemData.icon_big, self._icon)
		self._icon.spriteName = self._data.itemData.icon_big
		self._iconbg.spriteName = UIUtil.GetItemQualityBgSpName(self._data.itemData.quality)
		
		self._contentTrs.localPosition = self._contentPosForItem
	else
		self._icongo:SetActive(false)
		
		self._contentTrs.localPosition = self._contentPos
	end
	
	GameTimer.AddTimer(self._duration, 1, self.OnShowFinish, self)
end

function CommonTipItem:OnShowFinish()
	self._timerIdx = nil
	
	self:Hide()
	
	if self._finishFuncOnHide then
		self._finishFuncOnHide()
	end
end

function CommonTipItem:Hide()
    self:Reset()
    self:SetVisible(false)
end

function CommonTipItem:IsShowed()
	return self._isShowed
end

function CommonTipItem:SetPosY(posY)
	self._curPos.y = posY
	self._transform.localPosition = self._curPos
end

function CommonTipItem:GetPosY()
	return self._transform.localPosition.y
end

function CommonTipItem:Reset()
	if self._timerIdx then
		GameTimer.DeleteTimer(self._timerIdx)
		self._timerIdx = nil
	end
	
	self:ResetPos()
end

function CommonTipItem:ResetPos()
	self:SetPosY(0)
end

--CommonTipWidget
local CommonTipWidget = class("CommonTipWidget")
function CommonTipWidget:ctor(ui, path)
    --组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)
	
	self._ui = ui
	path = path .. "/"
	self._path = path

	self._offset = ui:Find(path .. "offset")
	self._itemTemp = ui:Find(path .. "offset/commontip/item")
	self._itemTemp.gameObject:SetActive(false)
    self._finishFunc = function()
        self:OnFinish()
    end
	
	--变量
	self._isShowed = false
	self._baseDistance = 75
	self._duration = 0.35
	self._offsetDistance = 55
	self._curDistance = 0
	self._maxDistance = 0
	self._fixedStep = Time.fixedDeltaTime
	if not self._fixedStep or self._fixedStep == 0 then
		self._fixedStep = 0.02
	end
	self._offsetDisPerFrame = self._baseDistance * self._fixedStep * 1 / self._duration
	self._curPos = Vector3.zero
	self._MaxItemNum = 3
	self._allItems = {}
	self._showingItems = {}
	self._waitItems = {}
	
	self:Init()
	self:Hide()
end

function CommonTipWidget:Init()
	local trs = nil
	local childPath = nil
	for idx = 1, self._MaxItemNum do
		trs = self._ui:DuplicateAndAdd(self._itemTemp, self._transform, 0)
		trs.name = "item" .. tostring(idx)
		childPath = string.format("%s%s%s", self._path, "item", tostring(idx))
		self._allItems[idx] = CommonTipItem.new(self._ui, childPath, self._finishFunc)
	end
end

--滚屏
function CommonTipWidget:OnUpdate()
	if self._curDistance <= self._maxDistance then
		self._curDistance = self._curDistance + self._offsetDisPerFrame
		self:SetPosY(self._curDistance)
	end
end

function CommonTipWidget:StartUpdate()
	UpdateBeat:Add(self.OnUpdate, self)
end

function CommonTipWidget:StopUpdate()
	UpdateBeat:Remove(self.OnUpdate, self)
end

function CommonTipWidget:GetUnShowedIdx()
	local item = nil
	for idx = 1, self._MaxItemNum do
		item = self._allItems[idx]
		if item and not item:IsShowed() then
			return idx
		end
	end
	return - 1
end

function CommonTipWidget:GetItem()
	local idx = self:GetUnShowedIdx()
	if idx == - 1 then
		return nil
	end
	if 1 <= idx and idx <= self._MaxItemNum then
		return self._allItems[idx]
	end
end

function CommonTipWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function CommonTipWidget:Show(content, itemData)
	if not self:IsShowed() then
        self:Reset()
        self:SetVisible(true)
		self:StartUpdate()
	end
	
	if #self._showingItems < self._MaxItemNum then
		self:DoShow(content, itemData)
	else
		--放入等待队列
		table.insert(self._waitItems, {content = content, itemData = itemData})
	end
end

function CommonTipWidget:DoShow(content, itemData)
	local item = self:GetItem()
	if item then
		item:Show(content, itemData)
		--设置位置
		if #self._showingItems == 0 then
			--新位置
			item:SetPosY(0)
			self:SetPosY(0)
			self:InitDistance()
		else
			--增量位置
			local lastItem = self._showingItems[#self._showingItems]
			local lastItemPosY = lastItem:GetPosY()
			item:SetPosY(lastItemPosY - self._offsetDistance)
			self:AddMaxDistance(self._offsetDistance)
		end
		table.insert(self._showingItems, item)
	end
end

function CommonTipWidget:OnFinish()
	if #self._showingItems > 0 then
		table.remove(self._showingItems, 1)
	end
	if #self._waitItems > 0 then
		local data = table.remove(self._waitItems, 1)
		self:DoShow(data.content, data.itemData)
	else
		if #self._showingItems == 0 then
			self:Hide()
		end
	end
end

function CommonTipWidget:HideAllItem()
	local item = nil
	for idx = 1, self._MaxItemNum do
		item = self._allItems[idx]
		if item and item:IsShowed() then
			item:Hide()
		end
	end
end

function CommonTipWidget:ResetAllItemPos()
	local item = nil
	for idx = 1, self._MaxItemNum do
		item = self._allItems[idx]
		if item then
			item:ResetPos()
		end
	end
end

function CommonTipWidget:Reset()
	self:StopUpdate()
	self:ResetPos()
	self._curDistance = 0
	self._maxDistance = 0
end

function CommonTipWidget:ResetPos()
	self:ResetAllItemPos()
	self:SetPosY(0)
end

function CommonTipWidget:SetPosY(posY)
	self._curPos.y = posY
	self._transform.localPosition = self._curPos
end

function CommonTipWidget:InitDistance()
	self._curDistance = 0
	self._maxDistance = self._baseDistance
end

function CommonTipWidget:AddMaxDistance(dis)
	self._maxDistance = self._maxDistance + dis
end

function CommonTipWidget:Hide()
    self:HideAllItem()
    self:Reset()
    self:SetVisible(false)

end

function CommonTipWidget:IsShowed()
	return self._isShowed
end

return CommonTipWidget