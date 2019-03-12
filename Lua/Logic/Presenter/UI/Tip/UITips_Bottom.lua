

local BottomTipItem = class("BottomTipItem")
function BottomTipItem:ctor(ui, path, finishFuncOnTa)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._content = ui:FindComponent("UILabel", path)
	self._tweenAlpha = ui:FindComponent("TweenAlpha", path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._finishFuncOnTa = finishFuncOnTa
	EventDelegate.Set(self._tweenAlpha.onFinished, self._finishFuncOnTa)
	
	--变量
	self._isShowed = false
	self._fromAlpha = 1
	self._toAlpha = 0
	self._duration = 0.5
	self._timerIdx = nil
	self._showDelay = 2
	
	self:Hide()
end

function BottomTipItem:Reset()
	if self._timerIdx then
		GameTimer.DeleteTimer(self._timerIdx)
		self._timerIdx = nil
	end
	self._tweenAlpha.enabled = false
	self._tweenAlpha:ResetToBeginning()
end

function BottomTipItem:Show(content)
	self:Reset()
	self._gameObject:SetActive(true)
	self._isShowed = true
	
	self._content.text = content
	self._timerIdx = GameTimer.AddTimer(self._showDelay, 1, self.OnShowDelayEnd, self)
end

function BottomTipItem:OnShowDelayEnd()
	self._timerIdx = nil
	self:PlayAni()
end

function BottomTipItem:PlayAni()
	self._tweenAlpha.enabled = true
	self._tweenAlpha.from = self._fromAlpha
	self._tweenAlpha.to = self._toAlpha
	self._tweenAlpha.duration = self._duration
	self._tweenAlpha:ResetToBeginning()
	self._tweenAlpha:PlayForward()
end

function BottomTipItem:Hide()
	self:Reset()
	self._gameObject:SetActive(false)
	self._isShowed = false
end

function BottomTipItem:IsShowed()
	return self._isShowed
end

--BottomTipWidget
local BottomTipWidget = class("BottomTipWidget")
function BottomTipWidget:ctor(ui, path)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)
	
	self._ui = ui
	path = path .. "/"
	self._path = path

	self._offsetWidget = ui:FindComponent("UIWidget", path .. "offset")
	self._finishFuncOnTa = EventDelegate.Callback(self.OnTaFinish, self)
	self._bottomTipItem = BottomTipItem.new(ui, path .. "offset/bottomtip/item", self._finishFuncOnTa)
	self._bottomTipItem:Hide()
	
	--变量
	self._isShowed = false
	self:Hide()
	self._contentList = {}
	self._isShowing = false
end

function BottomTipWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function BottomTipWidget:Show(content)
	if not self:IsShowed() then
		self._gameObject:SetActive(true)
		self._isShowed = true
	end
	if self._isShowing then
		--正在显示，放入等待队列
		table.insert(self._contentList, content)
	else
		--直接显示
		self._bottomTipItem:Show(content)
		self._isShowing = true
	end
end

function BottomTipWidget:Hide()
	self._bottomTipItem:Hide()
	self._isShowing = false
	self._gameObject:SetActive(false)
	self._isShowed = false
end

function BottomTipWidget:IsShowed()
	return self._isShowed
end

function BottomTipWidget:OnTaFinish()
	--一次提示结束，查看是否有下一个
	self._bottomTipItem:Hide()
	if #self._contentList > 0 then
		local content = table.remove(self._contentList, 1)
		self._bottomTipItem:Show(content)
	else
		self:Hide()
	end
end

function BottomTipWidget:SetAnchor(anchorTrs)
    self._offsetWidget.leftAnchor.target = nil
    self._offsetWidget.rightAnchor.target = nil

	if not tolua.isnull(anchorTrs) then
		self._offsetWidget.topAnchor.target = anchorTrs
		self._offsetWidget.topAnchor.relative = 1
		self._offsetWidget.topAnchor.absolute = 75
		self._offsetWidget.bottomAnchor.target = anchorTrs
		self._offsetWidget.bottomAnchor.relative = 1
		self._offsetWidget.bottomAnchor.absolute = - 25
		self._offsetWidget:ResetAnchors()
	end
end

return BottomTipWidget