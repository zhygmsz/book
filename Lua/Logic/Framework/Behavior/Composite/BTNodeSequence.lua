BTNodeSequence = class("BTNodeSequence",BTNodeComposite)

function BTNodeSequence:ctor()
    BTNodeComposite.ctor(self);
end

function BTNodeSequence:dtor()
    BTNodeComposite.dtor(self);
end

function BTNodeSequence:OnStart()
    self._childIndex = 1;
end

function BTNodeSequence:OnUpdate(deltaTime,btData)
    --继续执行上次运行中的子结点,全部成功则返回成功,有一个失败则返回失败
    local childStatus = nil;
    for i = self._childIndex,#self._childNodes do
        childStatus = self._childNodes[i]:Tick(deltaTime,btData);
        if childStatus == BTDefine.NODE_STATUS.FAILURE then return childStatus; end
        if childStatus == BTDefine.NODE_STATUS.RUNNING then self._childIndex = i; return childStatus; end
    end
    return BTDefine.NODE_STATUS.SUCCESS;
end

function BTNodeSequence:OnStop()
end