module("VitalityMgr", package.seeall);

local mCurrentVitalityValue = 0;
local mCustomRecommendList = {};
local mAwardGetFlagList = {};

local mRecommendActivityList = {};
local mDailayActivityList = {};
local mChallengeActivityList = {};
local mArderActivityList = {};
local mActivityNetData = {};

local mImageItemList = {};
local mColorFitImageItemList = {};

local mImgContentAreaList = {};
local mImgContentSearchList = {};

local mCurrentColorId = -1;
local mActivityImagePage = 1;
local mInitFillItemIdList = {};
local mColorItemList = {};

local mRequestList = {};

function GetActivityItemInfoByTypet(activityType)
	return ActivityData.GetActivityItemInfoByType(activityType);
end

function GetActivityItemInfoById(activityId)
	return ActivityData.GetActivityItemInfoById(activityId);
end

function GetActivityItemInfos()
	return ActivityData.GetActivityItemInfos();
end

function GetVitalityItemInfos()
	return ActivityData.GetVitalityInfo();
end

function GetRecommendActivityList()

	--遍历日常活动列表
	if next(mRecommendActivityList) == nil then
		--[[
		local dailyActivityList = GetDailyActivityList();
		for k, v in ipairs(dailyActivityList) do
			if v.recommendatory == true then
				table.insert(mRecommendActivityList, v);
			end
		end
		--遍历挑战活动列表
		local challengeActivityList = GetChallengeActivityList();
		for k, v in ipairs(challengeActivityList) do
			if v.recommendatory == true then
				table.insert(mRecommendActivityList, v);
			end
		end
		--遍历休闲竞技列表
		local arderActivityList = GetArderActivityList();
		for k, v in ipairs(arderActivityList) do
			if v.recommendatory == true then
				table.insert(mRecommendActivityList, v);
			end
		end
		]]
		--添加自定义推荐活动
		for k, v in ipairs(mCustomRecommendList) do
			local activityInfo = GetActivityItemInfoById(v);
			if activityInfo then
				table.insert(mRecommendActivityList, activityInfo);
			end
		end
	end
	return mRecommendActivityList;
end

function GetDailyActivityList()
	if next(mDailayActivityList) == nil then
		mDailayActivityList = GetActivityItemInfoByTypet(ActivityInfo_pb.ActivityItemInfo.DailyActivityType);
	end
	return mDailayActivityList;
end

function GetChallengeActivityList()
	if next(mChallengeActivityList) == nil then
		mChallengeActivityList = GetActivityItemInfoByTypet(ActivityInfo_pb.ActivityItemInfo.ChallengeActivityType);
	end
	return mChallengeActivityList;
end

function GetArderActivityList()
	if next(mArderActivityList) == nil then
		mArderActivityList = GetActivityItemInfoByTypet(ActivityInfo_pb.ActivityItemInfo.ArderActivityType);
	end
	return mArderActivityList;
end

function GetActivityNetData()
	if next(mActivityNetData) == nil then
		--获取活动服务器数据
	end
	return mActivityNetData;
end

function OnSetAitalityInfo(msg)
	mCurrentVitalityValue = msg.value;
	ParseAwardGetFlagInfo(msg.drawflag);
	if msg.recommend ~= nil then
		for k, v in ipairs(msg.recommend) do
			table.insert(mCustomRecommendList, v);
		end
	end
	mActivityImagePage = msg.data.progress;
	if mActivityImagePage == 0 then
		mActivityImagePage = 1;
	end
	for k, v in ipairs(msg.data.data.list) do
		table.insert(mInitFillItemIdList, v);
	end
	for k, v in ipairs(msg.data.itemlist) do
		table.insert(mColorItemList, v)
	end
end

function OnGetVitalityAward(msg)
	if msg.ret ~= 0 then return; end
	--获得奖励
	for k, v in ipairs(msg.prize.itemlist) do
		local itemData = ItemData.GetItemInfo(v.itemid);
		local content = string.format(WordData.GetWordStringByKey("drop_item"), itemData.name, 1);
		TipsMgr.TipCommon(content, itemData);
	end
	MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_GET_AWARD, msg.drawid);
