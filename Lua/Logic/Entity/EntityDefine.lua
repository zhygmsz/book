module("EntityDefine",package.seeall)

--实体类型
ENTITY_TYPE = 
{
    AREA            = 1;                --触发器
    COUNTER         = 2;                --计数器
    TIMER           = 3;                --计时器
    WALL            = 4;                --空气墙
    TRANSFER        = 5;                --传送点
    
    PLAYER          = 100;              --玩家
    NPC             = 101;              --怪物
    HELPER          = 102;              --助战
    PLAYER_MAIN     = 103;              --主角
    PET             = 104;              --宠物
    BULLET          = 105;              --技能子弹
    AIPET           = 106;              --AI宠物

    RENDER          = 200;              --UI展示模型
    CREATE          = 201;              --创建角色
}

--组件类型
COMPONENT_TYPE = 
{
    MODEL           = 1;            --模型组件(Visible对象拥有,管理根结点、显示模型、动画控制器等模型相关资源)
    COLLIDER        = 2;            --碰撞组件(提供碰撞检测功能,只在需要时添加,被动调用计算碰撞)
    BUFF            = 3;            --BUFF组件(Character对象拥有,管理BUFF的添加和移除以及BUFF的更新)
    SKILL           = 4;            --技能组件(Character对象拥有,管理技能释放逻辑)
    RENDER          = 5;            --渲染组件(用于渲染UI显示模型)
    MOVE            = 6;            --移动组件(主角使用控制器,其它同步服务器)
    STATE           = 7;            --状态组件(动画状态和控制状态)
    PROPERTY        = 8;            --属性组件(角色属性信息)
    CAMP            = 9;            --阵营组件
    AI              =10;            --AI组件(一般只有主角用,控制自动战斗)
    ACTION          =11;            --行为组件(控制出生、死亡表现)
    FLY             =12;            --飞行控制(粒子)
    SELECT          =13;            --选中控制(点选实体)
}

--模型处理方式
MODEL_PROCESS_TYPE =
{
    EFFECT          = 1;            --粒子特效
    PLAYER          = 2;            --玩家模型
    AIPET           = 5;            --AI宠物模型
    CHARACTER       = 6;            --通用角色
    WALL            = 7;            --空气墙
    PLAYER_MAIN     = 8;            --玩家自己模型
}

--技能打断类型
SKILL_CANCEL_TYPE = 
{
    MOVE            = 0;            --移动打断
    CAST_COMBO      = 1;            --连击打断
    CAST_SKILL      = 3;            --技能释放
    LIMIT_SKILL     = 5;            --禁止释放
    DEAD            = 6;            --实体死亡
    HIT             = 7;            --实体受击
    DIZZY           = 8;            --眩晕打断

    S_SKILL         = 2001609;      --服务器技能打断
    S_DEATH         = 2001610;      --服务器死亡打断
}

--技能目标优先
SKILL_PRIORITY_TYPE =
{
    NONE            = 0;            --不做限制
    PLAYER          = 1;            --优先攻击玩家
    OTHER           = 2;            --优先攻击非玩家
}

ACTION_CANCEL_TYPE = 
{
    NONE            = 0;
    MOVE            = 1;            --移动打断
    SKILL           = 2;            --技能打断
    DIZZY           = 3;            --眩晕打断
}

--客户端状态类型
CLIENT_STATE_TYPE = 
{
    LIMIT_SKILL           = 0;            --禁止释放技能
    LIMIT_MOVE_ROTATE     = 1;            --禁止移动,禁止旋转
    LIMIT_MOVE            = 2;            --禁止移动
    LIMIT_CANCEL          = 3;            --禁止打断当前技能
    COMBAT                = 4;            --战斗状态
    RUNFAST               = 5;            --加速跑状态
    ACTION                = 6;            --特殊表现状态
}

--基础动画名称
ANIM_NAME = 
{
    ANIM_IDLE               = "Stand";      --普通待机
    ANIM_ATTACK_IDLE        = "Stand_Atk";  --战斗待机
    ANIM_RIDE_IDLE          = "Ride_Stand"; --坐骑待机

    ANIM_ATTACK_IN          = "Atk_In";     --普通待机到战斗待机过渡
    ANIM_ATTACK_OUT         = "Atk_Out";    --战斗待机到普通待机过渡

    ANIM_RIDE_ON            = "On_Ride";    --普通待机到坐骑待机过渡
    ANIM_RIDE_OFF           = "Off_Ride";   --坐骑待机到普通待机过渡

    ANIM_RIDE_MOVE          = "Ride_Run";   --坐骑待机
    ANIM_MOVE               = "Run";        --普通移动
    ANIM_MOVE_FAST          = "Run_F";      --加速移动
    ANIM_MOVE_FAST_STOP     = "Stop_F";     --紧急停车

    ANIM_DIE                = "Die";        --死亡
    ANIM_DIZZY              = "Vertigo";    --眩晕
}

--实体根结点
ENTITY_ROOT =  { }

function InitModule()
    ENTITY_ROOT.effect = UnityEngine.GameObject.New("GAME_EFFECT").transform;
    ENTITY_ROOT.parent = UnityEngine.GameObject.New("ENTITY_OBJECT").transform;
    ENTITY_ROOT.pool = UnityEngine.GameObject.New("pool").transform;
    ENTITY_ROOT.pool.parent = ENTITY_ROOT.parent;
    for key,value in pairs(ENTITY_TYPE) do
        if VALID_ENTITY(value) or ROOT_ENTITY(value) then
            local root = UnityEngine.GameObject.New(key).transform;
            root.parent = ENTITY_ROOT.parent;
            ENTITY_ROOT[value] = root;
        end
    end
    UnityEngine.GameObject.DontDestroyOnLoad(ENTITY_ROOT.effect.gameObject);
    UnityEngine.GameObject.DontDestroyOnLoad(ENTITY_ROOT.parent.gameObject);
end

--服务器实体类型转换为客户端实体类型
function STC(entityType,entityID)
    entityID = tonumber(entityID);
    if entityType == Common_pb.LIFE_PLAYER then
        if entityID == UserData.PlayerID then
            return ENTITY_TYPE.PLAYER_MAIN,entityID;
        else
            return ENTITY_TYPE.PLAYER,entityID;
        end
    elseif entityType == Common_pb.LIFE_NPC then
        return ENTITY_TYPE.NPC,entityID;
    elseif entityType == Common_pb.LIFE_REGION then
        return ENTITY_TYPE.AREA,entityID;
    elseif entityType == Common_pb.LIFE_WALL then
        return ENTITY_TYPE.WALL,entityID;
    end
end

--客户端实体类型转换为服务器实体类型
function CTS(entityType)
    if entityType == ENTITY_TYPE.PLAYER_MAIN or entityType == ENTITY_TYPE.PLAYER then
        return Common_pb.LIFE_PLAYER;
    elseif entityType == ENTITY_TYPE.NPC then
        return  Common_pb.LIFE_NPC;
    elseif entityType == ENTITY_TYPE.AREA then
        return  Common_pb.LIFE_REGION;
    elseif entityType == ENTITY_TYPE.WALL then
        return  Common_pb.LIFE_WALL;
    end
end

--有效的需要更新的对象
function VALID_ENTITY(entityType)
    return true;
end

--有效的需要根结点的对象
function ROOT_ENTITY(entityType)
    if entityType == ENTITY_TYPE.AREA then return true; end
    if entityType == ENTITY_TYPE.WALL then return true; end
    if entityType == ENTITY_TYPE.RENDER then return true; end
end

return EntityDefine;