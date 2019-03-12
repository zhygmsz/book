local LuaTweenValue = GameBase.LuaTweenValue;
local IDPool = require "Common/IDPool";
local CameraEffectBase = require "Logic/Presenter/Camera/Effect/CameraEffectBase";
local idPool = IDPool.new();

local Brightness = class("CamEff_Brightness");

--[[
--@curCamGo int32
--@finishFunc func
--@finishFuncObj object
--]]
function Brightness:ctor(curCamGo,effect, finishFunc, finishFuncObj)
	CameraEffectBase.ctor(self,curCamGo,effect);
	self._beginV = -1;
	self._endV = -1;
	self._finishFunc = finishFunc;
	self._finishFuncObj = finishFuncObj;
	self._curV = 0;
	self._over = false;
end

local function Flush(self)
   if self._over then return end;
   if self._camEff ~= nil then
	   self._camEff._Brightness = self._curV;
   end
end

function Brightness:FlushValue(value)
	if self._over then return end;
	self._curV = value;
	if self._camEff ~= nil then
		self._camEff._Brightness = value;
	end
end

local function Tween(index, factor, isfinished)
	local self = idPool:Get(index);
	if self and not self._over then
		self._curV = self._beginV * (1 - factor) + self._endV * factor;

		Flush(self);

		if isfinished then
			idPool:Remove(index);
			self:Over();
			if self._finishFunc then
				self._finishFunc(self._finishFuncObj);
			end
		end
	end
end

function Brightness:Over()
	if self._camEff ~= nil then
			self._camEff.enabled=false;
	end
	self._over = true;
end

function Brightness:PlayEnter(duration,beginV,endV)
	self._over = false;
	self._beginV = beginV or 1;
	self._endV = endV or 0;
	self._curV = self._beginV;
	Flush(self);

	local id = idPool:GenID(self);
	LuaTweenValue.GenLinearTween(duration, Tween, id);
end

function Brightness:PlayExit(duration,beginV,endV)
	self._over = false;
	self._beginV = beginV or 0;
	self._endV = endV or 1;
	self._curV = self._beginV;
	Flush(self);

	local id = idPool:GenID(self);
	LuaTweenValue.GenLinearTween(duration, Tween, id);
end

return Brightness;
