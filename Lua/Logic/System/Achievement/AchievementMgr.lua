module("AchievementMgr",package.seeall);
local AchieveItem = require("Logic/System/Achievement/AchieveItem");
local mInited = false;

local mGroupInfos = {};

local mID_AchievementInfo = {};
local mTotalStars;

local function InitTotalStars()
    mTotalStars = 0;
    for k,item in pairs(mID_AchievementInfo) do
        mTotalStars = mTotalStars + item:GetStaticStar();
    end
end

local function SortCompare(a,b)--有奖>无奖>未完成--ID小的在前
    local a_state = a:GetFinishState();
    local b_state = b:GetFinishState();

    if a_state == b_state then
        return a:GetID() < b:GetID();
    else
        return a_state < b_state;
    end
end

local function SortGroupAchievements(list)
    table.sort(list, SortCompare);
end

local function SortAllAchievements()
    for k,v in pairs(mGroupInfos) do
        SortGroupAchievements(v.list);
    end
end
--==============================--
--desc:
--time:2018-12-04 01:33:02
--@friend1:
--@friend2:
--@return 
--==============================-------------
function Init()
    local groupInfo = AchievementData.GetCatalogueInfoList();
    for i,v in ipairs(groupInfo) do
        local mainID = 100 * math.floor(v.id*0.01);
        local gid = v.id;
        mGroupInfos[gid] = {};
        mGroupInfos[gid].list = {};
        mGroupInfos[gid].static = v;
        if not mGroupInfos[mainID] then 
            mGroupInfos[mainID] = {};
        end
        if gid == mainID then
            mGroupInfos[gid].isMain = true;
            mGroupInfos[mainID].subList = mGroupInfos[mainID].subList or {};
        else
            mGroupInfos[mainID].subList = mGroupInfos[mainID].subList or {};
            table.insert(mGroupInfos[mainID].subList, v );
        end
    end

    local achievementInfo = AchievementData.GetAllAchievementList();
    for i,v in ipairs(achievementInfo) do
        local achieveItem = AchieveItem.new(v);
        mID_AchievementInfo[v.achievement_sid] = achieveItem;
        local gid = v.achievement_type;
        local mainID = 100 * math.floor(gid*0.01);
        if mainID ~= gid then
            table.insert(mGroupInfos[mainID].list, achieveItem);
        end
        table.insert(mGroupInfos[gid].list, achieveItem);
    end

    InitTotalStars();
    RequestSynAchievementSys();
end

function DestroyPlayer()
    mInited = false;
end

function SynDynamicInfo()
    RequestSynAchievementSys();
end

--初始化请求
function RequestSynAchievementSys()
    if mInited then
        return;
    end
    GameLog.Log("Achievement Request Init  ");
    local msg = NetCS_pb.CSGetAchievementSysInfo();
    GameNet.SendToGate(msg);
    -- local data = {};
    -- data.ret = 0;
    -- data.achievementSysInfo = {};
    -- data.achievementSysInfo.achievements = {};
    -- for i = 1, 5 do
    --     local temp = {};
    --     data.achievementSysInfo.achievements[i] = temp;
    --     temp.ID = i;
    --     temp.condition = {};
    --     temp.condition.progress = 1;
    --     temp.state = i - math.floor(i/3)*3;
    --     temp.finishTime = os.time();
    -- end
    -- OnReceiveSyncAchievementSys(data);
end
--请求获得奖励
function RequestGetReward(id)
    GameLog.Log("Achievement Request award "..id);
    local CSGetAchievementReward = NetCS_pb.CSGetAchievementReward();
    CSGetAchievementReward.achievementID = id;
    GameNet.SendToGate(CSGetAchievementReward);
end
--初始化成就动态信息-- dynamic.state 1 完成未领奖,2 已领奖,3 未完成
function OnReceiveSyncAchievementSys(data)
    for i,v in ipairs(data.achievementSysInfo.achievements) do
        local item = mID_AchievementInfo[v.ID];
        item:InitDynamicInfo(v);
    end
    SortAllAchievements();
    GameEvent.Trigger(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_INIT);
    mInited = true;
end
--同步成就信息
function OnReceiveSyncAchievementInfo(data)
    local item = mID_AchievementInfo[data.achievementID];
    item:SyncDynamicInfo(data);
    GameEvent.Trigger(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_UPDATE_STATE,item);
end

--收到成就完成
function OnReceiveFinishAchievement(data)
    local item = mID_AchievementInfo[data.achievementID];
    item:SyncFinishInfo(data);
    GameEvent.Trigger(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_UPDATE_STATE,item);
end

--收到奖励获取返回
function OnReceiveGetAchieveReward(data)
    local item = mID_AchievementInfo[data.achievementID];
    item:SetAwardGot();
    GameEvent.Trigger(EVT.ACHIEVEMENT, EVT.ACHIEVEMENT_UPDATE_STATE,item);
