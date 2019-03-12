module("UI_Intensify_Inlay", package.seeall)

local LeftWidget = require("Logic/Presenter/UI/Intensify/Inlay/Inlay_LeftWidget")
local MiddleWidget = require("Logic/Presenter/UI/Intensify/Inlay/Inlay_MiddleWidget")
local RightWidget = require("Logic/Presenter/UI/Intensify/Inlay/Inlay_RightWidget")

--组件
local mSelf
local mLeftTrs
local mMiddleTrs
local mRightTrs
local mTitle

--
local mLeftWidget
local mMiddleWidget
local mRightWidget

--变量
local mEventIDs = {}

local mTitleStr

--uieventid分配
local mLefEventIdBase = 20
local mMiddleEventIdBase = 40
local mRightEventIdBase = 60

local mCanInlayEquipData
local mOneTwoDataList

--local方法
local function DispatchEventId(eventId)
    if mLefEventIdBase <= eventId and eventId < mMiddleEventIdBase then
        mLeftWidget:OnClick(eventId)
    elseif mMiddleEventIdBase <= eventId and eventId < mRightEventIdBase then
        mMiddleWidget:OnClick(eventId)
    else

    end
end

local function ShowMiddle(data)
    if not data then
        return
    end
    mMiddleWidget:Show(data)
end

local function ShowRight(data)
    if not data then
        return
    end
    mOneTwoDataList = GemInlayMgr.GetOneTwoDataList(data.itemSlot.item.tempId)
    if mOneTwoDataList then
        mRightWidget:Show(mOneTwoDataList, data)
    end
end

--[[
    @desc: 左侧列表的item点击回调，传回item内维护的数据，用于显示middle区域
    --@data: 详见GemInlayMgr.GetCanInlayEquipList方法内
]]
local function OnLeftItemClick(data)
    if data then
        mCanInlayEquipData = data
        ShowMiddle(data)
        ShowRight(data)
    end
end

--[[
    @desc: 
    --@oneDataIdx: 
]]
local function OnExpandOneItem(oneDataIdx)
    if not mCanInlayEquipData then
        return
    end
    --新组装数据
    GemInlayMgr.ExpandOneItem(mOneTwoDataList, oneDataIdx, mCanInlayEquipData.equipData.gemLevel)
    --重刷当前选中的oneitem
    mRightWidget:ReExpandCurOneItem()
end

--[[
    @desc: 镶嵌宝石UI操作回调
]]
local function OnInlayGem(rightData)
    if rightData.isAdd then
        --打开便捷合成界面
    else
        local leftData = mLeftWidget:GetCurSelectData()
        local gemPos = mMiddleWidget:GetCurGemPos()
        if not leftData or not gemPos then
            return
        end
        GemInlayMgr.CSInlayGem(leftData.bagType, leftData.itemSlot.slotId, gemPos, Bag_pb.NORMAL, rightData.slotId)
    end
end

--[[
    @desc: 卸下宝石UI操作回调
]]
local function OnRemoveGem(data)
    if not data then
        return
    end
    local leftData = mLeftWidget:GetCurSelectData()
    local gemPos = data.gemPos
    if not leftData or not gemPos then
        return
    end
    GemInlayMgr.CSRemoveGem(leftData.bagType, leftData.itemSlot.slotId, gemPos)
end

--[[
    @desc: 镶嵌宝石服务器回调
]]
local function OnSCInlayGem(msg)
    if msg then
        --mCanInlayEquipData.itemSlot有变动（背包内部），需要重新获取
        mCanInlayEquipData.itemSlot = BagMgr.GetBagSlotItemWitnIndex(msg.slotId, msg.bagType)
        mLeftWidget:OnSCInlayGem(mCanInlayEquipData, msg)
        mMiddleWidget:OnSCInlayGem(mCanInlayEquipData, msg)
    end
end

