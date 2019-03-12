module("UI_Chat_Bullet", package.seeall);
local mSelf;
local mBulletData;
--默认创建多少ITEM
local MAX_ITEM_COUNT = 50;
--屏幕宽度
local HALF_SCREEN_WIDTH = 667;
local WIDTH_DELTA = 30;
--热词事件偏移ID
local BASE_HOTWORD_EVENT_ID = 2000;
--点赞按钮事件偏移ID
local BASE_THUMPUP_EVENT_ID = 3000;
--最大宽度
local MAX_LINE_WIDTH = 2000;

local ICONWIDTH = 36 --头像宽度
local THUMBUPBTNOFFSET = 20 -- 点赞按钮偏移

local WIDTHOFFSET = 200 -- 头像 点赞 按钮 距离

local mInputHeigh = 45

local mLineItemIndex
local mBulletAddMsgData

--房间 剧情 开关 弹幕相关信息
local mRoomID = nil;
local mBulletName = nil;
local mBulletSwitch = false;
local mBulletDataCount = 0;
local mBulletDatas = {};
local mBulletItems = {};
local mBulletLines = {};
local mBulletTime = 0;
local mBulletLimitTime = 0;
local mBulletPrefab;

local mSwitchObj;
local mSwitchToggle;
local mSendObj;
local mInputTrs;
local mMaskObj;
local mInput;
local mInputSubmitCallBack;
local mInputData;
local mBulletRoot;
local mBulletRootPanel;

local mThumbUpTrans;

local mInputText;

local mBulletSelectItem = nil;

local mHotBulletParent;
local mHotBulletPanel;
local mHotBulletWrap;
local mHotBulletPrefab;
local mHotBulletDir;
local mHotBulletItems = {}
local mHotBulletDatas = {}

local mOldTipLayer;
local mOldTipDepth;
local mEvent = {};

local mPauseFunc;
local mContinueFunc;

function OnCreate(self)
    mSelf = self;
    mSwitchToggle = self:FindComponent("UIToggle","Offset/Switch");
    mSendObj = self:Find("Offset/SendBtn").gameObject;
    mInputTrs = self:Find("Offset/Input");
    mMaskObj = self:Find("Mask").gameObject;
    mBulletRoot = self:Find("Offset/BulletRoot");
    mBulletRootPanel = mBulletRoot:GetComponent("UIPanel");
    mBulletPrefab = self:Find("Offset/Prefab/LinePrefab");
    mBulletPrefab.gameObject:SetActive(false);
    local selfTrans = self:Find("Offset/Prefab/LinePrefab/Self");
    selfTrans.localPosition = Vector3.New(- WIDTH_DELTA / 2,0,0);

    --触摸后不做处理
    mHotBulletPrefab = self:Find("Offset/HotWord/DragParent/ScrollView/Wrap/HotItem");
    mHotBulletPanel = self:FindComponent("UIPanel","Offset/HotWord/DragParent/ScrollView");
    mHotBulletWrap = self:FindComponent("UITable","Offset/HotWord/DragParent/ScrollView/Wrap");
    mHotBulletParent = self:Find("Offset/HotWord/DragParent").gameObject;
    mHotBulletDir = self:FindComponent("UISprite","Offset/HotWord/Dir");
    mHotBulletPrefab.gameObject:SetActive(false);

    mInputText = self:Find("Offset/Input/Lb"):GetComponent("UILabel")

    mInput = self:FindComponent("LuaUIInput","Offset/Input");
    mInputSubmitCallBack = EventDelegate.Callback(OnBulletSubmit);
    EventDelegate.Set(mInput.onSubmit,mInputSubmitCallBack);
    mMaskObj:SetActive(false);

    local pixelSizeAdjustment = UIMgr.GetUIRoot().pixelSizeAdjustment
    HALF_SCREEN_WIDTH = SystemInfo:ScreenWidth() * pixelSizeAdjustment / 2

    ChatMgr.RegListener(Chat_pb.CHATMSG_BULLET_THUMBUP_TRANSMIT, OnThumbupCallback);
    ChatMgr.RegListener(Chat_pb.CHATMSG_BULLET_COMMENT_TRANSMIT, OnCommentCallback);
end

function InitInputData()
    mInputData = TextChatData.new();
    mInputData:SetInput(mInput,limitKey);
    EventDelegate.Set(mInput.onSelect,EventDelegate.Callback(OnBulletPause));
end

