module("UI_Bag_PlayerAtt", package.seeall)

local mAttDefineList = nil;
local mAttShowDefineList = nil;

local mPlayerName;
local mPlayerPro;
local mPlayerLevel;
local mPlayerCW;
local mPlayerBP;
local mPlayerID;
local mModelTex;

local mBaseAttHP;
local mBaseAttMP;
local mBaseAttAP;
local mBaseAttEXP;
local mBaseAttOffset;

local mLineAttPrefab;
local mLineAttItems = {};

local mAdvanceAttOffset;

local mAdvanceAttBG2;
local mAdvanceAttBG3;
local mAdvanceAttBG4;
local mAdvanceAttBG5;
local mElementAttOffset;

local mOtherAttOffset;

local mAttrNode;--属性tips
local mAttrBg
local mAttrDesc
local mTxtNode

local mScrollView;

local mSelf;

function OnCreate(self)
    mSelf = self;
    mPlayerName = self:FindComponent("UILabel", "Offset/Player/Name");
    mPlayerPro = self:FindComponent("UISprite", "Offset/Player/Name_Pro");
    mModelTex = self:FindComponent("UITexture", "Offset/Player/Model");
	--mPlayerLevel = self:FindComponent("UILabel", "Offset/Attr/BaseActive/LV");
    mPlayerLevel = self:FindComponent("UILabel", "Offset/Player/LabelLevel");
    -- mPlayerCW = self:FindComponent("UILabel", "Offset/Attr/BaseActive/CW");
    -- mPlayerBP = self:FindComponent("UILabel", "Offset/Attr/BaseActive/BP");
	-- mPlayerID = self:FindComponent("UILabel", "Offset/Attr/BaseActive/ID");
	
	mPlayerCW = self:FindComponent("UILabel", "Offset/Attr/OtherActive/DragParent/ScrollView/LabelCW");
    mPlayerBP = self:FindComponent("UILabel", "Offset/Attr/OtherActive/DragParent/ScrollView/LabelBH");
    mPlayerID = self:FindComponent("UILabel", "Offset/Attr/OtherActive/DragParent/ScrollView/LabelID");

    mBaseAttHP = {};
    mBaseAttHP.slider = self:FindComponent("UISlider", "Offset/Attr/BaseActive/HP");
    mBaseAttHP.label = self:FindComponent("UILabel", "Offset/Attr/BaseActive/HP/text");

    mBaseAttMP = {};
    mBaseAttMP.slider = self:FindComponent("UISlider", "Offset/Attr/BaseActive/MP");
    mBaseAttMP.label = self:FindComponent("UILabel", "Offset/Attr/BaseActive/MP/text");

    mBaseAttAP = {};
    mBaseAttAP.slider = self:FindComponent("UISlider", "Offset/Attr/BaseActive/AP");
    mBaseAttAP.label = self:FindComponent("UILabel", "Offset/Attr/BaseActive/AP/text");

    mBaseAttEXP = {};
    mBaseAttEXP.slider = self:FindComponent("UISlider", "Offset/Attr/BaseActive/EXP");
    mBaseAttEXP.label = self:FindComponent("UILabel", "Offset/Attr/BaseActive/EXP/text");

    mLineAttPrefab = self:Find("Offset/Attr/AdvanceActive/DragParent/ScrollView/Line").gameObject;
    mLineAttPrefab:SetActive(false);
    mLineAttItems.prefabHeight = mLineAttPrefab:GetComponent("UIWidget").height;

    mBaseAttOffset = self:Find("Offset/Attr/BaseActive/AttGrid").transform;

    mAdvanceAttOffset = self:Find("Offset/Attr/AdvanceActive/DragParent/ScrollView/Offset").transform;
    mAdvanceAttBG2 = self:Find("Offset/Attr/AdvanceActive/DragParent/ScrollView/Bg2").transform;
    mAdvanceAttBG3 = self:Find("Offset/Attr/AdvanceActive/DragParent/ScrollView/Bg3").transform;
    mAdvanceAttBG4 = self:Find("Offset/Attr/AdvanceActive/DragParent/ScrollView/Bg4").transform;
    mAdvanceAttBG5 = self:Find("Offset/Attr/AdvanceActive/DragParent/ScrollView/Bg5").transform;

	mElementAttOffset = self:Find("Offset/Attr/ElementActive/DragParent/ScrollView/Offset").transform;
	
    mOtherAttOffset = self:Find("Offset/Attr/OtherActive/DragParent/ScrollView").transform;

    mAttrNode = self:Find("Offset/Attr/AttrTipsPanel").gameObject;
    mAttrBg = self:Find("Offset/Attr/AttrTipsPanel/Bg"):GetComponent("UISprite");
    mAttrDesc = self:Find("Offset/Attr/AttrTipsPanel/Bg/Desc"):GetComponent("UILabel")
    mTxtNode = self:Find("Offset/Attr/AttrTipsPanel/Bg").gameObject
    mScrollView = self:Find("Offset/Attr/AdvanceActive/DragParent/ScrollView").transform;

    mAttDefineList = AttDefineData.GetAllDefineData();
    mAttShowDefineList = AttShowDefineData.GetAllShowData();
