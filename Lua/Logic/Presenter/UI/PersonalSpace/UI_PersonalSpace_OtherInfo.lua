module("UI_PersonalSpace_OtherInfo",package.seeall)
local PS_InfoViewController= require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/PS_InfoViewController")
--UI信息结构
local mUItable={}
local mPlayerInfo=nil
local mPlayerId = nil
local mShowMode = 1 --显示模式 2自己 1 别人
--uicontroller控制器
local mController = nil

function OnCreate(self)
    _self = self
    mUItable._ui = self
    mUItable._bgWidget =  self:FindComponent("UIWidget", "Offset/InfoScrollView/InfoBg")
    mUItable._headTexture = self:FindComponent("UITexture", "Offset/InfoScrollView/InfoBg/Header")
    mUItable._defaultHead = self:FindComponent("UISprite", "Offset/InfoScrollView/InfoBg/DefaultHead")
    mUItable._itemPrefab = self:Find("Offset/InfoScrollView/InfoBg/Item").gameObject
    mUItable._itemPrefab:SetActive(false)
    mUItable._professionSprite = self:FindComponent("UISprite", "Offset/InfoScrollView/InfoBg/ProfessionIcon")
    mUItable._professionLabel = self:FindComponent("UILabel", "Offset/InfoScrollView/InfoBg/ProfessionIcon/Label")
    mUItable._sexSprite = self:FindComponent("UISprite", "Offset/InfoScrollView/InfoBg/SexIcon")
    mUItable._sexLabel = self:FindComponent("UILabel", "Offset/InfoScrollView/InfoBg/SexIcon/Label")
    mController = PS_InfoViewController.new(mUItable)
end

function OnEnable(self,playerid,mode)
    RegEvent(self)
    mPlayerId = playerid
    mShowMode = 1
    GetData()
end

function OnDisable(self)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PSPACE,EVT.PS_UPDATEPLAYERINFO,PlayerInfoUpdated);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PSPACE,EVT.PS_UPDATEPLAYERINFO,PlayerInfoUpdated);
    mEvents = {};
end

function GetData()
    PersonSpaceMgr.GetPlayerInfoById(mPlayerId,PlayerInfoUpdated)
end

function PlayerInfoUpdated(playerid,playerInfo)
    if playerid == mPlayerId then
        mPlayerInfo=playerInfo
        if mPlayerInfo then
            mController:UpdateData(mPlayerInfo)
            mController:UpdateView()
        end
    end
end

function OnClick(go, id)
    if id == 1 then --个人点击头像
        mController:LookUpHeadIcon()
    end
end