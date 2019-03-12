module("UI_PersonalSpace_EditorMsg",package.seeall)

local ChatInputWrap = require("Logic/Presenter/UI/Chat/ChatInputWrap")
--当前数据
local mImageData = {}

--当前数据
local mSeeData = {"广场","好友","私密"}

--当前数据
local mTopicData = {"#说出你的成长故事#","#哈哈哈#","#滴滴监管#"}

--滚动消息
local mScrollPanel =nil
local mScrollView  =nil
--输入框
local mMsgInput =nil
local mMsgLabel =nil
--图片
local mImageTable =nil
local mImagePrefab =nil
local mImageWidgetTable =nil
--可见
local mSeeTable =nil
local mSeePrefab  =nil
local mSeeTableWidget =nil
-- 话题
local mTopicTable =nil
local mTopicPrefab =nil
local mTopicTableWidget = nil
--定位选中标识
local mLocationSelect =nil
local mLocation = nil
--最大的消息显示高度 SCrollow的最大高度
local MAX_MSG_HEIGHT = 100
--照片最大数量
local MAX_IMAGE_NUM = 9
--可见最大数
local MAX_SEE_NUM = 10
--话题最大数
local MAX_TOPIC_NUM = 10
--照片的实体列表
local mImageGrids ={}
--可见性的实体列表
local mSeeGrids ={}
--话题的实体列表
local mTopicGrids ={}
--选中的照片
local mSelectImage = {}
--选中的可见性
local mSelectSee = {}
--选中的话题
local mSelectTopic = {}
--定位是否开启
local isLocationOn = false
--发送按钮
local mSend = nil
--文字开始的y坐标
local mOrignalPos =nil
--话题滚动
local mTopicScrollView =nil
local mTopicScrollViewPanel=nil
local mTopicScrollViewPos=nil

local mMsgInputWrap = nil
local mAddress=nil
local _self = nil

function OnCreate(self)
    _self= self
    --消息滚动
	mScrollPanel= self:FindComponent("UIPanel", "Offset/ScrollView");
    mScrollView = self:FindComponent("UIScrollView", "Offset/ScrollView");
    mOrignalPos=mScrollPanel.transform.localPosition

    mTopicScrollViewPanel= self:FindComponent("UIPanel", "Offset/TopicScrollView");
    mTopicScrollView = self:FindComponent("UIScrollView", "Offset/TopicScrollView");
    mTopicScrollViewPos=mTopicScrollViewPanel.transform.localPosition

    --输入框
    mMsgInput = self:FindComponent("LuaUIInput", "Offset/ScrollView/Input");
    mMsgLabel = self:FindComponent("UILabel", "Offset/ScrollView/Input/Label");
    mMsgInput.defaultText="此刻的想法..."
    mMsgInputWrap = ChatInputWrap.new(mMsgInput, ChatMgr.CommonLinkOpenType.FromPersonSpace)
    mMsgInputWrap:ResetMsgCommon()
    mMsgInputWrap:ResetLimitCount(1000)
    mMsgInputWrap:ResetRoomType(Chat_pb.CHAT_ROOM_WORLD)
    
    local changeCall = EventDelegate.Callback(OnMsgChange);
    EventDelegate.Add(mMsgInput.onChange,changeCall);
    --图片
    mImageTable = self:FindComponent("UITable", "Offset/ImageTable");
    mImageTableWidget = self:FindComponent("UIWidget", "Offset/ImageTable");
    mImagePrefab = self:Find("Offset/ImageTable/Add");
    mImagePrefab.gameObject:SetActive(false)
    --可见
    mSeeTable = self:FindComponent("UITable", "Offset/SeeTags");
    mSeeTableWidget = self:FindComponent("UIWidget", "Offset/SeeTags");
    mImagePrefab = self:Find("Offset/ImageTable/Add");
    mSeePrefab = self:Find("Offset/SeeTags/ItemPrefab");
    mSeePrefab.gameObject:SetActive(false)
    -- 话题
    mTopicTable = self:FindComponent("UITable", "Offset/TopicScrollView/TopicTags");
    mTopicTableWidget = self:FindComponent("UIWidget", "Offset/TopicScrollView/TopicTags");

    mImagePrefab = self:Find("Offset/ImageTable/Add");
    mTopicPrefab = self:Find("Offset/TopicScrollView/TopicTags/ItemPrefab");
    mTopicPrefab.gameObject:SetActive(false)

    mLocation =  self:FindComponent("UISprite", "Offset/Location");
    mLocationSelect =  self:Find("Offset/Location/Select");
    mSend=  self:FindComponent("UISprite", "Offset/Send");
    mAddress =  self:FindComponent("UILabel", "Offset/Location/Address");

    local mLocationEvent = self:FindComponent("UIEvent", "Offset/Location");
	mLocationEvent.id = -1
    local mSendEvent = self:FindComponent("UIEvent", "Offset/Send");
	mSendEvent.id = -2
    local mCloseEvent = self:FindComponent("UIEvent", "Offset/Close");
    mCloseEvent.id = -3 

