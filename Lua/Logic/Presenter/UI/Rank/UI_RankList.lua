module("UI_RankList", package.seeall);

local RankList = {};
local FilterList = {};

local mSelf;
local mOffset;
local mEvents = {};
local FirstRankTitleList = {};
local SecondRankTitleList = {};
local FilterItemList = {};

local mRankResaultInfoList = {};

local mSelectFirstRankTitleItemKey = - 1;
local mSelectSecondRankTitleItemKey = - 1;
local mCurrentFilterType = - 1;
local mSelectFilterId = - 1;
local mSelectRankResaultKey = - 1;

local SecondRaknTitlePool = {};
local mFilterItemPool = {};
local mRankResaultItemPool = {};

local mRankFirstLevPrefab;
local mRankSecondLevPrefab;
local mRankInfoPrefab;
local mRankFilterItemPrefab;

local mRankTitleList;
local mRankFilter;
local mRankFilterList;

local mRankResaultTitle1;
local mRankResaultTitle2;
local mRankResaultTitle3;
local mRankResaultTitle4;

local mSelfRankResaultNumLabel;
local mSelfRankResaultNumSprite;

local mSelfRankResault2Table1;
local mSelfRankResault2Table2;
local mSelfRankResault2PlayerHeadPortrait;
local mSelfRankResault2PlayerIcon;
local mSelfRankResault2PlayerLevel;
local mSelfRankResault2Info;
local mSelfRankResault2ServerInfoLabel;
local mSelfRankResault2ServerInfo;

local mSelfRankInfo2;
local mSelfRankInfo3;
local mSelfRankInfo4;

local mWrapCall = nil
local mItemAlign = UITableWrapContent.Align.Top;
local mItemDataAlign = UITableWrapContent.Align.Bottom;

local mRankResaultWrap;
local mRankResalutScrollObj;
local MAX_WRAPSRANK_COUNT = 8;
local mInitRankResaultItemCount;

