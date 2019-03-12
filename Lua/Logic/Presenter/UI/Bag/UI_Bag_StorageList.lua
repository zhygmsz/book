--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
module("UI_Bag_StorageList",package.seeall);

local mStorages = {};
local mBaseInfos ={}
local pageMax = 12;
local mUnLockPageID = 0;
local mButton= nil
local mTable = nil

function OnCreate(self)
    mButton =self:Find("Offset/btn");
    mTable =self:FindComponent("UITable","Offset/Table");
    pageMax = Bag_pb.DEPOT_SIZE-Bag_pb.DEPOT1+1
    for i = 1,pageMax do
        if mStorages[i] == nil then
            local obj = self:DuplicateAndAdd(mButton,mTable.gameObject.transform,i);
            local item = {};
            item.gameObject = obj.gameObject;
            item.gameObject.name = i
            item.img = obj:GetComponent("UISprite");
            item.name = obj:Find("Label"):GetComponent("UILabel");
            item.lock = obj:Find("Lock").gameObject;
            item.event = obj:GetComponent("UIEvent")
            item.event.id =i
            mStorages[i] = item;
            item.gameObject:SetActive(false)
        end
    end
    mButton.gameObject:SetActive(false)
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PACKAGE,OnPackageUpdate);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PACKAGE,OnPackageUpdate);
    mEvents = {};
end

function OnEnable(self)
    RegEvent(self);
   -- OnGetPageName({"",""});
    UpdateView()
end

function OnDisable(self)
    UnRegEvent(self);
end

function OnClick(go,id)
    if id == -1 or id == -1000 then
        UIMgr.UnShowUI(AllUI.UI_Bag_StorageList);
    else
        if id >= 1 and id <= 12 then
            local item = mStorages[id]
            local baseinfo =mBaseInfos[Bag_pb.DEPOT1+id-1]
            if baseinfo then
                --切换仓库
                if baseinfo.isOpen then
                    UI_Bag_Storage.mCurSelectDEPOT = baseinfo.type
                    UI_Bag_Storage.UpdateView()
                    UIMgr.UnShowUI(AllUI.UI_Bag_StorageList);
                else
                    --解锁仓库
                    BagMgr.UnlockDepot()
                end
            end
        end
    end
end

function UpdateItemView(bagType)
    if mStorages and mBaseInfos[bagType] then
        local item = mStorages[bagType-Bag_pb.DEPOT1+1]
        --item.img.spriteName = mBaseInfos[bagType].isOpen and "button_common_15" or  "button_common_16"
        item.name.text = mBaseInfos[bagType].isOpen and BagMgr.GetDEPOTName(bagType) or ""
        item.lock:SetActive(not mBaseInfos[bagType].isOpen);
        local last = math.floor((bagType)/3-1)*3 + Bag_pb.DEPOT1-1
        local lastitem = BagMgr.GetBagBaseInfo(last)
        item.gameObject:SetActive(bagType<=Bag_pb.DEPOT3 and true or lastitem.isOpen);
    end
end

function UpdateView()
    for i = Bag_pb.DEPOT1,Bag_pb.DEPOT1+pageMax do
        local baseinfo = BagMgr.GetBagBaseInfo(i)
        mBaseInfos[i] = baseinfo
        UpdateItemView(i)
    end
    mTable:Reposition()
end

--收到背包信息更新的回调
function OnPackageUpdate(bagType)
    if bagType>=Bag_pb.DEPOT1 and bagType<=Bag_pb.DEPOT1+pageMax then
        local baseinfo = BagMgr.GetBagBaseInfo(bagType)
        mBaseInfos[bagType] = baseinfo
        UpdateItemView(bagType)
    end
 end

--endregion
