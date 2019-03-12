module("UI_AddOnePkg", package.seeall)

local JSON = require("cjson")

local EmojiInfo = require("Logic/System/Chat/EmojiInfo")
local PkgInfo = require("Logic/System/Chat/PkgInfo")

--组件
local mSelf
local mOffsetGo
local mMainWidgetGo
local mNameWidgetGo
local mDialogWidgetGo

local mIconBgGo
local mIconTexGo
local mIconTex

local mItemTemp
local mGrid
local mGridTrs

local mFinishLabel
local mFinishGo

local mPkgNameLabel
local mPkgDesLabel
local mNameInput
local mDesInput

--变量
local mEvents = nil
local mGridNum = 3

local mEmojiItemDic = {}

--上传之前，已添加的表情集合，引用mgr里的
local mAddingList = nil
--当前显示add的索引
local mCurAddIdx = -1

local mUIEventIdSpan = 2

--调整完成按钮标志
local mFinishFlag = false
local mFinishDes = "互相点击可以调整位置"
local mNoFinishDes = "长按即可删除图片或调整位置"
--当前长按选中的索引
local mCurLongPressIdx = -1

local mIconSquareLen = 150

local mLastNameInputValue = ""
local mLastDesInputValue = ""

local mPkgNameStr = "表情系列的名称"
local mPkgDesStr = "请输入表情系列描述（不超过50个字符）"

--异步添加的表情图数量
local mAddingNum = 0


--local方法
--[[
    @desc: 检测该picId是否已经存在于待添加列表里
    --@picId: 
]]
local function CheckPicIsExist(picId)
    local isExist = false
    for _, info in ipairs(mAddingList) do
        if info:GetPicId() == picId then
            isExist = true
            break
        end
    end
    return isExist
end

local function AddAddingNum()
    mAddingNum = mAddingNum + 1
end

local function ReduceAddingNum()
    mAddingNum = mAddingNum - 1
end

local function CheckAddingNumIsZero()
    return mAddingNum == 0
end

local function SetLabelText(name, des)
    mLastNameInputValue = name
    mLastDesInputValue = des
    mPkgNameLabel.text = mLastNameInputValue ~= "" and mLastNameInputValue or mPkgNameStr
    mPkgDesLabel.text = mLastDesInputValue ~= "" and mLastDesInputValue or mPkgDesStr
end

--[[
    @desc: 
    --@isMain:
	--@state: 关闭原因，isMain为true时才有用， 1确定，2取消，3关闭，4OnEnable方法里
]]
local function SetWidgetVisible(isMain, state)
    mMainWidgetGo:SetActive(isMain)
    mNameWidgetGo:SetActive(not isMain)

    if not isMain then
        --打开命名界面
        mNameInput.value = mLastNameInputValue
        mDesInput.value = mLastDesInputValue
    else
        --关闭命名界面
        if state == 1 then
            SetLabelText(mNameInput.value, mDesInput.value)
        elseif state == 2 or state == 3 then
            mNameInput.value = ""
            mDesInput.value = ""
        elseif state == 4 then
            SetLabelText("", "")
        end
    end
end

local function OnLoadBgTex()
    UIUtil.AdjustInSquare(mIconTex, mIconSquareLen, true)
end

--[[
    @desc: 封面设置必须在第一个表情图加载回调里进行
    --@info: 
]]
local function SetCoverIcon(relativePath, url)
    if relativePath and url then
        mIconTexGo:SetActive(true)
        mIconBgGo:SetActive(false)
        if relativePath ~= "" then
            UIUtil.LoadImage(mIconTex, CustomEmojiMgr.GetEmojiSize(), relativePath, false, OnLoadBgTex, nil)
        elseif url ~= "" then
            UIUtil.LoadImage(mIconTex, CustomEmojiMgr.GetEmojiSize(), url, true, OnLoadBgTex, nil)
        end
    else
        mIconTexGo:SetActive(false)
        mIconBgGo:SetActive(true)
    end
