local UITableListViewController = class("UITableListViewController",nil)

function UITableListViewController:ctor(ui,itemPrefab,tableWrap,scrollPanel,scrollView,maxCellcont,cellUpdate,align,dataAlign)
    --存放实例化信息条目的table
    self._mItemTable ={}
    --信息数据数组  item结构={name="",content=""}
    self._mItemDatas = {}
    --玩家信息对象 SocialPlayerInfo 类型
    self._mPlayerInfo ={}

    self:InitViewObject(ui,itemPrefab,tableWrap,scrollPanel,scrollView,maxCellcont,cellUpdate,align,dataAlign)
end

--==============================--
--desc:
--time:2018-10-26 09:40:15
--@return 
--==============================--
--初始化获取UI控制对象
function UITableListViewController:InitViewObject(ui,itemPrefab,tableWrap,scrollPanel,scrollView,maxCellcont,cellUpdate,align,dataAlign)
    self._ui=ui
    self._MAX_ITEM_COUNT = maxCellcont
    --朋友圈预制体
    self._mItemPrefab = itemPrefab
    --tablewrap组件
    self._mTableWrap = tableWrap
    self._mScrollPanel =scrollPanel
    self._mScrollView = scrollView
    self._mCellUpdate = cellUpdate

    local function LocalOnInitItem(go,wrapIndex,realIndex)
        self:OnInitItem(go,wrapIndex,realIndex)
    end
    --实例化回调UITableWrapContent.Align.Bottom
    self._mWrapCall = UITableWrapContent.OnInitializeItem(LocalOnInitItem);
    self._mAlign = align and align or UITableWrapContent.Align.Bottom;
    self._mDataAlign = dataAlign and dataAlign or UITableWrapContent.Align.Bottom;
    self._mOffset = Vector3.zero
    if self._mScrollPanel then 
        self._mScrollPanel.clipOffset= Vector2.zero
        self._mScrollPanel.transform.localPosition= Vector3.zero
    end   
end

--初始化朋友圈列表
function UITableListViewController:InitItems()
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
        item.gameObject  = UnityEngine.GameObject.Instantiate(self._mItemPrefab, self._mTableWrap.transform, true);
       -- item.gameObject = self._ui:DuplicateAndAdd(self._mItemPrefab.transform,self._mTableWrap.transform,i).gameObject;
        item.gameObject.name = tostring(10000 + i);
        item.transform = item.gameObject.transform;
        item.gameObject:SetActive(false);
        self._mItemTable[i] = item;
    end
    self._mItemPrefab.transform.parent = self._mScrollView.transform
    self._mItemPrefab:SetActive(false);
end

--初始化zoneItem
function UITableListViewController:OnInitItem(go,wrapIndex,realIndex)
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

function  UITableListViewController:SetDatas(data)
    self._mItemDatas = data
end

--获取数据位置的item
function UITableListViewController:GetItemAtDataIndex(index)
    for i,v in ipairs(self._mItemTable) do
        if v.dataIndex == index then
            return v
        end
    end
    return nil
end

function UITableListViewController:UpdateCellsContent()
    for i,v in ipairs(self._mItemTable) do
        self._mCellUpdate(v,self._mItemDatas[v.dataIndex])
    end
end

--获取实体位置的item
function UITableListViewController:GetItemAtIndex(index)
    local item =  self._mItemTable[index];
    return item
end

--更新列表
function UITableListViewController:UpdateItems()
    if self._mItemDatas then
        self._mTableWrap:ResetWrapContent(table.getn(self._mItemDatas),self._mWrapCall,self._mAlign,self._mDataAlign,true);
    end
end

--重新布局
function UITableListViewController:ReLayout()
    self._mTableWrap:ReLayout();
end

return UITableListViewController