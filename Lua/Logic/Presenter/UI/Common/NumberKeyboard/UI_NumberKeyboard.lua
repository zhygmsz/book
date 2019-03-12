
module("UI_NumberKeyboard",package.seeall)

local result = 0
local mOnSubmit = nil
local mOnChange = nil
local mMax = 0
local mDefaultText=""
local mLabel = nil
local mOffset = nil
local mPos = Vector3(0,0,0)
local first = true

function OnCreate(self)
    mOffset=self:Find("Offset");
end

function OnEnable(self)
    mOffset.localPosition = mPos
end

function OnDisable(self)
    result = 0
    mLabel=nil
    mOnSubmit = nil
    mOnChange = nil
    mMax = 0
end

function ShowKeyboard(label,currentvalue,max,onsubmit,onChange,pos)
    mLabel=label
    result = currentvalue
    mOnSubmit = onsubmit
    mOnChange = onChange
    mMax = max
    mPos = pos
    first = true
    UIMgr.ShowUI(AllUI.UI_NumberKeyboard);
end

function Value()
    return result
end

function SetDefaultText(v)
    mDefaultText = v
end

function OnClick(go,id)
    local close = false
    local input = false
    if id == 11 or id == -100  then--确定
        if mOnSubmit then
            mOnSubmit(result,false)
        end
        close =true
    elseif id == 10 then--最大值
        result = mMax
    elseif id == 12 then--回退
        result = math.floor(result/10)
    elseif id >= 0 and id <=9 then--输入
        if first then
            result=0
            first = false
        end
        result = result*10+id
        result = math.min(mMax,result)
        input = true
    end
    if close then
        UIMgr.UnShowUI(AllUI.UI_NumberKeyboard);
    else
        if result == 0 then
            if mMax >0 then
            result=0
            end
        end
        mLabel.text = string.NumberFormat(result,0)
        if mOnChange then
            mOnChange(result,input)
        end
    end
end

return UI_NumberKeyboard
