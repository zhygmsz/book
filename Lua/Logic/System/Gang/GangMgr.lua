--帮会新mgr

module("GangMgr", package.seeall)


DebugMode = true

--数据
--帮会范畴的角色数据，玩家登录后请求，以此来判定一个玩家的帮会状态
local mGangRoleInfo

--帮会信息，Guild.proto的GuildInfo结构
--主动请求回复赋值，接受广播赋值，都同步数据并刷UI
local mGangInfo = nil

--帮会成员列表
local mGangMemberList = nil

--从服务器请求下来的帮会列表，增量式往后插入，UI只访问这个结构
local mGangList = {}

--角色的帮会范畴数据，和帮会/帮会成员无关
local mRoleGangInfo = {}

--local方法
local function LogProto(msg)
    GameLog.LogProto(msg)
end

local function AppendGangList(list)
    if not list then
        return
    end
    local len = #list
    if len == 0 then
        return
    end
    mGangList = {}
    for idx = 1, len do
        table.insert(mGangList, list[idx])
    end

    --发送事件，通知UI
    GameEvent.Trigger(EVT.GANG, EVT.GETMOREGANGLIST)
end

--[[
    @desc: 初始化帮会成员列表，只此一次，后续改动使用单独更新成员接口
]]
local function InitGangMemberList(list)
    if not list then
        return
    end
    mGangMemberList = {}
    local data = nil
    for idx, info in ipairs(list) do
        --包装一层结构，便于扩展逻辑
        data = { memInfo = info }
        table.insert(mGangMemberList, data)
    end
end

local function InitData()

end

function InitModule()
    InitData()
end

function InitModuleOnLogin()
    RequestGangRoleInfo()
end

--[[
    @desc: 
    --@name: 帮会名字
	--@des: 帮会宣言
	--@x: 坐标值
	--@y: 坐标值
]]
function RequestCreate(name, des, x, y)
    --条件过滤
    if UserData.GetLevel() < 10 then
        TipsMgr.TipByFormat("等级不足10级")
        return
    end
    local coinType = ConfigData.GetIntValue("Underworldgang_establish_money1")
    local coinNum = ConfigData.GetIntValue("Underworldgang_establish_money2")
    local haveNum = BagMgr.GetMoney(coinType)
    if haveNum < coinNum then
        TipsMgr.TipByFormat("货币不足")
        return
    end

    local msg = NetCS_pb.CSCreateGuild()
    msg.guildName = name
    msg.manifesto = des
    msg.x = x
    msg.y = y
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 创建帮会返回
    --@data: 
]]
function OnCreate(data)
    LogProto(data)
    TipsMgr.TipByFormat("创建成功")
    --关闭帮会列表界面，打开帮会信息界面，进而获取帮会信息和成员列表
    UIMgr.UnShowUI(AllUI.UI_Gang_Create)
    UIMgr.UnShowUI(AllUI.UI_Gang_List)
    UIMgr.ShowUI(AllUI.UI_Gang_Main)
end

--[[
    @desc: 请求帮会信息
    每次打开UI都请求，因为会变动，且数据量小
]]
function RequestGangInfo()
    local msg = NetCT_pb.CTAskGuildInfo()
    msg.roleid = UserData.PlayerID
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 获取到帮派信息，同步数据到本地缓存
]]
function OnGetGangInfo(data)
    mGangInfo = data.guildinfo

    --发送事件
    GameEvent.Trigger(EVT.GANG, EVT.GETGANGINFO)
end

--[[
    @desc: 请求帮会成员列表
    本次登录只请求一次，后续成员变动单独以广播的方式同步
]]
function RequestGangMemberList()
    local msg = NetCT_pb.CTAskGuildMember()
    msg.roleid = UserData.PlayerID
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 获取到帮会成员列表
]]
function OnGetGangMemberList(data)
    InitGangMemberList(data.members)

    --发送事件
    GameEvent.Trigger(EVT.GANG, EVT.GETGANGMEMBERLIST)
end

--[[
    @desc: 请求加入指定id的帮会
    有去无回的消息，需等待帮会的同意，同意或拒绝后，通知对应申请人
	--@gangId: 
]]
function RequestJoin(gangId)
    --条件过滤
    if UserData.GetLevel() < 10 then
        TipsMgr.TipByFormat("等级不足10级")
        return
    end

    local msg = NetCS_pb.CSAskEnterGuild()
    msg.guildid = gangId
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 申请有审批帮会，申请成功，返回0，但并不会直接入会
    --@data: 
]]
function OnJoinResult(data)
    TipsMgr.TipByFormat("申请成功")
    GameEvent.Trigger(EVT.GANG, EVT.ONJOINRESULT, data.guildid)