function OnCreate(self)
	mSelf = self;
	
	mOffset = self:Find("Offset");
	mSharePanel = self:FindComponent("UIPanel", "Offset/RankPanel");
	mRankFirstLevPrefab = self:Find("Offset/RankPanel/RankFirstLevPrefab");
	mRankSecondLevPrefab = self:Find("Offset/RankPanel/RankSecondLevPrefab");
	mRankInfoPrefab = self:Find("Offset/RankPanel/RankResault");
	mRankFilterItemPrefab = self:Find("Offset/RankPanel/RankFilterItemPrefab");
	
	mRankTitleList = self:FindComponent("UITable", "Offset/RankPanel/RankingTitleScrollView/RankingTitleList");
	mRankFilter = self:Find("Offset/RankPanel/RankResaultTable/RankFilter");
	mRankFilterList = self:FindComponent("UITable", "Offset/RankPanel/RankResaultTable/RankFilter/RankFilterListScrollView/RankFilterList");
	
	mRankResaultTitle1 = self:FindComponent("UILabel", "Offset/RankPanel/RankResaultTable/RankResault/RankResaultTitleList/Title1");
	mRankResaultTitle2 = self:FindComponent("UILabel", "Offset/RankPanel/RankResaultTable/RankResault/RankResaultTitleList/Title2");
	mRankResaultTitle3 = self:FindComponent("UILabel", "Offset/RankPanel/RankResaultTable/RankResault/RankResaultTitleList/Title3");
	mRankResaultTitle4 = self:FindComponent("UILabel", "Offset/RankPanel/RankResaultTable/RankResault/RankResaultTitleList/Title4");
	
	mRankResaultWrap = self:FindComponent("UITableWrapContent", "Offset/RankPanel/RankResaultTable/RankResault/RankScrollView/RankWrap");
	mRankResalutScrollObj = self:Find("Offset/RankPanel/RankResaultTable/RankResault/RankScrollView");
	
	mSelfRankResaultNumLabel = self:FindComponent("UILabel", "Offset/RankPanel/RankResault/RankNumLabel");
	mSelfRankResaultNumSprite = self:FindComponent("UISprite", "Offset/RankPanel/RankResault/RankNumSprite");
	
	mSelfRankResault2Table1 = self:FindComponent("UITable", "Offset/RankPanel/RankResault/InfoTable1");
	mSelfRankResault2Table2 = self:FindComponent("UITable", "Offset/RankPanel/RankResault/InfoTable1/Table");
	mSelfRankResault2PlayerHeadPortrait = self:Find("Offset/RankPanel/RankResault/InfoTable1/PlayerHeadPortrait");
	mSelfRankResault2PlayerIcon = self:FindComponent("UISprite", "Offset/RankPanel/RankResault/InfoTable1/PlayerHeadPortrait/Icon");
	mSelfRankResault2PlayerLevel = self:FindComponent("UILabel", "Offset/RankPanel/RankResault/InfoTable1/PlayerHeadPortrait/LevelBg/Label");
	mSelfRankResault2Info = self:FindComponent("UILabel", "Offset/RankPanel/RankResault/InfoTable1/Table/InfoLabel");
	mSelfRankResault2ServerInfoLabel = self:FindComponent("UILabel", "Offset/RankPanel/RankResault/InfoTable1/Table/ServerInfo/ServerInfoLabel");
	mSelfRankResault2ServerInfo = self:Find("Offset/RankPanel/RankResault/InfoTable1/Table/ServerInfo");
	
	mSelfRankInfo3 = self:FindComponent("UILabel", "Offset/RankPanel/RankResault/Info3");
	mSelfRankInfo4 = self:FindComponent("UILabel", "Offset/RankPanel/RankResault/Info4");

	
	mRankFirstLevPrefab.gameObject:SetActive(false);
	mRankSecondLevPrefab.gameObject:SetActive(false);
	mRankFilterItemPrefab.gameObject:SetActive(false);

	RankList = RankMgr.GetRankList();
	InitRankLevList();
	Init();
	
	mWrapCall = UITableWrapContent.OnInitializeItem(OnRankListUpdate);
	--mItemAlign = UITableWrapContent.Align.Top;
	--mItemDataAlign = UITableWrapContent.Align.Bottom;
	
end

function OnEnable(self)
	UIMgr.ShowUI(AllUI.UI_Main_Money);
	
	--展开第一个分组
	SelectFirstRankTitle(100);
	RegEvent(self);
end

function OnDisable(self)
	mSelectFirstRankTitleItemKey = - 1;
	mSelectSecondRankTitleItemKey = - 1;
	mCurrentFilterType = - 1;
	mSelectFilterId = - 1;
	mSelectRankResaultKey = - 1;
	
	UIMgr.UnShowUI(AllUI.UI_Main_Money);
	UnRegEvent(self);
end

function InitRankLevList()
	for k, v in pairs(RankList) do
		local rankTypeItem = {};
		rankTypeItem.key = k;
		rankTypeItem.gameObject = mSelf:DuplicateAndAdd(mRankFirstLevPrefab, mRankTitleList.transform, k).gameObject;
		rankTypeItem.gameObject.name = k;
		rankTypeItem.transform = rankTypeItem.gameObject.transform;
		rankTypeItem.rankLabel = rankTypeItem.transform:Find("RankTitle"):GetComponent("UILabel");
		rankTypeItem.rankLabel.text = v["name"];
		rankTypeItem.Bg = rankTypeItem.transform:Find("Bg"):GetComponent("UISprite");
		--	rankTypeItem.DevelopFlag = rankTypeItem.transform:Find("DevelopFlag"):GetComponent("UISprite");
		rankTypeItem.uiEvent = rankTypeItem.transform:GetComponent("UIEvent");
		rankTypeItem.uiEvent.id = k;
		rankTypeItem.gameObject:SetActive(true);
		FirstRankTitleList[k] = rankTypeItem;
	end
