module("UI_PersonalSpace_OtherTag",package.seeall)

--信息结构
local mInfo={}
--标签结构
local mTag={}
local mPlayerInfo=nil
local mPlayerId =UserData.PlayerID
--玩家性别
local m_gender = 1
--玩家星座
local m_star = 1
--標籤
local m_TagsTable = {}
local m_userTags ={}
local m_RegionTitle = {"我眼中的自己","别人眼中的我","系统称号"}

local mRecommend = {}
local mRecommendItems = {}
local mRecommendData = {"ssss","ssdsa"}
local mShowMode = 1 --1 别人的 2 自己的

local mEditorSysTag = false


local mLikes = {}
local mLikesItems = {}
local mLikesData = {
    {tag="sss",count = "2",list ={"ss","sss"}}
}
local mAllLikesData = {
    [1] = {
        {tag="sss",count = "2",list ={"ss","sss"}},
    },
    [2] = {
        {tag="sss",count = "2",list ={"ss","sss"}},
        {tag="aaa",count = "2",list ={"ss","sss"}}
    },
    [3]={
        {tag="sss",count = "2",list ={"ss","sss"}},
        {tag="aaa",count = "2",list ={"ss","sss"}},
        {tag="ffff",count = "4",list ={"1","2","3","4","5"}}
    }
}
local mSystemTags = {tags = {"sdas","adas","aaa","ddddd","ssssss"},show = {1,2}}

local chooseRegionIndex = 1
local chooseLikeIndex = 1
local choosePlayerIndex = 1

local mPopView ={}

function OnCreate(self)
    _self = self
    mTag._closePopBtn = self:Find("Offset/CloseBtn").gameObject
    mTag._tagBgWidget = self:FindComponent("UIWidget","Offset/TagScrollView/TagBg")
    mTag._tagBgTable = self:FindComponent("UITable","Offset/TagScrollView/TagBg")
    mTag._tagRegion = self:Find("Offset/TagScrollView/TagRegion").gameObject
    mTag._tagPrefab = self:Find("Offset/TagScrollView/TagItem").gameObject
    mTag._tagRegion:SetActive(false)
    mTag._tagPrefab:SetActive(false)
    mTag._Regions = {}
    for i=1,3 do
        mTag._Regions[i] = AddTagRegion(mTag._tagBgWidget.transform,mTag._tagRegion.transform,i)
    end

    mRecommend._mRecommendBg = self:Find("Offset/RecommendBg")
    mRecommend._mScrollView = self:FindComponent("UIScrollView","Offset/RecommendBg/RecommendScrollView")
    mRecommend._mRecommendItem = self:Find("Offset/RecommendBg/RecommendScrollView/RecommendItem")
    mRecommend._mRecommendWidget = self:FindComponent("UIWidget","Offset/RecommendBg/RecommendScrollView/RecommendTable")
    mRecommend._mRecommendUITable = self:FindComponent("UITable","Offset/RecommendBg/RecommendScrollView/RecommendTable")
    mRecommend._mRecommendBg.gameObject:SetActive(false)
    mRecommend._mRecommendItem.gameObject:SetActive(false)
    mTag._closePopBtn.gameObject:SetActive(false)

    mLikes.mObject = self:Find("Offset/LikeBg").gameObject
    --点赞列表数组
    mLikes.mLists ={}
    for i=1,2 do
        local basePath = string.format("Offset/LikeBg/ListBg%d",i)
        local item ={}
        item.transform = self:Find(basePath)
        item.mTitle = item.transform:Find("Title"):GetComponent("UILable");
        item.mScrollView = item.transform:Find("ListLikeView"):GetComponent("UIScrollView");
        item.mUITable = item.transform:Find("ListLikeView/LikeTable"):GetComponent("UITable");
        item.mUIWidget = item.transform:Find("ListLikeView/LikeTable"):GetComponent("UIWidget");
        item.mItem = item.transform:Find("ListLikeView/LikeItem")
        item.mItem.gameObject:SetActive(false)
        item.transform.localPosition = Vector3(-144+288*(i-1),0,0)
        mLikes.mLists[i] = item
    end
    mLikes.mObject:SetActive(false)

    --推荐弹出视图
    mPopView.transform = self:Find("Offset/PopView")
    mPopView._mTableWidget = self:FindComponent("UIWidget","Offset/PopView/PopScrollView/PopTable")
    mPopView._mUITable = self:FindComponent("UITable","Offset/PopView/PopScrollView/PopTable")
    mPopView._mItem = self:Find("Offset/PopView/PopItem")
    mPopView._mItem.gameObject:SetActive(false)
    HidePopView()
