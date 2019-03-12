
local TEMP = {};

function TEMP.GenMessageSub(name)
	local Sub = {};
	Sub.pool = {};
	Sub.name = name;

	function Sub.UnRegister(first, second, index)
		if type(first) ~= "number" or type(second) ~= "number" then
			GameLog.LogError("message sub '" .. Sub.name .. "' unregister failed: first, second param must be integer");
			return;
		end

		if index == nil or type(index) ~= "number" then
			GameLog.LogError("message sub unregister failed: index must be not nil and is a integer->%s", tostring(index));
			return;
		end

		local temp = Sub.pool[first];
		if temp == nil then
			temp = {};
			Sub.pool[first] = temp;
		end

		local list = temp[second];
		if list ~= nil then
			list.Remove(index);
		end
	end

	function Sub.Register(first, second, func, self)
		if type(first) ~= "number" or type(second) ~= "number" then
			GameLog.LogError("message sub '" .. Sub.name .. "' register failed: first, second param must be integer");
			return -1;
		end

		if type(func) ~= "function" then
			GameLog.LogError("message sub '" .. Sub.name .. "' register failed: func must be a function");
			return -2;
		end

		local temp = Sub.pool[first];
		if temp == nil then
			temp = {};
			Sub.pool[first] = temp;
		end

		local list = temp[second];
		if list == nil then
			list = List();
			temp[second] = list;
		end

		if list.Count() > 200 then
			GameLog.LogError("message sub func register too much->%d, %d, %d", first, second, list.Count());
		end

		if list.Count() > 500 then
			GameLog.LogError("message sub func register too much->%d, %d, %d", first, second, list.Count());
			--return -3;
		end

		if SystemInfo and SystemInfo.IsEditor() then
			for i = 1, list.Count(), 1 do
				local xx = list.Get(i);
				if xx ~= nil and xx._func == func and xx._self == self then
					GameLog.LogError("ERROR: repeated register message sub func->%d, %d", first, second);
					return -4;
				end
			end
		end

		local t = {};
		t._func = func;
		t._self = self;
		return list.RandAdd(t);
	end

	--function Sub.SendMessage(first, second, data)
	function Sub.SendMessage(first, second, ...)
		if type(first) ~= "number" or type(second) ~= "number" then
			if GameLog then
				GameLog.LogError("message sub '" .. Sub.name .. "' send failed: first, second param must be integer");
			end
			return;
		end

		local temp = Sub.pool[first];
		if temp == nil then
			return;
		end

		temp = temp[second];
		if temp == nil then
			return;
		end

		local count = temp.Count();
		local t;
		for i = 1, count, 1 do
			t = temp.Get(i);
			if t ~= nil then
				if t._self then
					if not GameUtils.TryCatch(t._func, t._self, ...) then
						if GameLog then
							GameLog.Log("message sub call function error->%d, %d, %s", first, second, tostring(t._func));
						else
							print(debug.traceback(string.format("message sub call function error->%d, %d, %s", first, second, tostring(t._func))));
						end
					end
				else
					if not GameUtils.TryCatch(t._func, ...) then
						if GameLog then
							GameLog.Log("message sub call function error->%d, %d, %s", first, second, tostring(t._func));
						else
							print(debug.traceback(string.format("message sub call function error->%d, %d, %s", first, second, tostring(t._func))));
						end
					end
				end
			end
		end
	end

	return Sub;
end


MessageSub = TEMP.GenMessageSub("COMMON");

return TEMP;