end

local function RestoreGrid()
    if #mAddingList > 0 then
        local maxIdx = 0
        for idx, info in ipairs(mAddingList) do
            maxIdx = idx
            mEmojiItemDic[idx]:RestoreByInfo(info)
        end
        maxIdx = maxIdx + 1
        if maxIdx <= mGridNum then
            mCurAddIdx = maxIdx
            mEmojiItemDic[maxIdx]:SetState(2)               
        end
        for idx = maxIdx + 1, mGridNum do
            mEmojiItemDic[idx]:SetState(1)
        end
    else
        --新的
        mEmojiItemDic[1]:SetState(2)
        mCurAddIdx = 1
        for idx = 2, mGridNum do
            mEmojiItemDic[idx]:SetState(1)
        end

        --没有封面
        SetCoverIcon(nil, nil)
    end
end

local function ShowOper(itemIdx)
    if mEmojiItemDic[itemIdx] then
        mEmojiItemDic[itemIdx]:SetState(4)
    end

    local addNum = #mAddingList
    for idx = 1, addNum do
        if idx ~= itemIdx and mEmojiItemDic[idx] then
            mEmojiItemDic[idx]:SetState(5)
        end
    end
end

local function HideOper()
    local addNum = #mAddingList

    for idx = 1, addNum do
        if mEmojiItemDic[idx] then
            mEmojiItemDic[idx]:SetState(3)
        end
    end
end

--[[
    @desc: 设置mFinishFlag唯一入口
    --@flag: 该状态用于区分操作逻辑分支，入口唯一
]]
local function SetFinishFlag(flag)
    mFinishFlag = flag

    mFinishGo:SetActive(mFinishFlag)
    mFinishLabel.text = mFinishFlag and mFinishDes or mNoFinishDes

    if not flag then
        HideOper()
    end
    
    if mEmojiItemDic[mCurAddIdx] then
        mEmojiItemDic[mCurAddIdx]:SetUIEventEnable(not flag)
    end
end

local function OnReadyToUpload(relativePath, fullPath)
    if mEmojiItemDic[mCurAddIdx] then
        mEmojiItemDic[mCurAddIdx]:OnReadyToUpload(relativePath, fullPath)
    end
end

local function DoAddInfo2AddingList(info)
    table.insert(mAddingList, info)
    mCurAddIdx = mCurAddIdx + 1

    --add往后推一格
    if mCurAddIdx <= mGridNum then
        mEmojiItemDic[mCurAddIdx]:SetState(2)
    end
end

--[[
    @desc: 
    --@relativePath: 
    --@picId: md5即为picId，用来判断新添加的表情图是否已经存在于候选列表里
]]
local function TryAddOne(relativePath, picId)
    if not mEmojiItemDic[mCurAddIdx] then
        return
    end

    local info = EmojiInfo.new()
    info:SetLocalPath(relativePath)
    info:SetPicId(picId)
    --来自本地加载
    info:SetLocalOrCollect(1)

    mEmojiItemDic[mCurAddIdx]:SetState(3)
    mEmojiItemDic[mCurAddIdx]:DoShowIconByLocalPath(relativePath)

    DoAddInfo2AddingList(info)
end

--[[
    @desc: 从一个已收藏的表情添加，没有尝试过程，直接添加成功
    --@info: 
]]
local function TryAddOneByInfo(info)
    if not info then
        return
    end
    if CheckPicIsExist(info:GetPicId()) then
        return
    end

    --加载表情图
    if not mEmojiItemDic[mCurAddIdx] then
        return
    end
    mEmojiItemDic[mCurAddIdx]:SetState(3)
    mEmojiItemDic[mCurAddIdx]:DoShowIconByUrl(info:GetUrl())
    
    local newInfo = EmojiInfo.new()
    newInfo:InitByPicId(info:GetPicId(), info:GetUrl(), info:GetName(), info:GetPlayerId())
    --之前的表情图没有状态检测的概念，所以这里统一设置成1
    --外部的表情图接入状态后，这里直接读取
    newInfo:InitStatus(1)
    newInfo:SetFailed(false)
    --来自我的收藏
    newInfo:SetLocalOrCollect(2)

    DoAddInfo2AddingList(newInfo)
