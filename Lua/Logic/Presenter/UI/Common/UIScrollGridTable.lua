--UIScrollView下带有table或者grid窗口
UIScrollGridTable = class("UIScrollGridTable");
function UIScrollGridTable:ctor(uiFrame,scrollPath)
    self._uiFrame = uiFrame;
    self._scrollTrans = uiFrame:Find(scrollPath);
    self._scrollPanel = self._scrollTrans:GetComponent("UIPanel");
    self._scrollView = self._scrollTrans:GetComponent("UIScrollView");
    self._itemParent = uiFrame:Find(scrollPath.."/Grid");
    self._wrapTable = self._itemParent:GetComponent("UIGrid");--("UIWrapContentOrigin");
    self._wrapTable = self._wrapTable or self._itemParent:GetComponent("UITable");
    self._itemPrefab = uiFrame:Find(scrollPath.."/Grid/ItemPrefab");
end

function UIScrollGridTable:ResetWrapContent(count,OnCreate,caller)
    UIGridTableUtil.CreateChild(self._uiFrame,self._itemPrefab,count,self._itemParent,OnCreate,caller);
    self._wrapTable:Reposition();
    self:ResetInitPosition();
end

function UIScrollGridTable:ResetInitPosition()
    self._scrollTrans.localPosition = Vector3.zero;  
    self._scrollView.resetOffset = Vector3.zero;
    self._scrollPanel.clipOffset = Vector2.zero;
end

return UIScrollGridTable;