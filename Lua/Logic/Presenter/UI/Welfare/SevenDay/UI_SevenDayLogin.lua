module("UI_SevenDayLogin", package.seeall)

local GeneralItem = require("Logic/Presenter/UI/Shop/GeneralItem")
local SevenDayLoginMiddleItem = require("Logic/Presenter/UI/Welfare/SevenDay/SevenDayLoginMiddleItem")
local SevenDayLoginBottomItem = require("Logic/Presenter/UI/Welfare/SevenDay/SevenDayLoginBottomItem")

local SDLMgr = SevenDayLoginMgr
local MiddleItemState = SDLMgr.MiddleItemState

--修改许愿按钮当前状态
local ChangeBtnState = {}
--修改许愿
ChangeBtnState.Change = 1
--返回
ChangeBtnState.Return = 2

--组件
local mSelf
local mPanel
local mTop
local mTopGetBtn
local mTopDes
local mTopDesGo
local mMiddle
local mMiddleItem
local mMiddleGrid
local mMiddleGridTrs
local mBottom
local mBottomWishGo
local mBottomHideDes
local mBottomHideDesGo
local mBottomNextDayGo
local mBottomNextDayItem
local mBottomNextDayDes
local mBottomChangeGo
local mBottomChangeLbl
local mBottomWishDes
local mWillGetItemId

--特效loader
local mEffectLoaders={}

--变量
local mTopItemParentList = {}
local mTopItemList = {}
local mMiddleItemList = {}
local mBottomItemParentList = {}
local mBottomItemList = {}
local mGiftIds = {}

local mCurWishSelect = - 1
local mCurGiftSelect = -1
local mCurMiddleItemSelect = -1
local mChangeBtnState = ChangeBtnState.Change
local mEventType = {
	Close =0,--关闭UI
	SigninItems={IdScopeOfMin=1,IdScopeOfMax=7},--签到物品
	UltimateReward={IdScopeOfMin=11,IdScopeOfMax=13},--终极奖励物品
	ReceiveUltimateReward = 19,--领取终极奖励
	WishItems={IdScopeOfMin=21,IdScopeOfMax=27},--许愿物品
	WillGetItemTip=30,
	Wish = 31,--许愿按钮
	ChangeWish=41,--修改许愿
	SelectMiddleItem={IdScopeOfMin=51,IdScopeOfMax=57}--选择单日

}


local function LoadEffect()
	local _effectResId = 400400067;
	local effectSortOrder = mPanel.sortingOrder + 1
	for i=1,3 do
		mEffectLoaders[i] = LoaderMgr.CreateEffectLoader();
		mEffectLoaders[i]:LoadObject(_effectResId);
		mEffectLoaders[i]:SetLayer(CameraLayer.UILayer);
		if i==1 then
			mEffectLoaders[i]:SetTransform(mBottom,Vector3(10000,10000,0),Vector3.one,UnityEngine.Quaternion.identity,effectSortOrder);
		elseif i==2 then
			mEffectLoaders[i]:SetTransform(mTop,Vector3(10000,10000,0),Vector3.one,UnityEngine.Quaternion.identity,effectSortOrder);
		elseif i==3 then
			mEffectLoaders[i]:SetTransform(mMiddle,Vector3(10000,10000,0),Vector3.one,UnityEngine.Quaternion.identity,effectSortOrder);
		end
		mEffectLoaders[i]:SetActive(true);
	end
end

local function InitUI()
end

local function CheckAwardRange(awardIdx)
	if not awardIdx then
		return false
	end
	local bottomItem = mBottomItemList[awardIdx]
	if bottomItem then
		return true
	else
		return false
	end
end

local function CheckMiddleItemRange(middleItemIdx)
	if not middleItemIdx then
		return false
	end
	local middleItem = mMiddleItemList[middleItemIdx]
	if middleItem then
		return true
	else
		return false
	end
end

local function CheckGiftRange(giftIdx)
	if not giftIdx then
		return false
	end
	local tempId = mGiftIds[giftIdx]
	if tempId then
		return true
	else
		return false
	end
end

local function DestroyAllTopItem()
	local maxFashionNum = SDLMgr.GetFashionClothesNum()
	for idx = 1, maxFashionNum do
		if mTopItemList[idx] then
			mTopItemList[idx]:OnDestroy()
			mTopItemList[idx] = nil
		end
	end
