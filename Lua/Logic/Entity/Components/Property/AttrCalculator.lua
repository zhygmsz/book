module("AttrCalculator",package.seeall)

local math = math;
local ATTTYPE = PropertyInfo_pb;

--随机函数
local function f_random(min,max)
    return math.random(min,max);
end

local function f_limit(id,cur)
    local attData = AttDefineData.GetDefineData(id);
    if attData.minValue == 0 and attData.maxValue == 0 then 
        return cur; 
    end
    return math.max(attData.minValue,math.min(attData.maxValue,cur));
end

local function f_value(id,att)
    --lua数组下标从1开始
    return att.values and att.values[id + 1] or att[id] or 0;
end

local function f_config_value(key,param)
    if param then
        return ConfigData.GetValue(string.format(key,param));
    else
        return ConfigData.GetValue(key);
    end
end

--一级属性计算公式
local function f_fp(id_init,level,properAtt,addAtt,customInitValue)
    --属性ID
    local id_grow = id_init + 1;
    local id_base = id_init + 2;
    local id_basePercent = id_init + 3;
    local id_attach = id_init + 4;
    local id_percent = id_init + 5;
    --基础成长
    local init_value = (customInitValue or f_value(id_init,properAtt)) + f_value(id_init,addAtt);
    local grow_value = f_value(id_grow,properAtt) + f_value(id_grow,addAtt);
    local base_value = f_value(id_base,properAtt) + f_value(id_base,addAtt);
    local basePercent_value = f_value(id_basePercent,properAtt) + f_value(id_basePercent,addAtt);
    local attach_value = f_value(id_attach,properAtt) + f_value(id_attach,addAtt);
    local percent_value = f_value(id_percent,properAtt) + f_value(id_percent,addAtt);

    --特殊加成
    local all_base_value = f_value(ATTTYPE.SP_ALL_FP_BASE,properAtt) + f_value(ATTTYPE.SP_ALL_FP_BASE,addAtt);
    local all_basePercent_value = f_value(ATTTYPE.SP_ALL_FP_BASE_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_FP_BASE_PERCENT,addAtt);
    local all_attach_value = f_value(ATTTYPE.SP_ALL_FP_ATTACH,properAtt) + f_value(ATTTYPE.SP_ALL_FP_ATTACH,addAtt);
    local all_percent_value = f_value(ATTTYPE.SP_ALL_FP_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_FP_PERCENT,addAtt);

    --最终成长
    local final_base_value = grow_value * level + init_value + base_value + all_base_value;
    local final_basePercent_value = 10000 + f_limit(id_basePercent,basePercent_value + all_basePercent_value);
    local final_attach_value = attach_value + all_attach_value;
    local final_percent = 10000 + f_limit(id_percent,percent_value + all_percent_value);
    
    --最终结果
    return (final_base_value * (final_basePercent_value / 10000.0) + final_attach_value) * (final_percent / 10000.0);
end

--一级转二级公式->通用
local function f_sp_convert_common(id_base,level,properAtt,addAtt)
    local convert_base_value = 0;
    local convert_datas = AttDefineData.GetConvertDatas(id_base);
    for i = 1,#convert_datas do
        local data = convert_datas[i];
        convert_base_value = convert_base_value + f_fp(data.id,level,properAtt,addAtt) * (data.value / 100.0);
    end
    return convert_base_value;
end

