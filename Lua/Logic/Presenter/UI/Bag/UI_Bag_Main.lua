--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
module("UI_Bag_Main",package.seeall);

require("Logic/Presenter/UI/Bag/UI_Bag_Package")
require("Logic/Presenter/UI/Bag/UI_Bag_Equip")

--当前左侧选中的
mCurSelectL = 1;  -- 1-4
--当前中间选中的
mCurSelectC = 11; -- 11-15

--背包按钮 101
local mToggleBag;
--仓库按钮 102
local mToggleStorage;
--角色按钮 103
local mTogglePlayer;
--当前右侧选中的
mCurSelectR = 101; -- 101-102
local mTitle = nil

function OnCreate(self)
    mToggleBag = self:FindComponent("UIToggle","Offset/RToggles/TPackage");
    local mToggleBagOn = self:FindComponent("UILabel","Offset/RToggles/TPackage/Active/Name");
    local mToggleBagOff = self:FindComponent("UILabel","Offset/RToggles/TPackage/DeActive/Name");
    mToggleStorage = self:FindComponent("UIToggle","Offset/RToggles/TStorage");
    local mToggleStorageOn = self:FindComponent("UILabel","Offset/RToggles/TStorage/Active/Name");
    local mToggleStorageOff = self:FindComponent("UILabel","Offset/RToggles/TStorage/DeActive/Name");
    mTogglePlayer = self:FindComponent("UIToggle","Offset/RToggles/TPlayer");
    local mTogglePlayerOn = self:FindComponent("UILabel","Offset/RToggles/TPlayer/Active/Name");
    local mTogglePlayerOff = self:FindComponent("UILabel","Offset/RToggles/TPlayer/DeActive/Name");
    mTitle = self:FindComponent("UILabel","Offset/Title");
    mToggleBagOn.text = TipsMgr.GetTipByKey("backpack_info_19");
    mToggleBagOff.text =  TipsMgr.GetTipByKey("backpack_info_19");
    mToggleStorageOn.text =  TipsMgr.GetTipByKey("backpack_info_20");
    mToggleStorageOff.text =  TipsMgr.GetTipByKey("backpack_info_20");
    mTogglePlayerOn.text = TipsMgr.GetTipByKey("backpack_info_21");
    mTogglePlayerOff.text = TipsMgr.GetTipByKey("backpack_info_21");
end

local mEvents = {};
function RegEvent(self)
end

function UnRegEvent(self)
    mEvents = {};
end
function OnEnable(self)
    RegEvent(self)
    OnToggle(mCurSelectR,true);
    InitToggle(true);
    UIMgr.ShowUI(AllUI.UI_Main_Money);
    UIMgr.MaskUI(true, 0, 199)
end
function OnDisable(self)
    UnRegEvent(self)
    UIMgr.UnShowUI(AllUI.UI_Main_Money);
    UIMgr.MaskUI(false, 0, 199)
end

function InitToggle(reOpen)
    mToggleBag:Set(mCurSelectR == 101,true);
    mToggleStorage:Set(mCurSelectR == 102,true);
    mTogglePlayer:Set(mCurSelectR == 103,true);
    --mTogglePlayer:Set(false);
    mTitle.text = mCurSelectR == 101 and  TipsMgr.GetTipByKey("backpack_info_22") or mCurSelectR == 102 and TipsMgr.GetTipByKey("backpack_info_23") or  TipsMgr.GetTipByKey("backpack_info_24");
end

function OnClick(go,id)
   if id == 0 then -- 关闭按钮
        CloseSecondUI();
        mCurSelectR = 101
        UIMgr.UnShowUI(AllUI.UI_Bag_Package);
        UIMgr.UnShowUI(AllUI.UI_Bag_Equip);
        UIMgr.UnShowUI(AllUI.UI_Bag_Storage);
        UIMgr.UnShowUI(AllUI.UI_Bag_PlayerAtt); 
        UIMgr.UnShowUI(AllUI.UI_Bag_Main); 
        BagMgr.ClearBagNewItems(Bag_pb.NORMAL)
    elseif id == -100 then -- 点击空白
        CloseSecondUI();
    else
        OnToggle(id);
    end
end

function OnToggle(id,reOpen)
    CloseSecondUI();
    if id <= 103 and id >= 101 then      
        ToggleR(id,reOpen);
    end
end


--仓库和背包切换
function ToggleR(id,reOpen)
    if mCurSelectR ~= id or reOpen then
        if id == 101 then
            mCurSelectR = id;
            UIMgr.UnShowUI(AllUI.UI_Bag_Equip);
            UIMgr.UnShowUI(AllUI.UI_Bag_Storage);
            UIMgr.UnShowUI(AllUI.UI_Bag_PlayerAtt);
            UIMgr.ShowUI(AllUI.UI_Bag_Package);
            UI_Bag_Package.OnOpenStorage(false);
            UIMgr.ShowUI(AllUI.UI_Bag_Equip);
            UI_Bag_Equip.OnShowFacadeBtn(true);
        elseif id == 102 then
            mCurSelectR = id;                            
            UIMgr.UnShowUI(AllUI.UI_Bag_Equip);
            UIMgr.UnShowUI(AllUI.UI_Bag_PlayerAtt);
            UIMgr.ShowUI(AllUI.UI_Bag_Storage);
            UIMgr.ShowUI(AllUI.UI_Bag_Package);
            UI_Bag_Package.OnOpenStorage(true);
        elseif id == 103 then
            --TipsMgr.TipByKey("Function_Not_Finished") 
            mCurSelectR = id;                
            UIMgr.UnShowUI(AllUI.UI_Bag_Package);       
            UIMgr.UnShowUI(AllUI.UI_Bag_Storage);
            UIMgr.UnShowUI(AllUI.UI_Bag_Equip);
            UIMgr.ShowUI(AllUI.UI_Bag_PlayerAtt);
            UIMgr.ShowUI(AllUI.UI_Bag_Equip);
            UI_Bag_Package.OnOpenStorage(false);
            UI_Bag_Equip.OnShowFacadeBtn(false);
        end
    end
    InitToggle();
end


function CloseSecondUI()
    UIMgr.UnShowUI(AllUI.UI_Tip_UseMultiItems);
    UIMgr.UnShowUI(AllUI.UI_Tip_ItemInfoEx);
    UIMgr.UnShowUI(AllUI.UI_Tip_EquipItemInfo);
    UIMgr.UnShowUI(AllUI.UI_Bag_ModifyName);
    UIMgr.UnShowUI(AllUI.UI_Bag_StorageList);
end

function SetDefaultToggle(toggleID)
    mCurSelectR = toggleID;
end