function InitHotWordList()
    mHotBulletDatas = {};
    if mBulletData and #mBulletData.bulletHotWords > 0 then
        for i = 1,#mBulletData.bulletHotWords do
            local words = WordData.GetWordDatasByKey(mBulletData.bulletHotWords[i]);
            for j = 1,#words do
                table.insert(mHotBulletDatas,words[j]);
            end
        end
    end
    for i = #mHotBulletItems + 1,#mHotBulletDatas do
        local data = mHotBulletDatas[i];
        local item = {};
        item.gameObject = mSelf:DuplicateAndAdd(mHotBulletPrefab.transform,mHotBulletWrap.transform,i).gameObject;
        item.transform = item.gameObject.transform;
        item.event = item.gameObject:GetComponent("GameCore.UIEvent");
        item.event.id = BASE_HOTWORD_EVENT_ID + i;
        item.value = item.transform:Find("Value"):GetComponent("UILabel");
        item.value.text = data;
        item.data = data;
        item.gameObject:SetActive(true);
        mHotBulletItems[i] = item;  
    end
    mHotBulletWrap:Reposition();
end

function InitHotWord(open)
	mHotBulletDir.flip = open and UIBasicSprite.Flip.Horizontally or UIBasicSprite.Flip.Nothing;
    mHotBulletParent:SetActive(open);
    if open then
        OnBulletPause()
    else
        OnBulletContinue()
    end
end

function InitBulletItemPrefab(self)
    --创建弹幕预设
    for i = #mBulletItems + 1,MAX_ITEM_COUNT do
        local item = {};
        item.gameObject = self:DuplicateAndAdd(mBulletPrefab.transform,mBulletRoot,i).gameObject;
        item.transform = item.gameObject.transform;
        item.widget = item.gameObject:GetComponent("UIWidget");
        item.root = item.transform:Find("Root").transform;
        item.event = item.transform:Find("Root/content").gameObject:GetComponent("GameCore.UIEvent");
        item.event.id = BASE_THUMPUP_EVENT_ID + i;
        item.self = item.transform:Find("Self"):GetComponent("UISprite");
        item.icon = item.transform:Find("Self/Texture"):GetComponent("UITexture")
        item.content = item.transform:Find("Root/content"):GetComponent("UILabel")

        item.thumbUpBtn = item.transform:Find("Root/ThumbUpBtn")
        item.thumbUpNum = item.transform:Find("Root/ThumbUpBtn/ThumbUpNum"):GetComponent("UILabel")
        item.btnEvent = item.transform:Find("Root/ThumbUpBtn").gameObject:GetComponent("GameCore.UIEvent");
        item.btnEvent.id = BASE_THUMPUP_EVENT_ID + i

        item.gameObject:SetActive(false);
        item.curWidth = 0;
        mBulletItems[i] = item;      
    end
end

function InitBulletState()
    local enable = ChatMgr.IsBulletEnabled();
    mSwitchToggle:Set(enable,true);
    if enable then
        mBulletRootPanel.alpha = 1;
    else
        mBulletRootPanel.alpha = 0;
    end
end

function InitBulletItemState()
    --初始化弹幕预设状态
    for k,v in ipairs(mBulletItems) do
        v.flying = false;
        if not v.finish_func then
            v.finish_func = EventDelegate.Callback(OnTweenFinish,v);
        end
        if not v.tween then
            v.tween = v.gameObject:AddComponent(typeof(TweenPosition));
            v.tween.ignoreTimeScale = false;
            EventDelegate.Set(v.tween.onFinished,v.finish_func);
        end
        v.tween.enabled = false;
        v.transform.localPosition = Vector3.New(HALF_SCREEN_WIDTH,0,0);
    end
    mBulletSelectItem = nil;
end

function InitBulletLine()
    --初始化弹幕飞行轨道
    
    local pixelSizeAdjustment = UIMgr.GetUIRoot().pixelSizeAdjustment
    local halfHeight = SystemInfo:ScreenHeight() * pixelSizeAdjustment / 2

    local deltaHeight = mBulletData.bulletHeight; --每一行的高度
    local maxLine = math.floor(halfHeight * mBulletData.bulletAspect / deltaHeight);

    local y = mInputTrs.localPosition.y - deltaHeight / 2 - mInputHeigh / 2

    for i = 1,maxLine do
        local lineInfo = {};
        lineInfo.pos = y - deltaHeight * (i - 1)
        lineInfo.lastID = -1;
        mBulletLines[i] = lineInfo;
    end
end

