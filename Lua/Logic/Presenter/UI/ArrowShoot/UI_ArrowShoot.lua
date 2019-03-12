module("UI_ArrowShoot",package.seeall);

local mAimSprite;

local mAimStartPos;
local mEvents = {};

function OnCreate( self )
    mAimSprite = self:FindComponent("UISprite","Offset/AimSprite");
end

function OnEnable( self )
    MessageSub.SendMessage(GameConfig.SUB_G_ARROW_SHOOT, GameConfig.SUB_G_ARROW_SHOOT_SETAIM, mAimSprite);  
end

function OnDisable( self )
end

function SetAimOffset( offset )
    -- body
end

--[[
function OnEnable( self )
    self:SetListenOnClick(true);
    TouchMgr.SetEnableNGUIMode(false);
    TouchMgr.SetEnableCameraOperate(false);
    TouchMgr.SetListenOnTouch(UI_MindLink,true);
    ArrowShootController.CombineInstance():SetAimSprite(mAimSprite);
    Init();
end

function OnDisable( self )
    self:SetListenOnClick(false);
    TouchMgr.SetTouchEventEnable(false)
    TouchMgr.SetEnableNGUIMode(true)
    TouchMgr.SetEnableCameraOperate(true)
    TouchMgr.SetListenOnTouch(UI_MindLink,false);
end

function OnTouchStart( gesture )
    if ArrowShootController.CombineInstance():GetCurrentState() == ArrowShootController.ShootState.Edle then
        ArrowShootController.CombineInstance():SetStateToReady();
    end
end

function OnTouchDown( gesture )
    if ArrowShootController.CombineInstance():GetCurrentState() == ArrowShootController.ShootState.Ready then
        mReadyTimer = mReadyTimer + Time.fixedDeltaTime;
        if mReadyTimer>=mReadyTime then
            ArrowShootController.CombineInstance():SetTouchStartPosition(gesture.position.x, gesture.position.y);
            ArrowShootController.CombineInstance():SetStateToAiming();
            mAimSprite.gameObjeft:SetActive(true);
            mReadyTimer = 0;
        end
    elseif ArrowShootController.CombineInstance():GetCurrentState() == ArrowShootController.ShootState.Aiming then
        ArrowShootController.CombineInstance():SetTouchCurrentPosition(gesture.position.x, gesture.position.y);
    end
   
end

function OnTouchUp( gesture )
    if ArrowShootController.CombineInstance():GetCurrentState() == ArrowShootController.ShootState.Aiming then
        mScore = ArrowShootController.CombineInstance():ShootArrow();
    end
end

function Init()
    mReadyTimer = 0;
    mAimSprite.gameObjeft:SetActive(false);
    mScore = 0;
end
]]
