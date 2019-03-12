

local IDPool = class("IDPool");


function IDPool:ctor()
	self._index = -1;
	self._data = {};
end

--[[
--@ obj class obj or other
--Re@ int64
--]]
function IDPool:GenID(obj)
	if obj then
		self._index = self._index + 1;
		self._data[self._index] = obj;
		return self._index;
	end

	return -1;
end

--[[
--@ id int64
--Re@ class obj or other
--]]
function IDPool:Get(id)
	return self._data[id];
end

--[[
--@ id int64
--]]
function IDPool:Remove(id)
	self._data[id] = nil;
end

return IDPool;
