module("ItemFlyingMgr", package.seeall)

function InitData()
    
end

function InitModule()
    
end

--[[
    list 为 待飞的itemlist
    list需要两个信息 1. itemId  2.目标背包 bagType
]]

function AddItemList(list)
    local function TriggerEvent()
        GameEvent.Trigger(EVT.FLYITEM, EVT.FLYITEM_ADDITEM, list)
    end
    if not AllUI.UI_Item_Flying.enable then
        UIMgr.ShowUI(AllUI.UI_Item_Flying, nil, TriggerEvent)
    else
        GameEvent.Trigger(EVT.FLYITEM, EVT.FLYITEM_ADDITEM, list)
    end
end

return  ItemFlyingMgr