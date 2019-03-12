local SevenDayLoginMiddleItem = class("SevenDayLoginMiddleItem")
local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")

function SevenDayLoginMiddleItem:ctor(ui, path)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path
	self._topspr = ui:FindComponent("UISprite",path.."topspr")
	self._bottomspr = ui:FindComponent("UISprite",path.."bottomspr")
	self._bg = ui:FindComponent("UISprite", path .. "bg")
	self._titleBg = ui:FindComponent("UISprite", path .. "titlebg")
	self._title = ui:FindComponent("UILabel", path .. "title")
	self._title.color = Color(1, 1, 1, 1)
	self._sp = ui:FindComponent("UILabel", path .. "Label")
	self._spGo = self._sp.gameObject
	self._itemParent = ui:Find(path .. "item")
	self._itemParentGo = self._itemParent.gameObject
	self._btnGo = ui:FindGo(path .. "btn")
	ui:FindComponent("UILabel",path .. "btn/label").text = WordData.GetWordStringByKey("welfare_sevenday_get1")
	self._desGo = ui:FindGo(path .. "des")
	ui:FindComponent("UILabel",path .. "des").text = WordData.GetWordStringByKey("welfare_sevenday_got")
	self._selectedGo = ui:FindGo(path .. "selected")
	self._selectedGo:SetActive(false)

	--
	self._item = GeneralItem.new(self._itemParent, nil)
	
	--变量
	self._data = {}
	self._showingEffect = false
	self._topsprName={
		[SevenDayLoginMgr.MiddleItemState.Lock] = "frame_qiri_04",
		[SevenDayLoginMgr.MiddleItemState.NoGot] = "frame_qiri_04",
		[SevenDayLoginMgr.MiddleItemState.Got] = "frame_qiri_05",
		[SevenDayLoginMgr.MiddleItemState.Wished] = "frame_qiri_04", 
	}
	self._bottomsprName={
		[SevenDayLoginMgr.MiddleItemState.Lock] = "frame_qiri_10",
		[SevenDayLoginMgr.MiddleItemState.NoGot] = "frame_qiri_10",
		[SevenDayLoginMgr.MiddleItemState.Got] = "frame_qiri_11",
		[SevenDayLoginMgr.MiddleItemState.Wished] = "frame_qiri_10", 
	}
	self._bgName = { 
		[SevenDayLoginMgr.MiddleItemState.Lock] = "frame_qiri_08",
		[SevenDayLoginMgr.MiddleItemState.NoGot] = "frame_qiri_07",
		[SevenDayLoginMgr.MiddleItemState.Got] = "frame_qiri_06",
		[SevenDayLoginMgr.MiddleItemState.Wished] = "frame_qiri_08", 
	}
	self._titleBgName = { 
		[SevenDayLoginMgr.MiddleItemState.Lock] = "frame_qiri_03",
		[SevenDayLoginMgr.MiddleItemState.NoGot] = "frame_qiri_02",
		[SevenDayLoginMgr.MiddleItemState.Got] = "frame_qiri_01",
		[SevenDayLoginMgr.MiddleItemState.Wished] = "frame_qiri_03", 
	 }
	self._titleColor = { 
		[SevenDayLoginMgr.MiddleItemState.Lock] = "[ffecab]",
		[SevenDayLoginMgr.MiddleItemState.NoGot] = "[e7c977]",
		[SevenDayLoginMgr.MiddleItemState.Got] = "[7a7a7a]",
		[SevenDayLoginMgr.MiddleItemState.Wished] = "[ffecab]", 
	 }
	
	self:Hide()
end

function SevenDayLoginMiddleItem:DoShowItem(data)
	self._itemParentGo:SetActive(true)
	if self._data and self._data.state==SevenDayLoginMgr.MiddleItemState.Got then
		self._item:ShowByItemId(self._data.tempId,nil,true,nil,true)
	else
		self._item:ShowByItemId(self._data.tempId,nil,true,nil,false)
	end
