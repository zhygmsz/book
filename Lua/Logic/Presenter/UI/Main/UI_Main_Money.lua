--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
module("UI_Main_Money",package.seeall);
--金币显示框
local mGoldLabel;
--银币显示框
local mSilverLabel;
--玉显示框
local mJadeLabel;
--商店显示框
local mShop;


function OnCreate(self)
    mGoldLabel = self:FindComponent("UILabel","Offset/Gold/Count");
    mSilverLabel = self:FindComponent("UILabel","Offset/Silver/Count");
    mJadeLabel = self:FindComponent("UILabel","Offset/Jade/Count");
    mShop = self:FindComponent("UILabel","Offset/Shop/Count");
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_GETCOIN,InitMoney);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_GETCOIN,InitMoney);
    mEvents = {};
end

function OnEnable(self)
    RegEvent(self)
    InitMoney()
end
function OnDisable(self)
    UnRegEvent(self)
end

function InitMoney()
    mGoldLabel.text = string.NumberFormat(BagMgr.GetMoney(Coin_pb.GOLD),0);
    mSilverLabel.text = string.NumberFormat(BagMgr.GetMoney(Coin_pb.SILVER),0);
    mJadeLabel.text = string.NumberFormat(BagMgr.GetMoney(Coin_pb.INGOT),0);
end

function OnClick(go,id)
    if id == -1 then -- 购买金币
        UIMgr.ShowUI(AllUI.UI_Bag_GoldExchange,nil,nil,nil,nil,true,1,1)
    elseif id == -2 then -- 购买银币
        UIMgr.ShowUI(AllUI.UI_Bag_GoldExchange,nil,nil,nil,nil,true,2,2)
    elseif id == -3 then -- 购买元宝
        UI_Exchange.ShowUI(4);
    elseif id == -4 then -- 打开商店

    elseif id == 0 then -- 关闭按钮

    elseif id == -100 then -- 点击空白
    else
    end
end

