module("UI_Tip_BuffInfo", package.seeall)

local mSelf;

local mBuffItemPrefab;
local mBuffListWrap;
local mBuffListWrapCall;

local mBuffItemPool = {};
local mBuffInfoList = {};

local mCDTimer = nil;

local mItemAlign = UITableWrapContent.Align.Top;
local mItemDataAlign = UITableWrapContent.Align.Bottom;

local BUFF_POOL_COUNT = 4;

function OnCreate(self)
	mSelf = self;
	mBuffItemPrefab = self:Find("Anchor/Offset/All/widget/scrollview/BuffPrefab").transform;
	mBuffItemPrefab.gameObject:SetActive(false);
	mBuffListWrap = self:FindComponent("UIWrapContent", "Anchor/Offset/All/widget/scrollview/wrapcontent");
	mBuffListWrapCall = UIWrapContent.OnInitializeItem(OnUpdateBuffItem);
	InitBuffItemPool();
end

function OnDestroy(self)
	-- body
end

function OnEnable(self, ...)
	RegEvent();
	mCDTimer = GameTimer.AddTimer(1, 1000000, UpdateBuffCDTime);
	local args = {...};
	local buffList = args[1];
	OnBuffChanged(buffList);
end

function OnDisable(self)
	UnRegEvent();
	GameTimer.DeleteTimer(mCDTimer);
end

function RegEvent()
	GameEvent.Reg(EVT.MAINUI, EVT.MAINUI_BUFF_CHANGED, OnBuffChanged);
end

function UnRegEvent()
	GameEvent.UnReg(EVT.MAINUI, EVT.MAINUI_BUFF_CHANGED, OnBuffChanged);
end

function OnClick(go, id)
	if id == - 1 then
		UIMgr.UnShowUI(AllUI.UI_Tip_BuffInfo);
	end
end

function InitBuffItemPool()
	for i = 1, BUFF_POOL_COUNT do
		local buffItem = {};
		buffItem.buffId = - 1;
		buffItem.buffTime = 0;
		buffItem.gameObject = mSelf:DuplicateAndAdd(mBuffItemPrefab, mBuffListWrap.transform, i).gameObject;
		buffItem.transform = buffItem.gameObject.transform;
		buffItem.buffIcon = buffItem.transform:Find("Icon"):GetComponent("UISprite");
		buffItem.buffName = buffItem.transform:Find("Name"):GetComponent("UILabel");
		buffItem.timeLabel = buffItem.transform:Find("Time"):GetComponent("UILabel");
		buffItem.desLable = buffItem.transform:Find("Des"):GetComponent("UILabel");
		buffItem.LineBg = buffItem.transform:Find("Line"):GetComponent("UISprite");
		table.insert(mBuffItemPool, buffItem);
	end
end

function OnUpdateBuffItem(go, index, realIndex)
	if realIndex >= 0 and realIndex < #mBuffInfoList then
		go:SetActive(true);
		SetBuffItemInfo(index + 1, realIndex + 1);
	else
		local buffItem = mBuffItemPool[index + 1];
		if buffItem then
			buffItem.buffId = - 1;
		end
		go:SetActive(false);
	end
end

function SetBuffItemInfo(buffPoolIndex, buffInfoIndex)
	local buffItem = mBuffItemPool[buffPoolIndex];
	local buffInfo = mBuffInfoList[buffPoolIndex];
	if not buffItem or not buffItem then return; end
	local buffTableInfo = BuffData.GetBuffData(buffInfo.buffId);
	buffItem.buffId = buffInfo.buffId;
	buffItem.buffTime = buffInfo.buffTime;
	buffItem.buffName.text = buffTableInfo.name;
	--加载图标
	buffItem.desLable.text = buffTableInfo.desc;
	if buffInfoIndex == #mBuffInfoList then
		buffItem.LineBg.gameObject:SetActive(false);
	else
		buffItem.LineBg.gameObject:SetActive(true);
	end
	--时间
	UpdateBuffItemTime(buffPoolIndex);
end

function OnBuffChanged(buffList)
	mBuffInfoList = buffList;
	mBuffListWrap:ResetWrapContent(table.count(mBuffInfoList), mBuffListWrapCall);
end

function UpdateBuffCDTime()
	for k, v in ipairs(mBuffInfoList) do
		--v.buffTime = v.buffTime - 1;
		for m, n in ipairs(mBuffItemPool) do
			if n.buffId == v.buffId then
				n.buffTime = n.buffTime - 1000;
				UpdateBuffItemTime(m);
				break;
			end
		end
	end
end

function UpdateBuffItemTime(buffPoolIndex)
	local buffItem = mBuffItemPool[buffPoolIndex];
	if buffItem == nil then return; end
	local buffTime = buffItem.buffTime / 1000;
	buffTime = buffItem - buffItem % 0;
	local timeStr = "";
	if buffTime <= 60 then
		timeStr = buffTime .. "秒";
	elseif buffTime > 60 and buffTime <= 3600 then
		local a = buffTime % 60;
		local min =(buffTime - a) / 60;
		timeStr = min .. "分";
	elseif buffTime > 3600 and buffTime <= 86400 then
		local a = buffTime % 3600;
		local hour =(buffTime - a) / 3600;
		timeStr = hour .. "小时";
	elseif buffTime > 86400 then
		local a = buffTime % 86400;
		local day =(buffTime - a) / 86400;
		timeStr = day .. "天";
	end
	buffItem.timeLabel.text = timeStr;
end