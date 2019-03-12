module("BuffFactory",package.seeall)

local mBuffGroups = {};
local mBuffEffects = {};
local mBuffEffectCtors = {};

function CreateBuffGroup(...)
    local buffGroup = mBuffGroups[#mBuffGroups];
    if not buffGroup then 
        buffGroup = BuffGroup.new(...) 
    else
        mBuffGroups[#mBuffGroups] = nil;
        buffGroup:ctor(...);
    end
    return buffGroup;
end

function DestroyBuffGroup(buffGroup)
    if not buffGroup then return end
    mBuffGroups[#mBuffGroups + 1] = buffGroup;
    buffGroup:dtor();
end

function CreateBuffEffect(buffGroup,effectID)
    local effectData = BuffData.GetBuffEffectData(effectID);
    if not effectData then return end
    local effects = mBuffEffects[effectData.effectType];
    local effect = effects and effects[#effects];
    if not effect then
        local effectCtor = mBuffEffectCtors[effectData.effectType];
        effect = effectCtor and effectCtor(buffGroup,effectData) or BuffEffect.new(buffGroup,effectData);
    else
        effects[#effects] = nil;
        effect:ctor(buffGroup,effectData);
    end
    return effect;
end

function DestroyBuffEffect(buffEffect)
    local effects = mBuffEffects[buffEffect._effectData.effectType];
    if not effects then 
        effects = {};
        mBuffEffects[buffEffect._effectData.effectType] = effects;
    end
    effects[#effects + 1] = buffEffect;
    buffEffect:dtor();
end

function RegBuffEffect(effectType, path)
    mBuffEffectCtors[effectType] = require(path).new
end

function InitModule()
    require("Logic/Entity/Components/Buff/BuffEffect");
    require("Logic/Entity/Components/Buff/BuffGroup");

    local EFFECT_TYPE = StatusInfo_pb.StatusEffect
    RegBuffEffect(EFFECT_TYPE.BUFF_EFFECT_LIMIT_VISION, "Logic/Entity/Components/Buff/BuffEffect_LimitVision")
end

return BuffFactory;