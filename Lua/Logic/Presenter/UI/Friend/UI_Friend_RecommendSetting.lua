module("UI_Friend_RecommendSetting",package.seeall);
local UIPopupScrollListAddress = require("Logic/Presenter/UI/Common/UIPopupScrollListAddress");

local mSettingTable;
local mScrollAdress;
local mAddressKey;
local mClickTransmitter;

function OnCreate(ui)
    local path = "Offset/Bg/LeftPanel/Scroll View/Table/%s/Table/LabelItem1";
    mSettings = {};
    local sexPrefab = ui:Find(string.format(path,"ItemSex"));
    local levelPrefab = ui:Find(string.format(path,"ItemLevel"));
    local marriagePrefab = ui:Find(string.format(path,"ItemMarriage"));
    local careerPrefab = ui:Find(string.format(path,"ItemCareer"));
    local starPrefab = ui:Find(string.format(path,"ItemConstellation"));
    path = "Offset/Bg/RightPanel/Scroll View/Table/%s/Table/LabelItem1";
    local popursePrefab = ui:Find(string.format(path,"ItemTarget"));
    local interestPrefab = ui:Find(string.format(path,"ItemInterest"));
    
    path = "Offset/Bg/LeftPanel/Scroll View/Table/ItemCity/PopupListWithBroad";

    mScrollAdress = UIPopupScrollListAddress.new(ui,path,1,2);
    mAddressKey = FriendRecommendMgr.GetKeyLocation();

    mSettingTable = {};
    local item = {};
    item.prefab = sexPrefab;
    item.propertyKey = FriendRecommendMgr.GetKeySex();
    mSettingTable[1] = item;
    local item = {};
    item.prefab = levelPrefab;
    item.propertyKey = FriendRecommendMgr.GetKeyLevel();
    mSettingTable[2] = item;
    local item = {};
    item.prefab = marriagePrefab;
    item.propertyKey = FriendRecommendMgr.GetKeyMarriage();
    mSettingTable[3] = item;
    local item = {};
    item.prefab = careerPrefab;
    item.propertyKey = FriendRecommendMgr.GetKeyCareer();
    mSettingTable[4] = item;
    local item = {};
    item.prefab = starPrefab;
    item.propertyKey = FriendRecommendMgr.GetKeyStar();
    mSettingTable[5] = item;
    local item = {};
    item.prefab = popursePrefab;
    item.propertyKey = FriendRecommendMgr.GetKeyPurpose();
    mSettingTable[6] = item;
    local item = {};
    item.prefab = interestPrefab;
    item.propertyKey = FriendRecommendMgr.GetKeyPreperence();
    mSettingTable[7] = item;

    for i,prefabKey in ipairs(mSettingTable) do
        local count = FriendRecommendMgr.GetPropertyMaxIndex(prefabKey.propertyKey);
        local function OnItemCreate(itemData,i)
            local key = prefabKey.propertyKey;
            local trans = itemData.transform;
            itemData.toggle = trans:GetComponent("UIToggle");
            local label = trans:Find("Label"):GetComponent("UILabel");
            label.text = FriendRecommendMgr.GetPropertyName(key,i);
        end
        prefabKey.list = UIUtil.Duplicate(ui,prefabKey.prefab,nil,count,OnItemCreate);
        local table = prefabKey.prefab.parent:GetComponent("UIGrid");
        table:Reposition();
        prefabKey.prefab = nil;
    end
end


local function Reset()
    for i,data in ipairs(mSettingTable) do
        for i,item in ipairs(data.list) do
            item.toggle:Set(false);
        end
    end
    mScrollAdress:SetSelectedAddress();
    --mScrollAdress:SetSelectedAddress(0,0);
end

local function ChangeSettings()
    local selectedAny = false;
    local result = {};
    for i,data in ipairs(mSettingTable) do
        for i,item in ipairs(data.list) do
            result[data.propertyKey] = result[data.propertyKey] or {};
            if item.toggle.value then
                local code = FriendRecommendMgr.GetPropertyCode(data.propertyKey,i);
                table.insert(result[data.propertyKey],code);
                selectedAny = true;
            end
        end
    end

    local aid = mScrollAdress:GetSelectedAddress();
    local code = FriendRecommendMgr.GetPropertyCode(mAddressKey,aid);
    if code then
        selectedAny = true;
        result[mAddressKey] = {};
        table.insert(result[mAddressKey],code);
    end

    if selectedAny then
        FriendRecommendMgr.RequestSetRecommendSettings(result);
    else
        TipsMgr.TipByFormat("friend_recommend_setting_select_none");--推荐设置，没选择任何选项
    end
end

local function OnGetSettings()
    for i,data in ipairs(mSettingTable) do
        local key = data.propertyKey;
        local selected = FriendRecommendMgr.GetCustomSelectedIndexes(key);
        for i,index in ipairs(selected) do
            data.list[index].toggle.value = true;
        end
    end
    local addressids = FriendRecommendMgr.GetCustomSelectedIndexes(mAddressKey);
    for i = 1,#addressids do
        mScrollAdress:SetSelectedAddress(addressids[i]);
    end
end

local function OnChangeSettings()
    UIMgr.UnShowUI(AllUI.UI_Friend_RecommendSetting);
end

function OnEnable(ui)
    OnGetSettings();
    GameEvent.Reg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_SETTINGS_CHANGE,OnChangeSettings);
end

function OnClick(go,id)
    GameLog.Log("OnClick %s, %s",go.name,id);
    mScrollAdress:OnClick(go,id);
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Friend_RecommendSetting);
    elseif id == 11 then
        --重置条件
        Reset();
    elseif id == 12 then
        --开始推荐
        ChangeSettings();
    end
end

function OnDisable(ui)
    GameEvent.UnReg(EVT.FRIENDRECOMMEND,EVT.FRIENDRECOMMEND_SETTINGS_CHANGE,OnChangeSettings);
end

function OnDestroy(ui)
    mSettingTable = nil;
end