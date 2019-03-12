--个人空间管理 变量
module("PersonSpaceMgr",package.seeall);
local JSON = require "cjson"
--获取玩家朋友圈信息
function UpdateMomentData(playerid,mode,callback)
    if playerid==nil then return end
    playerid = tonumber(playerid)
    if mode == 2 then
        GetServerMomentData(callback)
    else
        GetOtherPlayerServerMomentData(playerid,mode,callback)
    end
end

--获取自己朋友圈服务器数据
function GetServerMomentData(callback)
    SocialNetworkMgr.RequestAskRelatedMoment(function (data,code,jsonData)
        if code==0 then
            local mMomentData={}
            local mMomentExtraPlayerInfo = jsonData["extraplayerinfo"]
            SocialPlayerInfoMgr.AddPlayerInfos(mMomentExtraPlayerInfo)
            for k,v in pairs(data) do
                table.insert(mMomentData,{mmtid = k,foldOpen=false,itemData=v})
            end
            table.sort(mMomentData,function(a,b)
            return a.itemData.createtime < b.itemData.createtime
            end)
            local selfplayerid= tonumber(UserData.PlayerID)
            mMomentDataWithPlayerId[selfplayerid] = mMomentData
            if callback then callback(selfplayerid,2,mMomentDataWithPlayerId[selfplayerid]) end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_UPDATEMOMENTS,selfplayerid,mMomentDataWithPlayerId[UserData.PlayerID],2);
        end
    end,0,mDedaultMomentCount,mDedaultComentCount,detailparams,usrdata_fields,moment_details)
end

--获取别人的朋友圈服务器数据
function GetOtherPlayerServerMomentData(playerid,mode,callback)
    if playerid==nil  or tonumber(playerid)<=0 then return end
    playerid = tonumber(playerid)
    
    SocialNetworkMgr.RequestAskMomentHistory(function (data,code,jsonData)
    local mMomentData={}
    local mMomentExtraPlayerInfo = jsonData["extraplayerinfo"]
    SocialPlayerInfoMgr.AddPlayerInfos(mMomentExtraPlayerInfo)
    for k,v in pairs(data) do
        table.insert(mMomentData,{mmtid = k,foldOpen=false,itemData=v})
    end
    table.sort(mMomentData,function(a,b)
       return a.itemData.createtime < b.itemData.createtime
    end)
    mMomentDataWithPlayerId[playerid] = mMomentData
    if callback then callback(playerid,mode,mMomentDataWithPlayerId[playerid]) end
    GameEvent.Trigger(EVT.PSPACE,EVT.PS_UPDATEMOMENTS,playerid,mMomentDataWithPlayerId[playerid],1);
    end,playerid,0,mDedaultMomentCount,mDedaultComentCount,detailparams,usrdata_fields)
end

--最近一条朋友圈
function GetLastMomentData(callback)
    SocialNetworkMgr.RequestAskRelatedMoment(function (data,code,jsonData)
        if code==0 then
            local mMomentData={}
            for k,v in pairs(data) do
                table.insert(mMomentData,{mmtid = k,itemData=v})
            end
            if #mMomentData>=1 then
                if callback then callback(mMomentData[1].itemData) end
            else
                if callback then callback(nil) end
            end
        end
    end,0,1,0,detailparams,usrdata_fields,moment_details)
end

--发朋友圈
--	photourl=照片url数组的json字符串，限制字符串长度为2048，格式为[{"img":"2222","thn":"323"},{"img":"FDA","thn":"DFADS"}]，每一对img和thn分别代表照片的原图地址和缩略图地址
--iv.	videopreviewurl=视频缩略图url，限制长度255
--v.	videourl=视频url，限制长度255
--vi.	is_appeal=1/0,1代表申诉提交
--vii.	audio=音频url
--viii.	audiolen=音频长度
--ix.	is_private=1/0,1代表私密，0代表公开
function AddMoment(content,photos,videopreviewurl,videourl,audio,audiolen,location,is_private,is_appeal)
    local photourl =""
    if photos then
        photourl = JSON.encode(photos)
    end
    local params = string.format("content=%s&photourl=%s&videopreviewurl=%s&videourl=%s&audio=%s&audiolen=%s&location=%s&is_private=%s&is_appeal=%s",content,photourl,videopreviewurl,videourl,audio,audiolen,location,is_private,is_appeal);
    SocialNetworkMgr.RequestAction("AddMoment",params,function(data,code,jsonData)
        if code == 0 then
            PersonSpaceMgr.GetServerMomentData()
        end
    end)
end

--删除状态
function DeleteMoment(mmtid)
    local params = string.format("mmtid=%s",mmtid);
    SocialNetworkMgr.RequestAction("DelMoment",params,function(data,code,jsonData)
        if code == 0 then--result.deletedlist存的是删除成功的mmtid，undeletedlist存的是删除失败的mmtid
            PersonSpaceMgr.GetServerMomentData()
        end
    end);