end

function InitWrap()
	mInitRankResaultItemCount = #mRankResaultInfoList;
	mRankResaultWrap:ResetWrapContent(mInitRankResaultItemCount, mWrapCall, mItemAlign, mItemDataAlign, true);
end

function RegEvent(self)
	mEvents[1] = MessageSub.Register(GameConfig.SUB_G_RANK, GameConfig.SUB_U_RANK_UPDATERESAULT, UpdateRankResaultLsit);
	mEvents[2] = MessageSub.Register(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_SWITCHSHARELAYER, SwitchRankPanelToShareLayer);
end

function UnRegEvent(self)
	MessageSub.UnRegister(GameConfig.SUB_G_RANK, GameConfig.SUB_U_RANK_UPDATERESAULT, mEvents[1]);
	MessageSub.UnRegister(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_SWITCHSHARELAYER, mEvents[2]);
end

function Init()
	for i = 1, 10 do
		local secondRankTitleItem = {};
		secondRankTitleItem.gameObject = mSelf:DuplicateAndAdd(mRankSecondLevPrefab, mRankTitleList.transform, i).gameObject;
		secondRankTitleItem.transform = secondRankTitleItem.gameObject.transform;
		secondRankTitleItem.rankLabel = secondRankTitleItem.transform:Find("RankTitle"):GetComponent("UILabel");
		secondRankTitleItem.Bg = secondRankTitleItem.transform:Find("Bg"):GetComponent("UISprite");
		secondRankTitleItem.uiEvent = secondRankTitleItem.transform:GetComponent("UIEvent");
		SecondRaknTitlePool[i] = {key = - 1, value = secondRankTitleItem};
	end
	
	for i = 1, 10 do
		local filterItem = {};
		filterItem.gameObject = mSelf:DuplicateAndAdd(mRankFilterItemPrefab, mRankFilterList.transform, i).gameObject;
		filterItem.transform = filterItem.gameObject.transform;
		filterItem.filterName = filterItem.transform:Find("FilterLabel"):GetComponent("UILabel");
		filterItem.SelectFlag = filterItem.transform:Find("SelectedBg"):GetComponent("UISprite");
		filterItem.SelectFlag.gameObject:SetActive(false);
		filterItem.uiEvent = filterItem.transform:GetComponent("UIEvent");
		--筛选项的id从11开始，取余进行判断
		filterItem.uiEvent.id = - 1;
		mFilterItemPool[i] = {key = - 1, value = filterItem};
	end
	
	for i = 1, MAX_WRAPSRANK_COUNT do
		local rankResaultItem = {};
		rankResaultItem.gameObject = mSelf:DuplicateAndAdd(mRankInfoPrefab, mRankResaultWrap.transform, i).gameObject;
		rankResaultItem.gameObject.name = i;
		rankResaultItem.transform = rankResaultItem.gameObject.transform;
		rankResaultItem.Bg = rankResaultItem.transform:GetComponent("UISprite");
		rankResaultItem.selfFlag = rankResaultItem.transform:Find("SelfFlag");
		rankResaultItem.rankNumSprite = rankResaultItem.transform:Find("RankNumSprite"):GetComponent("UISprite");
		rankResaultItem.rankNumLabel = rankResaultItem.transform:Find("RankNumLabel"):GetComponent("UILabel");
		rankResaultItem.info3 = rankResaultItem.transform:Find("Info3"):GetComponent("UILabel");
		rankResaultItem.info4 = rankResaultItem.transform:Find("Info4"):GetComponent("UILabel");
		rankResaultItem.infoTable1 = rankResaultItem.transform:Find("InfoTable1"):GetComponent("UITable");
		rankResaultItem.infoTable2 = rankResaultItem.transform:Find("InfoTable1/Table"):GetComponent("UITable");
		rankResaultItem.playerHeadPortrait = rankResaultItem.infoTable1.transform:Find("PlayerHeadPortrait");
		rankResaultItem.playerIcon = rankResaultItem.playerHeadPortrait:Find("Icon"):GetComponent("UISprite");
		rankResaultItem.playerLevLabel = rankResaultItem.playerHeadPortrait:Find("LevelBg/Label"):GetComponent("UILabel");
		rankResaultItem.info2 = rankResaultItem.transform:Find("InfoTable1/Table/InfoLabel"):GetComponent("UILabel");
		rankResaultItem.serverInfoLabel = rankResaultItem.transform:Find("InfoTable1/Table/ServerInfo/ServerInfoLabel"):GetComponent("UILabel");
		rankResaultItem.serverInfo = rankResaultItem.transform:Find("InfoTable1/Table/ServerInfo");
		rankResaultItem.shareBtn = rankResaultItem.transform:Find("ShareBtn");
		rankResaultItem.uiEvent = rankResaultItem.transform:GetComponent("UIEvent");
		rankResaultItem.shareBtn.gameObject:SetActive(false);
		mRankResaultItemPool[i] = rankResaultItem;
	end
