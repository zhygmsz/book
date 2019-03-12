UICommonCollapseWrapData = class("UICommonCollapseWrapData",nil);

-- 类型，内容，UI尺寸
function UICommonCollapseWrapData:ctor(type,content,size)
    self._content = content;
    self._type = type;
    self._size = size;
end

function UICommonCollapseWrapData:GetType()
    return self._type;
end

function UICommonCollapseWrapData:GetData()
    return self._content;
end

function UICommonCollapseWrapData:GetSize()
    return self._size;
end

function UICommonCollapseWrapData:ReSetData(content)
    self._content = content;
end