end

local function SetWishEffect(wishIdx)
	local parent = mBottomItemParentList[wishIdx]
	local bottomItem = mBottomItemList[wishIdx]
	if not tolua.isnull(parent) and bottomItem and mEffectLoaders[1] then
		mEffectLoaders[1]:SetParent(parent)
		mEffectLoaders[1]:SetPosition(parent.position)
		mEffectLoaders[1]:SetLocalScale(bottomItem:GetScale())
	end
end

local function SetGiftEffect(giftIdx)
	local parent = mTopItemParentList[giftIdx]
	local topItem = mTopItemList[giftIdx]
	if not tolua.isnull(parent) and topItem and mEffectLoaders[2] then
		mEffectLoaders[2]:SetParent(parent)
		mEffectLoaders[2]:SetPosition(parent.position)
		mEffectLoaders[2]:SetLocalScale(Vector3(0.6, 0.6, 1))
	end
end

local function SetMiddleItemEffect(middleIdx)
	local middleItem = mMiddleItemList[middleIdx]
	if not middleItem then
		return
	end
	local parent = middleItem:GetTransform()
	if not tolua.isnull(parent) and mEffectLoaders[3] then
		mEffectLoaders[3]:SetParent(parent)
		mEffectLoaders[3]:SetPosition(parent.position)
		mEffectLoaders[3]:SetLocalScale(middleItem:GetScale())
	end
end

--点击许愿物品
local function OnClickWishItem(id)
	if id and mCurWishSelect == id then
		local bottomItem = mBottomItemList[id]
		if not bottomItem then
			return
		end
		bottomItem:ShowTips()
		return
	end
	mCurWishSelect = id
	SetWishEffect(id)
end

--点击礼包奖励物品
local function OnClickGiftItem(id)
	local tempId = mGiftIds[id]
	if not tempId then
		return
	end
	if SDLMgr.CheckCanGetGift() then
		if mCurGiftSelect == id then
			--显示tips
			BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, tempId)
			return
		end
		mCurGiftSelect = id
		SetGiftEffect(id)
	else
		--不可领取时，直接显示tips，不显示选中特效
		BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, tempId)
	end
end

local function DoShowChangeBtnState()
	if mChangeBtnState == ChangeBtnState.Change then
		mBottomChangeLbl.text = WordData.GetWordStringByKey("welfare_sevenday_changewish")
	elseif mChangeBtnState == ChangeBtnState.Return then
		mBottomChangeLbl.text = WordData.GetWordStringByKey("welfare_sevenday_back")
	end
end

local function AllMiddleItemOnDestroy()
	for _, item in pairs(mMiddleItemList) do
		if item then
			item:OnDestroy()
		end
	end
end

local function AllBottomItemOnDestroy()
	for _, item in pairs(mBottomItemList) do
		if item then
			item:OnDestroy()
		end
	end
end

local function DestroyEffect()
	for i=1,3 do 
		LoaderMgr.DeleteLoader(mEffectLoaders[i]);
	end
	table.clear(mEffectLoaders);
end

local function HideWishEffect()
	if mEffectLoaders[1] then
		mEffectLoaders[1]:SetParent(mBottom)
		mEffectLoaders[1]:SetLocalPosition(Vector3(10000, 10000, 0))
		mCurWishSelect = -1
	end
end

local function HideMiddleItemEffecct()
	if mEffectLoaders[3] then
		mEffectLoaders[3]:SetParent(mMiddle)
		mEffectLoaders[3]:SetLocalPosition(Vector3(10000, 10000, 0))
		mCurMiddleItemSelect = -1
	end
end

local function DoShowBottomWishingItem(dayIdx)
	if SDLMgr.CheckIsAllWished() then
		--mBottomWishDes.text = "修改第" .. dayIdx .. "天奖励"
		mBottomWishDes.text = SDLMgr.GetBottomChangeWishDesStr(dayIdx)
	else
		--mBottomWishDes.text = "许愿第" .. dayIdx .. "天奖励"
		mBottomWishDes.text = SDLMgr.GetBottomWishDesStr(dayIdx)
	end
	local maxWishItemNum = SDLMgr.GetMaxWishItemNum()
	local ids = SDLMgr.GetWishItemIdList(dayIdx)
	for idx = 1, #mBottomItemList do
		if idx<#mBottomItemList then
			local wishItemId = ids[idx]
			local bottomItem = mBottomItemList[idx]
			if bottomItem and wishItemId then
				bottomItem:Show(wishItemId)
			end
		else
			mBottomItemList[idx]:Hide()
		end
	end