--一级转二级公式->宠物
local function f_sp_convert_pet(id_base,level,properAtt,addAtt,attOwnerData)
    --一级属性计算
    local rateValue;
    --体质
    local tzTotal = f_fp(ATTTYPE.FP_PHYSIQUE_INIT,level,properAtt,addAtt,attOwnerData.physical);
    local tzRateName = "Pet_tizhi_rate%s";
    --力量
    local llTotal = f_fp(ATTTYPE.FP_FORCE_INIT,level,properAtt,addAtt,attOwnerData.strength);
    local llRateName = "Pet_liliang_rate%s";
    --耐力
    local nlTotal = f_fp(ATTTYPE.FP_STAMINA_INIT,level,properAtt,addAtt,attOwnerData.stamina);
    local nlRateName = "Pet_naili_rate%s";
    --灵巧
    --local lqTotal = f_fp(ATTTYPE.FP_DEFT_INIT,level,properAtt,addAtt,attOwnerData.deft);
    --local lqRateName = "Pet_lingqiao_rate%s";
    --智力
    local zlTotal = f_fp(ATTTYPE.FP_INTELLECT_INIT,level,properAtt,addAtt,attOwnerData.intellect);
    local zlRateName = "Pet_zhili_rate%s";
    --资质
    local zzValue;
    local zzRateName = 0;
    --成长
    local growValue = attOwnerData.growth;

    if id_base == ATTTYPE.SP_HP_BASE then
        rateValue = 1; zzRateName = "Pet_qixue_apti"; zzValue = attOwnerData.hpApt;
    elseif id_base == ATTTYPE.SP_MP_MAX_BASE then
        rateValue = 2; zzRateName = "Pet_neiG_apti1"; zzValue = attOwnerData.magicApt;
    elseif id_base == ATTTYPE.SP_PHYSIC_ATT_BASE then
        rateValue = 3; zzRateName = "Pet_waiG_apti"; zzValue = attOwnerData.physicApt;
    elseif id_base == ATTTYPE.SP_MAGIC_ATT_BASE then
        rateValue = 4; zzRateName = "Pet_neiG_apti2"; zzValue = attOwnerData.magicApt;
    elseif id_base == ATTTYPE.SP_PHYSIC_DEF_BASE then
        rateValue = 5; zzRateName = "Pet_waiF_apti"; zzValue = attOwnerData.physicDefApt;
    elseif id_base == ATTTYPE.SP_MAGIC_DEF_BASE then
        rateValue = 6; zzRateName = "Pet_neiF_apti"; zzValue = attOwnerData.magicDefApt;
    else
        return 0;
    end
    --等级*资质数值*资质系数
    local zzValueFinal = level * zzValue * f_config_value(zzRateName) * 0.01;
    --一级属性总值*成长*一级属性转化系数
    local tzValueFinal = tzTotal * growValue * f_config_value(tzRateName,rateValue);
    local llValueFinal = llTotal * growValue * f_config_value(llRateName,rateValue);
    local nlValueFinal = nlTotal * growValue * f_config_value(nlRateName,rateValue);
    local lqValueFinal = 0;--lqTotal * growValue * f_config_value(lqRateName,rateValue);
    local zlValueFinal = zlTotal * growValue * f_config_value(zlRateName,rateValue);
    local finalValue = zzValueFinal + tzValueFinal + llValueFinal + nlValueFinal + lqValueFinal + zlValueFinal;
    return finalValue;
end

--一级转二级公式->助战
local function f_sp_convert_helper(id_base,level,properAtt,addAtt,attOwnerData)
    --资质
    local zzValue;
    local zzRateName = 0;

    if id_base == ATTTYPE.SP_HP_BASE then
        zzRateName = "fightHelper_qixue_apti"; zzValue = attOwnerData.bloodIntelligence;
    elseif id_base == ATTTYPE.SP_MP_MAX_BASE then
        zzRateName = "fightHelper_mofa_apti"; zzValue = attOwnerData.magicAttackIntelligence;
    elseif id_base == ATTTYPE.SP_PHYSIC_ATT_BASE then
        zzRateName = "fightHelper_waigong_apti"; zzValue = attOwnerData.physicalAttackIntelligence;
    elseif id_base == ATTTYPE.SP_MAGIC_ATT_BASE then
        zzRateName = "fightHelper_neigong_apti"; zzValue = attOwnerData.magicAttackIntelligence;
    elseif id_base == ATTTYPE.SP_PHYSIC_DEF_BASE then
        zzRateName = "fightHelper_waifang_apti"; zzValue = attOwnerData.physicalDefenseIntelligence;
    elseif id_base == ATTTYPE.SP_MAGIC_DEF_BASE then
        zzRateName = "fightHelper_neifang_apti"; zzValue = attOwnerData.magicDefenseIntelligence;
    else
        return 0;
    end

    --等级*资质数值*资质系数
    local zzValueFinal = level * zzValue * f_config_value(zzRateName) * 0.01;
    return zzValueFinal;
end

