module("GameInit",package.seeall)

local mModules = {};

local function LoadModule(modulePath)
	local moudleTimeBegin =Time.realtimeSinceStartup;	
	local flag,modTable = xpcall(require,traceback,modulePath);
	if not flag then
		--模块初始化错误
		print_error_module("INIT_MODULE",string.format("module has error %s %s",modulePath,modTable));
	else
		if type(modTable) == "table" then
			local function FindModuleFunc(funcName,callFunc)
				if modTable[funcName] then 
					if callFunc then modTable[funcName](); end
				-- else  -- 因有些文件缺失不需要Init函数，注释掉错误日志
				-- 	print_error_module("INIT_MODULE",string.format("can't find function %s %s",funcName,modulePath));
				end
			end
			--模块初始化
			FindModuleFunc("InitModule",true);
			--登录初始化
			--FindModuleFunc("InitModuleOnLogin",false);
			--退出初始化
			--FindModuleFunc("InitModuleOnLogout",false);
		else
			--因有些文件缺失不需要Init函数，注释掉错误日志
			--一个模块必须使用module+返回值形式
			--print_error_module("INIT_MODULE",string.format("can't find valid module function %s",modulePath));
		end
	end

	
	local moudleTimeEnd = Time.realtimeSinceStartup;	
	local logContent = string.format("init module{%s},need time %f", modulePath, moudleTimeEnd - moudleTimeBegin);
	print(logContent);
end

local function GetLimitTime()
	return math.ceil(Time.deltaTime * 1000) / 5;
end

local function GetRealTime()
	return math.ceil(Time.realtimeSinceStartup * 1000);
end

function RequireModule(modulePath)
	mModules[#mModules + 1] = modulePath;
end

function Begin()
	mModules.InitCount = 0;
	require("Logic/GameInit/GameInitCommon").InitCommon();
	mModules.CommonBorder = #mModules;
	require("Logic/GameInit/GameInitData").InitData();
	mModules.DataBorder = #mModules;
	require("Logic/GameInit/GameInitSystem").InitSystem();
	mModules.SystemBorder = #mModules;
end

function Update()
	local count = 0;
	local limitTime = GetLimitTime();
	local beginTime = GetRealTime();
	repeat
		--递增计数,每帧初始化几个模块
		count = count + 1;
		mModules.InitCount = mModules.InitCount + 1;
		if mModules.InitCount <= #mModules then
			LoadModule(mModules[mModules.InitCount]);
		else
			break;
		end
		--超过这一帧消耗时间上限则退出
		if GetRealTime() - beginTime >= limitTime then break; end
	until true
	return mModules.InitCount / #mModules;
end

function State()
	if mModules.InitCount <= mModules.CommonBorder then
		return "正在加载通用资源 "
	elseif mModules.InitCount <= mModules.DataBorder then
		return "正在加载游戏数据 "
	elseif mModules.InitCount <= mModules.SystemBorder then
		return "正在初始化游戏 "
	else
		return "初始化完成 "
	end
end

function Finish()
	require("Logic/GameInit/GameInitPlayer");
	require("Logic/GameInit/GameInitNet").InitNet();
end

return GameInit;