end

--[[
    @desc: 申请免审批的工会，直接进会，返回消息
    该消息和OnJoinResult，只会返回一个
]]
function OnJoinGangSuccess()
    --申请帮会的入口有以下两个界面，都关，没问题
    UIMgr.UnShowUI(AllUI.UI_Gang_Recommend)
    UIMgr.UnShowUI(AllUI.UI_Gang_List)

    UIMgr.ShowUI(AllUI.UI_Gang_Main)
end

--[[
    @desc: 一键申请，请求进入工会
]]
function RequestQuickJoin()
    --条件过滤
    if UserData.GetLevel() < 10 then
        TipsMgr.TipByFormat("等级不足10级")
        return
    end

    --等级相关的过滤到后期都可以删掉，因为整个帮会功能的入口由等级控制

    local msg = NetCS_pb.CSQuickAskEnterGuild()
    GameNet.SendToGate(msg)
end

--[[
    @desc: 一键申请返回
    --@data: 
]]
function OnQuickJoinResult(data)
    TipsMgr.TipByFormat("一键申请成功")
    UIMgr.UnShowUI(AllUI.UI_Gang_Recommend)
end

--[[
    @desc: 请求我所属帮会的申请入会列表
    帮会内，只有某些职位的人会申请该列表
]]
function RequestApplyList()
    local msg = NetCT_pb.CTAskGuildApplyList()
    msg.roleid = UserData.PlayerID
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 获取到入会申请列表
    每次打开UI时请求最新数据，该列表会随着其他帮会同意入会，而导致当前列表的数据删减
    所以，不缓存数据，直接把数据传递给UI
    --@data: 
]]
function OnGetApplyList(data)
    --发出事件，携带数据通知UI
    GameEvent.Trigger(EVT.GANG, EVT.GETGANGAPPLYLIST, data.applyinfo)
end

--[[
    @desc: 请求帮会列表，索引从1开始，增量式请求
    --@beginIdx:
	--@endIdx: 
]]
function RequestGangList(beginIdx, endIdx)
    local msg = NetCT_pb.CTAskGuildList()
    msg.roleid = UserData.PlayerID
    msg.beginidx = beginIdx
    msg.endidx = endIdx
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 获取到更多帮会列表
    --@data: 
]]
function OnGetMoreGangList(data)
    AppendGangList(data.guildlists)
end

--[[
    @desc: 请求处理一个入会申请
    --@targetRoleId: 
    --@reply: 1同意，2拒绝
]]
function RequestReplyJoin(targetRoleId, reply)
    local msg = NetCT_pb.CTReplyGuildApply()
    msg.roleid = UserData.PlayerID
    msg.tarroleid = targetRoleId
    msg.reply = reply
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 返回处理入会申请结果，给处理人发
    --@data: 
]]
function OnReplyJoin(data)
    TipsMgr.TipByFormat("处理成功")
    --发送事件，把数据传递给UI，和入会申请列表一样，不缓存
    GameEvent.Trigger(EVT.GANG, EVT.GETREPLYJOINDATA, data)
end

--[[
    @desc: 申请入会结果，给申请人发，在线的话做出表现
    如果是离线状态下，下次上线后，直接按有帮会处理
    如果，实在想在登陆时给个入会提示，就在角色数据里引入一个历史提示消息
    --@data: 
]]
function OnReplyJoinToMe(data)
    if data.reply == 1 then
        --同意
        TipsMgr.TipByFormat("成功加入帮会")
    elseif data.reply == 2 then
        --拒绝
        TipsMgr.TipByFormat("加入帮会请求被拒绝")
    end
end

--[[
    @desc: 一键处理，所有入会申请
    --@reply: 1同意，2拒绝
]]
function RequestQuickReplyJoin(reply)
    local msg = NetCT_pb.CTQuickReplyGuildApply()
    msg.roleid = UserData.PlayerID
    msg.reply = reply
    GameNet.SendToGate(msg)
end

--[[
    @desc: 一键处理入会申请的返回
    --@data: ret为0则成功，失败情况弹提示
]]
function OnQuickReplyJoin(data)
    if data.reply == 1 then
        --同意
        TipsMgr.TipByFormat("一键处理成功 - 同意")
    elseif data.reply == 2 then
        --拒绝
        TipsMgr.TipByFormat("一键处理成功 - 拒绝")
    end
    --通知UI
    GameEvent.Trigger(EVT.GANG, EVT.ONQUICKREPLYJOIN)
end

