--交互模式 - 点击

local InteractForClick = class("InteractForClick")

function InteractForClick:ctor(funcOnNor, funcOnSpec, funcOnClickSame, obj)
    --变量
    self._funcOnNor = funcOnNor
    self._funcOnSpec = funcOnSpec
    self._funcOnClickSame = funcOnClickSame
    self._obj = obj

    self._curDataIdx = nil
end

function InteractForClick:DoInvoke(func, dataIdx)
    if func then
        if self._obj then
            func(self._obj, dataIdx)
        else
            func(dataIdx)
        end
    end
end

function InteractForClick:InvokeOnNor(dataIdx)
    if not dataIdx then
        return
    end

    self:DoInvoke(self._funcOnNor, dataIdx)
end

function InteractForClick:InvokeOnSpec(dataIdx)
    if not dataIdx then
        return
    end

    self:DoInvoke(self._funcOnSpec, dataIdx)
end

function InteractForClick:InvokeOnClickSame(dataIdx)
    if not dataIdx then
        return
    end

    self:DoInvoke(self._funcOnClickSame, dataIdx)
end

function InteractForClick:OnClick(dataIdx)
    if not dataIdx then
        return
    end
    
    if self._curDataIdx and self._curDataIdx == dataIdx then
        self:InvokeOnClickSame(dataIdx)
    else
        self:InvokeOnNor(self._curDataIdx)
        self._curDataIdx = dataIdx
        self:InvokeOnSpec(self._curDataIdx)
    end
end

function InteractForClick:Clear()
    self._curDataIdx = nil
end

function InteractForClick:Leave()
    self:InvokeOnNor(self._curDataIdx)
    self._curDataIdx = nil
end

function InteractForClick:GetCurDataIdx()
    return self._curDataIdx or -1
end

function InteractForClick:OnEnable()
    
end

function InteractForClick:OnDisable()
    self:Leave()
end

function InteractForClick:OnDestroy()
    self:Clear()
end

return InteractForClick