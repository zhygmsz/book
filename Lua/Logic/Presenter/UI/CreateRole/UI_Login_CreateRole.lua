module("UI_Login_CreateRole",package.seeall);
local LuaObjs = GameBase.LuaObjs;
local UIListViewController= require("Logic/Presenter/UI/CreateRole/UIListViewController")
--自身引用
local _self
--UI对象集合
local mUIItems = {mJobButtonUI={}}
local mSortOrder = 5
--功能信息数组 当前角色名字 种族  等
local mInfoData ={
	mCurRice = 1,
	mCurJob =1,
	mPlayerName="",
	mRiceBtnList ={},
	mJobBtnList ={},
}
local MaxRacial =3
--能力图
local mAbility ={}
local mOriginY = 0
local mPageTurnDis = nil
--创建
function OnCreate(self)
	_self = self
	MaxRacial = Common_pb.RACIAL_MAX - 1
	--获取控制对象
	local mPanel = self:Find("Offset").transform.parent.gameObject:GetComponent("UIPanel");
	mPanel.sortingOrder = mSortOrder;
	mUIItems.mRoleInfo = self:Find("Offset/TopRight/Info");
	mUIItems.mRoleInfoEffect = self:Find("Offset/TopRight/Info/effect");
	mUIItems.mRoleJobIcon = self:FindComponent("UISprite","Offset/TopRight/Info/job");
	mUIItems.mRoleNameIcon = self:FindComponent("UISprite","Offset/TopRight/Info/name");
	mUIItems.mRoleDesIcon = self:FindComponent("UISprite","Offset/TopRight/Info/des");
	mUIItems.mRoleBgIcon = self:FindComponent("UISprite","Offset/TopRight/Info/bg");
	--职业背景图
	mUIItems.mPlayerBGName = self:FindComponent("UITexture","Offset/PlayerBG/PlayerBGName")
	--种族按钮滚动
	mUIItems.mWrap = self:FindComponent("UIWrapContent","Offset/Left/RiceButtons/ScrollView/ItemWrap");
	mUIItems.mDragPanel = self:Find("Offset/Left/RiceButtons/ScrollView").transform;
	mUIItems.mScrollView = mUIItems.mDragPanel:GetComponent("UIScrollView");
	mUIItems.mScrollPanel = mUIItems.mDragPanel:GetComponent("UIPanel");
	mAbility.mChart =  self:FindComponent("RadarChart","Offset/Right/Ability/Bg/RadarChart");
	mAbility.mChartEdge =  self:FindComponent("RadarChart","Offset/Right/Ability/Bg/RadarChartEdge");
	--种族按钮
	mUIItems.mRiceButton = self:Find("Offset/Left/RiceButton");
	--种族按钮特效设置
	local effectParent = self:Find("Offset/Left/RiceButton/Pan/active/Effect");
	mUIItems.mRiceButton.gameObject:SetActive(false);
	--职业按钮
	mUIItems.mJobBtnPrefab = self:Find("Offset/BottomRight/JobBg/JobButton").gameObject;
	mUIItems.mJobBtnParent = self:Find("Offset/BottomRight/JobBg/JobButtons").gameObject;
	mUIItems.mJobBtnPrefab:SetActive(false)
	mUIItems.mGrid = mUIItems.mJobBtnParent:GetComponent("UIGrid");
	mUIItems.mInputMask =  self:Find("Offset/Left/RiceButtons/ScrollView/InputMask").gameObject;
	mUIItems.mInputMask:SetActive(false)
	mUIItems.mNextBtnEvent = self:FindComponent("UIEvent","Offset/BottomRight/NextButton")
	mUIItems.mNextBtnEvent.id = 300
	mUIItems.mRandomNameEvent = self:FindComponent("UIEvent","Offset/BottomCenter/RoleNameBg/RandomName")
	mUIItems.mRandomNameEvent.id = 400
	mUIItems.mRandomNameBgEvent = self:FindComponent("UIEvent","Offset/BottomCenter/RoleNameBg")
	mUIItems.mRandomNameBgEvent.id = 401
	--mUIItems.mNameLabel = self:FindComponent("UILabel","Offset/BottomCenter/RoleNameBg/PlaceHolder")

	mUIItems.mCreateRoleName = {}
	mUIItems.mCreateRoleName.value = ""
	--mUIItems.mCreateRoleName.inPutView = self:Find("Offset/TopCenter/InputBg")
	--mUIItems.mCreateRoleName.luaUIInput = self:FindComponent("LuaUIInput","Offset/TopCenter/InputBg/Input")
	--角色名称输入
	mUIItems.mCreateRoleName.luaUIInput= self:FindComponent("LuaUIInput","Offset/BottomCenter/RoleNameBg/RoleName")
	mUIItems.mCreateRoleName.luaUIInput.defaultText = TipsMgr.GetTipByKey("createrole_name_input_1")
	local call = EventDelegate.Callback(OnInputSubmit);
	EventDelegate.Set(mUIItems.mCreateRoleName.luaUIInput.onSubmit,call);
	local change = EventDelegate.Callback(OnInputSubmit);
	EventDelegate.Set(mUIItems.mCreateRoleName.luaUIInput.onChange,change);
	mUIItems.mCreateRoleName.luaUIInput.characterLimit = 0
	-- mUIItems.mCreateRoleName.mOkEvent = self:FindComponent("UIEvent","Offset/TopCenter/InputBg/Ok")
	-- mUIItems.mCreateRoleName.mOkEvent.id = 500
	-- mUIItems.mCreateRoleName.mCancelEvent = self:FindComponent("UIEvent","Offset/TopCenter/InputBg/Cancel")
	-- mUIItems.mCreateRoleName.mCancelEvent.id = 501
