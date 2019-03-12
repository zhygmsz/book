--UITable的endless版本,在内容需要折叠时采用，比如好友界面。
--需要UICommonCollapseWrapUI 和UICommonCollapseWrapData配合使用
UICommonCollapseTableWrap = class("UICommonCollapseTableWrap", nil)


function UICommonCollapseTableWrap:CheckInverseData(dataIndex)
    if self._inverseData then
        dataIndex = #self._wrapDataList + 1 - dataIndex;
    end
    return dataIndex;
end
function UICommonCollapseTableWrap:OnItemCreate(wrapTrans,index)
    local wrapItem = {};
    wrapItem.transform = wrapTrans;
    wrapItem.uiList = {};
    for i,wrapUI in ipairs(self._wrapUIs) do
        local uiItem = wrapUI.new(wrapTrans,self._baseEvent+(index-1)*self._eventSpan,self._context);
        local type = uiItem:GetType();
        wrapItem.uiList[type] = uiItem;
    end
    self._wrapItemList[index] = wrapItem;
end

function UICommonCollapseTableWrap:OnGetDataHeight(dataIndex)
    dataIndex = dataIndex + 1;
    dataIndex = self:CheckInverseData(dataIndex);

    local wrapData = self._wrapDataList[dataIndex];
    local funcOrNumber = self._sizeTable[wrapData.__cname];
    if type(funcOrNumber)=="function" then
        if self._caller then
            return funcOrNumber(self._caller,wrapData);
        else
            return funcOrNumber(wrapData);
        end
    end
    return funcOrNumber or wrapData:GetSize();
end

function UICommonCollapseTableWrap:OnItemInit(go, wrapIndex, dataIndex)
    dataIndex = dataIndex + 1;
    dataIndex = self:CheckInverseData(dataIndex);
    wrapIndex = wrapIndex + 1;
    local wrapItem =  self._wrapItemList[wrapIndex];
    local wrapData =  self._wrapDataList[dataIndex];

    local dataClass = wrapData.__cname;
    local funcOrName = dataClass and self._typeTable[dataClass];
    if type(funcOrName) == "function" then
        if self._caller then
            funcOrName = funcOrName(self._caller,wrapData);
        else
            funcOrName = funcOrName(wrapData);
        end
    end
    local targetUI = nil;
    if funcOrName then--通过注册的classname来找对应的ui
        for uiType,wrapui in pairs(wrapItem.uiList) do
            if wrapui.__cname == funcOrName then
                targetUI = wrapui;
            else
                wrapui:SetActive(false);
            end
        end
    else--通过data文件自带的type类型来找对应的ui
        local dataType = wrapData:GetType();
        for uiType,wrapui in pairs(wrapItem.uiList) do
            if uiType ~= dataType then
                wrapui:SetActive(false);
            end
        end
        targetUI = wrapItem.uiList[dataType];
    end
    targetUI:SetActive(true);
    targetUI:DispatchData(wrapData);
    targetUI:OnRefresh();
end

--[[
    ui:UIFrame;
    path:UIScrollView的绝对路径；
    count:UI要复制的数量；
    wrapUIs:UI子类型列表；
    baseEvent:UIEvent.id的起始数值；
    eventSpan:每个UI占用的id跨度；
    context:上下文；
]]
function UICommonCollapseTableWrap:ctor(ui,path,count,wrapUIs,baseEvent,eventSpan,context)
    self._ui = ui;
    local tableTrans = ui:Find(path.."/WrapTable");
    self._tableGo = tableTrans.gameObject;
    self._context = context;
    self._wrapUIs = wrapUIs;
    self._baseEvent = baseEvent;
    self._eventSpan = eventSpan or 2;
    self._tableWrapContent = tableTrans:GetComponent("UITableWrapCollapse");
    if not self._tableWrapContent then
        self._tableWrapContent = tableTrans:GetComponent("UITableWrapCollapse");
    end
    self._wrapItemList = {};
    local wrapItemPrefab = tableTrans:Find("ItemPrefab");
    UIGridTableUtil.CreateChild(ui,wrapItemPrefab,count,tableTrans,self.OnItemCreate,self);
    self._onInitItemFunc = System.Action_UnityEngine_GameObject_int_int(self.OnItemInit,self);
    self._onGetDataHeight = System.Func_int_float(self.OnGetDataHeight,self);
    self._typeTable = {};
    self._sizeTable = {};
end
--注册Data对应的UIClassName和尺寸,可以是直接值或者是一个回调方法
function UICommonCollapseTableWrap:RegisterData(dataClassName,uiClassName,dataSize,caller)
    self._typeTable[dataClassName] = uiClassName;
    self._sizeTable[dataClassName] = dataSize;
    self._caller = caller;
end
--重置所有数据,数据,是否从后往前读数据
function UICommonCollapseTableWrap:ResetAll(dataList,inverseData)
    self._inverseData = inverseData;
    self._wrapDataList = dataList;
    self._tableWrapContent:ResetAllData(#(self._wrapDataList), self._onInitItemFunc,self._onGetDataHeight);
end

--新的数据列表；从第几个数据开始刷新；要保证在ScrollView的数据项
function UICommonCollapseTableWrap:ResetPartialData(dataList,fromIndex,inViewIndex)
    self._wrapDataList = dataList;
    inViewIndex = inViewIndex or fromIndex;

    fromIndex = self:CheckInverseData(fromIndex);
    inViewIndex = self:CheckInverseData(inViewIndex);
    self._tableWrapContent:ResetPartialData(fromIndex-1,#dataList,inViewIndex-1);
end

--新的数据列表；从第1个数据开始刷新；要保证在ScrollView的数据项
function UICommonCollapseTableWrap:ResetAllWithShowData(dataList,inViewIndex)
    self._wrapDataList = dataList;
    inViewIndex = self:CheckInverseData(inViewIndex);
    self._tableWrapContent:ResetPartialData(0,#dataList,inViewIndex-1);
end

--在尺寸位置不改变的情形下，刷新UI
function UICommonCollapseTableWrap:UpdateWithPosition()
    for i,wrapItem in ipairs(self._wrapItemList) do
        for uiType,wrapui in pairs(wrapItem.uiList) do
            if wrapui:IsActive() and wrapui:GetData() then
                wrapui:OnRefresh();
            end
        end
    end
end

--获得指定Data的UI
function UICommonCollapseTableWrap:GetUIWithData(data)
    for _, wrapItem in ipairs(self._wrapItemList) do
        for _,wrapui in pairs(wrapItem.uiList) do
            if wrapui:IsActive() and wrapui:GetData() == data then
                return wrapui;
            end
        end
    end
end

function UICommonCollapseTableWrap:RefreshUIWithData(data)
    for _, wrapItem in ipairs(self._wrapItemList) do
        for _,wrapui in pairs(wrapItem.uiList) do
            if wrapui:IsActive() and wrapui:GetData() == data then
                wrapui:OnRefresh();
            end
        end
    end
end

--点击事件
function UICommonCollapseTableWrap:OnClick(eventid)
    if not self._tableGo.activeInHierarchy then return; end
    eventid = eventid - self._baseEvent;
    local uiIndex = math.floor(eventid/self._eventSpan) + 1;
    local bid = eventid - (uiIndex-1) * self._eventSpan;

    local uiItems = self._wrapItemList[uiIndex].uiList;
    for _, uiItem in pairs(uiItems) do
        if uiItem:IsActive() then
            uiItem:OnClick(bid);
            return;
        end
    end
end
