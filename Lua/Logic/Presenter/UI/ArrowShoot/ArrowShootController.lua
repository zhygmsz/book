local ArrowShootController = class("ArrowShootController");

function ArrowShootController:ctor()
    self._ShootState = {
        Edle = 0,
        Ready = 1,
        Aiming = 2,
        Shooting = 3;
    }
    self._currntState = self._ShootState.Edle;

    self._touchStartPosition = Vector2.New(0, 0);
    self._aimMoveSpeed = Vector2.New(0, 0);

    self._cameraInitOffset = 1.8;
    self._arrowInitOffset = 1.57;
    self._shootPoint = nil;
 	self._arrowMoveTimer = 0;
 	self._acceleratedSpeed = 100;	--加速度
end

function ArrowShootController:ControllerStart()
    UpdateBeat:Add(self.Update, self);
    FixedUpdateBeat:Add(self.FixedUpdate, self);
    TouchMgr.SetEnableNGUIMode(false);
    TouchMgr.SetEnableCameraOperate(false);
    TouchMgr.SetListenOnTouch(self,true,true);
    self:Init();
end

--退出射箭时调用
function ArrowShootController:ControllerEnd()
    TouchMgr.SetTouchEventEnable(false)
    TouchMgr.SetEnableNGUIMode(true)
    TouchMgr.SetEnableCameraOperate(true)
    TouchMgr.SetListenOnTouch(self,false);
    UpdateBeat:Remove(self.Update,self);
    FixedUpdateBeat:Remove(self.FixedUpdate, self);
end

function ArrowShootController:Update(deltaTime)
    if not self._isLocated then
        if self._frameNum <= 60 then
            self._frameNum = self._frameNum + 1;
        else
            self:LocateAsset();
            CameraMgr.EnableMainCamera(false);
            self._shootCamera:SetActive(true);
            self._frameNum = self._frameNum + 1;
        end 
    end

    if self._currntState == self._ShootState.Shooting then
    	local initSpeed = 5;
        self._arrowMoveTimer = self._arrowMoveTimer + GameTime.deltaTime_L / 1000;
        local moveLength = initSpeed * self._arrowMoveTimer + self._acceleratedSpeed * self._arrowMoveTimer * self._arrowMoveTimer / 2;
        if moveLength >= self._arrowMoveLength then
        	moveLength = self._arrowMoveLength;
            self._currntState = self._ShootState.Edle;
        end
        local arrowPosOffset = self._arrowInitPos + self._arrowMoveVector * moveLength;
        self._arrowObj.transform.position = arrowPosOffset;
    end
end

function ArrowShootController:FixedUpdate()
    local a = 0;
end

function ArrowShootController:ControllerEnd()
    UpdateBeat:Remove(self.Update, self);
	FixedUpdateBeat:Remove(self.FixedUpdate, self);
end

function ArrowShootController:InitShootCamera()
    if tolua.isnull(self._shootCamera) then
		local cameraObj = UnityEngine.GameObject("ArrowShootCamera");
		self._shootCamera = cameraObj:AddComponent(typeof(UnityEngine.Camera));
    end
end

function ArrowShootController:Init()
	self:RegisterEvn();
    self:InitShootCamera();
    self._isLocated = false;
    self._frameNum = 0;
end

function ArrowShootController:LocateAsset()
    self._isLocated = true;

    local playerTrans = MapMgr.GetMainPlayer():GetModelComponent():GetEntityRoot();
    local playerPos = playerTrans.position;
    self._shootCamera.transform.position = Vector3.New(playerPos.x, playerPos.y + self._cameraInitOffset, playerPos.z);

    if self._arrowObj then
    	self._arrowObj.transform.position = Vector3.New(playerPos.x, playerPos.y + self._arrowInitOffset, playerPos.z);
    	self._arrowInitPos = self._arrowObj.transform.position;
    end
end