end

--注册消息
function RegEvent(self)
    mCurCamGo = LuaObjs.GameObjectFindAndReg("Main Camera_ani", true);
	if mCurCamGo < 0 then
		mCurCamGo = LuaObjs.GameObjectFindAndReg("Main Camera", true);
	end
	local mainCam = LuaObjs.GetComponent(mCurCamGo, typeof(UnityEngine.Camera));
	TouchMgr.SetTouchEventEnable(true)
	TouchMgr.SetListenOnSwipe(UI_Login_CreateRole,true);
	TouchMgr.SetListenOnPinch(UI_Login_CreateRole,true);
	GameEvent.Reg(EVT.COMMON,EVT.APPPAUSE,OnApplicationPause);
	GameEvent.Reg(EVT.COMMON,EVT.APPBACK,OnApplicationPause);
	GameEvent.Reg(EVT.COMMON,EVT.APPRESUME,OnApplicationFocus);
end

--去除注册
function UnRegEvent(self)
	TouchMgr.SetListenOnSwipe(UI_Login_CreateRole,false);
	TouchMgr.SetListenOnPinch(UI_Login_CreateRole,false);
	GameEvent.UnReg(EVT.COMMON,EVT.APPPAUSE,OnApplicationPause);
	GameEvent.UnReg(EVT.COMMON,EVT.APPBACK,OnApplicationPause);
	GameEvent.UnReg(EVT.COMMON,EVT.APPRESUME,OnApplicationFocus);
end

function OnEnable(self)   
		RegEvent(self);
		if mUIItems.listView then
			local item = mUIItems.listView:GetItemAtIndex(1)
			if item then 
				item.cell.toggle:Set(true,true)
			end
		end
		--mUIItems.mCreateRoleName.inPutView.gameObject:SetActive(false)
		GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_RADNOMNAME);
end

function OnDisable(self)
	UnRegEvent(self);
	Clean()
end

function SetRacialData(datas)
	BuildRiceButtons()
	mUIItems.listView:SetDatas(datas)
	mUIItems.listView:UpdateItems()
end

function BuildRiceButtons()
	local function OnCellUpdate(item,data)
        CellUpdate(item,data)
	end
	local function ScrollViewDragStart(item,data)
        OnScrollViewDragStart(item,data)
	end
	local function ScrollViewDragging(item,data)
        OnScrollViewDragging(item,data)
	end
	local function ScrollViewStoppped(item,data)
        OnScrollViewStoppped(item,data)
	end
	if mUIItems.listView==nil then
		mUIItems.listView = UIListViewController.new(_self,mUIItems.mRiceButton,mUIItems.mWrap,mUIItems.mScrollPanel,mUIItems.mScrollView,-1,OnCellUpdate,ScrollViewDragStart,ScrollViewDragging,ScrollViewStoppped,true,6)
		mUIItems.listView:InitItems()
	end