end

function OnEnable(self)
    InitPlayer();
    InitBaseAtt(self);
    InitAdvanceAtt(self);
    --InitElementAtt(self);
    GameEvent.Reg(EVT.PLAYER, EVT.PLAYER_ATT_UPDATE, OnAttrUpdate);
	GameEvent.Reg(EVT.ENTITY, EVT.ENTITY_HP_UPDATE, OnHPUpdate);
	GameEvent.Reg(EVT.PLAYER, EVT.PLAYER_SHOWATTRTIPS, ShowPlayerAttrTips);	
    CameraRender.RenderEntity(AllUI.UI_Bag_PlayerAtt, mModelTex, UserData.PlayerAtt);
end

function OnDisable(self)
    GameEvent.UnReg(EVT.PLAYER, EVT.PLAYER_ATT_UPDATE, OnAttrUpdate);
	GameEvent.UnReg(EVT.ENTITY, EVT.ENTITY_HP_UPDATE, OnHPUpdate);
	GameEvent.UnReg(EVT.PLAYER, EVT.PLAYER_SHOWATTRTIPS, ShowPlayerAttrTips);	
    CameraRender.DeleteEntity(AllUI.UI_Bag_PlayerAtt);
end

function InitPlayer()
    mPlayerName.text = UserData.GetName();
    --mPlayerPro.spriteName = "";
    mPlayerLevel.text = string.format("%s：%s", TipsMgr.GetTipByKey("Chaatt_sur9"), UserData.GetLevel());
    --mPlayerCW.text = "";
    --mPlayerBP.text = "";
    mPlayerID.text = string.format("%s：%s", TipsMgr.GetTipByKey("bag_att_id"), UserData.PlayerID);
end

