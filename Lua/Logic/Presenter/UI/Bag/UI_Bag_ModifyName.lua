module("UI_Bag_ModifyName",package.seeall);

local mInput;
local mTitle
local mDes
local mButtonName

function OnCreate(self)
    mTitle = self:FindComponent("UILabel","Offset/BG/title");
    mButtonName = self:FindComponent("UILabel","Offset/BG/SureBtn/Label");
    mDes = self:FindComponent("UILabel","Offset/BG/des");
    mInput = self:FindComponent("UIInput","Offset/BG/NameInput/Name");
    local call = EventDelegate.Callback(OnInputChange);
    EventDelegate.Set(mInput.onChange,call);
    mInput.characterLimit = 4
end

local mEvents = {};
function RegEvent(self)
    GameEvent.Reg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PAGENAME,OnUpdateName);
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.PACKAGE,EVT.PACKAGE_UPDATE_PAGENAME,OnUpdateName);
    mEvents = {};
end

function OnEnable(self)
    mInput.value =BagMgr.GetDEPOTName(UI_Bag_Storage.mCurSelectDEPOT);
    RegEvent(self);
end

function OnDisable(self)
    UnRegEvent(self);
end

function OnInputChange()
    local name = mInput.value
    local tname = string.Replace(name," ","");
    local found = string.Contains(tname,",")
    found = found or string.Contains(tname,"，")
    local length = string.Length(tname,0)
    if length>4 then
        local mRightName = string.SubString(tname,4,0)
        mInput.value = mRightName
    elseif found then
        tname = string.Replace(tname,",","");
        mInput.value = string.Replace(tname,"，","");
        TipsMgr.TipByKey("backpack_info_12");
    end
end

function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Bag_ModifyName);
    elseif id == 1 then
        local hasIlegal = string.ContainsIllegalWord(mInput.value)
        if hasIlegal then
            TipsMgr.TipByKey("backpack_info_18");
        else
            if  mInput.value == "" then
                mInput.value =BagMgr.GetDEPOTName(UI_Bag_Storage.mCurSelectDEPOT);
                TipsMgr.TipByKey("backpack_info_17");
            elseif mInput.value ~= BagMgr.GetDEPOTName(UI_Bag_Storage.mCurSelectDEPOT) then
                BagMgr.RequestRenameDepot(UI_Bag_Storage.mCurSelectDEPOT,mInput.value);
            else
                OnUpdateName()  
            end
        end
    end
end

function OnUpdateName()
    OnClick(nil,0);
end
--endregion
