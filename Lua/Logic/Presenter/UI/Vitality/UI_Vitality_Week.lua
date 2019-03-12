module("UI_Vitality_Week", package.seeall);

local mSelf;
local mEvents = {};
local mOffset;

local mCurrentSelectColorItemId = - 1;

local NumberText = {
	[1] = "Activity_index_one",
	[2] = "Activity_index_two",
	[3] = "Activity_index_three",
	[4] = "Activity_index_four",
	[5] = "Activity_index_five",
	[6] = "Activity_index_six",
	[7] = "Activity_index_seven",
	[8] = "Activity_index_eight",
	[9] = "Activity_index_nine",
	[10] = "Activity_index_ten",
};

local mMainPage;
local mOtherPageList = {};
local mOtherPage01;
local mOtherPage02;
local mOtherPage03;
local mOtherPage04;

local mMainPageTitleBg;
local mMainPageContentBg;
local mOtherPageBg01;
local mOtherPageBg02;
local mOtherPageBg03;
local mOtherPageBg04;

local mMianContentBgTexture;
local mContentItemGrid;

local mMainTitleLabel;
local mOtherPageTitle01;
local mOtherPageTitle02;
local mOtherPageTitle03;
local mOtherPageTitle04;

local mColorItemPrefab;
local mColorScrollViewTable;

local mSharePanel;

local mCurrentPageIndex;
local mPageRealIndex;

local mContentItemList = {};
local ITEM_MAX_HOR_COUNT = 37;
local ITEM_MAX_VER_COUNT = 19;
local PAGE_MAX_COUNT = 10;

local MAIN_PAGE_WIDTH = 857;
local OTHER_PAGE_WIDTH = 51;

local MAX_PAGE_NUMBER = 10;
local MAX_PAGE_SHOW_NUMBER = 5;

local mColorItemList = {};

function OnCreate(self)
	mSelf = self;
	mOtherPageList[1] = {};
	mOtherPageList[2] = {};
	mOtherPageList[3] = {};
	mOtherPageList[4] = {};
	
	mOffset = self:Find("Offset");
	mSharePanel = mOffset.parent:GetComponent("UIPanel");
	
	mMainPage = self:Find("Offset/PageList/MainPage");
	mOtherPage01 = self:Find("Offset/PageList/OtherPageObj01");
	mOtherPage02 = self:Find("Offset/PageList/OtherPageObj02");
	mOtherPage03 = self:Find("Offset/PageList/OtherPageObj03");
	mOtherPage04 = self:Find("Offset/PageList/OtherPageObj04");
	mOtherPageList[1].PagaObj = mOtherPage01;
	mOtherPageList[2].PagaObj = mOtherPage02;
	mOtherPageList[3].PagaObj = mOtherPage03;
	mOtherPageList[4].PagaObj = mOtherPage04;
	
	mMainPageTitleBg = self:FindComponent("UISprite", "Offset/PageList/MainPage/TitleBg");
	mMainPageContentBg = self:FindComponent("UISprite", "Offset/PageList/MainPage/ContentBg");
	
	mMianContentBgTexture = self:FindComponent("UITexture", "Offset/PageList/MainPage/ContentBg/ContentPanel/ConternBg");
	mContentItemGrid = self:FindComponent("UIGrid", "Offset/PageList/MainPage/ContentBg/ContentPanel/ConternBg/Grid");
	
	mMainTitleLabel = self:FindComponent("UILabel", "Offset/PageList/MainPage/TitleBg/IndexBg/IndexLabel");
	mOtherPageTitle01 = self:FindComponent("UILabel", "Offset/PageList/OtherPageObj01/OtherPage01/IndexBg/IndexLabel");
	mOtherPageTitle02 = self:FindComponent("UILabel", "Offset/PageList/OtherPageObj02/OtherPage02/IndexBg/IndexLabel");
	mOtherPageTitle03 = self:FindComponent("UILabel", "Offset/PageList/OtherPageObj03/OtherPage03/IndexBg/IndexLabel");
	mOtherPageTitle04 = self:FindComponent("UILabel", "Offset/PageList/OtherPageObj04/OtherPage04/IndexBg/IndexLabel");
	mOtherPageList[1].PageLabel = mOtherPageTitle01;
	mOtherPageList[2].PageLabel = mOtherPageTitle02;
	mOtherPageList[3].PageLabel = mOtherPageTitle03;
	mOtherPageList[4].PageLabel = mOtherPageTitle04;
	
	mColorItemPrefab = self:Find("Offset/PageList/MainPage/ContentBg/ColorScrollView/ColorItemPrefab");
	mColorItemPrefab.gameObject:SetActive(false);
	mColorScrollViewTable = self:FindComponent("UITable", "Offset/PageList/MainPage/ContentBg/ColorScrollView/Table");
	
	local itemCommonStr = "Offset/PageList/MainPage/ContentBg/ContentPanel/ConternBg/Grid/ContentItem"
	for i = 1, ITEM_MAX_VER_COUNT do
		local horItemList = {};
		for k = 1, ITEM_MAX_HOR_COUNT do
			local verStr = tostring(i);
			if i < 10 then
				verStr = "0" .. verStr;
			end
			local horStr = tostring(k);
			if k < 10 then
				horStr = "0" .. horStr;
			end
			local itemDetailStr = itemCommonStr .. verStr .. horStr;
			local item = {};
			item.itemBg = self:FindComponent("UISprite", itemDetailStr);
			item.itemLabel = item.itemBg.transform:Find("ItemLabel"):GetComponent("UILabel");
			item.selectFlag = item.itemBg.transform:Find("SelectFlag"):GetComponent("UISprite");
			table.insert(horItemList, item);
		end
		table.insert(mContentItemList, horItemList);
	end
	InitColorList();	
