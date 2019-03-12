MainUIEquip = class("MainUIEquip")

--UI槽位到部位映射
local Index2Bodytype =
{
	--v换成部位枚举
	[1] = Item_pb.ItemInfo.WEAPON,
	[2] = Item_pb.ItemInfo.BRACERS,  --护腕
	[3] = Item_pb.ItemInfo.GLOVES,
	[4] = Item_pb.ItemInfo.RING,
	[5] = Item_pb.ItemInfo.CLOTHES,
	[6] = Item_pb.ItemInfo.BELT,
	[7] = Item_pb.ItemInfo.SHOES,
	[8] = Item_pb.ItemInfo.NECKLACE,
}

--部位到UI槽位映射
local Bodytype2Data =
{
    [Item_pb.ItemInfo.WEAPON] = { index = 1, icon = "img_beibao_wuqi" },
	[Item_pb.ItemInfo.BRACERS] = { index = 2, icon = "img_beibao_huwan" },
	[Item_pb.ItemInfo.GLOVES] = { index = 3, icon = "img_beibao_shoutao" },
	[Item_pb.ItemInfo.RING] = { index = 4, icon = "img_beibao_jiezhi" },
	[Item_pb.ItemInfo.CLOTHES] = { index = 5, icon = "img_beibao_yifu" },
	[Item_pb.ItemInfo.BELT] = { index = 6, icon = "img_beibao_yaodai" },
	[Item_pb.ItemInfo.SHOES] = { index = 7, icon = "img_beibao_xie" },
	[Item_pb.ItemInfo.NECKLACE] = { index = 8, icon = "img_beibao_xianglian" },
}

--EffectItem
local EffectItem = class("EffectItem")
function EffectItem:ctor(parent, sortingOrder)
	--组件

	--loader
	self._effLoader = LoaderMgr.CreateEffectLoader()

    --变量
    self._parent = parent
    self._sortingOrder = sortingOrder
    
	self._duration = 1
	self._timerId = nil
    self._firstSetting = true
    self._targetPos = Vector3.zero
	--用于移出屏幕来实现隐藏效果
	self._farPos = Vector3(10000, 10000, 0)
end

function EffectItem:Reset()
	if self._timerId then
		GameTimer.DeleteTimer(self._timerId)
		self._timerId = nil
	end
end

function EffectItem:Play()
	self:Reset()

	--加载特效
	self._effLoader:LoadObject(GameAsset.UI_beibao_eff01)
	
	--设置类方法，只调用一次
	if self._firstSetting then
		self._firstSetting = false

		self._effLoader:SetLayer(CameraLayer.UILayer)
		self._effLoader:SetParent(self._parent)
		self._effLoader:SetLocalPosition(Vector3.zero)
		self._effLoader:SetLocalScale(Vector3.one)
        self._effLoader:SetLocalRotation(UnityEngine.Quaternion.identity)
		self._effLoader:SetSortOrder(self._sortingOrder)
	end
    self._effLoader:SetLocalPosition(self._targetPos)
	self._effLoader:SetActive(true)

	self._timerId = GameTimer.AddTimer(self._duration, 1, self.OnEffectEnd, self)
end

function EffectItem:OnEffectEnd()
    self._timerId = nil
    
    --播放完隐藏
    self:OnDisable()
end

--[[
    @desc: UI.OnDisable时，移除界面
]]
function EffectItem:OnDisable()
	self._effLoader:SetPosition(self._farPos)
end

function EffectItem:OnDestroy()
	if self._effLoader then
		LoaderMgr.DeleteLoader(self._effLoader)
		self._effLoader = nil
	end
	self._firstSetting = true
end

--EquipItem
local EquipItem = class("EquipItem")
function EquipItem:ctor(ui, path, idx, sortingOrder)
	--组件
	self._transform = ui:Find(path)
    self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path
	--部位索引，[1, 8]
	self._idx = idx

	self._bodyType = Index2Bodytype[idx]

    self._bg = ui:FindComponent("UISprite", path .. "ItemBg")
	self._itemIcon = ui:FindComponent("UISprite", path .. "ItemIcon")
	self._itemIconGo = ui:FindGo(path .. "ItemIcon")
	self._defaultIcon = ui:FindComponent("UISprite", path .. "icon")
    self._defaultIconGo = ui:FindGo(path .. "icon")
    
    self._defaultIconGo:SetActive(true)
    self._defaultIcon.spriteName = Bodytype2Data[self._bodyType].icon
    self._defaultIconGo:SetActive(false)

    self._itemIconGo:SetActive(true)
    self._itemIcon.spriteName = nil
    self._itemIconGo:SetActive(false)
    
    self._effectItem = EffectItem.new(self._transform, sortingOrder)

    --变量
    self._pos = self._transform.position
end

function EquipItem:Show()
	--尝试获取到对应部位的装备数据
	local itemSlot = EquipMgr.GetEquipedItemSlotByBodyType(self._bodyType)
	if itemSlot then
		--该部位有装备
		local itemData = ItemData.GetItemInfo(itemSlot.item.tempId)
        if itemData then
            self._defaultIconGo:SetActive(false)
            self._itemIconGo:SetActive(true)
			self._itemIcon.spriteName = itemData.icon_big
			self._bg.spriteName = UIUtil.GetItemQualityBgSpName(itemData.quality)
		else
			GameLog.LogError("MainUIEquip.EquipItem.Show -> itemData is nil")
		end
	else
        --该部位没装备
        --重置背景品质框
		self._bg.spriteName = UIUtil.GetItemQualityBgSpName()
		self._defaultIconGo:SetActive(true)
		self._itemIconGo:SetActive(false)
	end
