MainUIFunBtns = class("MainUIFunBtns");

function MainUIFunBtns:ctor(uiFrame)
	local rootSortorder = uiFrame:GetRoot():GetComponent("UIPanel").sortingOrder + 1;
	--右上角功能按钮组
	self._funBtnGridBR = uiFrame:FindComponent("UIGrid", "BottomRight/FunctionBtnsBR/Level1").gameObject;
	--临时背包
	self._tempBagBtnObject = uiFrame:FindComponent("UISprite", "BottomRight/FunctionBtnsBR/BtnTemBackpack").gameObject;
	--背包和临时背包已满标志
	self._bagFullFlagObject = uiFrame:FindComponent("UISprite", "BottomRight/FunctionBtnsBR/BtnBackpack/Count").gameObject;
	self._tempBagFullFlagObject = uiFrame:FindComponent("UISprite", "BottomRight/FunctionBtnsBR/BtnTemBackpack/Count").gameObject;
	--背包和临时背包tween动画
	self._tweenFlag = false;
	self._backpackTween = uiFrame:FindComponent("TweenScale", "BottomRight/FunctionBtnsBR/BtnBackpack");
	self._tempBagTween = uiFrame:FindComponent("TweenScale", "BottomRight/FunctionBtnsBR/BtnTemBackpack");
	self._backpackTween.enabled = false;
	self._tempBagTween.enabled = false;
	EventDelegate.Add(self._backpackTween.onFinished, EventDelegate.Callback(self.OnBackpackTweenFinishend, self));
	EventDelegate.Add(self._tempBagTween.onFinished, EventDelegate.Callback(self.OnTempBagTweenFinishend, self));
	
	--邮件提醒
	self._mailTips1 = uiFrame:Find("BottomLeft/FunctionBtnsBL/BtnFriend/MailTips1").gameObject
	self._mailTips2 = uiFrame:Find("BottomLeft/FunctionBtnsBL/BtnFriend/MailTips2").gameObject
	self._bottmonFunBtnTweenRotation = uiFrame:FindComponent("TweenRotation", "BottomRight/FunctionBtnsBR/BtnFold/Background");
	self._bottmonFunBtnTweenRotation:Play(false);
	self._mailTips1:SetActive(false)
	self._mailTips2:SetActive(false)
	
	--右上角功能按钮区控制
	self._topFunGridObject = uiFrame:FindComponent("UIGrid", "TopRight/FunctionBtnsTR/Level1").gameObject;
	self._topFunGridSwitchArrow = uiFrame:Find("TopRight/SystemInfo/LeftBtn/Normal").transform;
	self._topFunGridSwitchToggle = uiFrame:FindComponent("UIToggle", "TopRight/SystemInfo/LeftBtn");
	self._topFunGridSwitchToggle:Set(false, false);
	self._topFunGridSwitchCallBack = EventDelegate.Callback(self.class.OnTopFunGridSwitched, self);
	EventDelegate.Set(self._topFunGridSwitchToggle.onChange, self._topFunGridSwitchCallBack);
	
	--首充及特效
	self._firstChargeBtnTrans = uiFrame:Find("TopRight/FunctionBtnsTR/Level1/06-BtnShouChong");
	self._firstChargeBtnObject = self._firstChargeBtnTrans.gameObject;
	--引导首次充值特效
	self._firstChargeEffect1 = LoaderMgr.CreateEffectLoader();
	self._firstChargeEffect1:LoadObject(ResConfigData.GetResConfigID("UI_shouchongtishi_02"));
	self._firstChargeEffect1:SetParent(self._firstChargeBtnTrans);
	self._firstChargeEffect1:SetLocalPosition(Vector3.zero);
	self._firstChargeEffect1:SetLocalScale(Vector3.one);
	self._firstChargeEffect1:SetSortOrder(rootSortorder);
	--引导首充领奖特效
	self._firstChargeEffect2 = LoaderMgr.CreateEffectLoader();
	self._firstChargeEffect2:LoadObject(ResConfigData.GetResConfigID("UI_shouchongtishi_01"));
	self._firstChargeEffect2:SetParent(self._firstChargeBtnTrans);
	self._firstChargeEffect2:SetLocalPosition(Vector3.zero);
	self._firstChargeEffect2:SetLocalScale(Vector3.one);
	self._firstChargeEffect2:SetSortOrder(rootSortorder);
	
	local newDayTime = ConfigData.GetValue("Time_newday");
	local nextTime = {};
	nextTime.hour = newDayTime;
	local timeToNewDay = TimeUtils.TimeStampLeft2NextTime(nextTime, false);
	GameTimer.AddTimer(timeToNewDay, 1, self.UpdateFirstChargeState, self);
