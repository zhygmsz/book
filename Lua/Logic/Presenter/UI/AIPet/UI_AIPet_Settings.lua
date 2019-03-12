module("UI_AIPet_Settings",package.seeall);

local mDeskToggle;
local mSizeToggles;
local mChatToggles;

local function SaveSettings()
    local oldValue = AIPetMgr.IsShowOnDesk();
    local newValue = mDeskToggle.value;
    if newValue ~= oldValue then
        AIPetMgr.SetShowOnDesk(newValue);
    end

    oldValue = AIPetMgr.GetModelSizeLevel();
    for i=1,3 do
        if mSizeToggles[i].value then
            newValue = i;
            break;
        end
    end
    if newValue ~= oldValue then
        AIPetMgr.SetModelSizeLevel(newValue);
    end

    oldValue = AIPetMgr.GetChatFrequenceLevel();
    for i=1,4 do
        if mChatToggles[i].value then
            newValue = i;
            break;
        end
    end

    if newValue ~= oldValue then
        AIPetMgr.SetChatFrequenceLevel(newValue);
    end
end

function OnCreate(ui)
    mDeskToggle = ui:FindComponent("UIToggle","Offset/Setting1/Option");
    mSizeToggles = {};
    for i=1,3 do
        local toggle = ui:FindComponent("UIToggle","Offset/Setting2/Grid/Option"..i);
        table.insert(mSizeToggles, toggle);
    end
    mChatToggles = {};
    mChatLabels = {};
    for i =1,4 do
        local toggle = ui:FindComponent("UIToggle","Offset/Setting3/Grid/Option"..i);
        table.insert(mChatToggles,toggle);

        local label = ui:FindComponent("UILabel",string.format("Offset/Setting3/Grid/Option%s/Label",i));
        label.text = WordData.GetWordStringByKey("AIPet_chat_frequence_des"..i);
    end
end

function OnEnable(ui)
    mDeskToggle.value = AIPetMgr.IsShowOnDesk();
    local sizeLevel = AIPetMgr.GetModelSizeLevel();
    mSizeToggles[sizeLevel].value = true;
    local chatLevel = AIPetMgr.GetChatFrequenceLevel();
    mChatToggles[chatLevel].value = true;
end

function OnDisable(ui)

end

function OnDestroy(ui)
    mDeskToggle = nil;
    mSizeToggles = nil;
    mChatToggles = nil;
end

function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_AIPet_Settings);
    elseif id == 1 then
        AIPetMgr.ClearMessageRecord();
    elseif id == 2 then
        SaveSettings();
    end
end