end

local function CheckDirectShowTips()
	return mChangeBtnState == ChangeBtnState.Change
end

local function ShowWillGet(dayIdx)
	if not dayIdx then
		return
	end
	mBottomNextDayGo:SetActive(true)
	mBottomNextDayDes.text = SDLMgr.GetWillGetDesStr(dayIdx)
	mBottomNextDayItem:ShowByItemId(mMiddleItemList[dayIdx]._data.tempId,nil,true)
	mWillGetItemId = mMiddleItemList[dayIdx]._data.tempId or 0;
end

local function HideWillGet()
	mBottomNextDayGo:SetActive(false)
end

local function HideAllMiddleItemSelected()
	for _, middleItem in ipairs(mMiddleItemList) do
		if middleItem then
			middleItem:HideSelected()
		end
	end
end

local function ShowMiddleItemSelected(dayIdx)
	if not dayIdx then
		return
	end
	local middleItem = mMiddleItemList[dayIdx]
	if middleItem then
		HideAllMiddleItemSelected()
		middleItem:ShowSelected()
	end
end

local function HideWish()
	mBottomWishGo:SetActive(false)
end

local function ShowWish(dayIdx)
	if not dayIdx then
		return
	end
	mBottomWishGo:SetActive(true)
	DoShowBottomWishingItem(dayIdx)
end

local function CheckIsChangeingWish()
	return mChangeBtnState == ChangeBtnState.Return
end

--点击签到物品
local function OnClickMiddleItem(id)
	if SDLMgr.CheckHasWished(id) then
		local middleItem = mMiddleItemList[id]
		if not middleItem then
			return
		end
		if SDLMgr.CheckIsAllWished() then
			--[[
			if CheckDirectShowTips() then
				middleItem:ShowTips()
			else
				if mCurMiddleItemSelect == id then
					middleItem:ShowTips()
					return
				end
				mCurMiddleItemSelect = id
				SetMiddleItemEffect(id)
				DoShowBottomWishingItem(id)
			end
			--]]
			--只能选中未解锁的天
			local curDayIdx = SDLMgr.GetCurDayIdx()
			local maxDayIdx = SDLMgr.GetMaxDayIdx()
			if curDayIdx == maxDayIdx then
				TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_activityEnd"))
				return
			end
			if id <= curDayIdx then
				TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_chooseLimit"))
				return
			end
			mCurMiddleItemSelect = id
			ShowMiddleItemSelected(id)
			if CheckIsChangeingWish() then
				ShowWish(id)
			else
				ShowWillGet(id)
			end
		else
			--middleItem:ShowTips()
		end
	else
		DoShowBottomWishingItem(id)
	end
end

local function DoWish(dayIdx, wishItemIdx)
	if CheckAwardRange(wishItemIdx) then
		local wishingTempId = SDLMgr.GetWishingTempId(dayIdx, wishItemIdx)
		if wishingTempId ~= - 1 then
			SDLMgr.SendWish(dayIdx, wishItemIdx, wishingTempId)
		else
			GameLog.LogError("UI_SevenDayLogin.DoWish -> wishingTempId is -1")
		end
	else
		--未选中
		TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_choosemsg"))
	end
end

--点击许愿按钮
local function OnClickWishBtn()
	local isAllWished = SDLMgr.CheckIsAllWished()
	if isAllWished then
		--修改许愿逻辑
		if CheckMiddleItemRange(mCurMiddleItemSelect) then
			--判断是否是今天之后的
			local curDayIdx = SDLMgr.GetCurDayIdx()
			if curDayIdx < mCurMiddleItemSelect then
				DoWish(mCurMiddleItemSelect, mCurWishSelect)
			else
				TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_chooseLimit"))
			end
		else
			TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_choosemsg_day"))
		end
	else
		--一天天往后，许愿逻辑
		local firstUnWishedDayIdx = SDLMgr.GetFirstUnWishedDayIdx()
		if firstUnWishedDayIdx ~= -1 then
			DoWish(firstUnWishedDayIdx, mCurWishSelect)
		else
			GameLog.LogError("UI_SevenDayLogin.OnClickWishBtn -> firstUnWishedDayIdx is -1")
		end
	end
