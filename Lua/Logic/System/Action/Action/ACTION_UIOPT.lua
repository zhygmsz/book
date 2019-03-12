ACTION_UIOPT = class("ACTION_UIOPT",ACTION_BASE);

function ACTION_UIOPT:ctor(...)
    ACTION_BASE.ctor(self,...);
    self._optType = self._actionData.intParams[1];
    self._uiName = self._actionData.params[1];
    self._funcName = self._actionData.params[2];
    self._actionBegin = false;
end

function ACTION_UIOPT:OnUpdate(deltaTime)
    if not self._actionBegin then
        self._actionBegin = true;
        local uiData = AllUI[self._uiName];
        if uiData then
            if self._optType == 0 then
                --关闭UI
                self._actionDone = true;
                UIMgr.UnShowUI(uiData);
            elseif self._optType == 1 then
                --打开UI
                UIMgr.ShowUI(uiData,self,self.OnUIOpen,nil,nil,true,self._actionData);
            elseif self._optType == 2 then
                --执行UI函数
                self._actionDone = true;
                if uiData.luaScript.OnAction then
                    uiData.luaScript.OnAction(self._funcName,self._actionData);
                else
                    GameLog.LogError("can't find ui onaction %s",self._uiName);
                end
            end
        else
            GameLog.LogError("can't find ui %s",self._uiName);
            self._actionDone = true;
        end
    end
end

function ACTION_UIOPT:OnUIOpen()
    self._actionDone = true;
end

return ACTION_UIOPT;