end

--[[
    @desc: 上传系列结果回调
    --@pkgId: 
]]
local function OnAddPkgFinish(state, pkgId)
    if state then
        local pkgInfo = PkgInfo.new()
        pkgInfo:InitByPkgId(pkgId, mLastNameInputValue, mLastDesInputValue, UserData.PlayerID)
        
        --同步数据
        pkgInfo:AddEmojiInfoList(mAddingList)
        CustomEmojiMgr.AddPkg2MyAddListByPkgInfo(pkgInfo)

        --清空数据，并重置UI，关闭UI
        CustomEmojiMgr.ClearAddingPkgInfoList()
        CustomEmojiMgr.ClearAddingPkgInfoName()
        mLastNameInputValue = ""
        mLastDesInputValue = ""
        mPkgNameLabel.text = ""
        mPkgDesLabel.text = ""

        UIMgr.UnShowUI(AllUI.UI_AddOnePkg)

        --成功提示
        TipsMgr.TipByFormat("上传系列成功")
    else
        --失败提示
        TipsMgr.TipByFormat("上传系列失败")
    end
end

--[[
    @desc: 发送上传消息
]]
local function DoSendMsg()
    GameLog.LogError("--------------------------------DoSendMsg")
    --组织table并序列化json串
    local dataSource = {}
    local data = nil
    for _, info in ipairs(mAddingList) do
        data = {}
        data.pic_id = info:GetPicId()
        data.path = info:GetUrl()
        data.name = ""
        data.status = info:GetStatus()
        table.insert(dataSource, data)
    end
    local jsonStr = JSON.encode(dataSource)
    --替代反斜杠
    jsonStr = jsonStr:gsub("\\", "")
    SNSCustomEmojiMgr.RequestAddPkg(mLastNameInputValue, mLastDesInputValue, jsonStr, OnAddPkgFinish, nil)
end

local function CheckNameIsReady()
    if mLastNameInputValue == "" then
        TipsMgr.TipByFormat("请输入名字")
        return false
    end
    if mLastDesInputValue == "" then
        TipsMgr.TipByFormat("请输入介绍")
        return false
    end
    return true
end

local function CheckNumIsReady()
    local meetNum = #mAddingList >= 1
    if not meetNum then
        TipsMgr.TipByFormat("自定义图片数量需在10至20之间，继续添加后重试")
    end
    return meetNum
end

local function CheckExistFailed()
    local isExist = false
    for _, info in ipairs(mAddingList) do
        if info:GetFailed() then
            isExist = true
            break
        end
    end
    
    if isExist then
        TipsMgr.TipByFormat("存在添加失败的表情，删除后重试")
    end
    return isExist
end

--[[
    @desc: 检查是否所有的表情都准备完毕
    查看url是否合法有效
]]
local function CheckIsAllReady()
    local isAllReady = true
    for idx, info in ipairs(mAddingList) do
        if info:GetUrl() == "" then
            --遇到没填充过的url，则直接返回未准备好
            isAllReady = false
            break
        end
    end
    return isAllReady
end

--[[
    @desc: 
    --@itemIdx: 即为mAddingList的索引
	--@picId:
	--@url: 
]]
local function AddOneSucess(itemIdx, picId, url)
    local info = mAddingList[itemIdx]
    if not info then
        return
    end
    --表情系列里的单表情都没有名字
    info:InitByPicId(picId, url, "", UserData.PlayerID)
    --默认状态为1，后续接入鉴黄sdk和人工审核，该字段会动态变化
    info:InitStatus(1)
    info:SetFailed(false)

    if CheckIsAllReady() then
        DoSendMsg()
    end
