local UIGiftLetterPaint = class("UIGiftLetterPaint");

function UIGiftLetterPaint:ctor(uiInfo)

    self._paintRoot = uiInfo.paintRootGo;
    self._paintContext = uiInfo.uiPaint;

    self._eraseToggle = uiInfo.eraseToggle;
    self._defaultColorToggle = uiInfo.defaultColorToggle;
    self._defaultSizeToggle = uiInfo.defaultSizeToggle;
    for i = 1,#uiInfo.colorToggles do
        local index = i;
        local toggle = uiInfo.colorToggles[i];
        if toggle.value then self._paintContext:SelectColor(index); end
        EventDelegate.Add(toggle.onChange,EventDelegate.Callback(function() if toggle.value then self._paintContext:SelectColor(index); end end)); 
    end

    for toggle,size in pairs(uiInfo.toggleSizeTable) do
        if toggle.value then self._paintContext:SetPointSize(size,size); end
        EventDelegate.Add(toggle.onChange,EventDelegate.Callback(function() if toggle.value then self._paintContext:SetPointSize(size,size); end end)); 
    end

    EventDelegate.Add(uiInfo.eraseToggle.onChange,EventDelegate.Callback(function() self._paintContext:EnableErase(uiInfo.eraseToggle.value); end)); 

    
    self._paintRoot:SetActive(false);
end

function UIGiftLetterPaint:OnEnable()
    self._paintContext:ClearStateForDraw();
    self._paintRoot:SetActive(true);
    self._eraseToggle.value = false;
    self._defaultColorToggle.value = true;
    self._defaultSizeToggle.value = true;
end

function UIGiftLetterPaint:OnDisable()
    self._paintRoot:SetActive(false);
end

--获得序列化数据
function UIGiftLetterPaint:GetSerializedData()
    return self._paintContext:SerializeToString();
end

--清屏
function UIGiftLetterPaint:ClearScreen()
    return self._paintContext:ClearStateForRepaint();
end

--撤销
function UIGiftLetterPaint:Undo()
    return self._paintContext:BackSpace();
end

--恢复
function UIGiftLetterPaint:Recover()
    --todo
end
return UIGiftLetterPaint;