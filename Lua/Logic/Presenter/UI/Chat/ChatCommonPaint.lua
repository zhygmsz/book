ChatCommonPaint = class("ChatCommonPaint");

function ChatCommonPaint:ctor(uiInfo)
    self._paintRoot = uiInfo:Find("Offset/PaintRoot").gameObject;
    self._paintContext = uiInfo:FindComponent("UIPaint","Offset/PaintRoot/PaintBg/Paint");
    self._colorRoot = uiInfo:Find("Offset/PaintRoot/ColorRoot").transform;
    for i = 1,self._colorRoot.childCount do
        local index = i;
        local toggle = uiInfo:FindComponent("UIToggle","Offset/PaintRoot/ColorRoot/color"..tostring(index));
        EventDelegate.Add(toggle.onChange,EventDelegate.Callback(function() if toggle.value then self._paintContext:SelectColor(index); end end)); 
    end
    local toggle = uiInfo:FindComponent("UIToggle","Offset/PaintRoot/FuncRoot/Erase");
    EventDelegate.Add(toggle.onChange,EventDelegate.Callback(function() self._paintContext:EnableErase(toggle.value); end)); 
    self._paintContext:ClearStateForDraw();
    self._paintContext:SetPointSize(15,5);
    self._paintRoot:SetActive(false);
end

function ChatCommonPaint:OnEnable(onPaintFinish)
    self._onDrawFinish = onPaintFinish;
    self._paintRoot:SetActive(true);
end

function ChatCommonPaint:OnDisable()
    self._paintRoot:SetActive(false);
end

function ChatCommonPaint:OnClick(id)
    if id == 1 then
        --发送
        local data = self._paintContext:SerializeToString();
        if data == "" then
            TipsMgr.TipByKey("chat_paint_is_null");
        else   
            if self._onDrawFinish then
                self._onDrawFinish(data);
            end
        end
    elseif id == 3 then
        --清屏
        self._paintContext:ClearStateForRepaint();
    elseif id == 4 then
        --撤销
        self._paintContext:BackSpace();
    elseif id == 5 then
        --播放
        self._paintContext:PlayPoints();
    end
end