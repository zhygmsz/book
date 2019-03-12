local SevenDayLoginBottomItem = class("SevenDayLoginBottomItem")
local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")

function SevenDayLoginBottomItem:ctor(ui, path)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)
	self._uiEvent = self._transform:GetComponent("UIEvent");
	self._ui = ui
	path = path .. "/"
	self._path = path

	self._itemParent = self._transform
	self._itemParentGo = self._gameObject

	--
	self._item = GeneralItem.new(self._itemParent, nil)
	
	--变量
	self._tempId = - 1
	
	self:Hide()
end

function SevenDayLoginBottomItem:DoShowItem()
	self._itemParentGo:SetActive(true)
	self._item:ShowByItemId(self._tempId,nil,true);
end

function SevenDayLoginBottomItem:Show(tempId)
	self._tempId = tempId

	self._gameObject:SetActive(true)	
	
	self:DoShowItem()
end

function SevenDayLoginBottomItem:Hide()
	self._gameObject:SetActive(false)
end

function SevenDayLoginBottomItem:OnDisable()
end

function SevenDayLoginBottomItem:ShowTips()
	BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, self._tempId)
end

function SevenDayLoginBottomItem:GetScale()
	return Vector3.one
end

function SevenDayLoginBottomItem:OnDestroy()
	self._item:OnDestroy()
end

function SevenDayLoginBottomItem:SetEventId(id)
	self._uiEvent.id = id;
end

return SevenDayLoginBottomItem