end

function SelectFirstRankTitle(key)
	if key ~= mSelectFirstRankTitleItemKey then
		if mSelectFirstRankTitleItemKey ~= - 1 then
			local beforeSelectItem = FirstRankTitleList[mSelectFirstRankTitleItemKey];
			beforeSelectItem.Bg.spriteName = "button_common_09";
			--beforeSelectItem.DevelopFlag.gameObject.transform.localEulerAngles  = Vector3.New(0,0,90);
		end
		
		local selectFirstRankTitleItem = FirstRankTitleList[key];
		selectFirstRankTitleItem.Bg.spriteName = "button_common_10";
		--	selectFirstRankTitleItem.DevelopFlag.gameObject.transform.localEulerAngles  = Vector3.New(0,0,-90);
		mSelectFirstRankTitleItemKey = key;
		ShowSceconRankTitleList(key);
		--选中一级标签下的默认二级标签
		local defaultKey = RankMgr.FindDefaultSecondRankTitleKey(key);
		SelectSecondRankTitle(defaultKey);
	else
		local beforeSelectItem = FirstRankTitleList[mSelectFirstRankTitleItemKey];
		beforeSelectItem.Bg.spriteName = "button_common_09";
		--	beforeSelectItem.DevelopFlag.gameObject.transform.localEulerAngles  = Vector3.New(0,0,90);
		UnShowSecondRankTitleList();
		
		mSelectFirstRankTitleItemKey = - 1;
		mSelectSecondRankTitleItemKey = - 1;
	end
	
end

function ShowSceconRankTitleList(parentKey)
	UnShowSecondRankTitleList();
	mSelectSecondRankTitleItemKey = - 1;
	
	for k, v in pairs(RankList) do
		if k == parentKey then
			local childList = v["childList"];
			local index = 1;
			for r, n in pairs(childList) do
				local secondRankTitleItem = SecondRaknTitlePool[index];
				secondRankTitleItem["key"] = r;
				secondRankTitleItem["value"].gameObject.name = r;
				secondRankTitleItem["value"].rankLabel.text = n;
				secondRankTitleItem["value"].uiEvent.id = r;
				secondRankTitleItem["value"].gameObject:SetActive(true);
				SecondRankTitleList[index] = secondRankTitleItem;
				index = index + 1;
			end
			mRankTitleList:Reposition();
		end
	end
end

function UnShowSecondRankTitleList()
	if mSelectSecondRankTitleItemKey ~= - 1 then
		local beforeSelectRankTitleItem = FindShowingSecondRankTitleByKey(mSelectSecondRankTitleItemKey);
		if beforeSelectRankTitleItem ~= nil then
			beforeSelectRankTitleItem.Bg.spriteName = "button_common_12"
		end
		mSelectSecondRankTitleItemKey = - 1;
	end
	
	for i = #SecondRankTitleList, 1, - 1 do
		SecondRankTitleList[i] ["value"].gameObject:SetActive(false);
		table.remove(SecondRankTitleList, i);
	end
	mRankTitleList:Reposition();	
