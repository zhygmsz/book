module("UI_PersonalSpace_InfoSetting",package.seeall)
local UI_PickUpView = require("Logic/Presenter/UI/PersonalSpace/UI_PickUpView")
local UIPickUpViewController = require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/UIPickUpViewController")
--信息背景
local mDynamic = nil
local mInfo={}
local mPlayerInfo=nil
--玩家性别
local m_gender = 1
--玩家星座
local m_star = 1
--城市
local m_city=nil
--生日
local m_birthday=nil
--位置
local m_location=nil
--省份
local m_province=""

local mPickTagItems = {}
local MAX_PICK_NUM = 10

local mWrapGrids = {}
local mWrap;
local mWrapCallBack;
local itemCountPerLine = 4
local MAX_WRAPITEM_COUNT = 12;
local MAX_GRID_COUNT = 60;
local MIN_GRID_COUNT = 8
local mDragPanel;
local DragOffSet=nil
--全部格子数据数组
local mGridDatas = {};
local mCurGridCount = 50;
--当前选中格子
local mCurSelectIndex = - 1;

local mScrollView = nil
local mScrollPanel = nil
local mGifPanel = nil
local mPickController =nil

function OnCreate(self)
    mDynamic = self:Find("Offset/Dynamic").gameObject
    mInfo._title = self:FindComponent("UILabel", "Offset/Dynamic/Title")
    mInfo._thumb = self:FindComponent("TweenPosition", "Offset/Dynamic/Switch/thumb")
    mInfo._thumb.enabled = false
    mInfo._maleSelect = self:Find("Offset/Dynamic/Sex/MaleBtn/Select").gameObject
    mInfo._femaleSelect = self:Find("Offset/Dynamic/Sex/FemaleBtn/Select").gameObject
    mInfo._secretSelect = self:Find("Offset/Dynamic/Sex/SecretBtn/Select").gameObject
    mInfo._tagTable = self:FindComponent("UITable", "Offset/Dynamic/Tags/Table")
    mInfo._tag = self:Find("Offset/Dynamic/Tags/Table/Tag").gameObject
    mInfo._Add = self:Find("Offset/Dynamic/Tags/Table/Add").gameObject
    mInfo._AddTagEvent = self:FindComponent("UIEvent", "Offset/Dynamic/Tags/Table/Add");
    mInfo._AddTagEvent.id = 40
    mInfo._answerInput = self:FindComponent("UIInput", "Offset/Dynamic/AutoAnswer/Input")
    mInfo._provinceLabel = self:FindComponent("UILabel", "Offset/Dynamic/City/ProvinceBtn/Label")
    mInfo._cityLabel= self:FindComponent("UILabel", "Offset/Dynamic/City/CityBtn/Label")
    mInfo._birthLabel = self:FindComponent("UILabel", "Offset/Dynamic/Birthday/DateBtn/Label")
    mInfo._zodiacLabel = self:FindComponent("UILabel", "Offset/Dynamic/Zodiac")
    mInfo._locationLabel = self:FindComponent("UILabel", "Offset/Dynamic/Location/Label")

    for i = 1, MAX_PICK_NUM do
		mPickTagItems[i] =PickTag(self, i)
    end
    mInfo._tag.gameObject:SetActive(false);

    local itemPrefab = self:Find("Offset/Dynamic/GifPanel/ItemPrefab");
	mWrap = self:FindComponent("UIWrapContent", "Offset/Dynamic/GifPanel/ItemParent/ScrollView/ItemWrap");
	mWrap.itemCountPerLine = itemCountPerLine
	mCountPerLine = mWrap.itemCountPerLine
	mDragPanel = self:Find("Offset/Dynamic/GifPanel/ItemParent/ScrollView").transform;
	
	for i = 1, MAX_WRAPITEM_COUNT do
		mWrapGrids[i] = NewItem(self, itemPrefab, i);
	end
	itemPrefab.gameObject:SetActive(false);
	mScrollView = mDragPanel:GetComponent("UIScrollView");
    mScrollPanel = mDragPanel:GetComponent("UIPanel");
    mGifPanel = self:Find("Offset/Dynamic/GifPanel").gameObject;
    mGifPanel:SetActive(false)
	InitPanel();
end

function NewItem(self, obj, index)
	local item = {};
	item.index = index;
	item.gameObject = self:DuplicateAndAdd(obj, mWrap.transform, index).gameObject;
	item.gameObject.name = tostring(10000 + index);
	item.transform = item.gameObject.transform;
	item.itembg = item.transform:Find("ItemBg"):GetComponent("UISprite");
	item.itemicon = item.transform:Find("ItemIcon"):GetComponent("UISprite");
    item.itemselect = item.transform:Find("ItemSelect").gameObject;
    item.itemselectBg = item.transform:Find("ItemSelectBg").gameObject;
	item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
	item.gameObject:SetActive(false);
	return item;
