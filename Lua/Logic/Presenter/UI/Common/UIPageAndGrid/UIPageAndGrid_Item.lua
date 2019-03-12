local UIPageAndGridItem = class("UIPageAndGridItem")

function UIPageAndGridItem:ctor(trs, eventIdBase, eventIdSpan)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._widget = trs:GetComponent("UIWidget")
    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")

    self._uiEvent = trs:GetComponent("GameCore.UIEvent")
    self._uiEvent.id = eventIdBase + 1

    --变量
    self._isShowed = false
    self._data = nil
    --当前item所处的数据列表索引
    self._dataIdx = -1
    
    --检查是否需要nor和spec基本UI表现
    --不需要表现的UI则不要这两个go，算是一个内存上的优化
    --不过最好在上层传递一个变量用来标识是否需要Nor和Spec标识
    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    self._eventIdBase = eventIdBase
    self._eventIdSpan = eventIdSpan
end

------------------------------虚方法------------------------------
--[[
    @desc: 
    --@data:
	--@dataIdx: 数组里的索引
]]
function UIPageAndGridItem:Show(data, dataIdx)
    self:SetVisible(true)
    
    self._data = data
    self._dataIdx = dataIdx
end

function UIPageAndGridItem:Hide()
    self:SetVisible(false)
    self:ToNor()
    self._data = nil
end

function UIPageAndGridItem:OnDestory()
    
end
------------------------------虚方法------------------------------

--[[
    @desc: 子类构造方法最后，调用该方法
]]
function UIPageAndGridItem:Init()
    self:ToNor()
    self:Hide()
end

function UIPageAndGridItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function UIPageAndGridItem:IsShowed()
    return self._isShowed
end

function UIPageAndGridItem:ToNor()
    if self._hasNorAndSpec then
        self._specGo:SetActive(false)
        self._norGo:SetActive(true)
    end
end

function UIPageAndGridItem:ToSpec()
    if self._hasNorAndSpec then
        self._norGo:SetActive(false)
        self._specGo:SetActive(true)
    end
end

function UIPageAndGridItem:GetDataIdx()
    return self._dataIdx
end

function UIPageAndGridItem:GetData()
    return self._data
end

return UIPageAndGridItem