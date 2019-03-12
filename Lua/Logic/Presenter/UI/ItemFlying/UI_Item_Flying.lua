module("UI_Item_Flying", package.seeall)

local mCom = {}
local mSelf
local mItems = {}
local mDeltaTime = GameTime.deltaTime_L / 1000
local mStarPos --贝塞尔曲线起点
local mEndPos --贝塞尔曲线终点
local mMiddlePos --贝塞尔曲线控制点
local pos = Vector3.zero --飞图标过程中路径点
local mIsHaveItem = false
local mSpeed = 1.2 --飞行速度
local mBagTrs

local mCommonBagPos --背包位置
local mTemporaryBagPos --临时背包位置

local liminaValue = ConfigData.GetIntValue("Drop_performance_quantity_limit") --阈值

local function OnFinishOne(obj)
    GameEvent.Trigger(EVT.FLYITEM, EVT.FLYITEM_ONFINISHONE, mItems[1].bagType)
    UnityEngine.GameObject.Destroy(obj)
    table.remove(mItems, 1)
    mIsHaveItem = next(mItems) ~= nil

    if not mIsHaveItem then
        UIMgr.UnShowUI(AllUI.UI_Item_Flying)
    end

    if #mItems > liminaValue then
        local index = #mItems - liminaValue + 1
        for i = 1, index do
            table.remove(mItems, i)
        end
    end
end

--UI_Main 坐标 转换到 UI_Item_Flying
local function GetPosition(pos)
    local pos1 = mBagTrs.transform:TransformPoint(pos)
    local cam = UIMgr.GetCamera()
    local pos2 = cam.transform:InverseTransformPoint(pos1)
    return  pos2
end

function OnCreate(self)
    mSelf = self
    mCom.itemPerfab = self:Find("Offset/ItemPerfab")
    mCom.itemParent = self:Find("Offset/Itemlist") 
    mCom.commonBagBtn = AllUI.UI_Main.csScript:GetRootGo().Find("BottomRight/FunctionBtnsBR/BtnBackpack")
    mCom.temporaryBagBtn = AllUI.UI_Main.csScript:GetRootGo().Find("BottomRight/FunctionBtnsBR/BtnTemBackpack")
    mBagTrs = AllUI.UI_Main.csScript:GetRootGo().Find("BottomRight/FunctionBtnsBR")
end

function OnUpdate()

    if not mIsHaveItem then
        return 
    end

    if not mItems[1] then
        return 
    end

    if not mItems[1].obj.gameObject.activeSelf then
        mItems[1].obj.gameObject:SetActive(true)
    end

    mDeltaTime = mDeltaTime + GameTime.deltaTime_L / 1000 * mSpeed

    if mItems[1].bagType == Bag_pb.NORMAL then
        mEndPos = mCommonBagPos
    else
        mEndPos = mTemporaryBagPos
    end

    pos = math.BezierQuadratic(mStarPos, mMiddlePos, mEndPos, mDeltaTime)
    
    mItems[1].obj.localPosition = pos

    if mDeltaTime >= 1 then
        mDeltaTime = 0
        OnFinishOne(mItems[1].obj.gameObject)
    end
end

function OnEnable(self)
    UpdateBeat:Add(OnUpdate, self)

    mSpeed = ConfigData.GetFloatValue("FlyItem_Speed")

    mStarPos = Vector3.New(ConfigData.GetIntValue("Drop_beginning_abscissa"), ConfigData.GetIntValue("Drop_beginning_ordinate"), 0)
    mCommonBagPos = Vector3.New(ConfigData.GetIntValue("Drop_backpack_abscissa"), ConfigData.GetIntValue("Drop_backpack_ordinate"), 0)
    mTemporaryBagPos = Vector3.New(ConfigData.GetIntValue("Drop_temporary_backpack_abscissa"), ConfigData.GetIntValue("Drop_temporary_backpack_ordinate"), 0)
    mMiddlePos = Vector3.New(ConfigData.GetIntValue("Drop_control_point_abscissa"), ConfigData.GetIntValue("Drop_control_point_ordinate"), 0)

    GameEvent.Reg(EVT.FLYITEM, EVT.FLYITEM_ADDITEM, AddItems)

    mCommonBagPos = GetPosition(mCom.commonBagBtn.transform.localPosition)
    mTemporaryBagPos = GetPosition(mCom.temporaryBagBtn.transform.localPosition)
end

function OnDisable(self)
    UpdateBeat:Remove(OnUpdate, self)

    GameEvent.UnReg(EVT.FLYITEM, EVT.FLYITEM_ADDITEM, AddItems)
end

function OnDestroy()
    
end

function AddItems(itemlist)
    for i, itemInfo in ipairs(itemlist) do
        local itemTrs = mSelf:DuplicateAndAdd(mCom.itemPerfab, mCom.itemParent, i)
        itemTrs.gameObject:SetActive(false)
        itemTrs.localPosition = Vector3.zero
        itemTrs.localScale = Vector3.one

        local icon = itemTrs:Find("Icon"):GetComponent("UISprite")
        local itemData = ItemData.GetItemInfo(itemInfo.itemId)
        icon.spriteName = itemData.icon_big

        local vo = {}
        vo.bagType = itemInfo.bagType
        vo.obj = itemTrs

        table.insert(mItems, vo)

        mIsHaveItem = true
    end 
end