--个人空间管理
module("PersonSpaceMgr",package.seeall);

function InitModule()
    require("Logic/System/Social/PersonSpaceMgr_Value")
    require("Logic/System/Social/PersonSpaceMgr_Image")
    require("Logic/System/Social/PersonSpaceMgr_Msg")
end

function InitSNS()
    mImageMode = UserData.ReadBoolConfig("ImageMode",true)
end

--获取个人玩家信息
function GetSelfPlayerInfo(callback)
    return SocialPlayerInfoMgr.GetSelfPlayerInfo(callback)
end

function GetPlayerInfoById(playerid,callback)
    return SocialPlayerInfoMgr.GetPlayerInfoById(playerid,callback)
end

--默认请求朋友圈条数
function GetDedaultMomentCount()
    return mDedaultMomentCount
end

--默认请求朋友圈评论条数
function GetDefaultComentCount()
    return mDedaultComentCount
end

--获取朋友圈数据
function GetMomentData()
    return GetMomentDataById(tonumber(UserData.PlayerID),2)
end

--获取朋友圈数据
function GetMomentDataById(playerid,mode,callback)
    if playerid==nil  or tonumber(playerid)<=0 then return end
    playerid = tonumber(playerid)
    if mMomentDataWithPlayerId[playerid] and callback == nil then return mMomentDataWithPlayerId[playerid] end
    if mMomentDataWithPlayerId[playerid] and callback then callback(playerid,mode,mMomentDataWithPlayerId[playerid]) end
    UpdateMomentData(playerid,mode,callback)
end

function GetCurrentShowPlayerId()
    mCurrentShowPlayerId = PeekShowPlayerId()
    return mCurrentShowPlayerId
end

--打开空间主界面
function OpenPSpaceMain()
    mCurrentShowPlayerId = tonumber(UserData.PlayerID)
    PushShowPlayerId(mCurrentShowPlayerId)
    UIMgr.ShowUI(AllUI.UI_PersonalSpace_Main,nil,nil,nil,nil,true,mCurrentShowPlayerId,2)
    UpdateMomentData(mCurrentShowPlayerId,2)
end

--打开某个人的主页
function OpenPSpaceOnlyOnePerson(playerid)
    if playerid==nil then return end
    playerid = tonumber(playerid)
    mCurrentShowPlayerId = playerid
    PushShowPlayerId(mCurrentShowPlayerId)
    if mCurrentShowPlayerId == tonumber(UserData.PlayerID) then
        UIMgr.ShowUI(AllUI.UI_PersonalSpace_Main,nil,nil,nil,nil,true,mCurrentShowPlayerId,1)
        UpdateMomentData(mCurrentShowPlayerId,1)
    else
        UIMgr.ShowUI(AllUI.UI_PersonalSpace_Other,nil,nil,nil,nil,true,mCurrentShowPlayerId,1)
        UpdateMomentData(mCurrentShowPlayerId,1)
    end
end

--保存弹出视图的好友备注
function SavePopPadRemark(playerid,reName)
    if playerid==nil then return end
    playerid = tonumber(playerid)
    RequestModifyGameFriendRemark(function (data)
    end, tonumber(playerid), reName)
end

function UpdateMomentsView() 
    UI_PersonalSpace_Moments.UpdateView()
end

--点开评论的折叠
function MomentsFoldOpen(index,foldOpen)
    local cplayerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    local mMomentData = mMomentDataWithPlayerId[cplayerid]
    mMomentData[index].foldOpen = foldOpen
    GameEvent.Trigger(EVT.PSPACE,EVT.PS_COMMENTUPDATE,mMomentData[index].mmtid,index);
end

--查看更多评论
function GetMoreComments(mmtid,dataIndex,count)
    AskMomentComments(mmtid,count,3,dataIndex)
end

return PersonSpaceMgr