end

function OnEnable(self)
    RegEvent(self)
    GetData()
end

function OnDisable(self)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PSPACE,EVT.PS_SETPLAYERTAGS,TagChanged);
   
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_SETPLAYERTAGS,TagChanged);
    mEvents = {};
end

--添加标签显示条目
function AddTagRegion(parent,obj,index)
    local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(obj, parent, index).gameObject;
	item.gameObject.name = tostring(40000 + index);
    item.transform = item.gameObject.transform;
    item.widget= item.transform:GetComponent("UIWidget");
    item.bg = item.transform:Find("Bg"):GetComponent("UIEvent");
    item.bg.id = 40000+index
    item.setBtn = item.transform:Find("SetBtn"):GetComponent("UIEvent");
    item.setBtn.id = 42000+index
    item.label = item.transform:Find("Label"):GetComponent("UILabel");
    item.tagsTable= item.transform:Find("Tags"):GetComponent("UITable");
    item.tagsWidget= item.transform:Find("Tags"):GetComponent("UIWidget");
    item.addTagEvent= item.transform:Find("Tags/AddTag"):GetComponent("UIEvent");
    item.addTagEvent.id = 41000+index
	item.gameObject:SetActive(false);
	return item;
end

function PickTag(parent,obj, index)
	local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(obj, parent, index).gameObject;
	item.gameObject.name = tostring(10000 + index);
    item.transform = item.gameObject.transform;
    item.widget = item.transform:GetComponent("UIWidget");
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
    item.itemlabel = item.transform:Find("ItemLabel"):GetComponent("UILabel");
    item.select = item.transform:Find("Select"):GetComponent("UISprite");
    item.like = item.transform:Find("Like"):GetComponent("UISprite");
    item.Gray = item.transform:Find("Gray"):GetComponent("UISprite");
   -- item.popEvent = item.transform:Find("Pop"):GetComponent("UIEvent");
    item.uiEvent = item.transform:GetComponent("UIEvent");
    item.uiEvent.id = 10000 + index
  --  item.popEvent.id = 11000 + index
    item.gameObject:SetActive(false);
	return item;
end

function SetPlayerId(pid)
   mPlayerId = pid
end

function SetShowMode(mode)
    mShowMode = mode
end

function GetData()
    mPlayerInfo= PersonSpaceMgr.GetPlayerInfoById(mPlayerId)
    -- m_userTags[1] = PersonSpaceMgr.GetPlayerTagsById(mPlayerId)
    -- m_userTags[2] = PersonSpaceMgr.GetPlayerTagsById(mPlayerId)
    -- m_userTags[3] = PersonSpaceMgr.GetPlayerTagsById(mPlayerId)
  
    if mEditorSysTag then
        local temp = {}
        local check = {}
        local nn = table.getn(mSystemTags.show)
        for i=1,nn do
            temp[i] = mSystemTags.tags[mSystemTags.show[i]]
            check[mSystemTags.show[i]]=1
        end
        local index = 1
        for i=1,#mSystemTags.tags do
            if check[i]==nil then
                temp[nn+index] = mSystemTags.tags[i]
                index=index+1
            end
        end

        m_userTags[3] = temp
    else
        local temp = {}
        for i=1,#mSystemTags.show do
            temp[i] = mSystemTags.tags[mSystemTags.show[i]]
        end
        m_userTags[3] = temp
    end
    UpdateView()
end

function TagChanged()
    GetData()
end