--[[
    @desc: 踢出成员，需要通知给被踢出人，和同步给帮会其他所有玩家，成员列表删除该玩家
    --@targetRoleId: 
]]
function RequestKickMember(targetRoleId)
    local msg = NetCT_pb.CTKickMember()
    msg.roleid = UserData.PlayerID
    msg.tarid = targetRoleId
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 踢出成员返回，给处理人
]]
function OnKickResult(data)

end

--[[
    @desc: 自己被踢出帮会，数据全部清除，哪怕再次加入同一个帮会，数据也重新构建
    不带参数
]]
function OnKickMe()
    --发送事件，通知UI
end

--[[
    @desc: 玩家主动离开帮会
]]
function RequestLeaveGang()
    local msg = NetCT_pb.CTLeaveGuild()
    msg.roleid = UserData.PlayerID
    GameNet.SendToGate(msg, true)
end

--[[
    @desc: 主动离开帮会返回结果
    --@data: 
]]
function OnLeaveGang(data)
    --关闭UI，清理帮会相关数据
    UIMgr.UnShowUI(AllUI.UI_Gang_Main)
end

--[[
    @desc: 所属帮会成员变动广播
    --@data: 
]]
function OnMemberChange(data)
    if data.tp == 1 then
        --增加
    elseif data.tp ==2 then
        --减少
    end
end

--[[
    @desc: 请求角色数据（帮会范畴的，角色身上的）
]]
function RequestGangRoleInfo()
    local msg = NetCS_pb.CSGetRoleGuild()
    GameNet.SendToGate(msg)
end

--[[
    @desc: 获取到角色数据（帮会范畴）
    --@data: 直接赋值
]]
function OnGetGangRoleInfo(data)
    mGangRoleInfo = data
end

--[[
    @desc: 设置帮会是否自动审核
    --@check: 0自动审核，1手动审核
]]
function RequestSetGangCheck(check)
    local msg = NetCT_pb.CTSetGuildCheck()
    msg.roleid = UserData.PlayerID
    msg.check = check
    GameNet.SendToGate(msg)
end

--[[
    @desc: 设置帮会是否自动审核，返回
]]
function OnSetGangCheck(data)
    TipsMgr.TipByFormat("设置成功")
end

--[[
    @desc: 获取推荐帮会列表
]]
function RequestRecommendList()
    local msg = NetCT_pb.CTGuildRecommend()
    msg.roleid = UserData.PlayerID
    --自身坐标，来自lbs服务
    msg.x = 1
    msg.y = 1
    GameNet.SendToGate(msg)
end

--[[
    @desc: 获取到推荐帮会列表
    --@data: 
]]
function OnGetRecommendList(data)
    --发出事件，携带数据通知UI
    GameEvent.Trigger(EVT.GANG, EVT.GETRECOMMENTLIST, data)
end

--[[
    @desc: 获取帮会列表
]]
function GetGangList()
    return mGangList
end

--[[
    @desc: 获取对应职务的名字
    --@duty: 
]]
function GetGangDutyName(duty)
    local dutyName = "非法"
    if duty == 1 then
        dutyName = "帮主"
    elseif duty == 2 then
        dutyName = "副帮主"
    elseif duty == 3 then
        dutyName = "帮会宝贝1"
    elseif duty == 4 then
        dutyName = "帮会宝贝2"
    elseif duty == 5 then
        dutyName = "帮会长老1"
    elseif duty == 6 then
        dutyName = "帮会长老2"
    elseif duty == 7 then
        dutyName = "堂主"
    elseif duty == 8 then
        dutyName = "香主"
    elseif duty == 9 then
        dutyName = "香众"
    elseif duty == 10 then
        dutyName = "精英"
    elseif duty == 11 then
        dutyName = "帮众"
    elseif duty == 12 then
        dutyName = "学徒"
    end
    return dutyName
end

function GetGangInfo()
    return mGangInfo
end

function GetGangMemberList()
    return mGangMemberList
end

--[[
    @desc: 检测是否已经属于一个帮会
]]
function CheckHaveGang()
    --guildid为int64，字符串形式
    if mGangRoleInfo.guildid then
        return mGangRoleInfo.guildid ~= "0"
    else
        return false
    end
end

--[[
    @desc: 打开帮会，内部有一系列判断分支
]]
function OpenGangUI()
    if CheckHaveGang() then
        --有帮会，直接打开帮会主界面
        UIMgr.ShowUI(AllUI.UI_Gang_Main)
    else
        --没有帮会，打开帮会列表界面
        UIMgr.ShowUI(AllUI.UI_Gang_List)
    end
end

function GetGangName()
    return "帮会名字"
end

return GangMgr