end

function GetPickController()
    if mPickController == nil then
        mPickController = UIPickUpViewController.new()
    end
    return mPickController
end

function PickTag(self, index)
	local item = {};
	item.index = index;
	item.gameObject = self:DuplicateAndAdd(mInfo._tag.transform, mInfo._tagTable.transform, index).gameObject;
	item.gameObject.name = tostring(20 + index);
	item.transform = item.gameObject.transform;
	item.itembg = item.transform:GetComponent("UISprite");
	item.itemlabel = item.transform:Find("Label"):GetComponent("UILabel");
    item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
    item.uiEvent.id = 20 + index
	item.gameObject:SetActive(false);
	return item;
end

function OnEnable(self)
    RegEvent(self)
    UpdateData()
    UpdateView()
end

function OnDisable(self)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PSPACE,EVT.PS_SETPLAYERINFO,PlayerInfoSetted);
    GameEvent.Reg(EVT.PSPACE,EVT.PS_SETPLAYERTAGS,OnSaveTags);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_SETPLAYERINFO,PlayerInfoSetted);
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_SETPLAYERTAGS,OnSaveTags);
    mEvents = {};
end

function PlayerInfoSetted()
    UIMgr.UnShowUI(AllUI.UI_PersonalSpace_InfoSetting);
end

--初始化面板
function InitPanel()
	mScrollView.resetOffset = Vector3.zero;
	mScrollPanel.clipOffset = Vector2.zero;
	mDragPanel.localPosition = Vector3.zero;
end

--scrollowview布局
function UpdateLayout()
	local mDRAG_FINISH_OFFSET = DragOffSet or Vector3.New(0, 0, 0)
	table.sort(mWrapGrids, function(a, b) return a.gameObject.name < b.gameObject.name; end);
    for k, v in pairs(mWrapGrids) do if v then v.uiEvent.id = 10000+k; end end
    if not mWrapCallBack then mWrapCallBack = UIWrapContent.OnInitializeItem(OnInitGrid); end
	mWrap:WrapContentWithPosition(NewGridCount(), mWrapCallBack, mDRAG_FINISH_OFFSET);
end

--当前物品格子数
function NewGridCount()
	local curGridCount = #mGridDatas;
	mCurGridCount = curGridCount <= MAX_GRID_COUNT and curGridCount or MAX_GRID_COUNT;
	if mCurGridCount <= MIN_GRID_COUNT then
		mCurGridCount = MIN_GRID_COUNT
	end
	return mCurGridCount;
end

--初始化各自信息 范围内的可见 
function OnInitGrid(go, wrapIndex, realIndex)
	if realIndex >= 0 and realIndex < mCurGridCount then
		go:SetActive(true);
		InitGrid(wrapIndex + 1, realIndex + 1);
	else
		go:SetActive(false);
	end
end

--初始化背包物品信息 复用格子的id 逻辑数据的id
function InitGrid(gridID, dataID)
	local Grid = mWrapGrids[gridID];
	local data = mGridDatas[dataID];
    --item.itemicon.spriteName = ""
	Grid.itemselect:SetActive((data) and mCurSelectIndex == dataID or false);
	Grid.data = nil
	if data then
		Grid.data = data
	end
	Grid.gridID = gridID;
	Grid.dataID = dataID;
	Grid.gameObject:SetActive(true);
end

function UpdateData()
    mPlayerInfo = PersonSpaceMgr.GetSelfPlayerInfo()
    m_star= mPlayerInfo:GetStar()
    m_gender=mPlayerInfo:GetGender()
    m_birthday =mPlayerInfo:GetBirthday()
    m_location = mPlayerInfo:GetLocation()
end

function UpdateView()
    SetImageMode()
    mInfo._maleSelect:SetActive(m_gender==1)
    mInfo._femaleSelect:SetActive(m_gender==2)
    mInfo._secretSelect:SetActive(m_gender==3)
    mInfo._birthLabel.text = mPlayerInfo:GetBirthdayString()
    mInfo._zodiacLabel.text = mPlayerInfo:GetConstellationName()
    mInfo._locationLabel.text = mPlayerInfo:GetLocationAddress()
    m_province = mPlayerInfo:GetProvinceName()
    mInfo._provinceLabel.text = m_province
    m_city =mPlayerInfo:GetCityName()
    mInfo._cityLabel.text = m_city
    UpdateTags()
