local UI_Tip_UseItem = require("Logic/Presenter/UI/Bag/UI_Tip_UseItem")

local Bag_QuickUse = class("Bag_QuickUse",nil)

function Bag_QuickUse:ctor()
    self.dataTable = {}
    self.itemIdTable = {}
    self.mCurData = nil
    self.mLastUseData=nil
end

local using =false 

function Bag_QuickUse:OnEnable()
	self:CheckData()
end

function Bag_QuickUse:OnDisable()
end


function Bag_QuickUse:RegEvent()
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_USE_ITEM, self.OnUseItem,self);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_USE_MULITI_ITEM, self.OnMulitiUseItem,self);
	GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_MOVE_ITEM,self.OnMoveItem,self);
end

function Bag_QuickUse:UnRegEvent()
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_USE_ITEM,self.OnUseItem,self);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM,self.OnMulitiUseItem,self);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_USE_MULITI_ITEM,self.OnMoveItem,self);
end

function Bag_QuickUse:ClearUsing()
	using =false
end

function Bag_QuickUse:CheckData()
	if self.mCurData >= 1 and #self.itemIdTable >= self.mCurData then
		local mdata = self.dataTable[self.itemIdTable[self.mCurData]]
		if mdata then
			UI_Tip_UseItem.SetViewData(mdata.data)
		end
	end
end

function Bag_QuickUse:SetData(BagType, Data)
	GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_USEITEM_CLOSEBTN)
	if Data==nil then return end
	local newitem = BagMgr.CheckSuperPosotion(Data.item.tempId)
	--Data.item.tempId
	--完全新的 
	if self.dataTable[Data.item.tempId] == nil then
		self.dataTable[Data.item.tempId] ={data = Data, bagType = BagType}
		table.insert(self.itemIdTable, Data.item.tempId)
		self.mCurData = table.getn(self.itemIdTable)
	elseif newitem then--已经有相同itemid
		--可叠加物品
		self.dataTable[Data.item.tempId].data.Num = self.dataTable[Data.item.tempId].data.Num + Data.Num
		local index = 1
		for i = 1, #self.itemIdTable do
			if self.itemIdTable[i] == Data.item.tempId then
				index = i
				i = #self.itemIdTable
			end
		end
		table.remove(self.itemIdTable, index)
		table.insert(self.itemIdTable, Data.item.tempId)
		self.mCurData = table.getn(self.itemIdTable)
	elseif not newitem then--已经有相同itemid
		--不可叠加物品
		table.insert(self.itemIdTable, Data.item.tempId)
		self.mCurData = table.getn(self.itemIdTable)
		--这里的数量应该都是1 正好用以记录相同物品的个数 为零时删除这个物品
		self.dataTable[Data.item.tempId].data.Num = self.dataTable[Data.item.tempId].data.Num + Data.Num
	end
end

function Bag_QuickUse:CheckRemove(close,tempId)
	local tempDataId = self.itemIdTable[self.mCurData]
	if tempId~=nil then
		tempDataId = tempId
	end
	if self.dataTable[tempDataId]==nil then
		return
	end
	local data =self.dataTable[tempDataId].data
	if BagMgr.CheckSuperPosotion(tempDataId) then
		self.dataTable[tempDataId] = nil
		local signindex = nil
		for i,v in ipairs(self.itemIdTable) do
			if v==tempDataId then
				signindex = i
			end
		end
		table.remove(self.itemIdTable, signindex)
		UI_Tip_UseItem.DoTweenScale()
	else
		if data.itemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
			if close then 
				local signindex = nil
				for i,v in ipairs(self.itemIdTable) do
					if v==tempDataId then
						signindex = i
					end
				end
				data.Num = data.Num -1
				if data.Num<=0 then
					self.dataTable[tempDataId] = nil
				end
				table.remove(self.itemIdTable, signindex)
			else
				data.Num = data.Num -1
				--if data.Num<=0 then
					self.dataTable[tempDataId] = nil
				--end
				local removetable = {}
				for i=1,#self.itemIdTable do
					if self.itemIdTable[i]== tempDataId then
						table.insert(removetable,i)
					end
				end
				for i=#removetable,1,-1 do
					table.remove(self.itemIdTable, removetable[i])
				end
			end
            UI_Tip_UseItem.DoTweenScale()
		else
			local signindex = nil
			for i,v in ipairs(self.itemIdTable) do
				if v==tempDataId then
					signindex = i
				end
			end
			data.Num = data.Num -1
			if data.Num<=0 then
				self.dataTable[tempDataId] = nil
			end
			table.remove(self.itemIdTable, signindex)
			UI_Tip_UseItem.DoTweenScale()
		end
	end