end

function MainUIFunBtns:OnEnable()
	self:RegEvent();
	self:InitView();
end

function MainUIFunBtns:OnDisable()
	self:UnRegEvent();
end

function MainUIFunBtns:OnDestroy()
	
end

function MainUIFunBtns:RegEvent()
	GameEvent.Reg(EVT.MAINUI, EVT.MAINUI_BTN_STATE, self.OnMainUIBtnState, self);
	GameEvent.Reg(EVT.MAIL, EVT.MAIL_NEWMAILTIPS, self.OnNewMailTips, self)
	GameEvent.Reg(EVT.MAIL, EVT.MAIL_STOPNEWMAILTIPS, self.OnStopMailTips, self)
	GameEvent.Reg(EVT.MAIL, EVT.MAIL_CANCELNEWMAILTIPS, self.OnReadMail, self)
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_FULL, self.OnBagItemChanged, self);
	GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_UNLOCK_GRID, self.OnBagGridUnLock, self);
	GameEvent.Reg(EVT.FLYITEM, EVT.FLYITEM_ONFINISHONE, self.OnFlayItemFinished, self);
	GameEvent.Reg(EVT.CHARGE, EVT.CHARGE_FIRST_REWARD_CHANGE, self.UpdateFirstChargeState, self);
	GameEvent.Reg(EVT.CHARGE, EVT.CHARGE_HAS_RECHARGE_UPDATEUI, self.UpdateFirstChargeState, self);
end

function MainUIFunBtns:UnRegEvent()
	GameEvent.UnReg(EVT.MAINUI, EVT.MAINUI_BTN_STATE, self.OnMainUIBtnState, self);
	GameEvent.UnReg(EVT.MAIL, EVT.MAIL_NEWMAILTIPS, self.OnNewMailTips, self)
	GameEvent.UnReg(EVT.MAIL, EVT.MAIL_STOPNEWMAILTIPS, self.OnStopMailTips, self)
	GameEvent.UnReg(EVT.MAIL, EVT.MAIL_CANCELNEWMAILTIPS, self.OnReadMail, self)
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_FULL, self.OnBagItemChanged, self);
	GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_UNLOCK_GRID, self.OnBagGridUnLock, self);
	GameEvent.UnReg(EVT.FLYITEM, EVT.FLYITEM_ONFINISHONE, self.OnFlayItemFinished, self);
	GameEvent.UnReg(EVT.CHARGE, EVT.CHARGE_FIRST_REWARD_CHANGE, self.UpdateFirstChargeState, self);
	GameEvent.UnReg(EVT.CHARGE, EVT.CHARGE_HAS_RECHARGE_UPDATEUI, self.UpdateFirstChargeState, self);
end

