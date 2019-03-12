module("UI_Mail", package.seeall)
local MailListWidget = require("Logic/Presenter/UI/Mail/MailListWidget")
local mMailListWidget
local mMailListBaseEventId = 30
local mItemBaseEventId = 150

local mSenderPos1 = Vector3(280, -45, 0)  --有附件 落款的位置
local mSenderPos2 = Vector3(280, -150, 0) --无附件 落款的位置

local mDelBtnPos1 = Vector3(-150, -200, 0) --有领取按钮 删除按钮的位置
local mDelBtnPos2 = Vector3(0, -200, 0) -- 无领取按钮 删除按钮的位置

local mSelf

local mComs = 
{
    mailListTrs = nil,
    mailCount = nil,
    mailTitle = nil,
    mailContent = nil,
    itemPerfab = nil,
    itemParentNode = nil,
    getedSign = nil,
    noMail = nil,
    sender = nil,
    AffixNode = nil,
    getBtn = nil,
    delBtn = nil,
    tipsNode = nil,
    tipsStateNode = nil,
    tipsState = nil,
    tipsContent = nil,
    tipsStop = nil,
    contentsc = nil,
    itemsc = nil,
    deleteBtn = nil,
    deletaBC = nil,
    getallBtn = nil,
    getallBC = nil,
}

local mCurItemList = nil

local function SetItemListPanel(data)

    for i = 1, mComs.itemParentNode.childCount do
        UnityEngine.GameObject.Destroy(mComs.itemParentNode:GetChild(i - 1).gameObject)
    end 

    if #data.itemlist > 0 then
        mCurItemList = data.itemlist
        mComs.AffixNode:SetActive(true)
        mComs.getedSign:SetActive(data.attach_picked == 1)
        mComs.getBtn:SetActive(data.attach_picked == 0)
        mComs.sender.transform.localPosition = mSenderPos1
        mComs.delBtn.transform.localPosition = data.attach_picked == 0 and mDelBtnPos1 or mDelBtnPos2 

        for i, info in ipairs(data.itemlist) do
            local itemTrs = mSelf:DuplicateAndAdd(mComs.itemPerfab, mComs.itemParentNode, i)
            itemTrs.gameObject:SetActive(true)
            local width = itemTrs.gameObject:GetComponent("UISprite").width
            itemTrs.gameObject:GetComponent("UIEvent").id = mItemBaseEventId + i
            itemTrs.localPosition = Vector3.New(width * (i - 1), 0, 0) 
            itemTrs.localScale = Vector3.one
    
            local icon = itemTrs:Find("icon"):GetComponent("UISprite")
            local num = itemTrs:Find("num"):GetComponent("UILabel")
            num.text = info.count
            local itemdata = ItemData.GetItemInfo(info.itemid)
            if itemdata then
                icon.spriteName = itemdata.icon_big
            end
        end
    else
        --无附件
        mComs.AffixNode:SetActive(false)
        mComs.getBtn:SetActive(false)
        mComs.sender.transform.localPosition = mSenderPos2
        mComs.delBtn.transform.localPosition = mDelBtnPos2
    end  
    
end

local function OnMailClick(data)
    if data == nil then
        GameLog.LogError("data is nil ! ----- On click mail callback")
        return 
    end
    MailMgr.SetCurrShowMid(data.mid)
    if data.read == 0 then
        MailMgr.RequestReadMail(data.mid)
    end
    mComs.mailTitle.text = data.title
    mComs.mailContent.text = data.text
    mComs.sender.text = data.from

    mComs.contentsc:ResetPosition()
    mComs.itemsc:ResetPosition()

    SetItemListPanel(data)
end

local function OnUpdateMail(sIndex, isShowTips)

    local count = MailMgr.GetMailCount()

    mComs.noMail:SetActive(count <= 0)
    mComs.getBtn:SetActive(count > 0)
    mComs.delBtn:SetActive(count > 0)
    mComs.AffixNode:SetActive(count > 0)
    mComs.mailContent.gameObject:SetActive(count > 0)
    mComs.sender.gameObject:SetActive(count > 0)
    if count <= 0 then
        mComs.mailTitle.text = WordData.GetWordStringByKey("Mail_NoOne_Title")  
    end

    local dataList = MailMgr.GetMailList()
    local index = mMailListWidget:GetCurRealIdx() or 1

    if index > #dataList then
        index = #dataList
    end

    if sIndex == 1 then
        index = 1 
    end

    mMailListWidget:Show(dataList, index)

    mComs.mailCount.text = string.format( WordData.GetWordStringByKey("Mail_Tips_Count"), count )

    if isShowTips then
        local state = MailMgr.GetTipsState()
        if state and count >= ConfigData.GetIntValue("Mail_count_full") then
            mComs.tipsNode:SetActive(true)
            mComs.tipsContent.text = string.format( WordData.GetWordStringByKey("Mail_space_full"), count)
            mComs.tipsState:SetActive(not state)
        else
            mComs.tipsNode:SetActive(false)
        end
    end

    local readedList = MailMgr.GetReadedList()

    local haveItem = MailMgr.GetHaveAchstate()
    UIMgr.MakeUIGrey(mComs.getallBtn, not haveItem)
    mComs.getallBC.enabled = haveItem
end

local function OnUpdateReadState()
    local realIndex = mMailListWidget:GetCurRealIdx()
    local mid = MailMgr.GetCurrShowMid()
    local data = MailMgr.GetMailInfoByMid(mid)

    mMailListWidget:UpdateItem(realIndex, data)
end

