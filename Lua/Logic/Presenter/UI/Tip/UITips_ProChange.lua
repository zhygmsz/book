
--ProChangeItem
local ProChangeItem = class("ProChangeItem")
function ProChangeItem:ctor(ui, path)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._proname = ui:FindComponent("UILabel", path .. "proname")
	self._value = ui:FindComponent("UILabel", path .. "value")
	self._arrowGreenGo = ui:FindGo(path .. "arrowgreen")
	self._arrowRedGo = ui:FindGo(path .. "arrowred")
	
	--变量
	self._colorup = "[00ff00]"
	self._colordown = "[ff0000]"
	self._colorbai = Color.New(1, 1, 1, 1)
	self._isShowed = false
	
	self:Hide()
end


function ProChangeItem:Show(change)
	self._gameObject:SetActive(true)
	self._isShowed = true
	
	if change then
		self._proname.text = change.data.name
        self._value.color = self._colorbai
		local finalValue = AttrCalculator.CalculPropertyUI(change.deltaValue, change.data.showType, change.data.showLength)
		if change.deltaValue > 0 then
			self._value.text = self._colorup .. "+" .. finalValue .. "[-]"
			self._arrowGreenGo:SetActive(true)
			self._arrowRedGo:SetActive(false)
		else
			self._value.text = self._colordown .. finalValue .. "[-]"
			self._arrowRedGo:SetActive(true)
			self._arrowGreenGo:SetActive(false)
		end
	else
		self:Hide()
	end
end

function ProChangeItem:Hide()
	self._gameObject:SetActive(false)
	self._isShowed = false
end

function ProChangeItem:IsShowed()
	return self._isShowed
end

--ProChangeWidget
local ProChangeWidget = class("ProChangeWidget")
function ProChangeWidget:ctor(ui, path)
    --组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._tableTrs = ui:Find(path .. "offset/prochange/table")
	self._itemTemp = ui:Find(path .. "offset/prochange/item")
	self._itemTemp.gameObject:SetActive(false)
	self._table = self._tableTrs:GetComponent("UITable")
	self._tweenPos = ui:FindComponent("TweenPosition", path .. "offset/prochange")
	self._tweenAlpha = ui:FindComponent("TweenAlpha", path .. "offset/prochange")
	self._finishFuncOnTp = EventDelegate.Callback(self.OnTpFinish, self)
	EventDelegate.Set(self._tweenPos.onFinished, self._finishFuncOnTp)
	self._tweenPos.enabled = false
	self._tweenPos.enabled = false
	
	--变量
	self._MaxItemNum = 10
	self._allItems = {}
	self._timerIdx = nil
	self._isShowed = false
	self._showDelay = 2
	self._fromPos = self._transform.localPosition
	self._upOffset = 80
	self._toPos = Vector3(self._fromPos.x, self._fromPos.y + self._upOffset, self._fromPos.z)
	self._fromAlpha = 1
	self._toAlpha = 0.2
	self._duration = 0.6
	
	self:Init()
	self:Hide()
end

function ProChangeWidget:Init()
	--预先生成_MaxItemNum个，如果之后一次性属性提示超过_MaxItemNum个，则动态生成新的补充
	local trs = nil
	local childPath = nil
	for idx = 1, self._MaxItemNum do
		trs = self._ui:DuplicateAndAdd(self._itemTemp, self._tableTrs, 0)
		trs.name = "item" .. tostring(idx)
		childPath = string.format("%s%s%s", self._path, "offset/prochange/table/item", tostring(idx))
		self._allItems[idx] = ProChangeItem.new(self._ui, childPath)
	end
end

function ProChangeWidget:GetUnshowedIdx()
	local item = nil
	for idx = 1, self._MaxItemNum do
		item = self._allItems[idx]
		if item and not item:IsShowed() then
			return idx
		end
	end
	return - 1
end

function ProChangeWidget:Create()
	local trs = self._ui:DuplicateAndAdd(self._itemTemp, self._tableTrs, 0)
	self._MaxItemNum = self._MaxItemNum + 1
	trs.name = "item" .. tostring(self._MaxItemNum)
	local childPath = string.format("%s%s%s", self._path, "offset/prochange/table/item", tostring(self._MaxItemNum))
	self._allItems[self._MaxItemNum] = ProChangeItem.new(self._ui, childPath)
	return self._MaxItemNum
end

function ProChangeWidget:GetItem()
	local idx = self:GetUnshowedIdx()
	if idx == - 1 then
		idx = self:Create()
	end
	if 1 <= idx and idx <= self._MaxItemNum then
		return self._allItems[idx]
	end
end

function ProChangeWidget:Reset()
	if self._timerIdx then
		GameTimer.DeleteTimer(self._timerIdx)
		self._timerIdx = nil
	end
	self._tweenPos.enabled = false
	self._tweenAlpha.enabled = false
	self._tweenPos:ResetToBeginning()
	self._tweenAlpha:ResetToBeginning()
	self._transform.localPosition = self._fromPos
	self:HideAllItem()
end

function ProChangeWidget:Show(changes)
	self:Reset()
	self._gameObject:SetActive(true)
	self._isShowed = true
	local item = nil
	for _, change in pairs(changes) do
		item = self:GetItem()
		if item then
			item:Show(change)
		end
	end
	self._table:Reposition()
	
	self._timerIdx = GameTimer.AddTimer(self._showDelay, 1, self.OnShowDelayEnd, self)
end

function ProChangeWidget:OnShowDelayEnd()
	self._timerIdx = nil
	self:PlayAni()
end

function ProChangeWidget:PlayAni()
	self._tweenPos.enabled = true
	self._tweenPos.from = self._fromPos
	self._tweenPos.to = self._toPos
	self._tweenPos.duration = self._duration
	self._tweenPos:ResetToBeginning()
	self._tweenPos:PlayForward()
	
	self._tweenAlpha.enabled = true
	self._tweenAlpha.from = self._fromAlpha
	self._tweenAlpha.to = self._toAlpha
	self._tweenAlpha.duration = self._duration
	self._tweenAlpha:ResetToBeginning()
	self._tweenAlpha:PlayForward()
end

function ProChangeWidget:OnTpFinish()
	self:Hide()
end

function ProChangeWidget:HideAllItem()
	local item = nil
	for idx = 1, self._MaxItemNum do
		item = self._allItems[idx]
		if item and item:IsShowed() then
			item:Hide()
		end
	end
end

function ProChangeWidget:Hide()
	self:Reset()
	self._gameObject:SetActive(false)
	self._isShowed = false
end

function ProChangeWidget:IsShowed()
	return self._isShowed
end

return ProChangeWidget