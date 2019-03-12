module("UI_GlobalMap",package.seeall);

local GangIcon=nil
local PlayerIcon=nil;
local SelfIcon=nil;
local Offset = nil

local IconTable={}
local ReUseIconTable={}

local mSelf=nil
--手势移动的速度
local Speed=1
--自己的位置
local selfCoordinate = Vector2(39.9107608145,116.2066733837)
local selfLocationInfo = nil

--要显示的玩家和帮派
local GangsForShow={}
local PlayersForShow={}
--地址栏
local AddressLabel = nil
--一键申请label
local EasyApplyLabel =nil
--创建按钮label
local CreateLabel =nil
--列表模式label
local ListModeLabel =nil
--搜索栏
local SearchBar=nil
 --搜索输入框
local SearchBarInput=nil 
--显示搜索栏
local SearchBarShow=true

 --缩放slider
local ZoomSlider = nil
local ZoomSliderBtnsObj=nil
local ZoomSliderCountryLabel=nil
local ZoomSliderProvindeLabel=nil
local ZoomSliderCityLabel=nil
local ZoomSliderStreetLabel=nil
local ZoomMin=3
local ZoomMax=18
local ZoomStep=16
local CurZoomLevel=16

local Startlevel=nil
local Endlevel=nil
--定位图标
local LocatePan=nil

function OnCreate(self)
    mSelf=self
    Offset = self:Find("Offset").gameObject; 
    AddressLabel = self:FindComponent("UILabel","Offset/Address"); 
    GangIcon = self:Find("Offset/GangIcon").gameObject; 
    PlayerIcon = self:Find("Offset/PlayerIcon").gameObject;
    SelfIcon = self:Find("Offset/SelfIcon").gameObject;
    LocatePan = self:Find("Offset/LocatePan").gameObject; 
    LocatePan.transform.localPosition = Vector3.zero
    EasyApplyLabel = self:FindComponent("UILabel","Offset/BtnToggles/Active/EasyApply/Name"); 
    ListModeLabel = self:FindComponent("UILabel","Offset/BtnToggles/Active/ListMode/Name"); 
    CreateLabel = self:FindComponent("UILabel","Offset/BtnToggles/Active/Create/Name");
    SearchBar= self:Find("Offset/SearchBar").gameObject;
    SearchBarInput= self:FindComponent("LuaUIInput", "Offset/SearchBar/Input");
    ZoomSlider= self:FindComponent("UISlider", "Offset/ZoomSlider");
    ZoomSlider.numberOfSteps=ZoomStep
    local call = EventDelegate.Callback(OnSliderChange);
    EventDelegate.Set( ZoomSlider.onChange,call);
    ZoomSliderBtnsObj= self:Find("Offset/ZoomSlider/Btns").gameObject;
    ZoomSliderCountryLabel=self:FindComponent("UILabel", "Offset/ZoomSlider/Btns/Country/Name");
    ZoomSliderProvindeLabel=self:FindComponent("UILabel", "Offset/ZoomSlider/Btns/Province/Name");
    ZoomSliderCityLabel=self:FindComponent("UILabel", "Offset/ZoomSlider/Btns/City/Name");
    ZoomSliderStreetLabel=self:FindComponent("UILabel", "Offset/ZoomSlider/Btns/Street/Name");
    GangIcon:SetActive(false);
    PlayerIcon:SetActive(false);
end

function OnEnable(self)
    OpenMap()
    RegEvent(self)
end

function OnDisable(self)
    UnRegEvent(self)
    Clear()
end

local mEvents = {};
function RegEvent(self)
    InitGesture()
    UpdateBeat:Add(Update,self);
    table.insert(mEvents,MessageSub.Register(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_UPDATELOCATION,OnLocateFinished));
    table.insert(mEvents,MessageSub.Register(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_JOIN,OnJoinedGang));
    table.insert(mEvents,MessageSub.Register(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_ZOOMENDTO,OnZoomEnd));
    table.insert(mEvents,MessageSub.Register(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_POITOCOORDINATE,OnPOIToCoordiante));
    table.insert(mEvents,MessageSub.Register(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_CREATE,OnCreateGang));
    
end

