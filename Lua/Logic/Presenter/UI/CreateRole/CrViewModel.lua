
local CrView= require("Logic/Presenter/UI/CreateRole/CrView")
local CrModel= require("Logic/Presenter/UI/CreateRole/CrModel")
local CrViewModel = class("CrViewModel",nil)

function CrViewModel:ctor()
    self._model = CrModel.new()
    self._view = CrView.new()

    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_RADNOMNAME,self.RandomName,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_CREATE,self.CreateRoleAndStart,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_PINCHINCAMERA,self.OnPinchIn,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_PINCHOUTCAMERA,self.OnPinchOut,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_CHANGERICE,self.ChangeRice,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_CHANGEPRO,self.ChangeProfession,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_ROTATEROLE,self.RotateRole,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_CHANGENAME,self.OnInputChange,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_CLOSE,self.OnClose,self);
    GameEvent.Reg(EVT.CREATEROLE,EVT.CREATEROLE_PLAYFINISHED,self.OnFinishPlay,self);
end

function CrViewModel.OnRacialChanged(self,value,oldvalue)
    self._model:SetRacialIndex(value)
    self._model:SetProfessionIndex(1)
    self:UpdateUI(1)
    self:ChangeRole()
end

function CrViewModel.OnProfessionChanged(self,value,oldvalue)
    self._model:SetProfessionIndex(value)
    self:UpdateUI(value)
    self:ChangeRole()
end

function CrViewModel.OnPlayerNameChanged(self,value,oldvalue)
    local name = value;
    local length,found,len =GameUtils.StringCharactorLength(name,{",","，"},7);
    if length>7 then
        local mRightName = string.sub(name,1,len)
        self._model:SetPlayerName(mRightName)
        TipsMgr.TipByKey("createrole_name_fail_2");
    else
        self._model:SetPlayerName(name)
    end
end

function CrViewModel:Enter()
    local res = self._model:GetCurrentJobRes()
    local modelId = res.modelID
	local animId = res.controllerID
	local sceneId = res.sceneID
    local cameraAniId = res.cameraAnimationID
    
end

function CrViewModel:OnLoadingOpen(callObj)
    local res = self._model:GetCurrentJobRes()
	local sceneId = res.sceneID
    ResMgr.LoadSceneAsync(sceneId,callObj)
end

function CrViewModel:OnSceneLoad(callObj)
   -- self:Show(callObj)
    --self:Show()
end

function CrViewModel:LoadFinish(callObj,preshowcallback)
    self:Show(callObj)
    self._view:SetPreShowCallback(preshowcallback)
    self:ChangeRole()
end


function CrViewModel:Show(callObj)
    UIMgr.ShowUI(AllUI.UI_Login_CreateRole,self,self.OnCreateRoleOpen);
end

function CrViewModel:UnShow()
    UIMgr.UnShowUI(AllUI.UI_Login_CreateRole);
end

function CrViewModel:OnCreateRoleOpen()
    self:InitUI()
    self:UpdateUI(self._model:GetProfessionIndex())
    --self:ChangeRole()
end

function CrViewModel:InitUI()
    local rlist = self._model:GetRacialList()
    self._view:InitUI(rlist)
end

function CrViewModel:UpdateUI(chooseindex)
    local plist = self._model:GetProfessionList()
    local res = self._model:GetCurrentJobRes()
    local proAtt = self._model:GetProfessionAtt()
    self._view:UpdateUI(plist,chooseindex,res,proAtt)
end

function CrViewModel:ChangeRole()
    local res = self._model:GetCurrentJobRes()
    local modelId = res.modelID
	local animId = res.controllerID
	local sceneId = res.sceneID
    local cameraAniId = res.cameraAnimationID
    local actionTime = res.actionTime
    local nearpos =  math.ConvertProtoV3(res.nearCameraPosition)
    local nearrot =  math.ConvertProtoV3(res.nearCameraRotation)
    local nearscal =  math.ConvertProtoV3(res.nearCameraScale)
    self._view:ChangeRole(sceneId,cameraAniId,modelId,animId,actionTime,nearpos,nearrot,nearscal)