end

--分享状态
function ShareMoment(mmtid)
end

--点赞 mmtid=被点赞的状态id
function LikeMoment(mmtid,dataIndex)
    local cplayerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    local mMomentData = mMomentDataWithPlayerId[cplayerid]
    local params = string.format("optype=addmomentlike&mmtid=%s",mmtid)
    SocialNetworkMgr.RequestAction("ExternalModifyMoment",params,function(data,code,jsonData)
        if code == 0 then --1003	状态不存在 --1004	数据存储失败
            local mdata = mMomentData[dataIndex]
            if mdata and mdata.mmtid==mmtid then
                mdata.itemData.likedbyme=1
                --玩家id
                local playerid = tonumber(cplayerid)
                if mdata.itemData.recentlikers==nil then mdata.itemData.recentlikers = {} end
                table.insert(mdata.itemData.recentlikers,playerid)
                local count = tonumber(mdata.itemData.likecnt)+1
                mdata.itemData.likecnt = tostring(count)
            end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_LIKEUPDATE,mmtid,dataIndex);
        elseif code == 50003 then--50003	早已点过赞，无法再次点赞
            TipsMgr.TipByKey("personspace_have_liked")
        end
    end)
end

--取消点赞 mmtid=被点赞的状态id
function UnLikeMoment(mmtid,dataIndex)
    local cplayerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    local mMomentData = mMomentDataWithPlayerId[cplayerid]
    local params = string.format("optype=delmomentlike&mmtid=%s",mmtid)
    SocialNetworkMgr.RequestAction("ExternalModifyMoment",params,function(data,code,jsonData)
        if code == 0 then--50003	早已点过赞，无法再次点赞 --1003	状态不存在 --1004	数据存储失败
            local mdata = mMomentData[dataIndex]
            if mdata and mdata.mmtid==mmtid then
                mdata.itemData.likedbyme=0
                local playerid = tonumber(cplayerid)
                local rkey = nil
                for key,pid in pairs(mdata.itemData.recentlikers) do
                    if pid == playerid then
                        rkey = key
                    end
                end
                if rkey then mdata.itemData.recentlikers[rkey] = nil end
                local count = tonumber(mdata.itemData.likecnt)-1
                count = math.max(0,count)
                mdata.itemData.likecnt = tostring(count)
            end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_LIKEUPDATE,mmtid,dataIndex);
        end
    end)
end

--评论朋友圈 mmtid=被点赞的状态id
function CommentMoment(content,mmtid,dataIndex)
    local cplayerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    local mMomentData = mMomentDataWithPlayerId[cplayerid]
    local params = string.format("content=%s&mmtid=%s&replyid=0",content,mmtid)
    SocialNetworkMgr.RequestAction("AddMomentComment",params,function(data,code,jsonData)
        if code == 0 then--50003	早已点过赞，无法再次点赞 --1003	状态不存在 --1004	数据存储失败
            local mdata = mMomentData[dataIndex]
            if mdata and mdata.mmtid==mmtid then
                mdata.itemData.comments[data.cmtid]=data
                local count = tonumber(mdata.itemData.cmtcnt)+1
                mdata.itemData.cmtcnt = tostring(count)
            end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_COMMENTUPDATE,mmtid,dataIndex);
        end
    end)
end

--回复评论 mmtid=被点赞的状态id ii.	content=评论内容  mmtid=被评论的状态id 	replyid=被回复的玩家id
function CommentMomentReply(content,mmtid,replyid,dataIndex)
    local cplayerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    local mMomentData = mMomentDataWithPlayerId[cplayerid]
    local params = string.format("content=%s&mmtid=%s&replyid=%s",content,mmtid,replyid)
    SocialNetworkMgr.RequestAction("AddMomentComment",params,function(data,code,jsonData)
        if code == 0 then--32002	状态不存在 34004	没有权限在对方朋友圈评论
           --{"mmtid":"218080624408395777","content":"content","replyid":1,"cmtid":"219206160081879041","sendid":1,"createtime":1535462821}}
           local mdata = mMomentData[dataIndex]
           if mdata and mdata.mmtid==mmtid then
               mdata.itemData.comments[data.cmtid]=data
           end
           GameEvent.Trigger(EVT.PSPACE,EVT.PS_COMMENTUPDATE,mmtid,dataIndex);
        end
    end)
end

--删除评论 i.	action=DelMomentComment 
   -- ii.	cmtid=评论id 
   -- iii.	mmtid=留言所属的状态id