end

function SevenDayLoginMiddleItem:GetSpriteNameVariant(type,idx)
	if type == "Top" then
		return self._topsprName[idx]
	elseif type=="Title" then
		return self._titleBgName[idx]
	elseif type=="Bg" then
		return self._bgName[idx]
	elseif type=="Bottom" then
		return self._bottomsprName[idx]
	end
end


function SevenDayLoginMiddleItem:GetSpriteNameBase(type)
	if self._data and self._data.state then
		return self:GetSpriteNameVariant(type,self._data.state)
	else
		return self:GetSpriteNameVariant(type,SevenDayLoginMgr.MiddleItemState.Lock)
	end
end

function SevenDayLoginMiddleItem:SetSpriteName()
	self._topspr.spriteName = self:GetSpriteNameBase("Top")
	self._titleBg.spriteName = self:GetSpriteNameBase("Title")
	self._bg.spriteName = self:GetSpriteNameBase("Bg")
	self._bottomspr.spriteName = self:GetSpriteNameBase("Bottom")
end

function SevenDayLoginMiddleItem:SetTitle()
	local colorStr = self:GetTitleColorStr()
	self._title.text = colorStr .. SevenDayLoginMgr.GetMiddleTitleStr(self._data.dayIdx) .. "[-]"
end

function SevenDayLoginMiddleItem:GetTitleColorStr()
	if self._data and self._data.state then
		return self._titleColor[self._data.state]
	else
		return self._titleColor[SevenDayLoginMgr.MiddleItemState.Lock]
	end
end

function SevenDayLoginMiddleItem:ShowSelected()
	self._selectedGo:SetActive(true)
end

function SevenDayLoginMiddleItem:HideSelected()
	self._selectedGo:SetActive(false)
end

function SevenDayLoginMiddleItem:Show(data)
	self._data = data
	self._gameObject:SetActive(true)
	
	self:SetSpriteName()
	self:SetTitle()
	self:HideAll()
	if self._data.state == SevenDayLoginMgr.MiddleItemState.Lock then
		self._spGo:SetActive(true)
	elseif self._data.state == SevenDayLoginMgr.MiddleItemState.NoGot then
		self:DoShowItem()
		self._btnGo:SetActive(true)
	elseif self._data.state == SevenDayLoginMgr.MiddleItemState.Got then
		self:DoShowItem()
		self._desGo:SetActive(true)
	elseif self._data.state == SevenDayLoginMgr.MiddleItemState.Wished then
		self:DoShowItem()
	end
end

function SevenDayLoginMiddleItem:Hide()
	self._gameObject:SetActive(false)
	self._showingEffect = false
end

function SevenDayLoginMiddleItem:GetTransform()
	return self._itemParent
end

function SevenDayLoginMiddleItem:HideAll()
	self._spGo:SetActive(false)
	self._itemParentGo:SetActive(false)
	self._btnGo:SetActive(false)
	self._desGo:SetActive(false)
end

function SevenDayLoginMiddleItem:OnClick()
	--发送领取消息
	if not SevenDayLoginMgr.CheckHasGotItem(self._data.dayIdx) then
		SevenDayLoginMgr.SendGetAward(self._data.dayIdx)
	else
		GameLog.LogError("UI_SevenDayLogin.SevenDayLoginMiddleItem.OnClick -> CheckHasGotItem return true, dayIdx = %s", self._data.dayIdx)
	end
end

function SevenDayLoginMiddleItem:OnDisable()
	self:HideSelected()
end

function SevenDayLoginMiddleItem:ShowTips()
	BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, self._data.tempId)
end

function SevenDayLoginMiddleItem:GetScale()
	return Vector3.one
end

function SevenDayLoginMiddleItem:OnDestroy()
	self._item:OnDestroy()
end

return SevenDayLoginMiddleItem