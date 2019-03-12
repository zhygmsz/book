local PS_SpaceItemViewController = class("PS_SpaceItemViewController",nil)
local ChatInputWrap = require("Logic/Presenter/UI/Chat/ChatInputWrap")
local PS_CommontViewController = require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/PS_CommontViewController")
local PS_LikeViewController = require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/PS_LikeViewController")
local PS_ImageViewController = require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/PS_ImageViewController")
require("Logic/Presenter/UI/Friend/UI_Shortcut_Player");
local curReplyIndex= 0

function PS_SpaceItemViewController:ctor(ui,transform,index,mShowMode)
    self._ui = ui
    self._index = index
    --是否被自己点赞
    self._liked = false
    --显示模式 1是别人的 2是自己的
    self._mShowMode= mShowMode
    --是否显示了全部信息
    self._showAll = false
    self._widget = transform:GetComponent("UIWidget")
    self._Height =  self._widget.height
    self._bg = transform:Find("Bg"):GetComponent("UISprite")
    --头像
    self._icon={}
    self._icon.texture = transform:Find("Bg/Icon"):GetComponent("UITexture")
    self._icon.default = transform:Find("Bg/Icon/DefaultIcon"):GetComponent("UISprite")
    self._icon.event = transform:Find("Bg/Icon"):GetComponent("UIEvent")
    self._icon.event.id = self._index*10000+1
    --名字
    self._name = transform:Find("Bg/Name"):GetComponent("UILabel")
     --服务器
    self._server = transform:Find("Bg/Server"):GetComponent("UILabel")
    --定位图标
    self._sprite = transform:Find("Bg/Sprite"):GetComponent("UISprite")
    --定位文字
    self._location = transform:Find("Bg/Location"):GetComponent("UILabel")
    --发布时间
    self._time = transform:Find("Bg/Time"):GetComponent("UILabel")
    --内容
    self._content = transform:Find("Bg/Content"):GetComponent("UILabel")
    self._contentUIWidget = transform:Find("Bg/Content"):GetComponent("UIWidget")
    --浏览次数
    self._browse = transform:Find("Bg/Browse"):GetComponent("UILabel")
    --功能按钮
    self._funcBtns={}
    self._funcBtns.obj = transform:Find("Bg/FuncBtns")
    self._funcBtns.event = transform:Find("Bg/FuncBtns"):GetComponent("UIEvent")
    self._funcBtns.event.id = self._index*10000+5
    --展开按钮
    self._btnCommentFold={}
    self._btnCommentFold.transform  = transform:Find("Bg/TextZone/BtnCommentFold")
    self._btnCommentFold.sprite  = transform:Find("Bg/TextZone/BtnCommentFold"):GetComponent("UISprite")
    self._btnCommentFold.event  = transform:Find("Bg/TextZone/BtnCommentFold"):GetComponent("UIEvent")
    self._btnCommentFold.event.id = self._index*10000+6
    --更多按钮
    self._btnCommentMore={}
    self._btnCommentMore.transform  = transform:Find("Bg/TextZone/BtnCommentMore")
    self._btnCommentMore.event  = transform:Find("Bg/TextZone/BtnCommentMore"):GetComponent("UIEvent")
    self._btnCommentMore.event.id = self._index*10000+7
    --图片区域
    self._imageItem = transform:Find("Bg/ImageItem").gameObject
    self._imageItem:SetActive(false)
    self._imageContentWidget = transform:Find("Bg/ImageContent"):GetComponent("UIWidget")
    self._imageContentUITable = transform:Find("Bg/ImageContent"):GetComponent("UITable")
    --按钮集合区域
    self._buttonsWidget = transform:Find("Bg/Buttons"):GetComponent("UIWidget")
    self._BtnFavor={}
    self._BtnFavor.obj = transform:Find("Bg/Buttons/BtnFavor").gameObject
    self._BtnFavor.icon = transform:Find("Bg/Buttons/BtnFavor/Sprite"):GetComponent("UISprite")
    self._BtnFavor.label = transform:Find("Bg/Buttons/BtnFavor/Label"):GetComponent("UILabel")
    self._BtnFavor.event = transform:Find("Bg/Buttons/BtnFavor"):GetComponent("UIEvent")
    self._BtnFavor.event.id = self._index*10000+2
    self._BtnComment={}
    self._BtnComment.event = transform:Find("Bg/Buttons/BtnComment"):GetComponent("UIEvent")
    self._BtnComment.event.id = self._index*10000+3
    self._BtnGift={}
    self._BtnGift.event = transform:Find("Bg/Buttons/BtnGift"):GetComponent("UIEvent")
    self._BtnGift.event.id = self._index*10000+4
    self._BtnShare={}
    self._BtnShare.event = transform:Find("Bg/Buttons/BtnShare"):GetComponent("UIEvent")
    self._BtnShare.event.id = self._index*10000+11
    self._BtnDel={}
    self._BtnDel.event = transform:Find("Bg/Buttons/BtnDelete"):GetComponent("UIEvent")
    self._BtnDel.event.id = self._index*10000+12
    --回复视图
    self._ReplyView={}
    self._ReplyView.obj = transform:Find("Bg/ReplyView").gameObject 
    self._ReplyView.backEvent = transform:Find("Bg/ReplyView/BtnBack"):GetComponent("UIEvent")
    self._ReplyView.backEvent.id = self._index*10000+8
    self._ReplyView.lookEvent = transform:Find("Bg/ReplyView/BtnLook"):GetComponent("UIEvent")
    self._ReplyView.lookEvent.id = self._index*10000+9
    self._ReplyView.replyEvent = transform:Find("Bg/ReplyView/BtnReply"):GetComponent("UIEvent")
    self._ReplyView.replyEvent.id = self._index*10000+10
    self._ReplyView.Input = transform:Find("Bg/ReplyView/MsgView/Input"):GetComponent("LuaUIInput")
    self._ReplyView.mChatInputWrap = ChatInputWrap.new(self._ReplyView.Input, ChatMgr.CommonLinkOpenType.FromPersonSpace)
    self._ReplyView.mChatInputWrap:ResetMsgCommon()
    self._ReplyView.mChatInputWrap:ResetLimitCount(1000)
    self._ReplyView.mChatInputWrap:ResetRoomType(Chat_pb.CHAT_ROOM_WORLD)
    self._ReplyView.Input.defaultText = TipsMgr.GetTipByKey("personspace_reply_default")
    self._ReplyView.InputLabel = transform:Find("Bg/ReplyView/MsgView/Input/Label"):GetComponent("UILabel")
    self._ReplyView.InputWidget = transform:Find("Bg/ReplyView/MsgView/Input"):GetComponent("UIWidget")
    local function OnMsgChange()
        local ow = self._ReplyView.InputWidget.width
        local cw = self._ReplyView.InputLabel.width
        if cw>ow then
            self._ReplyView.InputWidget.width = cw
        end
    end
    local changeCall = EventDelegate.Callback(OnMsgChange);
    EventDelegate.Add(self._ReplyView.Input.onChange,changeCall);
    self._ReplyView.obj:SetActive(false)
    self._ReplyView._tweenPos = self._ReplyView.obj:AddComponent(typeof(TweenPosition))

    local function OnTweenFinish()
        self._ReplyView._tweenPos.enabled = false
    end
    local finishFunc = EventDelegate.Callback(OnTweenFinish)
    EventDelegate.Set(self._ReplyView._tweenPos.onFinished, finishFunc)
    --文字区域
    self._textZone = transform:Find("Bg/TextZone"):GetComponent("UIWidget")
    self._likesIcon = transform:Find("Bg/TextZone/LikeRegion/LikeIcon").gameObject
    --评论区域
    self._commentIcon = transform:Find("Bg/TextZone/CommentRegion/CommentIcon").gameObject
    self._mImageItems={}
    self._mCommentItems={}
    self._mLikeItems={}
    self._momentdata = nil
    self._commontsControl =PS_CommontViewController.new(ui,transform,index)
    self._likesControl =PS_LikeViewController.new(ui,transform,index)
    self._imagesControl =PS_ImageViewController.new(ui,transform,index)
