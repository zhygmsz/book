BTNodeDecorator = class("BTNodeDecorator",BTNodeBase);

function BTNodeDecorator:ctor()
    BTNodeBase.ctor(self);
    self._childNode = nil;
end

function BTNodeDecorator:dtor()
    BTNodeBase.dtor(self);
    BTFactory.FreeNode(self._childNode);
    self._childNode = nil;
end

function BTNodeDecorator:AddChild(childNode)
    self._childNode = childNode;
end

function BTNodeDecorator:OnAbort(btData)
    BTNodeBase.OnAbort(self,btData);
    self._childNode:OnAbort(btData);
end

function BTNodeDecorator:OnLog()
    BTNodeBase.OnLog(self);
    self._childNode:OnLog();
end