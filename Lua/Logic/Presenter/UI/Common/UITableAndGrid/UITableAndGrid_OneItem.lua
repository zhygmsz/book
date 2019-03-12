local OneItem = class("OneItem")

function OneItem:ctor(trs, funcOnClick, funcGetTwoItem, bottomOffset, hasBg)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._widget = trs:GetComponent("UIWidget")

    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")

    self._bg = trs:Find("bg"):GetComponent("UISprite")
    self._bgGo = self._bg.gameObject

    self._girdTrs = trs:Find("grid")
    self._gridGo = self._girdTrs.gameObject
    self._grid = self._girdTrs:GetComponent("UIGrid")
    local pos = self._girdTrs.localPosition
    self._gridOriginPos = Vector3(pos.x, pos.y, pos.z)

    self._lis = UIEventListener.Get(self._gameObject)
    self._lis.onClick = UIEventListener.VoidDelegate(self.OnClick, self)

    self:InitUI()

    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    --变量
    self._sourceData = nil
    self._oneDataIdx = -1
    self._data = nil
    self._isShowed = false
    self._widgetH = self._widget.height
    self._funcOnClick = funcOnClick
    self._funcGetTwoItem = funcGetTwoItem
    self._lastTwoItem = nil
    self._expanded = false  --是否处于展开状态
    self._bottomOffset = bottomOffset
    self._hasBg = hasBg

    self:ToNor()
    self:Hide()
end

------------------------------虚方法------------------------------
--[[
    @desc: 虚方法，在Hide前获取完所有的UI控件
]]
function OneItem:InitUI()
    
end

--[[
    @desc: 虚方法
    --@sourceData: { xxx, list = { {xxx}, {xxx},} }
	--@oneDataIdx: 在data数组里的索引
]]
function OneItem:Show(sourceData, oneDataIdx)
    self:SetVisible(true)

    self._sourceData = sourceData
    self._oneDataIdx = oneDataIdx
    self._data = sourceData[oneDataIdx]
end

function OneItem:Hide()
    self:SetVisible(false)

    self._sourceData = nil

    self:ToNor()
end

function OneItem:OnDestroy()
    
end
------------------------------虚方法------------------------------

function OneItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function OneItem:IsShowed()
    return self._isShowed
end

function OneItem:SetExpanded(expanded)
    self._expanded = expanded
end

function OneItem:GetExpanded()
    return self._expanded
end

function OneItem:ToNor()
    if self._hasNorAndSpec then
        self._specGo:SetActive(false)
        self._norGo:SetActive(true)
    end

    --处理bg和widget
    self._bgGo:SetActive(false)
    self._gridGo:SetActive(false)
    self._widget.bottomAnchor.target = nil
    self._widget:ResetAndUpdateAnchors()
    self._widget.height = self._widgetH
    self._widget:Update()

    self:SetExpanded(false)
end

function OneItem:GetTwoItem()
    if self._funcGetTwoItem then
        return self._funcGetTwoItem()
    end
end

function OneItem:InitGrid()
    self._gridGo:SetActive(true)

    for idx, _ in ipairs(self._data.list) do
        local twoItem = self:GetTwoItem()
        if twoItem then
            twoItem:SetParent(self._girdTrs)
            twoItem:Show(self._sourceData, self._oneDataIdx, idx)
            self._lastTwoItem = twoItem
        end
    end

    self._grid:Reposition()
    self._girdTrs.localPosition = self._gridOriginPos 
end

function OneItem:InitBg()
    if not self._hasBg then
        self._bgGo:SetActive(false)
        return
    end
    if not self._lastTwoItem then
        self._bgGo:SetActive(false)
        return
    end
    self._bgGo:SetActive(true)
    local h1 = self._bg.height
    self._bg.bottomAnchor.target = self._lastTwoItem:GetTransform()
    self._bg.bottomAnchor.relative = 0
    self._bg.bottomAnchor.absolute = self._bottomOffset
    self._bg:ResetAndUpdateAnchors()
    self._bg:Update()
end

function OneItem:InitWidget()
    if not self._lastTwoItem then
        self._widget.height = self._widgetH
        return
    end
    local h1 = self._widget.height
    self._widget.bottomAnchor.target = self._lastTwoItem:GetTransform()
    self._widget.bottomAnchor.relative = 0
    self._widget.bottomAnchor.absolute = -5
    self._widget:ResetAndUpdateAnchors()
end

function OneItem:ToSpec()
    if self._hasNorAndSpec then
        self._norGo:SetActive(false)
        self._specGo:SetActive(true)
    end

    --组装grid
    self:InitGrid()
    --设置bg的锚点
    self:InitBg()
    --设置widget的锚点
    self:InitWidget()

    self:SetExpanded(true)
end

function OneItem:OnClick(eventData)
    if self._funcOnClick then
        self._funcOnClick(self._oneDataIdx)
    end
end

function OneItem:GetSourceData()
    return self._sourceData
end

function OneItem:GetOneDataIdx()
    return self._oneDataIdx
end

function OneItem:GetOneData()
    return self._data
end

return OneItem