function InitAtt(self, attType, attRoot, offsetY)
    if not mLineAttItems[attType] then
        local atts = {};
        atts.datas = GetSortedAtts(attType);
        atts.items = {};
        for i = 1, #atts.datas do
            local item = {};
            item.gameObject = self:DuplicateAndAdd(mLineAttPrefab.transform, attRoot.transform, i).gameObject;
            item.transform = item.gameObject.transform;
            item.nameLabel = item.transform:Find("Name"):GetComponent("UILabel");
            item.valueLabel = item.transform:Find("Value"):GetComponent("UILabel");
            item.bgObj = item.transform:Find("Bg").gameObject;
            --item.eventInfo = {};
            --item.eventInfo.event = item.gameObject:GetComponent("GameCore.UIEvent");
            --item.eventInfo.event.id = -1;
            atts.items[i] = item;
        end
        mLineAttItems[attType] = atts;
    end

    local data = mLineAttItems[attType];
    for i = 1, #data.datas do
        local item = data.items[i];
        local itemValue = GetAttValue(data.datas[i]);
        if not item.value or item.value ~= itemValue then
            item.value = itemValue;
            item.nameLabel.text = data.datas[i].name;            
            item.valueLabel.text = itemValue;
            if attType == 0 then
                item.valueLabel.transform.localPosition = Vector3.New( item.valueLabel.transform.localPosition.x - 30, item.valueLabel.transform.localPosition.y, item.valueLabel.transform.localPosition.z )
            end
            item.gameObject:SetActive(true);
            item.bgObj:SetActive(i % 2 == 1);
            item.transform:Find("Box"):GetComponent("UIEvent").id = data.datas[i].id+100;
        end
        item.transform.localPosition = Vector3.New((i - 1) % 2 * 200,offsetY - (math.floor( (i - 1) / 2  )) * mLineAttItems.prefabHeight, 0);				
        --item.transform.localPosition = Vector3.New(0, offsetY - (i - 1) * mLineAttItems.prefabHeight, 0);
    end
    if #data.datas >= 1 then
        return data.items[#data.datas].transform.localPosition.y;
    else
        return 0;
    end
end

function InitBaseAtt(self)
    local cur = 0;
    local max = 0;
    local percent = 0;
    cur = UserData.GetHP();
    max = UserData.GetHPMax();
    percent = cur / max;
    mBaseAttHP.slider.value = percent;
    mBaseAttHP.label.text = string.format("%d/%d", cur, max);

    cur = UserData.GetMP();
    max = UserData.GetMPMax();
    percent = cur / max;
    mBaseAttMP.slider.value = percent;
    mBaseAttMP.label.text = string.format("%d/%d", cur, max);

    cur = UserData.GetAP();
    --max = UserData.GetAPMax();
    max = 10;
    percent = cur / max;
    mBaseAttAP.slider.value = percent;
    mBaseAttAP.label.text = string.format("%d/%d", cur, max);

    cur = UserData.GetExp();
    max = LevelExpData.GetExpByLevel(UserData.GetLevel());
    percent = cur / max;
    mBaseAttEXP.slider.value = percent;
    mBaseAttEXP.label.text = string.format("%d/%d", cur, max);

    InitAtt(self, 0, mBaseAttOffset, 0);
end

function InitOtherAtt()

end

function InitAdvanceAtt(self)
    local y = InitAtt(self, 1, mAdvanceAttOffset, 0);
    mAdvanceAttBG2.localPosition = mAdvanceAttOffset.localPosition + Vector3.New(0, y - 48, 0);
    y = InitAtt(self, 2, mAdvanceAttOffset, y - 96);
    mAdvanceAttBG3.localPosition = mAdvanceAttOffset.localPosition + Vector3.New(0, y - 48, 0);
    y = InitAtt(self, 3, mAdvanceAttOffset, y - 96);
    mAdvanceAttBG4.localPosition = mAdvanceAttOffset.localPosition + Vector3.New(0, y - 48, 0);
    y = InitAtt(self, 4, mAdvanceAttOffset, y - 96);
    mAdvanceAttBG5.localPosition = mAdvanceAttOffset.localPosition + Vector3.New(0, y - 48, 0);
    y = InitAtt(self, 5, mAdvanceAttOffset, y - 96);
end

function InitElementAtt(self)
    InitAtt(self, 4, mElementAttOffset, 0);
end

function InitIntegralView()

end

function OnClick(go, id)
    if id == 0 then
        --修改名字
    elseif id == 1 then
        --点击模型
    elseif id == 2 then       
    elseif id == 10 then
    elseif id == 11 then
    elseif id == 12 then
	elseif id == 13 then
		--修改称号
		--UIMgr.ShowUI(AllUI.UI_Title);
		--HP MP AP EXP
	elseif id >= 100 then
        TriggerAttrTips(id, go)
    elseif id == -3 then
        mAttrNode:SetActive(false);
    end
end

function TriggerAttrTips(id, go)
    for k, data in pairs(mAttShowDefineList) do
        if data.gid == (id-100) then
            GameEvent.Trigger(EVT.PLAYER, EVT.PLAYER_SHOWATTRTIPS, data.tips, go);
        end
    end     
end

function OnDrag(delta, id)
    CameraRender.DragEntity(AllUI.UI_Bag_PlayerAtt, delta);
end

function OnAttrUpdate(entity)
    InitBaseAtt(mSelf);
    InitAdvanceAtt(mSelf);
    --InitElementAtt(mSelf);
end

function OnHPUpdate(_, entity)
    if entity:IsSelf() then
        local cur = UserData.GetHP();
        local max = UserData.GetHPMax();
        local percent = cur / max;
        mBaseAttHP.slider.value = percent;
        mBaseAttHP.label.text = string.format("%d/%d", cur, max);
    end
end

function SortByWeight(a, b)
    if a == b or a.weight == b.weight then return false; end
    return a.weight > b.weight;
end

function GetSortedAtts(attType)
    local ret = {};
    for k, data in pairs(mAttShowDefineList) do
        for j, datas in pairs(mAttDefineList) do
            if data.gid == datas.id and data.showType == attType and (data.isAd == 0 or data.isAd == JudgeAdOrAp()) then
                table.insert(ret,datas)
            end
        end
    end
    table.sort(ret, SortByWeight);
    return ret;
end

function GetAttValue(data)
    local staticProperty = UserData.GetStaticProperty();
    local dynamicProperty = UserData.GetDynamicProperty();
    local value = AttrCalculator.CalculProperty(data.id, UserData.GetLevel(), staticProperty, dynamicProperty);
    return AttrCalculator.CalculPropertyUI(value, data.showType, data.showLength);
end

function JudgeAdOrAp()
    local ProfessionInfo = ProfessionInfoData.GetProfessionInfo();

    for k, data in pairs(ProfessionInfo) do
        if datas.id == UserData.GetRacial() then
            return data.type;
        end
    end  
    return 1;
end

function ShowPlayerAttrTips(content, go)
    mAttrNode:SetActive(true)
    mAttrDesc.text = content
    mAttrBg.height = mAttrDesc.height + 20
    local widget = go.transform.parent.gameObject:GetComponent("UIWidget")
    if widget then
        local pos = widget.transform.localPosition
        mTxtNode.transform.localPosition = Vector3.New( -120, pos.y + mScrollView.localPosition.y + 160, pos.z )
    end
end
