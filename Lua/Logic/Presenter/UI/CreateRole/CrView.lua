local CrView = class("CrView",nil)
local CrRoleController = require("Logic/Presenter/UI/CreateRole/CrRoleController")
local CrSceneController= require("Logic/Presenter/UI/CreateRole/CrSceneController")
local LuaObjs = GameBase.LuaObjs;
require("Logic/Presenter/UI/CreateRole/UI_Login_CreateRole")

function CrView:ctor()
    self._mSceneControl = CrSceneController.new()
    self._mRoleControl = CrRoleController.new()
    self._mRacialIndex =1
    self._mProfessionIndex  =1
    self._playerName =""
    self._mRoleParent=nil
    self._preShowCallback = nil
end

function CrView:Enter()
    
end

function CrView:MoveParent()
    if self._mRoleParent==nil then
        self._mRoleParent = LuaObjs.NewGameObject(false);
		LuaObjs.ResetTrans(self._mRoleParent); 
		LuaObjs.SetLocalScale(self._mRoleParent,0,0,0,false);
	else
		LuaObjs.SetActive(self._mRoleParent,true);
    end
    LuaObjs.SetName(self._mRoleParent, string.format("Role%d-%d",self._mRacialIndex,self._mProfessionIndex));
    LuaObjs.GetTransform(self._mRoleParent).localRotation =Quaternion.identity
    LuaObjs.SetLocalScale(self._mRoleParent,0,0,0,false);
end


function CrView:ResetParent()
    if self._mRoleParent==nil then
        self._mRoleParent = LuaObjs.NewGameObject(false);
		LuaObjs.ResetTrans(self._mRoleParent); 
		LuaObjs.SetLocalScale(self._mRoleParent,1,1,1,false);
	else
		LuaObjs.SetActive(self._mRoleParent,true);
    end
    LuaObjs.SetName(self._mRoleParent, string.format("Role%d-%d",self._mRacialIndex,self._mProfessionIndex));
    LuaObjs.GetTransform(self._mRoleParent).localRotation =Quaternion.identity
    LuaObjs.SetLocalScale(self._mRoleParent,1,1,1,false);
end

function CrView:SetRacialIndex(index)
    self._mRacialIndex =index
end

function CrView:SetProfessionIndex(index)
    self._mProfessionIndex = index
end


function CrView:RotateRole(delta)
    if self._mRoleControl:CanRotate() then
        local speed = ConfigData.GetIntValue("model_rotate_speed") or 0.5
        local eul = delta * speed + LuaObjs.GetTransform(self._mRoleParent).eulerAngles.y;
        LuaObjs.GetTransform(self._mRoleParent).rotation = Quaternion.Euler(0,eul,0); 
    end
end

function CrView.OnRacialChanged(self,value,oldvalue)
    return value
end

function CrView.OnProfessionChanged(self,value,oldvalue)
    return value
end

function CrView.OnPlayerNameChanged(self,value,oldvalue)
    UI_Login_CreateRole.SetInputName(value)
end

function CrView:InitUI(rlist)
    UI_Login_CreateRole.SetRacialData(rlist)
end

function CrView:UpdateUI(plist,chooseIndex,res,proAtt)
    UI_Login_CreateRole.SetAllJobButton(plist,chooseIndex)
    UI_Login_CreateRole.setRoleInfo(res.professionFeatureIcon,res.professionNameIcon,res.descriptionKey,proAtt,res.descriptionBgEffect,res.descriptionEffect)
end

function CrView:ChangeRole(sceneId,cameraAniId,modelId,animId,actionTime,nearpos,nearrot,nearscal)
    UI_Login_CreateRole.LockInput(true)
    self:MoveParent()
    if self._mSceneControl ==nil then
        self._mSceneControl = CrSceneController.new()
    end
    self._mSceneControl:SetActionTime(actionTime)
    self._mSceneControl:SetNearCameraTransform(nearpos,nearrot,nearscal)
    self._mSceneControl:ChangeScene(sceneId,cameraAniId,function ()
        self:LoadModel(modelId,animId,actionTime)
    end)
end

function CrView:SetPreShowCallback(callback)
    self._preShowCallback=callback
   
end

function CrView:LoadModel(modelId,animId,actionTime)
    if self._mRoleControl == nil then
        self._mRoleControl = CrRoleController.new(modelId,animId)
    end
    self._mRoleControl:SetActionTime(actionTime)
    self._mRoleControl:Load(LuaObjs.GetTransform(self._mRoleParent),function ()
        local obj =self._mRoleControl:GetAnimator()
        if obj then
            self._mSceneControl:InitSceneTimeline(obj)
        end
        UI_Login_CreateRole.LockInput(false)
        if self._preShowCallback then
            self._preShowCallback()
            self._preShowCallback= nil
        end
        self:ResetParent()
        self:BeginShow()
    end,modelId,animId)
end

function CrView:BeginShow()
    self._mSceneControl:BeginShow()
    self._mRoleControl:BeginShow()
end

function CrView:OnPinchIn(gesture)
    self._mSceneControl:OnPinchIn(gesture)
end

function CrView:OnPinchOut(gesture)
    self._mSceneControl:OnPinchOut(gesture)
end

function CrView:OnInputChange(name)
    --self._viewBind._playerName = name
    UI_Login_CreateRole.SetInputName(name)
end

function CrView:Destory()
    self._mSceneControl:Destory()
    self._mRoleControl:Destory()
	LuaObjs.Destroy(self._mRoleParent)
end

return CrView