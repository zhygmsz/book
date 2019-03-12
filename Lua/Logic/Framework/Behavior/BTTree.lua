BTTree = class("BTTree");

function BTTree:ctor(rootNode,btData)
    self._btData = btData or {};
    self._rootNode = rootNode;
end

function BTTree:dtor()
    BTFactory.FreeNode(self._rootNode);
    self._rootNode = nil;
    self._btData = nil;
end

function BTTree:Tick(deltaTime)
    self._rootNode:Tick(deltaTime,self._btData);
end

function BTTree:Reset()
    self._rootNode:OnAbort(self._btData);
end

function BTTree:Set(key,value)
    self._btData[key] = value;
end

function BTTree:Get(key)
    return self._btData[key];
end

function BTTree:Log()
    self._rootNode:OnLog();
end