function ArrowShootController:RegisterEvn()
	self._setAimTransEvent = MessageSub.Register(GameConfig.SUB_G_ARROW_SHOOT, GameConfig.SUB_G_ARROW_SHOOT_SETAIM, self.GetAimSprite, self);
end

function ArrowShootController:UnRegisterEvn()
	MessageSub.UnRegister(GameConfig.SUB_G_ARROW_SHOOT, GameConfig.SUB_G_ARROW_SHOOT_SETAIM, self._setAimTransEvent);
end

function ArrowShootController:OnTouchStart( gesture )
	if self._currntState == self._ShootState.Edle then
		self._touchStartPosition:Set(gesture.position.x, gesture.position.y);
		self._aimSprite.gameObject:SetActive(true);
		self._currntState = self._ShootState.Aiming;
		self._shootPoint = nil;
	end
end

function ArrowShootController:OnTouchDown( gesture )
	if self._currntState == self._ShootState.Aiming then
	    local currentMousePosition = Vector2.New(gesture.position.x, gesture.position.y);
	    self:UpdateAimMoveSpeed(currentMousePosition);
	    self:UpdateAimSpritePos();
	end
end

function ArrowShootController:OnTouchUp( gesture )
	if self._currntState == self._ShootState.Aiming then
		self._aimSprite.gameObject:SetActive(false);
		self:ShootArrow();
    end
end

function ArrowShootController:UpdateAimMoveSpeed( currentMousePosition )
	self._aimMoveSpeed = (currentMousePosition - self._touchStartPosition) / 10;
end

function ArrowShootController:UpdateAimSpritePos()
	local aimCurrentPosition = self._aimSprite.transform.localPosition;
	if math.abs(aimCurrentPosition.x + self._aimMoveSpeed.x) < SystemInfo.ScreenWidth() / 2 then
		aimCurrentPosition.x = aimCurrentPosition.x + self._aimMoveSpeed.x;
	end

	if math.abs(aimCurrentPosition.y + self._aimMoveSpeed.y) < SystemInfo.ScreenHeight() / 2 then
		aimCurrentPosition.y = aimCurrentPosition.y + self._aimMoveSpeed.y;
	end

	self._aimSprite.transform.localPosition = aimCurrentPosition;
end


function ArrowShootController:GetAimSprite( aimSprite )
    self._aimSprite = aimSprite;
    self._aimInitPos = aimSprite.transform.localPosition;
    self._aimSprite.gameObject:SetActive(false);
end

function ArrowShootController:GetArrowObj( arrowObj )
	self._arrowObj = arrowObj;

    local playerTrans = MapMgr.GetMainPlayer():GetModelComponent():GetEntityRoot();
    local playerPos = playerTrans.position;
    self._arrowObj.transform.position = Vector3.New(playerPos.x, playerPos.y + self._arrowInitOffset, playerPos.z);
    self._arrowInitPos = self._arrowObj.transform.position;
end

function ArrowShootController:ShootArrow()
    local aimPos = self._aimSprite.transform.position;
    local aimScreenPos = UICamera.currentCamera:WorldToScreenPoint(aimPos);
    aimScreenPos.z = 0;
    local hitPoint = nil;
	local hit = CameraMgr.Raycast(aimScreenPos,CameraLayer.MainMaskLayer,1000,self._shootCamera);
	if hit then
		local go = not tolua.isnull(hit.collider) and hit.collider.gameObject;
		if go then --go.layer==CameraLayer.PlayerLayer
            self._shootPoint = hit.point;
            self._arrowMoveVector = (self._shootPoint - self._arrowInitPos).normalized;
            self._arrowMoveLength = (self._shootPoint - self._arrowInitPos).magnitude;
		else
			--脱靶
		end
	else
		--脱靶
	end
	self._currntState = self._ShootState.Shooting;
	self._arrowMoveTimer = 0;
end

return ArrowShootController;


