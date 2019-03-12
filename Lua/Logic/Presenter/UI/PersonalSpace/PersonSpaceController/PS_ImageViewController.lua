

local PS_ImageViewController = class("PS_ImageViewController",nil)
local ChatInputWrap = require("Logic/Presenter/UI/Chat/ChatInputWrap")
local UI_PersonalSpace_ImageView = require("Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_ImageView")

function PS_ImageViewController:ctor(ui,transform,index)
    self._ui = ui
    self._index = index
    --图片区域
    self._imageItem = transform:Find("Bg/ImageItem").gameObject
    self._imageItem:SetActive(false)
    self._imageContentWidget = transform:Find("Bg/ImageContent"):GetComponent("UIWidget")
    self._imageContentUITable = transform:Find("Bg/ImageContent"):GetComponent("UITable")

    self._mImageItems={}
    self._mImageData = nil
    self._momentdataIndex = nil
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
    msgCommon.content = string.format("%s,%s",msgCommon.content,msgLink.contentWithId)
    return newMsgLink
end
 
--更新图片信息
function PS_ImageViewController:InitImageItems(momentdataIndex,data)
    self._momentdataIndex = momentdataIndex
    self._mImageData = data
    self._imageItem:SetActive(true)
    local count = table.getn(data)
    for i=1,#self._mImageItems do
        self._mImageItems[i].gameObject:SetActive(false);
    end
    for i = 1,count do
        if self._mImageItems[i] == nil then
            local item = {};
            item.index = i;
            item.gameObject = self._ui:DuplicateAndAdd(self._imageItem.transform,self._imageContentUITable.gameObject.transform,i).gameObject;
            item.gameObject.name = tostring(10000 + i);
            item.transform = item.gameObject.transform;
            item.image = item.transform:Find("Sprite"):GetComponent("UITexture")
            item.event = item.transform:GetComponent("UIEvent")
            item.event.id = self._index*10000+i+1000
            self._mImageItems[i] = item;
            item.gameObject:SetActive(false);
        end
        self._mImageItems[i].image.mainTexture = nil
        if data[i] and data[i].img then
            PersonSpaceMgr.LoadMomentImage(self._mImageItems[i].image,data[i].img)
        end
        self._mImageItems[i].gameObject:SetActive(true);
    end
    self._imageItem:SetActive(false);
    self._imageContentUITable:Reposition()
    self._imageContentWidget.height = count ==0 and 2 or  count >3 and 404 or 202
end

function PS_ImageViewController:GetWidget()
    return self._imageContentWidget
end

function PS_ImageViewController:OnClick(go,localid)
    local index = localid
    --self._mImageItems[index].image.mainTexture
    UI_PersonalSpace_ImageView.ShowImages(self._mImageData,index,true)
end 

return PS_ImageViewController