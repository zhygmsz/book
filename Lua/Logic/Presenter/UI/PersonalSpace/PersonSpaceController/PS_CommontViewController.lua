

local PS_CommontViewController = class("PS_CommontViewController",nil)
local ChatInputWrap = require("Logic/Presenter/UI/Chat/ChatInputWrap")
require("Logic/Presenter/UI/Friend/UI_Shortcut_Player");
local curReplyIndex= 0

function PS_CommontViewController:ctor(ui,transform,index)
    self._ui = ui
    self._index = index
    --评论区域
    self._comentItem= transform:Find("Bg/CommentItem").gameObject
    self._comentItem:SetActive(false)
    self._commentRegion = transform:Find("Bg/TextZone/CommentRegion"):GetComponent("UIWidget")
    self._commentUITable = transform:Find("Bg/TextZone/CommentRegion/Comments"):GetComponent("UITable")
    self._commentstWidget = transform:Find("Bg/TextZone/CommentRegion/Comments"):GetComponent("UIWidget")
    self._commentIcon = transform:Find("Bg/TextZone/CommentRegion/CommentIcon").gameObject
    self._mCommentItems={}
    self._commentsList={}
    self._momentdataIndex = nil
end

--添加玩家链接
local function AddPlayerLink(links,name,palyerid)
    local newMsgLink = links:add()
    local msgLink  = Chat_pb.ChatMsgLink()
    msgLink.linkType = Chat_pb.ChatMsgLink.PLAYER
    msgLink.isValid = true
    msgLink.content = string.format("%s",name)
    msgLink.contentWithId = string.format("[%s]",name)
    msgLink.linkDesc.textDesc.color = "[0000ff]"
    msgLink.strParams:append(palyerid)
    newMsgLink:ParseFrom(msgLink)
    return newMsgLink
end

function PS_CommontViewController:GetCommentItem(i)
    if self._mCommentItems[i] == nil then
        local item = {};
        item.index = i;
        item.gameObject =  self._ui:DuplicateAndAdd(self._comentItem.transform,self._commentUITable.gameObject.transform,i).gameObject;
        item.gameObject.name = tostring(10000 + i);
        item.transform = item.gameObject.transform;
        item.widget = item.transform:GetComponent("UIWidget")
        item.icon = item.transform:Find("Icon"):GetComponent("UISprite")
        item.like = item.transform:Find("Like"):GetComponent("UISprite")
        item.delete = item.transform:Find("Delete"):GetComponent("UISprite")
        item.content = item.transform:Find("Content"):GetComponent("UILabel")
        item.iconEvent = item.transform:Find("Icon"):GetComponent("UIEvent")
        item.likeEvent = item.transform:Find("Like"):GetComponent("UIEvent")
        item.deleteEvent = item.transform:Find("Delete"):GetComponent("UIEvent")
        item.contentEvent = item.transform:Find("Content"):GetComponent("UIEvent")
        item.iconEvent.id = self._index*10000+i*10+2000+1
        item.contentEvent.id = self._index*10000+i*10+2000+3
        item.likeEvent.id = self._index*10000+i*10+2000+4
        item.deleteEvent.id = self._index*10000+i*10+2000+5
        self._mCommentItems[i] = item
    end
    return self._mCommentItems[i]