function MainUIFunBtns:OnClick(id)
	if id == 101 then		--系统信息中的底图名称
		UIMgr.ShowUI(AllUI.UI_BigMap);
		UIMgr.ShowUI(AllUI.UI_Main_Money);
	elseif id == 201 then         --福利
		UIMgr.ShowUI(AllUI.UI_Welfare);
	elseif id == 202 then     --首冲
		UIMgr.ShowUI(AllUI.UI_ChargeFirst);
		UserData.SetChargeUIOpenNextTime();
		self:UpdateFirstChargeState();
	elseif id == 203 then     --商城
		--UIMgr.ShowUI(AllUI.UI_Shop_Main)
		UI_Exchange.ShowUI(1);
	elseif id == 204 then     --活动
		UIMgr.ShowUI(AllUI.UI_Vitality_Main);
	elseif id == 205 then    --地图
		UIMgr.ShowUI(AllUI.UI_BigMap);
		UIMgr.ShowUI(AllUI.UI_Main_Money);
	elseif id == 206 then    --分享
		--TouchMgr.EnableClickEffect(false);
		ShareMgr.CaptureGame();
	elseif id == 207 then     --AI宠物
		-- TipsMgr.TipByKey("Function_Not_Finished");
		-- UIMgr.ShowUI(AllUI.UI_AIPet_Home);
		MapMgr.RequestEnterMap(4, 99);
		-- UIMgr.UnShowAllUI(AllUI.UI_AIPet_Home);
	elseif id == 208 then     --送礼
		--TipsMgr.TipByKey("equip_share_not_support");
		UI_Gift_Main.ShowGiftSendRecord();
	elseif id == 209 then     --助战
		UIMgr.ShowUI(AllUI.UI_FightHelp_Main);
	elseif id == 210 then     --副本
		GameNet.SendGMCommand("28 1");
	elseif id == 211 then     --趣味技能
		UIMgr.ShowUI(AllUI.UI_Skill_Interest);
	elseif id == 231 then     --排行
		UIMgr.ShowUI(AllUI.AllUI.UI_RankList);
	elseif id == 232 then     --成就
		--UIMgr.ShowUI(AllUI.UI_AIPet_Home);
		UIMgr.ShowUI(AllUI.UI_Achievement);
	elseif id == 233 then     --技能
		UIMgr.ShowUI(AllUI.UI_Skill_Main);
	elseif id == 234 then     --装备
		--UIMgr.ShowUI(AllUI.UI_Bag_TempPackage);
		UIMgr.ShowUI(AllUI.UI_Intensify_Main);
	elseif id == 235 then     --帮派
		GangMgr.OpenGangUI()
	elseif id == 236 then     --设置
		UIMgr.ShowUI(AllUI.UI_Setting)
		--LoginMgr.StartLogin(false);
	elseif id == 237 then    --家园
		TipsMgr.TipByKey("equip_share_not_support");
		UIMgr.ShowUI(AllUI.UI_Equip_Selection, self, nil, nil, nil, true, nil, nil, 1, 20003, 20004);
	elseif id == 251 then   --背包
		UIMgr.ShowUI(AllUI.UI_Bag_Main)
	elseif id == 252 then   --临时背包
		UIMgr.ShowUI(AllUI.UI_Bag_TempPackage)
	elseif id == 261 then   --好友
		UIMgr.ShowUI(AllUI.UI_Friend_Main);
	elseif id == 300 then --战宠
		UIMgr.ShowUI(AllUI.UI_Pet_Main)
	elseif id == 500 then
		UserData.SetMainUIBtnState();
	elseif id == 550 then
		CameraMgr.EnterDefaultMode();
	end
end

function MainUIFunBtns:InitView()
	self:OnMainUIBtnState();
	self:UpdateFirstChargeState();
end

function MainUIFunBtns:OnMainUIBtnState()
	local btnState = UserData.GetMainUIBtnState();
	self._funBtnGridBR:SetActive(btnState)
	self._bottmonFunBtnTweenRotation:Play(btnState);
end

function MainUIFunBtns:OnNewMailTips()
	self._mailTips1:SetActive(true)
	self._mailTips2:SetActive(false)
end

function MainUIFunBtns:OnStopMailTips()
	self._mailTips1:SetActive(false)
	self._mailTips2:SetActive(true)
end

function MainUIFunBtns:OnReadMail()
	self._mailTips1:SetActive(false)
	self._mailTips2:SetActive(false)
