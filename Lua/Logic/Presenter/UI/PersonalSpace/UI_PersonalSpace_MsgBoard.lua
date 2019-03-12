module("UI_PersonalSpace_MsgBoard",package.seeall)
local JSON = require("cjson")
local UITableListViewController= require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/UITableListViewController")
local UIRichInputViewController= require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/UIRichInputViewController")
local MAX_WRAPITEM_COUNT = 7
local mDragPanel;
--全部格子数据数组
local mItemDatas = {"1","2","3","4","5","6","7","8","9","10"};
--当前选中格子
local mCurSelectIndex = - 1;
local mCurSelectItem = nil;
local mMsgInput = nil
local mlistView = nil
local _self=nil 

local mBtnMeet = nil
local mStepOn = nil
local mPopularity = {}
local mGift = {}
local mAchieve = {}

function OnCreate(self)
	_self = self
    local itemPrefab = self:Find("Mid/BoardView/MsgItem");
	mWrap = self:FindComponent("UITableWrapContent", "Mid/BoardView/ItemParent/ScrollView/ItemWrap");
	mDragPanel = self:Find("Mid/BoardView/ItemParent/ScrollView").transform;
	local mScrollView = mDragPanel:GetComponent("UIScrollView");
	local mScrollPanel = mDragPanel:GetComponent("UIPanel");

	mBtnMeet = self:Find("Mid/BoardView/BtnMeet").gameObject;
	mStepOn = self:FindComponent("UISprite","Mid/BoardView/BtnStepOn");

	mPopularity.num = self:FindComponent("UILabel","Mid/BoardView/Popularity/Num");
	mGift.num = self:FindComponent("UILabel","Mid/BoardView/Gift/Num");
	mAchieve.num = self:FindComponent("UILabel","Mid/BoardView/Achieve/Num");
	
	itemPrefab.gameObject:SetActive(false);
	mlistView = UITableListViewController.new(self,itemPrefab.gameObject,mWrap,mScrollPanel,mScrollView,MAX_WRAPITEM_COUNT,CellUpdate,UITableWrapContent.Align.Top,UITableWrapContent.Align.Bottom)
	mlistView:InitItems()

	local EditorView = self:Find("Mid/BoardView/EditorView").gameObject;
	local BtnBack = self:Find("Mid/BoardView/EditorView/BtnBack");
	local BtnLook = self:Find("Mid/BoardView/EditorView/BtnLook");
	local BtnReply = self:Find("Mid/BoardView/EditorView/BtnReply");
	local Input = self:Find("Mid/BoardView/EditorView/MsgView/Input");
	local panel = self:Find("Mid/BoardView/EditorView/MsgView");
	--,defaulttext,commonLinkOpenType,sendCallback,callObj,hiddenPos,showPos
	mMsgInput = UIRichInputViewController.new(EditorView,panel,BtnBack,BtnLook,BtnReply,Input,
	TipsMgr.GetTipByKey("personspace_reply_default"),
	ChatMgr.CommonLinkOpenType.FromPersonSpace,
	OnSendMsg,nil,
	Vector3(1252,-232,0),Vector3(178,-232,0))
	mMsgInput:SetBtnEventId(-4,-5,-6)
	mMsgInput:SetInputLimit(85)
end

function OnEnable(self)
	RegEvent(self)
	local playerid = PersonSpaceMgr.GetCurrentShowPlayerId()
	PersonSpaceMgr.AskHeroMessageBoard(playerid,0,200)
	PersonSpaceMgr.AskPopularity(playerid)
end

function OnDisable(self)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
	GameEvent.Reg(EVT.PSPACE,EVT.PS_ASKMSGBOAR,MsgBoardUpdated);
	GameEvent.Reg(EVT.PSPACE,EVT.PS_ADDMS,MsgAdded);
	GameEvent.Reg(EVT.PSPACE,EVT.PS_DELMS,OnDelMsg);
	GameEvent.Reg(EVT.PSPACE,EVT.PS_ASKPOP,OnAskPopularity);
	GameEvent.Reg(EVT.PSPACE,EVT.PS_ADDPOP,OnAddPopularity);
