--图片数字
UISpriteNumber = class("UISpriteNumber");

local function SetSprite(self,trans,index)
    local spr = trans:GetComponent("UISprite");
    spr.spriteName = self._baseName..self._nums[index];
end

function UISpriteNumber:ctor(ui,grid,baseName)
    self._ui = ui;
    self._grid = grid;
    self._baseName = baseName;
    self._prefab = grid.transform:GetChild(0);
end

function UISpriteNumber:SetNumber(num)
    self._nums = {};
    while num>0 do
        local temp = math.floor(num*0.1);
        table.insert(self._nums,1,num-temp*10);
        num = temp;
    end
    UIGridTableUtil.CreateChild(self._ui,self._prefab,#self._nums,nil,SetSprite,self);
    self._grid:Reposition();
end

return UISpriteNumber;