function UpdateUserTags()
    local region = mTag._Regions[1]
    if m_TagsTable[1] == nil then m_TagsTable[1]={} end
    local m_Tags  = m_TagsTable[1]
    local m_users  = m_userTags
    local mCount = table.getn(m_Tags)
    local datanum =  table.getn(m_users)
    local max = math.max(mCount,datanum)
    region.gameObject:SetActive(true);
    local height = 0
    for i=1,max do
        if m_Tags[i]==nil then
            m_Tags[i] = PickTag(region.tagsWidget.gameObject.transform,mTag._tagPrefab.transform,i)
        end
        local item =m_Tags[i]
    end
end

--刷新标签
function UpdateTags()
    local region
    local baseY = 0
    for j=1,3 do
        region = mTag._Regions[j]
        if m_TagsTable[j] == nil then m_TagsTable[j]={} end
        if m_userTags[j] == nil then m_userTags[j]={} end
        local m_Tags  = m_TagsTable[j]
        local m_users  = m_userTags[j]
        local mCount = table.getn(m_Tags)
        local datanum =  table.getn(m_users)
        local max = math.max(mCount,datanum)
        region.gameObject:SetActive(true);
        local height = 0
        for i=1,max do
            if m_Tags[i]==nil then
                m_Tags[i] = PickTag(region.tagsWidget.gameObject.transform,mTag._tagPrefab.transform,i)
            end
            local item =m_Tags[i]
            if i<=datanum then
                local kind = math.random(1,9)
                --item.itembg.spriteName = kind <10 and string.format("teps_geren_0%d",kind) or string.format("teps_geren_%d",kind)
                item.gameObject:SetActive(true)
                height=item.widget.height
                item.select.gameObject:SetActive(false)
                item.like.gameObject:SetActive(false)
                --item.popEvent.gameObject:SetActive(false)
                item.uiEvent.id =100000+ 10000*j + i
               -- item.popEvent.id =100000+ 10000*j+1000 + i
                item.dataIndex = i
                if j==1 or j==2 then
                    item.itemlabel.text = m_users[i]
                end
                if j==3 and mEditorSysTag then
                    item.itemlabel.text = m_users[i]
                    if table.contains_value(mSystemTags.show,i) then
                        item.Gray.gameObject:SetActive(false)
                    else
                        item.Gray.gameObject:SetActive(true)
                    end
                else
                    item.itemlabel.text = m_users[i]
                    item.Gray.gameObject:SetActive(false)
                end
            else
                item.gameObject:SetActive(false)
            end
        end
        region.addTagEvent.transform.gameObject:SetActive(mShowMode==2 and j~=2)
        region.label.text = m_RegionTitle[j]
        region.tagsWidget.height = math.ceil(datanum/2) *(height + region.tagsTable.padding.y)
        region.tagsTable:Reposition()
        region.widget.height = region.tagsWidget.height + 50
        region.widget.transform.localPosition.y = -7-baseY
        baseY = baseY + region.widget.height
    end
    mTag._tagBgTable:Reposition()
end

function UpdateView()
    UpdateTags()
end

--添加推荐
function AddRecommendItem(parent,obj, index)
	local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(obj, parent, index).gameObject;
	item.gameObject.name = tostring(20000 + index);
    item.transform = item.gameObject.transform;
    item.widget = item.transform:GetComponent("UIWidget");
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
    item.itemlabel = item.transform:Find("ItemLabel"):GetComponent("UILabel");
    item.select = item.transform:Find("Select"):GetComponent("UISprite");
    item.uiEvent = item.transform:GetComponent("UIEvent");
    item.uiEvent.id = 20000 + index
    item.gameObject:SetActive(false);
	return item;
end

function ShowRecommendList(show)
    mRecommend._mRecommendBg.gameObject:SetActive(show)
    mTag._closePopBtn.gameObject:SetActive(show)
    if not show then return  end
    local datanum =table.getn(mRecommendData)
    local itemCount =table.getn(mRecommendItems)
    local max = math.max(datanum,itemCount)
    local height = 0
    for i=1,max do
        if mRecommendItems[i]==nil then
            mRecommendItems[i] = AddRecommendItem(mRecommend._mRecommendWidget.transform,mRecommend._mRecommendItem.transform,i)
        end
        local item =mRecommendItems[i]
        if i<=datanum then
            item.itemlabel.text = mRecommendData[i]
            item.gameObject:SetActive(true)
            height=height+item.widget.height
            item.select.gameObject:SetActive(false)
            item.uiEvent.id = 20000 + i
        else
            item.gameObject:SetActive(false)
        end
    end
    mRecommend._mRecommendWidget.height = height
    mRecommend._mRecommendUITable:Reposition()
