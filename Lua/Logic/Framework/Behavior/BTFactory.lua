module("BTFactory",package.seeall)

local mNodePool = {};

function AllocNode(nodeType,...)
    local nodePool = mNodePool[nodeType];
    if not nodePool or #nodePool <= 0 then return nodeType.new(...) end
    local node = nodePool[#nodePool];
    nodePool[#nodePool] = nil;
    node:ctor(...);
    return node;
end

function FreeNode(node)
    local nodePool = mNodePool[node.class] or {};
    mNodePool[node.class] = nodePool;
    nodePool[#nodePool + 1] = node;
    node:dtor();
end

function InitModule()
    require("Logic/Framework/Behavior/Base/BTNodeBase");
    require("Logic/Framework/Behavior/Base/BTNodeComposite");
    require("Logic/Framework/Behavior/Base/BTNodeDecorator");
    require("Logic/Framework/Behavior/Base/BTNodeLeaf");

    require("Logic/Framework/Behavior/Composite/BTNodeParallel");
    require("Logic/Framework/Behavior/Composite/BTNodeSelector");
    require("Logic/Framework/Behavior/Composite/BTNodeSequence");

    require("Logic/Framework/Behavior/Decorator/BTNodeRepeater");
    require("Logic/Framework/Behavior/Decorator/BTNodeReverter");
    require("Logic/Framework/Behavior/Decorator/BTNodeUntilFailure");
    require("Logic/Framework/Behavior/Decorator/BTNodeUntilSuccess");
end

return BTFactory;