local function ShowItemTips(index)
    if mCurItemList == nil then
        return 
    end
    local data = mCurItemList[index - mItemBaseEventId]
    local itemData = ItemData.GetItemInfo(data.itemid)
    BagMgr.OpenItemTipsByTempId(EquipMgr.ItemTipsStyle.FromTempId, data.itemid)
end

local function Reg()
    GameEvent.Reg(EVT.MAIL, EVT.MAIL_ONUPDATE, OnUpdateMail)
    GameEvent.Reg(EVT.MAIL, EVT.MAIL_ONREADSTATECHANGE, OnUpdateReadState)
end

local function UnReg()
    GameEvent.UnReg(EVT.MAIL, EVT.MAIL_ONUPDATE, OnUpdateMail)
    GameEvent.UnReg(EVT.MAIL, EVT.MAIL_ONREADSTATECHANGE, OnUpdateReadState)
end

function OnCreate(self)

    mSelf = self
    
    mComs.mailListTrs = self:Find("Offset/MailListPanel/Bg")
    mComs.mailCount = self:Find("Offset/MailListPanel/Bg/MailCount"):GetComponent("UILabel")
    mComs.mailTitle = self:Find("Offset/ContentPanel/Title/Name"):GetComponent("UILabel")
    mComs.mailContent = self:Find("Offset/ContentPanel/Bg/scrollview/Content"):GetComponent("UILabel")
    mComs.itemPerfab = self:Find("Offset/ContentPanel/Bg/Affix/ItemPerfab")
    mComs.itemParentNode = self:Find("Offset/ContentPanel/Bg/Affix/ItemList/scrollview/wrapcontent")
    mComs.getedSign = self:Find("Offset/ContentPanel/Bg/Affix/Geted").gameObject
    mComs.noMail = self:Find("Offset/NoMail").gameObject
    mComs.sender = self:Find("Offset/ContentPanel/Bg/Sender"):GetComponent("UILabel")
    mComs.AffixNode = self:Find("Offset/ContentPanel/Bg/Affix").gameObject
    mComs.getBtn = self:Find("Offset/ContentPanel/Bg/GetBtn").gameObject
    mComs.delBtn = self:Find("Offset/ContentPanel/Bg/DeleteBtn").gameObject

    mComs.tipsNode = self:Find("Offset/Tips").gameObject
    mComs.tipsNode:SetActive(false)
    mComs.tipsStateNode = self:Find("Offset/Tips/bg/stateBg").gameObject
    mComs.tipsState = self:Find("Offset/Tips/bg/stateBg/state").gameObject
    mComs.tipsContent = self:Find("Offset/Tips/bg/content"):GetComponent("UILabel")
    mComs.tipsStop = self:Find("Offset/Tips/bg/stateBg/txt"):GetComponent("UILabel")
    mComs.tipsStop.text = WordData.GetWordStringByKey("Mail_space_full2_inform")

    mComs.contentsc = self:Find("Offset/ContentPanel/Bg/scrollview"):GetComponent("UIScrollView")
    mComs.itemsc = self:Find("Offset/ContentPanel/Bg/Affix/ItemList/scrollview"):GetComponent("UIScrollView")

    mComs.deleteBtn = self:Find("Offset/MailListPanel/Bg/DeleteBtn"):GetComponent("UISprite")
    mComs.deletaBC = self:Find("Offset/MailListPanel/Bg/DeleteBtn"):GetComponent("BoxCollider")

    mComs.getallBtn = self:Find("Offset/MailListPanel/Bg/GetBtn"):GetComponent("UISprite")
    mComs.getallBC = self:Find("Offset/MailListPanel/Bg/GetBtn"):GetComponent("BoxCollider")


    mMailListWidget = MailListWidget.new(mComs.mailListTrs, mMailListBaseEventId, OnMailClick)
end

function OnEnable()
    Reg()

    MailMgr.RequestMailList()
end

function OnDisable()
    UnReg()
end

function OnDestory()
    
end

function OnClick(go, id)
    local currShowMid = MailMgr.GetCurrShowMid()
    if id == -1 then 
        UIMgr.UnShowUI(AllUI.UI_Mail)
    elseif id == -2 then
        mComs.tipsNode:SetActive(false)
    elseif id == 1 then
        UIMgr.UnShowUI(AllUI.UI_Mail)
        UIMgr.ShowUI(AllUI.UI_Friend_Main)
    elseif id == 2 then
    elseif id == 3 then
    elseif id == 4 then
    elseif id == 11 then --一键提取
        if MailMgr.GetHaveAchstate() then
            MailMgr.RequestCSMailGetAttach(0) --0代表领取所有有附件的邮件
        end
    elseif id == 12 then --删除已读
        local midList = MailMgr.GetReadedList()
        if next(midList) == nil then
            TipsMgr.TipByKey("Mail_inform")
            return 
        end
        MailMgr.RequestCSMailDel(midList)
    elseif id == 13 then --删除邮件
        local midList = {}
        table.insert(midList, currShowMid)
        MailMgr.RequestCSMailDel(midList)
    elseif id == 14 then -- 提取附件
        MailMgr.RequestCSMailGetAttach(currShowMid)
    elseif id == 15 then
        local state = MailMgr.GetTipsState()
        MailMgr.SetTipsState( not state )
        mComs.tipsState:SetActive(state)
    elseif id > mMailListBaseEventId and id < mItemBaseEventId then
        mMailListWidget:OnClick(id)
    elseif id > mItemBaseEventId then
        ShowItemTips(id)
    end
end