end

function EquipItem:PlayEffect()
    self._effectItem:Play()
end

function EquipItem:OnDisable()
    self._effectItem:OnDisable()
end

function EquipItem:OnDestroy()
    self._effectItem:OnDestroy()
end

function MainUIEquip:ctor(uiFrame)
    --组件
    self._transform = uiFrame:Find("Equip")
    self._gameObject = uiFrame:FindGo("Equip")

    self._offset = uiFrame:Find("Equip/Offset")
    self._offsetPanel = uiFrame:FindComponent("UIPanel", "Equip/Offset")
    self._offsetGo = uiFrame:FindGo("Equip/Offset")
    self._offsetGo:SetActive(false)

    self._EquipItemMaxNum = 8
    self._equipItemList = {}
    local sortingOrder = self._offsetPanel.sortingOrder + 1
    for idx = 1, self._EquipItemMaxNum do
        self._equipItemList[idx] = EquipItem.new(uiFrame, "Equip/Offset/ItemList/item" .. tostring(idx), idx, sortingOrder)
    end

    --分配特效资源id
    ResMgr.DefineAsset("Assets/Res/UIEffects/Prefabs/UI_beibao_eff01.prefab")
    
    self._tweenPos = uiFrame:FindComponent("TweenPosition", "Equip/Offset")
    self._tweenPos.enabled = false
    self._tweenScale = uiFrame:FindComponent("TweenScale", "Equip/Offset")
    self._tweenScale.enabled = false

    self._funcOnTweenEnd = EventDelegate.Callback(self.OnTweenEnd, self)
    EventDelegate.Set(self._tweenPos.onFinished, self._funcOnTweenEnd)

    --变量
    --查找背包按钮
    self._bagBtnTrs = uiFrame:Find("BottomRight/FunctionBtnsBR/BtnBackpack")

    self._offsetOriginPos = self._offset.position
    self._offsetLocalPos = self._offset.localPosition
    self._timerId = nil
    --显示持续时间
    self._showDuration = 2
    --飞入背包持续时间
    self._flyDuration = 0.5
    self._one = Vector3.one
    self._zero = Vector3.zero

    --限制等级，超过该等级后，不再显示
    self._limitLevel = ConfigData.GetIntValue("Equipment_frame_level_limit")
end

function MainUIEquip:Reset()
    if self._timerId then
        GameTimer.DeleteTimer(self._timerId)
        self._timerId = nil
    end

    --清理tween动画
    self._tweenPos.enabled = false
    --self._offset.position = self._offsetOriginPos
    self._offset.localPosition = self._offsetLocalPos
    self._tweenScale.enabled = false
    self._offset.localScale = self._one
end

function MainUIEquip:PlayTween()
    self._tweenPos.enabled = true
    self._tweenPos.worldSpace = true
    self._tweenPos.from = self._offset.position
    self._tweenPos.to = self._bagBtnTrs.position
    self._tweenPos.duration = self._flyDuration
    self._tweenPos:ResetToBeginning()
    self._tweenPos:PlayForward()
    
    self._tweenScale.enabled = true
    self._tweenScale.from = self._one
    self._tweenScale.to = self._zero
    self._tweenScale.duration = self._flyDuration
    self._tweenScale:ResetToBeginning()
    self._tweenScale:PlayForward()
end

function MainUIEquip:OnTweenEnd()
    self:SetVisible(false)
end

function MainUIEquip:OnShowEnd()
    --执行飞入背包动画
    self:PlayTween()
end

function MainUIEquip:SetVisible(visible)
    self._offsetGo:SetActive(visible)
end

function MainUIEquip:Play(index)
    if not index then
        return
    end
    local equipItem = self._equipItemList[index]
    if not equipItem then
        return
    end

    self:Reset()

    self:SetVisible(true)
    --刷新槽位
    for _, item in ipairs(self._equipItemList) do
        item:Show()
    end

    --播放特效
    equipItem:PlayEffect()

    --延迟
    self._timerId = GameTimer.AddTimer(self._showDuration, 1, self.OnShowEnd, self)
end

--[[
    @desc: 检查是否符合显示条件
]]
function MainUIEquip:CheckNeedShow()
    if UserData.GetLevel() > self._limitLevel then
        return false
    end
    local equipedFromQuickUseItem = EquipMgr.GetEquipedFromQuickUseItem()
    if not equipedFromQuickUseItem then
        return
    end
    return true
end

function MainUIEquip:OnMoveItem(data)
    if data.toType == Bag_pb.EQUIP then
        --检测是否是通过快捷使用 - 装备途径穿上的
        if not self:CheckNeedShow() then
            return
        end

        --清除记录
        EquipMgr.SetEquipedFromQuickUseItem(false)

        self:Play(Bodytype2Data[data.toSlotId + 1].index)
    end
end

function MainUIEquip:OnEnable(uiFrame)
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM, self.OnMoveItem, self)
end

function MainUIEquip:OnDisable(uiFrame)
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_MOVE_ITEM, self.OnMoveItem, self)

    for _, item in ipairs(self._equipItemList) do
        item:OnDisable()
    end
end

function MainUIEquip:OnDestroy(uiFrame)
    for _, item in ipairs(self._equipItemList) do
        item:OnDestroy()
    end
end

return MainUIEquip