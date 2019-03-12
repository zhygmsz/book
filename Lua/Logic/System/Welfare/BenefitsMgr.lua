module("BenefitsMgr",package.seeall)

--每周特惠
local mWeeklySpecial = {}
--每日签到
local mDailySignInfo = {}
--等级礼包
local mLevelGifts = {}
--成长基金
local mGrowthFund = {}
--特惠礼包
local mSpecialGift = {}

local mIsNormalResault = false;

function GetDailySignInfo()
    return mDailySignInfo
end

function InitDailySignInfo(msg)

    mDailySignInfo.issign = msg.issign
    --for i = 1, math.min(#mDailySignInfo.todayprize, #msg.todayprize) do
    --    mDailySignInfo.todayprize[i] = msg.todayprize[i]
    --end
    mDailySignInfo.todayprize = {}
    for _, v in ipairs(msg.todayprize) do

        local prize = {itemlist = {}, exp = v.exp, silver = v.silver, gold = v.gold, cash = v.cash}
        --table.insert(mDailySignInfo.todayprize,v)
        for _, item in ipairs(v.itemlist) do
            local prizeItem = {itemid = item.itemid, count = item.count}
            table.insert(prize.itemlist, prizeItem)
        end
        table.insert(mDailySignInfo.todayprize, prize)
    end

    mDailySignInfo.consecutiveprize = {}
    for _, v in ipairs(msg.consecutiveprize) do
        --table.insert(mDailySignInfo.consecutiveprize,v)
        local prize = {itemlist = {}, exp = v.exp, silver = v.silver, gold = v.gold, cash = v.cash}
        --table.insert(mDailySignInfo.todayprize,v)
        for _, item in ipairs(v.itemlist) do
            local prizeItem = {itemid = item.itemid, count = item.count}
            table.insert(prize.itemlist, prizeItem)
        end
        table.insert(mDailySignInfo.consecutiveprize, prize)
    end

    mDailySignInfo.roleflag = msg.roleflag

    --if msg.award > 0 then
    --    mDailySignInfo.award = msg.award
    --end

    if msg.award then

        mDailySignInfo.award = {itemlist = {}, exp = msg.award.exp, silver = msg.award.silver, gold = msg.award.gold, cash = msg.award.cash}
        for _, v in ipairs(msg.award.itemlist) do
            local prizeItem = {itemid = v.itemid, count = v.count}
            table.insert(mDailySignInfo.award.itemlist, prizeItem)
        end

    end

    mDailySignInfo.consecutivecont = msg.consecutivecont
    mDailySignInfo.fillcheckcount = msg.fillcheckcount
    mDailySignInfo.refreshcount = msg.refreshcount
    mDailySignInfo.todaytips = msg.todaytips
    --mDailySignInfo.today = msg.today

    if msg.today ~= nil then
        mDailySignInfo.today = { prizetype = msg.today.prizetype, awarditemid = msg.today.awarditemid }
    end

end

function UpdateDailySignIn(msg)

    if msg.ret ~= 0 then
        --提示
        GameEvent.Trigger(EVT.SUB_G_SIGN, EVT.SUB_U_SIGNIN, msg)
        return
    end

    mDailySignInfo.issign = true
    mDailySignInfo.consecutivecont = msg.signresult.consecutive

    --mDailySignInfo.today = {}
    mDailySignInfo.today.prizetype = msg.signresult.type
    mDailySignInfo.today.prizeItems = msg.signresult.prize.itemlist;
    mDailySignInfo.today.awarditemid = msg.signresult.awarditemid.itemlist[1].itemid

    GameEvent.Trigger(EVT.SUB_G_SIGN, EVT.SUB_U_SIGNIN, msg)

end

function UpdateFillCheck(msg)

    if msg.ret ~= 0 then
        --提示
        GameEvent.Trigger(EVT.SUB_G_SIGN, EVT.SUB_U_FILLCHECK, msg)
        return
    end

    --local updateResult = false
    mDailySignInfo.fillcheckcount = msg.fillcheckcount
    mDailySignInfo.consecutivecont = msg.signresult.consecutive
    --if msg.signresult.type < mDailySignInfo.today.prizetype then
    mDailySignInfo.today.prizetype = msg.signresult.type
    mDailySignInfo.todaytips = msg.tips

    --updateResult = true
    --end
    mDailySignInfo.today.awarditemid = msg.signresult.awarditemid.itemlist[1].itemid
    GameEvent.Trigger(EVT.SUB_G_SIGN, EVT.SUB_U_FILLCHECK, msg)

end

function UpdateConsecutive(msg)
    if msg.ret ~= 0 then
        TipsMgr.TipErrorByID(msg.ret)
        return
    end

    mDailySignInfo.roleflag = msg.roleflag
    mDailySignInfo.consecutivecont = msg.consecutivecont

    if #msg.consecutiveprize > 0 then

        --GameEvent.Trigger(EVT.SUB_G_SIGN, EVT.SUB_U_UPDATE_CONSECUTIVE, msg)
        --for i = 1, math.min(#mDailySignInfo.consecutiveprize, #msg.consecutiveprize) do
        --    mDailySignInfo.consecutiveprize[i] = msg.consecutiveprize[i]
        --end
        mDailySignInfo.consecutiveprize = {}
        for _, v in ipairs(msg.consecutiveprize) do
            --table.insert(mDailySignInfo.consecutiveprize,v)
            local prize = {itemlist = {}, exp = v.exp, silver = v.silver, gold = v.gold, cash = v.cash}
            --table.insert(mDailySignInfo.todayprize,v)
            for _, item in ipairs(v.itemlist) do
                local prizeItem = {itemid = item.itemid, count = item.count}
                table.insert(prize.itemlist, prizeItem)
            end
            table.insert(mDailySignInfo.consecutiveprize, prize)
        end
        return

    end

    for _, v in ipairs(msg.prize.itemlist) do
    end

    GameEvent.Trigger(EVT.SUB_G_SIGN, EVT.SUB_U_GETCONSECUTIVE, msg)

end

function UpdateTodayPrize(msg)

    if msg.ret ~= 0 then
        TipsMgr.TipErrorByID(msg.ret)
        return
    end
    mDailySignInfo.todayprize = {}
    for _, v in ipairs(msg.todayprize) do

        local prize = {itemlist = {}, exp = v.exp, silver = v.silver, gold = v.gold, cash = v.cash}
        --table.insert(mDailySignInfo.todayprize,v)
        for _, item in ipairs(v.itemlist) do
            local prizeItem = {itemid = item.itemid, count = item.count}
            table.insert(prize.itemlist, prizeItem)
        end
        table.insert(mDailySignInfo.todayprize, prize)
    end

    mDailySignInfo.refreshcount = msg.refreshcount
    GameEvent.Trigger(EVT.SUB_G_SIGN, EVT.SUB_U_REFRESH_TODAYPRIZE, msg)

end

function InitModule()

end

function GetSignPrizeltItems()
    return mDailySignInfo.today.prizeItems;
end

function GetAwardItemId()
    return mDailySignInfo.today.awarditemid;
end

function GetPrizeType()
    return mDailySignInfo.today.prizetype;
end

function SetIsNormalResault(isNormalResault)
    mIsNormalResault = isNormalResault;
end

function GetIsNormalResault()
    return mIsNormalResault;
end

return BenefitsMgr;