end

function MainUIFunBtns:OnBagItemChanged(type)
	if type == Bag_pb.TEMP then
		self:SetTempBagVisible();
	end
	local isBagFull = BagMgr.GetBagLeftSlotNumber(Bag_pb.NORMAL) == 0;
	self._bagFullFlagObject:SetActive(isBagFull);
	local isTempBagFull = BagMgr.GetBagLeftSlotNumber(Bag_pb.TEMP) == 0;
	self._tempBagFullFlagObject:SetActive(isTempBagFull);
end

function MainUIFunBtns:OnBagGridUnLock()
	local isBagFull = BagMgr.GetBagLeftSlotNumber(Bag_pb.NORMAL) == 0;
	self._bagFullFlagObject:SetActive(isBagFull);
end

function MainUIFunBtns:SetTempBagVisible()
	local maxTemp = BagMgr.GetOpenGridCount(Bag_pb.TEMP);
	local isTempHasItem = BagMgr.GetBagLeftSlotNumber(Bag_pb.TEMP) < maxTemp;
	self._tempBagBtnObject:SetActive(isTempHasItem)
end

function MainUIFunBtns:OnTopFunGridSwitched()
	local isSwitch = self._topFunGridSwitchToggle.value;
	if isSwitch then
		self._topFunGridSwitchArrow.localScale = Vector3.New(1, - 1, 1);
	else
		self._topFunGridSwitchArrow.localScale = Vector3.one;
	end
	self._topFunGridObject:SetActive(not isSwitch);
end

function MainUIFunBtns:OnFlayItemFinished(BagType)
	if BagType == Bag_pb.NORMAL then
		self._backpackTween.enabled = true;
		self._backpackTween:Play(true);
		self._tweenFlag = true;
	elseif BagType == Bag_pb.TEMP then
		self._tempBagTween.enabled = true;
		self._tempBagTween:Play(true);
		self._tweenFlag = true;
	end
end

function MainUIFunBtns:OnBackpackTweenFinishend()
	if self._tweenFlag then
		self._backpackTween:Play(false);
		self._tweenFlag = false;
	else
		self._backpackTween.enabled = false;
	end
end

function MainUIFunBtns:OnTempBagTweenFinishend()
	if self._tweenFlag then
		self._tempBagTween:Play(false);
		self._tweenFlag = false;
	else
		self._tempBagTween.enabled = false;
	end
end

function MainUIFunBtns:UpdateFirstChargeState()
	--首先判断功能是否开启
	--判断是否有过充值
	local isHaseCharged = ChargeMgr.HasAnyCharge();
	if not isHaseCharged then
		--判断当日是否打开首充界面
		local isOpenFirstChargeUI = UserData.GetChargeUIOpenFlagToday();
		if not isOpenFirstChargeUI then
			self._firstChargeBtnObject:SetActive(true);
			self._firstChargeEffect2:SetActive(false);
			self._firstChargeEffect1:SetActive(false);
			self._firstChargeEffect1:SetActive(true);
		else
			self._firstChargeBtnObject:SetActive(true);
			self._firstChargeEffect2:SetActive(false);
			self._firstChargeEffect1:SetActive(false);
		end
	else
		--判断是否有未领取礼包
		local firstChargeState = ChargeMgr.GetFirstChargeState();
		if firstChargeState == 1 then
			self._firstChargeBtnObject:SetActive(true);
			self._firstChargeEffect1:SetActive(false);
			self._firstChargeEffect2:SetActive(false);
			self._firstChargeEffect2:SetActive(true);
		elseif firstChargeState == 2 then
			self._firstChargeEffect1:SetActive(false);
			self._firstChargeEffect2:SetActive(false);
		elseif firstChargeState == 3 then
			self._firstChargeEffect1:SetActive(false);
			self._firstChargeEffect2:SetActive(false);
			self._firstChargeBtnObject:SetActive(false);
		end
	end
end

return MainUIFunBtns; 