function InitBulletData()
    mBulletData = BulletData.GetBulletDataByName(mBulletName);
end

function OnEnable(self)
    
    UpdateBeat:Add(OnUpdate,self);
    InitBulletData();
    InitInputData();
    InitHotWordList();
    InitHotWord(false);
    InitBulletItemPrefab(self);
    InitBulletState(self);
    InitBulletItemState(self);
    InitBulletLine(self);

    --弹幕房间进入退出、弹幕列表、新增弹幕
    GameEvent.Reg(EVT.BULLET, EVT.BULLET_ONJOINROOM, OnJoinRoom)
    GameEvent.Reg(EVT.BULLET, EVT.BULLET_ONGETBULLET, OnGetBullets)
    GameEvent.Reg(EVT.BULLET, EVT.BULLET_ONTHUMBUP, OnThumbup)
    ChatMgr.RegListener(Chat_pb.CHATMSG_BULLET_ADD,OnReceiveMsg);
    TouchMgr.SetListenOnNGUIEvent(UI_Chat_Bullet,true);

    mOldTipLayer = AllUI.UI_Tips.layer;
    mOldTipDepth = AllUI.UI_Tips.depth;

    mInputText.text = WordData.GetWordStringByKey("bullet_input_word")
end

function OnDisable(self)
    UpdateBeat:Remove(OnUpdate,self);
    GameEvent.UnReg(EVT.BULLET, EVT.BULLET_ONJOINROOM, OnJoinRoom)
    GameEvent.UnReg(EVT.BULLET, EVT.BULLET_ONGETBULLET, OnGetBullets)
    ChatMgr.UnRegListener(Chat_pb.CHATMSG_BULLET_ADD,OnReceiveMsg);
    TouchMgr.SetListenOnNGUIEvent(UI_Chat_Bullet,false);
end

function OnTweenFinish(item)
    item.flying = false;
    item.tween.enabled = false;
    local bulletLine = mBulletLines[item.lineIndex];
    if bulletLine.lastID == item.itemIndex then
        bulletLine.lastID = -1;
        bulletLine.speed = 0;
    end
end

function SetBullet(lineItemIndex, bulletAddMsgData)
    local item = mBulletItems[lineItemIndex]
    local arg = item.arg or {};
    item.arg = arg
    arg.isSelfMsg = bulletAddMsgData.sendContent.sender.senderID == tostring(UserData.PlayerID);
    arg.itemData = bulletAddMsgData;
    item.content.text = arg.itemData.sendContent.content

    local bulletData = BulletData.GetBulletDataByName(bulletAddMsgData.bulletName);
    if bulletData then
        arg.contentColor = arg.isSelfMsg and bulletData.bulletStartSelfColor or bulletData.bulletStartOtherColor
    else
        arg.contentColor = "[FFFFFF]"
    end
    item.content.text = arg.contentColor .. item.content.text

    local wOffset = 0

    item.gameObject:SetActive(true)
    item.self.gameObject:SetActive(arg.isSelfMsg);
    
    item.self.height = item.content.height + 20;
    item.self.transform.localPosition = Vector3.zero
    item.tween.to = Vector3.New(-HALF_SCREEN_WIDTH - item.content.width,item.tween.to.y,0)

    local upStr =  ""
    if bulletAddMsgData.thumbUpCount > 0 then
        item.thumbUpNum.gameObject:SetActive(true)
        item.thumbUpNum.text = bulletAddMsgData.thumbUpCount
        upStr = "911"
        wOffset = 80
    else
        item.thumbUpNum.gameObject:SetActive(false)
        upStr = "912"
        wOffset = ICONWIDTH
    end

    item.self.width = item.content.width + wOffset + 10

    item.thumbUpBtn:GetComponent("UISprite").spriteName = upStr
    item.thumbUpBtn.localPosition = Vector3(item.content.width + THUMBUPBTNOFFSET, 0, 0)

    if arg.isSelfMsg then
        item.self.width = ICONWIDTH + item.self.width
        item.root.localPosition = Vector3.New(ICONWIDTH, 0, 0)
        item.thumbUpBtn.localPosition = Vector3(item.content.width + THUMBUPBTNOFFSET, 0, 0)
    end

    local player = SocialPlayerMgr.GetSelf()
    player:SetHeadIcon(item.icon)
end

