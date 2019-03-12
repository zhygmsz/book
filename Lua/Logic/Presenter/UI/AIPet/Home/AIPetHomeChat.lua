local AIPetHomeChat = class("AIPetHomeChat");--
local RSTATE = {idle = -1, preBegin = 0, recording = 1, prepare = 5, forCancel = 2, waitResult=3, finish = 4};
---聊天模块--这部分要重新整理
function AIPetHomeChat:ctor(ui)
    local panelPath = "Offset/ChatPanel/Offset/";
    local openSprite = ui:FindComponent("UISprite",panelPath.."OpenButton/Arrow");
    
    local wrapTablePath = panelPath.."Chat/Scroll View/TableWrapContent";
    local wrapPrefab = ui:Find(wrapTablePath.."/WrapItem");

    local OnItemCreat = function(contentItem)
        local itemTran = contentItem.transform;
        local itemServer1 = {};
        local subItemTran = itemTran:Find("LeftMessage");
        itemServer1.gameObject = subItemTran.gameObject;
        itemServer1.contentLabel = subItemTran:Find("ContentText/Label"):GetComponent("UILabel");
        itemServer1.widget = subItemTran:Find("ContentText/SpriteBg"):GetComponent("UIWidget");
        contentItem.left = itemServer1;
        local itemServer2 = {};
        local subItemTran2 = itemTran:Find("RightMessage");
        itemServer2.gameObject = subItemTran2.gameObject;
        itemServer2.contentLabel = subItemTran2:Find("ContentText/Label"):GetComponent("UILabel");
        itemServer2.widget = subItemTran2:Find("ContentText/SpriteBg"):GetComponent("UIWidget");
        contentItem.right = itemServer2;
    end

    self.wrapItemList = UITableWrapUtils.InitWrapTable(ui,wrapPrefab,10,nil,OnItemCreat);--(ui,prefab,count,parentTrans,OnItemCreat)
    local OnItemInit = function(go,wrapIndex,realIndex)
        local OnItemEnabled = function(wrapData, wrapItem)
            -- local subItem;
            -- if wrapData.dType == AIPetMgr.AIPET_DIALOG.AIPET then
            --     subItem = wrapItem.left;
            -- else
            --     subItem = wrapItem.right;
            -- end
            -- subItem.gameObject:SetActive(true);
            -- subItem.contentLabel.text = wrapData.msg;
            -- return subItem.widget, 15;
        end
        UITableWrapUtils.OnItemInit(go,wrapIndex,realIndex,self.wrapItemList, self.wrapDataList, OnItemEnabled);
    end

    local itemAlignType = UITableWrapContent.Align.Bottom;
    local dataAlignType = UITableWrapContent.Align.Bottom;

    local tableWrapContent = ui:FindComponent("UITableWrapContent",wrapTablePath);
    self.onInitItemFunc = UITableWrapContent.OnInitializeItem(OnItemInit);
    self.RefreshMsgContent = function()
        self.wrapDataList = AIPetMgr.GetDialogs();
        tableWrapContent:ResetWrapContent(table.maxn(self.wrapDataList), self.onInitItemFunc,itemAlignType,dataAlignType,true)
    end
    self.UpdateContent = function()
        local oldcount = table.maxn(self.wrapDataList);
        self.wrapDataList = AIPetMgr.GetDialogs();
        local newcount = table.maxn(self.wrapDataList);
        tableWrapContent:UpdateContent(oldcount -1, newcount);
    end

    local tweens = ui:Find("Offset/ChatPanel/Offset"):GetComponents(typeof(TweenPosition));
    
    self.tweensCom = CreateTweenCom(self,tweens);
    self.tweensCom:UseDefaultMode(openSprite);

    local textInput = ui:FindComponent("LuaUIInput",panelPath.."InputButtons/TextInput");
    self.GetInput = function()
        local value = textInput.value;
        textInput.value = "";
        return value;
    end

    local recordGo = ui:Find(panelPath.."InputButtons/RecordState").gameObject;
    local prepareGo = ui:Find(panelPath.."InputButtons/RecordState/LabelPrepare").gameObject;
    local countDownSprite = ui:FindComponent("UISprite", panelPath.."InputButtons/RecordState/SpriteSpeech");
    local recordingGo = ui:Find(panelPath.."InputButtons/RecordState/SpriteSpeech/SpriteRecording").gameObject;
    local cancelGo = ui:Find(panelPath.."InputButtons/RecordState/SpriteSpeech/SpriteForCancel").gameObject;
    self.OnUIPrepareRecord = function()
        prepareGo:SetActive(true);
        recordingGo:SetActive(false);
        cancelGo:SetActive(false);
        recordGo:SetActive(true);
    end
    self.OnUIReadyRecord = function()
        prepareGo:SetActive(false);
        recordingGo:SetActive(true);
        countDownSprite.fillAmount = 1;
    end
    self.OnUIRecording = function(cancel, fillAmount)
        recordGo:SetActive(not cancel);
        cancelingGo:SetActive(cancel);
        countDownSprite.fillAmount = fillAmount;
    end
    self.OnUIRecordFinish = function()
        recordGo:SetActive(false);
    end

    return self;
