module("DamageNumber_Param",package.seeall)

--伤害跳字效果参数,目前写死在这里,后面可以考虑配置在表里
DamageParam = {}

--普通伤害->玩家自己和自己的宠物(友方其他人受伤不显示伤害)
DamageParam.NormalDamageToSelf = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 6,  --红色数字
}

--普通伤害->敌对单位(玩家、助战、怪物、精英怪物、BOSS)
DamageParam.NormalDamageToOther = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 3,  --白色数字
}

--暴击伤害->玩家自己和自己的宠物(友方其他人受伤不显示伤害)
DamageParam.CritDamageToSelf = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 8,  --黄色数字
}

--暴击伤害->敌对单位(玩家、助战、怪物、精英怪物、BOSS)
DamageParam.CritDamageToOther = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 8,  --黄色数字
}

--持续伤害->玩家自己和自己的宠物(友方其他人受伤不显示伤害)
DamageParam.DotDamageToSelf = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 5,  --紫色数字
}

--持续伤害->敌对单位
DamageParam.DotDamageToOther = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 5,  --紫色数字
}

--普通治疗->玩家自己||助战||队友
DamageParam.NormalAddHpToSelf = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 7,  --绿色数字
}

--暴击治疗->玩家自己||助战||队友
DamageParam.CritAddHpToSelf = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 7,  --绿色数字
}

--异常状态->玩家自己、敌对玩家、敌方助战、精英怪物、BOSS、敌方宠物、自己宠物
DamageParam.Status = 
{
    needRandomPos = true,
    pathType = 0,   --0号轨迹
    valueType = 10, --文字类型
}

--货币经验
DamageParam.ItemCount = 
{
    pathType = 0,   --0号轨迹
    valueType = 2,  --蓝色数字
}

--随机参数
DamageParam.RandomData = 
{
    lastOffsetX = -1,       --上一次的偏移结果
    maxOffsetX = 1,         --左右偏移最大值
    lastOffsetY = -1,       --上一次的偏移结果
    maxOffsetY = 1,         --上下偏移最大值
    randomThreshold = 1,    --两次随机结果大于该阈值认为有效
    maxRandomTimes = 5,     --最多随机几次
}