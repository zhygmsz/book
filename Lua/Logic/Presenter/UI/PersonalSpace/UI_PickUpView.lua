module("UI_PickUpView", package.seeall);

local _self
local mPickWheel= nil
local mPickItem = nil
local mInitCount = 9
local mGrid=nil
local mWheeltable= {}
local mResult = {1,1,1}
local mOnPickedCallback = nil
local mSureCallback = nil
local mItemHeight = 50
local mItemWidth = 100
local mRow = 7
local mBg = nil
local mRuler = nil
local mWheelNum = 1
local mWheekDatas ={}
local mSureBtn = nil
local mOffset = nil
local mPosition = Vector3.zero
local mOnSetItemData = nil
local mOnCloseCallback = nil

function OnCreate(self)
    _self=self
    mOffset = self:Find("Offset");
    mGrid = self:Find("Offset/Grid");
    mSureBtn = self:Find("Offset/Sure");
    mBg =  self:Find("Offset/Bg"):GetComponent("UISprite");
    mRuler = self:Find("Offset/RulerPanel/Ruler"):GetComponent("UISprite");
    mGridComp = self:Find("Offset/Grid"):GetComponent("UIGrid");
    mPickWheel = self:Find("Offset/PickWheel");
    mPickItem = self:Find("Offset/PickItem");
    mPickWheel.gameObject:SetActive(false);
    mPickItem.gameObject:SetActive(false);
end

local mEvents = {};
function RegEvent(self)
end

function UnRegEvent(self)
	mEvents = {};
end

function OnEnable(self,wheelNum,datas)
    RegEvent(self);
    mWheelNum = wheelNum
    mWheekDatas = datas
	UpdateView()
end

function OnDisable(self)
	mCurSelectIndex = - 1;
	UnRegEvent(self);
end

function onDestroy(self)
	--ClearLoaders()
end

--获取一个轮子
function GetWheel(index)
    if mWheeltable[index] == nil then
        local wheel = {};
        wheel.index = index;
        wheel.gameObject = _self:DuplicateAndAdd(mPickWheel, mGrid, index).gameObject;
        wheel.gameObject.name = tostring(index);
        wheel.transform = wheel.gameObject.transform;
        wheel.mWrapContent = wheel.transform:Find("ScrollView/ItemWrap"):GetComponent("UIWrapContent")
        wheel.mScrollView = wheel.transform:Find("ScrollView"):GetComponent("UIScrollView")
        wheel.mScrollPanel = wheel.transform:Find("ScrollView"):GetComponent("UIPanel")
        wheel.widget =  wheel.transform:GetComponent("UIWidget")
        wheel.mWrapItems= {}
        wheel.mItemDatas= {}
        wheel.offset = Vector3.New(0, 0, 0)
        local function OnInitGrid(go, wrapIndex, realIndex)
            if realIndex >= 0 and realIndex < #wheel.mItemDatas then
                go:SetActive(true);
                local gridID= wrapIndex + 1
                local dataID = realIndex + 1
                local Grid = wheel.mWrapItems[gridID];
                local data = wheel.mItemDatas[dataID];
                Grid.visualPad.gameObject:SetActive(true)
                if mOnSetItemData then
                    mOnSetItemData(wheel.index,Grid.name,data)
                else
                    Grid.name.text = data
                end
                if data == "" then
                    Grid.visualPad.gameObject:SetActive(false)
                end
            else
                go:SetActive(false);
            end
        end
        wheel.OnInitGrid = OnInitGrid
        wheel.mWrapCallBack = UIWrapContent.OnInitializeItem(wheel.OnInitGrid)
        wheel.inited = false
        mWheeltable[index]=wheel
        local onstopped = UIScrollView.OnDragNotification(function ()
            OnWheelAtIndexStoppped(index)
        end)
        wheel.mScrollView.onStoppedMoving= onstopped
    end
    local wheel = mWheeltable[index]
	wheel.mWrapContent.itemCountPerLine = 1
    wheel.mScrollPanel.baseClipRegion = Vector4(0,0,mItemWidth,mItemHeight*mRow)
    wheel.widget.width = mItemWidth
    wheel.widget.height = mItemHeight*mRow
	return wheel;
end

--初始化pickwheel数据
function InitWheelsData()
    for i=1,mWheelNum do
        local wheel = GetWheel(i)
        InitWheelItem(i)
        wheel.mWrapContent.transform.localPosition = Vector3(0,mItemHeight *math.floor((mRow-1)/2),0)
        wheel.mItemDatas = {}
        local list = mWheekDatas[i]
        local count = table.count(list)
        local more = mRow-1
        local bf = math.floor(more/2)
        for i=1,count+more do
            if i<=bf or i>=(count+bf+1) then
                wheel.mItemDatas[i]=""
            else
                wheel.mItemDatas[i]=list[i-bf]
            end
        end
        wheel.gameObject:SetActive(true);
        UpdateLayout(i)
    end
    mGridComp:Reposition()
end

