module("AIMaker",package.seeall)

function InitModule()
    require("Logic/Framework/Behavior/BTDefine");
    require("Logic/Framework/Behavior/BTTree");
    require("Logic/Framework/Behavior/BTFactory").InitModule();

    require("Logic/Entity/Components/AI/Nodes/AINodeBase");

    require("Logic/Entity/Components/AI/Nodes/AINodeMoveManual");
    require("Logic/Entity/Components/AI/Nodes/AINodeMoveCustom");
    require("Logic/Entity/Components/AI/Nodes/AINodeMoveBack");
    
    require("Logic/Entity/Components/AI/Nodes/AINodeSkillSelect");
    require("Logic/Entity/Components/AI/Nodes/AINodeTargetSelect");
    require("Logic/Entity/Components/AI/Nodes/AINodeTargetFollow");
    require("Logic/Entity/Components/AI/Nodes/AINodeSkillCast");
end

function MakePlayerAI(aiComponent)
    --技能逻辑
    local skillNode = BTFactory.AllocNode(BTNodeSequence);          --
    skillNode:AddChild(BTFactory.AllocNode(AINodeSkillSelect));     --技能筛选
    skillNode:AddChild(BTFactory.AllocNode(AINodeTargetSelect));    --目标筛选
    skillNode:AddChild(BTFactory.AllocNode(AINodeTargetFollow));    --追击目标
    skillNode:AddChild(BTFactory.AllocNode(AINodeSkillCast));       --释放技能

    --主动移动
    local moveNode = BTFactory.AllocNode(BTNodeSelector);           --
    moveNode:AddChild(BTFactory.AllocNode(AINodeMoveCustom));       --自定义移动
    moveNode:AddChild(BTFactory.AllocNode(AINodeMoveManual));       --摇杆或点地移动
    moveNode:AddChild(BTFactory.AllocNode(AINodeMoveBack));         --返回挂机点

    --AI根结点
    local rootNode = BTFactory.AllocNode(BTNodeSelector);
    rootNode:AddChild(moveNode);
    rootNode:AddChild(skillNode);

    local btTree = BTTree.new(rootNode,aiComponent._entity._entityAtt.aiData);
    btTree:Set("attacker",aiComponent._entity);
    btTree:Set("aiComponent",aiComponent);
    btTree:Set("moveComponent",aiComponent._entity:GetMoveComponent());
    btTree:Set("stateComponent",aiComponent._entity:GetStateComponent());
    btTree:Set("skillComponent",aiComponent._entity:GetSkillComponent());
    btTree:Set("campComponent",aiComponent._entity:GetCampComponent());
    btTree:Set("propertyComponent",aiComponent._entity:GetPropertyComponent());
    btTree:Set("modelComponent",aiComponent._entity:GetModelComponent());
    
    return btTree;
end

return AIMaker;