function UnRegEvent(self)
    CancelGesture()
    UpdateBeat:Remove(Update,self);
    MessageSub.UnRegister(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_UPDATELOCATION,mEvents[1]);
    MessageSub.UnRegister(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_JOIN,mEvents[2]);
    MessageSub.UnRegister(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_ZOOMENDTO,mEvents[3]);
    MessageSub.UnRegister(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_POITOCOORDINATE,mEvents[4]);
    MessageSub.UnRegister(GameConfig.SUB_G_GANG,GameConfig.SUB_U_GANG_CREATE,mEvents[4]);
    mEvents = {};
end

function OnShowOver()
    OnLocateFinished(selfCoordinate)
    LocateSelf()
end

--设置显示地址
function SetAddress(str)
    AddressLabel.text = str
end 

--定位到自己的位置
function LocateSelf()
    LocateToCoordinate(selfCoordinate)
end

--定位到位置
function LocateToCoordinate(coordinate)
    GlobalMapMgr.SetCoordinate(coordinate)
    GameTimer.AddTimer(0.3, 1, UpdateView);
end

--开始定位
function StartSelfLocate()
    GangMgr.StartSelfLocate()
end

-- 1是帮派 2是玩家
function NewIconButton(type,index)
    if IconTable[type] ==nil then IconTable[type]={} end
    local item = {};
    if ReUseIconTable[type]==nil or #ReUseIconTable[type]==0 then
        local obj = type==1 and GangIcon or PlayerIcon 
        item.index = index;
        item.type=type
        item.gameObject = mSelf:DuplicateAndAdd(obj.transform,Offset.transform,index).gameObject;
        item.transform=item.gameObject.transform
        item.transform.parent = Offset.transform
        item.transform.localPosition=Vector3.zero
        item.BgSprite = item.transform:GetComponent("UISprite");
        item.IconSprite = item.transform:Find("Icon").gameObject:GetComponent("UISprite")
        item.CountBg = item.transform:Find("CountBg").gameObject
        item.Count = item.transform:Find("CountBg/Count").gameObject:GetComponent("UILabel")
        item.pos = Vector2(0,0)
        item.coordinate = Vector2(0,0)
        item.CountBg:SetActive(false)
        item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
        table.insert(IconTable[type], item)
    else
        item = ReUseIconTable[type][1]
        table.insert(IconTable[type], item)
        table.remove(ReUseIconTable[type],1)
    end
    return item;
end

function UpdateUIEventIndex()
    for i=1,#IconTable do
        local icons=IconTable[i]
        if icons then
            for j=1,#icons do
                local item=icons[j]
                item.gameObject.name = i*10000+j
                item.uiEvent.id = i*10000+j
            end
        end
    end
end

--获取显示的数据
function GetServerData()
  
end

--添加图标到某个经纬度 type 1帮派 2 是玩家
function AddIconToLauLon(type,coordinatex,coordinatey,dataIndex,groupid,count)
    local item = NewIconButton(type,dataIndex)
    item.index = dataIndex;
    item.type=type
    local Icon=""
    if type==1 then--帮会
        Icon=GangMgr.GetGangDataByIndex(dataIndex).Icon
    elseif type==2 then--玩家
        Icon=GangMgr.GetPlayerDataByIndex(dataIndex).Icon
    end
    item.groupid = groupid
    item.count = count
    item.coordinate.x=coordinatex
    item.coordinate.y=coordinatey
    if count >1 then
        item.CountBg:SetActive(true)
        item.Count.text =string.format("%s",count)
    else
        item.CountBg:SetActive(false)
        item.Count.text=""
    end
    item.IconSprite.spriteName = Icon
    GlobalMapMgr.SetCoordinateToUIPosition(item.gameObject,coordinatex,coordinatey)           
    item.pos = item.gameObject.transform.localPosition
    item.gameObject:SetActive(true)
    UpdateUIEventIndex()
    UpdateView()
end


function OpenMap()
    CameraMgr.EnableMainCamera(true)
    UIMgr.MaskUI(true, AllUI.GET_MIN_DEPTH(), AllUI.GET_UI_DEPTH(AllUI.UI_GlobalMap))
    GlobalMapMgr.OpenMap()
    SetMapZoom(11)
