module("MailMgr", package.seeall)

local mMailList = {}

local mMailCount = 0

local mCurrShowMid

local mNewMailTimeStamp

local mShowTips = true

local tipsTimer = nil

function InitSNS()
    RequestMailList(true)
end

function InitModule()
    
end

--请求http协议并组装数据
function RequestMailList(isLogin)
    local function OnGetMailList(jsonData)
        if jsonData == nil then
            return 
        end

        mMailCount = 0
        mMailList = {}
        local list1 = {}
        local list2 = {}

        for mid, info in pairs(jsonData) do
            local vo = {}
            vo.mid = mid
            vo.time = info.time
            vo.read = info.read --0未读
            vo.type = info.type
            vo.stype = info.stype

            local contentStr = string.FromBase64(info.context)
            local mailText = Mail_pb.MailText()
            mailText:ParseFromString(contentStr)

            local attachStr = string.FromBase64(info.attach)
            local mailList = Mail_pb.MailAttach()
            mailList:ParseFromString(attachStr)

            vo.from = mailText.from
            vo.title = mailText.title
            vo.text = mailText.text

            vo.itemlist = mailList.itemlist

            vo.attach_picked = info.attach_picked --0为未领取 1已领取

            local haveItem = false
            if #vo.itemlist ~= 0 then
                if vo.attach_picked == 0 then
                    haveItem = true
                else
                    haveItem = false
                end
            else
                haveItem = false
            end

            if not haveItem and vo.read ~= 0 then
                table.insert(list2, vo)
            else
                table.insert(list1, vo)
            end
            mMailCount = mMailCount + 1
        end

        table.sort(list1, function (a, b)
            return a.time > b.time
        end)
        table.sort(list2, function (a, b)
            return a.time > b.time
        end)

        for i, v in ipairs(list1) do
            table.insert(mMailList, v)
        end

        for i, v in ipairs(list2) do
            table.insert(mMailList, v)
        end

        GameEvent.Trigger(EVT.MAIL, EVT.MAIL_ONUPDATE, 1, true)

        local isHaveNewMail = CheackIsShowTips()

        if isHaveNewMail and isLogin then
            OnTCMailNew()
        end
    end

    local action = "XAskMail"
    local param = string.format( "mtype=%s", 2 )
    SocialNetworkMgr.RequestAction(action,param,OnGetMailList);
end

function RequestReadMail(mid)
   local function OnMailRead(jsonData)
        if jsonData == nil then
            return 
        end

        for i, v in ipairs(mMailList) do
            if jsonData == v.mid then
                v.read = 1
            end
        end

        GameEvent.Trigger(EVT.MAIL, EVT.MAIL_ONREADSTATECHANGE)

        local isShowTips = CheackIsShowTips()
        if not isShowTips then
            GameEvent.Trigger(EVT.MAIL, EVT.MAIL_CANCELNEWMAILTIPS)
        end
   end
   
   local action = "XReadMail"
   local param = string.format( "mid=%s",mid )
   SocialNetworkMgr.RequestAction(action,param,OnMailRead);
end

--请求删除邮件
function RequestCSMailDel(mailIdList)
    local haveitem = false
    local function OnOkClick()
        local msg = NetCS_pb.CSMailDel()
        for i, v in ipairs(mailIdList) do
            msg.mailidlist:append(v)
        end
        GameNet.SendToGate(msg)
    end
    local function OnCancelClick()
        
    end

    for i, v in ipairs(mailIdList) do
        local mailInfo = GetMailInfoByMid(v)
        if #mailInfo.itemlist > 0 and mailInfo.attach_picked == 0 then
            TipsMgr.TipConfirmByKey("Mail_warning", OnOkClick, OnCancelClick)
            haveitem = true
        end
    end

    if not haveitem then
        local msg = NetCS_pb.CSMailDel()
        for i, v in ipairs(mailIdList) do
            msg.mailidlist:append(v)
        end
        GameNet.SendToGate(msg)
    end
end
--删除邮件返回
function OnSCMailDel(data)
    if data.ret == 0 then
        local indexList = {}
        for index, info in ipairs(mMailList) do
            for i, v in ipairs(data.mailidlist) do
                if v == info.mid then
                    table.insert(indexList, index)
                end
            end
        end

        for i = #indexList, 1, -1 do
            table.remove(mMailList, indexList[i])
            mMailCount = mMailCount - 1
        end

        GameEvent.Trigger(EVT.MAIL, EVT.MAIL_ONUPDATE)
        
    else
        GameLog.Log("Del mail fail , error code is : "..data.ret)
    end
