module("UITableWrapUtils",package.seeall)

function InitWrapTable(ui,prefab,count,parentTrans,OnItemCreat,par)
    parentTrans = parentTrans and parentTrans or prefab.parent;
    -- prefab.gameObject:SetActive(false);
    for i =0,prefab.childCount-1 do
        local child = prefab:GetChild(i);
        local pos = child.localPosition;
        child.localPosition = Vector3.New(pos.x,0,0);
        --child.gameObject:SetActive(false);
    end

    local itemList = {};
    itemList[1] = {};
    itemList[1].transform = prefab;
    for i=2,count do
        itemList[i]= {};
        itemList[i].transform = ui:DuplicateAndAdd(prefab,parentTrans,i); 
    end
    for i=1,count do
        local contentItem = itemList[i];
        contentItem.gameObject = contentItem.transform.gameObject;
        contentItem.widget = contentItem.transform:GetComponent("UIWidget");
        if par and OnItemCreat then
            OnItemCreat(par, contentItem,i);
        elseif OnItemCreat then
            OnItemCreat(contentItem,i);
        end
    end
    return itemList;
end
    
function OnItemInit(go,wrapIndex,realIndex,wrapItemList, wrapDataList, OnItemEnabled)
    realIndex = realIndex + 1;
    wrapIndex = wrapIndex + 1;
    if not wrapDataList[realIndex] then
        go:SetActive(false);
        return;
    end
    go:SetActive(true);
    local wrapItem = wrapItemList[wrapIndex];
    local wrapData = wrapDataList[realIndex];
    for i = 0, wrapItem.transform.childCount-1 do
        local child = wrapItem.transform:GetChild(i);
        child.gameObject:SetActive(false);
    end
    local widget, offset = OnItemEnabled(wrapData,wrapItem);
    if widget then
        widget:Update();
        widget:UpdateAnchors();
        wrapItem.widget.height = widget.height + offset;
    end
end