end

--新的图片
function NewImage(obj, index)
	local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(obj, mImageTable.transform, index).gameObject;
	item.gameObject.name = tostring(10000 + index);
	item.transform = item.gameObject.transform;
	item.texture = item.transform:GetComponent("UITexture");
    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.uiEvent.id = 10000 + index
	item.gameObject:SetActive(false);
	return item;
end

--新的可见
function NewSeeTag(obj, index)
	local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(obj, mSeeTable.transform, index).gameObject;
	item.gameObject.name = tostring(20000 + index);
	item.transform = item.gameObject.transform;
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
	item.itemlabel = item.transform:Find("ItemLabel"):GetComponent("UILabel");
	item.itemselect = item.transform:Find("ItemSelect").gameObject;
    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.uiEvent.id = 20000 + index
	item.gameObject:SetActive(false);
	return item;
end

--新的话题
function NewTopicTag(obj, index)
	local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(obj, mTopicTable.transform, index).gameObject;
	item.gameObject.name = tostring(30000 + index);
	item.transform = item.gameObject.transform;
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
	item.itemlabel = item.transform:Find("ItemLabel"):GetComponent("UILabel");
    item.itemselect = item.transform:Find("ItemSelect").gameObject;
    item.widget = item.transform:GetComponent("UIWidget");
    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.uiEvent.id = 30000 + index
	item.gameObject:SetActive(false);
	return item;
end

local mEvents = {};
function RegEvent(self)
end

function UnRegEvent(self)
  	mEvents = {};
end

function OnEnable(self)
    RegEvent(self);
    mImageData={}
    isLocationOn = false
	UpdateView()
end

function OnDisable(self)
	UnRegEvent(self);
end

--消息改编
function OnMsgChange()
   -- local content = string.ToBase64(self._ReplyView.mChatInputWrap:GetMsgCommon():SerializeToString())
    mMsgInput.value = mMsgInputWrap:GetMsgCommon().content
    UpdateMsgInput()
    UpdateLayout()
end

--添加玩家链接
function AddPlayerLink(name,palyerid)
    local msgLink = Chat_pb.ChatMsgLink()
    msgLink.linkType = Chat_pb.ChatMsgLink.ITEM
    msgLink.isValid = true
    msgLink.content = string.format("@%s",name)
    msgLink.linkDesc.textDesc.color = "[0000ff]"
    msgLink.strParams:append(palyerid)
    mMsgInputWrap:TryAppendMsgLink(msgLink)
end

--添加话题链接
function AddTopicLink(content)
    local msgLink = Chat_pb.ChatMsgLink()
    msgLink.linkType = Chat_pb.ChatMsgLink.ITEM
    msgLink.isValid = true
    msgLink.content = content
    msgLink.linkDesc.textDesc.color = "[0000ff]"
    
    --把显示所需数据序列化
   -- msgLink.byteParams:append(data.itemSlot:SerializeToString())
    --msgLink.staticID = 1
    mMsgInputWrap:TryAppendMsgLink(msgLink)
end