function OnThumbup()

    local item = mBulletItems[mLineItemIndex];
    if mBulletAddMsgData.thumbUpCount > 0 then
        item.thumbUpNum.gameObject:SetActive(true)
        item.thumbUpNum.text = mBulletAddMsgData.thumbUpCount
        item.thumbUpBtn:GetComponent("UISprite").spriteName = "911"
    end
    
end

function OnNewItem(self,bulletAddMsgData)
    --找一个空闲的ITEM
    local lineItem = nil;
    local lineItemIndex = nil;
    for k,v in ipairs(mBulletItems) do
        if not v.flying then
            lineItem = v;
            lineItemIndex = k;
            break;
        end
    end
    if not lineItem then return -1 end
    --根据规则找一个可插入数据的行
    local lineInfo = nil;
    local lineInfoIndex = nil;
    for k,v in ipairs(mBulletLines) do
        local vItem = mBulletItems[v.lastID];
        if vItem and vItem.flying then
            v.space = HALF_SCREEN_WIDTH - (vItem.transform.localPosition.x - vItem.content.width);
            if v.space >= mBulletData.bulletMaxSpace then
                if not lineInfo or lineInfo.space < v.space then
                    lineInfo = v;
                    lineInfoIndex = k;
                end
            end
        else
            lineInfo = v;
            lineInfoIndex = k;
            break;
        end
    end
    if not lineInfo then return -2 end
    --随机一个速度
    lineInfo.lastID = lineItemIndex;
    lineInfo.speed = math.random(mBulletData.bulletMinSpeed,mBulletData.bulletMaxSpeed);
    lineItem.flying = true;
    lineItem.lineIndex = lineInfoIndex;
    lineItem.itemIndex = lineItemIndex;
    SetBullet(lineItemIndex,bulletAddMsgData);
    lineItem.transform.localPosition = Vector3.New(HALF_SCREEN_WIDTH,lineInfo.pos,0);
    --计算目标点
    local to = Vector3.New(-HALF_SCREEN_WIDTH-lineItem.content.width-WIDTHOFFSET,lineInfo.pos,0);
    TweenPosition.Begin(lineItem.gameObject,math.abs(to.x) / lineInfo.speed,to);
    lineItem.tween.enabled = true;
    return 0;
end

function OnUpdate(self)
    if mBulletSwitch then
        mBulletTime = mBulletTime + GameTime.deltaTime_L;
        mBulletLimitTime = mBulletLimitTime + GameTime.deltaTime_L;
        if mBulletLimitTime >= mBulletData.bulletLimitTime then
            mBulletLimitTime = 0;
            local group = math.ceil(mBulletTime / mBulletData.bulletGroupMs);
            local groupData = mBulletDatas[group] or {};
            for i = 1,#groupData do
                local ret = OnNewItem(self,groupData[1]);
                if ret >= 0 then
                    table.remove(groupData,1);
                else
                    break;
                end
            end
        end
    end
end

function OnNewBullet(bulletAddMsgData)
    local group = math.ceil(bulletAddMsgData.playTime / mBulletData.bulletGroupMs);
    if not mBulletDatas[group] then
        mBulletDatas[group] = {};
    end
    if tonumber(bulletAddMsgData.sendContent.sender.senderID) == tonumber(UserData.PlayerID) then
        table.insert(mBulletDatas[group], 1, bulletAddMsgData);
    else
        table.insert(mBulletDatas[group],bulletAddMsgData);
    end
end

function OnBulletSubmit()
    --OnClick(nil,0);
end

function OnClick(go,id)
    if id == -1 then
        --关闭
        GameEvent.Trigger(EVT.STORY,EVT.BULLET_FINISH,mBulletData.bulletID);
    elseif id == 0 then
        --发送
        ChatMgr.RequestSendBullet(mRoomID, mBulletName, mInput.value, mBulletTime);
        mInput.value = ""
        OnBulletContinue()
    elseif id == 1 then
        --开关
        local active = ChatMgr.IsBulletEnabled();
        ChatMgr.SetBulletEnabled(not active);
        if not active then
            mBulletRootPanel.alpha = 1;
        else
            mBulletRootPanel.alpha = 0;
        end
    elseif id == 2 then
        --热词
        InitHotWord(not mHotBulletParent.activeSelf);
    elseif id > BASE_HOTWORD_EVENT_ID and id < BASE_THUMPUP_EVENT_ID then
        local hotIndex = id - BASE_HOTWORD_EVENT_ID;
        local hotItem = mHotBulletItems[hotIndex];
        if hotItem then
            InitHotWord(false);
            mInput.value = hotItem.data;
            OnBulletPause()
        end
    elseif id > BASE_THUMPUP_EVENT_ID then
        --点赞
        local bulletIndex = id - BASE_THUMPUP_EVENT_ID;
        local bulletItem = mBulletItems[bulletIndex];
        if bulletItem and bulletItem.arg.itemData.sendContent.sender.senderID == tostring(UserData.PlayerID) then --自己不能给自己点赞
            return 
        end
        if bulletItem and not bulletItem.arg.itemData.bulletThumbFlag then
            bulletItem.arg.itemData.bulletThumbFlag = true;
            mLineItemIndex = bulletItem.itemIndex
            mBulletAddMsgData = bulletItem.arg.itemData
            ChatMgr.RequestAddThumbUp(mRoomID,bulletItem.arg.itemData);
        else
            TipsMgr.TipByKey("bullet_thumup_repeat");
        end

    end