end

 --更新评论信息
 function PS_CommontViewController:InitCommentItems(momentdataIndex,commentsList,foldOpen)
    for i=1,#self._mCommentItems do
        self._mCommentItems[i].gameObject:SetActive(false);
    end
    local yoffset = 0
    local index = 1;
    self._momentdataIndex = momentdataIndex
    self._commentsList= commentsList
    local count = table.getn(commentsList)
    if count>0 then
        --默认加载的评论数
        local defaulycmtcnt = PersonSpaceMgr.GetDefaultComentCount()
        if not foldOpen then count =math.min(defaulycmtcnt,count) end
        for i = 1,count do
            local mCommentItem = self:GetCommentItem(i)
            local commentData = commentsList[i]
            mCommentItem.dataIndex = i
            local ownerid =tostring(commentData.sendid)
            local replyid =tostring(commentData.replyid)
            local owerdata= PersonSpaceMgr.GetPlayerInfoById(ownerid)
            local replydata= PersonSpaceMgr.GetPlayerInfoById(replyid)
            local likedbyme =commentData.likedbyme
            mCommentItem.content.transform.localPosition = Vector3(5,0,0)
            mCommentItem.content.width = 480

            local commonmsgstr = string.FromBase64(commentData.content)
            local msgCommon = Chat_pb.ChatMsgCommon()
            msgCommon:ParseFromString(commonmsgstr)
        
            local name1 = owerdata and string.format("%s",AddPlayerLink(msgCommon.links,owerdata:GetNickName(),ownerid).contentWithId) or ""
            local name2 = replydata and string.format("%s",AddPlayerLink(msgCommon.links,replydata:GetNickName(),replyid).contentWithId) or ""
            local name3 = replydata and TipsMgr.GetTipByKey("personspace_comment_reply") or ""
            msgCommon.content = string.format("%s%s%s:%s",name1,name3,name2,msgCommon.content)

            TextHelper.ProcessItemCommon(self._ui,
            mCommentItem,
            msgCommon.content,
            mCommentItem.content.transform,
            mCommentItem.content.width,
            0,
            true,
            msgCommon.links, nil, nil, nil, nil)
            mCommentItem.msgCommon = msgCommon
            mCommentItem.content.text ="" 
            --玩家id
            local playerid = PersonSpaceMgr.GetCurrentShowPlayerId()
            --判断是不是我评论的 是我评论的 显示删除 不是我评论的显示like
            if playerid == ownerid then
                mCommentItem.delete.gameObject:SetActive(true);
                mCommentItem.like.gameObject:SetActive(false);
            else
                mCommentItem.delete.gameObject:SetActive(false);
                mCommentItem.like.gameObject:SetActive(true);
                mCommentItem.like.spriteName =likedbyme==1 and "icon_common_zan" or "icon_common_zan"
            end
            mCommentItem.gameObject:SetActive(true);
            mCommentItem.widget.height= mCommentItem.curHeight + self._commentUITable.padding.y
            yoffset=yoffset+mCommentItem.widget.height
        end
    end
    self._comentItem:SetActive(false);
    self._commentUITable:Reposition()
    self._commentstWidget.height = yoffset+self._commentUITable.padding.y
    self._commentRegion.height = self._commentstWidget.height 
end

function PS_CommontViewController:GetWidget()
    return self._commentRegion
end

function PS_CommontViewController:OnClick(go,localid)
    local comindex=localid-2000
    local index = math.floor(comindex/10)
    local eventid = comindex%10
    if eventid ==1 or  eventid ==2 then --icon --name
        local dataIndex= self._mCommentItems[index].dataIndex
        local commentData = self._commentsList[dataIndex]
        local sendid = commentData.sendid
        FriendMgr.OpenFriendShortcut(sendid)
    elseif eventid ==2 then --icon --name
        
    elseif eventid ==3 then --content 点击内容 例如人名
        local linkIdx =self._mCommentItems[index].imageLabelContent:ProcessClick()
        if linkIdx then
            local msgCommon = self._mCommentItems[index].msgCommon
            local linkData = msgCommon.links[linkIdx]
            if linkData then
               if linkData.linkType == Chat_pb.ChatMsgLink.PLAYER then
                    local playerid  = linkData.strParams[1]
                    UI_Shortcut_Player.ShowPlayerByID(playerid)
               end
            end
        end
    elseif eventid ==4 then --like
        
    elseif eventid ==5 then --del
        local dataIndex= self._mCommentItems[index].dataIndex
        local commentData = self._commentsList[dataIndex]
        local cmtid = commentData.cmtid
        local mmtid = commentData.mmtid
        local sendid = commentData.sendid
        local replyid =tostring(sendid)
        PersonSpaceMgr.DeleteComment(mmtid,cmtid,self._momentdataIndex)
    end
end 

return PS_CommontViewController