end

function PS_SpaceItemViewController:ReplyViewTween(forward)
    self._ReplyView.obj:SetActive(true)
    self._ReplyView._tweenPos.enabled = true
    self._ReplyView._tweenPos.worldSpace = false
    local y = self._buttonsWidget.transform.localPosition.y-24
    if forward then
        self._buttonsWidget.transform.gameObject:SetActive(false)
        self._ReplyView._tweenPos.from = Vector3(1193.9,y,0)
        self._ReplyView._tweenPos.to =  Vector3(420,y,0)
        self._replyOpen = true
    else
        self._buttonsWidget.transform.gameObject:SetActive(true)
        self._ReplyView._tweenPos.to = Vector3(1193.9,y,0)
        self._ReplyView._tweenPos.from =  Vector3(420,y,0)
        self._replyOpen = false
    end
	self._ReplyView._tweenPos.duration = 0.1
	self._ReplyView._tweenPos:ResetToBeginning()
    self._ReplyView._tweenPos:PlayForward()
end

--更新图片信息
function PS_SpaceItemViewController:InitImageItems(dataindex,data)
    self._imagesControl:InitImageItems(dataindex,data)
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

--添加玩家链接
local function AddLikesLink(msgCommon,name,palyerid)
    local newMsgLink = msgCommon.links:add()
    local msgLink  = Chat_pb.ChatMsgLink()
    msgLink.linkType = Chat_pb.ChatMsgLink.PLAYER
    msgLink.isValid = true
    msgLink.content = string.format("%s",name)
    msgLink.contentWithId = string.format("[%s]",name)
    msgLink.linkDesc.textDesc.color = "[0000ff]"
    msgLink.strParams:append(palyerid)
    newMsgLink:ParseFrom(msgLink)
    msgCommon.content = string.format("%s,%s",msgCommon.content,msgLink.contentWithId)
    return newMsgLink
