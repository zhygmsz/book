module("GameNet",package.seeall)
local JSON = require "cjson";
local traceback = traceback;
local xpcall = xpcall;
--SOCKET最大数量
local MAX_SOCKET_COUNT = 2;
--每帧处理消息数
local MAX_MSG_PER_FRAME = 8;
--SOCKET消息处理函数
local mMsgCallBacks = {};
--HTTP消息回调
local mHttpCallBacks = {};
local mHttpSendDatas = {};
--兼容处理
local mHttpOldFlag = {};

local function OnRecvFail(tid, gid, uid, errorMsg, msg)
	if msg then
		GameLog.LogError("msg process error %s^%s^%s %s %s",tid,gid,uid,getmetatable(msg)._descriptor.name,errorMsg);
	else
		GameLog.LogError("msg process error %s^%s^%s %s",tid,gid,uid,errorMsg);
	end
end

local function OnRecvMsg(tid, gid, uid, data)
	if mMsgCallBacks[tid] and mMsgCallBacks[tid][gid] and mMsgCallBacks[tid][gid][uid] then
		local callBack = mMsgCallBacks[tid][gid][uid];
		local msg = callBack.proto();
		local flag,errorMsg = xpcall(msg.ParseFromString,traceback,msg,data);
		if flag then
			local msgErrorCode = msg.ret or msg.result or 0;
			GameLog.LogSocketMessage(msg,false,msgErrorCode);
			if msgErrorCode ~= 0 then
				if callBack.errorHandler then
					--有自定义错误处理函数
					local flag,errorMsg = xpcall(callBack.errorHandler,traceback,msg,msgErrorCode);
					if not flag then
						OnRecvFail(tid,gid,uid,errorMsg,msg);
					end
				else
					TipsMgr.TipErrorByID(msgErrorCode);
					GameLog.Log("msg name = %s, ret = %d", getmetatable(msg)._descriptor.name, msgErrorCode);
				end
			else
				--没有错误,正常处理
				if callBack.handler then					
					local flag,errorMsg = xpcall(callBack.handler,traceback,msg);
					if not flag then
						OnRecvFail(tid,gid,uid,errorMsg,msg);
					end
				else
					OnRecvFail(tid,gid,uid,"handler is nil",msg);
				end
			end
		else
			OnRecvFail(tid,gid,uid,errorMsg,msg);
		end
	else
		OnRecvFail(tid,gid,uid,"handler is nil");
	end
end

local function OnSocketEvent(eventType,socketIndex,arg1,arg2,arg3,data)
	if eventType == 1 then
		GameLog.LogError("socket %s error %s",socketIndex,arg1);
		GameEvent.Trigger(EVT.NETWORK,EVT.NETWORK_ERROR,socketIndex,arg1);
	elseif eventType == 2 then
		GameLog.Log("socket %s connected",socketIndex);
		GameEvent.Trigger(EVT.NETWORK,EVT.NETWORK_CONNECT,socketIndex);
	elseif eventType == 3 then
		GameLog.LogError("socket %s disconnected passive",socketIndex);
		GameEvent.Trigger(EVT.NETWORK,EVT.NETWORK_DISCONNECT,socketIndex,true);
	elseif eventType == 4 then
		GameLog.Log("socket %s disconnected active",socketIndex);
		GameEvent.Trigger(EVT.NETWORK,EVT.NETWORK_DISCONNECT,socketIndex,false);
	elseif eventType == 5 then
		GameLog.LogError("socket %s connect fail timeout",socketIndex);
		GameEvent.Trigger(EVT.NETWORK,EVT.NETWORK_CONNECT_FAIL,socketIndex,"network_connect_timeout");
	elseif eventType == 6 then
		GameLog.LogError("socket %s connect fail %s",socketIndex,arg1);
		GameEvent.Trigger(EVT.NETWORK,EVT.NETWORK_CONNECT_FAIL,socketIndex,string.format("network_connect_%s",string.lower(arg1)));
	elseif eventType == 7 then
		GameLog.LogError("socket %s connect lost,message %s send fail",socketIndex,arg1);
		GameEvent.Trigger(EVT.NETWORK,EVT.NETWORK_SEND_MSG_FAIL,socketIndex);
	elseif eventType == 10 then	
		OnRecvMsg(arg1,arg2,arg3,data);
	end