end
--新建种族按钮
function NewRiceButton(self,prefab,parent,index)
    local item = {};
    item.index = index;
    item.gameObject = self:DuplicateAndAdd(prefab.transform,parent.transform,index).gameObject;
    item.gameObject.name = tostring(10000 + index);
    item.transform = item.gameObject.transform;
    item.activeHead = item.transform:Find("Pan/active/head"):GetComponent("UITexture");
    item.deActiveHead = item.transform:Find("Pan/deactive/head"):GetComponent("UITexture");
	item.activeName = item.transform:Find("Pan/active/nameIcon"):GetComponent("UISprite");
	item.uiEvent= item.transform:GetComponent("GameCore.UIEvent");
	item.toggle = item.transform:GetComponent("UIToggle");
	item.effectParent =  item.transform:Find("Pan/active/Effect");
	item.mPan =  item.transform:Find("Pan");
	item.toggle.startsActive = index==1
	item.gameObject:SetActive(true);
    return item;
end

--新建职业按钮
function NewJobButton(self,prefab,parent,index)
    local item = {};
    item.index = index;
    item.gameObject = self:DuplicateAndAdd(prefab.transform,parent.transform,index).gameObject;
    item.gameObject.name = string.format( "JobButton%d",index);
    item.transform = item.gameObject.transform;
	item.onImage = item.transform:Find("active/icon"):GetComponent("UISprite");
	item.onName= item.transform:Find("active/name_img"):GetComponent("UISprite");
	item.onNameStr= item.transform:Find("active/name"):GetComponent("UILabel");
	item.offImage = item.transform:Find("deactive/icon"):GetComponent("UISprite");
	item.offName= item.transform:Find("deactive/name_img"):GetComponent("UISprite");
	item.offNameStr= item.transform:Find("deactive/name"):GetComponent("UILabel");
	item.toggle = item.transform:GetComponent("UIToggle");
	item.uiEvent= item.transform:GetComponent("GameCore.UIEvent");
	item.box = item.transform:GetComponent("BoxCollider");
	item.toggle.startsActive = index==1
    item.gameObject:SetActive(true);
    return item;
end

--根据角色选择重新设置人物显示和角色姓名
function SetAllJobButton(mJobBtnList,choose)
	local RCount=#mJobBtnList
	local maxN = math.max(RCount,table.getn(mUIItems.mJobButtonUI))
	for i = 1, maxN do
		if i<=RCount then
			if mUIItems.mJobButtonUI[i]==nil then
				local btn = NewJobButton(_self,mUIItems.mJobBtnPrefab,mUIItems.mJobBtnParent,i)
				mUIItems.mJobButtonUI[i]=btn
				btn.uiEvent.id = 100+i
				btn.gameObject:SetActive(true)
			end
			local res = mJobBtnList[i]
			local jobButton = mUIItems.mJobButtonUI[i]
			if res and jobButton then
				jobButton.onImage.spriteName =  string.format("%s_2",res.professionIcon)  
				jobButton.offImage.spriteName =res.professionIcon
				jobButton.onName.spriteName = res.professionNameIcon
				jobButton.offName.spriteName = res.professionNameIcon
				if i==choose then
					jobButton.toggle:Set(true)
				end
				jobButton.gameObject:SetActive(true)
				jobButton.onImage:MakePixelPerfect()
				jobButton.offImage:MakePixelPerfect()
				jobButton.box.enabled = not res.unOpen
			end
		else
			if mUIItems.mJobButtonUI[i] then
				mUIItems.mJobButtonUI[i].gameObject:SetActive(false)
			end
		end
	end
	mUIItems.mGrid:Reposition()
end