end

function OnEnable(self)
	RegEvent(self);
	InitView();
	SelectColorItem();
end

function OnDisable(self)
	UnRegEvent(self);
end

function RegEvent(self)
	mEvents[1] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_IMAGE_INIT, OnActivityImageReset);
	mEvents[2] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_FILL_IMAGE, OnFillImageItem);
	mEvents[3] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_UPDATE_SELECT_FLAG, UpdateSelectImgItemList);
	mEvents[4] = MessageSub.Register(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_UPDATE_COLOR_COUNT, UpdateColorItemCount);
	mEvents[5] = MessageSub.Register(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_SWITCHSHARELAYER, SwitchRankPanelToShareLayer);
end

function UnRegEvent(self)
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_IMAGE_INIT, mEvents[1]);
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_FILL_IMAGE, mEvents[2]);
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_UPDATE_SELECT_FLAG, mEvents[3]);
	MessageSub.UnRegister(GameConfig.SUB_G_VITALITY, GameConfig.SUB_U_VITALITY_UPDATE_COLOR_COUNT, mEvents[4]);
	MessageSub.UnRegister(GameConfig.SUB_G_SHARE, GameConfig.SUB_U_SHARE_SWITCHSHARELAYER, mEvents[5]);
end

function InitView()
	JumpPage(VitalityMgr.GetCurrentPage());
	VitalityMgr.InitActivityImage();
	InitColorItemCount();
end

function OnClick(go, id)
	if id == 0 then
		UIMgr.UnShowUI(AllUI.UI_Vitality_Week);
	elseif id == 1 then
		--左翻页
		TurnPage(true);
	elseif id == 2 then
		--右翻页
		TurnPage(false);
	elseif id == 3 then
		--分享
		ShareWeekActivity();
	elseif id == 4 then
		--页签1
		JumpPage(mOtherPageList[1].index);
	elseif id == 5 then
		--页签2
		JumpPage(mOtherPageList[2].index);
	elseif id == 6 then
		--页签3
		JumpPage(mOtherPageList[3].index);
	elseif id == 7 then
		--页签4
		JumpPage(mOtherPageList[4].index);
	elseif id > 20 and id < 100 then
		--色块
		SelectColorItem(id - 20)
	elseif id > 100 and id < 2000 then
		SelectImageItem(id);
	end
end

function SetCurrentPage(pageIndex)
	mPageRealIndex = pageIndex;
	local otherPageCount = #mOtherPageList;
	for i = 1, pageIndex - 1 do
		mOtherPageList[i].PagaObj.transform.localPosition = Vector3.New((i - 1) * OTHER_PAGE_WIDTH, 0, 0);
	end
	for k = pageIndex, otherPageCount do
		mOtherPageList[k].PagaObj.transform.localPosition = Vector3.New((k - 1) * OTHER_PAGE_WIDTH + MAIN_PAGE_WIDTH, 0, 0);
	end
	mMainPage.transform.localPosition = Vector3.New((pageIndex - 1) * OTHER_PAGE_WIDTH, 0, 0);
	local mainTitleDepth =(otherPageCount + 2 - pageIndex) * 3 - 1;
	mMainPageTitleBg.depth = mainTitleDepth;
	mMainPageContentBg.depth = mainTitleDepth - 1;
