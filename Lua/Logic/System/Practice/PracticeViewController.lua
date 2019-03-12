local PracticeViewController = class("PracticeViewController",nil)

--targetType 1=经脉修炼 2=御兽修炼
--attType 1=攻法修炼-- 2=物防修炼-- 3=法防修炼-- 4=气血修炼-- 5=共鸣修炼

local mIconMap = {
    [1] = {
        [1] = "Prac_Icon3",[2] = "Prac_Icon4",[3] = "Prac_Icon5",[4] = "Prac_Icon2",[5] = "Prac_Icon1",
    },
    [2] = {
        [1] = "Prac_Icon8",[2] = "Prac_Icon9",[3] = "Prac_Icon10",[4] = "Prac_Icon7",[5] = "Prac_Icon6",
    }
} 

local mTextMap = {
    [1] = {
        [1] = "Prac_JM3",[2] = "Prac_JM4",[3] = "Prac_JM5",[4] = "Prac_JM2",[5] = "Prac_JM1",
    },
    [2] = {
        [1] = "Prac_YS3",[2] = "Prac_YS4",[3] = "Prac_YS5",[4] = "Prac_YS2",[5] = "Prac_YS1",
    }
} 

local mEffectLoaders = {}
function PracticeViewController:ctor(ui)
    self._ui = ui
    --经脉面板
    self._meridianPad = self._ui._meridianPad
    --御兽面板
    self._beastPad = self._ui._beastPad
    --修炼升级界面
    self._practicePad = self._ui._practicePad
    --共鸣生就界面
    self._sympathyPad = self._ui._sympathyPad
    
    GameEvent.Reg(EVT.PRACTICE,EVT.SELECT_ITEM,self.OnSelectItem,self);
    GameEvent.Reg(EVT.PRACTICE,EVT.SEE_TIP,self.OnSeeTip,self);
    GameEvent.Reg(EVT.PRACTICE,EVT.TRAIN_ONCE,self.OnTrainOnce,self);
    GameEvent.Reg(EVT.PRACTICE,EVT.TRAIN_BTACH,self.OnTrainBatch,self);
    GameEvent.Reg(EVT.PRACTICE,EVT.USE_ITEM,self.OnUseItem,self);
    GameEvent.Reg(EVT.PRACTICE,EVT.SYMPHY_LEVEL,self.OnSymphyLevelUp,self);
    GameEvent.Reg(EVT.PRACTICE,EVT.ADD_SILVER,self.OnAddSilver,self);
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_GETCOIN, self.OnUpdateMoney,self);
end

--经脉御兽图标
function PracticeViewController:GetIcon(targetType,attType)
    local key = mIconMap[targetType][attType]
    return ConfigData.GetValue(key)
end

--经脉御兽文字
function PracticeViewController:GetText(targetType,attType)
    local key = mTextMap[targetType][attType]
    return TipsMgr.GetTipByKey(key)
end

--设置经脉面板的图标文字 选中状态
function PracticeViewController:SetMeridianPad(select)
    for i=1,5 do
        self._meridianPad.mItems[i].mIcon.spriteName = self:GetIcon(1,i)
        self._meridianPad.mItems[i].mName.text =  self:GetText(1,i)
        self._meridianPad.mItems[i].mSelect.gameObject:SetActive(select == i)
    end
end

--设置御兽面板的图标文字 选中状态
function PracticeViewController:SetBeastPad(select)
    for i=1,5 do
        self._beastPad.mItems[i].mIcon.spriteName = self:GetIcon(2,i)
        self._beastPad.mItems[i].mName.text =  self:GetText(2,i)
        self._beastPad.mItems[i].mSelect.gameObject:SetActive(select == i)
    end
end

