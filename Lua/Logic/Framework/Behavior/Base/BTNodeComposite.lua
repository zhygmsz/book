BTNodeComposite = class("BTNodeComposite",BTNodeBase);

function BTNodeComposite:ctor()
    BTNodeBase.ctor(self);
    self._childNodes = {};
end

function BTNodeComposite:dtor()
    BTNodeBase.dtor(self);
    for _,childNode in pairs(self._childNodes) do
        BTFactory.FreeNode(childNode);
    end
    self._childNodes = nil;
end

function BTNodeComposite:AddChild(childNode)
    self._childNodes[#self._childNodes + 1] = childNode;
end

function BTNodeComposite:OnAbort(btData)
    BTNodeBase.OnAbort(self,btData);
    for _,childNode in pairs(self._childNodes) do
        childNode:OnAbort(btData);
    end
end

function BTNodeComposite:OnLog()
    BTNodeBase.OnLog(self);
    for _,childNode in pairs(self._childNodes) do
        childNode:OnLog();
    end
end