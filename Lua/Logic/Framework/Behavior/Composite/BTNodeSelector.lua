BTNodeSelector = class("BTNodeSelector",BTNodeComposite)

function BTNodeSelector:ctor()
    BTNodeComposite.ctor(self);
end

function BTNodeSelector:dtor()
    BTNodeComposite.dtor(self);
end

function BTNodeSelector:OnStart()
    self._childIndex = 1;
end

function BTNodeSelector:OnUpdate(deltaTime,btData)
    --继续执行上次运行中的子结点,全部失败则返回失败,有一个成功则返回成功
    local childStatus = nil;
    for i = self._childIndex,#self._childNodes do
        childStatus = self._childNodes[i]:Tick(deltaTime,btData);
        if childStatus == BTDefine.NODE_STATUS.SUCCESS then return childStatus; end
        if childStatus == BTDefine.NODE_STATUS.RUNNING then self._childIndex = i; return childStatus; end
    end
    return BTDefine.NODE_STATUS.FAILURE;
end

function BTNodeSelector:OnStop()
end