end

function UnRegEvent(self)
	GameEvent.UnReg(EVT.PSPACE,EVT.PS_ASKMSGBOAR,MsgBoardUpdated);
	GameEvent.UnReg(EVT.PSPACE,EVT.PS_ADDMS,MsgAdded);
	GameEvent.UnReg(EVT.PSPACE,EVT.PS_DELMS,OnDelMsg);
	GameEvent.UnReg(EVT.PSPACE,EVT.PS_ASKPOP,OnAskPopularity);
	GameEvent.UnReg(EVT.PSPACE,EVT.PS_ADDPOP,OnAddPopularity);
    mEvents = {};
end

function CellUpdate(item,data)
	if item.init==nil then
		item.widget = item.transform:GetComponent("UIWidget");
		item.bg = item.transform:Find("Bg"):GetComponent("UISprite");
		item.icon = item.transform:Find("Content/Icon"):GetComponent("UITexture");
		item.defaulticon = item.transform:Find("Content/Default"):GetComponent("UISprite");
		item.name = item.transform:Find("Content/Name"):GetComponent("UILabel");
		item.tag = item.transform:Find("Content/Tag"):GetComponent("UISprite");
		item.time = item.transform:Find("Content/Time"):GetComponent("UILabel");
		item.content = item.transform:Find("Content/Content"):GetComponent("UILabel");
		item.level = item.transform:Find("Content/Des"):GetComponent("UILabel");
		item.server = item.transform:Find("Content/Des2"):GetComponent("UILabel");
		item.gift={}
		item.gift.obj = item.transform:Find("Content/Gift").gameObject
		item.gift.icon = item.transform:Find("Content/Gift/Icon"):GetComponent("UISprite");
		item.gift.num = item.transform:Find("Content/Gift/Num"):GetComponent("UILabel");
		item.removeBtn={}
		item.removeBtn.uiEvent = item.transform:Find("Content/RemoveBtn"):GetComponent("GameCore.UIEvent");
		item.replyBtn={}
		item.replyBtn.uiEvent = item.transform:Find("Content/ReplyBtn"):GetComponent("GameCore.UIEvent");
		item.uiEvent = item.transform:GetComponent("GameCore.UIEvent");
		item.uiEvent.id = item.index
		item.removeBtn.uiEvent.id = item.index*10000+1
		item.replyBtn.uiEvent.id = item.index*10000+2
		item.init =true
	end
	if item and data then
		SocialPlayerInfoMgr.GetPlayerInfoById(data.sender_id,function (playerid,playerInfo)
			if playerInfo then
				item.name.text = playerInfo:GetNickName()
				item.level.text = string.format("LV:%d",playerInfo:GetLevel())
				item.server.text = playerInfo:GetServerId()
				playerInfo:SetHeadIcon(item.icon,item.defaulticon)
			end
		end)
		item.content.text =""-- data.content
		--local commonmsgstr = string.FromBase64(data.frec) or ""
		local msgCommon = Chat_pb.ChatMsgCommon()
		--msgCommon:ParseFromString(commonmsgstr)
		local msg = JSON.decode(data.frec);
		msgCommon.content =msg.c  
		item.time.text = TimeUtils.FormatTime(tonumber(msg.t),1,false)
		TextHelper.ProcessItemCommon(_self,
		item,
		msgCommon.content,
		item.content.transform,
		item.content.width,
		0,
		true,
		msgCommon.links, nil, nil, nil, nil)
		item.widget.height = 80+ item.curHeight --item.content.height
		item.gift.icon.spriteName = msg.g ==1 and "icon_pengyouquan_meili" or "icon_pengyouquan_meili"
		item.gift.num.text = tostring(msg.n and msg.n or 0)
		item.gift.obj:SetActive(msg.n and msg.n>0 or false)
		if item.dataIndex == mCurSelectIndex then
			item.bg.spriteName = "button_common_07"
		else 
			item.bg.spriteName = "button_common_06"
		end
	end
end