end

function AIPetHomeChat:OnEnable()
    --self.RefreshMsgContent();
    GameTimer.AddTimer(1,1,self.RefreshMsgContent);
end

function AIPetHomeChat:StartRecord()
    if not SystemInfo.IsMobilePlatform() or SystemInfo.IsEditor() then
        TipsMgr.TipByFormat("电脑端无法监听！");
        return;
    end
    self.state = RSTATE.prepare;--准备录音
    GameLog.Log("Start Record");
    self.OnUIPrepareRecord();
    local ret = AIPetMgr.StartRecord(self.OnRecordReady);--调用sdk开始录音；
end

function AIPetHomeChat:SendTextMsg()
    local msg = self.GetInput();
    if msg==nil or msg=="" then
        TipsMgr.TipByFormat("输入不能为空");
    end
    AIPetMgr.CallFairyText(msg);
end

function AIPetHomeChat:EndRecord()   
    if self.state == RSTATE.prepare then
        self:CancelRecord();
    elseif self.state == RSTATE.recording then
        self:SendRecord();
    elseif self.state == RSTATE.forCancel then
        self:CancelRecord();
    end
end

function AIPetHomeChat:CheckCancel(go)
    if self.state == RSTATE.recording or self.state == RSTATE.forCancel then
        local hoveredOb = UICamera.hoveredObject;
        self.state = (go == hoveredOb) and RSTATE.recording or RSTATE.forCancel;
        GameLog.Log("OnDrag state".. tostring(self.state));
    end
end

function AIPetHomeChat:CancelRecord()
    GameLog.Log("CancelRecord");
    self:OnUIRecordFinish();
    
    if self.state == RSTATE.recording then
        AIPetMgr.CancelRecord();    --调用sdk取消；
    end
    self.state = RSTATE.finish;
end

function AIPetHomeChat:SendRecord()
    GameLog.Log("SendRecord");
    self.state = RSTATE.waitResult;--发送录音
    self.OnUIRecordFinish();
    AIPetMgr.StopRecord();
end

function AIPetHomeChat.OnRecordReady()
    local _self = AIPetHomeChat;
    if _self.state ~= RSTATE.prepare then
        return;
    end
    _self.state = RSTATE.recording;--开始录音
    _self.startTime = GameTime.time_L;
    _self.OnUIReadyRecord();
    GameLog.Log("OnRecordReady");
end

function AIPetHomeChat:OnReceiveNewDialog(msg)
    self:UpdateContent();
end

function AIPetHomeChat:OnUpdate()
    if self.state == RSTATE.recording or self.state == RSTATE.forCancel then
        local timePassed = (GameTime.time_L - self.startTime);
        --GameLog.Log("on recording timepassed "..tostring(timePassed));
        if self.timeLimit<= timePassed then
            self:SendRecord();
            return;
        end
        local canceling = self.state == RSTATE.forCancel;
        self.OnUIRecording(canceling,1 - timePassed/self.timeLimit);
    end
end


return AIPetHomeChat;