end

--添加点赞列表内容
function AddLikeItem(parent,obj, index)
	local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(obj, parent, index).gameObject;
	item.gameObject.name = tostring(20000 + index);
    item.transform = item.gameObject.transform;
    item.widget = item.transform:GetComponent("UIWidget");
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
    item.itemlabel = item.transform:Find("ItemLabel"):GetComponent("UILabel");
    item.select = item.transform:Find("Select"):GetComponent("UISprite");
    item.icon = item.transform:Find("Icon"):GetComponent("UISprite");
    item.likeIcon = item.transform:Find("LikeIcon"):GetComponent("UISprite");
    item.tagName = item.transform:Find("Tag"):GetComponent("UILabel");
    item.uiEvent = item.transform:GetComponent("UIEvent");
    item.uiEvent.id = 20000 + index
    item.gameObject:SetActive(false);
	return item;
end

function ShowLikeList(show)
    mLikes.mObject:SetActive(show)
    mTag._closePopBtn.gameObject:SetActive(show)
    if not show then return  end
    mLikesData = mAllLikesData[chooseRegionIndex]
    --列表对象
    local listview = mLikes.mLists[1]
    --当前被点赞的标签数量
    local tagsNum = table.getn(mLikesData)
    --实例化的条目
    if mLikesItems[1] == nil then  mLikesItems[1]={} end
    local itemCount =table.getn(mLikesItems[1])
    local max = math.max(tagsNum,itemCount)
    local height = 0
    for i=1,max do
        local gridlist = mLikesItems[1]
        if gridlist[i]==nil then
            gridlist[i] = AddLikeItem(listview.mUITable.transform,listview.mItem.transform,i)
        end
        if i<=tagsNum then
            local grid = gridlist[i]
            local data = mLikesData[i]
            grid.tagName.text = data.tag
            grid.itemlabel.text = data.count
            grid.gameObject:SetActive(true)
            grid.select.gameObject:SetActive(false)
            grid.uiEvent.id = 60000 + i
            height=height+grid.widget.height
        else
            local grid = gridlist[i]
            grid.gameObject:SetActive(false)
        end
    end
    listview.mUITable:Reposition()
    listview.mUIWidget.height = height

    height = 0
    --列表对象
    local playerlistview = mLikes.mLists[2]
    --点赞人的数量
    local playerData = mLikesData[chooseLikeIndex].list
    local playerNum = table.getn(playerData)
    if mLikesItems[2] == nil then  mLikesItems[2]={} end
    local itemCount =table.getn(mLikesItems[2])
    local max = math.max(playerNum,itemCount)
    for i=1,max do
        local gridlist = mLikesItems[2]
        if gridlist[i]==nil then
            gridlist[i] = AddLikeItem(playerlistview.mUITable.transform,playerlistview.mItem.transform,i)
        end
        if i<=playerNum then
            local grid = gridlist[i]
            local data = playerData[i] 
            grid.itemlabel.text = data
            grid.gameObject:SetActive(true)
            grid.select.gameObject:SetActive(false)
            grid.uiEvent.id = 70000 + i
            height=height+grid.widget.height
        else
            local grid = gridlist[i]
            grid.gameObject:SetActive(false)
        end
    end 
    playerlistview.mUITable:Reposition()
    playerlistview.mUIWidget.height = height
end

function AddPopItem(parent,obj, index)
	local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(obj, parent, index).gameObject;
	item.gameObject.name = tostring(30000 + index);
    item.transform = item.gameObject.transform;
    item.widget = item.transform:GetComponent("UIWidget");
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
    item.itemlabel = item.transform:Find("ItemLabel"):GetComponent("UILabel");
    item.icon = item.transform:Find("Head"):GetComponent("UISprite");
    item.uiEvent = item.transform:GetComponent("UIEvent");
    item.uiEvent.id = 30000 + index
    item.gameObject:SetActive(false);
	return item;
