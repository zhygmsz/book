
local TopTipWidget = class("TopTipWidget")
function TopTipWidget:ctor(ui, path)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)
	
	self._ui = ui
	path = path .. "/"
	self._path = path

    self._offet = ui:Find(path .. "offset")
	self._panel = ui:FindComponent("UIPanel", path .. "offset/toptip/panel")
	self._content = ui:FindComponent("UILabel", path .. "offset/toptip/panel/content")
	self._contentTrs = self._content.transform
	self._tweenPos = self._contentTrs:GetComponent("TweenPosition")
	self._tweenPos.enabled = false
	self._contentGo = self._contentTrs.gameObject
	self._contentGo:SetActive(false)
	self._finishFunc = EventDelegate.Callback(self.OnFinish, self)
	EventDelegate.Set(self._tweenPos.onFinished, self._finishFunc)
	
	--变量
	self._isShowed = false
	self._isShowing = false
	self._disPerSec = 200
	self._panelWidth = self._panel.baseClipRegion.z
	self._waitContents = {}
	self._fromPos = self._contentTrs.localPosition
	self._toPos = Vector3(0, self._fromPos.y, 0)
	self._len = 0
	self._duration = 0
end

function TopTipWidget:Reset()
	self._contentGo:SetActive(false)
	self._isShowing = false
	self._tweenPos.enabled = false
	self._tweenPos:ResetToBeginning()
	self._contentTrs.localPosition = self._fromPos
end

function TopTipWidget:SetVisible(visible)
    self._gameObject:SetActive(visible)
    self._isShowed = visible
end

function TopTipWidget:Show(content)
    self:SetVisible(true)

	if self._isShowing then
		table.insert(self._waitContents, content)
	else
		self:DoShow(content)
	end
end

function TopTipWidget:DoShow(content)
	self._contentGo:SetActive(true)
	self._content.text = content
	self._content:Update()
	self._isShowing = true

	self:PlayAni()
end

function TopTipWidget:PlayAni()
	self._tweenPos.enabled = true
	self._tweenPos.from = self._fromPos
	--计算目标点
	self._len = self._panelWidth + self._content.width + 5
	self._duration = self._len / self._disPerSec
	self._toPos.x = self._fromPos.x - self._len
	self._tweenPos.to = self._toPos
	self._tweenPos.duration = self._duration
	self._tweenPos:ResetToBeginning()
	self._tweenPos:PlayForward()
end

function TopTipWidget:OnFinish()
	self:Reset()
	if #self._waitContents > 0 then
		local content = table.remove(self._waitContents, 1)
		self:DoShow(content)
	else
		self:Hide()
	end
end

function TopTipWidget:Hide()
    self:Reset()
    self:SetVisible(false)
end

function TopTipWidget:IsShowed()
	return self._isShowed
end

return TopTipWidget