--设置修炼图标文字
function PracticeViewController:SetPracticePad(targetType,attType,level,exp)
    self._practicePad.mIcon.spriteName = self:GetIcon(targetType,attType)
    self._practicePad.mAttLabel.text = self:GetText(targetType,attType)
    self._practicePad.mAttLevelLabel.text = TipsMgr.GetTipByKey("Prac_showlv",level) 
    self._practicePad.mMaxLevelLabel.text = TipsMgr.GetTipByKey("Prac_showlimitlv",PracticeMgr.GetMaxPracticeLevel(targetType)) 
    self._practicePad.mDesLabel.text = targetType == 1 and TipsMgr.GetTipByKey("Prac_show201") or TipsMgr.GetTipByKey("Prac_show202")
    local needExp=PracticeMgr.GetPracticeLevelUpNeedExp(targetType,attType,level)
    self._practicePad.mExpSlider.value = needExp==-1 and 1 or exp/needExp
    self._practicePad.mExpSliderLabel.text = string.format("%d/%d",exp,needExp)

    local curLevelData = PracticeMgr.GetPracticeAttByType(targetType,attType,level)
    local nextLevelData = PracticeMgr.GetPracticeAttByType(targetType,attType,level+1)
    --修炼属性提升数组
    local  temp = {}
    for i=1,#curLevelData.raiseAtts do
        local raiseAttId = curLevelData.raiseAtts[i].raiseAttId
        local raiseAttValue= curLevelData.raiseAtts[i].raiseAttValue
        local raiseAttValueNext= nextLevelData.raiseAtts[i].raiseAttValue
        local attData = AttDefineData.GetDefineData(raiseAttId);
        temp[i]={}
        temp[i].name = attData.name
        temp[i].raiseAttId = raiseAttId
        temp[i].curValue = AttrCalculator.CalculPropertyUI(raiseAttValue,attData.showType,attData.showLength)
        temp[i].nextValue = AttrCalculator.CalculPropertyUI(raiseAttValueNext,attData.showType,attData.showLength)
        temp[i].showValue = string.format("%s→%s",temp[i].curValue,temp[i].nextValue)
    end
    self._practicePad.mNextLevelPad.mTableList:BuildTableList(temp)
    local segExp= 0
    --分段显示
    if curLevelData.attSegNum >1 then
        segExp = math.floor(math.floor(nextLevelData.needExp/curLevelData.attSegNum)/10) *10
        local perExp =PracticeMgr.ExpValue()
        --该段内剩余所需经验
        local leftExp = exp%segExp
        --该段内所处段位
        local segIndex =  math.floor(exp/segExp)
        --该段内剩余修炼次数
        local leftPracCount = math.floor(leftExp/perExp)
        --累计附加属性数值
        local sumAddAtt = {}
        for i=1,level do
            local data = PracticeMgr.GetPracticeAttByType(targetType,attType,i)
            if data.attSegNum>1 then
                for i=1,#data.segAtts do
                    local segAttId = data.segAtts[i].segAttId
                    local segAttValue= data.segAtts[i].segAttValue
                    if sumAddAtt[segAttId] ==  nil then sumAddAtt[segAttId] =0 end
                    if i<level then
                        sumAddAtt[segAttId] = sumAddAtt[segAttId] + segAttValue*data.attSegNum
                    else
                        sumAddAtt[segAttId] = sumAddAtt[segAttId] + segAttValue*segIndex
                    end
                end
            end
        end
        --修炼属性分段数组
        local  temSeg = {}
        for i=1,#curLevelData.segAtts do
            local segAttId = curLevelData.segAtts[i].segAttId
            local segAttValue= curLevelData.segAtts[i].segAttValue
            local attData = AttDefineData.GetDefineData(segAttId);
            temSeg[i]={}
            temSeg[i].name = attData.name
            temSeg[i].segAttId = segAttId
            temSeg[i].addValue = AttrCalculator.CalculPropertyUI(segAttValue,attData.showType,attData.showLength)
            temSeg[i].sumValue = AttrCalculator.CalculPropertyUI(sumAddAtt[segAttId],attData.showType,attData.showLength)
            temSeg[i].showAddValue = string.format("%s+%d",temSeg[i].name,temSeg[i].addValue)
            --累计增加
            temSeg[i].showSumValue=  TipsMgr.GetTipByKey("Prac_extra_info3",temSeg[i].sumValue)
        end
        self._practicePad.mExtraAttPad.mTableList:BuildTableList(temSeg)
        --剩余多少次就升级
        local mPrac_extra_info = "Prac_extra_info2"
        if segIndex == curLevelData.attSegNum then
            mPrac_extra_info = "Prac_extra_info1"
        end
        self._practicePad.mExtraAttPad.mLeftPracCount.text = TipsMgr.GetTipByKey(mPrac_extra_info,leftPracCount)
    end
    
    --单次消耗银币数量
    self._practicePad.mPracticeCost.text = string.format("%d",PracticeMgr.CostSilverNum())
    --拥有银币数量
    self._practicePad.mSilverCount.text = string.format("%d",BagMgr.GetMoney(Coin_pb.SILVER))
    local itemdata = PracticeMgr.GetCostItemInfo(targetType)
    self._practicePad.mCostItemIcon.spriteName = itemdata.icon_big
    self._practicePad.mCostItemNum.text = string.format("%d",BagMgr.GetCountByItemId(itemdata.id))
    self._practicePad.mExtraTip.transform.gameObject:SetActive(level<PracticeMgr.PracticeExtraAttMinLevel())
    self._practicePad.mExtraAttPad.obj:SetActive(level>=PracticeMgr.PracticeExtraAttMinLevel())
