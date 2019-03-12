module("ChatMgr",package.seeall);


--弹幕耦合了聊天   弹幕用的聊天的Token 
--引擎部提供的弹幕相关http接口，在他们后台实现里耦合了聊天基础，所以在客户端使用接口时，使用的聊天token
--后续要跟引擎部讨论，把弹幕功能单独剥离出来，成为一个独立的SNS模块

--发送弹幕
function RequestSendBullet(roomID,roomName,textData,playOffset, isCommon)
    if IsEmptyContent(textData) then return; end

    local msg = Chat_pb.ChatMsgCommon()
    ChatMgr.SetSenderInfo(msg.sender)
    local illegalflag = false
    msg.content, illegalflag = string.ReplaceIllegalWord(textData)
    local finalContent = msg:SerializeToString();
    local bulletAddMsg = Chat_pb.ChatMsgBulletAdd();

    local function OnSendBullet(jsonData)
        if jsonData then
            bulletAddMsg.bulletID = tonumber(jsonData["result"]);

            RequestSendRoomMessage(Chat_pb.CHAT_ROOM_BULLET,roomName,Chat_pb.CHATMSG_BULLET_ADD,bulletAddMsg:SerializeToString());

            if illegalflag then
                TipsMgr.TipByKey("bullet_input_ilegal")
            else
                TipsMgr.TipByKey("bullet_send_success");
            end
        end
    end
    if mModuleInit.InitClient then
        bulletAddMsg.sendTime = os.date("%Y-%m-%d %H:%M:%S",os.time());
        bulletAddMsg.sendContent:ParseFromString(finalContent);
        bulletAddMsg.playTime = playOffset;
        bulletAddMsg.thumbUpCount = 0;
        bulletAddMsg.bulletID = -1;
        bulletAddMsg.bulletName = roomName;

        local requestAddr = mChatPHPAddr;
        local requestParam = {};
        table.insert(requestParam,mChatPHPCommonParam);
        table.insert(requestParam,"action=AddBarrage");
        table.insert(requestParam,"brg_name=".. tostring(roomID));
        table.insert(requestParam,"content=".. string.ToBase64(bulletAddMsg:SerializeToString()));
        requestParam = table.concat(requestParam,"&");

        GameNet.SendToHttp(requestAddr, requestParam, OnSendBullet);
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end

--读取弹幕
function RequestGetBullet(roomID,startMsgID,msgCount)
    local function OnGetBullet(jsonData)   
        if jsonData then
            local msgJsons = jsonData["result"];
            local msgLuas = {};
            if msgJsons then
                for _,msg in ipairs(msgJsons) do
                    local bulletAddMsg = Chat_pb.ChatMsgBulletAdd();
                    bulletAddMsg:ParseFromString(string.FromBase64(msg.content));
                    bulletAddMsg.bulletID = tonumber(msg.msgid);
                    bulletAddMsg.thumbUpCount = tonumber(msg.likecnt);
                    table.insert(msgLuas,bulletAddMsg);
                end
            end
            GameEvent.Trigger(EVT.BULLET, EVT.BULLET_ONGETBULLET, msgLuas)
        end
    end
    if ChatMgr.IsInited() then
        local requestAddr = mChatPHPAddr
        local requestParam = {}
        table.insert(requestParam,mChatPHPCommonParam);
        table.insert(requestParam,"action=GetBarrageList");
        table.insert(requestParam,"brg_name="..tostring(roomID));
        table.insert(requestParam,"start="..tostring(startMsgID or 0));
        table.insert(requestParam,"cnt="..tostring(msgCount or 50));
        requestParam = table.concat(requestParam,"&");

        GameNet.SendToHttp(requestAddr, requestParam, OnGetBullet);
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end

