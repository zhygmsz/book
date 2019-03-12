--Tween效果
UITweenOutBack = class("UITweenOutBack");

---回来，回去，箭头，初始是否是出的状态
function UITweenOutBack:ctor(tweenOut,tweenBack,initOut)
    self._tweenOut = tweenOut;
    self._tweenBack = tweenBack;
    self._isOut = initOut;
end

function UITweenOutBack:FlipSprite()
    if not self._arrowSprite then return; end
    if self._arrowSprite.flip == UIBasicSprite.Flip.Horizontally then
        self._arrowSprite.flip = UIBasicSprite.Flip.Nothing;
    else
        self._arrowSprite.flip = UIBasicSprite.Flip.Horizontally;
    end
end

function UITweenOutBack:UseDefaultMode(arrowSprite)
    self._arrowSprite = arrowSprite;
    EventDelegate.Add(self._tweenOut.onFinished, EventDelegate.Callback(self.FlipSprite,self));
    EventDelegate.Add(self._tweenBack.onFinished, EventDelegate.Callback(self.FlipSprite,self));
end

function UITweenOutBack:SetCallback(onOutEnd,onBackout,obj)
    if onOutEnd then
        EventDelegate.Add(self._tweenOut.onFinished, EventDelegate.Callback(onOutEnd,obj));
    end
    if onBackout then
        EventDelegate.Add(self._tweenBack.onFinished, EventDelegate.Callback(onBackout,obj));
    end
end

function UITweenOutBack:OnClick()
    local tween = nil;
    if self._isOut then
        self:TweenBack()
    else
        self:TweenOut();
    end
end

function UITweenOutBack:TweenOut()
    local tween  = self._tweenOut;
    self._isOut = true;
    tween.enabled = true
    tween:ResetToBeginning()
    tween:PlayForward()
end

function UITweenOutBack:TweenBack()
    local tween  = self._tweenBack;
    self._isOut = false;
    tween.enabled = true
    tween:ResetToBeginning()
    tween:PlayForward()
end