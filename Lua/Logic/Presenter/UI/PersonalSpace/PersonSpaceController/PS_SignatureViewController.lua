--个人空间签名档的处理类型
local PS_SignatureViewController = class("PS_SignatureViewController",nil)

function PS_SignatureViewController:ctor(ui,mode,playerid)
    --UI对象
    self._ui = ui
    --显示模式  1是别人的 2是自己的
    self._mode = mode
    if playerid~=nil then
        self._playerid =playerid
    end
    --个性签名gameobject
    self._mSignatureGo=nil
    --个性签名输入框Input
    self._mSignatureInput=nil
    --个人信息
    self._mPlayerInfo = nil
    --输入信息
    self._mInputInfo = {}
    --录音按钮
    self._mRecordVoiceBtn = nil
    --播放按钮
    self._mPlayVoiceBtn = nil
    self._mShowRecord = false
    self:Init()
end

function PS_SignatureViewController:Init()
    self._mSignatureGo = self._ui:Find("Mid/ZoneView/Signature").gameObject
    self._mSignatureInput = self._ui:FindComponent("LuaUIInput", "Mid/ZoneView/Signature/Input")
    self._mRecordVoiceBtn = self._ui:Find("Mid/ZoneView/Signature/RecordVoice")
    self._mPlayVoiceBtn = self._ui:Find("Mid/ZoneView/Signature/PlayVoice")
    local function onDeSelect()
        self:UpdateSelfintro()
    end
    local changeCall = EventDelegate.Callback(onDeSelect);
    EventDelegate.Set( self._mSignatureInput.onDeSelect,changeCall);
    self._mSignatureInput.defaultText = TipsMgr.GetTipByKey("personspace_signature_default")
end

function PS_SignatureViewController:SetPlayerId(pid)
    self._playerid = pid
end

function PS_SignatureViewController:SetShowMode(mode)
    self._mode = mode
end

function PS_SignatureViewController:UpdateData()
    self._mPlayerInfo = PersonSpaceMgr.GetPlayerInfoById(self._playerid)
end

function PS_SignatureViewController:UpdateSelfintro()
    self._mPlayerInfo:SaveSelfintro(self._mSignatureInput.value,true)
end

function PS_SignatureViewController:UpdateView()
    if self._mPlayerInfo==nil then return end
    if self._mPlayerInfo:GetSelfintro() then
        self._mSignatureInput.value =  self._mPlayerInfo:GetSelfintro()
    end
    --"voicemsg","voicemsglen"
    if self._mode == 2 then
        self._mRecordVoiceBtn.gameObject:SetActive(true)
        self._mPlayVoiceBtn.gameObject:SetActive(false)
        self._mSignatureInput.enabled = true
    else
        self._mRecordVoiceBtn.gameObject:SetActive(false)
        self._mPlayVoiceBtn.gameObject:SetActive(self._mPlayerInfo:GetVoiceUrl()~=nil)
        self._mSignatureInput.enabled = false
    end
end

function PS_SignatureViewController:OnPress(press,id)
    if self._mode == 2 then
        if id == 403 then
            --TODO 语音使用方式修改,请使用新的录音方式
        end
    end
end

function PS_SignatureViewController:OnClick(go, id)
    if self._mode == 2 then
        --录制按钮
        if id == 400 then
            --弹出录制界面
            self._mShowRecord = not self._mShowRecord
            UIMgr.ShowUI(AllUI.UI_PersonalSpace_Voice)
        elseif id == 405 then --播放
        end
    end
end

return PS_SignatureViewController