end

local function AddOneFailed(itemIdx)
    local info = mAddingList[itemIdx]
    if not info then
        return
    end
    info:SetFailed(true)
end

--[[
    @desc: 上传按钮，遍历item，执行上传
    其中可能有失败的，在表情图上做标记，供删除
    该方法可能会被执行多次，需要一个上传中状态
]]
local function DoUpload()
    --当前adding列表里是否已经全是准备好的
    if CheckIsAllReady() then
        DoSendMsg()
        return
    end

    for idx, info in ipairs(mAddingList) do
        if info:GetUrl() == "" then
            mEmojiItemDic[idx]:DoUpload()
        end
    end
end

--[[
    @desc: 计算落在哪个idx里，并且区分是哪个类型的点击事件
    --@eventId: 
]]
local function CalClickIdx(eventId)
    eventId = eventId - 1
    local quotient = math.floor(eventId / mUIEventIdSpan)
    local remainder = eventId - quotient * mUIEventIdSpan
    local itemIdx = quotient + 1
    local clickIdx = remainder + 1
    return itemIdx, clickIdx
end

--[[
    @desc: 选中itemIdx，其他有图片的item显示交换
    --@itemIdx: 
]]
local function LongPressOne(itemIdx)
    mCurLongPressIdx = itemIdx
    ShowOper(itemIdx)
    SetFinishFlag(true)
end

--[[
    @desc: 删除一个表情
    --@itemIdx: 
]]
local function DeleteOne(itemIdx)
    table.remove(mAddingList, itemIdx)

    SetFinishFlag(false)

    --重刷UI
    RestoreGrid()
end

--[[
    @desc: 
    --@itemIdx: 
]]
local function ChangeOne(itemIdx)
    SetFinishFlag(false)

    if mCurLongPressIdx == itemIdx then
        --交换和长按是同一个，不作为
    else
        --真正交换
        local itemInfo = mAddingList[itemIdx]
        local longPressInfo = mAddingList[mCurLongPressIdx]
        mAddingList[itemIdx] = longPressInfo
        mAddingList[mCurLongPressIdx] = itemInfo

        --重刷UI
        RestoreGrid()
    end
end

--[[
    @desc: UI_MyCollectHelp开关回调
    --@flag: 
]]
local function OnMyCollectHelpUIVisible(flag)
    if flag ~= nil then
        mOffsetGo:SetActive(not flag) 
    end    
end

local function GetRemainedNum()
    return mGridNum - #mAddingList
end

--[[
    @desc: 点击确定按钮后，传回来的一个选中状态字典
    --@checkedDic: 
    --@dataList: 
]]
local function OnMyCollectHelpUIOk(checkedDic, dataList)
    --遍历找到符合规则的（不重复），添加进来
    for key, flag in pairs(checkedDic) do
        if flag then
            --选中的才考虑
            TryAddOneByInfo(dataList[key])
        end
    end
end

local function SetMyCollectHelpUIData()
    CustomEmojiMgr.SetMyCollectHelpData(OnMyCollectHelpUIOk, GetRemainedNum())
end

local function RegEvent()
    mEvents = {}
    mEvents[1] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_READYTO_UPLOAD, OnReadyToUpload)
    mEvents[2] = MessageSub.Register(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_MYCOLLECTHELP, OnMyCollectHelpUIVisible)
end

local function UnRegEvent()
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_READYTO_UPLOAD, mEvents[1])
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_MYCOLLECTHELP, mEvents[2])
    mEvents = nil
end


