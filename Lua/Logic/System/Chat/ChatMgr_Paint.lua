module("ChatMgr",package.seeall);

--发送绘图信息
function RequestSendPaintMessage(paintData)
    local leftCount = #paintData;
    local sliceEnd = nil;
    local sliceMsg = Chat_pb.ChatMsgCommon();
    local sliceLink = sliceMsg.links:add();
    local sliceLen = 512;
    sliceMsg.roomType = Chat_pb.CHAT_ROOM_WORLD;
    sliceMsg.contentPostfix = "#913";
    SetSenderInfo(sliceMsg.sender);
    sliceLink.linkType = Chat_pb.ChatMsgLink.PAINT;
    sliceLink.strParams:append(tostring(UserData.PlayerID));
    sliceLink.intParams:append(0);
    sliceLink.byteParams:append("");
    --begin
    RequestSendRoomMessage(sliceMsg.roomType,"",Chat_pb.CHATMSG_PAINT,sliceMsg:SerializeToString());
    --content
    sliceLink.intParams[1] = -1;
    for i = 1,#paintData,sliceLen do
        sliceEnd = i + (leftCount < sliceLen and leftCount or sliceLen) - 1;
        leftCount = leftCount - sliceLen;
        sliceLink.byteParams:set(1,string.sub(paintData,i,sliceEnd));
        RequestSendRoomMessage(sliceMsg.roomType,"",Chat_pb.CHATMSG_PAINT,sliceMsg:SerializeToString());
    end
    --end
    sliceLink.intParams[1] = 1;
    sliceLink.byteParams:set(1,"");
    RequestSendRoomMessage(sliceMsg.roomType,"",Chat_pb.CHATMSG_PAINT,sliceMsg:SerializeToString());
end

return ChatMgr;