end

function Bag_QuickUse:OnClick(go, id)
	if id == 10 then
		--使用按钮
		if using ==false then
			GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_USEITEM_CLOSEBTN)
			if self.mCurData >= 1 and #self.itemIdTable >= self.mCurData then
				local bagType = self.dataTable[self.itemIdTable[self.mCurData]].bagType
				local data = self.dataTable[self.itemIdTable[self.mCurData]].data
				using = BagMgr.UniqueUseItem(bagType,data,data.Num,true)
				local isEquip = data.itemData.itemInfoType == Item_pb.ItemInfo.EQUIP
				--是否是通过快捷使用物品方式穿戴的装备
				EquipMgr.SetEquipedFromQuickUseItem(isEquip and using)
				if not using then
					self:CheckRemove(false)
					self.mLastUseData = nil
					self:CheckNext()
				end
			end
		end
	elseif id == 11 then
		--关闭
		GameEvent.Trigger(EVT.PACKAGE, EVT.PACKAGE_USEITEM_CLOSEBTN)
		if self.itemIdTable[self.mCurData] and self.dataTable[self.itemIdTable[self.mCurData]] then
			self:CheckRemove(true)
		end
		self:CheckNext()
	elseif id == 0 then --点击物品
		if self.mCurData >= 1 and #self.itemIdTable >= self.mCurData then
			local bagType = self.dataTable[self.itemIdTable[self.mCurData]].bagType
			local data = self.dataTable[self.itemIdTable[self.mCurData]].data
			if data.itemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
				--装备
				local bestItem = BagMgr.GetEquipAutoSlotId(bagType, data.item.tempId)
				if bestItem then
					local itemSlot = bestItem.item
					EquipMgr.OpenEquipTips(EquipMgr.ItemTipsStyle.FromUseItem, itemSlot)
				end
			else
				--物品
				BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, data.itemData.id)
			end
		end
	end
end

function Bag_QuickUse:OnMulitiUseItem(redata)
	for i=1,#redata.ayitemInfo do
		self:CheckRemove(false,redata.ayitemInfo[i].tempId)
		self:CheckNext()
	end
	self.mLastUseData = nil
	using =false
end

function Bag_QuickUse:OnUseItem(redata)
	self:CheckRemove(false, redata.tempId)
	self.mLastUseData = nil
	self:CheckNext()
	using =false
end

function Bag_QuickUse:OnMoveItem(redata)
	if self.itemIdTable[self.mCurData] and self.dataTable[self.itemIdTable[self.mCurData]] then
		local bagType = self.dataTable[self.itemIdTable[self.mCurData]].bagType
		local data = self.dataTable[self.itemIdTable[self.mCurData]].data
		
        if redata.fromType == Bag_pb.NORMAL and redata.toType == Bag_pb.EQUIP then
            --装备背包多了一件装备，检测是否是当前这一件
            self:CheckRemove(false)
            self.mLastUseData = nil
            self:CheckNext()
            using =false
        end
	end
end

function Bag_QuickUse:CheckNext()
	if table.getn(self.itemIdTable) >= 1 then
		self.mCurData = table.getn(self.itemIdTable)
		self:CheckData()
	else
		UIMgr.UnShowUI(AllUI.UI_Tip_UseItem)
	end
end

function Bag_QuickUse:IsEmpty()
	local count = table.count(self.itemIdTable)
	return count<=0
end

return Bag_QuickUse