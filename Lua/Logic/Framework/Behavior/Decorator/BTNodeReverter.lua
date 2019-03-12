BTNodeReverter = class("BTNodeReverter",BTNodeDecorator);

function BTNodeReverter:ctor()
    BTNodeDecorator.ctor(self);
end

function BTNodeReverter:dtor()
    BTNodeDecorator.dtor(self);
end

function BTNodeReverter:OnStart()
end

function BTNodeReverter:OnUpdate(deltaTime,btData)
    local childStatus = self._childNode:Tick(deltaTime,btData);
    if childStatus == BTDefine.NODE_STATUS.RUNNING then return childStatus; end
    if childStatus == BTDefine.NODE_STATUS.SUCCESS then return BTDefine.NODE_STATUS.FAILURE; end
    if childStatus == BTDefine.NODE_STATUS.FAILURE then return BTDefine.NODE_STATUS.SUCCESS; end
end

function BTNodeReverter:OnStop()
end