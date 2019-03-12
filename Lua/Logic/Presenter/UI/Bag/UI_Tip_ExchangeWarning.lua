module("UI_Tip_ExchangeWarning",package.seeall)

local mAsk
local mTitle
local mFromIcon;
local mFromNum;
local mToIcon;
local mToNum;
local showData = {}

function OnCreate(self)
    mAsk = self:FindComponent("UILabel","Offset/Bg/Content/ask");
    mTitle = self:FindComponent("UILabel","Offset/Bg/Title");
    local mChange = self:FindComponent("UILabel","Offset/Bg/Content/change");
    mChange.text = TipsMgr.GetTipByKey("bag_exchange_confirmmsg2")
    mFromNum = self:FindComponent("UILabel","Offset/Bg/Content/fromNum");
    mFromIcon = self:FindComponent("UISprite","Offset/Bg/Content/fromIcon");
    mToNum = self:FindComponent("UILabel","Offset/Bg/Content/toNum");
    mToIcon = self:FindComponent("UISprite","Offset/Bg/Content/toIcon");
    mAsk.text = TipsMgr.GetTipByKey("bag_exchange_confirmmsg1")  
end

function OnEnable(self)
    UpdateView()
end

function OnDisable(self)
end

function SetData(from,to,fromnum,tonum,iokFunc,icancelFunc)
    showData.from = from
    showData.to = to
    showData.fromNum = fromnum
    showData.toNUm = tonum
    showData.okFunc = iokFunc
    showData.cancelFunc = icancelFunc
end

function UpdateView()
    if mFromIcon and showData.from then mFromIcon.spriteName =BagMgr.GetCoinIconName(showData.from) end
    if mToIcon and showData.to then mToIcon.spriteName =BagMgr.GetCoinIconName(showData.to) end
    if mFromNum and showData.fromNum then 
        mFromNum.text =string.format("%s",string.NumberFormat(showData.fromNum,0))
      --  mFromNum.text = TipsMgr.GetTipByKey("bag_coin_coinshownum",string.NumberFormat(showData.fromNum,0),BagMgr.GetCoinName(showData.from))
    end
    if mToNum and showData.toNUm then
        mToNum.text =string.format("%s",string.NumberFormat(showData.toNUm,0))
       -- mToNum.text = TipsMgr.GetTipByKey("bag_coin_coinshownum",string.NumberFormat(showData.toNUm,0),BagMgr.GetCoinName(showData.to))
    end
    mFromIcon:MakePixelPerfect()
    mToIcon:MakePixelPerfect()
end

--from和to是货币类型:Coin_pb.INGOT Coin_pb.GOLD
function ShowTip(from,to,fromnum,tonum,iokFunc,icancelFunc)
    SetData(from,to,fromnum,tonum,iokFunc,icancelFunc)
    UIMgr.ShowUI(AllUI.UI_Tip_ExchangeWarning);
end

function OnClick(go,id)
    if id == 10 then--确定
        if showData.okFunc then
            showData.okFunc()
        end
        UIMgr.UnShowUI(AllUI.UI_Tip_ExchangeWarning);
    elseif id == 11 then--取消
        if showData.cancelFunc then showData.cancelFunc() end
        UIMgr.UnShowUI(AllUI.UI_Tip_ExchangeWarning);
    elseif id == 0 then--关闭
        if showData.cancelFunc then showData.cancelFunc() end
        UIMgr.UnShowUI(AllUI.UI_Tip_ExchangeWarning);
    end
end
