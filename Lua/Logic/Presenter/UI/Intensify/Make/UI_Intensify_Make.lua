module("UI_Intensify_Make", package.seeall);

require("Logic/Presenter/UI/Intensify/Make/EquipMakeModule")
local m_equipMakeLeftClass = require("Logic/Presenter/UI/Intensify/Make/EquipMake_Left")
local m_equipMakeRightClass = require("Logic/Presenter/UI/Intensify/Make/EquipMake_Right")
local m_equipMakeLeft;
local m_equipMakeRight;
local m_self;
local m_leftTransfrom;
local m_rightTransfrom;
local m_leftEventIdBase = 20;
local m_rightEventIdBase = 800;
local m_currentSeletEquipMake = -1;

function OnCreate(self)
    m_Self = self;
    m_leftTransfrom = self:Find("Offset/LeftPanel");
    m_rightTransfrom = self:Find("Offset");
    m_equipMakeLeft = m_equipMakeLeftClass.new(m_leftTransfrom, m_leftEventIdBase , OnSelectedEquipMakeItem);
    m_equipMakeRight = m_equipMakeRightClass.new(m_rightTransfrom, m_rightEventIdBase);
    --UserData.GetLevel();
    m_equipMakeLeft:SetEquipMakeLevel(20);
end

function OnEnable(self)
	RegEvent(self)
end

function OnDisable(self)
	UnRegEvent(self)
end


function RegEvent(self)
    GameEvent.Reg(EVT.EQUIPMAKE, EVT.EQUIPMAKE_REFRESH, OnEquipMakeFinish)
    GameEvent.Reg(EVT.EQUIPMAKE, EVT.EQUIPMAKE_RECEIVEMAKEVALUE_REWARD,OnReceiveMakeValueReward)
end

function UnRegEvent(self)
    GameEvent.UnReg(EVT.EQUIPMAKE, EVT.EQUIPMAKE_REFRESH, OnEquipMakeFinish)
    GameEvent.UnReg(EVT.EQUIPMAKE, EVT.EQUIPMAKE_RECEIVEMAKEVALUE_REWARD,OnReceiveMakeValueReward)
end

function OnClick(go, id)
    if id >= m_rightEventIdBase then       
        m_equipMakeRight:OnClick(go,id);
    elseif id >= m_leftEventIdBase then
        m_equipMakeLeft:OnClick(go,id);
    
    end
end

--选中打造装备的回调 data中包含EquipMake的id
function OnSelectedEquipMakeItem(data)
    m_currentSeletEquipMake = data.id;
    EquipMakeModule.Init(data.id);
    m_equipMakeRight:RefreshInfo(data.id);
end 

function OnEquipMakeFinish()  
    EquipMakeModule.Init(m_currentSeletEquipMake);
    m_equipMakeRight:RefreshInfo(m_currentSeletEquipMake);
end

function OnReceiveMakeValueReward(data)
   m_equipMakeRight:ReceiveMakeValueReward(data.makeValue);
end

return UI_Intensify_Make