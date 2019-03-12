--UIWrapContent 的封装，即将弃用，建议使用BaseWrapContentEx
BaseWrapContent = class("BaseWrapContent");

function BaseWrapContent:ctor(ui,path,count,wrapUIClass,itemCountPerLine,context)
    local contentTrans = ui:Find(path.."/WrapContent");
    self._wrapContent = contentTrans:GetComponent("UIWrapContent");
    self._dragPanel = ui:Find(path);
    if itemCountPerLine then
        self._wrapContent.itemCountPerLine = itemCountPerLine;
    end
    local wrapItemPrefab = contentTrans:Find("WrapItem");
    local transformList = {};
    transformList[1] = wrapItemPrefab;
    for i=2,count do
        transformList[i] = ui:DuplicateAndAdd(wrapItemPrefab,contentTrans,i); 
    end
    self._wrapItemList = {};
    for i=1,count do
        local wrapItem = transformList[i];
        local wrapUI = wrapUIClass.new(wrapItem,context);
        table.insert(self._wrapItemList,wrapUI)
        wrapUI:SetActive(false);
    end

    self._onInitItemFunc = UIWrapContent.OnInitializeItem(self.OnInitItem,self);

end

function BaseWrapContent:OnInitItem(go,wrapIndex,realIndex)
    if self._lineDatas[realIndex+1] then
        
        local wrapUI = self._wrapItemList[wrapIndex + 1];
        local wrapData = self._lineDatas[realIndex+1];
        wrapUI:SetActive(true);
        wrapUI:OnRefresh(wrapData);
        wrapData:RegisterUI(wrapUI);

    else
        wrapUI:SetActive(false);
    end
end

function BaseWrapContent:ResetWithData(dataList)
    self._lineDatas = dataList;
    self._wrapContent:ResetWrapContent(table.maxn(dataList),self._onInitItemFunc);
end

function BaseWrapContent:Update()

    local DRAG_FINISH_OFFSET = self._dragPanel.localPosition;
    self._wrapContent:WrapContentWithPosition(table.maxn(self._lineDatas),self._onInitItemFunc, DRAG_FINISH_OFFSET or Vector3.zero);
end

function BaseWrapContent:ResetWithPosition(dataList)
    self._lineDatas = dataList;
    self:Update();
end

function BaseWrapContent:ReleaseData()
    self._lineDatas = nil;
end

function BaseWrapContent:RefreshWrapUI(info)
    for i,wrapUI in ipairs(self._wrapItemList) do
        if wrapUI:IsTarget(info) then
            wrapUI:OnRefresh();
        end
    end
end

function BaseWrapContent:OnDestroy()
    self._lineDatas = nil;
    self._wrapItemList = nil;
    self._wrapContent = nil;
    self._onInitItemFunc = nil;
    self._dragPanel = nil;
end

return BaseWrapContent;
