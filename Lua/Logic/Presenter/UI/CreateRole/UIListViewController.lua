local UIListViewController = class("UIListViewController",nil)

function UIListViewController:ctor(ui,itemPrefab,itemWrap,scrollPanel,scrollView,maxCellcont,cellUpdate,ondragstarted,ondragging,ondragstop,pageMode,pageSize)
    --存放实例化信息条目的table
    self._mItemTable ={}
    --信息数据数组  item结构={name="",content=""}
    self._mItemDatas = {}

    self:InitViewObject(ui,itemPrefab,itemWrap,scrollPanel,scrollView,maxCellcont,cellUpdate,ondragstarted,ondragging,ondragstop,pageMode,pageSize)
end

--==============================--
--desc:
--time:2018-10-26 09:40:15
--@return 
--==============================--
--初始化获取UI控制对象
function UIListViewController:InitViewObject(ui,itemPrefab,itemWrap,scrollPanel,scrollView,maxCellcont,cellUpdate,ondragstarted,ondragging,ondragstop,pageMode,pageSize)
    self._ui=ui
    self._MAX_ITEM_COUNT = maxCellcont
    --预制体
    self._mItemPrefab = itemPrefab
    --itemWrap
    self._mWrapContent = itemWrap
    self._mScrollPanel =scrollPanel
    self._mScrollView = scrollView
    self._mCellUpdate = cellUpdate
    self._mOnDragStart = ondragstarted
    self._mOnDraging = ondragging;
    self._mOnDragStop = ondragstop;
    self._mSelectIndex = 1
    self._mPageMode = pageMode
    self._mPageSize = pageSize
    self._mPageIndex =1
    local function LocalOnInitItem(go,wrapIndex,realIndex)
        self:OnInitItem(go,wrapIndex,realIndex)
    end
    --实例化回调
    self._mWrapCall = UIWrapContent.OnInitializeItem(LocalOnInitItem);

    self._mOffset = Vector3.zero
    if self._mScrollPanel then 
        self._mScrollPanel.clipOffset= Vector2.zero
        self._mScrollPanel.transform.localPosition= Vector3.zero
    end   
    local dragstart = UIScrollView.OnDragNotification(function ()
		self:OnScrollViewDragStart()
	end)
	local dragging = UIScrollView.OnDragNotification(function ()
		self:OnScrollViewDragging()
	end)
	local dragFinished= UIScrollView.OnDragNotification(function ()
		self:OnScrollViewStoppped()
    end)
    self._mScrollView.onDragStarted=dragstart
    self._mScrollView.onDragging= dragging
	self._mScrollView.onDragFinished= dragFinished
end

function UIListViewController:CurrentPage()
    if self._mPageMode then
        local totalN =  table.count(self._mItemDatas)
        --整除最后一页剩余的个数
        local modN =totalN%self._mPageSize
         --总页数
        local allpage =math.floor(totalN/self._mPageSize)+(modN>0 and 1 or 0)
        local pos = math.abs(self._mScrollPanel.transform.localPosition.y)
        local pageH =self._mScrollPanel.height/2
        local page =math.floor(math.abs(pos/pageH-0.5))+1
        if allpage>1 and page == allpage-1 then
            pageH = modN/self._mPageSize*self._mScrollPanel.height/2
            page =math.floor(math.abs(pos/pageH-0.5))+1
        end
        return page
    end
end

function UIListViewController:MoveToPage(page)
    if self._mPageMode then
        local totalN =  table.count(self._mItemDatas)
        --整除最后一页剩余的个数
        local modN =totalN%self._mPageSize
         --总页数
        local allpage =math.floor(totalN/self._mPageSize)+(modN>0 and 1 or 0)
        local tpPage = Mathf.Clamp(page,1,allpage)
        local Count = 0
        if allpage>1 and tpPage == allpage then
            Count = (tpPage- 2 +modN/self._mPageSize)
        elseif allpage>1 and tpPage ~= allpage then
            Count = (tpPage- 1)
        end
        local dis =self._mScrollPanel.height *Count
        self._mScrollPanel.clipOffset=Vector3(0,-1*dis,0)
        self._mScrollPanel.transform.localPosition= Vector3(0,dis,0)
        self._mPageIndex=tpPage
    end
end

function UIListViewController:MoveToCurrentPage()
    if self._mPageMode then
        self:MoveToPage(self:CurrentPage())
    end
end

function UIListViewController:PageUp()
    if self._mPageMode then
        self:MoveToPage(self._mPageIndex-1)
    end
end

function UIListViewController:PageDown()
    if self._mPageMode then
        self:MoveToPage(self._mPageIndex+1)
    end
end

--初始化朋友圈列表
function UIListViewController:InitItems()
    local count =#self._mItemTable
    for i=1,count do
        if self._mItemTable[i].gameObject then
            UnityEngine.GameObject.Destroy(self._mItemTable[i].gameObject)
        end
    end
    self._mItemTable={}
    for i = 1,self._MAX_ITEM_COUNT do
        local item = {};
        item.index = i;
        item.dataIndex = i;
        item.gameObject = self._ui:DuplicateAndAdd(self._mItemPrefab.transform,self._mWrapContent.transform,i).gameObject;
        item.gameObject.name = tostring(10000 + i);
        item.transform = item.gameObject.transform;
        item.gameObject:SetActive(false);
        self._mItemTable[i] = item;
    end
    
    self._mItemPrefab.transform.gameObject:SetActive(false);
end

--初始化zoneItem
function UIListViewController:OnInitItem(go,wrapIndex,realIndex)
    if self._mItemDatas then
        if realIndex >= 0 and realIndex < #self._mItemDatas then
            go:SetActive(true);
            local item =  self._mItemTable[wrapIndex+1];
            local data = self._mItemDatas[realIndex + 1];
            if item and data then
                item.dataIndex = realIndex + 1
                self._mCellUpdate(item,data)
            end
        else
            go:SetActive(false);
        end
    end
end

function UIListViewController:CurrentSelect()
    return self._mSelectIndex 
end

function UIListViewController:OnSelect(realIndex)
    self._mSelectIndex = realIndex
end

function UIListViewController:OnScrollViewDragStart()
    if self._mOnDragStart then
        self._mOnDragStart(self._mScrollPanel,self._mItemTable)
    end
end

function UIListViewController:OnScrollViewDragging()
    if self._mOnDraging then
        self._mOnDraging(self._mScrollPanel,self._mItemTable)
    end
end

function UIListViewController:OnScrollViewStoppped()
    if self._mOnDragStop then
        self._mOnDragStop(self._mScrollPanel,self._mItemTable)
    end
end

function UIListViewController:SetDatas(data)
    self._mItemDatas = data
    if self._MAX_ITEM_COUNT==-1 then
        self._MAX_ITEM_COUNT = table.count(self._mItemDatas)
        self:InitItems()
    end
end

--获取数据位置的item
function UIListViewController:GetItemAtDataIndex(index)
    for i,v in ipairs(self._mItemTable) do
        if v.dataIndex == index then
            return v
        end
    end
    return nil
end

--获取实体位置的item
function UIListViewController:GetItemAtIndex(index)
    local item =  self._mItemTable[index];
    return item
end

--更新列表
function UIListViewController:UpdateItems()
    self._mWrapContent:WrapContentWithPosition(table.getn(self._mItemDatas),self._mWrapCall,Vector3.New(0,0,0));
    if self._mOnDraging then
        self._mOnDraging(self._mScrollPanel,self._mItemTable)
    end
end

--重新布局
function UIListViewController:ReLayout()
    self._mWrapContent:ReLayout();
end

return UIListViewController