end

local function OnHttpEvent(callIndex,hasError,errorMsg,data)	
	local callBack = mHttpCallBacks[callIndex];
	mHttpCallBacks[callIndex] = nil;
	local sendData = mHttpSendDatas[callIndex];
	mHttpSendDatas[callIndex] = nil;
	local oldFlag = mHttpOldFlag[callIndex];
	mHttpOldFlag[callIndex] = nil;

	if hasError then
		--HTTP网络连接错误
		TipsMgr.TipByKey("http_error");
		GameLog.LogError("http error %s, sendData: %s",errorMsg, sendData); 
	else
		GameLog.LogHttpRecMessage(data,sendData);
		local flag,result = xpcall(JSON.decode,traceback,data);
		if not flag then
			--HTTP网络JSON解析错误
			TipsMgr.TipByKey("http_json_error");
			GameLog.LogError("http json decode error %s, sendData %s",result, sendData);
		else
			local httpErrorCode = result["code"] or result["errcode"] or 0;
			if httpErrorCode ~= 0 then
				TipsMgr.TipErrorByID(httpErrorCode);
				GameLog.LogError("httpError code=%s, data=%s",httpErrorCode,data);
				if callBack then callBack(nil,httpErrorCode); end
			else
				if callBack then callBack(result,httpErrorCode); end
			end
		end
	end
end

function InitModule()
	GameCore.NetMgr.Instance:Init(MAX_SOCKET_COUNT,OnSocketEvent,OnHttpEvent,MAX_MSG_PER_FRAME);
end

--[[
注册消息处理函数
proto			消息类,示例NetCS_pb.XX
handler			处理函数
errorHandler	错误处理函数(错误码不为0时会调用)
--]]
function Reg(proto,handler,errorHandler)
	local mid,gid,uid = proto.MRID,proto.GROUPID,proto.UNITID;
	if not mMsgCallBacks[mid] then mMsgCallBacks[mid] = {} end
	if not mMsgCallBacks[mid][gid] then mMsgCallBacks[mid][gid] = {} end
	if mMsgCallBacks[mid][gid][uid] then
		local callBack = mMsgCallBacks[mid][gid][uid];
		local callBackMeta = getmetatable(callBack.proto());
		local newCallBackMeta = getmetatable(proto());
		GameLog.LogError("msg handler repeat %s %s %d_%d_%d",callBackMeta._descriptor.name,newCallBackMeta._descriptor.name,mid,gid,uid);
	else
		local callBack = {};
		callBack.proto = proto;
		callBack.handler = handler;
		callBack.errorHandler = errorHandler;
		mMsgCallBacks[mid][gid][uid] = callBack;
	end
end

function SendToGate(msg)
	local data = msg:SerializeToString();
	GameCore.NetMgr.Instance:SocketSend(GameConfig.GATE_SOCKET,msg.MRID, msg.GROUPID, msg.UNITID, data);
	GameLog.LogSocketMessage(msg,true);
end

function SendToLogin(msg)
	local data = msg:SerializeToString();
	GameCore.NetMgr.Instance:SocketSend(GameConfig.LOGIN_SOCKET,msg.MRID, msg.GROUPID, msg.UNITID, data);
	GameLog.LogSocketMessage(msg,true);
end

function SendToHttp(url,data,callBack)
	local callIndex = GameCore.NetMgr.Instance:HttpSend(url,data);
	mHttpCallBacks[callIndex] = callBack;
	mHttpSendDatas[callIndex] = data;
	GameLog.LogHttpSendMessage(data,url);
end

function SendGMCommand(cmd)
	local msg = NetCS_pb.CSGmCmd();
	msg.cmd = string.format("%s",cmd or "");
    SendToGate(msg);
end

function ConnectSocket(socketIndex,socketIP,socketPort)
	GameCore.NetMgr.Instance:SocketConnect(socketIndex,socketIP,tonumber(socketPort));
end

function CloseSocket(socketIndex)
	GameCore.NetMgr.Instance:SocketClose(socketIndex);
end

return GameNet;