end

--点击领取终极奖励按钮
local function OnClickGiftBtn()
	if CheckGiftRange(mCurGiftSelect) then
		if SDLMgr.CheckCanGetGift() then
			if not SDLMgr.CheckHasGotGift() then
				SDLMgr.SendGetGift(mGiftIds[mCurGiftSelect])
			else
				--已经领取过
			TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_finalGift_got2"))
			end
		else
			--未达到领取条件
			TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_get_tips"))
		end
	else
		--未选中
		TipsMgr.TipByFormat(WordData.GetWordStringByKey("welfare_sevenday_clothes"))
	end
end

--点击签到物品领取按钮
local function OnClickMiddleGetItemBtn(id)
	if id then
		local item = mMiddleItemList[id]
		if item then
			item:OnClick()
		end
	end
end

--点击修改许愿，自动选中第一个可修改许愿的天
local function AutoSelectForChange()
	local curDayIdx = SDLMgr.GetCurDayIdx()
	local maxDayIdx = SDLMgr.GetMaxDayIdx()
	if curDayIdx < maxDayIdx then
		--OnClickMiddleItem(curDayIdx + 1)
		HideWillGet()
		ShowWish(curDayIdx + 1)
	end
end

local function ShowChangeBtn()
	mBottomChangeGo:SetActive(true)
end

local function HideChangeBtn()
	mBottomChangeGo:SetActive(false)
end

--点击修改许愿按钮
local function OnClickChangeBtn()
	if mChangeBtnState == ChangeBtnState.Change then
		mChangeBtnState = ChangeBtnState.Return
		HideChangeBtn()
		--AutoSelectForChange()
		HideWillGet()
		ShowWish(mCurMiddleItemSelect)
	elseif mChangeBtnState == ChangeBtnState.Return then
		mChangeBtnState = ChangeBtnState.Change
		ShowChangeBtn()
		HideWish()
		HideWishEffect()
		ShowWillGet(mCurMiddleItemSelect)
		--HideMiddleItemEffecct()
	end
	DoShowChangeBtnState()
end

--重置修改许愿按钮状态和表现
local function ResetChangeBtnState()
	mChangeBtnState = ChangeBtnState.Change
	DoShowChangeBtnState()
	HideWish()
	HideWishEffect()
	HideMiddleItemEffecct()
end

--显示顶部区域
local function ShowTop()
	local ids = SDLMgr.GetFashionClothesId()
	mGiftIds = ids
	local maxFashionNum = SDLMgr.GetFashionClothesNum()
	for idx = 1, maxFashionNum do
		mTopItemList[idx]:ShowByItemId(ids[idx],nil,true)
	end

	if SDLMgr.CheckCanGetGift() then
		if SDLMgr.CheckHasGotGift() then
			--已领取
			mTopGetBtn:SetActive(false)
			mTopDesGo:SetActive(true)
			mTopDes.text = WordData.GetWordStringByKey("welfare_sevenday_got")
		else
			--可领取且未领取
			mTopGetBtn:SetActive(true)
			mTopDesGo:SetActive(false)
		end
	else
		--不可领
		mTopGetBtn:SetActive(false)
		mTopDesGo:SetActive(true)
		mTopDes.text = SDLMgr.GetTopDesStr()
	end
end

--显示中间区域
local function ShowMiddle()
	local sdlData = SDLMgr.GetSevenDayLoginData()
	local maxDayIdx = SDLMgr.GetMaxDayIdx()
	for idx = 1, maxDayIdx do
		local data = sdlData[idx]
		local middleItem = mMiddleItemList[idx]
		if middleItem and data then
			middleItem:Show(data)
		end
	end
end

--显示下方区域
local function ShowBottom()
	if SDLMgr.CheckIsLastDay() then
		HideWish()
		HideChangeBtn()
		mBottomHideDesGo:SetActive(true)
		HideWillGet()
	else
		mBottomHideDesGo:SetActive(false)
		if SDLMgr.CheckIsAllWished() then
			HideWish()
			--只有全部许愿，才显示修改许愿按钮
			ShowChangeBtn()
			ResetChangeBtnState()
			local curDayIdx = SDLMgr.GetCurDayIdx()
			OnClickMiddleItem(curDayIdx + 1)
		else
			firstUnWishedDayIdx = SDLMgr.GetFirstUnWishedDayIdx()
			ShowWish(firstUnWishedDayIdx)
			HideChangeBtn()
		end
	end