end

 --更新点赞信息
function PS_SpaceItemViewController:InitLikeItems(dataindex,data)
    self._likesControl:InitLikeItems(dataindex,data)
 end

 --更新评论信息
function PS_SpaceItemViewController:InitCommentItems(dataindex,commentsList)
    self._commontsControl:InitCommentItems(dataindex,commentsList,self._foldOpen)
end

function PS_SpaceItemViewController:SetModel(showMode)
    self._mShowMode =showMode
end

function PS_SpaceItemViewController:ReSetupView()
    local alldata = PersonSpaceMgr.GetMomentData()
    self._fulldata= alldata[self._momentdataIndex]
    self:SetupView(self._fulldata,self._momentdataIndex)
end

--设置数据 状态数据结构
function PS_SpaceItemViewController:SetupView(data,dataIndex)
    --状态id
    self._fulldata = data
    self._mmtid = data.mmtid
    self._momentdata = data.itemData
    self._momentdataIndex = dataIndex
    --状态的发布者
    self._owerdata= PersonSpaceMgr.GetPlayerInfoById(self._momentdata.ownerid)
    --玩家自己
    local selfData = PersonSpaceMgr.GetPlayerInfoById(UserData.PlayerID)
    if self._owerdata==nil or selfData==nil then return  end
    --朋友圈的主人
    local playerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    --是否是自己的状态
    self._myMmt = playerid==self._momentdata.ownerid --UserData.PlayerID
    --是否是自己的朋友圈
    --是否同服
    self._sameServer = selfData:GetServerId() == self._owerdata:GetServerId()
    self._liked = self._momentdata.likedbyme==1
    --评论总个数
    local cmtcnt = tonumber(self._momentdata.cmtcnt)
    --赞总个数
    local likecnt = tonumber(self._momentdata.likecnt)
    local showLocation = (self._momentdata.location ~= nil and self._momentdata.location ~= "")
    --评论数组
    self._commentsList ={}
    local index = 1
    for k,v in pairs(self._momentdata.comments) do
        self._commentsList[index]=v
        index = index+1
    end
    --时间排序
    table.sort(self._commentsList,function(a,b)
        return tonumber(a.createtime) < tonumber(b.createtime)
    end)

    self._curcmtcnt =table.getn(self._commentsList)
    --还有更多评论可以加载
    self._hasMore = self._curcmtcnt < cmtcnt
    --fold打开状态
    if data.foldOpen == nil then data.foldOpen=false; end
    self._foldOpen = data.foldOpen
    --默认加载的评论数
    local defaulycmtcnt = PersonSpaceMgr.GetDefaultComentCount()
    --默认加载数量已经大于等于所有数量 不显示更多fold按钮
    self._btnCommentFold.transform.gameObject:SetActive(cmtcnt>defaulycmtcnt) 
    --点赞数量为零 不显示点赞按钮
    self._likesIcon.gameObject:SetActive(likecnt>0) 
    --评论数量为零 不显示评论按钮
    self._commentIcon.gameObject:SetActive(self._curcmtcnt>0)
    --位置信息的显示隐藏
    self._sprite.gameObject:SetActive(showLocation)
    self._location.gameObject:SetActive(showLocation)
     --打开状态 还有更多 显示更多按钮
    self._showAll = not (data.foldOpen and self._hasMore)
    self._textZone.transform.gameObject:SetActive((likecnt >0 or cmtcnt>0))
    --点赞按钮状态
     if not self._liked then
       -- self._BtnFavor.icon.spriteName = "icon_common_zan"--self._BtnFavor.label.text="点赞"
    else
      --  self._BtnFavor.icon.spriteName = "icon_common_zan"--self._BtnFavor.label.text="点赞"
    end
    if self._foldOpen  then
        self._btnCommentFold.transform.localRotation = Quaternion.Euler(0, 0,90)
    else
        self._btnCommentFold.transform.localRotation=Quaternion.Euler(0, 0,-90)
    end
    --回复视图显示状态
    self._replyOpen = false
    self._BtnDel.event.transform.gameObject:SetActive(self._myMmt)
    --赋值
    --self._content.text = self._momentdata.content
    local commonmsgstr = string.FromBase64(self._momentdata.content) or ""
    local msgCommon = Chat_pb.ChatMsgCommon()
    msgCommon:ParseFromString(commonmsgstr)
    TextHelper.ProcessItemCommon(self._ui,
    self,
    msgCommon.content,
    self._content.transform,
    self._content.width,
    0,
    true,
    msgCommon.links, nil, nil, nil, nil)
    self._content.height = self.curHeight
    self._imageContentcount = table.getn(self._momentdata.photourl)
    self._name.text =self._owerdata:GetNickName()
    self._server.text = self._sameServer and TipsMgr.GetTipByKey("personspace_moment_sameserver") or self._owerdata:GetServerId()
    self._owerdata:SetHeadIcon(self._icon.texture,self._icon.default)
    if self._mShowMode == 2 then
        self._time.text = TimeUtils.FormatTime(self._momentdata.createtime,4,true)
    elseif self._mShowMode == 1 then
        self._time.text = TimeUtils.FormatTime(self._momentdata.createtime,5,true)
    end
    self._location.text =self._momentdata.location -- self._owerdata:GetLocationAddress()
    self._browse.text = TipsMgr.GetTipByKey("personspace_moment_browse_cnt",0)
    self:InitImageItems(self._momentdataIndex,self._momentdata.photourl)
    self:InitCommentItems(self._momentdataIndex,self._commentsList)
    self:InitLikeItems(self._momentdataIndex,self._momentdata.recentlikers)
    --布局函数
    self:Layout()