end

--成就条目信息
function GetAchievementItemData(achieveID)
    -- local data = {};
    -- local item = mID_AchievementInfo[achieveID];
    -- data.hasAward = item.static.reward_id ~=0 ;
    -- data.showShare = item.dynamic.state == 2;
    -- data.showAchieve = item.dynamic.state == 1;
    -- data.finished = item.dynamic.state ~= 3;
    -- data.star = item.static.star;
    -- data.name = item.static.name;
    -- data.descript = item.static.description;
    -- data.progress = item.dynamic.progress / item.static.totalCount;
    -- data.progressLable = string.format("%s/%s",item.dynamic.progress, item.static.totalCount);
    -- local base = 10000 + (achieveID-1)*10;
    -- data.openEvent = base + 0;
    -- data.closeEvent = base + 1;
    -- data.shareEvent = base + 2;
    -- data.achieveEvent = base + 3;
    -- data.awardEvent = base + 4;
    -- if data.finished then
    --     local rank = item.dynamic.rank or 0.05;
    --     local rankInfo = AchievementMgr.GetRankInfo(rank);
    --     data.moreFinishDescript = string.format(rankInfo.description,rank);
    --     data.moreFinishTimeLable = os.date("%Y/%m/%d",item.dynamic.finishTime);
    --     data.moreFinishStarName = rankInfo.iconName;
    -- else
    --     data.moreUnfinishedLabel = "成就尚未完成,同志仍需努力";
    -- end
    -- return data;
end

--获得分组内的所有成就列表
function GetAchievementList(catalogueID)
    return mGroupInfos[catalogueID].list;
end

--获得自身排名
function GetRank()
    for i,player in ipairs(mFriendRankList) do
        if player:IsSelf() then
            return i;
        end
    end
    return 1;
end
--分组信息
function GetCatalogueInfo(ID)
    return mGroupInfos[ID].static;
end
--分组内所有已完成/能获得星星总和
function GetCatalogueStarInfo(ID)
    local total = 0;
    local finish = 0;
    for i,item in ipairs(mGroupInfos[ID].list) do
        total = total + item:GetStaticStar();
        if item:IsFinished() then
            finish = finish + item:GetStaticStar();--完成即获得所有星星
        end
    end
    return finish, total;
end
--主目录
function GetMainContents()
    local mainContents = {};
    for k,v in pairs(mGroupInfos) do
        if v.isMain then
            local item = v.static;
            table.insert( mainContents,item);
        end
    end
    local function Compare(a,b)
        return a.id < b.id;
    end
    table.sort(mainContents,Compare);
    return mainContents;
end
--二级目录
function GetSubContents(mainID)
    if mGroupInfos[mainID].isMain then
        return mGroupInfos[mainID].subList;
    else
        GameLog.LogError("错误的ID "..tostring(mainID));
    end
end

--首页显示分组
function GetFrontpageCatalogues()
    local frontContents = {};
    for k,v in pairs(mGroupInfos) do
        if v.static.inFrontPage then
            table.insert( frontContents,v.static.id);
        end
    end
    return frontContents;
end

--所有已完成的星数总和
function GetFinishedStars()
    local finished = 0;
    for k,item in pairs(mID_AchievementInfo) do
        if item:IsFinished() then
            finished = finished + item:GetStaticStar();
        end
    end
    return finished;
end

function GetTotalStars()
    return mTotalStars;
end

--成就完成度等级信息
function GetFinishLevelInfo(stars)
    local percent = stars/mTotalStars;
    return GetTotalLayer(percent);
end

--成就完成度等级信息
function GetTotalLayer(percent)
    local levelInfos = AchievementData.GetLevelStandards();
    for i,v in ipairs(levelInfos) do
        if percent >= v.standard then
            return v;
        end
    end
end

--单项成就完成全服排名百分比显示信息
function GetRankInfo(rank)
    local rankInfos = AchievementData.GetRankStandards();
    for k,v in pairs(rankInfos) do
        if rank <= v.standard then
            return v;
        end
    end
end

--最近完成的十条成就
function GetLatestAchievements()
    local finishedList = {};
    local function Compare(a,b)
        return a:GetFinisheTime() > b:GetFinisheTime();
    end
    for k,item in pairs(mID_AchievementInfo) do
        if item:IsFinished()  then
            table.insert_limit_array(finishedList,10,item,Compare);
        end
    end
    return finishedList;
end

--将要完成的十条成就
function GetCommingAchievements()
    local unfinishedList = {};
    local function Compare(a,b)
        return a:GetProgress() > b:GetProgress();
    end
    for k,item in pairs(mID_AchievementInfo) do
        if not item:IsFinished() and item:GetProgress() >0 then
            table.insert_limit_array(unfinishedList,10,item,Compare);
        end
    end
    return unfinishedList;
end
return AchievementMgr;