end

function CrViewModel:OnFinishPlay()
end

--创建角色 开始游戏
function CrViewModel:CreateRoleAndStart(name)
    local mPlayerName = self._model:GetPlayerName()
    local hasIlegal = string.ContainsIllegalWord(mPlayerName)
    if hasIlegal then
         TipsMgr.TipByKey("createrole_name_fail_5");
    else
        local mCurRice = self._model:GetRacial()
        local mCurJob = self._model:GetProfession()
        local length,found,len =GameUtils.StringCharactorLength(mPlayerName,{",","，"},7);
        if length>0 and length<2 then
            TipsMgr.TipByKey("createrole_name_fail_1");
        elseif length==0 then
            TipsMgr.TipByKey("createrole_name_fail_3");
        elseif length>7 then
            TipsMgr.TipByKey("createrole_name_fail_2");
        else
            GameLog.Log("create role on click->%s", mPlayerName);
            LoginMgr.RequestCreateRole(mPlayerName,mCurRice,mCurJob);
        end
    end
end

--随机名称
function CrViewModel:RandomName()
	local malename = RandomNameData.GetRandomMaleName();
	local femalename = RandomNameData.GetRandomFemaleName()
    local N =  math.random(1,2);
    local name = N==1 and malename or femalename
    local hasIlegal = string.ContainsIllegalWord(name)
    --还有非法字符重新随机一个
    if hasIlegal then
        self:RandomName()
    else
        self:OnInputChange(name)
    end
   
end

function CrViewModel:RotateRole(gesture)
    local delta = -1*gesture.deltaPosition.x;
    self._view:RotateRole(delta)
end

function CrViewModel:OnPinchIn(gesture)
    self._view:OnPinchIn(gesture)
end

function CrViewModel:OnPinchOut(gesture)
    self._view:OnPinchOut(gesture)
end

function CrViewModel:OnInputChange(name)
    local tname = string.Replace(name," ","");
    local length,found,len =GameUtils.StringCharactorLength(tname,{",","，"},7);
    if length>7 then
        local mRightName = string.sub(tname,1,len)
        self._model:SetPlayerName(mRightName)
        self._view:OnInputChange(mRightName)
        TipsMgr.TipByKey("createrole_name_fail_2");
    else
        self._model:SetPlayerName(tname)
        self._view:OnInputChange(tname)
    end
end

function CrViewModel:OnClose()
    GameNet.CloseSocket(GameConfig.GATE_SOCKET);
    UIMgr.ShowUI(AllUI.UI_Login_SelectServerRole)
end
 

function CrViewModel:ChangeRice(tCurRice)
    if self._model:GetRacialIndex()==tCurRice then return end
    self._model:SetRacialIndex(tCurRice)
    self._model:SetProfessionIndex(1)
    self._view:SetRacialIndex(tCurRice)
    self._view:SetProfessionIndex(1)
    self:UpdateUI(1)
    self:ChangeRole()
end

function CrViewModel:ChangeProfession(tCurJob)
    if self._model:GetProfessionIndex()==tCurJob then return end
    self._model:SetProfessionIndex(tCurJob)
    self._view:SetProfessionIndex(tCurJob)
    self:UpdateUI(tCurJob)
    self:ChangeRole()
end

function CrViewModel:Destory()
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_RADNOMNAME,self.RandomName,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_CREATE,self.CreateRoleAndStart,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_PINCHINCAMERA,self.OnPinchIn,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_PINCHOUTCAMERA,self.OnPinchOut,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_CHANGERICE,self.ChangeRice,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_CHANGEPRO,self.ChangeProfession,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_ROTATEROLE,self.RotateRole,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_CHANGENAME,self.OnInputChange,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_CLOSE,self.OnClose,self);
    GameEvent.UnReg(EVT.CREATEROLE,EVT.CREATEROLE_PLAYFINISHED,self.OnFinishPlay,self);
    self._view:Destory()
    self._model:Destory()
    self._view = nil
    self._model = nil
end

return CrViewModel