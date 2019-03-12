--基于NGUI中的UIToggle的封装

UIToggleGroup = class("UIToggleGroup");

local function SetObjectActive(objs,state)
    if type(objs) == "table" then
        for i,object in ipairs(objs) do
            object:SetActive(state);
        end
    else
        objs:SetActive(state);
    end
end

function UIToggleGroup:ctor()
    self._toggles = {};
end

function UIToggleGroup:OnToggleStateChange(toggle)
    if toggle.value then
        for tog,objs in pairs(self._toggles) do
            if toggle == tog then
                SetObjectActive(objs,true);
            else
                --if tog.value then--减少触发回调
                    --tog:Set(false);
                --end
                SetObjectActive(objs,false);
            end
        end
    end
end

local function GetEventCallback(self, toggle)
    return EventDelegate.Callback(function(self)
        self:OnToggleStateChange(toggle);
    end,self);
end

--UIToggle, gameObject  --Support Multi Add Operation
function UIToggleGroup:AddToggleObject(toggle,object)
    if not self._toggles[toggle] then
        self._toggles[toggle] = object;
        local callback = GetEventCallback(self,toggle);
        EventDelegate.Add(toggle.onChange, callback);
    elseif type(self._toggles[toggle]) == "userdata" then--只有一个响应对象
        local first = self._toggles[toggle];
        self._toggles[toggle] = {first,object};
    else--有多个响应对象
        table.insert(self._toggles[toggle],object);
    end
end

return UIToggleGroup;