--[[
    @desc: 卸下宝石的服务器回调
]]
local function OnSCRemoveGem(msg)
    if msg then
        --mCanInlayEquipData.itemSlot有变动（背包内部），需要重新获取
        mCanInlayEquipData.itemSlot = BagMgr.GetBagSlotItemWitnIndex(msg.slotId, msg.bagType)
        mLeftWidget:OnSCRemoveGem(mCanInlayEquipData, msg)
        mMiddleWidget:OnSCRemoveGem(mCanInlayEquipData, msg)
    end
end

--[[
    @desc: 增加宝石格子事件处理
    --@itemSlot: 
]]
local function OnAddGemItemSlot(itemSlot)
    if mCanInlayEquipData then
        OnExpandOneItem(mRightWidget:GetCurOneDataIdx())
    end
end

--[[
    @desc: 删除宝石格子事件处理
    --@itemSlot: 
]]
local function OnRemoveGemItemSlot(itemSlot)
    if mCanInlayEquipData then
        OnExpandOneItem(mRightWidget:GetCurOneDataIdx())
    end
end

--[[
    @desc: 更新宝石格子事件处理
    --@itemSlot: 
]]
local function OnUpdateGemItemSlot(itemSlot)
    if mCanInlayEquipData then
        OnExpandOneItem(mRightWidget:GetCurOneDataIdx())
    end
end

local function RegEvent(self)
    mEventIDs[1] = MessageSub.Register(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_INLAY, OnSCInlayGem)
    mEventIDs[2] = MessageSub.Register(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_REMOVE, OnSCRemoveGem)
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_ADDGEM, OnAddGemItemSlot)
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_REMOVEGEM, OnRemoveGemItemSlot)
    GameEvent.Reg(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_UPDATEGEM, OnUpdateGemItemSlot)
end

local function UnRegEvent(self)
    MessageSub.UnRegister(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_INLAY, mEventIDs[1])
    MessageSub.UnRegister(GameConfig.SUB_G_GEM, GameConfig.SUB_U_GEM_REMOVE, mEventIDs[2])
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_ADDGEM, OnAddGemItemSlot)
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_REMOVEGEM,OnRemoveGemItemSlot)
    GameEvent.UnReg(EVT.PACKAGE, EVT.PACKAGE_PACKAGE_UPDATEGEM,OnUpdateGemItemSlot)
    mEventIDs = {}
end

function OnCreate(self)
    mSelf = self

    mTitle = self:FindComponent("UILabel", "Offset/title")

    mLeftTrs = self:Find("Offset/left")
    mLeftWidget = LeftWidget.new(mLeftTrs, mLefEventIdBase, OnLeftItemClick)

    mMiddleTrs = self:Find("Offset/middle")
    mMiddleWidget = MiddleWidget.new(mMiddleTrs, mMiddleEventIdBase, OnRemoveGem)

    mRightTrs = self:Find("Offset/right")
    mRightWidget = RightWidget.new(mRightTrs, mSelf, OnInlayGem, OnExpandOneItem)

    mTitleStr = WordData.GetWordStringByKey("Shop_class1_1") .. WordData.GetWordStringByKey("gem_inlay")
    mTitle.text = mTitleStr
end

function OnEnable(self)
    RegEvent(self)

    mLeftWidget:OnEnable()
    mMiddleWidget:OnEnable()
    mRightWidget:OnEnable()

    --每次打开默认选中第一个数据对应的UI格子
    if mLeftWidget:CheckIsNone() then
        mLeftWidget:SetNoneDesVisible(true)
        --清空中间和右侧区域
        mMiddleWidget:Hide()
        mRightWidget:Hide()
    else
        mLeftWidget:SetNoneDesVisible(false)
        mLeftWidget:AutoSelectRealIdx(1)
    end
end

function OnDisable(self)
    UnRegEvent(self)

    mLeftWidget:OnDisable()
    mMiddleWidget:OnDisable()
    mRightWidget:OnDisable()
end

function OnDestroy(self)
    mLeftWidget:OnDestroy()
end

function OnClick(go, id)
    if id == -1 then
        --宝石升级
        UIMgr.UnShowUI(AllUI.UI_Intensify_Main)
        UIMgr.ShowUI(AllUI.UI_Intensify_GemLevelup)
    else
        DispatchEventId(id)
    end
end