end

function OnActivityComplete(msg)
	--活动完成
	local activityId = msg.activityid;
	local changeValue = msg.changevalue;
	
	mCurrentVitalityValue = mCurrentVitalityValue + changeValue;
	MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_VALUE_CHANGE);
end

--向服务器发送完成活动消息
function CompleteActivity(activityId)
	local msg = NetCS_pb.CSActivityEnd();
	msg.activityid = activityId;
	GameNet.SendToGate(msg);
end

--向服务器发型领取奖励消息
function GetAward(vitalityId)
	local msg = NetCS_pb.CSActivityDrawValue();
	msg.drawid = vitalityId;
	GameNet.SendToGate(msg);
end

--向服务器发送加入/移除推荐活动
function AddOrRemoveRecommendActivity(activityId, isAdd)
	local msg = NetCS_pb.CSActivityUpdateRecommend();
	msg.activityid = activityId;
	msg.isAdd = isAdd;
	GameNet.SendToGate(msg);
end

function GetCurrentVitalityValue()
	return mCurrentVitalityValue;
end

function ResetAwardGetFlagList()
	local vitalityItemList = GetVitalityItemInfos();
	for k, v in ipairs(vitalityItemList) do
		mAwardGetFlagList[k] = 0;
	end
end

function ParseAwardGetFlagInfo(flagInfo)
	local currentFlag = flagInfo;
	local startNum = #mAwardGetFlagList - 1;
	while startNum >= 0 do
		if currentFlag >= Mathf.Pow(2, startNum) then
			mAwardGetFlagList[startNum + 1] = 1;
			currentFlag = currentFlag - Mathf.Pow(2, startNum);
		else
			mAwardGetFlagList[startNum + 1] = 0;
		end
		startNum = startNum - 1;
	end
end

function GetAwardGetFlagInfo()
	return mAwardGetFlagList;
end

function InitModule()
	ResetAwardGetFlagList();
end

function SetAwardGetFlagInfo(index, isGet)
	if mAwardGetFlagList[index] ~= nil then
		if isGet then
			mAwardGetFlagList[index] = 1;
		else
			mAwardGetFlagList[index] = 0;
		end
	end
end

function GetActivityIsInCustRecList(activityId)
	for k, v in ipairs(mCustomRecommendList) do
		if v == activityId then
			return true;
		end
	end
	return false;
end

function OnRecommendActivityUpdated(msg)
	local activityId = msg.activityid;
	local isAdd = msg.isAdd;
	
	local findFlag = false;
	local pos = nil;
	for k, v in ipairs(mCustomRecommendList) do
		if v == activityId then
			findFlag = true;
			pos = k;
		end
	end
	if isAdd then
		if not findFlag then
			
			local activityInfo = GetActivityItemInfoById(activityId);
			if activityInfo then
				table.insert(mCustomRecommendList, activityId);
				table.insert(mRecommendActivityList, activityInfo);
				TipsMgr.TipByKey("Activity_in_success");
				MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RECOMMEND_UPDATE, info);
			end
		end
	else
		if findFlag then
			table.remove(mCustomRecommendList, pos);
			
			local recommendActivityListPos = - 1;
			for k, v in ipairs(mRecommendActivityList) do
				if v.id == activityId then
					recommendActivityListPos = k;
					break;
				end
			end
			if recommendActivityListPos ~= - 1 then
				table.remove(mRecommendActivityList, recommendActivityListPos);
			end
			TipsMgr.TipByKey("Activity_out_success");
			MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RECOMMEND_UPDATE, info);
		end
	end
end

function SelectImageContentItem(VIndex, HIndex)
	if mColorFitImageItemList[VIndex] then
		if mColorFitImageItemList[VIndex] [HIndex] and mColorFitImageItemList[VIndex] [HIndex].isFill == false and mColorFitImageItemList[VIndex] [HIndex].colorIndex == mCurrentColorId then
			FillArea(VIndex, HIndex);
		end
	end
end

