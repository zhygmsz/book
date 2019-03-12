local TwoItem = class("TwoItem")

function TwoItem:ctor(trs, funcOnClick)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._norGo = NGUITools.FindGo(trs, "nor")
    self._specGo = NGUITools.FindGo(trs, "spec")

    self._lis = UIEventListener.Get(self._gameObject)
    self._lis.onClick = UIEventListener.VoidDelegate(self.OnClick, self)

    self:InitUI()

    --变量
    self._sourceData = nil
    self._oneDataIdx = -1
    self._twoDataIdx = -1
    self._data = nil
    self._isShowed = false
    self._funcOnClick = funcOnClick
    self._zero = Vector3.zero
    self._one = Vector3.one

    if not tolua.isnull(self._norGo) and not tolua.isnull(self._specGo) then
        self._hasNorAndSpec = true
    else
        self._hasNorAndSpec = false
    end

    self:ToNor()
    self:Hide()
end

------------------------------虚方法------------------------------
--[[
    @desc: 虚方法，在Hide前获取完所有的UI控件
]]
function TwoItem:InitUI()
    
end

--[[
    @desc: 
    --@sourceData:
	--@oneDataIdx:
	--@twoDataIdx: 
]]
function TwoItem:Show(sourceData, oneDataIdx, twoDataIdx)
    self:SetVisible(true)

    self._sourceData = sourceData
    self._oneDataIdx = oneDataIdx
    self._twoDataIdx = twoDataIdx

    self._data = sourceData[oneDataIdx].list[twoDataIdx]
end

function TwoItem:Hide()
    self:SetVisible(false)

    self._sourceData = nil
    self._oneDataIdx = -1
    self._twoDataIdx = -1
    self._data = nil

    self:ToNor()
end

function TwoItem:OnDestroy()
    
end
------------------------------虚方法------------------------------

function TwoItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function TwoItem:IsShowed()
    return self._isShowed
end

function TwoItem:ToNor()
    if self._hasNorAndSpec then
        self._specGo:SetActive(false)
        self._norGo:SetActive(true)
    end
end

function TwoItem:ToSpec()
    if self._hasNorAndSpec then
        self._norGo:SetActive(false)
        self._specGo:SetActive(true)
    end
end

function TwoItem:OnClick(eventData)
    if self._funcOnClick then
        self._funcOnClick(self._twoDataIdx)
    end
end

function TwoItem:SetParent(parent)
    self._transform.parent = parent
    self._transform.localPosition = self._zero
    self._transform.localScale = self._one
end

function TwoItem:GetTransform()
    return self._transform
end

function TwoItem:GetSourceData()
    return self._sourceData
end

function TwoItem:GetOneDataIdx()
    return self._oneDataIdx
end

function TwoItem:GetTwoDataIdx()
    return self._twoDataIdx
end

function TwoItem:GetTwoData()
    return self._data
end

return TwoItem