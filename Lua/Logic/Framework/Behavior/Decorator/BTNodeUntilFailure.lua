BTNodeUntilFailure = class("BTNodeUntilFailure",BTNodeDecorator);

function BTNodeUntilFailure:ctor()
    BTNodeDecorator.ctor(self);
end

function BTNodeUntilFailure:dtor()
    BTNodeDecorator.dtor(self);
end

function BTNodeUntilFailure:OnStart()
end

function BTNodeUntilFailure:OnUpdate(deltaTime,btData)
    local childStatus = self._childNode:Tick(deltaTime,btData);
    if childStatus ~= BTDefine.NODE_STATUS.FAILURE then 
        return BTDefine.NODE_STATUS.RUNNING;
    else
        return childStatus;
    end
end

function BTNodeUntilFailure:OnStop()
end