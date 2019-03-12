local RaceEventEffect = require("Logic/System/Race/RaceEventEffect")
local RaceEventSpeedUp = require("Logic/System/Race/RaceEventSpeedUp")
local RaceEventSlowDown = require("Logic/System/Race/RaceEventSlowDown")  
local RaceEventShield = require("Logic/System/Race/RaceEventShield")  
local RaceEventStop = require("Logic/System/Race/RaceEventStop") 
local RaceEventSleep = require("Logic/System/Race/RaceEventSleep") 
local RaceEventSkill = require("Logic/System/Race/RaceEventSkill")   

RaceEventEffectFactory = class("RaceEventEffectFactory")

local _creaters = {};

local _goodEffects = {RaceEventEffect.EFFECT_SPEEDUP,RaceEventEffect.EFFECT_SHIELD,RaceEventEffect.EFFECT_SKILL};
local _badEffects = {RaceEventEffect.EFFECT_SLOW,RaceEventEffect.EFFECT_STOP,RaceEventEffect.EFFECT_SLEEP};

function RaceEventEffectFactory.CreateEffect(effectType,...)
    local creater = _creaters[effectType];
    return creater.new(...)
end 

local _goodIndex = 1;
local _badIndex = 1;

function RaceEventEffectFactory.CreateRandomEffect(good)
    local effectType = nil;
    if good then
        effectType = _goodEffects[1];        
        _goodIndex = _goodIndex + 1;
        if _goodIndex > #_goodEffects then
            _goodIndex = 1;
        end
    else
        effectType = _badEffects[_badIndex];
        _badIndex = _badIndex + 1;
        if _badIndex > #_badEffects then
            _badIndex = 1;
        end
    end
    return effectType;
end

function RaceEventEffectFactory.Init()
    _creaters[RaceEventEffect.EFFECT_SPEEDUP] = RaceEventSpeedUp;
    _creaters[RaceEventEffect.EFFECT_SLOW] = RaceEventSlowDown;
    _creaters[RaceEventEffect.EFFECT_SHIELD] = RaceEventShield; 
    _creaters[RaceEventEffect.EFFECT_SKILL] = RaceEventSkill;
    _creaters[RaceEventEffect.EFFECT_STOP] = RaceEventStop;
    _creaters[RaceEventEffect.EFFECT_SLEEP] = RaceEventSleep;
end

RaceEventEffectFactory.Init();

return RaceEventEffectFactory;