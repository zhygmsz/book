module("UI_PersonalSpace_Moments",package.seeall)
local PS_MomentViewController= require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/PS_MomentViewController")
--空内容视图
local mEmptyView=nil
--朋友圈预制体
local mZoneItem = nil
--tablewrap组件
local mZoneWrap = nil
--最大实例化item数量
local MAX_ITEM_COUNT = 4
--实例化的wrapitem数组
local mZoneWrapItems = {}
--实例化回调
local mZoneWrapCall = nil
local mDragPanel
local mScrollPanel
local mScrollView
--显示模式  1我看别人 2我看自己的全部
local mShowMode = 2
local mPlayerId = -1
local mViewController = nil

function OnCreate(self)
    mEmptyView=self:Find("Mid/ZoneView/EmptyView").gameObject
    local mEmptyViewTip=self:FindComponent("UILabel","Mid/ZoneView/EmptyView/Sprite/tip")
    mEmptyViewTip.text = TipsMgr.GetTipByKey("personspace_background_default")
    mZoneItem = self:Find("Mid/ZoneView/ZoneItemParent/ScrollView/TableWrap/ZoneItem").gameObject;
    mZoneWrap = self:FindComponent("UITableWrapContent","Mid/ZoneView/ZoneItemParent/ScrollView/TableWrap");
    mDragPanel =  self:Find("Mid/ZoneView/ZoneItemParent/ScrollView");
    mScrollView =  self:FindComponent("UIScrollView","Mid/ZoneView/ZoneItemParent/ScrollView");
    mScrollPanel = mDragPanel:GetComponent("UIPanel");
    mScrollPanel.clipOffset= Vector2.zero
    mScrollPanel.transform.localPosition= Vector3.zero
   
    local mBtnFavorLabel = self:FindComponent("UILabel","Mid/ZoneView/ZoneItemParent/ScrollView/TableWrap/ZoneItem/Bg/Buttons/BtnFavor/Label");
    mBtnFavorLabel.text = TipsMgr.GetTipByKey("personspace_moment_dianzan")

    local mBtnCommentLabel = self:FindComponent("UILabel","Mid/ZoneView/ZoneItemParent/ScrollView/TableWrap/ZoneItem/Bg/Buttons/BtnComment/Label");
    mBtnCommentLabel.text = TipsMgr.GetTipByKey("personspace_moment_pinglun")

    local mBtnGiftLabel = self:FindComponent("UILabel","Mid/ZoneView/ZoneItemParent/ScrollView/TableWrap/ZoneItem/Bg/Buttons/BtnGift/Label");
    mBtnGiftLabel.text = TipsMgr.GetTipByKey("personspace_moment_songli")

    local onPullstart = UIScrollView.OnPullNotification(OnPullstart)
    local onPulling = UIScrollView.OnPullNotification(OnPulling)
    local onPullend = UIScrollView.OnPullNotification(OnPullend)
    mScrollView.onPullingStarted = onPullstart
    mScrollView.onPullingMoving = onPulling
    mScrollView.onPullingEnded = onPullend
    mViewController = PS_MomentViewController.new(
        {_ui=self,
        _itemPrefab=mZoneItem,
        _tableWrap=mZoneWrap,
        _scrollPanel=mScrollPanel,
        _scrollView=mScrollView,
        _maxCellcont=MAX_ITEM_COUNT},mPlayerId,mShowMode)
end

function OnEnable(self,playerid,mode)
    RegEvent(self)
    SetPlayerId(playerid)
    SetShowMode(mode)
    UpdateView()
end

function OnDisable(self)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PSPACE,EVT.PS_UPDATEMOMENTS,MomentsUpdated);
    GameEvent.Reg(EVT.PSPACE,EVT.PS_COMMENTUPDATE,CommentUpdated);
    GameEvent.Reg(EVT.PSPACE,EVT.PS_LIKEUPDATE,LikeUpdated);
    GameEvent.Reg(EVT.PSPACE,EVT.PS_DELETECOMMENT,DeleteComment);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_UPDATEMOMENTS,MomentsUpdated);
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_COMMENTUPDATE,CommentUpdated);
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_LIKEUPDATE,LikeUpdated);
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_DELETECOMMENT,DeleteComment);
    mEvents = {};
end

--下拉更新或加载更多
function OnPullstart(amount)
    GameLog.Log(amount) 
end

function OnPulling(amount)
end

function OnPullend(amount)
end

function GetVieWcontroller()
    if mViewController then
        return mViewController
    end
end

function SetPlayerId(pid)
    mPlayerId = pid
    if mViewController then mViewController:SetPlayerId(pid) end
end

--mShowMode = 2正常模式  1只显示一个人的
function SetShowMode(mode)
    mShowMode = mode
    GetVieWcontroller():SetShowMode(mode)
end

--朋友圈更新
function MomentsUpdated(playerid,momentdata,showmode)
    mPlayerId = playerid
    SetShowMode(showmode)
    UpdateView()
end

--朋友圈更新
function CommentUpdated(mmtid,dataIndex)
    GetVieWcontroller():ReLayout(mmtid,dataIndex)
end

function DeleteComment(mmtid,cmtid,dataIndex)
    GetVieWcontroller():ReLayout(mmtid,dataIndex)
end

--朋友圈更新
function LikeUpdated(mmtid,dataIndex)
    GetVieWcontroller():ReLayout(mmtid,dataIndex)
end

function UpdateView()
    GetVieWcontroller():UpdateData(mPlayerId)
    GetVieWcontroller():UpdateView()
    local mcnt = GetVieWcontroller():GetDataCount()
    mEmptyView:SetActive(mcnt<=0)
end
 
function OnClick(go, id)
    --点击了朋友圈
    GetVieWcontroller():ClickItem(go,id)
end