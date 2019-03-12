
local BuffEffect_LimitVision = class("BuffEffect_LimitVision", BuffEffect)

function BuffEffect_LimitVision:ctor(buffGroup, effectData)
    self._buffGroup = buffGroup;
    self._buffGroup = buffGroup;
    self._effectData = effectData;
    self._leftCount = self._effectData.count;
    self._leftTime = self._effectData.interval;
    self._tickType = self._effectData.tickType;
    self._stop = false;
    self:DoStartEffect();
end

function BuffEffect_LimitVision:DoStartEffect()

    local isSelf = self._buffGroup._buffComponent._entity:IsSelf()

    if not isSelf then
        return 
    end

    UIMgr.ShowUI(AllUI.UI_CleanLime)
    
end

function BuffEffect_LimitVision:DoStopEffect()
    local isSelf = self._buffGroup._buffComponent._entity:IsSelf()

    if not isSelf then
        return 
    end
    GameEvent.Trigger(EVT.LIME, EVT.LIME_BUFFSTOP)
end

function BuffEffect_LimitVision:DoStopBuffer()
    LoaderMgr.DeleteLoader(self._effectLoader)
    self._effectLoader = nil
end

return BuffEffect_LimitVision