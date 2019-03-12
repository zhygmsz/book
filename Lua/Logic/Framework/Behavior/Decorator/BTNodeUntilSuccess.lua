BTNodeUntilSuccess = class("BTNodeUntilSuccess",BTNodeDecorator);

function BTNodeUntilSuccess:ctor()
    BTNodeDecorator.ctor(self);
end

function BTNodeUntilSuccess:dtor()
    BTNodeDecorator.dtor(self);
end

function BTNodeUntilSuccess:OnStart()
end

function BTNodeUntilSuccess:OnUpdate(deltaTime,btData)
    local childStatus = self._childNode:Tick(deltaTime,btData);
    if childStatus ~= BTDefine.NODE_STATUS.SUCCESS then 
        return BTDefine.NODE_STATUS.RUNNING;
    else
        return childStatus;
    end
end

function BTNodeUntilSuccess:OnStop()
end