end

function ShowPopView(show,parent,datas)
    mTag._closePopBtn.gameObject:SetActive(show)
    mPopView.transform.gameObject:SetActive(show)
    if show==false then return end
    mPopView.transform.parent = parent
    mPopView.transform.localPosition = Vector3(0,-100,0)
    if mPopView.Items == nil then  mPopView.Items= {} end
    local datanum =table.getn(datas)
    local itemCount =table.getn(mPopView.Items)
    local max = math.max(datanum,itemCount)
    local height = 0
    for i=1,max do
        if mPopView.Items[i]==nil then
            mPopView.Items[i] = AddPopItem(mPopView._mTableWidget.transform,mPopView._mItem.transform,i)
        end
        local item =mPopView.Items[i]
        if i<=datanum then
            item.itemlabel.text = datas[i]
            item.gameObject:SetActive(true)
            height=height+item.widget.height
            item.uiEvent.id = 30000 + i
        else
            item.gameObject:SetActive(false)
        end
    end
    mPopView._mTableWidget.height = height
    mPopView._mUITable:Reposition()
end

function HidePopView()
    ShowPopView(false)
end

function OnClick(go, id)
    if id == 1 then
    elseif id == 2 then
    elseif id ==3 then  
    elseif id ==-1000 then--关闭弹出界面
        HidePopView()
        ShowRecommendList(false)
        ShowLikeList(false)
    end
    if id >100000 and id <200000 then--点击
        local localid = id-100000
        local region =math.floor(localid/10000)
        local index = localid % 10000
        if mShowMode==1 then--别人的
            if index>1000 then--popview--点击推荐气泡 弹出推荐列表
                local tagId = index-1000
                local tagItem  = m_TagsTable[region][tagId]
                HidePopView()
                ShowRecommendList(true)
            else
                --tagview
                local tagId = index
                --点赞 弹出推荐气泡
                local tagItem  = m_TagsTable[region][tagId]
                local tagData  = m_userTags[region][tagId]
                local regiondata = mTag._Regions[region]
                ShowPopView(true,tagItem.gameObject.transform,{"ssss","sdsdsd","dsdsdsd"})
            end
        elseif mShowMode==2 then--看自己的
            if region==3 and mEditorSysTag then--编辑显示隐藏
                   --tagview
                   local tagId = index
                   --点赞 弹出推荐气泡
                   local tagItem  = m_TagsTable[region][tagId]
                   local tagData  = m_userTags[region][tagId]
                   local regiondata = mTag._Regions[region]
                   if table.contains_value(mSystemTags.show,tagId) then
                        table.remove_value(mSystemTags.show,tagId)
                   else
                        table.insert(mSystemTags.show,tagId)
                   end
                   GetData()
            end
        end
    end

    if id >20000 and id <30000 then
        GameLog.Log("点击推荐的人 ")
    elseif id >30000 and id <40000 then--点击弹出popview
        HidePopView()
        ShowRecommendList(true)
    end

    if mShowMode==2 then--看自己的
            --点击标签分区
        if id>40000 and id < 41000 then
            GameLog.Log("点击标签分区")
        elseif id>41000 and id < 42000 then
            GameLog.Log("区域编辑")
            local regionid = id - 41000
            if regionid == 1 then
                UIMgr.ShowUI(AllUI.UI_PersonalSpace_AddTags);
            end
            if regionid == 3 then
                --编辑系统标签显示隐藏
                mEditorSysTag =not mEditorSysTag
                GetData()
            end
        elseif id>42000 and id < 43000 then
            GameLog.Log("点击列表")
            local regionid = id - 42000
            chooseRegionIndex = regionid
            ShowLikeList(true)
        elseif id>60000 and id < 70000 then--点击点赞的tag
            GameLog.Log("点击被点赞tag")
            local tagindex = id - 60000
            chooseLikeIndex = tagindex
            ShowLikeList(true)
        elseif id>70000  then--点击点赞的tag
            GameLog.Log("点击点赞人")
            local playerid = id - 70000
            choosePlayerIndex = playerid
        end
    end
    
    
end