end

function CloseMap()
    CameraMgr.EnableMainCamera(true)
    UIMgr.MaskUI(false)
    GlobalMapMgr.CloseMap()
end

--清理图标和二级界面
function Clear()
    for i=1,#IconTable do
        local icons=IconTable[i]
        if icons then
            for j=1,#icons do
                local item=icons[j]
                item.gameObject:SetActive(false)
                if ReUseIconTable[i]==nil then ReUseIconTable[i]={} end
                table.insert(ReUseIconTable[i],item)
            end
        end
    end
    IconTable={}
end
--==============================--
--手势处理
--==============================--
--初始化手势
function InitGesture()
    TouchMgr.SetEnableNGUIMode(false);
    TouchMgr.SetEnableCameraOperate(false);
    TouchMgr.SetTouchEventEnable(true)
    TouchMgr.SetListenOnSwipe(UI_GlobalMap,true);
    TouchMgr.SetListenOnPinch(UI_GlobalMap,true);
end
function CancelGesture() 
    TouchMgr.SetEnableNGUIMode(true)
    TouchMgr.SetTouchEventEnable(true)
    TouchMgr.SetEnableCameraOperate(true);
    TouchMgr.SetListenOnSwipe(UI_GlobalMap,false);
    TouchMgr.SetListenOnPinch(UI_GlobalMap,false);
end

local function round(value)
    value = tonumber(value) or 0
    return math.floor(value + 0.5)
end

local startDragPos=nil
local dragLocation=false
local dragDelta=Vector3.zero
local PixelSizeAdjustment=nil
function OnDragStart(id)
    if id == -400 then
        dragLocation=true;
            GameLog.Log("OnDragStart")
            startDragPos=LocatePan.transform.localPosition
            dragDelta=Vector3.zero
       end

end
function OnDrag(delta,id)
    if id == -400 then
        GameLog.Log("Drag drag drag drag ".."  delta "..delta.x.." delta.y "..delta.y.."   id id "..id)
        if PixelSizeAdjustment == nil then PixelSizeAdjustment = GlobalMapMgr.GetPixelSizeAdjustment() end
        dragDelta = dragDelta + Vector3(delta.x*PixelSizeAdjustment,delta.y*PixelSizeAdjustment,0)
        LocatePan.transform.localPosition =  startDragPos + dragDelta
    end
 end
function OnDragEnd(id)
    if id == -400 then
        dragLocation = false
        local coordinate = GlobalMapMgr.UIPositionToCoordinate(LocatePan)
        GameLog.Log("OnDragEnd coordinate %f %f",coordinate.x,coordinate.y)
        GlobalMapMgr.CoordinateToPOI(coordinate.x,coordinate.y,1)
    end
end

--拉进camera
function OnPinchIn(gesture)
    if gesture.touchCount == 2 then
        if Startlevel==nil then Startlevel= GlobalMapMgr.GetZoomLevel() end
        Endlevel =Startlevel- gesture.deltaPinch/100;
        if Endlevel<3 then Endlevel=3 end;
        if Endlevel>18 then Endlevel=18 end;
        Startlevel=Endlevel
        SetMapZoom(Endlevel);
	end 
end

--拉远camera
function OnPinchOut(gesture)
    if gesture.touchCount == 2 then
        if Startlevel==nil then Startlevel= GlobalMapMgr.GetZoomLevel() end
        Endlevel = Startlevel + gesture.deltaPinch/100;
        if Endlevel<3 then Endlevel=3 end;
        if Endlevel>18 then Endlevel=18 end;
        Startlevel=Endlevel
        SetMapZoom(Endlevel);
	end
end

function OnPinchEnd(gesture)
    if gesture.touchCount == 2 then
        Startlevel=Endlevel
        SetMapZoom(Endlevel);
	end
end

--转动
function OnSwipe(gesture)
	if gesture.touchCount == 1 and dragLocation==false then
		local finger = gesture.fingerIndex;
		local ix = gesture.deltaPosition.x;
		local iy = gesture.deltaPosition.y;
		local px = gesture.position.x;
        local py = gesture.position.y;
        GlobalMapMgr.MoveOffset(-1*ix*Speed,-1*iy*Speed)
        UpdateView()
	end
