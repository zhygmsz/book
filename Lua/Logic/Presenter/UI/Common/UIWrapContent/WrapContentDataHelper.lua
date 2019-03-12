WrapContentDataHelper = class("WrapContentDataHelper");
--按钮UIEventID的起始数据, 每个Item下的UIEventID的跨度（默认为5）
function WrapContentDataHelper:ctor(baseEventId, eventIdSpan,wrapContent)
    self._baseEventId = baseEventId;
    self._eventIdSpan = eventIdSpan or 5;
    self._wrapContent = wrapContent;
end
function WrapContentDataHelper:UpdateContent()
    self._wrapContent:Update();
end

function WrapContentDataHelper:ResetTable(ids,callbacks,context)
    self:MakeDataList(ids,callbacks,context);
    self._wrapContent:ResetWithData(self._lineDatas);
end

function WrapContentDataHelper:ResetTableWithDefaultData()
    self._wrapContent:ResetWithData(self._lineDatas);
end

--id表，回调table, 上下文，
function WrapContentDataHelper:MakeDataList(ids,callbacks,context)
    self._lineDataByID = {};
    self._lineDatas = {};
    for i = 1, #ids do
        local id = ids[i];
        local eventId = self._baseEventId  + self._eventIdSpan * (i-1);
        local wrapData = BaseWrapContentData.new(id,eventId,callbacks,context);
        table.insert(self._lineDatas,wrapData);
        self._lineDataByID[id] = wrapData;
    end
end

function WrapContentDataHelper:OnClick(id)
    
    id = (id - self._baseEventId);
    local dataIndex = math.floor(id / self._eventIdSpan) + 1;
    local buttonId = id - (dataIndex-1) * self._eventIdSpan + 1;
    self._lineDatas[dataIndex]:OnClick(buttonId);
    return dataIndex, buttonId;
end

function WrapContentDataHelper:GetDataByIndex(index)
    return self._lineDatas[index];
end

function WrapContentDataHelper:DeleteAllData()
    self._lineDatas = {};
end

function WrapContentDataHelper:DeleteData(id)
    for i = 1,#self._lineDatas do
        if self._lineDatas[i]:GetID()==id then
            table.remove(self._lineDatas,i);
            return;
        end
    end
    self._lineDataByID[id] = nil ;
end

function WrapContentDataHelper:GetDataList()
    return self._lineDatas;
end

function WrapContentDataHelper:GetDataTable()
    return self._lineDataByID;
end

function WrapContentDataHelper:ReleaseData()
    self._lineDataByID = nil;
    self._lineDatas = nil;
end

return WrapContentDataHelper;
