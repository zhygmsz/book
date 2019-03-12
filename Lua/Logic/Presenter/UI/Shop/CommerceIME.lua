
------------------------------------IMEItem------------------------------------
local IMEItem = class("IMEItem")
function IMEItem:ctor(trs, funcOnNumClick, funcOnBackClick, funcOnOKClick, funcOnAutoIdRollback)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject
    self._bgGo = trs:Find("bg").gameObject
    self._btnGoList = {}
    local lis
    for idx = 1, 12 do
        self._btnGoList[idx] = trs:Find("btnlist/btn" .. tostring(idx - 1)).gameObject
        lis = UIEventListener.Get(self._btnGoList[idx])
        lis.onClick = UIEventListener.VoidDelegate(self.OnBtnClick, self)
    end
    self._btnGoList[#self._btnGoList + 1] = self._bgGo

    --变量
    self._isShowed = false
    self._funcOnNumClick = funcOnNumClick
    self._funcOnBackClick = funcOnBackClick
    self._funcOnOKClick = funcOnOKClick
    self._funcOnAutoIdRollback = funcOnAutoIdRollback
    --用于记录打开的次数，每次Show，自增1
    self._autoId = -1
    self._maxAutoId = 5

    self:Hide()
end

function IMEItem:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function IMEItem:IsShowed()
    return self._isShowed
end

function IMEItem:Show()
    self:SetVisible(true)
    self:AutoIdIncrement()
end

function IMEItem:AutoIdIncrement()
    self._autoId = self._autoId + 1
    if self._autoId > self._maxAutoId then
        self._autoId = 0
        if self._funcOnAutoIdRollback then
            self._funcOnAutoIdRollback()
        end
    end
end

function IMEItem:GetAutoId()
    return self._autoId
end

function IMEItem:Hide()
    self:SetVisible(false)
end

--所有按钮主入口，再根据按钮类型向外抛出
function IMEItem:OnBtnClick(go)
    if tolua.isnull(go) then
        return
    end
    local id = tonumber(string.sub(go.name, 4))
    if 0 <= id and id <= 9 then
        if self._funcOnNumClick then
            self._funcOnNumClick(id)
        end
    elseif id == 10 then
        --10为回退
        if self._funcOnBackClick then
            self._funcOnBackClick()
        end
    elseif id == 11 then
        --11为ok
        if self._funcOnOKClick then
            self._funcOnOKClick()
        end
    end
end

--检测当前press是否点击到了ime内
function IMEItem:CheckPressInIME(go)
    if tolua.isnull(go) then
        return false
    end
    for _, btnGo in ipairs(self._btnGoList) do
        if not tolua.isnull(btnGo) and btnGo == go then
            return true
        end
    end
    return false
end

return IMEItem
------------------------------------IMEItem------------------------------------