end

function SelectSecondRankTitle(key)
	if mSelectSecondRankTitleItemKey == key then
		return;
	end
	
	--清空之前的选择状态
	if mSelectSecondRankTitleItemKey ~= - 1 then
		local beforeSelectRankTitleItem = FindShowingSecondRankTitleByKey(mSelectSecondRankTitleItemKey);
		if beforeSelectRankTitleItem ~= nil then
			beforeSelectRankTitleItem.Bg.spriteName = "button_common_12"
		end
	end
	
	for i, v in ipairs(SecondRankTitleList) do
		if v["key"] == key then
			v["value"].Bg.spriteName = "button_common_11";
		end
	end
	
	mSelectSecondRankTitleItemKey = key;
	local rankInfo = RankMgr.GetRankInfoById(key);
	if rankInfo ~= nil then
		if rankInfo.rankProType == RankInfo_pb.RankType_Power then
			SetResaultTitle(rankInfo);
			ResetFilterList(rankInfo.filterType);
			Rank();
		else
			TipsMgr.TipByKey("equip_share_not_support");
		end
	end
end

function Rank()
	local rankInfo = RankMgr.GetRankInfoById(mSelectSecondRankTitleItemKey);
	local currentFilterIndex = GetCurrentFilterIndex();
	RankMgr.RequestRankListToServer(rankInfo, currentFilterIndex);
end

function GetCurrentFilterIndex()
	local currentFilterIndex = - 1;
	for k, v in pairs(FilterItemList) do
		if v.key == mSelectFilterId then
			currentFilterIndex = k;
			break;
		end
	end
	return currentFilterIndex;
end

function OnClick(go, id)
	if id == 0 then
		--退出
		UIMgr.UnShowUI(AllUI.UI_RankList);
	elseif id == 1 then
		--分享
		ShareRankList();
	elseif id >= 100 and id < 3000 then
		if id % 100 == 0 then
			SelectFirstRankTitle(id);
		else
			SelectSecondRankTitle(id);
		end
	elseif id >= 10 and id < 100 then
		SelectRankFilter(id);
		Rank();
	elseif id > 3000 then
		--排行条目被点击了
		TipsMgr.TipByKey("equip_share_not_support");
	end
end

function ShareRankList()
	ShareMgr.SetShareManagerParent(mOffset.transform);
	SwitchRankPanelToShareLayer(true);
	UIMgr.ShowUI(AllUI.UI_Tip_Share, mSelf, nil, nil, nil, true, mSharePanel.sortingOrder);
	ShareMgr.CaptureCamera();
end

function FindShowingSecondRankTitleByKey(key)
	for i, v in ipairs(SecondRankTitleList) do
		if v["key"] == key then
			return v["value"];
		end
	end
	return nil;
end

function SetResaultTitle(rankInfo)
	mRankResaultTitle1.text = rankInfo.resault1;
	mRankResaultTitle2.text = rankInfo.resault2;
	mRankResaultTitle3.text = rankInfo.resault3;
	mRankResaultTitle4.text = rankInfo.resault4;
end

function ResetFilterList(filterTypeId)
	if mCurrentFilterType ~= filterTypeId then
		ClearFilterList();			
		FilterList = RankMgr.GetFilterListByFilterType(filterTypeId);
		for index, value in pairs(FilterList) do
			local filterItem = mFilterItemPool[index];
			filterItem.key = value.id;
			filterItem.value.gameObject:SetActive(true);
			filterItem.value.filterName.text = value.name;
			filterItem.value.uiEvent.id = value.id;
			FilterItemList[index] = filterItem;
		end
		SelectDefaultFilter();
		mCurrentFilterType = filterTypeId;
	else
		SelectDefaultFilter();
	end