function FillArea(VIndex, HIndex)
	mImgContentAreaList = {};
	mImgContentAreaList = {};
	
	local selectContentItem = {};
	selectContentItem.vIndex = VIndex;
	selectContentItem.hIndex = HIndex;
	selectContentItem.item = mColorFitImageItemList[VIndex] [HIndex];
	table.insert(mImgContentAreaList, selectContentItem);
	
	local posInfo = {};
	posInfo.vIndex = VIndex;
	posInfo.hIndex = HIndex;
	table.insert(mImgContentSearchList, posInfo);
	
	FindArea(VIndex, HIndex);
	mImgContentSearchList = {};
	
	table.sort(mImgContentAreaList, function(a, b)
		if a.vIndex ~= b.vIndex then
			return a.vIndex < b.vIndex;
		else	
			return a.hIndex < b.hIndex
		end
	end)
	local colorItemCount = 0;
	for k, v in ipairs(mColorItemList) do
		if k == mCurrentColorId then
			colorItemCount = v;
		end
	end
	
	if colorItemCount <= 0 then
		--色块数量不足，直接返回
		return;
	end
	
	local netImageItemIndexList = {};
	local imageFillItemLsit = {};
	for k, v in ipairs(mImgContentAreaList) do
		local imageFillInfo = {};
		imageFillInfo.vIndex = v.vIndex;
		imageFillInfo.hIndex = v.hIndex;
		--获取颜色信息
		local imageItemColorInfo = ActivityData.GetVitalityColorInfoById(v.item.colorIndex);
		imageFillInfo.color = imageItemColorInfo.colorValue;
		
		table.insert(imageFillItemLsit, imageFillInfo);
		table.insert(netImageItemIndexList, v.item.index);
		
		colorItemCount = colorItemCount - 1;
		if colorItemCount <= 0 then
			break;
		end
	end
	
	local netData = ActivityInfo_pb.ActivityPicData();
	for k, v in ipairs(netImageItemIndexList) do
		netData.list:append(v);
	end
	--netData.list = netImageItemIndexList;
	local msg = NetCS_pb.CSActivitySavePic();
	msg.iscomplete = false;
	msg.progress = mActivityImagePage;
	msg.data:ParseFrom(netData)
	GameNet.SendToGate(msg);
	
	table.insert(mRequestList, imageFillItemLsit);
end

function OnGetFillImageArea(msg)
	if msg.ret ~= 0 then return; end

	local colorItemUse = msg.data.itemlist;
	--服务器返回成功
	if next(mRequestList) then
		local imageFillList = mRequestList[1];
		for k, v in ipairs(imageFillList) do
			mImageItemList[v.vIndex] [v.hIndex].isFill = true;
			mColorFitImageItemList[v.vIndex] [v.hIndex].isFill = true;
			table.insert(mInitFillItemIdList, mImageItemList[v.vIndex] [v.hIndex].index);
		end
		MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_FILL_IMAGE, imageFillList);
		table.remove(mRequestList, 1);
		
		local colorItemUseList = colorItemUse;
		local infoList = {};
		for k, v in ipairs(colorItemUseList) do
			if mColorItemList[v.itemid] then
				local count = mColorItemList[v.itemid] - v.count;
				mColorItemList[v.itemid] = count;
				local colorItem = {};
				colorItem.id = v.itemid;
				colorItem.count = count;
				table.insert(infoList, colorItem);
			end
		end
		MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_UPDATE_COLOR_COUNT, infoList);
	end
end

function FindArea(VIndex, HIndex)
	for i = VIndex - 1, VIndex + 1 do
		for k = HIndex - 1, HIndex + 1 do
			local isSearched = false;
			for r, v in ipairs(mImgContentSearchList) do
				if i == v.vIndex and k == v.hIndex then
					isSearched = true;
				end
			end
			if not isSearched then
				local posInfo = {};
				posInfo.vIndex = i;
				posInfo.hIndex = k;
				table.insert(mImgContentSearchList, posInfo);
				if mColorFitImageItemList[i] then
					if mColorFitImageItemList[i] [k] and mColorFitImageItemList[i] [k].isFill == false then
						local selectContentItem = {};
						selectContentItem.vIndex = i;
						selectContentItem.hIndex = k;
						selectContentItem.item = mColorFitImageItemList[i] [k];
						table.insert(mImgContentAreaList, selectContentItem);
						FindArea(i, k);
					end
				end
			end
		end
	end
