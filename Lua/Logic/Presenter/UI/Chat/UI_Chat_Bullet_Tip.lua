module("UI_Chat_Bullet_Tip", package.seeall);
local MAX_CACHE_DATA = 10;
local MAX_REQUEST_DATA = 5;

local mOpenFlag;
local mMask;
local mSelf;
local mOffsetWidth;

local mThumbRoot;
local mThumbBulletPrefab;
local mThumbThumbPrefab;
local mThumbWrap;
local mThumbPanel;
local mThumbItems = {};
mThumbItems.bulletItems = {};
mThumbItems.thumbItems = {};
local mThumbDatas = {};

local mCommentRoot;
local mCommentBulletPrefab;
local mCommentCommentPrefab;
local mCommentWrap;
local mCommentPanel;
local mCommentItems = {};
mCommentItems.bulletItems = {};
mCommentItems.commentItems = {};
local mCommentDatas = {};

local mOfflineTipFlag = false;
local mLoadingFinish = false;

local function NewThumbItem(isBullet,idx,data,baseIDX)
    if isBullet then
        if not mThumbItems.bulletItems[idx] then
            local item = {};
            item.gameObject = mSelf:DuplicateAndAdd(mThumbBulletPrefab,mThumbWrap.transform,idx).gameObject;
            item.transform = item.gameObject.transform;
            item.content = item.transform:Find("Content"):GetComponent("UILabel");
            item.sendtime = item.transform:Find("Content/SendTime"):GetComponent("UILabel");
            item.gameObject:SetActive(false);
            mThumbItems.bulletItems[idx] = item;
        end
        local bulletItem = mThumbItems.bulletItems[idx];
        bulletItem.content.text = data.sendContent.content;
        bulletItem.sendtime.text = data.sendTime;
        bulletItem.gameObject.name = tostring(baseIDX + idx);
        bulletItem.gameObject:SetActive(true);
    else
        if not mThumbItems.thumbItems[idx] then
            local item = {};
            item.gameObject = mSelf:DuplicateAndAdd(mThumbThumbPrefab,mThumbWrap.transform,idx).gameObject;
            item.transform = item.gameObject.transform;
            item.icon = item.transform:Find("Icon"):GetComponent("UITexture");
            item.name = item.transform:Find("Name"):GetComponent("UILabel");
            item.gameObject:SetActive(false);
            mThumbItems.thumbItems[idx] = item;
        end
        local thumbItem = mThumbItems.thumbItems[idx];
        thumbItem.name.text = data.sender.senderName;
        thumbItem.gameObject.name = tostring(baseIDX + idx);
        thumbItem.gameObject:SetActive(true);
    end
end

local function NewCommentItem(isBullet,idx,data,baseIDX)
    if isBullet then
        if not mCommentItems.bulletItems[idx] then
            local item = {};
            item.gameObject = mSelf:DuplicateAndAdd(mCommentBulletPrefab,mCommentWrap.transform,idx).gameObject;
            item.transform = item.gameObject.transform;
            item.content = item.transform:Find("Content"):GetComponent("UILabel");
            item.sendtime = item.transform:Find("Content/SendTime"):GetComponent("UILabel");
            item.gameObject:SetActive(false);
            mCommentItems.bulletItems[idx] = item;
        end
        local bulletItem = mCommentItems.bulletItems[idx];
        bulletItem.content.text = data.sendContent.content;
        bulletItem.sendtime.text = data.sendTime;
        bulletItem.gameObject.name = tostring(baseIDX + idx);
        bulletItem.gameObject:SetActive(true);
    else
        if not mCommentItems.commentItems[idx] then
            local item = {};
            item.gameObject = mSelf:DuplicateAndAdd(mCommentCommentPrefab,mCommentWrap.transform,idx).gameObject;
            item.transform = item.gameObject.transform;
            item.icon = item.transform:Find("Icon"):GetComponent("UITexture");
            item.name = item.transform:Find("Name"):GetComponent("UILabel");
            item.comment = item.transform:Find("Comment"):GetComponent("UILabel");
            item.bg = item.transform:Find("Bg"):GetComponent("UISprite");
            item.widget = item.gameObject:GetComponent("UIWidget");
            item.gameObject:SetActive(false);
            mCommentItems.commentItems[idx] = item;
        end
        local commentItem = mCommentItems.commentItems[idx];
        local commentData = data.comment or data;
        commentItem.name.text = commentData.sendContent.sender.senderName;
        commentItem.comment.text = string.format("%s%s",TipsMgr.GetTipByKey("bullet_comment"),commentData.sendContent.content);
        commentItem.comment:ProcessText();
        commentItem.bg.height = commentItem.comment.height - 22 + 80;
        commentItem.widget.height = commentItem.bg.height;
        commentItem.gameObject.name = tostring(baseIDX + idx);
        commentItem.gameObject:SetActive(true);
    end
end

