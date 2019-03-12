local AchieveItem = class("AchieveItem")

function AchieveItem:ctor(v)
    self._static = v;
    self._id = v.achievement_sid;
    -- self._gID = v.achievement_type;
    -- self._mainID = 100 * math.floor(gid*0.01);
    self._dynamic = {};
    self._dynamic.progress = 0;
end

--初始化成就动态信息-- dynamic.state 1 完成未领奖,2 已领奖,3 未完成
function AchieveItem:InitDynamicInfo(v)
    self._dynamic.state = v.state;
    if self._dynamic.state ==0 then
        self._dynamic.state = 3;
    end
    self._dynamic.finishTime = tonumber(v.finishTime);
    self._dynamic.progress = v.condition.progress;
end
--同步成就信息
function AchieveItem:SyncDynamicInfo(data)
    local dynamic = self._dynamic;
    if data.state then
        dynamic.state = data.state;
    end
    if dynamic.state ==0 then
        dynamic.state = 3;--1 完成未领奖,2 已领奖,3 未完成
    end
    if data.progress then
        dynamic.progress = data.progress;
    end
end

--收到成就完成
function AchieveItem:SyncFinishInfo(data)
    self._dynamic.finishTime = tonumber(data.finishTime);
    if self._static.reward_id and self._static.reward_id ~= 0 then
        self._dynamic.state = 1;
    else
        self._dynamic.state = 2;
    end
end
--奖励领取完成
function AchieveItem:SetAwardGot()
    self._dynamic.state = 2;
end

function AchieveItem:GetID()
    return self._id;
end

function AchieveItem:GetMainID()
    return self._mgID;
end

function AchieveItem:GetStaticStar()
    return self._static.star;
end

function AchieveItem:GetFinishState()
    return self._dynamic.state;
end

function AchieveItem:IsFinished()
    return self._dynamic.state ~= 3;--item.dynamic.state ~= 3;
end

function AchieveItem:HasAward()
    return self._static.reward_id ~=0 ;
end
function AchieveItem:HasFinalFinish()
    return self._dynamic.state == 2;--data.showShare 
end
function AchieveItem:NextToReward()
    return self._dynamic.state == 1;--data.showAchieve = item.
end
function AchieveItem:GetName()
    return self._static.name;
end
function AchieveItem:GetDesc()
    return self._static.description;
end
function AchieveItem:GetProgress()
    return self._dynamic.progress;
end
function AchieveItem:GetTotalProgress()
    return self._static.totalCount;
end
function AchieveItem:GetRank()
    return self._dynamic.rank or 0.05;
end

function AchieveItem:GetFinisheTime()
    return self._dynamic.finishTime;
end

function AchieveItem:GetMoreDetails()
    local info = {};
    if self:IsFinished() then
        local rank = self:GetRank();
        local rankInfo = AchievementMgr.GetRankInfo(rank);
        
        info.desc = string.format(rankInfo.description,rank);
        info.finishTime = os.date("%Y/%m/%d",self._dynamic.finishTime);
        info.iconName = rankInfo.iconName;
    else
        info.desc = WordData.GetWordStringByKey("achievement_not_finish_desc");--"成就尚未完成,同志仍需努力";
    end
    return info;
end

return AchieveItem;