end

function TurnPage(isLeft)
	local isPageChange = false;
	if isLeft then
		if mCurrentPageIndex > 1 then
			mCurrentPageIndex = mCurrentPageIndex - 1;
			if mCurrentPageIndex == 1 then
				SetCurrentPage(1);
			else
				if mPageRealIndex > 2 then
					SetCurrentPage(mPageRealIndex - 1);
				end
			end
			isPageChange = true;
		end
	else
		if mCurrentPageIndex < PAGE_MAX_COUNT then
			mCurrentPageIndex = mCurrentPageIndex + 1;
			if mCurrentPageIndex == PAGE_MAX_COUNT then
				SetCurrentPage(#mOtherPageList + 1);
			else
				if mPageRealIndex < #mOtherPageList then
					SetCurrentPage(mPageRealIndex + 1);
				end
			end
			isPageChange = true;
		end
	end
	if isPageChange then
		UpdatePageIndexAndText();
	end
end

function JumpPage(PageIndex)
	mCurrentPageIndex = PageIndex;
	if MAX_PAGE_NUMBER - PageIndex < 2 then
		SetCurrentPage(MAX_PAGE_SHOW_NUMBER -(MAX_PAGE_NUMBER - PageIndex));
	elseif MAX_PAGE_NUMBER - PageIndex > 7 then
		SetCurrentPage(PageIndex);
	else
		SetCurrentPage(3);
	end
	UpdatePageIndexAndText();	
end

function UpdatePageIndexAndText()
	mMainTitleLabel.text = WordData.GetWordDataByKey(NumberText[mCurrentPageIndex]).value;
	local leftCount = mPageRealIndex - 1;
	for i = 1, leftCount do
		mOtherPageList[i].PageLabel.text = WordData.GetWordDataByKey(NumberText[mCurrentPageIndex -(leftCount + 1 - i)]).value;
		mOtherPageList[i].index = mCurrentPageIndex -(leftCount + 1 - i);
	end
	local rightCount = #mOtherPageList - leftCount;
	for i = mPageRealIndex, #mOtherPageList do
		mOtherPageList[i].PageLabel.text = WordData.GetWordDataByKey(NumberText[mCurrentPageIndex +(i + 1 - mPageRealIndex)]).value;
		mOtherPageList[i].index = mCurrentPageIndex +(i + 1 - mPageRealIndex);
	end
end

function GetHVIndex(index)
	local x = math.floor(index * 0.01);
	local y = index % 100;
	return x, y;
end

function SelectImageItem(id)
	local indexV, indexH = GetHVIndex(id);
	VitalityMgr.SelectImageContentItem(indexV, indexH);
end

function OnActivityImageReset(imageInitList)
	for k, v in ipairs(imageInitList) do
		local imageItem = mContentItemList[v.vIndex] [v.hIndex];
		if imageItem then
			if v.isFill then
				imageItem.itemBg.spriteName = "icon_huoyuedu_color";
				local r, g, b, a = HexToColor(v.colorInfo.colorValue);
				imageItem.itemBg.color = Color.New(r, g, b, a);
				imageItem.itemLabel.gameObject:SetActive(false);
				imageItem.selectFlag.gameObject:SetActive(false);
				
			else
				imageItem.itemLabel.gameObject:SetActive(true);
				imageItem.itemLabel.text = v.colorInfo.str;
			end
		end
	end
end

function OnFillImageItem(imageFillList)
	for k, v in ipairs(imageFillList) do
		local indexV = v.vIndex;
		local indexH = v.hIndex;
		local color = v.color;
		local hItemList = mContentItemList[indexV];
		local contentItem = hItemList[indexH];
		if contentItem then
			contentItem.itemBg.spriteName = "icon_huoyuedu_color";
			local r, g, b, a = HexToColor(color)
			contentItem.itemBg.color = Color.New(r, g, b, a);
			contentItem.itemLabel.gameObject:SetActive(false);
			contentItem.selectFlag.gameObject:SetActive(false);
		end
	end
end

function UpdateSelectImgItemList(isShow, imageItemInfoList)
	for k, v in ipairs(imageItemInfoList) do
		local indexV = v.vIndex;
		local indexH = v.hIndex;
		local hItemList = mContentItemList[indexV];
		local contentItem = hItemList[indexH];
		if contentItem then
			contentItem.itemLabel.gameObject:SetActive(not isShow);
			contentItem.selectFlag.gameObject:SetActive(isShow);
		end
	end
end

function InitColorList()
	local allColorInfo = VitalityMgr.GetAllVitalityColorInfo();
	for k, v in ipairs(allColorInfo) do
		local colorItem = {};
		colorItem.id = v.id;
		colorItem.gameObject = mSelf:DuplicateAndAdd(mColorItemPrefab, mColorScrollViewTable.transform, k).gameObject;
		colorItem.gameObject:SetActive(true);
		colorItem.transform = colorItem.gameObject.transform;
		colorItem.bg = colorItem.transform:GetComponent("UISprite");
		colorItem.selectFlag = colorItem.transform:Find("SelectFlag"):GetComponent("UISprite");
		colorItem.selectFlag.gameObject:SetActive(false);
		colorItem.colorIcon = colorItem.transform:Find("ColorSprite"):GetComponent("UISprite");
		local r, g, b, a = HexToColor(v.colorValue)
		colorItem.colorIcon.color = Color.New(r, g, b, a);
		colorItem.colorLabel = colorItem.transform:Find("ColorSprite/Label"):GetComponent("UILabel");
		colorItem.colorLabel.text = v.str;
		colorItem.countLabel = colorItem.transform:Find("ColorCountLabel"):GetComponent("UILabel");
		colorItem.countLabel.text = "0";
		colorItem.uiEvent = colorItem.transform:GetComponent("UIEvent");
		colorItem.uiEvent.id = 20 + v.id;
		table.insert(mColorItemList, colorItem);
	end
end

function InitColorItemCount()
	local colorItemCountInfo = VitalityMgr.GetColorItemList();
	for k, v in ipairs(mColorItemList) do
		for n, m in ipairs(colorItemCountInfo) do
			if n == v.id then
				v.countLabel.text = m;
				break;
			end
		end
	end
end

function HexToColor(hex)
	local s;
	s = string.sub(hex, 1, 2)
	local a = tonumber(s, 16) / 255
	s = string.sub(hex, 3, 4)
	local r = tonumber(s, 16) / 255
	s = string.sub(hex, 5, 6)
	local g = tonumber(s, 16) / 255
	s = string.sub(hex, 7, 8)
	local b = tonumber(s, 16) / 255
	return r, g, b, a;
end

function UpdateColorItemCount(infoList)
	for k, v in ipairs(infoList) do
		for r, m in ipairs(mColorItemList) do
			if v.id == m.id then
				m.countLabel.text = v.count;
				break;
			end
		end
	end
end

function ShareWeekActivity()
	ShareMgr.SetShareManagerParent(mOffset.transform);
	SwitchRankPanelToShareLayer(true);
	UIMgr.ShowUI(AllUI.UI_Tip_Share, mSelf, nil, nil, nil, true, mSharePanel.sortingOrder);
	ShareMgr.CaptureCamera();
end

function SwitchRankPanelToShareLayer(isShareLayer)
	if isShareLayer then
		GameUtil.GameFunc.SetGameObjectLayer(mSharePanel.transform, CameraLayer.ShareLayer);
	else
		GameUtil.GameFunc.SetGameObjectLayer(mSharePanel.transform, CameraLayer.UILayer);
	end
end

function SelectColorItem(colorItemId)
	for k, v in ipairs(mColorItemList) do
		if v.id == mCurrentSelectColorItemId then
			v.selectFlag.gameObject:SetActive(false);
			v.bg.spriteName = "button_huoyuedu_09";
			break;
		end
	end
	if mCurrentSelectColorItemId == colorItemId or colorItemId == - 1 then
		mCurrentSelectColorItemId = - 1;
	else
		for k, v in ipairs(mColorItemList) do
			if v.id == colorItemId then
				v.selectFlag.gameObject:SetActive(true);
				v.bg.spriteName = "button_huoyuedu_10";
				break;
			end
		end
		mCurrentSelectColorItemId = colorItemId;		
	end
	VitalityMgr.FillColorFitImageItemList(mCurrentSelectColorItemId);	
end