local function InitThumb()
    --限制弹出
    if not mThumbDatas.updateFlag then return; end
    local bulletIdx = 1;
    local thumbIdx = 1;
    for bulletID,thumbDatas in pairs(mThumbDatas.allDatas) do
        local bulletData = thumbDatas.bullet;
        NewThumbItem(true,bulletIdx,bulletData,bulletIdx * 1000); 
        for idx,thumbData in ipairs(thumbDatas) do
            NewThumbItem(false,thumbIdx,thumbData,bulletIdx * 1000 + 1); 
            thumbIdx = thumbIdx + 1;
        end
        bulletIdx = bulletIdx + 1;
    end
    for i = bulletIdx,#mThumbItems.bulletItems do
        mThumbItems.bulletItems[i].gameObject:SetActive(false);
    end
    for i = thumbIdx,#mThumbItems.thumbItems do
        mThumbItems.thumbItems[i].gameObject:SetActive(false);
    end
    mThumbRoot:SetActive(true);
    mMask:SetActive(true);
    mThumbWrap:Reposition();
    mThumbPanel:ResetPosition();
end

local function InitComment()
    --限制弹出
    if not mCommentDatas.updateFlag then return; end
    local bulletIdx = 1;
    local commentIdx = 1;
    for bulletID,commentDatas in pairs(mCommentDatas.allDatas) do
        local bulletData = commentDatas.bullet;
        NewCommentItem(true,bulletIdx,bulletData,bulletIdx * 1000);
        for idx,commentData in ipairs(commentDatas) do
            NewCommentItem(false,commentIdx,commentData,bulletIdx * 1000 + 1);
            commentIdx = commentIdx + 1;
        end
        bulletIdx = bulletIdx + 1;
    end
    for i = bulletIdx,#mCommentItems.bulletItems do
        mCommentItems.bulletItems[i].gameObject:SetActive(false);
    end
    for i = commentIdx,#mCommentItems.commentItems do
        mCommentItems.commentItems[i].gameObject:SetActive(false);
    end
    mCommentRoot:SetActive(true);
    mMask:SetActive(true);
    mCommentWrap:Reposition();
    mCommentPanel:ResetPosition();
end

function InitPosition()
    local activeAll = mThumbRoot.activeSelf and mCommentRoot.activeSelf;
    if activeAll then
        mThumbRoot.transform.localPosition = Vector3.New(-mOffsetWidth,0,0);
        mCommentRoot.transform.localPosition = Vector3.New(mOffsetWidth,0,0);  
    else
        mThumbRoot.transform.localPosition = Vector3.zero;
        mCommentRoot.transform.localPosition = Vector3.zero;
    end
end

local function SortByTime(a,b) 
    if a == b then return false end  
    if a.updateFlag ~= b.updateFlag then return b.updateFlag end
    if a.updateTime ~= b.updateTime then return a.updateTime > b.updateTime end
    return a.bulletID > b.bulletID;
end

function OnCreate(self)
    mMask = self:Find("Offset/Mask").gameObject;
    mSelf = self;
    mOffsetWidth = self:FindComponent("UITexture","Offset/Thumb/Bg").width / 2.0;

    mThumbRoot = self:Find("Offset/Thumb").gameObject;
    mThumbBulletPrefab = self:Find("Offset/Thumb/DragParent/ScrollView/Wrap/BulletPrefab");
    mThumbThumbPrefab = self:Find("Offset/Thumb/DragParent/ScrollView/Wrap/ThumbPrefab");
    mThumbWrap = self:FindComponent("UITable","Offset/Thumb/DragParent/ScrollView/Wrap");
    mThumbPanel = self:FindComponent("UIScrollView","Offset/Thumb/DragParent/ScrollView");
    mThumbThumbPrefab.gameObject:SetActive(false);
    mThumbBulletPrefab.gameObject:SetActive(false);
    mThumbRoot:SetActive(false);

    mCommentRoot = self:Find("Offset/Comment").gameObject;
    mCommentBulletPrefab = self:Find("Offset/Comment/DragParent/ScrollView/Wrap/BulletPrefab");
    mCommentCommentPrefab = self:Find("Offset/Comment/DragParent/ScrollView/Wrap/ThumbPrefab");
    mCommentWrap = self:FindComponent("UITable","Offset/Comment/DragParent/ScrollView/Wrap");
    mCommentPanel = self:FindComponent("UIScrollView","Offset/Comment/DragParent/ScrollView");
    mCommentCommentPrefab.gameObject:SetActive(false);
    mCommentBulletPrefab.gameObject:SetActive(false);
    mCommentRoot:SetActive(false);
    ChatMgr.RegListener(Chat_pb.CHATMSG_BULLET_THUMBUP_TRANSMIT,OnReceiveMsg);
    ChatMgr.RegListener(Chat_pb.CHATMSG_BULLET_COMMENT_TRANSMIT,OnReceiveMsg);

    GameEvent.Reg(EVT.CHAT,EVT.CHAT_OFFLINE_MSG,OnReceiveOfflineMsg);