end

function InitActivityImage()
	if mActivityImagePage == 0 then
		mActivityImagePage = 1;
	end
	local activityImageId = mActivityImagePage;
	local activityImageInfo = ActivityData.GetActivityImageById(activityImageId);
	local imageInitList = {};
	for k, v in ipairs(activityImageInfo.contentList) do
		if mImageItemList[v.Y] == nil then
			mImageItemList[v.Y] = {};
		end
		local item = {};
		item.colorIndex = v.ColorItemId;
		item.index = k - 1;
		--获取网络数据，初始化填充列表
		local itemIsFill = false;
		for r, m in ipairs(mInitFillItemIdList) do
			if m == item.index then
				itemIsFill = true;
				break;
			end
		end
		item.isFill = itemIsFill;
		mImageItemList[v.Y] [v.X] = item;
		
		local imageInitInfo = {};
		imageInitInfo.vIndex = v.Y;
		imageInitInfo.hIndex = v.X;
		imageInitInfo.isFill = itemIsFill;
		local imageItemColorInfo = ActivityData.GetVitalityColorInfoById(v.ColorItemId);
		imageInitInfo.colorInfo = imageItemColorInfo;
		table.insert(imageInitList, imageInitInfo);
	end
	MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_IMAGE_INIT, imageInitList);
end

function FillColorFitImageItemList(colorId)
	mCurrentColorId = colorId;
	ClearColorFitImageItemList();
	if colorId == -1 then return end
	local colorFitItemList = {};
	for i = 1, table.maxn(mImageItemList) do
		if mImageItemList[i] then
			for k = 1, table.maxn(mImageItemList[i]) do
				if mImageItemList[i] [k] then
					if mImageItemList[i] [k].colorIndex == colorId and mImageItemList[i] [k].isFill == false then
						mColorFitImageItemList[i] = mColorFitImageItemList[i] or {};
						mColorFitImageItemList[i] [k] = mImageItemList[i] [k];
						
						local colorFitItem = {};
						colorFitItem.vIndex = i;
						colorFitItem.hIndex = k;
						table.insert(colorFitItemList, colorFitItem);
					end
				end
			end
		end
	end
	MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_UPDATE_SELECT_FLAG, true, colorFitItemList);
end

function ClearColorFitImageItemList()
	local colorFitItemList = {};
	for i = 1, table.maxn(mColorFitImageItemList) do
		if mColorFitImageItemList[i] then
			for k = 1, table.maxn(mColorFitImageItemList[i]) do
				if mColorFitImageItemList[i] [k] then
					if mColorFitImageItemList[i] [k].isFill == false then
						local colorFitItem = {};
						colorFitItem.vIndex = i;
						colorFitItem.hIndex = k;
						table.insert(colorFitItemList, colorFitItem);
					end
				end
			end
		end
	end
	mColorFitImageItemList = {};
	MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_UPDATE_SELECT_FLAG, false, colorFitItemList);
end

function GetAllVitalityColorInfo()
	return ActivityData.GetVitalityColorInfos();
end

function GetCurrentPage()
	return mActivityImagePage;
end

function OnInitColorItemList(msg)
    local colorItemList = {};
    colorItemList = msg.data.itemlist;
	
	local infoList = {};
	for k, v in ipairs(colorItemList) do
		mColorItemList[v.itemid] = v.count;
		local colorItem = {};
		colorItem.id = v.itemid;
		colorItem.count = v.count;
		table.insert(infoList, colorItem);
	end
	MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_UPDATE_COLOR_COUNT, infoList);
end

function GetColorItemList()
	return mColorItemList;
end

function OnResetVitality(msg)
	mCurrentVitalityValue = msg.value;
	ParseAwardGetFlagInfo(msg.flag);
	MessageSub.SendMessage(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_RESET_VITALITY);
end

return VitalityMgr; 