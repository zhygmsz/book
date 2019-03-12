

local BossBattleTipWidget = class("BossBattleTipWidget")
function BossBattleTipWidget:ctor(ui, path)
	--组件
	self._transform = ui:Find(path)
	self._gameObject = ui:FindGo(path)

	self._ui = ui
	path = path .. "/"
	self._path = path

	self._offset = ui:Find(path .. "offset")

	self._bossTip = ui:Find(path .. "offset/bosstip")
	self._bossTipGo = self._bossTip.gameObject
	self._icon = ui:FindComponent("UITexture", path .. "offset/bosstip/icon")
	self._des = ui:FindComponent("UILabel", path .. "offset/bosstip/des")
	self._bar = ui:FindComponent("UISlider", path .. "offset/bosstip/bar")
	self._barGo = self._bar.gameObject

	--loader
	self._texLoader = LoaderMgr.CreateTextureLoader(self._icon)

	--变量
	self._isShowed = false
	self._needBar = true
	self._duration = 0
	self._remained = 0
	self._per = 0

	self:Hide()
end

function BossBattleTipWidget:Update()
	self._remained = self._remained - Time.deltaTime

	if self._needBar and self._duration ~= 0 then
		self._per = self._remained / self._duration
		self._per = Mathf.Clamp1(self._per)
		self._bar.value = self._per
	end

	if self._remained <= 0 then
		self:Hide()
	end
end

function BossBattleTipWidget:StartUpdate()
	self:StopUpdate()
	UpdateBeat:Add(self.Update, self)
end

function BossBattleTipWidget:StopUpdate()
	UpdateBeat:Remove(self.Update, self)
end

function BossBattleTipWidget:SetBarVisible(visible)
	self._barGo:SetActive(visible)
	--调整整个UI布局
	if visible then
		--
	end
end

function BossBattleTipWidget:DoShow(iconName, desContent, duration, needBar)
	local resID = ResConfigData.GetResConfigID(iconName)
	self._texLoader:Clear()
	self._texLoader:LoadObject(resID)
	self._texLoader:SetPixelPerfect(true);
	self._des.text = desContent

	if duration then
		self._duration = duration
		self._remained = duration
		self._needBar = needBar
		self:SetBarVisible(needBar)
		self:StartUpdate()
	end
end

function BossBattleTipWidget:SetVisible(visible)
	self._gameObject:SetActive(visible)
	self._isShowed = visible
end

--[[
function BossBattleTipWidget:Show(iconName, desContent, duration, needBar)
	self:SetVisible(true)
	self:DoShow(iconName, desContent, duration, needBar)
end
--]]

function BossBattleTipWidget:Show(content, data)
    self:SetVisible(true)
    self._duration = data.duration
    if self._duration <= 0 then
        self._duration = 5
    end
    self._needBar = data.needBar == 1
    --目前图片不支持配置
    self:DoShow("img_toudingbiaoqing02", content, self._duration, self._needBar)
end

function BossBattleTipWidget:Reset()
	self._duration = 0
	self._remained = 0
	self._per = 0
end

function BossBattleTipWidget:Hide()
	self:StopUpdate()
	self:Reset()
	self:SetVisible(false)
	--清理当前引用的资源
	self._texLoader:Clear()
end

function BossBattleTipWidget:IsShowed()
	return self._isShowed
end

function BossBattleTipWidget:OnDestroy()
	if self._texLoader then
		LoaderMgr.DeleteLoader(self._texLoader)
		self._texLoader = nil
	end
end

return BossBattleTipWidget