--设置角色信息
function setRoleInfo(nameImg,professionNameIcon,desIcon,proAtt,bgname,resId)
	mUIItems.mRoleJobIcon.spriteName = professionNameIcon;
	mUIItems.mRoleNameIcon.spriteName = nameImg;
	mUIItems.mRoleDesIcon.spriteName = desIcon;
	mUIItems.mRoleBgIcon.spriteName = bgname;
	if not mUIItems.mRoleEffectLoader then mUIItems.mRoleEffectLoader = LoaderMgr.CreateEffectLoader(); end
	mUIItems.mRoleEffectLoader:LoadObject(resId);
	mUIItems.mRoleEffectLoader:SetParent(mUIItems.mRoleInfoEffect.transform,true);
	mUIItems.mRoleEffectLoader:SetSortOrder(10);
	mUIItems.mRoleEffectLoader:SetActive(true,true);

	if mAbility.mChart.sides ~= 5 then
		mAbility.mChart:SetSides(5)
	end
	if proAtt == nil then  proAtt = {life=0, attack=0, difficulty=0, dominate=0, assist=0 } end
	mAbility.mChart:SetVerticesDistance({proAtt.life/10.0,proAtt.attack/10.0,proAtt.difficulty/10.0,proAtt.dominate/10.0,proAtt.assist/10.0})
	if mAbility.mChartEdge.sides ~= 5 then
		mAbility.mChartEdge:SetSides(5)
	end
	mAbility.mChartEdge:SetVerticesDistance({proAtt.life/10.0,proAtt.attack/10.0,proAtt.difficulty/10.0,proAtt.dominate/10.0,proAtt.assist/10.0})
	mAbility.mChart:FillAllPoints();
	local resId = 400400091
	if mAbility.mEffects ==  nil then mAbility.mEffects = {} end
	for i = 1,5 do
		local pos = mAbility.mChart:GetCornerPoints(i-1)
		if mAbility.mEffects[i] == nil then
			local effectLoader = LoaderMgr.CreateEffectLoader();
			effectLoader:LoadObject(resId);
			effectLoader:SetParent(mAbility.mChart.transform,true);
			effectLoader:SetLocalPosition(pos);
			effectLoader:SetSortOrder(10);
			effectLoader:SetActive(true);
			mAbility.mEffects[i] = effectLoader;
		else
			local effectLoader = mAbility.mEffects[i];
			effectLoader:SetLocalPosition(pos);
			effectLoader:SetActive(true,true);
		end
	end
end 

function CellUpdate(item,data)
	if item.cell==nil then
		item.cell={}
		item.cell.activeHead = item.transform:Find("Pan/active/head"):GetComponent("UITexture");
		item.cell.deActiveHead = item.transform:Find("Pan/deactive/head"):GetComponent("UITexture");
		item.cell.activeName = item.transform:Find("Pan/active/nameIcon"):GetComponent("UISprite");
		item.cell.uiEvent= item.transform:GetComponent("GameCore.UIEvent");
		item.cell.toggle = item.transform:GetComponent("UIToggle");
		item.cell.box = item.transform:GetComponent("BoxCollider");
		item.cell.effectParent =  item.transform:Find("Pan/active/Effect");
		item.cell.mPan =  item.transform:Find("Pan");
		item.cell.toggle.startsActive = item.dataIndex==1
	end
 
	item.cell.uiEvent.id = 10+item.dataIndex;
	item.cell.activeName.spriteName = data.unOpen and "" or data.nameIcon
	item.cell.box.enabled = not data.unOpen
	UIUtil.SetTexture(data.headIcon,item.cell.activeHead,true)
	UIUtil.SetTexture(data.headIcon,item.cell.deActiveHead,true)
end


function OnScrollViewDragStart(mDragPanel,mWrapGrids)
	mOriginY = mDragPanel.transform.localPosition.y
end

function OnScrollViewDragging(mDragPanel,mWrapGrids)
	local count = mDragPanel.transform.localPosition.y/108
	count = count>4 and 4 or count
	count = count<0 and 0 or count
	count = math.abs(count)
	for i=1,#mWrapGrids do
		local item = mWrapGrids[i];
		local size = (item.dataIndex- count-3.5)
		local f = size / 5
		local rate = 0.5 - math.abs(f)
		local x = math.BezierAt(-125,8,8,0,rate)
		if item.cell then
			item.cell.mPan.localPosition = Vector3(x,0,0)
		end
	end
end

local function GetPageTurnDistance()
	if mPageTurnDis == nil then 
		mPageTurnDis = ConfigData.GetIntValue("createrole_pageturn_distance") or 50
	end
end