function MsgBoardUpdated(playerid,data)
	mItemDatas = data
	SocialPlayerInfoMgr.GetPlayerInfoById(playerid,function (playerid,playerInfo)
		if playerInfo then
			local mm= not playerInfo:IsSelf() 
			if mm then mm = playerInfo:GetFriendCom():IsFriend() end
			mBtnMeet:SetActive(mm)
		end
	end)
	UpdateView()
end

function MsgAdded(playerid,content)
	local playerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    PersonSpaceMgr.AskHeroMessageBoard(playerid,0,200)
end


function OnAskPopularity(target,popularity,pop_clked)
	mStepOn.spriteName = pop_clked==0 and "button_common_08" or "frame_common_20"
	mPopularity.num.text =tostring(popularity)
end

function OnAddPopularity(target,popularity)
	mStepOn.spriteName = "frame_common_20"
	mPopularity.num.text =tostring(popularity)
end

function UpdateView()
	if mlistView then
		mlistView:SetDatas(mItemDatas)
		UpdateItems()
	end
end

function ReLayout()
    mlistView:ReLayout()
end

--更新列表
function UpdateItems()
    mlistView:UpdateItems()
end

function OnSendMsg(msgCommon)
	local commonmsgstr =msgCommon.content 
	--local sender_id = mCurSelectIndex>0 and mItemDatas[mCurSelectIndex].sender_id or nil
	if mCurSelectItem then
		commonmsgstr = string.format("对%s说:%s",item.name.text,msgCommon.content)
	end
	local playerid = PersonSpaceMgr.GetCurrentShowPlayerId()
	-- string.ToBase64(msg) or ""
	local msg = {c=commonmsgstr,g=0,n=0,t=TimeUtils.SystemTimeStamp(false)}
    data =JSON.encode(msg)
	PersonSpaceMgr.AddHeroMessage(playerid,data)
end

function OnDelMsg(sender,content)
	local playerid = PersonSpaceMgr.GetCurrentShowPlayerId()
    PersonSpaceMgr.AskHeroMessageBoard(playerid,0,200)
end

function OnClick(go, id)
	if id >10000 then
		local index = math.floor(id/10000)
		local eventid = id - index*10000
		if eventid==1 then--removeBtn
			local item =mlistView:GetItemAtIndex(index);
			local sender_id = mItemDatas[item.dataIndex].sender_id
			local content = mItemDatas[item.dataIndex].frec
			PersonSpaceMgr.DelHeroMessage(sender_id,content)
		elseif eventid ==2 then--replyBtn
		end
	elseif id >= 1 then
		local item =mlistView:GetItemAtIndex(id);
		mCurSelectIndex = item.dataIndex;
		local sender_id = mItemDatas[item.dataIndex].sender_id
		local playerid = PersonSpaceMgr.GetCurrentShowPlayerId()
		if playerid==sender_id then
			mCurSelectItem=nil
			mMsgInput:ResetDefaultText(TipsMgr.GetTipByKey("personspace_reply_default"))
		else
			mCurSelectItem = item
			mMsgInput:ResetDefaultText(string.format("您对%s说:",item.name.text)) 
		end
		mlistView:UpdateCellsContent()
	elseif id == -1 then--成就
	elseif id == -2 then--人气
	elseif id == -3 then--礼物
	elseif id == -4 then--返回
		mCurSelectIndex =-1
		mMsgInput:ResetDefaultText(TipsMgr.GetTipByKey("personspace_reply_default"))
		mMsgInput:OnClickBack()
	elseif id == -5 then--表情
		mMsgInput:OnClickSign()
	elseif id == -6 then--发送留言
		mMsgInput:OnClickSend()
	elseif id == -7 then--留言
		mMsgInput:ShowViewTween(true)
	elseif id == -8 then--踩一下
		local playerid = PersonSpaceMgr.GetCurrentShowPlayerId()
		PersonSpaceMgr.AddPopularity(playerid)
	elseif id == -9 then--送礼
		
	elseif id == -10 then--加好友
		SocialPlayerInfoMgr.GetPlayerInfoById(playerid,function (playerid,playerInfo)
			if playerInfo then
				local friend = playerInfo:GetFriendCom()
				FriendMgr.RequestAskAddFriend(friend);
			end
		end)
		
    end
end