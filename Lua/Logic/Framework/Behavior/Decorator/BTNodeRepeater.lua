BTNodeRepeater = class("BTNodeRepeater",BTNodeDecorator);

function BTNodeRepeater:ctor(maxExecuteCount)
    BTNodeDecorator.ctor(self);
    self._maxExecuteCount = maxExecuteCount;
end

function BTNodeRepeater:dtor()
    BTNodeDecorator.dtor(self);
end

function BTNodeRepeater:OnStart()
    self._executeCount = 0;
end

function BTNodeRepeater:OnUpdate(deltaTime,btData)
    local childStatus = self._childNode:Tick(deltaTime,btData);
    self._executeCount = self._executeCount + 1;
    if self._executeCount < self._maxExecuteCount then
        return BTDefine.NODE_STATUS.RUNNING;
    else
        return BTDefine.NODE_STATUS.SUCCESS;
    end
end

function BTNodeRepeater:OnStop()
end