local EmojiItem = class("EmojiItem")
function EmojiItem:ctor(trs, itemIdx)
    --组件
    self._transform = trs
    self._gameObject = trs.gameObject

    self._bgGo = trs:Find("bg").gameObject
    self._addGo = trs:Find("add").gameObject
    self._iconGo = trs:Find("icon").gameObject
    self._icon = self._iconGo:GetComponent("UITexture")

    self._selectedGo = trs:Find("selected").gameObject
    self._changeGo = trs:Find("change").gameObject

    self._collider = trs:GetComponent("BoxCollider")

    self._failedGo = trs:Find("failed").gameObject
    self._failedGo:SetActive(false)

    --变量
    self._itemIdx = itemIdx
    --状态，1只显示背景，2显示add，3显示图片，4选中，5交换
    self._state = 1
    self:SetState(1)
    self._picId = ""
    self._relativePath = ""
    self._url = ""
    self._squareLen = 100
    
    self._remoteDir = ChatMgr.GetCustomEmojiRemoteDir()
end

function EmojiItem:SetState(state)
    self._state = state

    if state == 1 or state == 2 then
        self:SetFailedGoVisible(false)
    end

    if state == 1 then
        self._bgGo:SetActive(true)
        self._addGo:SetActive(false)
        self._iconGo:SetActive(false)
        self._selectedGo:SetActive(false)
        self._changeGo:SetActive(false)
    elseif state == 2 then
        self._bgGo:SetActive(true)
        self._addGo:SetActive(true)
        self._iconGo:SetActive(false)
        self._selectedGo:SetActive(false)
        self._changeGo:SetActive(false)
    elseif state == 3 then
        self._bgGo:SetActive(false)
        self._addGo:SetActive(false)
        self._iconGo:SetActive(true)
        self._selectedGo:SetActive(false)
        self._changeGo:SetActive(false)
    elseif state == 4 then
        self._bgGo:SetActive(false)
        self._addGo:SetActive(false)
        self._iconGo:SetActive(true)
        self._selectedGo:SetActive(true)
        self._changeGo:SetActive(false)
    elseif state == 5 then
        self._bgGo:SetActive(false)
        self._addGo:SetActive(false)
        self._iconGo:SetActive(true)
        self._selectedGo:SetActive(false)
        self._changeGo:SetActive(true)
    end
end


function EmojiItem:SetFailedGoVisible(visible)
    self._failedGo:SetActive(visible)
end
--[[
    @desc: 上传过程中，某个失败后，显示失败标记
]]
function EmojiItem:OnAddFail()
    self:SetFailedGoVisible(true)

    AddOneFailed(self._itemIdx)
end

function EmojiItem:OnUpload(state, localPath, url)
    if state then
        --异步添加操作-1
        ReduceAddingNum()

        self:SetFailedGoVisible(false)

        AddOneSucess(self._itemIdx, self._picId, url)
    else
        --异步添加操作-1
        ReduceAddingNum()

        self:OnAddFail()
    end
end

function EmojiItem:DoUpload()
    --异步添加操作+1
    AddAddingNum()

    EmojiUploadMgr.Upload(self._relativePath, self._remoteDir, self.OnUpload, self)
end

function EmojiItem:OnLoadTex()
    UIUtil.AdjustInSquare(self._icon, self._squareLen)

    --第一个表情为封面
    if self._itemIdx == 1 then
        SetCoverIcon(self._relativePath, self._url)
    end
end

--[[
    @desc: 去重检测返回
    --@isExist: 
]]
function EmojiItem:OnCheckResult(isExist)
    if isExist then
        self:OnAddFail()
    end
end

--[[
    @desc: 从已收藏的表情单品集合里的url里加载
    --@url: 
]]
function EmojiItem:DoShowIconByUrl(url)
    self._url = url
    UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), url, true, self.OnLoadTex, self)
end

--[[
    @desc: --从本地加载
    --@localPath: 
]]
function EmojiItem:DoShowIconByLocalPath(localPath)
    self._relativePath = localPath
    UIUtil.LoadImage(self._icon, CustomEmojiMgr.GetEmojiSize(), localPath, false, self.OnLoadTex, self)
end