end

--设置共鸣修炼图标文字 symlevel共鸣等级 minlevel当前最小的经脉或御兽等级
function PracticeViewController:SetSympathyPad(targetType,attType,symlevel,minlevel)
    self._sympathyPad.mIcon.spriteName = self:GetIcon(targetType,attType)
    self._sympathyPad.mAttLabel.text = self:GetText(targetType,attType)
    self._sympathyPad.mAttLevelLabel.text = TipsMgr.GetTipByKey("Prac_showlv",symlevel)
    self._sympathyPad.mDesLabel.text = targetType == 1 and TipsMgr.GetTipByKey("Prac_show201") or TipsMgr.GetTipByKey("Prac_show202")
    local needMinLevel = PracticeMgr.GetSymNeedLevel(targetType,symlevel)
    if minlevel>=needMinLevel then--可升级
        self._sympathyPad.mCanLevelUp.text = targetType==1 and TipsMgr.GetTipByKey("Prac_show1312") or TipsMgr.GetTipByKey("Prac_show1322")
    else--不可升级
        self._sympathyPad.mCanLevelUp.text =  targetType==1 and TipsMgr.GetTipByKey("Prac_show1311",needMinLevel) or TipsMgr.GetTipByKey("Prac_show1321",needMinLevel)
    end
    local curLevelData = PracticeMgr.GetPracticeAttByType(targetType,attType,symlevel)
    local nextLevelData = PracticeMgr.GetPracticeAttByType(targetType,attType,symlevel+1)
    --共鸣属性提升数组
    local  temp = {}
    for i=1,#curLevelData.raiseAtts do
        local raiseAttId = curLevelData.raiseAtts[i].raiseAttId
        local raiseAttValue= curLevelData.raiseAtts[i].raiseAttValue
        local raiseAttValueNext= nextLevelData.raiseAtts[i].raiseAttValue
        local attData = AttDefineData.GetDefineData(raiseAttId);
        temp[i]={}
        temp[i].name = attData.name
        temp[i].raiseAttId = raiseAttId
        temp[i].curValue = AttrCalculator.CalculPropertyUI(raiseAttValue,attData.showType,attData.showLength)
        temp[i].nextValue = AttrCalculator.CalculPropertyUI(raiseAttValueNext,attData.showType,attData.showLength)
        temp[i].showCurValue = string.format("%s→%s",temp[i].curValue,temp[i].nextValue)
        temp[i].showNextValue = string.format("%s→%s",temp[i].curValue,temp[i].nextValue)
    end
    self._sympathyPad.SymAttPad.mCurTableList:BuildTableList(temp)
    self._sympathyPad.SymAttPad.mNextTableList:BuildTableList(temp)
end

function PracticeViewController:ShowPracticePad(show)
    self._practicePad.obj:SetActive(show)
end

function PracticeViewController:ShowSympathyPad(show)
    self._sympathyPad.obj:SetActive(show)
