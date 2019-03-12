module("UI_Equip_Selection", package.seeall)

local mTitle;
local mButtinLabel;
local mEquipSelects = {};
local mSelectIndex = 1;
local mTaskType;
local mTaskId;
local mHeightLightBg;
local mNormalBg;

local mAtt1 = {};
local mAtt2 = {};

function OnCreate(self)
	
	mTitle = self:FindComponent("UILabel", "Offset/Sprite/Label");
	mButtinLabel = self:FindComponent("UILabel", "Offset/Top/Select/label");
	mHeightLightBg = self:Find("Offset/ModelList/Item_1/Frame");
	mNormalBg = self:Find("Offset/ModelList/Item_2/Frame");
	for i = 1, 2 do
		local selectItem = {};
		selectItem.root = self:Find("Offset/ModelList/Item_" .. tostring(i));
		selectItem.texture = self:FindComponent("UITexture", "Offset/ModelList/Item_" .. tostring(i) .. "/Texture");
		selectItem.tip = self:Find("Offset/ModelList/Item_" .. tostring(i) .. "/Panel/SelectFlag").gameObject;
		selectItem.frameBgTrans = self:Find("Offset/ModelList/Item_" .. tostring(i) .. "/Bg");
		--selectItem.bg = self:FindComponent("UITexture", "Offset/ModelList/Item_" .. tostring(i) .. "/Frame");
		--selectItem.bgLoader = LoaderMgr.CreateTextureLoader(selectItem.bg);
		selectItem.nameLabel = self:FindComponent("UILabel", "Offset/ModelList/Item_" .. tostring(i) .. "/Panel/Title/TitleLable");
		selectItem.selectLabel = self:FindComponent("UILabel", "Offset/ModelList/Item_" .. tostring(i) .. "/Panel/SelectFlag/SelectFlagLabel");
		
		local scaleValue;
		local offsetValueX;
		
		local rootSortorder = self:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
		
		selectItem.selectEffect = LoaderMgr.CreateEffectLoader();
		selectItem.selectEffect:LoadObject(ResConfigData.GetResConfigID("UI_huanzhuang_eff01"));
		selectItem.selectEffect:SetParent(selectItem.frameBgTrans);
		selectItem.selectEffect:SetLocalPosition(Vector3.zero);
		selectItem.selectEffect:SetLocalScale(Vector3.one);
		selectItem.selectEffect:SetSortOrder(rootSortorder);
		
		table.insert(mEquipSelects, selectItem);
	end
	
	mAtt1.name = "att1";
	mAtt1.position = Vector3.zero;
	mAtt1.forward = Quaternion.identity;
	mAtt1.petData = nil;
	mAtt1.modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER;
	mAtt1.fashions = {};
	mAtt1.physiqueID = nil;
	
	mAtt2.name = "att1";
	mAtt2.position = Vector3.zero;
	mAtt2.forward = Quaternion.identity;
	mAtt2.petData = nil;
	mAtt2.modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER;
	mAtt2.fashions = {};
	mAtt2.physiqueID = nil;
end

function OnEnable(self, taskId, taskType, selectType, firstShowId, secondShowId)
	mTaskId = taskId;
	mTaskType = taskType;
	if selectType == 1 then
		mAtt1.modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER;
		mAtt2.modelType = EntityDefine.MODEL_PROCESS_TYPE.PLAYER;
	elseif selectType == 2 then
		mAtt1.modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER;
		mAtt2.modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER;
	elseif selectType == 3 then
		mAtt1.modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER;
		mAtt2.modelType = EntityDefine.MODEL_PROCESS_TYPE.CHARACTER;
	end
	CameraRender.RenderEntity(AllUI.UI_Equip_Selection, mEquipSelects[1].texture, mAtt1, 1, firstShowId);
	CameraRender.RenderEntity(AllUI.UI_Equip_Selection, mEquipSelects[2].texture, mAtt2, 2, secondShowId);
	SelectEquip(1);
	ResetView(selectType, firstShowId, secondShowId);
end