end

function ClearFilterList()
	ResetSelectedRankFilter();
	for i = #FilterItemList, 1, - 1 do
		FilterItemList[i] ["value"].gameObject:SetActive(false);
		table.remove(FilterItemList, i);
	end
	--mRankFilterList:Reposition();
end

function SelectDefaultFilter()
	for index, value in pairs(FilterItemList) do
		if index == 1 then
			SelectRankFilter(value.key);
			break;
		end
	end
end

function SelectRankFilter(filterId)
	ResetSelectedRankFilter();
	for k, v in pairs(FilterItemList) do
		if v.key == filterId then
			v.value.SelectFlag.gameObject:SetActive(true);
			mSelectFilterId = filterId;
		end
	end
end

function ResetSelectedRankFilter()
	if mSelectFilterId ~= - 1 then
		for k, v in pairs(FilterItemList) do
			if v.key == mSelectFilterId then
				v.value.SelectFlag.gameObject:SetActive(false);
				mSelectFilterId = - 1;
				break;
			end
		end
	end
end

function OnRankListUpdate(go, index, realIndex)
	if realIndex >= 0 and realIndex < mInitRankResaultItemCount then
		go:SetActive(true);
		SetRankItemInfo(index + 1, realIndex + 1);
	else
		go:SetActive(false);
	end
end

function SetRankItemInfo(rankItemPoolInedx, rankInfoListIndex)
	local rankItem = mRankResaultItemPool[rankItemPoolInedx];
	local rankInfo = mRankResaultInfoList[rankInfoListIndex];
	if rankItem and rankInfo then
		if rankInfoListIndex == 1 then
			rankItem.rankNumSprite.gameObject:SetActive(true);
			rankItem.rankNumSprite.spriteName = "img_paihangbang_paizi01";
			rankItem.Bg.spriteName = "frame_common_15";
		elseif rankInfoListIndex == 2 then
			rankItem.rankNumSprite.gameObject:SetActive(true);
			rankItem.rankNumSprite.spriteName = "img_paihangbang_paizi02";
			rankItem.Bg.spriteName = "frame_common_16";
		elseif rankInfoListIndex == 3 then
			rankItem.rankNumSprite.gameObject:SetActive(true);
			rankItem.rankNumSprite.spriteName = "img_paihangbang_paizi03";
			rankItem.Bg.spriteName = "frame_common_17";
		else
			rankItem.rankNumSprite.gameObject:SetActive(false);
			rankItem.rankNumLabel.text = rankInfoListIndex;
			if rankInfoListIndex % 2 == 0 then
				rankItem.Bg.spriteName = "frame_common_12";
			else	
				rankItem.Bg.spriteName = "frame_common_14";
			end
		end
		
		rankItem.selfFlag.gameObject:SetActive(rankInfo.selfFlag);
		rankItem.playerHeadPortrait.gameObject:SetActive(false);
		--info2.height = 74;
		--info2.height = 36;
		rankItem.serverInfo.gameObject:SetActive(false);
		--rankItem.infoTable2:Reposition();
		--rankItem.infoTable1:Reposition();
		
		rankItem.info2.text = rankInfo.info1;
		rankItem.info3.text = rankInfo.info2;
		rankItem.info4.text = rankInfo.info3;
		
		rankItem.uiEvent.id = 3000 + rankInfoListIndex;
	end
end

function UpdateRankResaultLsit()
	local rankResaultInfo = RankMgr.GetRankResault();
	local currentFilterIndex = GetCurrentFilterIndex();
	if mSelectSecondRankTitleItemKey ~= rankResaultInfo.RankId or currentFilterIndex ~= rankResaultInfo.para2 + 1 then
		return;
	end
	ParseRankResaultList(rankResaultInfo)
	InitWrap();
end