end
 
function UpdateTags()
    local tags = mPlayerInfo:GetCharacterTags()
    if tags==nil then return end
 
    local tagnum = table.count(tags)
    for i=1,MAX_PICK_NUM do
        if i<=tagnum then
            local tag = CharacterTagData.GetCharacterTag(tags[i])
            mPickTagItems[i].itemlabel.text = tag.value
            mPickTagItems[i].gameObject:SetActive(true);
        else
            mPickTagItems[i].gameObject:SetActive(false);
        end
    end
    if tagnum>=MAX_PICK_NUM then
        mInfo._Add.gameObject:SetActive(false);
    end
    mInfo._tagTable:Reposition()
end

function OnSaveTags()
    UpdateTags()
end

function SetImageMode()
    mInfo._thumb.enabled = true
    local mul = PersonSpaceMgr.mImageMode and 1 or -1
    mInfo._thumb.from =Vector3(-25*mul,0,0)
    mInfo._thumb.to = Vector3(25*mul,0,0)
    mInfo._thumb.duration = 0
    mInfo._thumb:PlayForward()
end

function ChooseLocation()
    GetPickController():PickLocation(Vector3(-180,-132,0),function (pid,cid,pname,cname)
        m_province = pname
        m_city = cname
        local selfAddressInfo = {
            adcode = cid,
            coordinate = Vector2(116.40,39.90),
            address=string.format("%s%s",m_province,m_city)
        }
        if selfAddressInfo then
             mPlayerInfo:SaveLocation(selfAddressInfo,false)
         end
        UpdateView()
    end)
end

function OnClick(go, id)
    if id == 0 then --无图加载开关
        PersonSpaceMgr.mImageMode = not PersonSpaceMgr.mImageMode
        SetImageMode()
    elseif id==1 then --生日
        GetPickController():PickUpData(Vector3(-180,-80,0),function (y,m,d)
            mPlayerInfo:SaveBirthday(y,m,d,false)
            mPlayerInfo:SaveStar(TimeUtils.SystemDate2Constellation(m,d),false)
            UpdateView()
        end)
    elseif id==2 then--位置
       local selfAddressInfo = GlobalMapMgr.GetCurrentAddressInfo()
       selfAddressInfo = {
           adcode = 1101,
           coordinate = Vector2(116.40,39.90),
           address="北京市"
       }
       if selfAddressInfo then
            mPlayerInfo:SaveLocation(selfAddressInfo,false)
        end
        --[[  GlobalMapMgr.StartSelfLocateComplete(function (selfCoordinate,selfLocationInfo,selfAddressInfo)
            mPlayerInfo.locationStruct.code = selfAddressInfo.adcode
            mPlayerInfo.locationStruct.coordinate = selfAddressInfo.coordinate
            mPlayerInfo.locationStruct.address = selfAddressInfo.address
            mPlayerInfo:SaveLocation(self._info.locationStruct)
       end)]]
        UpdateView()
    elseif id==3 then--省
        m_province="北京市"
        ChooseLocation()
    elseif id==4 then--城市
        m_city="北京市"
        ChooseLocation()
    elseif id==5 then--性别男
        m_gender=1
        mPlayerInfo:SaveGender(m_gender,false)
        UpdateView()
    elseif id==6 then--性别女
        m_gender=2
        mPlayerInfo:SaveGender(m_gender,false)
        UpdateView()
    elseif id==7 then--性别秘密
        m_gender=3
        mPlayerInfo:SaveGender(m_gender,false)
        UpdateView()
    elseif id==8 then--回复动态动作
        mGifPanel.gameObject:SetActive(true)
        mGridDatas = {"","","","","","","","",""}
        UpdateLayout();
    elseif id==9 then--回复输入键 

    elseif id==10 then--保存
        mPlayerInfo:SaveNickName(UserData.GetName(),false)
        mPlayerInfo:Save()
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_InfoSetting);
    elseif id==40 then --添加标签
        UIMgr.ShowUI(AllUI.UI_PersonalSpace_AddTags);
    elseif id>20 and id<=30 then --标签
        UIMgr.ShowUI(AllUI.UI_PersonalSpace_AddTags);
    elseif id==-100 then --关闭
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_InfoSetting);
    elseif id>10000 then
        --点击物品
        local index = id-10000
        local item = mWrapGrids[index];
        mCurSelectIndex = item.dataID;
        UpdateLayout()
    elseif id==-20000 then --关闭gif
        mGifPanel:SetActive(false)
    end
end