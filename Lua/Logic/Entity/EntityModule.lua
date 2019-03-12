module("EntityModule",package.seeall);

function InitModule()
    --实体定义、管理、缓存相关脚本
    require("Logic/Entity/EntityDefine").InitModule();
    require("Logic/Entity/EntityFactory").InitModule();
    require("Logic/Entity/EntityManager");
    require("Logic/Entity/EntityAttFactory");

    --基类
    require("Logic/Entity/Components/EntityComponent"); 

    --阵营
    require("Logic/Entity/Components/Camp/CampComponent");

    --选中
    require("Logic/Entity/Components/Select/SelectComponent");

    --碰撞
    require("Logic/Entity/Components/Collider/ColliderComponent");

    --状态
    require("Logic/Entity/Components/State/StateComponent");
    require("Logic/Entity/Components/State/AnimController");
    require("Logic/Entity/Components/State/StateController");
    require("Logic/Entity/Components/State/EffectController");

    --飞行
    require("Logic/Entity/Components/Fly/FlyComponent");
    require("Logic/Entity/Components/Fly/FActionFactroy").InitModule();

    --BUFF
    require("Logic/Entity/Components/Buff/BuffComponent");
    require("Logic/Entity/Components/Buff/BuffFactory").InitModule();

    --技能
    require("Logic/Entity/Components/Skill/SkillComponent");
    require("Logic/Entity/Components/Skill/SkillFactory").InitModule();
    require("Logic/Entity/Components/Skill/SkillActionFactory").InitModule();

    --主角自动战斗、自动移动控制
    require("Logic/Entity/Components/AI/AIComponent");
    require("Logic/Entity/Components/AI/AIMaker").InitModule();

    --出生、死亡、受击表现
    require("Logic/Entity/Components/Action/ActionComponent");
    require("Logic/Entity/Components/Action/AActionFactory").InitModule();
    
    --实体模型
    require("Logic/Entity/Components/Model/ModelComponent");
    require("Logic/Entity/Components/Model/ModelFactory").InitModule();  
    
    --UI模型
    require("Logic/Entity/Components/Render/RenderComponent");
    require("Logic/Entity/Components/Render/RenderCamera");
    require("Logic/Entity/Components/Render/RenderLight");
    require("Logic/Entity/Components/Render/RenderPostProcess");

    --实体属性
    require("Logic/Entity/Components/Property/PropertyComponent");
	require("Logic/Entity/Components/Property/AttrCalculator");

    --移动控制
    require("Logic/Entity/Components/Move/MoveComponent");
    require("Logic/Entity/Components/Move/MoveAction_Base");
    require("Logic/Entity/Components/Move/MoveAction_Client");
    require("Logic/Entity/Components/Move/MoveAction_Server");
end

return EntityModule;