function InitWheelItem(wheelIndex)
    local wheel = GetWheel(wheelIndex)
    local force =false
    if table.count(wheel.mWrapItems) < (mRow+4) then
        mInitCount = mRow+4
        force =true
    end
    if  wheel.inited == false or force then
        for index=1,mInitCount do
            if wheel.mWrapItems[index] == nil then
                local item = {};
                item.index = index;
                item.gameObject = _self:DuplicateAndAdd(mPickItem, wheel.mWrapContent.transform, index).gameObject;
                item.gameObject.name = tostring(wheelIndex*10000 + index);
                item.transform = item.gameObject.transform;
                item.name= item.transform:Find("Visual/Name"):GetComponent("UILabel");
                item.visualPad = item.transform:Find("Visual")
                item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
                item.gameObject:SetActive(false);
                wheel.mWrapItems[index] = item
                item.wheel = wheel
            end
        end
        wheel.inited = true
    end
end

--布局函数
function UpdateLayout(wheelIndex)
    local wheel = GetWheel(wheelIndex)
	table.sort(wheel.mWrapItems, function(a, b) return a.gameObject.name < b.gameObject.name; end);
    for k, v in pairs(wheel.mWrapItems) do if v then v.uiEvent.id = k; end end
    local count = math.floor(math.abs(wheel.offset.y/mItemHeight)+0.5)
    local datacount = #wheel.mItemDatas
    if datacount<count then
        wheel.offset = Vector2.zero
    end
	wheel.mWrapContent:WrapContentWithPosition(datacount, wheel.mWrapCallBack,wheel.offset);
end

--更新界面视图
function UpdateView()
    if mWheelNum < #mWheekDatas then GameLog.LogError("datas num is not enough!") return end
    mOffset.localPosition =mPosition
    mGridComp.cellWidth = mItemWidth+4
    mGridComp.cellHeight = mItemHeight*mRow
    mBg.width = (mItemWidth+4)*mWheelNum + 30
    mBg.height = mItemHeight*mRow + 30
    mRuler.width = (mItemWidth+4)*mWheelNum + 30
    mSureBtn.gameObject:SetActive(mSureCallback and true or false)
    InitWheelsData()
end

--设置轮子数据
function SetDataForColum(colum,data)
    if mWheekDatas[colum] then
        mWheekDatas[colum]=data
        InitWheelsData()
    end
end

--设置pickitem的赋值函数
function SetItemDataCallback(setitemdatacallback)
    mOnSetItemData = setitemdatacallback
end

--设置确定一次数据的回调函数
function SetPickedCallback(pickedcallback)
    mOnPickedCallback = pickedcallback
end

--设置关闭界面的回调函数
function SetCloseCallback(closecallback)
    mOnCloseCallback = closecallback
end

--设置点击确定按钮的回调函数
function SetSureCallback(surecallback)
    mSureCallback = surecallback
end

--打开界面
function ShowPickWheel(colum,row,datas,setitemdatacallback,pickedcallback,offset,itemwidth,itemheight,closecallback,surecallback)
    mResult= {}
    mWheekDatas = datas
    mWheelNum = colum
    for i=1,mWheelNum do
        mResult[i] = 1
    end
    for i=1,#mWheeltable do
        mWheeltable[i].gameObject:SetActive(false)
    end
   
    if row then mRow =row end
    if itemwidth then mItemWidth =itemwidth end
    if itemheight then mItemHeight =itemheight end
    mPosition = offset or vector3.zero
    mOnPickedCallback = pickedcallback
    mOnSetItemData = setitemdatacallback
    mOnCloseCallback = closecallback
    mSureCallback = surecallback
    UIMgr.ShowUI(AllUI.UI_PickUpView,nil,nil,nil,nil,true,mWheelNum,mWheekDatas)
end

function OnWheelAtIndexStoppped(wheelIndex)
    local wheel = GetWheel(wheelIndex)
    local count = math.floor(math.abs(wheel.mScrollPanel.clipOffset.y/mItemHeight)+0.5)
    wheel.mScrollView:DisableSpring()
    wheel.mScrollPanel.clipOffset = Vector2(0,-1*count*mItemHeight)
    wheel.mScrollPanel.transform.localPosition = Vector3(0,count*mItemHeight,0)
    wheel.offset = wheel.mScrollPanel.transform.localPosition
    mResult[wheelIndex] = count+1
    if mOnPickedCallback then
        mOnPickedCallback(mResult,GetResultData())
    end
end

function GetResult()
    return mResult
end

function GetResultData()
    local res = {}
    for i=1,#mWheekDatas do
        local data = mWheekDatas[i] 
        local index = mResult[i]
        if data then
            res[i] = data[index]
        end
    end
    return res
end

function OnClick(go, id)
    if id == -10000 then--关闭
        if mOnCloseCallback then
            mOnCloseCallback(mResult)
        end
        UIMgr.UnShowUI(AllUI.UI_PickUpView)
    elseif id == -1 then--确定
        if mSureCallback then
            mSureCallback(mResult,GetResultData())
        end
        UIMgr.UnShowUI(AllUI.UI_PickUpView)
    end
end

return UI_PickUpView