--更新输入显示
function UpdateMsgInput()
    local curHeight =math.min(MAX_MSG_HEIGHT,mMsgLabel.localSize.y)
    local dif = MAX_MSG_HEIGHT - mMsgLabel.localSize.y
    mScrollPanel:SetRect(0,-curHeight/2,608,curHeight)
    if dif >= 0 then
        mScrollPanel.clipOffset =  Vector2.zero;
        mScrollPanel.transform.localPosition = mOrignalPos
    else
        mScrollPanel.clipOffset =  Vector2(0,dif);
        mScrollPanel.transform.localPosition = Vector3(mOrignalPos.x,mOrignalPos.y-dif,0) 
    end
    mImageTable.transform.localPosition = Vector3(-300,mOrignalPos.y-curHeight-15,0)
end

--更新图片
function UpdateImageTable()
    local Num =table.getn(mImageData)+1
    local initNum = math.min(Num,MAX_IMAGE_NUM)
    for i = 1, MAX_IMAGE_NUM do
        if i<=initNum then
            if mImageGrids[i]==nil then
                mImageGrids[i] = NewImage(mImagePrefab, i);
            end
            local item =mImageGrids[i]
            if mImageData[i] then
                item.dataId = i;
                if  item.texture.mainTexture then
                    item.texture.mainTexture = nil
                end
                PersonSpaceMgr.LoadMomentImage(item.texture,mImageData[i].img)
            else 
                item.dataId = -1;
            end
            item.gameObject:SetActive(true)
        else
            if mImageGrids[i] then
                mImageGrids[i].gameObject:SetActive(false)
            end
        end
    end
    mImageTable:Reposition()
end

--更新可见
function UpdateSeeTable()
    local Num =table.getn(mSeeData)
    local initNum = math.min(Num,MAX_SEE_NUM)
    for i = 1, MAX_SEE_NUM do
        if i<=initNum then
            if mSeeGrids[i]==nil then
                mSeeGrids[i] = NewSeeTag(mSeePrefab, i);
            end
            local item =mSeeGrids[i]
            if mSeeData[i] then
                item.dataId = i;
                item.itemlabel.text = mSeeData[i]
                item.itemselect:SetActive(mSelectSee[i] and mSelectSee[i]==1);
            else 
                item.dataId = -1;
            end
            item.gameObject:SetActive(true)
        else
            if mSeeGrids[i] then
                mSeeGrids[i].gameObject:SetActive(false)
            end
        end
    end
    mSeeTable:Reposition()
end

--更新可见
function UpdateTopicTable()
    local Num =table.getn(mTopicData)+1
    local initNum = math.min(Num,MAX_TOPIC_NUM)
    local maxwidth = mTopicTable.padding.x
    mTopicTable.columns = initNum
    for i = 1, MAX_TOPIC_NUM do
        if i<=initNum then
            if mTopicGrids[i]==nil then
                mTopicGrids[i] = NewTopicTag(mTopicPrefab, i);
            end
            local item =mTopicGrids[i]
            if mTopicData[i] then
                item.dataId = i;
                item.itemlabel.text = mTopicData[i]
                item.itemselect:SetActive(mSelectTopic[i] and mSelectTopic[i]==1);
            else
                item.dataId = -1;
                item.itemlabel.text ="添加话题"
                item.itemselect:SetActive(false);
            end
            item.widget.width= item.itemlabel.localSize.x+26
            item.gameObject:SetActive(true)
            maxwidth=maxwidth+ item.widget.width+mTopicTable.padding.x
        else
            if mTopicData[i] then
                mTopicData[i].gameObject:SetActive(false)
            end
        end
        
    end
    mTopicTableWidget.width = maxwidth
    mTopicTable:Reposition()
end

function UpdateLayout()
    local ly =mImageTable.transform.localPosition.y - mImageTableWidget.localSize.y - 5 - mLocation.localSize.y
    mLocation.transform.localPosition = Vector3(-190,ly,0)
    local sy = ly - mLocation.localSize.y-5
    mSeeTable.transform.localPosition = Vector3(-190,sy,0)
    local ty = sy - mSeeTableWidget.localSize.y-5
    mTopicScrollViewPanel.transform.localPosition = Vector3(38,ty,0)
    mTopicTable.transform.localPosition = Vector3(-234,0,0)
    local sey = ty - mTopicScrollViewPanel.height-5 - mSend.localSize.y
    mSend.transform.localPosition = Vector3(0,sey,0)
    mTopicTable:Reposition()
end


