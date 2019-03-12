local SimapleTableList = class("SimapleTableList",nil)

function SimapleTableList:ctor(ui,itemPrefab,table,cellUpdate)
    self._ui = ui
    self._table=table
    self._mItemTable ={}
    self._mItemPrefab = itemPrefab
    self._mItemDatas ={}
    self._mCellUpdate = cellUpdate
end

function SimapleTableList:BuildTableList(items)
    self._mItemDatas = items
    local count =  table.count(self._mItemTable)
    local dataN =  table.count(self._mItemDatas)
    local max = math.max(count,dataN)

    self._mItemPrefab:SetActive(true);
    for i = 1,max do
        local item= self._mItemTable[i]
        if item ==nil then
            item = {};
            item.index = i;
            item.gameObject  = UnityEngine.GameObject.Instantiate(self._mItemPrefab, self._table.transform, true);
            item.gameObject.name = tostring(10000 + i);
            item.transform = item.gameObject.transform;
            item.dataIndex = i
            item.gameObject:SetActive(true);
            self._mItemTable[i] = item;
        end
        if i<=dataN then
            self._mCellUpdate(item,self._mItemDatas[i])
        else
            item.gameObject:SetActive(false);
        end
    end
    self._mItemPrefab:SetActive(false);
    self:ReLayout();
end

function SimapleTableList:UpdateCellsContent()
    for i,v in ipairs(self._mItemTable) do
        self._mCellUpdate(v,self._mItemDatas[v.dataIndex])
    end
end

--获取实体位置的item
function SimapleTableList:GetItemAtIndex(index)
    local item =  self._mItemTable[index];
    return item
end

--获取数据位置的item
function SimapleTableList:GetItemAtDataIndex(index)
    for i,v in ipairs(self._mItemTable) do
        if v.dataIndex == index then
            return v
        end
    end
    return nil
end

function SimapleTableList:ReLayout()
    self._table:Reposition();
end

return SimapleTableList