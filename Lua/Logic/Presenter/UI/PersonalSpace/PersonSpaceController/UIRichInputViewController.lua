local UIRichInputViewController = class("UIRichInputViewController",nil)

function UIRichInputViewController:ctor(root,panel,btnBack,btnSign,btnSend,input,defaulttext,commonLinkOpenType,sendCallback,callObj,hiddenPos,showPos)
    --回复视图
    self._obj = root
    self._backEvent = btnBack:GetComponent("UIEvent")
    self._lookEvent = btnSign:GetComponent("UIEvent")
    self._replyEvent = btnSend:GetComponent("UIEvent")
    self._Input = input:GetComponent("LuaUIInput")
    self._mChatInputWrap = ChatInputWrap.new(self._Input, commonLinkOpenType or ChatMgr.CommonLinkOpenType.FromPersonSpace)
    self._mChatInputWrap:ResetMsgCommon()
    self._mChatInputWrap:ResetLimitCount(1000)
    self._mChatInputWrap:ResetRoomType(Chat_pb.CHAT_ROOM_WORLD)
    self._defaultText =defaulttext
    self._Input.defaultText = defaulttext
    self._InputLabel = self._Input.label
    self._InputWidget = input:GetComponent("UIWidget")
    self._originWidth = self._InputWidget.width
    self._originPos = self._Input.transform.localPosition
    self._panel =  panel:GetComponent("UIPanel")
    self._originPanelPos = self._panel.transform.localPosition
    local function OnMsgChange()
        self:OnInputChange()
    end
    local changeCall = EventDelegate.Callback(OnMsgChange);
    EventDelegate.Add(self._Input.onChange,changeCall);
    self._obj:SetActive(false)
    self._tweenPos = self._obj:AddComponent(typeof(TweenPosition))

    local function OnTweenFinish()
        self._tweenPos.enabled = false
    end
    local finishFunc = EventDelegate.Callback(OnTweenFinish)
    EventDelegate.Set(self._tweenPos.onFinished, finishFunc)
    self._sendCallback = sendCallback
    self._callObj =callObj
    self._hiddenPos =hiddenPos
    self._showPos =showPos
    self._inputLimit = -1;
end

function UIRichInputViewController:SetInputLimit(limit)
    self._inputLimit = limit
    self._mChatInputWrap:ResetLimitCount(limit)
end

function UIRichInputViewController:ResetDefaultText(defaulttext)
    self._Input.defaultText = defaulttext
end

function UIRichInputViewController:OnInputChange()
    local ow = self._originWidth
    local cw = self._InputLabel.width
    local cha = cw-ow  >0 and cw-ow or 0
    self._panel.clipOffset = Vector2(cha,0)
    self._panel.transform.localPosition = Vector3(self._originPanelPos.x-cha,self._originPanelPos.y,self._originPanelPos.z)
    self._InputWidget.width = cw>ow and cw or ow

    -- if self._inputLimit>0 then
    --     local content = self._Input.value
    --     --local content =self._mChatInputWrap:GetMsgCommon():SerializeToString()
    --     local length,found,len =GameUtils.StringCharactorLength(content,{",","，"},self._inputLimit);
    --     if length>self._inputLimit then
    --         self._Input.value = string.sub(content,1,len)
    --         --TipsMgr.TipByKey("createrole_name_fail_2");
    --         TipsMgr.TipByFormat("字数超出输入%d个字符上限",self._inputLimit)
    --     end
    -- end
end


function UIRichInputViewController:SetBtnEventId(backeventid,signeventid,sendeventid)
    self._backEvent.id = backeventid
    self._lookEvent.id = signeventid
    self._replyEvent.id = sendeventid
end

function UIRichInputViewController:SetTweenPos(hiddenPos,showPos)
    self._hiddenPos =hiddenPos
    self._showPos =showPos
end


function UIRichInputViewController:SetSendCallback(sendCallback,callObj)
    self._sendCallback = sendCallback
    self._callObj =callObj
end

function UIRichInputViewController:ShowViewTween(show)
    self._obj:SetActive(true)
    self._tweenPos.enabled = true
    self._tweenPos.worldSpace = false
    if show then
        self._Input.value = ""
        self._InputWidget.width = self._originWidth
        self._Input.transform.localPosition = self._originPos
        self._tweenPos.from = self._hiddenPos
        self._tweenPos.to = self._showPos
        self._replyOpen = true
    else
        self._tweenPos.to = self._hiddenPos
        self._tweenPos.from =  self._showPos
        self._replyOpen = false
    end
	self._tweenPos.duration = 0.1
	self._tweenPos:ResetToBeginning()
    self._tweenPos:PlayForward()
end

function UIRichInputViewController:OnClickBack()
    self:ShowViewTween(false)
end

function UIRichInputViewController:OnClickSign()
    self._mChatInputWrap:OnLinkBtnClick()
end

--msgCommon
function UIRichInputViewController:OnClickSend()
     --回復
     local content =self._mChatInputWrap:GetMsgCommon()--:SerializeToString()
     self:ShowViewTween(false)
     if self._sendCallback then
         if self._callObj then
             self._sendCallback(self._callObj,content)
         else
             self._sendCallback(content)
         end
     end
end

return UIRichInputViewController