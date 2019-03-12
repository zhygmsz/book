
BaseWrapContentUI = class("BaseWrapContentUI");

function BaseWrapContentUI:ctor(wrapItemTrans,context)
    self._gameObject = wrapItemTrans.gameObject;
    self._events = {};
    self._context = context;
end

function BaseWrapContentUI:SetActive(b)
    self._gameObject:SetActive(b);
end

--插入UIEvent
function BaseWrapContentUI:InsertUIEvent(event)
    table.insert(self._events,event);
end
--设置点击回调
function BaseWrapContentUI:SetOnClick(callbacks,caller,eventId)
    self._callbacks = callbacks;
    self._caller = caller;
    for i = 1,#self._events do
        self._events[i].id = eventId -1 + i;
    end
end
--分配data
function BaseWrapContentUI:DispatchData(wrapData)
    self._data = wrapData;
end

--是否是目标
function BaseWrapContentUI:IsTarget(data)
    if not data then return false; end
    return data == self._data;
end

--刷新UI
function BaseWrapContentUI:OnRefresh()

end

function BaseWrapContentUI:OnClick(buttonId)
    local callback = nil;
    if type(self._callbacks) == "function" then
        callback = self._callbacks;
    else
        callback= self._callbacks[buttonId];
    end
    GameUtils.TryInvokeCallback(callback,self._caller,self._data,self);
end

return BaseWrapContentUI;