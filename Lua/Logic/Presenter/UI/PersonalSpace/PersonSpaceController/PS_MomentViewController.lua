local PS_SpaceItemViewController = require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/PS_SpaceItemViewController")
local PS_SignatureViewController = require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/PS_SignatureViewController")
local UITableListViewController= require("Logic/Presenter/UI/PersonalSpace/PersonSpaceController/UITableListViewController")
local PS_MomentViewController = class("PS_MomentViewController",nil)

function PS_MomentViewController:ctor(uitable,mPlayerId,mShowMode)
    --存放实例化信息条目的table
    self._mItemTable ={}
    --信息数据数组 
    self._mItemDatas = {}
    --玩家信息对象 SocialPlayerInfo 类型
    self._mPlayerInfo ={}
    self._mShowMode =mShowMode
    self._mPlayerId = mPlayerId
    self:InitViewObject(uitable)
    self._mSignature = PS_SignatureViewController.new(uitable._ui,self._mShowMode,self._mPlayerId)
    self._mSignature:Init()
end

--==============================--
--desc:
--time:2018-10-26 09:40:15
--@uitable:uitable =keys: {_ui,_itemPrefab,_tableWrap,_scrollPanel,_scrollView,_maxCellcont}
--@return 
--==============================--
--初始化获取UI控制对象
function PS_MomentViewController:InitViewObject(uitable)
    self._uitable=uitable
    local function OnCellUpdate(item,data)
        self:CellUpdate(item,data)
    end
    self._listView = UITableListViewController.new(uitable._ui,uitable._itemPrefab,uitable._tableWrap,uitable._scrollPanel,
    uitable._scrollView,uitable._maxCellcont,OnCellUpdate,UITableWrapContent.Align.Top,UITableWrapContent.Align.Top)
    self._listView:InitItems()
end

--设置数据
function PS_MomentViewController:SetItemDatas(datas)
    self._mItemDatas=datas
end

function PS_MomentViewController:CellUpdate(item,data)
    if item.zoneItem == nil then
        item.zoneItem = PS_SpaceItemViewController.new(self._uitable._ui,item.transform,item.index,self._mShowMode)
    end
    item.zoneItem:SetModel(self._mShowMode)
    item.zoneItem:SetupView(data,item.dataIndex)
end

function PS_MomentViewController:SetPlayerId(pid)
    self._mPlayerId = pid
    if self._mSignature then
        self._mSignature:SetPlayerId(self._mPlayerId)
    end
end

--mShowMode = 2正常模式  1只显示一个人的
function PS_MomentViewController:SetShowMode(mode)
    self._mShowMode = mode
    if self._mSignature then
        self._mSignature:SetShowMode(mode)
    end
end

function PS_MomentViewController:GetDataCount()
    return table.getn(self._mItemDatas)
end

function PS_MomentViewController:UpdateData(mPlayerId)
    self._mPlayerId = mPlayerId
    self._mItemDatas=PersonSpaceMgr.GetMomentDataById(self._mPlayerId)
    self._listView:SetDatas(self._mItemDatas)
    if self._mSignature then
        self._mSignature:SetPlayerId(self._mPlayerId)
        self._mSignature:UpdateData()
    end
end

--更新列表
function PS_MomentViewController:UpdateItems()
    self._listView:UpdateItems()
end

function PS_MomentViewController:UpdateView()
    self._mSignature:UpdateView()
    self._listView:UpdateItems()

end

function PS_MomentViewController:ReLayout(mmtid,dataIndex)
    local item = self._listView:GetItemAtDataIndex(dataIndex)
    item.zoneItem:ReSetupView()
    self._listView:ReLayout()
end

function PS_MomentViewController:ClickItem(go,id)
    self._mSignature:OnClick(go, id)
    if id >10000 then
        local index = math.floor(id/10000)
        local item = self._listView:GetItemAtIndex(index)
        if item then
            item.zoneItem:OnClick(go,id)
        end
    end
end

return PS_MomentViewController