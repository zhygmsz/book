function StartGame()
	print("lua game start");
	--初始化基础脚本,这些脚本不更新
	require("Logic/Framework/ToLua/debug/" .. (jit and "LuaDebugjit" or "LuaDebug"))("localhost",7003);
	require("Logic/GameState/GameStateMgr").InitModule();
	--进入启动状态
	GameStateMgr.EnterStart();
end

function StopGame()
	print("lua game stop")
end
