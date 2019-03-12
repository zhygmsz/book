--个人空间管理 变量
module("PersonSpaceMgr",package.seeall);

require ("Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Moments")
require("Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Main")
require("Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Info")
require("Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_Tag")


SocialPlayerInfo = require("Logic/System/Social/SocialPlayerInfo")

--玩家信息表
mOtherPlayerInfo = {}
--玩家个性标签表
mPlayerTags = {}
--朋友圈id栈
mPlayerIdStack ={}

mCurrentShowPlayerId =-1
--无图模式
mImageMode = true

--默认请求朋友圈条数
mDedaultMomentCount  =10
--默认请求朋友圈评论条数
mDedaultComentCount  =3

detailparams =SocialPlayerInfoMgr.detailparams -- '"playerid,playerid,nickname,icon,location,selfintro,localicon,voicemsg,voicemsglen,voicemsglen"'
--userdata 参数
usrdata_fields =SocialPlayerInfoMgr.usrdata_fields --'"level,game_svr_id,sex,home,mempai_id,level,guild_name,spouse_name,title_name,title_name"'

moment_details ="detailparams=mmtid,ownerid,location,content,photourl,audiourl,videourl,videopreviewurl,createtime,likecnt,cmtcnt,verify,recentlikers"
--朋友圈数据
mMomentDataWithPlayerId ={}

function PopShowPlayerId()
    local n = table.count(mPlayerIdStack)
    if n>0 then
        local id = mPlayerIdStack[n]
        mPlayerIdStack[n] = nil
        return id
    end
    return nil
end

function PeekShowPlayerId()
    local n = table.count(mPlayerIdStack)
    if n>0 then
        local id = mPlayerIdStack[n]
        return id
    end
    return nil
end

function PushShowPlayerId(id)
   local n = table.count(mPlayerIdStack)
   mPlayerIdStack[n+1] = id
end
