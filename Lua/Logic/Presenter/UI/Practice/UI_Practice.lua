module("UI_Practice",package.seeall)
local SimapleTableList = require("Logic/Presenter/UI/Practice/SimapleTableList")
local _self = {}

function OnCreate(self)
    _self._ui=self
    _self._meridianPad = {}
    --御兽面板
    _self._beastPad ={}
    --修炼升级界面
    _self._practicePad ={}
    --共鸣生就界面
    _self._sympathyPad ={}

    _self._meridianPad.obj = self:Find("Offset/MeridianPad").gameObject
    _self._meridianPad.mTitle=  self:FindComponent("UILabel", "Offset/MeridianPad/TitleBg/Title");
    _self._meridianPad.mItems = {}
    for i=1,5 do
        local  transform= self:Find(string.format("Offset/MeridianPad/Item%d",i))
        _self._meridianPad.mItems[i]={}
        _self._meridianPad.mItems[i].obj =transform.gameObject;
        _self._meridianPad.mItems[i].mIcon = transform:Find("Icon"):GetComponent("UISprite");
        _self._meridianPad.mItems[i].mName = transform:Find("Name"):GetComponent("UILabel");
        _self._meridianPad.mItems[i].mSelect = transform:Find("Select"):GetComponent("UISprite");
    end

    _self._beastPad.obj = self:Find("Offset/BeastPad").gameObject
    _self._beastPad.mTitle=  self:FindComponent("UILabel", "Offset/BeastPad/TitleBg/Title");
    _self._beastPad.mItems = {}
    for i=1,5 do
        local  transform= self:Find(string.format("Offset/BeastPad/Item%d",i))
        _self._beastPad.mItems[i]={}
        _self._beastPad.mItems[i].obj =transform.gameObject;
        _self._beastPad.mItems[i].mIcon = transform:Find("Icon"):GetComponent("UISprite");
        _self._beastPad.mItems[i].mName = transform:Find("Name"):GetComponent("UILabel");
        _self._beastPad.mItems[i].mSelect = transform:Find("Select"):GetComponent("UISprite");
    end

    _self._practicePad.obj = self:Find("Offset/PracticePad").gameObject
    _self._practicePad.mIcon=  self:FindComponent("UISprite", "Offset/PracticePad/PracItem/Icon");
    _self._practicePad.mAttLabel=  self:FindComponent("UILabel", "Offset/PracticePad/Name");
    _self._practicePad.mAttLevelLabel=  self:FindComponent("UILabel", "Offset/PracticePad/AttLevel");
    _self._practicePad.mMaxLevelLabel=  self:FindComponent("UILabel", "Offset/PracticePad/MaxLevel");
    _self._practicePad.mDesLabel=  self:FindComponent("UILabel", "Offset/PracticePad/DesLabel");
    _self._practicePad.mExpSlider =  self:FindComponent("UISlider", "Offset/PracticePad/ExpSlider");
    _self._practicePad.mExpSliderLabel=  self:FindComponent("UILabel", "Offset/PracticePad/ExpSliderLabel");
     --单次消耗银币数量
     _self._practicePad.mPracticeCost =  self:FindComponent("UILabel", "Offset/PracticePad/PracOnceCostTip/Num");
     --拥有银币数量
     _self._practicePad.mSilverCount =  self:FindComponent("UILabel", "Offset/PracticePad/OwnMoney/Num");
     _self._practicePad.mCostItemIcon =  self:FindComponent("UISprite", "Offset/PracticePad/CostItem/Icon");
     _self._practicePad.mCostItemNum =  self:FindComponent("UILabel", "Offset/PracticePad/CostItem/Num");

     _self._practicePad.mNextLevelPad = {}
     _self._practicePad.mNextLevelPad.obj =  self:Find("Offset/PracticePad/NextLevelPad").gameObject;
     local  ntransform= _self._practicePad.mNextLevelPad.obj.transform
     local mAttTable = ntransform:Find("AttTable"):GetComponent("UITable");
     local mAttItem = ntransform:Find("AttItem")
     _self._practicePad.mNextLevelPad.mTableList = SimapleTableList.new(_self._ui,mAttItem.gameObject,mAttTable,NextCellUpdate)

     _self._practicePad.mExtraAttPad = {}
     _self._practicePad.mExtraTip =  self:FindComponent("UILabel","Offset/PracticePad/ExtraAttPad/ExtraTip")
     local  atransform =  self:Find("Offset/PracticePad/ExtraAttPad")
     _self._practicePad.mExtraAttPad.obj =  atransform.gameObject;
     local mAttTable1 = atransform:Find("AddPad/AttTable"):GetComponent("UITable");
     local mAttItem1 = atransform:Find("AddPad/AttItem")
     _self._practicePad.mExtraAttPad.mLeftPracCount =  atransform:Find("AddPad/LeftPracCount"):GetComponent("UILabel");
     _self._practicePad.mExtraAttPad.mSumAtt =  atransform:Find("AddPad/SumAtt"):GetComponent("UILabel");
     _self._practicePad.mExtraAttPad.mTableList = SimapleTableList.new(_self._ui,mAttItem1.gameObject,mAttTable1,ExtraCellUpdate)

     _self._sympathyPad.obj = self:Find("Offset/SympathyPad").gameObject
     _self._sympathyPad.mIcon=  self:FindComponent("UISprite", "Offset/SympathyPad/SymItem/Icon");
     _self._sympathyPad.mAttLabel=  self:FindComponent("UILabel", "Offset/SympathyPad/Name");
     _self._sympathyPad.mAttLevelLabel=  self:FindComponent("UILabel", "Offset/SympathyPad/AttLevel");
     _self._sympathyPad.mDesLabel =  self:FindComponent("UILabel", "Offset/SympathyPad/DesLabel");
     _self._sympathyPad.mCanLevelUp =  self:FindComponent("UILabel", "Offset/SympathyPad/CanLevelUp");
     _self._sympathyPad.SymAttPad = {}
     _self._sympathyPad.SymAttPad.obj =  self:Find("Offset/SympathyPad/SymAttPad").gameObject;
     local  stransform= _self._sympathyPad.SymAttPad.obj.transform
     local mCurAttTable = stransform:Find("CurAttTable"):GetComponent("UITable");
     local mNextAttTable = stransform:Find("NextAttTable"):GetComponent("UITable");
     local mAttItem2 = stransform:Find("AttItem")
     _self._sympathyPad.SymAttPad.mCurTitle =  stransform:Find("CurTitle"):GetComponent("UILable");
     _self._sympathyPad.SymAttPad.mNextTitle =  stransform:Find("NextTitle"):GetComponent("UILable");
     _self._sympathyPad.SymAttPad.mCurTableList = SimapleTableList.new(_self._ui,mAttItem2.gameObject,mCurAttTable,CurAttCellUpdate)
     _self._sympathyPad.SymAttPad.mNextTableList = SimapleTableList.new(_self._ui,mAttItem2.gameObject,mNextAttTable,NextAttCellUpdate)