end

function OnEnable(self)
    InitComment();
    InitThumb();
    InitPosition();
end

function OnDisbale(self)
    mOpenFlag = false;
end

function OnClick(go,id)
    if id == 0 then
        mThumbRoot:SetActive(false);
        mCommentRoot:SetActive(false);
        mMask:SetActive(false);
    end
end

function OnNewData(targetDatas,bulletTipData,isComment)
    if not bulletTipData then return end
    targetDatas.updateFlag = true;
    targetDatas.allDatas = targetDatas.allDatas or {};
    --遍历查找是否已经接收过该弹幕的消息
    local datas = nil;
    for i = 1,#targetDatas.allDatas do
        if targetDatas.allDatas[i].bulletID == (bulletTipData.bulletID or bulletTipData.bullet.bulletID) then
            datas = targetDatas.allDatas[i];
            break;
        end
    end
    --没有接收过,插入新的弹幕
    if datas == nil then
        datas = {};
        datas.bullet = bulletTipData.bullet;
        datas.bulletID = bulletTipData.bullet.bulletID;
        datas.bulletSendTime = bulletTipData.bullet.sendTime;
        datas.sendTime = bulletTipData.sendTime or bulletTipData.comment.sendTime;
        table.insert(targetDatas.allDatas,datas);
        if isComment then 
            local bulletData = BulletData.GetBulletDataByName(bulletTipData.comment.bulletName);
            if bulletData then
                ChatMgr.RequestGetComment(bulletData.bulletID,datas.bulletID,0,MAX_REQUEST_DATA);
                return;
            end
        end
    end

    --修改弹幕信息
    datas.updateTime = GameTime.realtime_L;
    datas.updateFlag = true;

    --新增该弹幕的信息
    table.insert(datas,1,bulletTipData);
    if #datas > MAX_CACHE_DATA then table.remove(datas); end

    --信息排序
    table.sort(targetDatas.allDatas,SortByTime);
end

function OnNewComment(bulletTipData,waitShow)
    --刷新弹幕评论信息
    OnNewData(mCommentDatas,bulletTipData,true);
    if (mOpenFlag and mOffsetWidth and not waitShow) then InitComment(); InitPosition(); end
end

function OnNewThumb(bulletTipData,waitShow)
    --刷新弹幕点赞信息 
    OnNewData(mThumbDatas,bulletTipData,false);
    if (mOpenFlag and mOffsetWidth and not waitShow) then InitThumb(); InitPosition(); end
end

function OnLoadingFinish()
    mLoadingFinish = true;
    if not mOfflineTipFlag then
        --ChatMgr.RequestGetPlayerOfflineMessage();
    end
end

function OnReceiveOfflineMsg()
    if mLoadingFinish then
        mOfflineTipFlag = true;
        local msgType = Chat_pb.CHATMSG_BULLET_THUMBUP_TRANSMIT;
        local msgDatas = ChatMgr.GetOfflineMsg(msgType);
        for idx,realMsg in ipairs(msgDatas) do
            OnReceiveMsg(realMsg,msgType);
        end
        
        msgType = Chat_pb.CHATMSG_BULLET_COMMENT_TRANSMIT;
        msgDatas = ChatMgr.GetOfflineMsg(msgType);
        for idx,realMsg in ipairs(msgDatas) do
            OnReceiveMsg(realMsg,msgType);
        end
    end
end

function OnGetComment(bulletID,comments)
    for i = #comments,1,-1 do
        OnNewComment(comments[i], i ~= 1);
    end
end

function OnReceiveMsg(bulletTipData,msgType)
    if msgType == Chat_pb.CHATMSG_BULLET_THUMBUP_TRANSMIT or msgType == Chat_pb.CHATMSG_BULLET_COMMENT_TRANSMIT then
        if bulletTipData.bullet.sendContent.sender.senderID ~= tostring(UserData.PlayerID) then return end
        if msgType == Chat_pb.CHATMSG_BULLET_COMMENT_TRANSMIT then
            --弹幕新增评论
            OnNewComment(bulletTipData);
        else
            --弹幕新增点赞
            OnNewThumb(bulletTipData);
        end
        if not mOpenFlag then 
            --首次打开提示
            mOpenFlag = true; 
            UIMgr.ShowUI(AllUI.UI_Chat_Bullet_Tip); 
        end
    end
end


MessageSub.Register(GameConfig.SUB_G_CHAT,GameConfig.SUB_U_CHAT_OFFLINE_MSG,OnReceiveOfflineMsg);
MessageSub.Register(GameConfig.SUB_G_CHAT,GameConfig.SUB_U_CHAT_BULLET_GET_COMMENT,OnGetComment);
--GameEvent.Reg(EVT.COMMON,GameConfig.SUB_U_LOADING_FINISH_FIRST_ENTER_SCENE,OnLoadingFinish);