

--StoryGotTipItem+
local StoryGotTipItem = class("StoryGotTipItem")
function StoryGotTipItem:ctor(ui, path, funcOnHide, psoY)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._icon = ui:FindComponent("UITexture", path .. "icon")
	self._des = ui:FindComponent("UILabel", path .. "des")
	self._badge = ui:Find(path .. "badge")
	self._funcOnHide = funcOnHide

	--loader
	self._texLoader = LoaderMgr.CreateTextureLoader(self._icon)
	
	--变量
	self._isShowed = false
	self._pos = Vector3.zero
	self._pos.y = psoY
	self._timerIdx = nil
	self._duration = 3
	self._iconName = "icon_head_banmoying"
	
	self:Init()
	self:Hide()
end

function StoryGotTipItem:Init()
	self:InitPos()
	--self:InitIcon()
end

function StoryGotTipItem:InitIcon()
	local resID = ResConfigData.GetResConfigID(self._iconName)
	self._texLoader:Clear()
	self._texLoader:LoadObject(resID);
	self._texLoader:SetPixelPerfect(true);
end

function StoryGotTipItem:InitPos()
	self._transform.localPosition = self._pos
end

function StoryGotTipItem:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function StoryGotTipItem:Reset()
	if self._timerIdx then
		GameTimer.DeleteTimer(self._timerIdx);
		self._timerIdx = nil
	end
end

function StoryGotTipItem:Show(desContent)
	self:Reset()
	self:SetVisible(true)
	self._des.text = desContent

	self._timerIdx = GameTimer.AddTimer(self._duration, 1, self.OnShowEnd, self)
end

function StoryGotTipItem:OnShowEnd()
	self:Hide()
	if self._funcOnHide then
		self._funcOnHide()
	end
end

function StoryGotTipItem:Hide()
	self:Reset()
	self:SetVisible(false)
	--self._texLoader:Clear()
end

function StoryGotTipItem:IsShowed()
	return self._isShowed
end

function StoryGotTipItem:OnDestroy()
	if self._texLoader then
		LoaderMgr.DeleteLoader(self._texLoader)
		self._texLoader = nil
	end
end

--StoryGotTipWidget
local StoryGotTipWidget = class("StoryGotTipWidget")
function StoryGotTipWidget:ctor(ui, path)
    --组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._offset = ui:Find(path .. "offset")
	self._itemTemp = ui:Find(path .. "offset/storygottip")
	self._itemTemp.gameObject:SetActive(false)
	self._funcOnHide = function()
		self:FuncOnItemHide()
	end

	--变量
	self._isShowed = false
	self._itemList = {}
	self._MaxItemNum = 3
	self._offsetY = 150
	
	self:Init()
	self:Hide()
end

function StoryGotTipWidget:Init()
	local trs = nil
	local posY = 0
	local childPath = nil
	for idx = 1, self._MaxItemNum do
		trs = self._ui:DuplicateAndAdd(self._itemTemp, self._offset, 0)
		trs.name = "item" .. tostring(idx)
		posY = (idx - 1) * self._offsetY
		childPath = string.format("%s%s%s", self._path, "offset/item", tostring(idx))
		self._itemList[idx] = StoryGotTipItem.new(self._ui, childPath, self._funcOnHide, posY)
	end
end

function StoryGotTipWidget:GetUnshowedIdx()
	local item = nil
	for idx = 1, self._MaxItemNum do
		item = self._itemList[idx]
		if item and not item:IsShowed() then
			return idx
		end
	end
	return -1
end

function StoryGotTipWidget:Create()
	local trs = self._ui:DuplicateAndAdd(self._itemTemp, self._offset, 0)
	self._MaxItemNum = self._MaxItemNum + 1
	trs.name = "item" .. tostring(self._MaxItemNum)
	local childPath = string.format("%s%s%s", self._path, "offset/item", tostring(self._MaxItemNum))
	self._itemList[self._MaxItemNum] = StoryGotTipItem.new(self._ui, childPath)
	return self._MaxItemNum
end

function StoryGotTipWidget:GetItem()
	local idx = self:GetUnshowedIdx()
	if idx == -1 then
		idx = self:Create()
	end
	if 1 <= idx and idx <= self._MaxItemNum then
		return self._itemList[idx]
	end
end

function StoryGotTipWidget:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

function StoryGotTipWidget:GetShowedNum()
	local item = nil
	local num = 0
	for idx = 1, self._MaxItemNum do
		item = self._itemList[idx]
		if item and item:IsShowed() then
			num = num + 1
		end
	end
	return num
end

function StoryGotTipWidget:Show(content)
	if true then
		return
	end
	self:SetVisible(true)

	local item = self:GetItem()
	if item then
		item:Show(content)
	end
end

function StoryGotTipWidget:Hide()
	self:SetVisible(false)
end

function StoryGotTipWidget:FuncOnItemHide()
	local num = self:GetShowedNum()
	if num == 0 then
		self:Hide()
	end
end

return StoryGotTipWidget