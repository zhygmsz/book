ChatCommonRepaint = class("ChatCommonRepaint");

function ChatCommonRepaint:ctor(uiInfo)
    self._paintRoot = uiInfo:Find("Offset/MailPaint").gameObject;
    self._paintContext = uiInfo:FindComponent("UIPaint","Offset/MailPaint/PaintBg/Paint");
    self._paintContext:ClearStateForRepaint();
    self._paintContext:SetPointSize(15,5);
    self._paintRoot:SetActive(false);
    self._paintData = {};
end

function ChatCommonRepaint:OnEnable(linkData)
    if not self._paintData.linkData or self._paintData.linkData ~= linkData then
        self._paintData.linkData = linkData; 
        self._paintData.pointData = linkData.byteParams[1];
        self._paintContext:ClearStateForRepaint();
        self._paintContext:ParseFromString(self._paintData);
    end
    self._paintRoot:SetActive(true);
    self._paintContext:PlayPoints();
end

function ChatCommonRepaint:OnDisable()
    self._paintRoot:SetActive(false);
end