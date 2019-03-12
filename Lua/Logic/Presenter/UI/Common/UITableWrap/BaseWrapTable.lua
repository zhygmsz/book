--[[deprecated-----Use UICommonCollapseTableWrap  or BaseWrapTableEx]]
require("Logic/Presenter/UI/Common/UITableWrap/UITableWrapUtils");
BaseWrapTable = class("BaseWrapTable", nil)

function BaseWrapTable:ctor(ui,path,count,context)

    local tableTrans = ui:Find(path.."/WrapTable");
    self._scrollTrans = ui:Find(path);
    self._scrollPanel = self._scrollTrans:GetComponent("UIPanel");
    self._context = context;
    local wrapItemPrefab = tableTrans:Find("ItemPrefab");
    local function OnItemCreate(...)
        self:OnItemCreate(...);
    end

    local wrapItemList = UITableWrapUtils.InitWrapTable(ui,wrapItemPrefab,count,tableTrans,OnItemCreate);

    self._tableWrapContent = tableTrans:GetComponent("UITableWrapContent");

    local OnItemInit = function(go,wrapIndex,realIndex)
        local OnItemEnabled = function(wrapData, wrapItem)
            local type = wrapData.GetType and wrapData:GetType() or wrapData.type;
            wrapItem[type]:Refresh(wrapData);
            if wrapItem[type].SetActive then
                wrapItem[type]:SetActive(true);
            else
                wrapItem[type].gameObject:SetActive(true);
            end
            if wrapItem[type].GetWidget then
                return wrapItem[type]:GetWidget(), 0;
            else
                return wrapItem[type].widget, 0;
            end
        end
        UITableWrapUtils.OnItemInit(go,wrapIndex,realIndex, wrapItemList, self._wrapDataList, OnItemEnabled);
    end
    self._onInitItemFunc = UITableWrapContent.OnInitializeItem(OnItemInit);

end

function BaseWrapTable:ResetWrapContent(dataList,itemAlignType, dataAlignType)
    self._wrapDataList = dataList;
    self._itemAlignType = itemAlignType;
    self._dataAlignType = dataAlignType;
    self._scrollTrans.localPosition = Vector3.zero;
    self._scrollPanel.clipOffset = Vector2.zero;
    self._tableWrapContent:ResetWrapContent(table.maxn(self._wrapDataList), self._onInitItemFunc,self._itemAlignType, self._dataAlignType,true);
end

function BaseWrapTable:UpdateContent(oldcount,newcount)
    newcount = newcount or table.maxn(self._wrapDataList);
    oldcount = oldcount or 1;
    if oldcount > 2 then
        oldcount = oldcount -2;--C#脚本的bug
        self._tableWrapContent:UpdateContent(oldcount, newcount);
    else
        self._tableWrapContent:ResetWrapContent(table.maxn(self._wrapDataList), self._onInitItemFunc,self._itemAlignType, self._dataAlignType,true);
    end
end

function BaseWrapTable:GetData(index)
    return self._wrapDataList[index];
end

function BaseWrapTable:OnDisable()
    self._wrapDataList = nil;
    self._itemAlignType = nil;
    self._dataAlignType = nil;
end

function BaseWrapTable:OnDestroy()
    self._scrollTrans = nil;
    self._scrollPanel = nil;
    self._tableWrapContent = nil;
    self._onInitItemFunc = nil;
end

return BaseWrapTable