function ParseRankResaultList(serverInfo)
	local serverList = serverInfo.list;
	mRankResaultInfoList = {};
	local selfRankNum = - 1;
	local isContentSelf = false;
	
	if serverInfo.type == RankInfo_pb.RankType_Power or serverInfo.type == RankInfo_pb.RankType_Lvl then
		
		mSelfRankResault2PlayerHeadPortrait.gameObject:SetActive(false);
		mSelfRankResault2ServerInfo.gameObject:SetActive(false);
		--mSelfRankResault2Table2:Reposition();
		--mSelfRankResault2Table1:Reposition();
		
		
		--解析列表
		local selfRoleId = UserData.PlayerID;
		
		for index, value in pairs(serverList) do
			local rankItemInfo = {};
			rankItemInfo.info1 = value.info1;
			
			local professionIndex = tonumber(value.info2);
			rankItemInfo.info2 = GetProfessionNameById(professionIndex);
			
			rankItemInfo.info3 = value.info3;
			rankItemInfo.roleID = value.roleID;
			rankItemInfo.selfFlag = false;
			
			if selfRoleId == tonumber(value.roleID) then
				selfRankNum = index;
				rankItemInfo.selfFlag = true;
				isContentSelf = true;
				
				--设置玩家信息
				mSelfRankResault2Info.text = rankItemInfo.info1;
				mSelfRankInfo3.text = rankItemInfo.info2;
				mSelfRankInfo4.text = rankItemInfo.info3;
			end
			mRankResaultInfoList[index] = rankItemInfo;
		end
		
		if isContentSelf == false then
			--设置玩家信息
			mSelfRankResault2Info.text = UserData.GetName();
			mSelfRankInfo3.text = GetProfessionNameById(UserData.GetProfession());
			mSelfRankInfo4.text = "123456";
		end
	end
	
	mSelfRankResaultNumSprite.gameObject:SetActive(false);
	--设置玩家排名
	if selfRankNum ~= - 1 then
		if selfRankNum == 1 then
			mSelfRankResaultNumSprite.gameObject:SetActive(true);
			mSelfRankResaultNumSprite.spriteName = "img_paihangbang_paizi01";
		elseif selfRankNum == 2 then
			mSelfRankResaultNumSprite.gameObject:SetActive(true);
			mSelfRankResaultNumSprite.spriteName = "img_paihangbang_paizi02";
		elseif selfRankNum == 3 then
			mSelfRankResaultNumSprite.gameObject:SetActive(true);
			mSelfRankResaultNumSprite.spriteName = "img_paihangbang_paizi03";
		else
			mSelfRankResaultNumSprite.gameObject:SetActive(false);
			mSelfRankResaultNumLabel.text = selfRankNum;
		end
	else
		mSelfRankResaultNumLabel.text = "榜外";
	end
end

function GetProfessionNameById(id)
	local professionName = "";
	if id == Common_pb.PROFESSION_ZHIGE then
		professionName = "止戈"
	elseif id == Common_pb.PROFESSION_YINGCHA then
		professionName = "影刹"
	elseif id == Common_pb.PROFESSION_TIANJUE then
		professionName = "天诀"
	elseif id == Common_pb.PROFESSION_CHUANYUN then
		professionName = "穿云"
	elseif id == Common_pb.PROFESSION_XINGLIN then	
		professionName = "杏林"
	end
	return professionName;
end

function SwitchRankPanelToShareLayer(isShareLayer)
	if isShareLayer then
		--NGUITools.SetLayer(mSharePanel.gameObject, 26);
		--NGUITools.SetChildLayer(mSharePanel.transform, 26);
		GameUtil.GameFunc.SetGameObjectLayer(mSharePanel.transform, CameraLayer.ShareLayer);
	else
		--NGUITools.SetLayer(mSharePanel.gameObject, 5);
		--NGUITools.SetChildLayer(mSharePanel.transform, 5);
		GameUtil.GameFunc.SetGameObjectLayer(mSharePanel.transform, CameraLayer.UILayer);
	end
end