end

--界面显示 修炼类型 属性类型 当前属性等级 共鸣等级 最小属性等级 当前属性经验
function PracticeViewController:ShowPad(targetType,attType,level,symlevel,minlevel,exp)
    local symShow = attType==5 --and minlevel>=PracticeMgr.SymNeedMinLevel()
    self._sympathyPad.obj:SetActive(symShow)
    self._practicePad.obj:SetActive(not symShow)
    self:SetMeridianPad(targetType==1 and attType or -1 )
    self:SetBeastPad(targetType==2 and attType or -1 )
    if symShow then
        self:SetSympathyPad(targetType,attType,symlevel,minlevel)
    else
        self:SetPracticePad(targetType,attType,level,exp)
    end
end

function PracticeViewController:CheckSymCanLevelUp(targetType)
    local canlevel = PracticeMgr.SymCanLevevlUp(targetType)
    local root = targetType == 1 and self._meridianPad.mItems[5].obj or self._beastPad.mItems[5].obj
    if canlevel then
        --可升级
        local resId = 400400092
        if not mEffectLoaders[targetType] then
            local effectLoader = LoaderMgr.CreateEffectLoader();
            effectLoader:LoadObject(resId);
            effectLoader:SetParent(root.transform,true);
            effectLoader:SetSortOrder(500);
            mEffectLoaders[targetType] = effectLoader;
        end
        mEffectLoaders[targetType]:SetActive(true,true);
    else
        --不可升级
        if mEffectLoaders[targetType] then
            mEffectLoaders[targetType]:SetActive(false);
        end
    end
end

function PracticeViewController:OnUpdateMoney()
    --拥有银币数量
    if  self._practicePad and self._practicePad.mSilverCount then
        self._practicePad.mSilverCount.text = string.format("%d",BagMgr.GetMoney(Coin_pb.SILVER))
    end
end

function PracticeViewController:OnSelectItem(targetType,attType)
    PracticeMgr.OnSelectItem(targetType,attType)
    self:ShowPad(targetType,attType,PracticeMgr.CurrentLevel(),PracticeMgr.CurrentSymLevel(),PracticeMgr.CurrentMinLevel(),PracticeMgr.CurrentExp())
end

function PracticeViewController:OnSeeTip()
    PracticeMgr.CurrentSymLevel()
end

function PracticeViewController:OnTrainOnce()
    PracticeMgr.PracticeOnce()
end

function PracticeViewController:OnTrainBatch()
    PracticeMgr.PracticeBatch()
end

function PracticeViewController:OnUseItem()
    PracticeMgr.UseItem()
end

function PracticeViewController:OnSymphyLevelUp()
    PracticeMgr.SymphyLevelUp()
end

function PracticeViewController:OnAddSilver()
    UIMgr.ShowUI(AllUI.UI_Bag_GoldExchange,nil,nil,nil,nil,true,2,1)
end

function PracticeViewController:Destory()
    GameEvent.UnReg(EVT.PRACTICE,EVT.SELECT_ITEM,self.OnSelectItem,self);
    GameEvent.UnReg(EVT.PRACTICE,EVT.SEE_TIP,self.OnSeeTip,self);
    GameEvent.UnReg(EVT.PRACTICE,EVT.TRAIN_ONCE,self.OnTrainOnce,self);
    GameEvent.UnReg(EVT.PRACTICE,EVT.TRAIN_BTACH,self.OnTrainBatch,self);
    GameEvent.UnReg(EVT.PRACTICE,EVT.USE_ITEM,self.OnUseItem,self);
    GameEvent.UnReg(EVT.PRACTICE,EVT.SYMPHY_LEVEL,self.OnSymphyLevelUp,self);
    GameEvent.UnReg(EVT.PRACTICE,EVT.ADD_SILVER,self.OnAddSilver,self);
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_GETCOIN, self.OnUpdateMoney,self);
    for k,loader in pairs(mEffectLoaders) do
        LoaderMgr.DeleteLoader(loader);
        mEffectLoaders[k] = nil;
    end
end

return PracticeViewController