function OnScrollViewStoppped(mDragPanel,mWrapGrids)
	GetPageTurnDistance()
	local cha = mDragPanel.transform.localPosition.y - mOriginY
	if cha>mPageTurnDis then
		 mUIItems.listView:PageDown()
	elseif cha<-1*mPageTurnDis then
		mUIItems.listView:PageUp()
	end
	local count = math.floor(math.abs(mDragPanel.transform.localPosition.y/108)+0.5)
	count = math.floor(count)
	mDragPanel.clipOffset = Vector2(0,-1*count*108)
	mDragPanel.transform.localPosition = Vector3(0,count*108,0)
	OnScrollViewDragging(mDragPanel,mWrapGrids)
end

--==============================--
--手势处理
--==============================--
--拉进camera
function OnPinchIn(gesture)
	GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_PINCHINCAMERA,gesture);
end

--拉远camera
function OnPinchOut(gesture)
	GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_PINCHOUTCAMERA,gesture);
end

--转动
function OnSwipe(gesture)
	 if gesture.touchCount == 1 then
		GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_ROTATEROLE,gesture);
	 end
end

--点击模型
function  ClickModel(gameObject)
end

--清理内存 
function Clean()
	for k,loader in pairs(mAbility.mEffects) do LoaderMgr.DeleteLoader(loader) end
	table.clear(mAbility.mEffects);
	mInfoData.mPlayerName = "";
	mUIItems.mCreateRoleName.value=mInfoData.mPlayerName
	UIUtil.CleanTextureCache()
end

--随机名称
function SetInputName(name)
	mUIItems.mCreateRoleName.value = name
	mUIItems.mCreateRoleName.luaUIInput.value = name
	--mUIItems.mNameLabel.text = name
	if mUIItems.mCreateRoleName.value == "" then
		mUIItems.mCreateRoleName.value = TipsMgr.GetTipByKey("createrole_name_input_1")
	end
end

function OnApplicationPause()
	-- if mUIItems.mCreateRoleName.inPutView.gameObject.activeSelf == true then
	-- 	mUIItems.mCreateRoleName.inPutView.gameObject:SetActive(false)
	-- end
end

function OnApplicationFocus()
	-- if mUIItems.mCreateRoleName.inPutView.gameObject.activeSelf == true then
	-- 	mUIItems.mCreateRoleName.inPutView.gameObject:SetActive(false)
	-- end
end

function OnInputSubmit()
	mUIItems.mCreateRoleName.value = mUIItems.mCreateRoleName.luaUIInput.value
	OnInputChange()
	--mUIItems.mCreateRoleName.inPutView.gameObject:SetActive(false)
end

function OnInputChange()
	GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_CHANGENAME,mUIItems.mCreateRoleName.value);
end

local mInputLock = false

function LockInput(enable)
	UIMgr.LockEvent(AllUI.UI_Login_CreateRole,-1,enable)
	mInputLock = enable
	if mUIItems.mInputMask then
		mUIItems.mInputMask:SetActive(enable)
	end
end

function OnClick(go,id)
	if mInputLock==false then
		if id >= 11 and id <= 100 then
			local tCurRice = id-10;
			mUIItems.listView:OnSelect(tCurRice)
			GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_CHANGERICE,tCurRice);
		elseif id >= 101 and id <= 200 then
			local tCurJob = id-100;
			GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_CHANGEPRO,tCurJob);
		elseif id == 0  then
			GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_CLOSE);
			--退出
		elseif id == 300  then
			--创建角色
			GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_CREATE,mUIItems.mCreateRoleName.value);
		elseif id == 400  then
			--随机名称
			GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_RADNOMNAME);
		elseif id == 401  then
			--点击输入输入 弹出输入UI
			--mUIItems.mCreateRoleName.luaUIInput.value = mUIItems.mCreateRoleName.value 
			--mUIItems.mCreateRoleName.inPutView.gameObject:SetActive(true)
			--mUIItems.mCreateRoleName.luaUIInput:Select()
		elseif id == 500  then
			--确定输入姓名
			OnInputSubmit()
		elseif id == 501  then
			--取消输入姓名
			--mUIItems.mCreateRoleName.inPutView.gameObject:SetActive(false)
		end
	end
end