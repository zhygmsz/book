module("UI_PersonalSpace_HeadIcon", package.seeall);

local mCurSelectIndex = 1
local _self = nil
local mLastBtn = nil
local mNextBtn = nil
local mViewer = nil
local mTweener = nil
local mTable = nil
local mViewItem = nil
local mChoosePhoto = nil
local mButtonTable =nil
local mSetDefaultBtn = nil
local mDeleteBtn = nil
local mDefaultIcon = nil
local mViewGrids={}
local mImageDatas =nil
local mPlayerInfo = nil
local mShowMode = 2 -- 显示模式2是自己 1 是别人
local mLikeCount = nil
local mViewCount = nil
local mShowIndex = 1
local mViewerDefault = nil
local mSelectIcon = nil

function OnCreate(self)
    _self=self
    mViewer = self:FindComponent("UITexture", "Offset/Viewer");
    mTable = self:FindComponent("UITable", "Offset/ImageList/Table");
    mChoosePhoto =  self:Find("Offset/PhotoBtn");
    mChoosePhoto.gameObject:SetActive(false)
    mButtonTable = self:FindComponent("UITable", "Offset/PhotoBtn/ButtonPad");
    mSetDefaultBtn =  self:Find("Offset/PhotoBtn/ButtonPad/setDefault");
    mDeleteBtn =  self:Find("Offset/PhotoBtn/ButtonPad/delete");
    mDefaultIcon =  self:Find("Offset/DefaultIcon");
    mViewItem = self:Find("Offset/ViewItem");
    mViewerDefault= self:Find("Offset/Viewer/Default");
	mTweener = mViewer.gameObject:AddComponent(typeof(TweenScale))
	mLastBtn = self:Find("Offset/Last");
    mNextBtn = self:Find("Offset/Next");
    mLikeCount = self:FindComponent("UILabel", "Offset/Like/Label");
    mViewCount = self:FindComponent("UILabel", "Offset/View/Label");
    mSelectIcon =  self:Find("Offset/SelectIcon");
	local function OnTweenFinish()
		mTweener.enabled = false
    end

    local finishFunc = EventDelegate.Callback(OnTweenFinish)
	EventDelegate.Set(mTweener.onFinished, finishFunc)
	
	for i=1,3 do
        mViewGrids[i] = AddViewItem(i)
    end
    mViewItem.gameObject:SetActive(false)
    mTable:Reposition()
end

function AddViewItem(index)
	local item = {};
	item.index = index;
	item.gameObject = _self:DuplicateAndAdd(mViewItem, mTable.transform, index).gameObject;
	item.gameObject.name = tostring(10000 + index);
	item.transform = item.gameObject.transform;
	item.texture = item.transform:GetComponent("UITexture");
    item.uiEvent = item.transform:GetComponent("UIEvent");
    item.uiEvent.id =10000 + index;
	item.gameObject:SetActive(true);
	return item;
end

local mEvents = {};
function RegEvent(self)
    --UpdateBeat:Add(Update,self);
    GameEvent.Reg(EVT.PSPACE,EVT.PS_SETPLAYERINFO,PlayerInfoSetted);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_SETPLAYERINFO,PlayerInfoSetted);
	mEvents = {};
	--UpdateBeat:Remove(Update,self);
end

function OnEnable(self)
    RegEvent(self);
    if mShowMode==2 then
        mPlayerInfo = PersonSpaceMgr.GetSelfPlayerInfo()
        mImageDatas = mPlayerInfo:GetPhotoWall()
    end
	ShowBtns()
    MoveToIndex(mShowIndex)
	UpdateView()
end

function OnDisable(self)
	UnRegEvent(self);
end

function onDestroy(self)
	--ClearLoaders()
end


--刷险背包界面显示
function UpdateView()
    mDefaultIcon.transform.gameObject:SetActive(false)
    if mShowMode==2 then
        for i=1,#mViewGrids do
            mViewGrids[i].texture.mainTexture = nil
        end
        mTable.transform.gameObject:SetActive(true)
        for i=1,#mImageDatas do
            --添加默认头像图标
            local headid = mPlayerInfo:GetHeadIcon()
            if  headid == mImageDatas[i].photoid then
                mDefaultIcon.parent = mViewGrids[i].transform
                mDefaultIcon.localPosition = Vector3.zero
                mDefaultIcon.transform.gameObject:SetActive(true)
            end
            PersonSpaceMgr.LoadHeadIcon(mViewGrids[i].texture,mPlayerInfo:GePhotoURLByPhotoId(mImageDatas[i].photoid))
        end
    else
        mTable.transform.gameObject:SetActive(false)
    end
    local choosePhoto = mImageDatas[mCurSelectIndex]
    mLikeCount.text = choosePhoto and tostring(choosePhoto.likecnt) or ""
    mViewCount.text =choosePhoto and  tostring(choosePhoto.viewcnt) or ""