--二级属性标准、元素公式
local function f_sp_standard(id_base,level,properAtt,addAtt,attOwnerType,attOwnerData)
    --属性ID
    local id_basePercent = id_base + 1;
    local id_attach = id_base + 2;
    local id_percent = id_base + 3;

    --转化成长
    local convert_base_value = 0;
    if attOwnerType == nil then
        convert_base_value = f_sp_convert_common(id_base,level,properAtt,addAtt);
    elseif attOwnerType == EntityDefine.ENTITY_TYPE.PET then
        convert_base_value = f_sp_convert_pet(id_base,level,properAtt,addAtt,attOwnerData);
    elseif attOwnerType == EntityDefine.ENTITY_TYPE.HELPER then
        convert_base_value = f_sp_convert_helper(id_base,level,properAtt,addAtt,attOwnerData);
    else
        
    end

    --基础成长
    local base_value = f_value(id_base,properAtt) + f_value(id_base,addAtt);
    local basePercent_value = f_value(id_basePercent,properAtt) + f_value(id_basePercent,addAtt);
    local attach_value = f_value(id_attach,properAtt) + f_value(id_attach,addAtt);
    local percent_value = f_value(id_percent,properAtt) + f_value(id_percent,addAtt);

    --特殊加成
    local all_base_value = 0;
    local all_basePercent_value = 0;
    local all_attach_value = 0;
    local all_percent_value = 0;
    if id_base == ATTTYPE.SP_PHYSIC_ATT_BASE or id_base == ATTTYPE.SP_MAGIC_ATT_BASE then
        --攻击加成
        all_base_value = f_value(ATTTYPE.SP_ALL_ATT_BASE,properAtt) + f_value(ATTTYPE.SP_ALL_ATT_BASE,addAtt);
        all_basePercent_value = f_value(ATTTYPE.SP_ALL_ATT_BASE_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_ATT_BASE_PERCENT,addAtt);
        all_attach_value = f_value(ATTTYPE.SP_ALL_ATT_ATTACH,properAtt) + f_value(ATTTYPE.SP_ALL_ATT_ATTACH,addAtt);
        all_percent_value = f_value(ATTTYPE.SP_ALL_ATT_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_ATT_PERCENT,addAtt);
    elseif id_base == ATTTYPE.SP_PHYSIC_DEF_BASE or id_base == ATTTYPE.SP_MAGIC_DEF_BASE then
        --防御加成
        all_base_value = f_value(ATTTYPE.SP_ALL_DEF_BASE,properAtt) + f_value(ATTTYPE.SP_ALL_DEF_BASE,addAtt);
        all_basePercent_value = f_value(ATTTYPE.SP_ALL_DEF_BASE_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_DEF_BASE_PERCENT,addAtt);
        all_attach_value = f_value(ATTTYPE.SP_ALL_DEF_ATTACH,properAtt) + f_value(ATTTYPE.SP_ALL_DEF_ATTACH,addAtt);
        all_percent_value = f_value(ATTTYPE.SP_ALL_DEF_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_DEF_PERCENT,addAtt);
    elseif id_base == ATTTYPE.SP_J_ATT_BASE or 
           id_base == ATTTYPE.SP_M_ATT_BASE or 
           id_base == ATTTYPE.SP_S_ATT_BASE or
           id_base == ATTTYPE.SP_H_ATT_BASE or
           id_base == ATTTYPE.SP_T_ATT_BASE then
        --元素攻击加成
        all_base_value = f_value(ATTTYPE.SP_ALL_ELEMENT_ATT_BASE,properAtt) + f_value(ATTTYPE.SP_ALL_ELEMENT_ATT_BASE,addAtt);
        all_basePercent_value = f_value(ATTTYPE.SP_ALL_ELEMENT_ATT_BASE_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_ELEMENT_ATT_BASE_PERCENT,addAtt);
        all_attach_value = f_value(ATTTYPE.SP_ALL_ELEMENT_ATT_ATTACH,properAtt) + f_value(ATTTYPE.SP_ALL_ELEMENT_ATT_ATTACH,addAtt);
        all_percent_value = f_value(ATTTYPE.SP_ALL_ELEMENT_ATT_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_ELEMENT_ATT_PERCENT,addAtt);
    elseif id_base == ATTTYPE.SP_J_DEF_BASE or 
           id_base == ATTTYPE.SP_M_DEF_BASE or
           id_base == ATTTYPE.SP_S_DEF_BASE or
           id_base == ATTTYPE.SP_H_DEF_BASE or
           id_base == ATTTYPE.SP_T_DEF_BASE then
        --元素防御加成
        all_base_value = f_value(ATTTYPE.SP_ALL_ELEMENT_DEF_BASE,properAtt) + f_value(ATTTYPE.SP_ALL_ELEMENT_DEF_BASE,addAtt);
        all_basePercent_value = f_value(ATTTYPE.SP_ALL_ELEMENT_DEF_BASE_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_ELEMENT_DEF_BASE_PERCENT,addAtt);
        all_attach_value = f_value(ATTTYPE.SP_ALL_ELEMENT_DEF_ATTACH,properAtt) + f_value(ATTTYPE.SP_ALL_ELEMENT_DEF_ATTACH,addAtt);
        all_percent_value = f_value(ATTTYPE.SP_ALL_ELEMENT_DEF_PERCENT,properAtt) + f_value(ATTTYPE.SP_ALL_ELEMENT_DEF_PERCENT,addAtt);
    end

    --最终成长
    local final_base_value = base_value + all_base_value + convert_base_value;
    local final_basePercent_value = 10000 + f_limit(id_basePercent,basePercent_value + all_basePercent_value);
    local final_attach_value = attach_value + all_attach_value;
    local final_percent = 10000 + f_limit(id_percent,percent_value + all_percent_value);
    
    --最终结果
    return (final_base_value * (final_basePercent_value / 10000.0) + final_attach_value) * (final_percent / 10000.0);
