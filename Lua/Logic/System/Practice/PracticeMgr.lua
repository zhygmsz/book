module("PracticeMgr",package.seeall);
local PracticeViewController = require("Logic/System/Practice/PracticeViewController")

local mViewController = nil
local mTargetType = 1
local mAttType= 1
local mPracticeInfo = {}

function InitModule()
    
end

function InitData()
    AskPracticeInfo()
end

--消息处理
function OnHandlePracticeInfo(info)
    if info and info.practice then
        for i=1,#info.practice do
            local data = info.practice[i]
            local att=PracticeData.GetParcticeAtt(data.id)
            if mPracticeInfo[att.targetType] == nil then  mPracticeInfo[att.targetType]={} end
            if mPracticeInfo[att.targetType][att.attType] == nil then  mPracticeInfo[att.targetType][att.attType]={} end
            mPracticeInfo[att.targetType][att.attType].exp = data.exp
            mPracticeInfo[att.targetType][att.attType].id = data.id
        end
        UpdateUI()
    end
end

--请求修炼信息
function AskPracticeInfo()
    local msg = NetCS_pb.CSAskPracticeInfo();
    GameNet.SendToGate(msg);
end

--修炼升级 //修炼ID //1,一次修炼。2,十次修炼。3,道具修炼
function AskPracticeLevelUp(practiceId,consumType)
    local msg = NetCS_pb.CSPracticeLevelUp();
    msg.practiceId = practiceId
    msg.consumType = consumType
    GameNet.SendToGate(msg);
end

--data 是属性定义表的数据
function GetAttValue(baseID)
    local attData = AttDefineData.GetDefineData(baseID);
	local staticProperty = UserData.GetStaticProperty();
	local dynamicProperty = UserData.GetDynamicProperty();
	local value = AttrCalculator.CalculProperty(attData.id, UserData.GetLevel(), staticProperty, dynamicProperty);
	return value
end

--计算baseID指定的属性在UI上的最终显示结果
function GetAttValueString(baseID)
    local attData = AttDefineData.GetDefineData(baseID);
	local staticProperty = UserData.GetStaticProperty();
	local dynamicProperty = UserData.GetDynamicProperty();
	local value = AttrCalculator.CalculProperty(attData.id, UserData.GetLevel(), staticProperty, dynamicProperty);
	return AttrCalculator.CalculPropertyUI(value, attData.showType, attData.showLength);
end

--单次修炼消耗银币数
function CostSilverNum()
    return tonumber(ConfigData.GetValue("Prac_coin_num")) or 10
end

--单次次来呢增加经验值
function ExpValue()
    return tonumber(ConfigData.GetValue("Prac_timesexp")) or 10
end

--批量修炼的次数
function BatchNum()
    return tonumber(ConfigData.GetValue("Prac_coin_times")) or 10
end

--共鸣所需最下等级
function SymNeedMinLevel()
    return tonumber(ConfigData.GetValue("Prac_GMlv")) or 15
end

--额外属性所需最下等级
function PracticeExtraAttMinLevel()
    return tonumber(ConfigData.GetValue("Prac_valuelv")) or 16
end

--经脉消耗道具id
function MeridianCostItemId()
    local id =tonumber(ConfigData.GetValue("Prac_itemJM"))
    return id
end

--经脉消耗道具
function MeridianCostItemInfo()
    return ItemData.GetItemInfo(MeridianCostItemId())
end

--御兽消耗道具id
function BeastCostItemId()
    return tonumber(ConfigData.GetValue("Prac_itemYS"))
end

--御兽消耗道具
function BeastCostItemInfo()
    return ItemData.GetItemInfo(BeastCostItemId())
end

--targetType 1=经脉修炼 2=御兽修炼
--attType 1=攻法修炼-- 2=物防修炼-- 3=法防修炼-- 4=气血修炼-- 5=共鸣修炼
--level 1--25
function GetPracticeAttByType(targetType,attType,level)
    return PracticeData.GetPracticeAttByType(targetType,attType,level)
end

--获得升级所需经验值
function GetPracticeLevelUpNeedExp(targetType,attType,level)
    local data = GetPracticeAttByType(targetType,attType,level)
    if data==nil then--表示满级
        return -1
    end
    return data.needExp
end