end

function OnPressScreen()
    if not mBulletSelectItem then return; end
    local hoveredObject = UICamera.hoveredObject;
    if hoveredObject == mBulletSelectItem.gameObject then return; end
end

--弹幕开始
function OnBulletBegin(bulletID,pauseFunc,continueFunc) 
    mBulletData = BulletData.GetBulletDataByID(bulletID);
    if mBulletData and mBulletData.bulletName then
        mBulletName = mBulletData.bulletName;
        mBulletSwitch = false;
        mBulletTime = 0;
        mBulletLimitTime = 0;
        mBulletDataCount = 0;
        mPauseFunc = pauseFunc;
        mContinueFunc = continueFunc;
        UIMgr.ShowUI(AllUI.UI_Chat_Bullet,nil,function() ChatMgr.RequestJoinRoom(mBulletData.bulletName,true); end);  
    end
end

function OnBulletPause()
    for i = 1,#mBulletItems do
        if mBulletItems[i].flying then
            mBulletItems[i].tween.enabled = false;
        end
    end
    mBulletSwitch = false;
    if mPauseFunc then mPauseFunc() end
end

function OnBulletContinue()
    for i = 1,#mBulletItems do
        if mBulletItems[i].flying then
            mBulletItems[i].tween.enabled = true;
        end
    end
    mBulletSwitch = true;
    if mContinueFunc then mContinueFunc() end
end

--弹幕结束
function OnBulletFinish(bulletID)
    local bulletData = BulletData.GetBulletDataByID(bulletID);
    if mBulletData and bulletData.bulletName == mBulletName then
        mBulletDatas = {};  
        mBulletData = nil;    
        UIMgr.UnShowUI(AllUI.UI_Chat_Bullet);
        ChatMgr.RequestJoinRoom(mBulletName,false);
    end
end

--进入弹幕房间
function OnJoinRoom(roomID)
    mRoomID = roomID;
    ChatMgr.RequestGetBullet(mRoomID,0,mBulletData.bulletPerRequest);
end

--弹幕历史记录
function OnGetBullets(bulletAddMsgDatas)
    mBulletDataCount = mBulletDataCount + #bulletAddMsgDatas;
    for i = 1,#bulletAddMsgDatas do
        OnNewBullet(bulletAddMsgDatas[i]);
    end
    if #bulletAddMsgDatas >= mBulletData.bulletPerRequest then
        ChatMgr.RequestGetBullet(mRoomID,mBulletDataCount,mBulletData.bulletPerRequest);
    else
        mBulletSwitch = true;
    end
end

--收到弹幕消息
function OnReceiveMsg(bulletAddMsgData,msgType)
    if msgType == Chat_pb.CHATMSG_BULLET_ADD then
        OnNewBullet(bulletAddMsgData);
    end
end

function OnThumbupCallback()
    
end

function OnCommentCallback()
    
end

function OnStoryEnter(storyData)
    if storyData then
        OnBulletBegin(storyData.bulletID,SequenceMgr.Pause,SequenceMgr.Resume);
    end
end

function OnStoryLeave(storyData)
    if storyData then
        OnBulletFinish(storyData.bulletID);
    end
end

--弹幕开始和结束
GameEvent.Reg(EVT.STORY,EVT.BULLET_ENTER,OnBulletBegin);
GameEvent.Reg(EVT.STORY,EVT.BULLET_FINISH,OnBulletFinish);

--剧情开始和结束
GameEvent.Reg(EVT.STORY,EVT.STORY_ENTER,OnStoryEnter);
GameEvent.Reg(EVT.STORY,EVT.STORY_FINISH,OnStoryLeave);