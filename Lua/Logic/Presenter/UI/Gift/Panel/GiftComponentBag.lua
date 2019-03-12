local GiftComponentBag = class("GiftComponentBag");

local UIGiftBagWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftBagWrapUIEx");
local UIGiftCategoryWrapUIEx = require("Logic/Presenter/UI/Gift/Component/UIGiftCategoryWrapUIEx");

function GiftComponentBag:OnItemChange(gift)
    self._bagTable:RefreshWrapUI(gift);
end

function GiftComponentBag:OnItemCategoryClick(cate,wrapUI)
    GameLog.Log("OnItemCategoryClick %s ",cate.id);
    self._selectedCategory = cate;
    local bagDatas = self._selectedCategory.giftList;
    self._bagTable:ResetWithData(bagDatas);
end

function GiftComponentBag:IsCategorySelected(cate)
    return self._selectedCategory == cate;
end

function GiftComponentBag:ctor(ui,giftInfoTable)
    local path = "Offset";
    self._panelGo = ui:Find(path).gameObject;
                --(ui,path,count,wrapUIClass,itemCountPerLine,context)
    self._categoryTable = BaseWrapContentEx.new(ui,path.."/BagWidget/BagTitle/Scroll View",7,UIGiftCategoryWrapUIEx,nil,self);
    self._categoryTable:SetUIEvent(2000,1,{self.OnItemCategoryClick},self);
    self._bagTable = BaseWrapContentEx.new(ui,path.."/BagWidget/BagContent/Scroll View",24,UIGiftBagWrapUIEx,nil,giftInfoTable.context);
    self._bagTable:SetUIEvent(2100,5,giftInfoTable.callbacks,giftInfoTable.caller);

    
    local categories = {};
    self._categories = categories;
    local categoryByID = {};

    local cateAll = {id = 0};
    categories[1] = cateAll;
    local gifts = giftInfoTable.gifts;
    cateAll.giftList = gifts;

    for index, gift in ipairs(gifts) do
        local cid = gift:GetCategoryID();
        if not categoryByID[cid] then
            local cate = {id = cid};
            categories[#categories+1] = cate;
            categoryByID[cid] = cate;
            cate.giftList = {};
        end
        table.insert(categoryByID[cid].giftList,gift);
    end
    
end

function GiftComponentBag:OnEnable(ui)
    self._categoryTable:ResetWithData(self._categories);
    
    self._selectedCategory = self._selectedCategory or self._categories[1];

    self:RefreshBag();
end

function GiftComponentBag:RefreshBag()
    local bagDatas = self._selectedCategory.giftList;
    self._bagTable:ResetWithData(bagDatas);
end

function GiftComponentBag:OnDisable()

    self._categoryTable:ReleaseData();
    self._bagTable:ReleaseData();
end

function GiftComponentBag:OnClick(id)
    GameLog.Log("OnClick %s", id);
    if not self._panelGo.activeInHierarchy then
        return;
    end

    if id >= 2100 then
        self._bagTable:OnClick(id);
    elseif id >= 2000 then
        self._categoryTable:OnClick(id);
    end
end

return GiftComponentBag;