end

--UI布局函数
function PS_SpaceItemViewController:Layout()
    local h1=self._imagesControl:GetWidget().height
    local h2= self._commontsControl:GetWidget().height
    local h3= self._likesControl:GetWidget().height
    local baseX =115
    local baseY =-17
    local currentY = baseY
    --正常模式
    if self._mShowMode==2 then
        self._icon.texture.transform.gameObject:SetActive(true)
        self._icon.texture.transform.localPosition =  Vector3(28,-14,0)
        self._name.transform.gameObject:SetActive(true)
        self._name.transform.localPosition = Vector3(baseX,baseY,0)
        self._content.transform.localPosition = Vector3(baseX,-46,0)
        self._server.transform.localPosition = Vector3(270,baseY,0)
        self._sprite.transform.localPosition = Vector3(400,baseY,0)
        self._location.transform.localPosition = Vector3(430,baseY,0)
        self._time.transform.localPosition = Vector3(628,baseY,0)
        self._browse.transform.gameObject:SetActive(false)
        currentY =-38-self._contentUIWidget.height-5
        --图片位置
        self._imagesControl:GetWidget().transform.localPosition = Vector3(baseX,currentY,0)
        currentY =currentY-h1-5
        self._funcBtns.obj.gameObject:SetActive(false)
    elseif self._mShowMode==1 then--单人模式
        self._icon.texture.transform.gameObject:SetActive(false)
        self._name.transform.gameObject:SetActive(false)
        self._time.transform.localPosition = Vector3(28,baseY,0)
        self._content.transform.localPosition = Vector3(baseX,baseY,0)
        currentY =baseY-self._contentUIWidget.height-5
        --图片位置
        self._imagesControl:GetWidget().transform.localPosition = Vector3(baseX,currentY,0)
        self._browse.transform.gameObject:SetActive(true)
        currentY =currentY-h1-5
        self._sprite.transform.localPosition = Vector3(baseX,currentY,0)
        self._location.transform.localPosition = Vector3(baseX+33,currentY,0)
        self._server.transform.localPosition = Vector3(270,currentY,0)
        self._browse.transform.localPosition = Vector3(596,currentY,0)
        currentY =currentY-25
        self._funcBtns.obj.gameObject:SetActive(true)
    end
    self._server.gameObject:SetActive(not self._myMmt)
    --按钮位置
    self._buttonsWidget.transform.localPosition =  Vector3(baseX,currentY,0)
    --文字区域的大小 位置
    currentY =currentY-55
    self._textZone.transform.localPosition = Vector3(90,currentY,0)
     --计算评论的区域大小 位置
    self._commontsControl:GetWidget().transform.localPosition = Vector3(14,-10-h3,0)
    --显示了全部信息
    self._btnCommentMore.transform.gameObject:SetActive(not self._showAll)
    self._btnCommentMore.transform.localPosition = Vector3(314,-15-h3-h2,0)
    self._textZone.height = self._showAll and (h3+h2+20) or (h3+h2+42)
    self._widget.height =math.abs(self._textZone.transform.localPosition.y)+self._textZone.height+5
    --隱藏
    local y = self._buttonsWidget.transform.localPosition.y-25
    self._ReplyView.obj.transform.localPosition = Vector3(1193,y,0)
    self._ReplyView.obj:SetActive(false)
    self._buttonsWidget.transform.gameObject:SetActive(true)