--刷险背包界面显示
function UpdateView()
    if mAddress then
        mAddress.text =""
    end
    if mMsgInput then
        mMsgInput.value=""
    end
    mLocationSelect.gameObject:SetActive(isLocationOn)
    UpdateMsgInput()
    UpdateImageTable()
    UpdateSeeTable()
    UpdateTopicTable()
    UpdateLayout()
end

function OnUpLoadFinished(url,localPath)
    if url == nil then
    else
        table.insert(mImageData,{img=url,thn =url})
    end 
    UpdateImageTable()
end

function OnPhotoFinish(path)
    GameLog.Log("OpenPhotoLibrary "..path)
    PersonSpaceMgr.UpLoadMomentImage(path,OnUpLoadFinished,nil)
end

--更新选择显示
function UpdateSelect()
    for i,item in ipairs(mSeeGrids) do
        item.itemselect:SetActive(mSelectSee[item.dataId] and mSelectSee[item.dataId]==1);
    end
    for i,item in ipairs(mTopicGrids) do
        item.itemselect:SetActive(mSelectTopic[item.dataId] and mSelectTopic[item.dataId]==1);
    end
end

--点击事件处理
function OnClick(go, id)
	GameLog.Log("id %d", id)
    if id == -3 then--关闭
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_EditorMsg);
    elseif id == -4 then--表情
        mMsgInputWrap:OnLinkBtnClick()
    elseif id == -2 then--发送
        local msgstr = mMsgInputWrap:GetMsgCommon():SerializeToString()
        local content = string.ToBase64(msgstr)
        if content=="" and table.getn(mImageData)==0 then
            TipsMgr.TipCommon("不能发送空的朋友圈")
        else
            --(content,photos,videopreviewurl,videourl,audio,audiolen,location,is_private,is_appeal)
            PersonSpaceMgr.AddMoment(content,mImageData,"","","",0,mAddress.text,0,0)
            UIMgr.UnShowUI(AllUI.UI_PersonalSpace_EditorMsg);
        end
    elseif id == -1 then--开关定位
        isLocationOn = not isLocationOn
        mLocationSelect.gameObject:SetActive(isLocationOn)
        if isLocationOn then 
            GlobalMapMgr.StartSelfLocateComplete(function (selfCoordinate,selfLocationInfo,selfAddressInfo)
                mAddress.text = selfAddressInfo.address
           end)
           mAddress.text = "北京市"
        else
            mAddress.text = ""
        end
    elseif id >= 10000 and id <20000 then--点击图片
        local index =id-10000
        --local mMax = table.getn(mImageData)+1
        --local mAdd = math.min(mMax,MAX_IMAGE_NUM)
        local item = mImageGrids[index];
        if item.dataId==-1 then --是添加按钮
            --添加照片
            GameLog.Log("添加照片")
            PersonSpaceMgr.ChooseMomentImage(false,OnPhotoFinish,_self)
        else
            GameLog.Log("点击照片"..item.dataId)
            if mSelectImage[item.dataId] == nil then
                mSelectImage[item.dataId]=1
            else
                mSelectImage[item.dataId] = nil
            end
        end
    elseif id >20000 and id <30000 then--点击到see
        local index =id-20000
        --local mMax = table.getn(mImageData)+1
        --local mAdd = math.min(mMax,MAX_IMAGE_NUM)
        local item = mSeeGrids[index];
        if item.dataId and item.dataId>0 then --数据可用
            GameLog.Log("点击可见"..item.dataId)
            if mSelectSee[item.dataId] == nil then
                mSelectSee[item.dataId]=1
            else
                mSelectSee[item.dataId] = nil
            end
        end
		UpdateSelect()
    elseif id >30000 then--点击到话题 tag
        local index =id-30000
        local item = mTopicGrids[index];
        if item.dataId==-1 then --是添加按钮
            --添加话题
            GameLog.Log("添加话题")
        else
            GameLog.Log("点击话题"..item.dataId)
            AddTopicLink(""..mTopicData[item.dataId])
            if mSelectTopic[item.dataId] == nil then
                mSelectTopic[item.dataId]=1
            else
                mSelectTopic[item.dataId] = nil
            end
        end
       UpdateSelect()
	end
end
