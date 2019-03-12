module("UserData",package.seeall)
--属性变化对比结果和显示结果
local mPropertyDiff = {};
local mPropertyOld = {};
--属性
function GetStaticProperty() return PlayerAtt.staticProperty; end
function GetDynamicProperty() return PlayerAtt.dynamicProperty or {}; end
function GetMoveSpeed() return PlayerAtt.moveSpeed; end

--某个模块属性发生变化后
function OnPropertyUpdate(propertySource,propertyOld,propertyNew)
    table.clear(mPropertyDiff);
    for k, v in pairs(propertyNew) do mPropertyDiff[k] = v - (propertyOld[k] or 0); end
    for k, v in pairs(propertyOld) do mPropertyDiff[k] = (propertyNew[k] or 0) - v; end
    --计算变化前需要显示的属性的当前值
    table.clear(mPropertyOld);
    local playerLevel = GetLevel();
    local staticProperty = GetStaticProperty();
    local dynamicProperty = GetDynamicProperty();
    local allShowProperty = AttDefineData.GetAllShowData();
    for _,property in ipairs(allShowProperty) do
        mPropertyOld[property.id] = AttrCalculator.CalculProperty(property.id,playerLevel,staticProperty,dynamicProperty);
    end
    --修改动态属性表
    for k, v in pairs(mPropertyDiff) do
        dynamicProperty[k] = (dynamicProperty[k] or 0) + v;
    end
    --计算变化后需要显示的属性的当前值
    table.clear(mPropertyDiff);
    for _,property in ipairs(allShowProperty) do
        local oldValue = mPropertyOld[property.id];
        local newValue = AttrCalculator.CalculProperty(property.id,playerLevel,staticProperty,dynamicProperty);
        if oldValue ~= newValue then
            property.deltaValue = newValue - oldValue;
            mPropertyDiff[#mPropertyDiff + 1] = property;
        end
    end
    --按照权值排序并且变大的值在前
    local function SortByWeight(a,b)
        if((a.deltaValue < 0) == (b.deltaValue < 0)) then
            return a.data.weight > b.data.weight;
        else
            return a.deltaValue > b.deltaValue;
        end
    end
    table.sort(mPropertyDiff,SortByWeight);
    --显示变化
    TipsMgr.TipProChange(mPropertyDiff)
    GameEvent.Trigger(EVT.PLAYER,EVT.PLAYER_ATT_UPDATE);
end

--移动速度百分比发生变化
function OnMoveSpeedPercentUpdate(moveSpeedPercent)
    local dynamicProperty = GetDynamicProperty();
    dynamicProperty[PropertyInfo_pb.SP_MOVE_SPEED_PERCENT] = moveSpeedPercent;
    local mainPlayer = MapMgr.GetMainPlayer();
    if mainPlayer then mainPlayer:GetPropertyComponent():SetMoveSpeed(GetMoveSpeed(),false,true); end
end