--弹幕点赞
function RequestAddThumbUp(roomID,bulletAddMsgData)
    local function OnAddThumbUp(jsonData)   
        if jsonData then
            local count = jsonData["result"];
            bulletAddMsgData.thumbUpCount = bulletAddMsgData.thumbUpCount + 1;
            local thumbUpMsg = Chat_pb.ChatMsgBulletThumbUpTransmit();
            SetSenderInfo(thumbUpMsg.sender);
            thumbUpMsg.sendTime = os.date("%Y-%m-%d %H:%M:%S",os.time());
            thumbUpMsg.bullet:ParseFrom(bulletAddMsgData);
            RequestSendPrivateMessage(Chat_pb.CHATMSG_BULLET_THUMBUP_TRANSMIT,thumbUpMsg:SerializeToString(),bulletAddMsgData.sendContent.sender.senderID);

            GameEvent.Trigger(EVT.BULLET, EVT.BULLET_ONTHUMBUP)

            TipsMgr.TipByKey("bullet_thump_up_success");
        end
    end
    if mModuleInit.InitClient then 
        local requestAddr = mChatPHPAddr
        local requestParam = {}
        table.insert(requestParam,mChatPHPCommonParam);
        table.insert(requestParam,"action=AddBarrageLike");
        table.insert(requestParam,"brg_name="..tostring(roomID));
        table.insert(requestParam,"msgid="..tostring(bulletAddMsgData.bulletID));
        requestParam = table.concat(requestParam,"&");

        GameNet.SendToHttp(requestAddr, requestParam, OnAddThumbUp);

        GameLog.Log("chat send http thumbup bullet");
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end

--评论弹幕
function RequestAddComment(roomID,textData,bulletAddMsgData)
    local inputInfo = textData:GetInput();
    if IsEmptyContent(inputInfo) then return; end
    local bulletCommentAddMsg = Chat_pb.ChatMsgBulletCommentAdd();  
    local function OnAddComment(jsonData)   
        if jsonData then
            local bulletCommentTransmitMsg = Chat_pb.ChatMsgBulletCommentTransmit();
            bulletCommentTransmitMsg.comment:ParseFrom(bulletCommentAddMsg);
            bulletCommentTransmitMsg.bullet:ParseFrom(bulletAddMsgData);
            RequestSendPrivateMessage(Chat_pb.CHATMSG_BULLET_COMMENT_TRANSMIT,bulletCommentTransmitMsg:SerializeToString(),bulletAddMsgData.sendContent.sender.senderID);
            TipsMgr.TipByKey("bullet_comment_success");
        end
    end
    if mModuleInit.InitClient then
        bulletCommentAddMsg.sendTime = os.date("%Y-%m-%d %H:%M:%S",os.time());
        bulletCommentAddMsg.sendContent:ParseFromString(inputInfo);
        bulletCommentAddMsg.bulletID = bulletAddMsgData.bulletID;
        bulletCommentAddMsg.bulletName = bulletAddMsgData.bulletName;

        local requestAddr = mChatPHPAddr
        local requestParam = {}
        table.insert(requestParam,mChatPHPCommonParam);
        table.insert(requestParam,"action=AddBarrageCmt");
        table.insert(requestParam,"brg_name="..tostring(roomID));
        table.insert(requestParam,"msgid="..tostring(bulletAddMsgData.bulletID));
        table.insert(requestParam,"content="..string.ToBase64(bulletCommentAddMsg:SerializeToString()));
        requestParam = table.concat(requestParam,"&");

        GameNet.SendToHttp(requestAddr, requestParam, OnAddComment);
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end

--评论获取
function RequestGetComment(roomID,bulletID,commentStartID,commentCount)
    local function OnGetComment(jsonData)   
        if jsonData then
            local commentDatas = {};
            local comments = jsonData["result"];
            for idx,comment in pairs(comments) do
                local commentAddMsg = Chat_pb.ChatMsgBulletCommentAdd();
                commentAddMsg:ParseFromString(string.FromBase64(comment));
                table.insert(commentDatas,commentAddMsg);
            end
            MessageSub.SendMessage(GameConfig.SUB_G_CHAT,GameConfig.SUB_U_CHAT_BULLET_GET_COMMENT,bulletID,commentDatas);
        end
    end
    if mModuleInit.InitClient then
        local requestAddr = mChatPHPAddr
        local requestParam = {}
        table.insert(requestParam,mChatPHPCommonParam);
        table.insert(requestParam,"action=GetBarrageCmtList");
        table.insert(requestParam,"brg_name="..tostring(roomID));
        table.insert(requestParam,"msgid="..tostring(bulletID));
        table.insert(requestParam,"start="..tostring(commentStartID or 0));
        table.insert(requestParam,"cnt="..tostring(commentCount or 50));
        requestParam = table.concat(requestParam,"&");

        GameNet.SendToHttp(requestAddr, requestParam, OnGetComment);
    else
        TipsMgr.TipByKey("chat_server_token_receive_fail");
    end
end

return ChatMgr;