--修炼的等级上限
function GetMaxPracticeLevel(targetType)
    local limit1=PracticeData.GetGangLevelLimit(targetType,UserData.GetGangLevel())
    local limit2=PracticeData.GetPlayerLevelLimit(targetType,UserData.GetLevel())
    local limit3=PracticeData.GetGaneOfferLimit(targetType,UserData.GetGangContribute())
    local limitlevel = math.min(limit1,limit2,limit3)
    return limitlevel
end

--共鸣的等级上限
function GetMaxSymLevel(targetType,level)
    local limit=PracticeData.GetSymLevelLimit(targetType,level)
    return limit
end

--共鸣升级所需最小等级
function GetSymNeedLevel(targetType,symlevel)
    local limit=PracticeData.GetSymNeedLevel(targetType,symlevel)
    return limit
end

--消耗道具信息
function GetCostItemInfo(targetType)
    if targetType==1 then
        return MeridianCostItemInfo()
    elseif targetType==2 then
        return BeastCostItemInfo()
    end
end

function GetTargetAtt(targetType,attType)
    local id = mPracticeInfo[targetType][attType].id
    local att=PracticeData.GetParcticeAtt(id)
    return att
end

function CurrentAtt()
    return GetTargetAtt(mTargetType,mAttType)
end

--当前等级
function CurrentLevel()
    return CurrentAtt().level
end

--最下等级
function GetMinLevel(targetType)
    local min = 25
    for i=1,4 do
       local att=GetTargetAtt(targetType,i)
       min = math.min(min,att.level)
    end
    return min
end

--当前最下等级
function CurrentMinLevel()
    local min = GetMinLevel(mTargetType)
    return min
end

--共鸣等级
function GetSymLevel(targetType)
    local att=GetTargetAtt(targetType,5)
    return att.level
end

--当前共鸣等级
function CurrentSymLevel()
    return GetSymLevel(mTargetType)
end

--经验
function GetExp(targetType,attType)
    return mPracticeInfo[targetType][attType].exp
end

--当前经验
function CurrentExp()
    return mPracticeInfo[mTargetType][mAttType].exp
end

function OnSelectItem(targetType,attType)
    mTargetType = targetType
    mAttType = attType
end

--修炼一次
function PracticeOnce()
    local practiceId = mPracticeInfo[mTargetType][mAttType].id
    AskPracticeLevelUp(practiceId,1)
end

--修十次
function PracticeBatch()
    local practiceId = mPracticeInfo[mTargetType][mAttType].id
    AskPracticeLevelUp(practiceId,2)
end

--使用道具
function UseItem()
    local practiceId = mPracticeInfo[mTargetType][mAttType].id
    AskPracticeLevelUp(practiceId,3)
end

--共鸣升级
function SymphyLevelUp()
    if SymCanLevevlUp(mTargetType) then
        local practiceId = mPracticeInfo[mTargetType][5].id
        AskPracticeLevelUp(practiceId,1)
    else
        local needMinLevel = PracticeMgr.GetSymNeedLevel(mTargetType,CurrentSymLevel())
        if mTargetType==1 then
            TipsMgr.TipByKey("Prac_show1311",needMinLevel) 
        else 
            TipsMgr.TipByKey("Prac_show1321",needMinLevel)
        end
    end
end

function ShowPracticeUI()
    UIMgr.ShowUI(AllUI.UI_Practice,nil,function()
        if mViewController==nil then
            mViewController = PracticeViewController.new(UI_Practice.GetUI())
        end
        UpdateUI()
    end);
end

--共鸣是否可升级
function SymCanLevevlUp(targetType)
    local symlevel = GetSymLevel(targetType)
    local minlevel = GetMinLevel(targetType)
    local needMinLevel = GetSymNeedLevel(targetType,symlevel)
    return minlevel>=needMinLevel
end

function UpdateUI()
    if mViewController then
           --修炼类型 属性类型 当前属性等级 共鸣等级 最小属性等级 当前属性经验
        mViewController:ShowPad(mTargetType,mAttType,CurrentLevel(),CurrentSymLevel(),CurrentMinLevel(),CurrentExp())
        mViewController:CheckSymCanLevelUp(1)
        mViewController:CheckSymCanLevelUp(2)
    end
end

function UnShowPracticeUI()
    UIMgr.UnShowUI(AllUI.UI_Practice);
end

return PracticeMgr;