end

function GetUI()
    return _self
end

function OnEnable(self)
    RegEvent(self)
end

function OnDisable(self)
    UnRegEvent(self)
end

local mEvents = {};
function RegEvent(self)
end

function UnRegEvent(self)
    mEvents = {};
end

function NextCellUpdate(item,data)
	if item.init==nil then
		item.name = item.transform:Find("AttName"):GetComponent("UILabel");
		item.value = item.transform:Find("AttValue"):GetComponent("UILabel");
		item.init =true
	end
	if item and data then
        item.name.text = data.name
        item.value.text = data.showValue
	end
end

function ExtraCellUpdate(item,data)
	if item.init==nil then
		item.name = item.transform:Find("AttName"):GetComponent("UILabel");
		item.value = item.transform:Find("AttValue"):GetComponent("UILabel");
		item.init =true
	end
	if item and data then
        item.name.text = data.showAddValue
        item.value.text = data.showSumValue
	end
end

function CurAttCellUpdate(item,data)
	if item.init==nil then
		item.name = item.transform:Find("AttName"):GetComponent("UILabel");
		item.value = item.transform:Find("AttValue"):GetComponent("UILabel");
		item.init =true
	end
	if item and data then
        item.name.text = data.name
        item.value.text = data.showCurValue
	end
end

function NextAttCellUpdate(item,data)
	if item.init==nil then
		item.name = item.transform:Find("AttName"):GetComponent("UILabel");
		item.value = item.transform:Find("AttValue"):GetComponent("UILabel");
		item.init =true
	end
	if item and data then
        item.name.text = data.name
        item.value.text = data.showNextValue
	end
end

function OnClick(go, id)
    if id>=11 and id<=15 then
        local attType = math.floor(id%10)
        GameEvent.Trigger(EVT.PRACTICE,EVT.SELECT_ITEM,1,attType);
    elseif id>=21 and id<=25 then
        local attType = math.floor(id%10)
        GameEvent.Trigger(EVT.PRACTICE,EVT.SELECT_ITEM,2,attType);
    elseif id ==31 then -- 等级信息
        GameEvent.Trigger(EVT.PRACTICE,EVT.SEE_TIP);
    elseif id ==32 then -- 修炼一次
        GameEvent.Trigger(EVT.PRACTICE,EVT.TRAIN_ONCE);
    elseif id ==33 then -- 修炼十次
        GameEvent.Trigger(EVT.PRACTICE,EVT.TRAIN_BTACH);
    elseif id ==34 then -- 使用道具
        GameEvent.Trigger(EVT.PRACTICE,EVT.USE_ITEM);
    elseif id ==35 then -- 添加银币
        GameEvent.Trigger(EVT.PRACTICE,EVT.ADD_SILVER);
    elseif id ==41 then -- 共鸣升级
        GameEvent.Trigger(EVT.PRACTICE,EVT.SYMPHY_LEVEL);
    end
end

return UI_Practice

