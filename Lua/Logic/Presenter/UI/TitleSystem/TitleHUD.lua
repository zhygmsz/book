local TitleHUD = class("TitleHUD",nil);

function TitleHUD:ctor(rootTrans)
    self._rootGo = rootTrans.gameObject;
    local labelTrans = rootTrans:Find("LabelTitle");
    self._titleLabel = labelTrans:GetComponent("UILabel");
    self._titleLabelGo = labelTrans.gameObject;
    local textureTrans = rootTrans:Find("SpriteTitle");
    self._titleSprite = textureTrans:GetComponent("UISprite");
    self._titleSpriteGo = textureTrans.gameObject;
end

function TitleHUD:Show(entity)
    if not entity then
        self._rootGo:SetActive(false);
        return;
    end
    local title  = entity:GetPropertyComponent():GetTitle();
    local hasTitle = title and title.titleid and title.titleid ~=0;
    if not hasTitle then
        self._rootGo:SetActive(false);
        return;
    end
    self._rootGo:SetActive(true);
    local tid = title.titleid;
    local item = TitleMgr.GetItemByID(tid);
    
    if not item:IsArt() then
        self._titleLabelGo:SetActive(true);
        self._titleSpriteGo:SetActive(false);
        self._titleLabel.text = string.format("[%s]<%s>[-]",item:GetColor(),title.titlestr);
        -- if TitleMgr.IsItemUserDefine(tid) then
            
        --     self._titleLabel.text = string.format("[%s]<%s>[-]",TitleMgr.GetItemColor,title.titlestr);
        -- else
        --     self._titleLabel.text = string.format("[%s]<%s>[-]",TitleMgr.GetItemColor,title.titlestr);
        -- end
    else
        self._titleLabelGo:SetActive(false);
        self._titleSpriteGo:SetActive(true);
        local iconName = item:GetIconName();
        self._titleSprite.spriteName = iconName;
    end
end

function TitleHUD:Destroy()
    self._rootGo = nil;
    self._titleLabel = nil;
    self._titleLabelGo = nil;
    self._titleSprite = nil;
    self._titleSpriteGo = nil;
end

return TitleHUD;