function DeleteComment(mmtid,cmtid,dataIndex)
    local cplayerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    local mMomentData = mMomentDataWithPlayerId[cplayerid]
    local params = string.format("mmtid=%s&cmtid=%s",mmtid,cmtid)
    SocialNetworkMgr.RequestAction("DelMomentComment",params,function(data,code,jsonData)
        if code == 0 then--32002	状态不存在 34004	没有权限在对方朋友圈评论
            local mdata = mMomentData[dataIndex]
            if mdata and mdata.mmtid==mmtid then
                mdata.itemData.comments[cmtid]=nil
                local count = tonumber(mdata.itemData.cmtcnt)-1
                count = math.max(0,count)
                mdata.itemData.cmtcnt = tostring(count)
            end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_DELETECOMMENT,mmtid,cmtid,dataIndex);
        end
    end)
end

--获取状态的评论 optype=detail count detailwithplayer  detailparams不知道什么意思
function AskMomentComments(mmtid,start,cnt,dataIndex)
    local cplayerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    local mMomentData = mMomentDataWithPlayerId[cplayerid]
    local params = string.format("cmd=moment_mmtcmthistory_customcontent&optype=detailwithplayer&mmtid=%s&start=%s&cnt=%s&%s&detailparams=%s",mmtid,start,cnt,SocialNetworkMgr.BasicPlayerDetailParam(detailparams,usrdata_fields),"mmtid,cmtid,sendid,replyid,createtime,likedbyme,content,likecnt")
    SocialNetworkMgr.RequestAction("AskMomentCommentHistory",params,function(data,code,jsonData)
        if code == 0 then--32002	状态不存在 34004	没有权限在对方朋友圈评论
            local commentsPlayerInfo = jsonData["extraplayerinfo"]
            if commentsPlayerInfo then
                SocialPlayerInfoMgr.AddPlayerInfos(commentsPlayerInfo)
            end
            local mdata = mMomentData[dataIndex]
            if mdata and mdata.mmtid==mmtid then
                for k,v in pairs(data) do
                    mdata.itemData.comments[v.cmtid]=v
                end
            end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_COMMENTUPDATE,mmtid,dataIndex);
        end
    end)
end

--获取状态的点赞
function AskMomentLikes(mmtid,cnt,dataIndex)
    local cplayerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    local mMomentData = mMomentDataWithPlayerId[cplayerid]
    local params = string.format("optype=detail&mmtid=%s&start=%s&cnt=%s&%s",mmtid,cnt,SocialNetworkMgr.BasicPlayerDetailParam(detailparams,usrdata_fields))
    SocialNetworkMgr.RequestAction("AskMomentLikers",params,function(data,code,jsonData)
        if code == 0 then--32002	状态不存在 34004	没有权限在对方朋友圈评论
            --"1":{"nickname":"HAHAHA","level":"12","device_id":"1"
            if data then
                SocialPlayerInfoMgr.AddPlayerInfos(data)
            end
            local mdata = mMomentData[dataIndex]
            if mdata and mdata.mmtid==mmtid then
                for k,v in pairs(data) do
                    if mdata.itemData.recentlikers[k]==nil then
                        table.insert(mdata.itemData.recentlikers,k)
                    end
                end
            end

            GameEvent.Trigger(EVT.PSPACE,EVT.PS_LIKEUPDATE,mmtid,dataIndex);
        end
    end)
end


--添加留言
function AddHeroMessage(playerid,content)
    local params = string.format("targetid=%s&flower_rec=%s",playerid,content)
    SocialNetworkMgr.RequestAction("AddFlowerRecord",params,function(data,code,jsonData)
        if code == 0 then
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_ADDMS,playerid,content);
        end
    end)
end

--拉取留言
function AskHeroMessageBoard(playerid,start,cnt)
    local param = string.format("player_params=%s&usrdata_fields=%s",detailparams,usrdata_fields);
    local params = string.format("id=%s&start=%d&cnt=%d&%s",playerid,start,cnt,param)
    SocialNetworkMgr.RequestAction("AskFlowerRecord",params,function(data,code,jsonData)
        if code == 0 then
            local commentsPlayerInfo = jsonData["extraplayerinfo"]
            if commentsPlayerInfo then
                SocialPlayerInfoMgr.AddPlayerInfos(commentsPlayerInfo)
            end
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_ASKMSGBOAR,playerid,data);
        end
    end)
end

function DelHeroMessage(sender,content)
    local params = string.format("sender=%d&flower_rec=%s",sender,content)
    SocialNetworkMgr.RequestAction("DelFlowerRecord",params,function(data,code,jsonData)
        if code == 0 then
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_DELMS,sender,content);
        end
    end)
end

--添加人气值
function AddPopularity(target)
    local params = string.format("target=%d",target)
    SocialNetworkMgr.RequestAction("AddPopularity",params,function(data,code,jsonData)
        if code == 0 then
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_ADDPOP,target,data.popularity);
        end
    end)
end

--请求人气值
function AskPopularity(target)
    local params = string.format("target=%d",target)
    SocialNetworkMgr.RequestAction("AskPopularity",params,function(data,code,jsonData)
        if code == 0 then
            GameEvent.Trigger(EVT.PSPACE,EVT.PS_ASKPOP,target,data.popularity,data.pop_clked);
        end
    end)
end
