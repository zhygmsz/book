MainUIJoyStick = class("MainUIJoyStick");

function MainUIJoyStick:ctor(uiFrame)
    --local joyPanelPanel = uiFrame:FindComponent("UIPanel","BottomLeft/PanelJoystick");
    uiFrame:SetChildPanelDepth("PanelJoystick",199);
    self._joyStick = uiFrame:FindComponent("GameCore.UIJoystick","BottomLeft/PanelJoystick/Joystick");
    self._joyGo = self._joyStick.gameObject;
    self._joyStickBack = uiFrame:Find("BottomLeft/PanelJoystick/Joystick/back");
    self._joyStickFore = uiFrame:Find("BottomLeft/PanelJoystick/Joystick/fore");
    self._joyStickDirection = uiFrame:Find("BottomLeft/PanelJoystick/Joystick/back/light");
    --摇杆拖拽的UI目标
    self._joyStick:InitDragTarget(self._joyStickBack,self._joyStickFore,self._joyStickDirection);
    --拖拽事件回调
    local onDragStart = GameCore.UIJoystick.OnJoystickDragStart(self.OnJoyDragStart,self);
    local onDrag = GameCore.UIJoystick.OnJoystickDrag(self.OnJoyDrag,self);
    local onDragEnd = GameCore.UIJoystick.OnJoystickDragEnd(self.OnJoyDragEnd,self);
    self._joyStick:InitDragCallBack(onDragStart,onDrag,onDragEnd);
end

function MainUIJoyStick:OnEnable()

end

function MainUIJoyStick:OnDisable()
end

function MainUIJoyStick:OnDestroy()

end

function MainUIJoyStick:OnJoyDragStart()
    TouchMgr.SetEnablePinch(false);
end

function MainUIJoyStick:OnJoyDrag(dx,dy)
    if not TouchMgr.IsDragJoyStickEnable() then return end
    if MapMgr.GetMainPlayer() then MapMgr.GetMainPlayer():GetAIComponent():MoveWithJoystick(dx,dy); end
    GameEvent.Trigger(EVT.COMMON,EVT.DRAGJOYSTICK,true);
end

function MainUIJoyStick:OnJoyDragEnd()
    TouchMgr.SetEnablePinch(true);
    if MapMgr.GetMainPlayer() then MapMgr.GetMainPlayer():GetAIComponent():StopWithJoystick(); end
    GameEvent.Trigger(EVT.COMMON,EVT.DRAGJOYSTICK,false);
end

return MainUIJoyStick;