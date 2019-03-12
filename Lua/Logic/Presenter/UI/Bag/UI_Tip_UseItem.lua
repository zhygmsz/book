module("UI_Tip_UseItem", package.seeall)
--物品背景图
local mItemBg
--图标
local mItemIcon
--数量
local mItemCount
--选择框
local mItemSelect
--锁
local mItemLock
--名称
local mItemName
--关闭界面
local mCloseBtn
--使用按钮
local mUseBtn
local UseBtnLabel
local tweenScale
enable=false
local using =false

function OnCreate(self)
	local item = self:Find("Offset/Bg/Item");
	mItemBg = item.transform:Find("ItemBg"):GetComponent("UISprite");
	mItemIcon = item.transform:Find("ItemIcon"):GetComponent("UISprite");
	mItemCount = item.transform:Find("ItemCount"):GetComponent("UILabel");
	mItemSelect = item.transform:Find("ItemSelect").gameObject;
	mItemLock = item.transform:Find("ItemLock").gameObject;
	mItemName = self:FindComponent("UILabel", "Offset/Bg/Name");
	mUseBtn = self:Find("Offset/Bg/UseBtn");
    mUseBtnLabel = self:Find("Offset/Bg/UseBtn/Label"):GetComponent("UILabel");
	mCloseBtn = self:Find("Offset/Bg/CloseBtn");
	tweenScale = self:Find("Offset/Bg"):GetComponent("TweenScale");
end

function OnEnable(self)
	enable = true
	BagMgr.GetQuickUseObj():OnEnable()
end

function OnDisable(self)
	enable=false
	BagMgr.GetQuickUseObj():OnDisable()
end

--是否可堆叠
function CheckSuperPosotion( data )
	if data.itemData and (data.itemData.maxSuperPosition==nil or data.itemData.maxSuperPosition<=1) then 
		return false
	 end
	 return true
end

--设置显示内容 data为背包格子上的数据对象  local data = {item = Item_pb.Item, itemData = Item_pb.ItemInfo, lock=true }
function SetViewData(data)
	if data == nil then return end
	mItemIcon.spriteName = ""
	if data and data.itemData then
		mItemIcon.spriteName = data.itemData.icon_big
	end
	local bgid = data.itemData and data.itemData.quality or - 1
	mItemBg.spriteName = UIUtil.GetItemQualityBgSpName(bgid)
	mItemCount.text =(data) and tostring(data.Num) or "";
	if not CheckSuperPosotion(data) then mItemCount.text = "" end

	mItemSelect:SetActive(false);
	mItemLock:SetActive(false);
	mItemName.text = data.itemData.name
	if data.itemData.itemInfoType == Item_pb.ItemInfo.EQUIP then
		local str = TipsMgr.GetTipByKey("bag_title_quick_equip")
        mUseBtnLabel.text = str  or "Equip";
    else
		local str = TipsMgr.GetTipByKey("bag_title_quick_use")
        mUseBtnLabel.text = str  or "Use"
	end
	DoTweenScale()
end

function DoTweenScale()
	tweenScale.gameObject:SetActive(true)
	tweenScale:ResetToBeginning()
	tweenScale:PlayForward()
end

function OnClick(go, id)
	local obj = BagMgr.GetQuickUseObj()
	if obj then obj:OnClick(go, id) end
end

return UI_Tip_UseItem