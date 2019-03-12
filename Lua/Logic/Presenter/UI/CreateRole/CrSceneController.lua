--创建角色的场景控制类型
local CrSceneController = class("CrSceneController",nil)
--相机移动相关
local mCameraMove = 4
local mCameraMoveTime = 0
local mNormalCamera = { position = Vector3(0.04597203,1.069095,4.240279),
						rotation =  Vector3(-5.077789,-179.4563,-0.3490601),
						scale= Vector3(0.1043512,0.1043512,0.1043512)}
local mZoomInCamera  = {
						position =  Vector3(0.001,1.66,1.4),
						rotation = Vector3(0.8840001,179.491,-0.257),
						scale= Vector3(0.1043512,0.1043512,0.1043512)}

--控制参数
local mPlaying=0
local mPlayingTime =0
local mPlayDuration = 8430

function CrSceneController:ctor()
    self._camera = nil
    self.sceneLoadCallback = nil
    self._camAniId = nil;
    self._sceneId = nil
    self._cameraAniLoader =  LoaderMgr.CreateGameObjectLoader();
    UpdateBeat:Add(self.Update,self);
end

function CrSceneController:GetMainCamera()
    -- if self._camera then
    --     UnityEngine.GameObject.DestroyImmediate(self._camera);
    --     self._camera = nil
    -- end
    self._camera = UnityEngine.GameObject.Find("Main Camera_ani");
	if tolua.isnull(self._camera) then
		self._camera = UnityEngine.GameObject.Find("Main Camera");
    end
    if tolua.isnull(self._camera) then
		self._camera = UnityEngine.Camera.main;
    end
    if self._camera then
        self._camAnimator = self._camera:GetComponent(typeof(UnityEngine.Animator));
    end
end

function CrSceneController:GetDirector()
    if self._director==nil then
        local obj = UnityEngine.GameObject.Find("PlayerTimeline")
        if obj then
            self._director =obj:GetComponent(typeof(UnityEngine.Playables.PlayableDirector))
        end
    end
    return self._director
end

function CrSceneController:Init()
    if self.sceneLoadCallback then
        self.sceneLoadCallback()
    end
end

function CrSceneController:InitSceneTimeline(obj)
    self:GetMainCamera()
    if self._director == nil then self:GetDirector() end
    if self._director then
        GameUtil.GameFunc.ReBindTimelineObj(self._director,"playertrack",obj)
    else
    end
end

function CrSceneController:OnSceneLoad(sceneName)
    self:Init()
end

function CrSceneController:ChangeScene(sceneid,camAniId,callback)
    self._director=nil
    self.sceneLoadCallback = callback
    self._camAniId = camAniId
   -- if self._sceneId == sceneid then
    --    self:OnSceneLoad(self._sceneId)
    --else
        self._sceneId = sceneid
        ResMgr.LoadSceneAsync(self._sceneId,self)
   -- end
end

--重置相机
function CrSceneController:ResetCamera()
    mCameraMove = 4
end


function CrSceneController:BeginShow()
    if self._camAnimator then self._camAnimator.enabled =true end
    if self._director then
        self._director.enabled = true
        self._director.time = 0
        self._director:Play()
    end
    mCameraMove = 4
    mPlaying = 1
    mPlayingTime = 0
end

function CrSceneController:SetActionTime(actionTime)
    mPlayDuration = actionTime
end

function CrSceneController:SetNearCameraTransform(nearpos,nearrot,nearscal)
    mZoomInCamera.position =  nearpos
    mZoomInCamera.rotation = nearrot
    mZoomInCamera.scale= nearscal
end

function CrSceneController:IsPlaying()
	return mPlaying == 1
end

function CrSceneController:OnPinchIn(gesture)
	if gesture.touchCount == 2 then
		if mCameraMove == 3 then
			mCameraMove = 2 ;
		end
	end
end

--拉远camera
function CrSceneController:OnPinchOut(gesture)
	if gesture.touchCount == 2 then
		if mCameraMove == 4 then
			mCameraMove = 1 ;
		end
	end
end

function CrSceneController:Update()
    if mPlaying==1 then
        mPlayingTime =mPlayingTime+ GameTime.deltaTime_L
		if mPlayingTime>=mPlayDuration  then
            if self._camAnimator then self._camAnimator.enabled =false end
            mPlaying = 2
            if self._camera then
                mNormalCamera.position = self._camera.transform.localPosition
                mNormalCamera.rotation = self._camera.transform.localRotation
                mNormalCamera.scale = self._camera.transform.localScale
            end
            GameEvent.Trigger(EVT.CREATEROLE,EVT.CREATEROLE_PLAYFINISHED);
		end
    end
    if mPlaying==2 then
        --	相机移动 zoomin
        if mCameraMove==1 then
            self:GetMainCamera()
            if tolua.isnull(self._camera) or self._camera == nil then return end
            local anima = self._camera:GetComponent(typeof(UnityEngine.Animator));
            mCameraMoveTime = mCameraMoveTime + GameTime.deltaTime_L;
            self._camera.transform.localPosition = Vector3.Lerp(mNormalCamera.position,mZoomInCamera.position,mCameraMoveTime/500)
            if mCameraMoveTime >= 500 then
                mCameraMove = 3;
                mCameraMoveTime =0
            end
        elseif mCameraMove==2 then
            self:GetMainCamera()
            if tolua.isnull(self._camera) or self._camera == nil then return end
            mCameraMoveTime = mCameraMoveTime + GameTime.deltaTime_L;
            self._camera.transform.localPosition = Vector3.Lerp(mZoomInCamera.position,mNormalCamera.position,mCameraMoveTime/500)
            if mCameraMoveTime >= 500 then
                mCameraMove = 4
                mCameraMoveTime = 0
            end
        end
    end
end

function CrSceneController:Destory()
    if  self._camera then
        UnityEngine.GameObject.DestroyImmediate(self._camera);
        self._camera = nil
    end
    self._camera = nil
    self.sceneLoadCallback = nil
    self._camAniId = nil;
    self._sceneId = nil
    LoaderMgr.DeleteLoader(self._cameraAniLoader)
    UpdateBeat:Remove(self.Update,self);
end

return CrSceneController