end

--获取数据，刷新界面
local function OnGetData()
	ShowMiddle()
	ShowTop()
	ShowBottom()
end

--领奖返回
local function OnGetAward(dayIdx)
	local sdlData = SDLMgr.GetSevenDayLoginData()
	local middleItem = mMiddleItemList[dayIdx]
	local data = sdlData[dayIdx]
	if middleItem and data then
		middleItem:Show(data)
	end
end

--自动寻找下一个可许愿的天
local function AutoSelectForWish()
	local firstUnWishedDayIdx = SDLMgr.GetFirstUnWishedDayIdx()
	if firstUnWishedDayIdx ~= -1 then
		DoShowBottomWishingItem(firstUnWishedDayIdx)
	end
end

--许愿返回
local function OnWish(dayIdx)
	if not dayIdx then
		return
	end
	local sdlData = SDLMgr.GetSevenDayLoginData()
	local middleItem = mMiddleItemList[dayIdx]
	local data = sdlData[dayIdx]
	if middleItem and data then
		middleItem:Show(data)
	end

	--刷新bottom
	if CheckIsChangeingWish() then
		OnClickChangeBtn()
	else
		AutoSelectForWish()		
	end
end

--所有的都已许愿，做UI表现
local function OnAllWished()
	GameLog.LogError("UI_SevenDayLogin.OnAllWished -> all wished")
	ShowBottom()
end

--大礼包领取返回
local function OnGetGift()
	ShowTop()
end

local function RegEvent(self)
	GameEvent.Reg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETDATA, OnGetData)
	GameEvent.Reg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETAWARD, OnGetAward)
	GameEvent.Reg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_ONWISH, OnWish)
	GameEvent.Reg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_ALLWISHED, OnAllWished)
	GameEvent.Reg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETGIFT, OnGetGift)
end

local function UnRegEvent(self)
	GameEvent.UnReg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETDATA, OnGetData)
	GameEvent.UnReg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETAWARD, OnGetAward)
	GameEvent.UnReg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_ONWISH, OnWish)
	GameEvent.UnReg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_ALLWISHED, OnAllWished)
	GameEvent.UnReg(EVT.SUB_G_SEVENDAYLOGIN, EVT.SUB_U_SEVENDAYLOGIN_GETGIFT, OnGetGift)
end

