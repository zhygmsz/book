local UIPageAndGrid = require("Logic/Presenter/UI/Common/UIPageAndGrid/UIPageAndGrid")
local InteractForClick = require("Logic/Presenter/UI/Common/InteractMode/InteractForClick")

local UIPageAndGridWidget = class("UIPageAndGridWidget")

function UIPageAndGridWidget:ctor(trs, ui, eventIdBase, eventIdSpan)
    --组件
    self._ui = ui
    self._transform = trs
    self._gameObject = trs.gameObject

    --变量
    self._isShowed = false

    --以下两个数据由派生类获取
    self._dataList = nil
    self._numPerPage = 0

    --由派生类根据自己的Item和numPerPage创建
    self._pageAndGrid = nil
    self._eventIdBase = eventIdBase
    self._eventIdSpan = eventIdSpan
    
    self._interactClick = InteractForClick.new(self.OnNor, self.OnSpec, self.OnSameIdClick, self)

    --点击其他spanIdx时触发回调
    self._funcOnClickSpanIdx = nil
end

--[[
    @desc: 构造方法的补充
]]
function UIPageAndGridWidget:CreatePageAndGrid(Item, numPerPage)
    self._numPerPage = numPerPage
    self._pageAndGrid = UIPageAndGrid.new(self._transform, self._ui, Item, numPerPage, 
                                        self._eventIdBase, self._eventIdSpan)
end

function UIPageAndGridWidget:InitFuncOnClickSpanIdx(funcOnClickSpanIdx)
    self._funcOnClickSpanIdx = funcOnClickSpanIdx
end

--[[
    @desc: 来自UI的事件id，在该widget下分发
    --@id: 
]]
function UIPageAndGridWidget:OnClick(id)
    local itemIdx, spanIdx = self._pageAndGrid:CalItemAndSpanIdx(id)
    if spanIdx == 1 then
        --通用交互逻辑
        --这里没有循环利用的概念，所以itemIdx即为dataIdx
        self._interactClick:OnClick(itemIdx)
    else
        --外部需要捕捉到其余事件id
        if self._funcOnClickSpanIdx then
            self._funcOnClickSpanIdx(itemIdx, spanIdx)
        end
    end
end

------------------------------虚方法------------------------------
--[[
    @desc: 点击同一个item回调，交给子类重写
]]
function UIPageAndGridWidget:OnSameIdClick(dataIdx)

end

function UIPageAndGridWidget:OnNor(dataIdx)
    local item = self._pageAndGrid:GetItem(dataIdx)
    if item then
        item:ToNor()
    end
end

function UIPageAndGridWidget:OnSpec(dataIdx)
    local item = self._pageAndGrid:GetItem(dataIdx)
    if item then
        item:ToSpec()
    end
end

function UIPageAndGridWidget:Show()
    self:SetVisible(true)
end

function UIPageAndGridWidget:Hide()
    self:SetVisible(false)
    self._interactClick:Leave()

    self._pageAndGrid:Hide()
end

function UIPageAndGridWidget:OnEnable()
    self._interactClick:OnEnable()
end

function UIPageAndGridWidget:OnDisable()
    self._interactClick:OnDisable()
end

function UIPageAndGridWidget:OnDestroy()
    self._interactClick:OnDestroy()

    self._pageAndGrid:OnDestroy()
end
------------------------------虚方法------------------------------

--[[
    @desc: page数量发生
]]
function UIPageAndGridWidget:ResetPointList()
    
end

function UIPageAndGridWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

return UIPageAndGridWidget
