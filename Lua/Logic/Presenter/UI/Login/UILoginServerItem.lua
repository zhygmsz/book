local UILoginServerItem = class("UILoginServerItem");

function UILoginServerItem:ctor(nameLabel,stateSprite,newGo)
    self._nameLabel = nameLabel;
    self._stateSprite = stateSprite;
    self._newGo = newGo;
end

function UILoginServerItem:Refresh(server)
    if not server then return; end
    if self._nameLabel then
        self._nameLabel.text = server:GetName();
    end

    if  self._stateSprite then       
        if not server:IsOpen() then
             self._stateSprite.spriteName = "icon_denglu_01";
        elseif server:IsFull() then
             self._stateSprite.spriteName = "icon_denglu_02";
        elseif server:IsBusy() then
             self._stateSprite.spriteName = "icon_denglu_03";
        else
             self._stateSprite.spriteName = "icon_denglu_04";
        end
    end

    if self._newGo then
        self._newGo:SetActive(server:IsNew());
    end
end

return UILoginServerItem;