end

function PS_SpaceItemViewController:OnClick(go,id)
    GameLog.Log(id)
    local base =self._index*10000
    local localid = id-base
    --头像
    if localid ==1 then
        UI_Shortcut_Player.ShowPlayerByID(self._momentdata.ownerid)
    --点赞
    elseif localid == 2 then
        if self._liked then
            PersonSpaceMgr.UnLikeMoment(self._mmtid,self._momentdataIndex)
        else
            PersonSpaceMgr.LikeMoment(self._mmtid,self._momentdataIndex)
        end
    --评论
    elseif  localid == 3 then
        self._ReplyView.Input.value = ""
        self:ReplyViewTween(true)
        curReplyIndex= -1*self._index
    --送礼
    elseif  localid == 4 then
    --更多功能
    elseif  localid == 5 then
    --展开
    elseif  localid == 6 then
        self._foldOpen = not self._foldOpen
        if self._foldOpen  then
            self._btnCommentFold.sprite.spriteName="moremsg2"
            self._btnCommentMore.transform.gameObject:SetActive(true)
        else
            self._btnCommentFold.sprite.spriteName="moremsg"
            self._btnCommentMore.transform.gameObject:SetActive(false)
        end
        PersonSpaceMgr.MomentsFoldOpen(self._momentdataIndex,self._foldOpen)
      --  PersonSpaceMgr.UpdateMomentsView()
    --更多
    elseif  localid == 7 then
        PersonSpaceMgr.GetMoreComments(self._mmtid,self._momentdataIndex,self._curcmtcnt)
    elseif  localid == 8 then
        --返回
        self:ReplyViewTween(false)
    elseif  localid == 9 then
        --表情
        self._ReplyView.mChatInputWrap:OnLinkBtnClick()
    elseif  localid == 10 then
        --回復
        local index = curReplyIndex
        if index>0 then
            local dataIndex= self._mCommentItems[index].dataIndex
            local commentData = self._commentsList[dataIndex]
            local cmtid = commentData.cmtid
            local mmtid = commentData.mmtid
            local sendid = commentData.sendid
            local replyid =tostring(sendid)
            --local content =self._ReplyView.mChatInputWrap:GetMsgCommon().content -- self._ReplyView.Input.value
            local content = string.ToBase64(self._ReplyView.mChatInputWrap:GetMsgCommon():SerializeToString())
            PersonSpaceMgr.CommentMomentReply(content,mmtid,replyid,self._momentdataIndex)
            curReplyIndex = 0
        else
            local content = string.ToBase64(self._ReplyView.mChatInputWrap:GetMsgCommon():SerializeToString())
            PersonSpaceMgr.CommentMoment(content,self._mmtid,self._momentdataIndex)
            curReplyIndex = 0
        end
        self:ReplyViewTween(false)
    elseif localid==11 then -- 分享
    elseif localid == 12 then --删除
        PersonSpaceMgr.DeleteMoment(self._mmtid)
    elseif localid == 20 then --点击点赞的人
        self._likesControl:OnClick(go,localid)
    --点击图片
    elseif localid > 1000  and localid<2000 then
        local imgindex=localid-1000
        self._imagesControl:OnClick(go,imgindex)
    --点击评论
    elseif  localid>2000 and localid<3000 then
        self._commontsControl:OnClick(go,localid)
    --点击点赞的人
    elseif  localid>3000 then
        local comindex=localid-3000
        local index = math.floor(comindex/10)
        local eventid = comindex%10
        if eventid ==1 then --icon
        elseif eventid ==2 then --name
        end
        GameLog.Log("点击点赞的人 "..comindex)
    end
end

return PS_SpaceItemViewController