end

function ShowButtonPad(show)
    local item = mImageDatas[mCurSelectIndex]
    mChoosePhoto.gameObject:SetActive(show)
    mChoosePhoto.parent = mViewGrids[mCurSelectIndex].transform
    mChoosePhoto.localPosition = Vector3.zero
    local headid = mPlayerInfo:GetHeadIcon()
    mSetDefaultBtn.gameObject:SetActive( (item and (headid ~= item.photoid)) and true or false)
    mDeleteBtn.gameObject:SetActive(item and true or false)
    mButtonTable:Reposition()
end

function ReplyViewTween(index)
    if mImageDatas[index] then
        PersonSpaceMgr.LoadHeadIcon(mViewer, mPlayerInfo:GePhotoURLByPhotoId(mImageDatas[index].photoid))
        mTweener.enabled = true
        mTweener.from = Vector3.zero
        mTweener.to = Vector3.one
        mTweener.duration = 0.3
        mTweener:ResetToBeginning()
        mTweener:PlayForward()
    end
end

function ShowBtns()
	local max = table.getn(mImageDatas)
	if max>=1 then
		mShowIndex = Mathf.Clamp(mShowIndex,1,max)
		mLastBtn.gameObject:SetActive(mShowIndex>1)
		mNextBtn.gameObject:SetActive(mShowIndex<max)
    end
    local headid = mPlayerInfo:GetHeadIcon()
    if mImageDatas[mShowIndex] and mImageDatas[mShowIndex].photoid then
        mViewerDefault.transform.gameObject:SetActive(headid == mImageDatas[mShowIndex].photoid)
    else
        mViewerDefault.transform.gameObject:SetActive(false)
    end
    mSelectIcon.parent = mViewGrids[mShowIndex].transform
    mSelectIcon.localPosition = Vector3.zero
    mSelectIcon.transform.gameObject:SetActive(true)
end

function MoveToIndex(index)
	ReplyViewTween(index)
end

function ClickLast()
	mShowIndex =mShowIndex - 1
	ShowBtns()
	MoveToIndex(mShowIndex)
end

function ClickNext()
	mShowIndex = mShowIndex + 1
	ShowBtns()
	MoveToIndex(mShowIndex)
end

function PlayerInfoSetted(playerid)
    if mShowMode==2 then
        mPlayerInfo = PersonSpaceMgr.GetSelfPlayerInfo()
        mImageDatas = mPlayerInfo:GetPhotoWall()
    end
    ShowBtns()
    MoveToIndex(mShowIndex)
    UpdateView()
end

function OnUpLoadFinished(url,localPath)
    if url == nil then

    else
        local dest = string.split(url,".com/")
        if dest and #dest==2 then
            local path =string.format("%s.com/",dest[1])
            local name = dest[2]
            PersonSpaceMgr.LoadHeadIcon(mViewGrids[mCurSelectIndex].texture,url)
            mPlayerInfo:AddPhoto(name,name,name,0,-1)
        end
    end
end

function OnPhotoFinish(path)
    GameLog.Log("OpenPhotoLibrary "..path)
    PersonSpaceMgr.UpLoadHeadIcon(path,OnUpLoadFinished)
end

function OnClick(go, id)
   if id>=10000 then
        local index = id - 10000    
        local item = mViewGrids[index];
        mCurSelectIndex =index;
        ShowButtonPad(true)
    elseif id == -20 then--拍照
        PersonSpaceMgr.ChooseHeadImage(true,OnPhotoFinish,_self)
        ShowButtonPad(false)
    elseif id== -21 then --选取照片
        PersonSpaceMgr.ChooseHeadImage(false,OnPhotoFinish,_self)
        ShowButtonPad(false)
    elseif id== -22 then --设置为默认
        ShowButtonPad(false)
        if mImageDatas[mCurSelectIndex] ~=  nil then
            local pid = mImageDatas[mCurSelectIndex].photoid
            mPlayerInfo:SaveHeadIcon(pid,true)
        end
    elseif id== -23 then --删除
        if mImageDatas[mCurSelectIndex] ~=  nil then
            local pid = mImageDatas[mCurSelectIndex].photoid
            mPlayerInfo:DelPhoto({tonumber(pid)})
        end
        ShowButtonPad(false)
        UpdateView()
   elseif id == -1000 then
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_HeadIcon)
    elseif id == -2000 then
		ShowButtonPad(false)
	elseif id == -1 then
		ClickLast()
	elseif id == -2 then
		ClickNext()
   end
end

return UI_PersonalSpace_HeadIcon