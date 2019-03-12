--根据一定时间间隔播放随机动作
local UIAIPetComponentAniRandom = class("UIAIPetComponentAniRandom");
 
function UIAIPetComponentAniRandom:ctor(ui,context,rootPath)
    self._context = context;
    self._timePlay = nil;
    self._enabled = false;
    self._timeLimit = ConfigData.GetIntValue("AIPet_Animation_Random_Time") or 20;--随机动画间隔 单位秒
end

function UIAIPetComponentAniRandom:OnPlayEnd()
    self._timePlay = TimeUtils.SystemTimeStamp(true) + self._timeLimit;
end

function UIAIPetComponentAniRandom:Update()
    local cur = TimeUtils.SystemTimeStamp(true);
    if self._timePlay and cur > self._timePlay then
        self._context:PlayAnimation(AIPetUIANIMATION.Random);
        self:OnPlayEnd();
    end
end

function UIAIPetComponentAniRandom:OnEnable()
    if self._enabled then return; end
    self._enabled =true;
    self:OnPlayEnd();
    GameEvent.Reg(EVT.AIPET,EVT.AIPET_UI_ANIMATION_END,self.OnPlayEnd,self);
    UpdateBeat:Add(self.Update,self);
end
function UIAIPetComponentAniRandom:OnDisable()
    if not self._enabled then return; end
    self._enabled = false;
    self._timePlay = nil;
    GameEvent.UnReg(EVT.AIPET,EVT.AIPET_UI_ANIMATION_END,self.OnPlayEnd,self);
    UpdateBeat:Remove(self.Update,self);
end

return UIAIPetComponentAniRandom;