end

--请求领取附件
function RequestCSMailGetAttach(mid)

    -- local canSend = true
    -- if mid == 0 then
    --     canSend = false
    --     local mailList = UnGetItemList()
    --     for _, mail in ipairs(mailList) do

    --         local can = true
    --         for i, v in ipairs(mail.itemlist) do
    --             local b = BagMgr.CanPutIn(Bag_pb.NORMAL, v.itemid, v.count)
    --             if not b then
    --                 can = false
    --             end 
    --         end

    --         if can == true then
    --             canSend = true
    --             break
    --         end
    --     end
    -- else
    --     local mailInfo = GetMailInfoByMid(mid)
    --     for i, v in ipairs(mailInfo.itemlist) do
    --         local b = BagMgr.CanPutIn(Bag_pb.NORMAL, v.itemid, v.count)
    --         if not b then
    --             canSend = false
    --         end
    --     end
    -- end

    -- if not canSend then
    --     TipsMgr.TipByKey("Mail_bag_space")
    --     return
    -- end

    local msg = NetCS_pb.CSMailGetAttach()
    msg.mailid = mid
    GameNet.SendToGate(msg)
end
--领取附件返回
function OnSCMailGetAttach(data)
    if data.ret == 0 then
        for i, v in ipairs(mMailList) do
            for _, mid in ipairs(data.mailid) do
                if v.mid == mid then
                    v.attach_picked = 1
                    v.read = 1
                end
            end
        end

        GameEvent.Trigger(EVT.MAIL, EVT.MAIL_ONUPDATE)

        local isShowTips = CheackIsShowTips()
        if not isShowTips then
            GameEvent.Trigger(EVT.MAIL, EVT.MAIL_CANCELNEWMAILTIPS)
        end
    else
        TipsMgr.TipErrorByID(data.ret, true)
        GameLog.Log("Get mail fail , error code is : "..data.ret)
    end
end

function OnTCMailNew(data)
    GameEvent.Trigger(EVT.MAIL,EVT.MAIL_NEWMAILTIPS)
    local tipsTime = ConfigData.GetIntValue("Mail_new_tipsTime")
    if tipsTimer ~= nil then
        GameTimer.DeleteTimer(tipsTimer)
        tipsTimer = nil
    end

    local function StopTipsTween()
        GameTimer.DeleteTimer(tipsTimer)
        tipsTimer = nil

        GameEvent.Trigger(EVT.MAIL,EVT.MAIL_STOPNEWMAILTIPS)
    end

    tipsTimer = GameTimer.AddTimer(tipsTime, 1, StopTipsTween)
end

function GetReadedList()
    local readedList = {}
    for i, v in ipairs(mMailList) do
        repeat
            if v.read == 0 then
                break
            end
    
            if #v.itemlist > 0 then
                if v.attach_picked == 1 then
                    table.insert(readedList, v.mid)
                end
            else
                table.insert(readedList, v.mid)
            end
        until true
    end

    return readedList
end

function GetHaveAchstate()
    for i, v in ipairs(mMailList) do
        if #v.itemlist > 0 and v.attach_picked == 0 then
            return true
        end
    end
    return false
end

function SetCurrShowMid(mid)
    mCurrShowMid = mid
end

function GetCurrShowMid()
    return mCurrShowMid
end

function GetMailInfoByMid(mid)
    for _, v in ipairs(mMailList) do
        if mid == v.mid then
            return v
        end
    end
    return nil
end

function GetMailCount()
    return mMailCount
end

function GetMailList()
    return mMailList
end

function SetTipsState(isShow)
    mShowTips = isShow
end

function GetTipsState()
    return mShowTips
end

function UnGetItemList()
    local list = {}
    for i, v in ipairs(mMailList) do
        if #v.itemlist > 0 and v.attach_picked == 0 then
            table.insert(list, v)
        end
    end
    return list
end

function GetIsHaveNewMail()
    for i, v in ipairs(mMailList) do
        if v.read == 0 then
            return true
        end
    end

    return false
end

function CheackIsShowTips()
    for i, v in ipairs(mMailList) do
        if (#v.itemlist > 0 and v.attach_picked == 0) or v.read == 0 then
            return true
        end
    end

    return false
end

return MailMgr