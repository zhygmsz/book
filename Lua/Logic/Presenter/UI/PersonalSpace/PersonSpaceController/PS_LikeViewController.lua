

local PS_LikeViewController = class("PS_LikeViewController",nil)
local ChatInputWrap = require("Logic/Presenter/UI/Chat/ChatInputWrap")
require("Logic/Presenter/UI/Friend/UI_Shortcut_Player");
function PS_LikeViewController:ctor(ui,transform,index)
    self._ui = ui
    self._index = index
    self._likeRegion = transform:Find("Bg/TextZone/LikeRegion"):GetComponent("UIWidget")
    self._likesWidget = transform:Find("Bg/TextZone/LikeRegion/Likes"):GetComponent("UIWidget")
    self._likesEvent = transform:Find("Bg/TextZone/LikeRegion/Likes"):GetComponent("UIEvent")
    self._likesIcon = transform:Find("Bg/TextZone/LikeRegion/LikeIcon").gameObject
    self._mLikeItems={}
    self._likesEvent.id = self._index*10000+20
    self._msgCommon = nil
    self._momentdataIndex=nil
end

--添加玩家链接
local function AddLikesLink(msgCommon,name,palyerid)
    local newMsgLink = msgCommon.links:add()
    local msgLink  = Chat_pb.ChatMsgLink()
    msgLink.linkType = Chat_pb.ChatMsgLink.PLAYER
    msgLink.isValid = true
    msgLink.content = string.format("%s",name)
    msgLink.contentWithId = string.format("[%s]",name)
    msgLink.linkDesc.textDesc.color = "[0000ff]"
    msgLink.strParams:append(palyerid)
    newMsgLink:ParseFrom(msgLink)
    local split = ","
    if msgCommon.content == "" or msgCommon.content==nil then
        split = ""
    end
    msgCommon.content = string.format("%s%s%s",msgCommon.content,split,msgLink.contentWithId)
    return newMsgLink
end
 
 --更新评论信息
function PS_LikeViewController:InitLikeItems(momentdataIndex,data)
    self._momentdataIndex = momentdataIndex
    self._likesWidget.height = 0
    local hscale = 0
    self._msgCommon = Chat_pb.ChatMsgCommon()
    if data~=nil and #data>0 then
        for i = 1,#data do
            local pid =tostring(data[i])
            local playerdata= PersonSpaceMgr.GetPlayerInfoById(pid)
            if playerdata then
                AddLikesLink(self._msgCommon,playerdata:GetNickName(),pid)
            end
        end
        hscale =1
    end
    TextHelper.ProcessItemCommon(self._ui,
    self,
    self._msgCommon.content,
    self._likesWidget.transform,
    self._likesWidget.width,
    0,
    true,
    self._msgCommon.links, nil, nil, nil, nil)
    
    self._likesWidget.height = self.curHeight * hscale
    self._likeRegion.height = self._likesWidget.height
end

function PS_LikeViewController:GetWidget()
    return self._likeRegion
end

function PS_LikeViewController:OnClick(go,localid)
    local linkIdx =self.imageLabelContent:ProcessClick()
    if linkIdx then
        local msgCommon  =self._msgCommon
        local linkData = msgCommon.links[linkIdx]
        if linkData then
           if linkData.linkType == Chat_pb.ChatMsgLink.PLAYER then
                local playerid  = linkData.strParams[1]
                UI_Shortcut_Player.ShowPlayerByID(playerid)
           end
        end
    end
end 

return PS_LikeViewController