function EmojiItem:OnReadyToUpload(relativePath, fullPath)
    --获取md5（picId），检测去重
    self._picId = GameUtil.GameFunc.GetMD5(fullPath)
    TryAddOne(relativePath, self._picId)
    if self._picId ~= "" then
        --去重请求
        SNSCustomEmojiMgr.RequestCheckOneEmoji(self._picId, self.OnCheckResult, self)
    else
        --md5获取失败
        self:OnAddFail()
    end
end

--[[
    @desc: 根据上次未完成的上传表情信息，恢复
    --@info: 对应的表情已经上传
]]
function EmojiItem:RestoreByInfo(info)
    --重置数据
    --待实现，在去重检测消息回来之前，不允许做交换修改
    self._picId = info:GetPicId()
    self._relativePath = info:GetLocalPath()
    self._url = info:GetUrl()

    self:SetState(3)
    --判断是来自本地还是已收藏单品集合
    local localOrCollect = info:GetLocalOrCollect()
    if localOrCollect == 1 then
        self:DoShowIconByLocalPath(info:GetLocalPath())
    elseif localOrCollect == 2 then
        self:DoShowIconByUrl(info:GetUrl())
    end

    --查看是否有添加失败标记
    self:SetFailedGoVisible(info:GetFailed())
end

function EmojiItem:SetUIEventEnable(enabled)
    self._collider.enabled = enabled
end

function EmojiItem:OnClick(spanIdx)
    if spanIdx == 1 then
        --根据状态响应不同的行为
        if self._state == 2 then
            --弹出功能按钮列表
            SetMyCollectHelpUIData()
            local pos = self._transform.localPosition
            pos = self._transform.parent:TransformPoint(pos.x + 55, pos.y, 0)
            MessageSub.SendMessage(GameConfig.SUB_G_CHAT, GameConfig.SUB_U_CHAT_SHOWBTNLIST, pos, CustomEmojiMgr.ChatAddBtnType.AddPkg)
        elseif self._state == 4 or self._state == 5 then
            --只有处于4或5状态时，点击即为交换（包括和自己交换）
            ChangeOne(self._itemIdx)
        end
    elseif spanIdx == 2 then
        --删除，只有处于选中状态的才会有删除按钮
        DeleteOne(self._itemIdx)
    end
end

function EmojiItem:OnLongPress(spanIdx)
    --只有1有长按响应
    if spanIdx == 1 then
        --处于显示图片状态下，才有长按响应
        if self._state == 3 then
            LongPressOne(self._itemIdx)
        end
    end
end


function OnCreate(self)
    mAddingList = CustomEmojiMgr.GetAddingPkgInfoList()

    mSelf = self

    mOffsetGo = self:Find("Offset").gameObject

    mMainWidgetGo = self:Find("Offset/mainwidget").gameObject
    mNameWidgetGo = self:Find("Offset/namewidget").gameObject
    mDialogWidgetGo = self:Find("Offset/dialogwidget").gameObject
    mDialogWidgetGo:SetActive(false)

    mIconBgGo = self:Find("Offset/mainwidget/icon/bg").gameObject
    mIconTex = self:FindComponent("UITexture", "Offset/mainwidget/icon/tex")
    mIconTexGo = mIconTex.gameObject
    mIconTexGo:SetActive(false)

    mItemTemp = self:Find("Offset/mainwidget/middle/item")
    mGrid = self:FindComponent("UIGrid", "Offset/mainwidget/middle/list/widget/scrollview/grid")
    mGridTrs = mGrid.transform

    local trs = nil
    local uiEvent = nil
    for idx = 1, mGridNum do
        trs = self:DuplicateAndAdd(mItemTemp, mGridTrs, 0)
        trs.name = "item" .. tostring(idx)
        uiEvent = trs:GetComponent("GameCore.UIEvent")
        uiEvent.id = (idx - 1) * mUIEventIdSpan + 1
        uiEvent = trs:Find("selected/delete"):GetComponent("GameCore.UIEvent")
        uiEvent.id = (idx - 1) * mUIEventIdSpan + 2
        --以uieventid为key建立映射
        mEmojiItemDic[idx] = EmojiItem.new(trs, idx)
    end
    mGrid:Reposition()

    mItemTemp.gameObject:SetActive(false)

    --
    mFinishLabel = self:FindComponent("UILabel", "Offset/mainwidget/bottom/des")
    mFinishGo = self:Find("Offset/mainwidget/bottom/finish").gameObject
    SetFinishFlag(false)

    mPkgNameLabel = self:FindComponent("UILabel", "Offset/mainwidget/middle/name/name")
    mPkgDesLabel = self:FindComponent("UILabel", "Offset/mainwidget/middle/name/des")
    mNameInput = self:FindComponent("LuaUIInput", "Offset/namewidget/nameinput")
    mDesInput = self:FindComponent("LuaUIInput", "Offset/namewidget/desinput")
