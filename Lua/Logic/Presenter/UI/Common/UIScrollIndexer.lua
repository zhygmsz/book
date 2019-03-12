--指示图标，用来指示可滑动图片的位置
--0 0 0 * 0--
local UIScrollIndexer = class("UIScrollIndexer");

function UIScrollIndexer:ctor(uiFrame,rootTran)
    self._uiFrame = uiFrame;
    self._indexTrans = rootTran:Find("Indexer");
    self._gridTrans = rootTran:Find("Grid");
    self._grid = self._gridTrans:GetComponent("UIGrid");
    self._prefab = rootTran:Find("Grid/Prefab");
end

function UIScrollIndexer:Reset(count)
    UIGridTableUtil.CreateChild(self._uiFrame,self._prefab,count);
    self._grid:Reposition();
    self:SetIndex(0);
end

--从0开始
function UIScrollIndexer:SetIndex(index)
    local max = self._gridTrans.childCount;
    if index < 0 or index >= max then
        GameLog.LogError("Index %s id invalid",index);
        return;
    end
    local targetTrans = self._gridTrans:GetChild(index);
    self._indexTrans.localPosition = targetTrans.localPosition;
end
return UIScrollIndexer;