end

--二级功能属性
local function f_sp_function(id_base,id_common,properAtt,addAtt)
    local base_value = f_value(id_base,properAtt) + f_value(id_base,addAtt);
    local common_value = f_value(id_common,properAtt) + f_value(id_common,addAtt);

    return f_limit(id_base,base_value + common_value);
end

--单个属性
local function f_sp_single(id_base,properAtt,addAtt)
    return f_limit(id_base,f_value(id_base,properAtt) + f_value(id_base,addAtt));
end

--怒气计算
local function f_sp_anger(id_base,properAtt,addAtt)
    local id_attach = id_base + 1;

    local base_value = f_value(id_base,properAtt) + f_value(id_base,addAtt);
    local attach_value = f_value(id_attach,properAtt) + f_value(id_attach,addAtt);

    return base_value + attach_value;
end

function CalculHPMax(level,properAtt,addAtt)
    return f_sp_standard(ATTTYPE.SP_HP_BASE,level,properAtt,addAtt);
end

function CalculMPMax(level,properAtt,addAtt)
    return f_sp_standard(ATTTYPE.SP_MP_MAX_BASE,level,properAtt,addAtt);
end

function CalculAPMax(level,properAtt,addAtt)
    return f_sp_anger(ATTTYPE.SP_ANGER_MAX_BASE,properAtt,addAtt);
end

function CalculMoveSpeed(baseSpeed,properAtt,addAtt)
    local id_speed_percent = ATTTYPE.SP_MOVE_SPEED_PERCENT
    return baseSpeed * ((10000 + f_limit(id_speed_percent,f_value(id_speed_percent,properAtt) + f_value(id_speed_percent,addAtt))) / 10000.0);
end

--计算baseID指定的属性数值
function CalculProperty(baseID,level,properAtt,addAtt,attOwnerType,attOwnerData)
    if baseID >= 0 and baseID <= 29 then
        --一级属性
        return f_fp(baseID,level,properAtt,addAtt);
    elseif baseID >= 50 and baseID <= 81 then
        --标准二级属性
        return f_sp_standard(baseID,level,properAtt,addAtt,attOwnerType,attOwnerData);
    elseif baseID >= 82 and baseID <= 99 then
        --功能属性
        local id_common = baseID + 3 - (baseID % 81) % 3;
        return f_sp_function(baseID,id_common,properAtt,addAtt);
    elseif baseID >= 100 and baseID <= 139 then
        --标准元素属性
        return f_sp_standard(baseID,level,properAtt,addAtt);
    elseif baseID == 140 then
        --怒气属性
        return f_sp_anger(baseID,properAtt,addAtt);
    elseif baseID >= 145 and baseID <= 164 then
        --标准全属性
        return f_sp_standard(baseID,level,properAtt,addAtt);
    else
        --特殊属性
        return f_sp_single(baseID,properAtt,addAtt);
    end
end

--计算某个数值在UI上如何显示
function CalculPropertyUI(value,showType,showLength)
    if showType == 1 then
        local mod = math.abs(value) % 1;
        value = string.format("%d",value - ((value < 0) and -mod or mod));
    elseif showType == 2 then
        local format = string.format("%%0.%df",showLength);
        local mod =  math.abs(value) % (1 / math.pow(10,showLength));
        value = string.format(format,value - ((value < 0) and -mod or mod));
    elseif showType == 3 then
        value = value * 0.01;
        local format = string.format("%%0.%df%%%%",showLength);
        local mod =  math.abs(value) % (1 / math.pow(10,showLength));
        value = string.format(format,value - ((value < 0) and -mod or mod));
    end
    return value;
end

--计算baseID指定的属性在UI上的最终显示结果
function CalculUIValue(baseID,level,properAtt,addAtt,attOwnerType,attOwnerData)
    local attData = AttDefineData.GetDefineData(baseID);
    local attValue = CalculProperty(baseID,level,properAtt,addAtt,attOwnerType,attOwnerData);
    return CalculPropertyUI(attValue,attData.showType,attData.showLength);
end
