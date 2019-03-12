
module("GameLog",package.seeall)
local print = print;
local print_error = print_error;
local print_module = print_module;
local print_error_module = print_error_module;
local xpcall = xpcall;
local traceback = debug.traceback;

function InitModule()

end

local function LogContent(format, ...)
	return string.format("%s\n%s",string.format(format, ...),debug.traceback());
end

function Log(format, ...)
	if GameConfig.ENABLE_LOG then
		local logContent = LogContent(format, ...);
		local flag,msg = xpcall(print,traceback,logContent)
		if not flag then LogError(msg); end
	end
end

function LogError(format, ...)
	if GameConfig.ENABLE_LOG then
		local logContent = LogContent(format, ...);
		local flag,msg = xpcall(print_error,traceback,logContent)
		if not flag then LogError(msg); end
	end
end

function LogModuleInfo(modName,format,...)
	if GameConfig.ENABLE_LOG then
		local logContent = LogContent(format, ...);
		local flag,msg = xpcall(print_module,traceback,modName,logContent)
		if not flag then LogError(msg); end
	end
end

function LogModuleError(modName,format,...)
	if GameConfig.ENABLE_LOG then
		local logContent = LogContent(format, ...);
		local flag,msg = xpcall(print_error_module,traceback,modName,logContent)
		if not flag then LogError(msg); end
	end
end

function LogProto(proto,isChildProto)
	if GameConfig.ENABLE_LOG then
		if not isChildProto then LogModuleInfo("PROTO","--------------------------proto begin--------------------------"); end
		local meta = getmetatable(proto);
		for _,field in pairs(meta._descriptor.fields) do
			local fieldValue = proto[field.name];
			if field.label == 3 then
				for idx,fieldChild in ipairs(fieldValue) do
					if type(fieldChild) == "table" then
						LogProto(fieldChild,true);
					else
						LogModuleInfo("PROTO","%s[%s] = %s",field.full_name, idx , fieldChild);
					end
				end
			elseif field.cpp_type == 10 then
				LogProto(fieldValue,true);
			else
				LogModuleInfo("PROTO","%s = %s",field.full_name, fieldValue);
			end
		end
		if not isChildProto then LogModuleInfo("PROTO","--------------------------proto end--------------------------"); end
	end
end

function LogTable(luaTable,tableName,isChildTable,logCache)
	if GameConfig.ENABLE_LOG then
		if not isChildTable then LogModuleInfo("TABLE","--------------------------table begin--------------------------"); end
		if not logCache then logCache = {} end
		if not logCache[luaTable] then
			logCache[luaTable] = luaTable;
			local childTables = {};
			local tableValues = {};
			local parentTableName = (tableName or "")
			for k,v in pairs(luaTable) do
				if type(v) == "table" then
					table.insert(childTables,{ name = parentTableName .. "." .. tostring(k), value =  v});
				else
					table.insert(tableValues,string.format("%s = %s",k,v))
				end
			end
			LogModuleInfo("TABLE","\ntableName:%s\n%s",parentTableName,table.concat(tableValues,"\n"));
			for _,childTable in pairs(childTables) do LogTable(childTable.value,childTable.name,true,logCache); end
		end
		if not isChildTable then LogModuleInfo("TABLE","--------------------------table end--------------------------"); end
	end
end

function LogSocketMessage(msg,sendFlag,errorCode)
	if GameConfig.ENABLE_LOG then
		local msg_name = getmetatable(msg)._descriptor.name;
		if table.contains_value(GameConfig.LOG_FILTER,msg_name) then return end
		if sendFlag then
			LogModuleInfo("S_MSG_SEND_RECV","send socketMsg %s to server",msg_name);
		else
			LogModuleInfo("S_MSG_SEND_RECV","recv socketMsg %s from server, ret is %s", msg_name, errorCode);
		end
	end
end

function LogHttpSendMessage(data,url)
	if GameConfig.ENABLE_LOG then
		LogModuleInfo("H_MSG_SEND_RECV","send httpMsg %s to httpserver %s",data,url);
	end
end

function LogHttpRecMessage(recData,sendData)
	if GameConfig.ENABLE_LOG then
		LogModuleInfo("H_MSG_SEND_RECV","recv httpMsg %s from httpserver by sendData %s",recData,sendData);
	end
end

return GameLog;
