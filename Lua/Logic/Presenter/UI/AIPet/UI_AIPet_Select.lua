module("UI_AIPet_Select",package.seeall);
local UIAIPetArrow = require("Logic/Presenter/UI/AIPet/FirstSelect/UIAIPetArrow")
local UIAIPetPersonInfo = require("Logic/Presenter/UI/AIPet/FirstSelect/UIAIPetPersonInfo");
local UIAIPetBubble = require("Logic/Presenter/UI/AIPet/FirstSelect/UIAIPetBubble");
local mPersonInfo;
local mBubble;

local mHudPrefab;
local mEntities;
local mUI;
local mArrows;

local mSelectPet;
local function FindEntityByEID(eid)
    for i,entity in ipairs(mEntities) do
        if entity:GetID() == eid then
            return entity;
        end
    end
end

local function OnHUDCreate(trans, index)
    local entity = mEntities[index];
    mArrows[entity] = UIAIPetArrow.new(trans);
    mArrows[entity]:SetFollow(entity);
end

local function OnSelect(pet)
    mSelectPet = pet;
    mBubble:SetTarget(pet);
    mPersonInfo:SetTarget(pet);
end

function OnCreate(ui)
    mUI = ui;
    local personInfo = ui:Find("Offset/PetInfo");
    mPersonInfo = UIAIPetPersonInfo.new(personInfo);
    mPersonInfo:Close();

    local bubble = ui:Find("Offset/LabelPP");
    mBubble = UIAIPetBubble.new(bubble);
    mBubble:Close();

    mHudPrefab = ui:Find("Offset/Hud/Item");
end

function OnEnable(ui)
    UIMgr.MaskUI(true, 0, 198);
    mEntities = {};

    local npcs = MapMgr.GetAllEntityByType(EntityDefine.ENTITY_TYPE.NPC );
    for i,npc in pairs(npcs) do
        if npc:GetNPCType() == Common_pb.NPC_AIPET then
            table.insert(mEntities,npc);
        end
    end
    mArrows = {};
    UIGridTableUtil.CreateChild(ui,mHudPrefab,#mEntities,nil,OnHUDCreate);
    --GameEvent.Reg(EVT.COMMON,EVT.CLICK_ENTITY,OnClickEntity);
end
function OnAction(actionName, actionData)
    local pid = actionData.intParams[2] or 1;
    local pet = AIPetMgr.GetPetByID(pid);
    OnSelect(pet);
end

function OnDisable(ui)
    UIMgr.MaskUI(false);
end

function OnDestroy(ui)

end

function OnClick(go,id)
    if id == 0 then

    elseif id== 1 then
        local msg = NetCS_pb.CSSceneEvent();
        msg.eventType = 117  --// 自定义选择		select_id(选择编号)
        table.insert(msg.params,mSelectPet:GetID());
        GameLog.Log("eventType=%s, params={%s}", msg.eventType, msg.params[1]);
        GameNet.SendToGate(msg);
        UIMgr.MaskUI(false);
    end
    --退出选择模式
    OnSelect(nil);
    CameraMgr.EnterDefaultMode();
end
