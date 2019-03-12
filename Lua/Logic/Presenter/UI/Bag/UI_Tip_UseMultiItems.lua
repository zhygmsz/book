module("UI_Tip_UseMultiItems",package.seeall)

--1 使用 2 分解
 type = 1
 data = nil
 bagType = Bag_pb.NORMAL
 fullCount = true
 mAutoSlotId=false

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
--减少数量按钮
local mReduceBtn
--增加数量按钮
local mAddBtn
--数量
local mNumInput
local mMaxCount = 1
local useNum=1

function OnCreate(self)
    local item = self:Find("Offset/Bg/Item");
    mItemBg = item.transform:Find("ItemBg"):GetComponent("UISprite");
    mItemIcon = item.transform:Find("ItemIcon"):GetComponent("UISprite");
    mItemCount = item.transform:Find("ItemCount"):GetComponent("UILabel");
    mItemSelect = item.transform:Find("ItemSelect").gameObject;
    mItemLock = item.transform:Find("ItemLock").gameObject;
    mItemName =self:FindComponent("UILabel","Offset/Bg/Name");
    mUseBtn = self:Find("Offset/Bg/UseBtn");
    mCloseBtn = self:Find("Offset/Bg/CloseBtn");
    mReduceBtn = self:Find("Offset/Bg/ReduceBtn");
    mAddBtn =  self:Find("Offset/Bg/AddBtn");
    mNumInput = self:Find("Offset/Bg/NumBg/Num"):GetComponent("UIInput");
    local call = EventDelegate.Callback(OnChange);
    EventDelegate.Set(mNumInput.onChange,call);
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_USE_ITEM, OnUseItem);
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_USE_MULITI_ITEM, OnMulitiUseItem);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_USE_ITEM,OnUseItem);
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_USE_MULITI_ITEM,OnMulitiUseItem);
	mEvents = {};
end

function OnEnable(self)
    SetBtnVisual(type)
    SetViewData(data)
    RegEvent(self)
end

function OnDisable(self)
    UnRegEvent(self)
    fullCount = true;
end

--s设置按钮显示与隐藏
function SetBtnVisual(type)
    mUseBtn.gameObject:SetActive(false)
    --只有使用
    if type==1 or type==2 then mUseBtn.gameObject:SetActive(true) end;
end

function GetCount(array)
	local count=0
	for i,v in ipairs(array) do
		count = count+v.Num
	end
	return count
end

--设置显示内容 data为背包格子上的数据对象  local data = {item = Item_pb.Item, itemData = Item_pb.ItemInfo, lock=true }
function SetViewData(data)
    if data == nil then return end
    mItemIcon.spriteName = ""
    if data and data.itemData then
        -- local loadResID = ResConfigData.GetResConfigID(data.itemData.icon_big)
        -- UIUtil.SetTexture(loadResID,mItemIcon)
        mItemIcon.spriteName = data.itemData.icon_big
    end
    
    local bgid = data.itemData and data.itemData.quality or -1
    mItemBg.spriteName =  UIUtil.GetItemQualityBgSpName(bgid)
    mMaxCount =  fullCount and data.item.count or data.Num

    mItemCount.text =(data and data.item and mMaxCount > 1) and tostring(mMaxCount) or "";
    mItemSelect:SetActive(false);
    mItemLock:SetActive(false);
    mItemName.text = data.itemData.name
    mNumInput.value="1"
end

function OnChange()
    -- body
    if mNumInput.value=="" then mNumInput.value = "1" end
    useNum = tonumber(mNumInput.value)
    if useNum==nil then useNum=1 end
    if useNum<1 then useNum=1 end
    if useNum>mMaxCount then useNum=mMaxCount end
    mNumInput.value = ""..useNum
end

function OnUseItem(redata)
	--if redata.slotId == data.slotId and redata.id == data.item.id then
        UIMgr.UnShowUI(AllUI.UI_Tip_UseMultiItems)
	--end
end

function OnMulitiUseItem(redata)
    UIMgr.UnShowUI(AllUI.UI_Tip_UseMultiItems)
end

function OnClick(go,id)
    if id == 10 then
        if mNumInput.value=="" then mNumInput.value = "1" end
        useNum = tonumber(mNumInput.value)
        if useNum==nil then useNum=1 end
        if useNum<1 then useNum=1 end
        if useNum>mMaxCount then useNum=mMaxCount end
        mNumInput.value = ""..useNum
        if type==1 then
            --使用按钮
            if mAutoSlotId then
                if BagMgr.UseItemAutoSlotId(bagType,data.item.tempId,useNum) then
                else
                end
            else
               -- BagMgr.UniqueUseItem(bagType,data,useNum)
                BagMgr.RequestUseBagItem(bagType,data.slotId,data.item.id,data.item.tempId, useNum)
            end
        elseif type==2 then
       --分解按钮
            BagMgr.RequestDecomposeBagItem(bagType,data.slotId,data.item.id,useNum)
        end
    elseif id == 12 then
        --关闭
        UIMgr.UnShowUI(AllUI.UI_Tip_UseMultiItems)
    elseif id == 13 then
        --减少
        if mNumInput.value=="" then mNumInput.value = "1" end
        useNum = tonumber(mNumInput.value)-1
        if useNum==nil then useNum=1 end
        if useNum<1 then useNum=1 end
        mNumInput.value = ""..useNum
    elseif id == 14 then
        --增加
        if mNumInput.value=="" then mNumInput.value = "1" end
        useNum = tonumber(mNumInput.value)+1
        if useNum==nil then useNum=1 end
        if useNum>mMaxCount then useNum=mMaxCount end
        mNumInput.value = ""..useNum
    elseif id == 15 then
        --最少
        mNumInput.value = "1"
    elseif id == 16 then
        --最多
        useNum=mMaxCount
        mNumInput.value = ""..useNum
    end
end
--endregion