function OnDisable(self)
	CameraRender.DeleteEntity(AllUI.UI_Equip_Selection, 1);
	CameraRender.DeleteEntity(AllUI.UI_Equip_Selection, 2);
end

function OnClick(go, id)
	if id == 0 then
		UIMgr.UnShowUI(AllUI.UI_Equip_Selection);
	elseif id == 1 then
		SelectEquip(1);
	elseif id == 2 then
		SelectEquip(2);
	elseif id == 3 then
		--TaskMgr.RequestChangeSuit(UserData.GetPhysiqueID(), mSelectIndex);
		TaskMgr.RequestSelectGoal(mTaskType, mTaskId, mSelectIndex)
		UIMgr.UnShowUI(AllUI.UI_Equip_Selection);
	end
end

function OnDrag(delta, id)
	if id == 1 then
		CameraRender.DragEntity(AllUI.UI_Equip_Selection, delta, 1);
	elseif id == 2 then
		CameraRender.DragEntity(AllUI.UI_Equip_Selection, delta, 2);
	end
end

function SelectEquip(index)
	mSelectIndex = index;
	for i, v in ipairs(mEquipSelects) do
		local isSelect = index == i;
		v.tip:SetActive(isSelect);
		if isSelect then
			--v.bg.depth = 2;
			--v.bg.transform.localScale = Vector3.New(- 1, 1, 1);
			--v.bgLoader:LoadObject(ResConfigData.GetResConfigID("frame_huanzhuang_01"));
			mHeightLightBg.parent = v.root;
			mHeightLightBg.localPosition = Vector3.zero;
			if v.selectEffect then v.selectEffect:SetActive(true); end;
		else
			--v.bg.depth = 1;
			--v.bg.transform.localScale = Vector3.New(1, 1, 1);
			--v.bgLoader:LoadObject(ResConfigData.GetResConfigID("frame_huanzhuang_02"));
			mNormalBg.parent = v.root;
			mNormalBg.localPosition = Vector3.zero;
			if v.selectEffect then v.selectEffect:SetActive(false); end;
		end
	end
end

function ResetView(selectType)
	local titleStr = "";
	local btnStr = "";
	local selectFlagStr = "";
	local nameStr1 = "";
	local nameStr2 = "";
	if selectType == 1 then
		titleStr = WordData.GetWordStringByKey("pick_2to1_fashion_title");
		btnStr = WordData.GetWordStringByKey("pick_2to1_fashion_button");
		selectFlagStr = WordData.GetWordStringByKey("pick_2to1_fashion_tips");
		nameStr1 = WordData.GetWordStringByKey("pick_2to1_fashion_nameleft");
		nameStr2 = WordData.GetWordStringByKey("pick_2to1_fashion_nameright");
	elseif selectType == 2 then
		titleStr = WordData.GetWordStringByKey("pick_2to1_pet_title");
		btnStr = WordData.GetWordStringByKey("pick_2to1_pet_button");
		selectFlagStr = WordData.GetWordStringByKey("pick_2to1_pet_tips");
		nameStr1 = WordData.GetWordStringByKey("pick_2to1_pet_nameleft");
		nameStr2 = WordData.GetWordStringByKey("pick_2to1_pet_nameright");
	elseif selectType == 3 then
		titleStr = WordData.GetWordStringByKey("pick_2to1_zuoqi_title");
		btnStr = WordData.GetWordStringByKey("pick_2to1_zuoqi_button");
		selectFlagStr = WordData.GetWordStringByKey("pick_2to1_zuoqi_tips");
		nameStr1 = WordData.GetWordStringByKey("pick_2to1_zuoqi_nameleft");
		nameStr2 = WordData.GetWordStringByKey("pick_2to1_zuoqi_nameright");
	end
	mTitle.text = titleStr;
	mEquipSelects[1].nameLabel.text = nameStr1;
	mEquipSelects[2].nameLabel.text = nameStr2;
	mButtinLabel.text = btnStr;
	mEquipSelects[1].selectLabel.text = selectFlagStr;
	mEquipSelects[2].selectLabel.text = selectFlagStr;
end 