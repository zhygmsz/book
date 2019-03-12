--如果文本超出，则用...表示更多
local UIBriefLabel = class("UIBriefLabel");


function UIBriefLabel:ctor(uiLabel,maxLength)
    self._label = uiLabel;
    self._maxLength = maxLength;
end
function UIBriefLabel:SetLabel(text)
    if not text then
        text = "";
    elseif string.len(text) > self._maxLength then
        local brefText = string.sub(text,1,maxLength-3).."...";
        text = brefText;
    end
    self._label.text = text;
end

return UIBriefLabel;