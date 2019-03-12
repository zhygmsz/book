module("RideMgr",package.seeall)

local mOffRideMsg = nil;

local function TipByKey(key,noTipflag)
    if noTipflag then return end
    TipsMgr.TipByKey(key);
end

local function OnRequestRideOff() RequestRideOff() end

local function OnRequestRideOn() RequestRideOn(true) end

--是否在坐骑上
function IsOnRide() return UserData.PlayerAtt.rideData.enable; end

function OnRideOperate(msg)
end

function RequestRideOn(noTip)
    --已经在坐骑上了
    if IsOnRide() then return end
    --默认坐骑
    local rideInfo = UserData.PlayerAtt.rideData.rideInfo;
    local defaultRide = nil;
    for _,rideDynamicData in ipairs(rideInfo.rideInfos) do 
        if rideDynamicData.guid == rideInfo.selectid then 
            defaultRide = rideDynamicData; break 
        end
    end
    --没有坐骑
    if not defaultRide then TipByKey("Ride_msg_donohave",noTip); return end
    local mainPlayer = MapMgr.GetMainPlayer();
    if mainPlayer then
        --释放技能
        if mainPlayer:GetSkillComponent():GetCastingSkillCount() > 0 then TipByKey("Ride_msg_state_fight",noTip); return end
        --战斗状态
        if mainPlayer:GetStateComponent():HasServerState(Common_pb.ESE_CT_INCOMBAT) then TipByKey("Ride_msg_state_fight",noTip); return end
        --变身状态
        if mainPlayer:GetStateComponent():HasServerState(Common_pb.ESE_CT_SHAPED) then TipByKey("Ride_msg_state_change",noTip); return end
        --受限制场景 TODO
        local msg = NetCS_pb.CSRideOperate();
        msg.status = 1;
        GameNet.SendToGate(msg);
    end
end

function RequestRideOff()
    --不在坐骑上
    if not IsOnRide() then return end
    local mainPlayer = MapMgr.GetMainPlayer();
    if mainPlayer then
        --下坐骑
        mainPlayer:GetStateComponent():SyncServerState(mOffRideMsg);
        --发消息
        local msg = NetCS_pb.CSRideOperate();
        msg.status = 0;
        GameNet.SendToGate(msg);
    end
end

function InitModule()
    --下坐骑立即操作,因为下坐骑后会播放其它动画
    mOffRideMsg = NetCS_pb.SCSyncObjectStatus();
    mOffRideMsg.operType = Common_pb.ESOE_DEL;
    mOffRideMsg.status.id = Common_pb.ESE_CT_BIND;

    GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_REQ_RIDE_ON,OnRequestRideOn);
    GameEvent.Reg(EVT.PLAYER,EVT.PLAYER_REQ_RIDE_OFF,OnRequestRideOff);
end

return RideMgr; 