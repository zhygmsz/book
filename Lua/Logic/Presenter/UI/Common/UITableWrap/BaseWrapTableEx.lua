--UITable的加上 LoopScrollViewEx 版本,一般用来展示聊天内容。
local MAX_LABEL_COUNT = 30;
local MAX_SPRITE_COUNT = 30;
require("Logic/Presenter/UI/Common/UITableWrap/UITableWrapUtils");
BaseWrapTableEx = class("BaseWrapTableEx", nil);

function BaseWrapTableEx:OnItemCreate(wrapTrans,index)
    local wrapItem = {};
    wrapItem.transform = wrapTrans;
    wrapItem.gameObject = wrapTrans.gameObject;
    wrapItem.widget = wrapTrans:GetComponent("UIWidget");
    wrapItem.uiList = {};
    for i,wrapUI in ipairs(self._wrapUIs) do
        --(root,baseEventID,ui,uiName)
        local uiItem = wrapUI.new(wrapTrans,self._baseEvent+(index-1)*self._eventSpan,self._ui,self._context);
        local uiType = uiItem:GetType();
        wrapItem.uiList[uiType] = uiItem;
    end
    self._wrapItemList[index] = wrapItem;
end

function BaseWrapTableEx:OnItemInit(go,dataIndex,wrapIndex)
    dataIndex = dataIndex + 1;
    wrapIndex = wrapIndex + 1;
    local wrapItem =  self._wrapItemList[wrapIndex];
    local wrapData =  self._wrapDataList[dataIndex];
    if not wrapData then
        go:SetActive(false);
        return;
    end
    go:SetActive(true);


    local targetType = self._data_ui_hash[wrapData.__cname];
    if not targetType then 
        targetType = self._data_ui_hash[wrapData:GetType()];
    end

    if not targetType then
        GameLog.LogError("Not Found UI for Data %s", dataType);
    end

    local targetUI = nil;

    for uiType,wrapui in pairs(wrapItem.uiList) do
        if uiType == targetType then
            wrapui:SetActive(true);
            targetUI = wrapui;
        else
            wrapui:SetActive(false);
        end
    end
    if not targetUI then
        GameLog.LogError("Not found Target UI %s ",tagetType);
        return;
    end

    targetUI:DispatchData(wrapData);
    targetUI:OnRefresh();
    local widget,offset = targetUI:GetWidget();
    if widget then
        widget:Update();
        widget:UpdateAnchors();
        wrapItem.widget.height = widget.height + (offset or 0);
    end
end

function BaseWrapTableEx:OnLockStateChange(lock)
    GameLog.LogError("locked = %s",lock);
    self._lock = lock;
    if not lock then self:ResetWrapContent(self._wrapDataList, true); end
end

function BaseWrapTableEx:ctor(ui,path,count,wrapUIs,baseEvent,eventSpan,context)
    self._ui = ui;
    self._context = context;
    self._wrapUIs = wrapUIs;
    self._baseEvent = baseEvent;
    self._eventSpan = eventSpan or 2;

    local tableTrans = ui:Find(path.."/WrapTableLoop");
    self._scrollTrans = ui:Find(path);
    self._scrollPanel = self._scrollTrans:GetComponent("UIPanel");
    self._tableGo = tableTrans.gameObject;

    self._wrapItemList = {};
    local wrapItemPrefab = tableTrans:Find("ItemPrefab");

    UIGridTableUtil.CreateChild(ui,wrapItemPrefab,count,tableTrans,self.OnItemCreate,self);
    self._tableWrapContent = tableTrans:GetComponent("LoopScrollViewEx");

    self._tableWrapContent:Init();
	self._tableWrapContent:InitGoList();
    local onInitItemFunc = LoopScrollViewEx.OnItemChange(self.OnItemInit, self);
    local onLockChange = System.Action_bool(self.OnLockStateChange,self);
	self._tableWrapContent:SetDelegate(onInitItemFunc,onLockChange);
    self._tableWrapContent:InitAlign(1);
    
    self._data_ui_hash = {};
end
function BaseWrapTableEx:RegisterData(dataType,uiType)
    self._data_ui_hash[dataType] = uiType;
end

--[[
@desc: 
author:{hesinian}
time:2019-03-05 17:45:05
--@dataList: 要刷新的数据
--@refreshAll: 是否全部刷新:当添加新数据的时候 = false,当需要重刷全屏的ui = true;
@return:
]]
function BaseWrapTableEx:ResetWrapContent(dataList,refreshAll)
    self._wrapDataList = dataList;

    if self._lock then return; end

    self._scrollTrans.localPosition = Vector3.zero;
    self._scrollPanel.clipOffset = Vector2.zero;
    --self._tableWrapContent:ResetWrapContent();

    self._tableWrapContent:Refresh(table.maxn(self._wrapDataList), -1, refreshAll, false)
end
--只刷新数值，不改变UI位置和大小
function BaseWrapTableEx:UpdateWithPosition()
    for i, wrapItem in ipairs(self._wrapItemList) do
        for uiType,wrapui in pairs(wrapItem.uiList) do
            wrapui:OnRefresh();
        end
    end
end

function BaseWrapTableEx:GetData(index)
    return self._wrapDataList[index];
end

--点击事件
function BaseWrapTableEx:OnClick(eventid)
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

return BaseWrapTableEx;