end
--退出
function Exit()
    CloseMap()
    UIMgr.UnShowUI(AllUI.UI_GlobalMap)
end

function OnClick(go,id)
	if id == 0 then
      --退出
      Exit()
    elseif id == -1 then
        --定位
        GlobalMapMgr.StartSelfLocate()
        OnLocateFinished(selfCoordinate)
    elseif id == -2 then
        --点击自己
    elseif id == -3 then
        --设置
    elseif id == -4 then
        --一键申请
    elseif id == -5 then
        --列表模式
        Exit()
    elseif id == -6 then
        --创建
    elseif id == -7 then
        --取消搜索
        SearchBarInput.value=""
    elseif id == -8 then
        --搜索
    elseif id == -10 then
        --国家
        SetMapZoom(3);
    elseif id == -11 then
        --省
        SetMapZoom(7);
    elseif id == -12 then
        --城市
        SetMapZoom(11);
    elseif id == -13 then
        --街道
        SetMapZoom(18);
    elseif id == -20 then
        --隐藏/显示按钮
        if SearchBarShow then 
            SearchBarShow=false
            SearchBar:SetActive(false)
        else 
            SearchBarShow=true
            SearchBar:SetActive(true)
        end
    elseif id == -21 then
        --放大
        local level = CurZoomLevel+1
        if level>18 then level=18 end 
        SetMapZoom(level);
    elseif id == -22 then
        --缩小
        local level = CurZoomLevel-1
        if level<3 then level=3 end
        SetMapZoom(level);
    elseif id > 0 then--点击图标
        local type = math.floor(id/10000) 
        local index = math.floor(id%10000)
        local item = IconTable[type][index]
        if type ==1 then--帮会
            if item.count > 1 then
            else
            end
        elseif type ==2 then --玩家
            if item.count > 1 then
            else
            end
            
        end 
	end
end

--更新显示
function UpdateView()
    for i=1,#IconTable do
        local icons=IconTable[i]
        if icons then
            for j=1,#icons do
                local item=icons[j]
                --item.BgSprite.atlas="UI_Gang"
                --item.IconSprite.atlas="UI_Gang"
                coordinatex=item.coordinate.x
                coordinatey=item.coordinate.y
                GlobalMapMgr.SetCoordinateToUIPosition(item.gameObject,coordinatex,coordinatey)           
                item.pos = item.gameObject.transform.localPosition
            end
        end
    end
    GlobalMapMgr.DidRender()
end

function Update()
   
end

--设置地图缩放
function SetMapZoom(level)
    CurZoomLevel=level
    GlobalMapMgr.SetZoomLevel(level)
    ZoomSlider.value = (level-ZoomMin)/(ZoomStep-1) 
end

--slider改变的参数
function OnSliderChange()
    local Endlevel= ZoomMin+ZoomSlider.value*(ZoomStep-1)
    if CurZoomLevel~=Endlevel then
        CurZoomLevel=Endlevel
        SetMapZoom(CurZoomLevel);
        GameLog.Log("OnSliderChange "..Endlevel)
    end
end

--缩放结束回调
function OnZoomEnd( endlevle )
    if  ZoomSlider.value ~= (CurZoomLevel-ZoomMin)/(ZoomStep-1) then
        ZoomSlider.value =  (CurZoomLevel-ZoomMin)/(ZoomStep-1) 
    end
    UpdateView()
end

--定位回调
function OnLocateFinished(coordinate)
    selfCoordinate= coordinate
    GetServerData()
    LocateSelf()
    Clear()
    UpdateView()
end 

--地址返回坐标回调
function OnPOIToCoordiante(info)
    local title = info.title
    local coordinate = info.coordinate
    local address = string.format( "%s-%s%s%s%s%s",title,info.province,info.city,info.district,info.street,info.street_number)
    LocateToCoordinate(coordinate)
    SetAddress(address)
    SetMapZoom(3)
end

--常见帮会回调
function OnCreateGang( gangindex )
    Exit()
end

--加入帮派回调
function OnJoinedGang( gangindex )
    Exit()
end