local CommonSkillGroupItem = class("CommonSkillGroupItem", UICommonCollapseWrapUI);

function CommonSkillGroupItem:ctor(wrapItemTrans, baseEventID, context)
	self._gameObject = wrapItemTrans.gameObject;
	self._context = context;
	self._uiFrame = context.GetUIFrame();
	self._rootSortorder = self._uiFrame:GetRoot():GetComponent("UIPanel").sortingOrder + 100;
	self._id = - 1;
	self._bgMain = wrapItemTrans:Find("Bg/Bg_Main"):GetComponent("UISprite");
	self._titleLabel = wrapItemTrans:Find("Bg/Bg_Head/TitleLabel"):GetComponent("UILabel");
	self._skillListGrid = wrapItemTrans:Find("Grid"):GetComponent("UIGrid");
	self._skillItemPrefab = wrapItemTrans:Find("Grid/SkillItemPrefab");
	self._skillItemList = {};
	self._baseEventId = baseEventID;
end

function CommonSkillGroupItem:OnRefresh()
	local data = self._wrapData;
	self._id = data._id;
	self._titleLabel.text = "[b]" .. data._source;
	if #data._skillList > 4 then
		self._bgMain.height = 380;
	else
		self._bgMain.height = 205;
	end
	self._skillItemList = {};
	UIGridTableUtil.CreateChild(self._uiFrame, self._skillItemPrefab, #data._skillList, self._skillListGrid.transform, self.OnSkillItemCreate, self);
	self._skillListGrid:Reposition();
	self:InitSelectSkillItem();
end

function CommonSkillGroupItem:OnClick(id)
	if id % 2 == 0 then
		self:OnSelectSkillItem((id + 2) / 2);
	else
		self:OnEquipSkill((id + 1) / 2);
	end
end

function CommonSkillGroupItem:OnSkillItemCreate(skillItemTrans, index)
	local data = self._wrapData;
	local skillInfo = data._skillList[index];
	
	local skillItem = {};
	skillItem.id = skillInfo.skillId;
	skillItem.transform = skillItemTrans;
	skillItem.skillNameLabel = skillItemTrans:Find("NameLabel"):GetComponent("UILabel");
	skillItem.skillIcon = skillItemTrans:Find("Icon"):GetComponent("UITexture");
	skillItem.skillIconLoader = LoaderMgr.CreateTextureLoader(skillItem.skillIcon);
	skillItem.starList = {};
	local starCommonPath = "StarList/Start0";
	for i = 1, 5 do
		local starItem = skillItemTrans:Find(starCommonPath .. i):GetComponent("UISprite");
		table.insert(skillItem.starList, starItem);
	end
	skillItem.equipFlagObject = skillItemTrans:Find("EquipFlag").gameObject;
	skillItem.upFlagObject = skillItemTrans:Find("UpFlag").gameObject;
	skillItem.equipBtn = skillItemTrans:Find("EquipBtn");
	skillItem.equipBtnObject = skillItem.equipBtn.gameObject;
	skillItem.selectFlagObject = skillItemTrans:Find("SelectFlag").gameObject;
	skillItem.choseUIEvent = skillItemTrans:GetComponent("UIEvent");
	skillItem.equipUIEvent = skillItem.equipBtn:GetComponent("UIEvent");
	
	local skillTableInfo = SkillData.GetSkillInfo(skillInfo.skillId);
	skillItem.skillNameLabel.text = skillTableInfo.name;
	if skillTableInfo.icon then
		skillItem.skillIconLoader:LoadObject(ResConfigData.GetResConfigID(skillTableInfo.icon));
	end
	skillItem.choseUIEvent.id = self._baseEventId +(index - 1) * 2;
	skillItem.equipUIEvent.id = self._baseEventId +(index - 1) * 2 + 1;
	local currentSelectSkillid = self._context.GetCurrentSelectedSkillId();
	--选中标志和装备按钮
	if currentSelectSkillid == skillInfo.skillId then
		skillItem.selectFlagObject:SetActive(true);
		--装备按钮
		local commonSkillInfo = SkillMgr.GetCommonSkillInfo(skillItem.id);
		if commonSkillInfo ~= nil then
			local isEquiped = SkillMgr.GetCommonSkillIsEquiped(skillItem.id);
			if isEquiped == true then
				skillItem.equipBtnObject:SetActive(false);
			else
				skillItem.equipBtnObject:SetActive(true);
			end
		else
			skillItem.equipBtnObject:SetActive(false);
		end
	else
		skillItem.selectFlagObject:SetActive(false);
		skillItem.equipBtnObject:SetActive(false);
	end
	
	if skillInfo.isActive == true then
		for k, v in ipairs(skillItem.starList) do
			local commonSkillInfo = SkillMgr.GetCommonSkillInfo(skillInfo.skillId);
			if k <= commonSkillInfo.skillLevel then
				v.gameObject:SetActive(true);
			else
				v.gameObject:SetActive(false);
			end
		end
		UIMgr.MakeUIGrey(skillItem.skillIcon, false);
	else
		for k, v in ipairs(skillItem.starList) do
			v.gameObject:SetActive(false);
		end
		UIMgr.MakeUIGrey(skillItem.skillIcon, true);
	end
	
	--装备标志
	local isEquiped = SkillMgr.GetCommonSkillIsEquiped(skillInfo.skillId);
	skillItem.equipFlagObject:SetActive(isEquiped);
	
	skillItem.upFlagObject:SetActive(false);
	--待做升星特效

	table.insert(self._skillItemList, skillItem);
end

function CommonSkillGroupItem:OnSelectSkillItem(index)
	self._context.SelectSkillItem(self._skillItemList[index].id);
	self:SetSelectFlagVisiable(index, true);
end

function CommonSkillGroupItem:OnEquipSkill(index)
	local skillItem = self._skillItemList[index];
	if skillItem == nil then return; end
	local isSlotUnlocked = FunUnLockMgr.GetSkillSlotIsUnlock(5);
	if isSlotUnlocked then
		SkillMgr.RequestCommonSkillEquip(skillItem.id);
	else
		TipsMgr.TipByKey("skill_slot_Locked");
	end
end

function CommonSkillGroupItem:SetSelectFlagVisiable(index, isVisiable)
	local skillItem = self._skillItemList[index];
	if skillItem == nil then return; end
	skillItem.selectFlagObject:SetActive(isVisiable);
	self:UpdateSkillEquipBtnVisible(index);
end

function CommonSkillGroupItem:SetCommonSkillIsEquiped(index, isEquiped)
	local skillItem = self._skillItemList[index];
	if skillItem == nil then return; end
	skillItem.equipFlagObject:SetActive(isEquiped);
	self:UpdateSkillEquipBtnVisible(index);
end

function CommonSkillGroupItem:UpdateSkillStarInfo(index)
	local skillItem = self._skillItemList[index];
	if skillItem == nil then return; end
	local commonSkillInfo = SkillMgr.GetCommonSkillInfo(skillItem.id);
	if commonSkillInfo ~= nil then
		for k, v in ipairs(skillItem.starList) do
			if k <= commonSkillInfo.skillLevel then
				v.gameObject:SetActive(true);
			else
				v.gameObject:SetActive(false);
			end
		end
		UIMgr.MakeUIGrey(skillItem.skillIcon, false);
	else
		UIMgr.MakeUIGrey(skillItem.skillIcon, true);
	end
	self:UpdateSkillEquipBtnVisible(index);
end

function CommonSkillGroupItem:UpdateSkillEquipBtnVisible(index)
	local skillItem = self._skillItemList[index];
	if skillItem == nil then return; end
	local commonSkillInfo = SkillMgr.GetCommonSkillInfo(skillItem.id);
	if commonSkillInfo ~= nil then
		local currentSelectSkillid = self._context.GetCurrentSelectedSkillId();
		if currentSelectSkillid == skillItem.id then
			local isEquiped = SkillMgr.GetCommonSkillIsEquiped(skillItem.id);
			if isEquiped == true then
				skillItem.equipBtnObject:SetActive(false);
			else
				skillItem.equipBtnObject:SetActive(true);
			end
		else
			skillItem.equipBtnObject:SetActive(false);
		end
	else
		skillItem.equipBtnObject:SetActive(false);
	end
end

function CommonSkillGroupItem:InitSelectSkillItem()
	local equipedSkillId = SkillMgr.GetEquipedSkillId();
	if equipedSkillId == - 1 then
		local dataIndex = self._context.GetDataindex(self._wrapData);
		if dataIndex == 1 then
			self:OnSelectSkillItem(1);
		end
	else
		local isContentEquipSkill = self._context.GetIsFilterListContainEquipedSkill();
		if isContentEquipSkill then
			for k, v in ipairs(self._skillItemList) do
				if v.id == equipedSkillId then
					self:OnSelectSkillItem(k);
					break;
				end
			end
		else
			local dataIndex = self._context.GetDataindex(self._wrapData);
			if dataIndex == 1 then
				self:OnSelectSkillItem(1);
			end
		end
	end
end

return CommonSkillGroupItem; 