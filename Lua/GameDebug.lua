module("GameDebug",package.seeall)

local function OnReceiveCameraCommand(command)
    --摄像机控制命令解析
    local commands = string.split(command," ");

    --默认命令为控制摄像机观察参数
    GameCore.CameraSetting[commands[1]] = tonumber(commands[2]);
end

local function OnReceiveCustomCommand(command)
    --执行指定lua字符串
    local flag,msg = xpcall(do_custom_string,traceback,command);
    if not flag then GameLog.LogModuleError("COMMAND_ERROR",msg); end
end

local function OnReceiveFrameCommand(command)
    --设定帧率上限
    UnityEngine.Application.targetFrameRate = tonumber(command);
end

local client_gm_list = 
{ 
    ["gm camera "] = OnReceiveCameraCommand,
    ["gm custom "] = OnReceiveCustomCommand,
    ["gm frame"] = OnReceiveFrameCommand,
}

local function OnReceiveCommand(command)
    if string.StartWith(command,"gm") then
        for gmName,gmFunc in pairs(client_gm_list) do
            if string.StartWith(command,gmName) then gmFunc(string.gsub(command,gmName,"")); end
        end
    else
        GameNet.SendGMCommand(command);
    end
end

function InitModule()
    UnityEngine.GameObject.Find("GameStart"):AddComponent(typeof(GameCore.GameDebugInteractionRoot));
    GameCore.GameDebugInteractionRoot.RegisterCommondFunc(GameCore.GameDebugInteractionRoot.GMCommondFunc(OnReceiveCommand));
end