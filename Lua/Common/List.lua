
--local list = {};

local ipairs = ipairs;
local rawget = rawget;

function List()
	local temp = {};

	temp._data = {};
	temp._info = {};
	local _data = temp._data;
	local _info = temp._info;
	--local _data= {};
	--list[temp] = _data;

	--_data.count = 0;
	_info.count = 0;

	local t = {};

	t.Clear = function()
		
	end

	t.Add = function(e)
		_data[_info.count + 1] = e;
		_info.count = _info.count + 1;

		return _info.count;
	end

	t.RandAdd = function(e)
		for i = 1, _info.count, 1 do
			if _data[i] == nil then
				_data[i] = e;
				return i;
			end
		end

		return t.Add(e);
	end

	t.Remove = function(index)
		t.Set(index, nil);
	end

	t.Get = function(index)
		if index < 1 or index > _info.count then
			--GameLog.LogError("get index is in_dataalid->" .. tostring(index));
			return nil;
		end

		return _data[index];
	end

	t.Count = function()
		return _info.count;
	end

	t.Set = function(index, e)
		if index < 1 or index > _info.count then
			--GameLog.LogError("set index is in_dataalid->" .. tostring(index));
			return;
		end

		_data[index] = e;
	end

	t.GetIpairs = function()
		return pairs(_data);
	end

	temp.__index = function(ta, k)
		--GameLog.LogError("use 'Get' function to get value");
		--return nil;
		return t.Get(k);
	end
	
	temp.__newindex = function(ta, k, v)
		--GameLog.LogError("use 'Add' or 'Set' function to set value");
		t.Set(k, v);
	end

	setmetatable(t, temp);

	return t;
end
