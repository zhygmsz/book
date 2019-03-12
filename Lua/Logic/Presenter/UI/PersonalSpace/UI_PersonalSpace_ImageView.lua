module("UI_PersonalSpace_ImageView", package.seeall);--格子对象数组
local mWrapGrids = {}
--itemwrap组件
local mWrap;
local mWrapCallBack;
local mScrollPanel=nil
local mDragPanel;
local mCurSelectIndex = 1
local mViewItem = nil
local mImageDatas ={}
local mCurGridCount = 0
local _self = nil
local mLastBtn = nil
local mNextBtn = nil
local mViewer = nil
local mTweener = nil
local mIsMoment = true

function OnCreate(self)
    _self=self
	mViewItem = self:Find("Offset/ViewItem");
	mViewer = self:FindComponent("UITexture", "Offset/Viewer");
	mTweener = mViewer.gameObject:AddComponent(typeof(TweenScale))
	mWrap = self:FindComponent("UIWrapContent", "Offset/ImageView/ScrollView/ItemWrap");
	mDragPanel = self:Find("Offset/ImageView/ScrollView").transform;
	mLastBtn = self:Find("Offset/Last");
	mNextBtn = self:Find("Offset/Next");
    mScrollPanel = mDragPanel:GetComponent("UIPanel");
	mScrollView = mDragPanel:GetComponent("UIScrollView");

	local function OnTweenFinish()
		mTweener.enabled = false
    end

    local finishFunc = EventDelegate.Callback(OnTweenFinish)
	EventDelegate.Set(mTweener.onFinished, finishFunc)
	
	InitPanel();
end

function NewItem(self, obj, index)
	local item = {};
	item.index = index;
	item.gameObject = self:DuplicateAndAdd(obj, mWrap.transform, index).gameObject;
	item.gameObject.name = tostring(10000 + index);
	item.transform = item.gameObject.transform;
	item.texture = item.transform:GetComponent("UITexture");
	item.uiEvent = item.transform:GetComponent("UIEvent");
	item.gameObject:SetActive(false);
	return item;
end

local mEvents = {};
function RegEvent(self)
	UpdateBeat:Add(Update,self);
end

function UnRegEvent(self)
	mEvents = {};
	UpdateBeat:Remove(Update,self);
end

function OnEnable(self)
	RegEvent(self);
	UpdateView()
end

function OnDisable(self)
	mCurSelectIndex = 1;
	UnRegEvent(self);
end

function onDestroy(self)
	--ClearLoaders()
end

--初始化面板
function InitPanel()
	mScrollView.resetOffset = Vector3.zero;
	mScrollPanel.clipOffset = Vector2.zero;
	mDragPanel.localPosition = Vector3.zero;
end

function InitViews()
    local gridnum = table.getn(mWrapGrids)
    local num = table.getn(mImageDatas)
    local max = math.max(gridnum,num)
    for i = 1, max do
        if mWrapGrids[i] == nil  then
            mWrapGrids[i] = NewItem(_self, mViewItem, i);
        end
        mWrapGrids[i].gameObject:SetActive(false);
    end
    mViewItem.gameObject:SetActive(false);
end

--刷险背包界面显示
function UpdateView()
    --InitViews()
	--UpdateLayout()
	ShowBtns()
	MoveToIndex(mCurSelectIndex)
end

--scrollowview布局
function UpdateLayout()
	table.sort(mWrapGrids, function(a, b) return a.gameObject.name < b.gameObject.name; end);
	for k, v in pairs(mWrapGrids) do if v then v.uiEvent.id = k; end end
	if not mWrapCallBack then mWrapCallBack = UIWrapContent.OnInitializeItem(OnInitGrid); end
	mWrap:WrapContentWithPosition(NewGridCount(), mWrapCallBack, Vector3.New(1, 1, 1));
end

--当前物品格子数
function NewGridCount()
    mCurGridCount = #mImageDatas;
    mWrap.itemCountPerLine = 1
	return mCurGridCount;
end

--初始化各自信息 范围内的可见 
function OnInitGrid(go, wrapIndex, realIndex)
	if realIndex >= 0 and realIndex < mCurGridCount then
		go:SetActive(true);
		InitGrid(wrapIndex + 1, realIndex + 1);
	else
		go:SetActive(false);
	end
end

--初始化背包物品信息 复用格子的id 逻辑数据的id
function InitGrid(gridID, dataID)
	local Grid = mWrapGrids[gridID];
    local data = mImageDatas[dataID];
    Grid.gridID = gridID;
	Grid.dataID = dataID;
	if mIsMoment then
		PersonSpaceMgr.LoadMomentImage(Grid.texture,data.img)
	else
		PersonSpaceMgr.LoadHeadIcon(Grid.texture, data)
	end
end

function ShowImages(imagesarray,selectIndex,isMoment)
	mIsMoment = isMoment
	mImageDatas = imagesarray
	mCurSelectIndex = selectIndex or 1
    UIMgr.ShowUI(AllUI.UI_PersonalSpace_ImageView)
end

function ReplyViewTween(index)
	if mIsMoment then
		PersonSpaceMgr.LoadMomentImage(mViewer, mImageDatas[index].img)
	else
		PersonSpaceMgr.LoadHeadIcon(mViewer, mImageDatas[index])
	end
    mTweener.enabled = true
    mTweener.from = Vector3.zero
    mTweener.to = Vector3.one
	mTweener.duration = 0.3
	mTweener:ResetToBeginning()
    mTweener:PlayForward()
end


function ShowBtns()
	local max = table.getn(mImageDatas)
	if max>=1 then
		mCurSelectIndex = Mathf.Clamp(mCurSelectIndex,1,max)
		mLastBtn.gameObject:SetActive(mCurSelectIndex>1)
		mNextBtn.gameObject:SetActive(mCurSelectIndex<max)
	end
end

function MoveToIndex(index)
	ReplyViewTween(index)
	--[[ 
	local x = mWrap.itemWidth*(index-1)
	mScrollPanel.clipOffset = Vector2.Lerp(mScrollPanel.clipOffset, Vector2(x,0), 0.3);
	mDragPanel.localPosition =  Vector2.Lerp(mDragPanel.localPosition, Vector3(-x,0,0), 0.3);
	]]
	--mScrollPanel.clipOffset = Vector2(x,0);
	--mDragPanel.localPosition =  Vector3(-x,0,0)
end

function ClickLast()
	mCurSelectIndex =mCurSelectIndex - 1
	ShowBtns()
	MoveToIndex(mCurSelectIndex)
end

function ClickNext()
	mCurSelectIndex = mCurSelectIndex + 1
	ShowBtns()
	MoveToIndex(mCurSelectIndex)
end

function Update()
	--MoveToIndex(mCurSelectIndex)
end

function OnClick(go, id)
   if id>=1 then
        local item = mWrapGrids[id];
        mCurSelectIndex = item.dataID;
        local data = mImageDatas[item.dataID]
   elseif id == -1000 then
		UIMgr.UnShowUI(AllUI.UI_PersonalSpace_ImageView)
	elseif id == -1 then
		ClickLast()
	elseif id == -2 then
		ClickNext()
   end
end

return UI_PersonalSpace_ImageView