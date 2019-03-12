local UI_PersonalSpace_ImageView = require("Logic/Presenter/UI/PersonalSpace/UI_PersonalSpace_ImageView")

local PS_InfoViewController = class("PS_InfoViewController",nil)

function PS_InfoViewController:ctor(uitable)
    --存放实例化信息条目的table
    self._mItemTable ={}
    --信息数据数组  item结构={name="",content=""}
    self._mItemDatas = {}
    --玩家信息对象 SocialPlayerInfo 类型
    self._mPlayerInfo ={}
    self:InitViewObject(uitable)
end

--==============================--
--desc:
--time:2018-10-26 09:40:15
--@uitable:uitable =keys: {_ui,_bgWidget,_headTexture,_itemPrefab,_professionSprite,_professionLabel,_sexSprite,_sexLabel}
--@return 
--==============================--
--初始化获取UI控制对象
function PS_InfoViewController:InitViewObject(uitable)
    self._uitable=uitable
end

--添加信息显示条目
function PS_InfoViewController:AddInfoItem(parent,obj,index)
    local item = {};
	item.index = index;
	item.gameObject = self._uitable._ui:DuplicateAndAdd(obj, parent, index).gameObject;
	item.gameObject.name =string.format("InfoItem_%d",index)
    item.transform = item.gameObject.transform;
    item.itemLabel = item.transform:GetComponent("UILabel");
	item.contentLabel = item.transform:Find("Content"):GetComponent("UILabel");
	item.gameObject:SetActive(false);
	return item;
end

--更新个人信息 除去职业 性别
function PS_InfoViewController:UpdateInfoItems()
    local mCount = table.getn(self._mItemTable)
    local datanum =  table.getn(self._mItemDatas)
    local max = math.max(mCount,datanum)
    local h = 474
    for i=1,max do
        if self._mItemTable[i]==nil then
            self._mItemTable[i] = self:AddInfoItem(self._uitable._bgWidget.transform, self._uitable._itemPrefab.transform,i)
        end
        local item =self._mItemTable[i]
        if i<=datanum then
            item.itemLabel.text = self._mItemDatas[i].name
            item.contentLabel.text =self._mItemDatas[i].content
            item.gameObject:SetActive(true)
        else
            item.gameObject:SetActive(false)
        end
        item.transform.localPosition = Vector3(-150,-254-i*40,0)
        local th=(254+i*40+30)
        h = h < th and th or h 
    end
     self._uitable._bgWidget.height = h
end

function PS_InfoViewController:UpdateData(playerInfo)
   -- local names ={"ID：","昵称：","生日：","星座：","城市：","配偶：","称号：","帮派："}
    self._mPlayerInfo = playerInfo
    if self._mPlayerInfo then
        for i=1,9 do
            if self._mItemDatas[i]==nil then self._mItemDatas[i]={} end
            self._mItemDatas[i].name = string.format("%s:",TipsMgr.GetTipByKey(string.format("personspace_info_infoname%d",i)))
            self._mItemDatas[i].content = self._mPlayerInfo:GetInfoByIndex(i)
        end
    end
end

function PS_InfoViewController:UpdateView()
    if self._mPlayerInfo==nil then
        return
    end
    self._mPlayerInfo:SetHeadIcon(self._uitable._headTexture,self._uitable._defaultHead)
    local gentername = {"personspace_info_female", "personspace_info_male", "personspace_info_secret"}
    local racial = UserData.GetRacial()
    local profession = UserData.GetProfession()
    self._uitable._professionSprite.spriteName = ProfessionData.GetProfessionResByRacialProfession(racial,profession).professionIcon
    self._uitable._professionLabel.text =string.format("%s-%s",self._mPlayerInfo:GetMenpaiID(),self._mPlayerInfo:GetLevel())
    self._uitable._sexSprite.spriteName = self._mPlayerInfo:GetRoleGender() ==2 and "icon_pengyouquan_nan" or "icon_pengyouquan_nv"
   
    self._uitable._sexLabel.text =TipsMgr.GetTipByKey(gentername[self._mPlayerInfo:GetRoleGender()])
    self:UpdateInfoItems()
end

--查看头像图片
function PS_InfoViewController:LookUpHeadIcon()
    local url = mPlayerInfo:GetDefaultHeadIconURL()
    UI_PersonalSpace_ImageView.ShowImages({url},1,false)
end

--显示个人头像编辑页面
function PS_InfoViewController:ShowHeadIconView()
    UIMgr.ShowUI(AllUI.UI_PersonalSpace_HeadIcon)
end

return PS_InfoViewController