end

function OnEnable(self)
    RegEvent()

    --提示，继续编辑or重新开始
    local nameData = CustomEmojiMgr.GetAddingPkgInfoName()
    if #mAddingList > 0 or (nameData.name ~= "" and nameData.des ~= "") then
        --有编辑记录
        mMainWidgetGo:SetActive(false)
        mNameWidgetGo:SetActive(false)
        mDialogWidgetGo:SetActive(true)
    else
        SetWidgetVisible(true, 4)
        RestoreGrid()
    end
end

function OnDisable(self)
    UnRegEvent()

    CustomEmojiMgr.SetAddingPkgInfoName(mLastNameInputValue, mLastDesInputValue)

    --重置finishflag状态
    if mFinishFlag then
        SetFinishFlag(false)
    end

    --再次打开表情库
    CustomEmojiMgr.DoInvokeFunc(AllUI.UI_AddOnePkg)
end

function OnDestroy(self)

end

function OnClick(go, id)
    if id == -200 then
        --命名界面关闭
        SetWidgetVisible(true, 3)
    elseif id == -201 then
        --命名界面确定
        if mNameInput.value ~= "" and mDesInput.value ~= "" then
            SetWidgetVisible(true, 1)
        else
            TipsMgr.TipByFormat("输入不能为空")
        end
    elseif id == -202 then
        --命名界面取消
        SetWidgetVisible(true, 2)
    elseif id == -203 then
        --继续编辑
        mDialogWidgetGo:SetActive(false)
        local nameData = CustomEmojiMgr.GetAddingPkgInfoName()
        SetLabelText(nameData.name, nameData.des)
        SetWidgetVisible(true, 3)
        RestoreGrid()
    elseif id == -204 then
        --重新开始
        mDialogWidgetGo:SetActive(false)
        --清楚历史数据
        CustomEmojiMgr.ClearAddingPkgInfoList()
        CustomEmojiMgr.ClearAddingPkgInfoName()
        SetLabelText("", "")
        SetWidgetVisible(true, 3)
        RestoreGrid()
    elseif id == -100 then
        UIMgr.UnShowUI(AllUI.UI_AddOnePkg)
    elseif id == -11 then
        --命名
        SetWidgetVisible(false)
    elseif id == -12 then
        --完成按钮
        SetFinishFlag(false)
    elseif id == -13 then
        --上传，上传状态下，再次点击无效
        if CheckAddingNumIsZero() then
            if CheckNumIsReady() and CheckNameIsReady() and not CheckExistFailed() then
                DoUpload()
            end
        else
            TipsMgr.TipByFormat("上传中，请稍后")
        end
    elseif 1 <= id and id <= mGridNum * mUIEventIdSpan then
        --list区域
        local itemIdx, spanIdx = CalClickIdx(id)
        if mEmojiItemDic[itemIdx] then
            mEmojiItemDic[itemIdx]:OnClick(spanIdx)
        end
    end
end

function OnLongPress(id)
    local itemIdx, spanIdx = CalClickIdx(id)
    if mEmojiItemDic[itemIdx] then
        mEmojiItemDic[itemIdx]:OnLongPress(spanIdx)
    end
end