function OnCreate(self)
	mSelf = self
	
	mPanel = self:Find("Offset").parent:GetComponent("UIPanel")
	mTop = self:Find("Offset/top")
	mTopGetBtn = self:FindGo("Offset/top/btn")
	mTopGetBtn:SetActive(false)
	mTopDes = self:FindComponent("UILabel", "Offset/top/tip")
	mTopDesGo = self:FindGo("Offset/top/tip")
	mTopDesGo:SetActive(false)
	local maxFashionNum = SDLMgr.GetFashionClothesNum()
	local trs = nil
	for idx = 1, maxFashionNum do
		trs = self:Find("Offset/top/item" .. idx)
		if not tolua.isnull(trs) then
			mTopItemParentList[idx] = trs
			mTopItemList[idx] = GeneralItem.new(trs, nil)
		end
	end

	mMiddle = self:Find("Offset/middle")
	mMiddleGridTrs = self:Find("Offset/middle/grid")
	mMiddleGrid = self:FindComponent("UIGrid", "Offset/middle/grid")
	mMiddleItem = self:Find("Offset/middle/item")
	mMiddleItem.gameObject:SetActive(false)
	local maxDayIdx = SDLMgr.GetMaxDayIdx()
	local uiEvent
	local childPath = nil
	for idx = 1, maxDayIdx do
		trs = self:DuplicateAndAdd(mMiddleItem, mMiddleGridTrs, 0)
		trs.name = "item" .. tostring(idx)
		childPath = string.format("%s%s%s", "Offset/middle/grid/item", tostring(idx), "/item")
		uiEvent = self:FindComponent("GameCore.UIEvent", childPath)
		uiEvent.id = 50 + idx
		childPath = string.format("%s%s%s", "Offset/middle/grid/item", tostring(idx), "/btn")
		uiEvent = self:FindComponent("GameCore.UIEvent", childPath)
		uiEvent.id = idx
		if not tolua.isnull(trs) then
			mMiddleItemList[idx] = SevenDayLoginMiddleItem.new(self, "Offset/middle/grid/item" .. tostring(idx))
		end
	end
	mMiddleGrid:Reposition()

	mBottom = self:Find("Offset/bottom/wish")
	mBottomWishGo = self:FindGo("Offset/bottom/wish")
	mBottomWishGo:SetActive(false)
    mBottomHideDes = self:FindComponent("UILabel", "Offset/bottom/hidedes")
    mBottomHideDesGo = mBottomHideDes.gameObject
    mBottomHideDesGo:SetActive(false)
	local maxWishItemNum = SDLMgr.GetMaxWishItemNum()
	for idx = 1, 7 do
		trs = self:Find("Offset/bottom/wish/grid/item" .. idx)
		if not tolua.isnull(trs) then
			mBottomItemParentList[idx] = trs
			mBottomItemList[idx] = SevenDayLoginBottomItem.new(self, "Offset/bottom/wish/grid/item" .. idx)
			mBottomItemList[idx]:SetEventId(20+idx);
			if idx > maxWishItemNum then
				mBottomItemList[idx]:Hide()
			end
		end
	end
	self:FindComponent("UILabel","Offset/bottom/chargedes").text=WordData.GetWordStringByKey("welfare_sevenday_xuyuantips3")
	mBottomNextDayGo = self:FindGo("Offset/bottom/nextday")
	mBottomNextDayDes = self:FindComponent("UILabel", "Offset/bottom/nextday/des")
	local mBottomRewardItem = self:Find("Offset/bottom/nextday/Reward")
	mBottomRewardItem:GetComponent("UIEvent").id = mEventType.WillGetItemTip;
	mBottomNextDayItem = GeneralItem.new(mBottomRewardItem, nil)
	mBottomNextDayGo:SetActive(false)
	mBottomChangeLbl = self:FindComponent("UILabel", "Offset/bottom/change/label")
	mBottomChangeGo = self:FindGo("Offset/bottom/change")
	mBottomChangeGo:SetActive(false)
	mBottomWishDes = self:FindComponent("UILabel", "Offset/bottom/wish/title")

end

function OnEnable(self)
	LoadEffect()
	InitUI()
	mCurWishSelect = -1
	mCurGiftSelect = -1
	mCurMiddleItemSelect = -1
	RegEvent(self)
	SDLMgr.SendGetSevenDayData()
end

function OnDisable(self)
	DestroyEffect()
	ResetChangeBtnState()

	mCurWishSelect = - 1
	mCurGiftSelect = -1
	mCurMiddleItemSelect = -1
	
	UnRegEvent(self)
end

function OnClick(go, id)
    if id == mEventType.Close then
        --关闭
        --UIMgr.UnShowUI(AllUI.UI_SevenDayLogin)
	elseif mEventType.SigninItems.IdScopeOfMin <= id and id <= mEventType.SigninItems.IdScopeOfMax then
		--7个签到物品
		OnClickMiddleGetItemBtn(id)
	elseif mEventType.UltimateReward.IdScopeOfMin <= id and id <= mEventType.UltimateReward.IdScopeOfMax then
		--终极奖励物品
		id = id - 10
		OnClickGiftItem(id)
    elseif id == mEventType.ReceiveUltimateReward then
		--领取终极奖励按钮
		OnClickGiftBtn()
	elseif mEventType.WishItems.IdScopeOfMin <= id and id <= mEventType.WishItems.IdScopeOfMax then
		--许愿物品
		id = id - 20
		OnClickWishItem(id)
	elseif mEventType.WillGetItemTip == id then
		if mWillGetItemId > 0 then
			BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromUseItem, mWillGetItemId);
		end
	elseif id == mEventType.Wish then
		--许愿按钮
		OnClickWishBtn()
	elseif id == mEventType.ChangeWish then
		--修改许愿
		OnClickChangeBtn()
	elseif mEventType.SelectMiddleItem.IdScopeOfMin <= id and id <= mEventType.SelectMiddleItem.IdScopeOfMax then
		id = id - 50
		OnClickMiddleItem(id)
	end
end

function OnDestroy(self)
	DestroyEffect()
	DestroyAllTopItem()
	AllMiddleItemOnDestroy()
	AllBottomItemOnDestroy()
end