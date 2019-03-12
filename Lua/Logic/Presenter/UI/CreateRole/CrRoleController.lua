--创建角色的模型控制类型
local CrRoleController = class("CrRoleController",nil)
local mActorTime = 10000

function CrRoleController:ctor(modelid,animctrid)
    self._modelId = modelid;
    self._modelAnimatorControllerID = animctrid;
    self._modelLoader = LoaderMgr.CreateModelLoader();
    self._animationTime = 0
    self._animationState = -1
    UpdateBeat:Add(self.Update,self);
end

function CrRoleController:Load(parent,callback,modelid,animctrid)
    if modelid then
        self._modelId = modelid;
    end
    if animctrid then
        self._modelAnimatorControllerID = animctrid;
    end
	self._modelLoader:LoadObject(self._modelId,self._modelAnimatorControllerID,true,nil,nil,callback,self);
	self._modelLoader:SetActive(true);
    self._modelLoader:SetLayer(CameraLayer.EntityLayer);
	self._modelLoader:SetParent(parent,true);
    self._modelLoader:SetRenderOffScreen();
end

function CrRoleController:GetRoleData()

end

function CrRoleController:GetAnimator()
    return self._modelLoader._loadScript:GetAnimator()
end

function CrRoleController:Play(actName,fadeInTime)
    self._modelLoader._loadScript:PlayAnimation(actName,fadeInTime or 0.3);
end

function CrRoleController:SetActive(active)
    self._modelLoader:SetActive(active)
end

function CrRoleController:SetActionTime(t)
    mActorTime = t ==nil and 10000 or t
end

--是否允许旋转
function CrRoleController:CanRotate()
    return self._animationState == -1
end

--开始动作表现
function CrRoleController:BeginShow()
    self:ResetState()
    self._modelLoader:SetLocalScale(Vector3.one);
    self._animationState=1
end

--重置资源状态
function CrRoleController:ResetState()
    self._animationState = -1
    self._animationTime = 0
end

function CrRoleController:Update()
    if self._animationState == 1 then
          --  self:Play("SelectRole",0,false)
            self._animationTime = 0
            self._animationState = 2
    elseif  self._animationState == 2 then
        self._animationTime = self._animationTime+GameTime.deltaTime_L
        if  self._animationTime >= mActorTime then
         --   self:Play("Stand_Atk",0,false);
            self._animationTime = 0
            self._animationState= -1
        end
    end
end

function CrRoleController:Destory()
    UpdateBeat:Remove(self.Update,self);
    LoaderMgr.DeleteLoader(self._modelLoader)
end

return CrRoleController