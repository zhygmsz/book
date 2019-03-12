--交互模式 - checkbox

local InteractForCheck = class("InteractForCheck")

function InteractForCheck:ctor(funcOnClick, obj)
    --变量
    self._funcOnClick = funcOnClick
    self._obj = obj

    --各个data的选中状态，字典形式，便于存取
    self._checkedDic = {}
    --最大可选择数量，不限量填-1
    self._maxCheckedNum = -1
    --当前已选择数量
    self._curCheckedNum = 0
end

function InteractForCheck:OnClick(dataIdx)
    if not dataIdx then
        return
    end

    if self._checkedDic[dataIdx] then
        --取消选中
        self:ReduceCurCheckedNum()
        self._checkedDic[dataIdx] = false
        self:InvokeOnClick(true, dataIdx, self._checkedDic[dataIdx])
    else
        --选中一个新的
        if self._maxCheckedNum > 0 and self:GetRemainedNum() <= 0 then
            --限量，但数量不足
            self:InvokeOnClick(false)
        else
            --不限量或，还有的选择
            self:AddCurCheckedNum()
            self._checkedDic[dataIdx] = true
            self:InvokeOnClick(true, dataIdx, self._checkedDic[dataIdx])
        end
    end
end

--[[
    @desc: 
    --@success: 选中成功，失败发生在选中数量不足时
	--@dataIdx: 数据索引
	--@checked: 选中状态
]]
function InteractForCheck:InvokeOnClick(success, dataIdx, checked)
    if self._funcOnClick then
        if self._obj then
            self._funcOnClick(self._obj, success, dataIdx, checked, self:GetRemainedNum(), self:GetCheckedNum())
        else
            self._funcOnClick(success, dataIdx, checked, self:GetRemainedNum(), self:GetCheckedNum())
        end
    end
end

--[[
    @desc: 
    --@maxNum: 最大可选择数量，不限量填-1
]]
function InteractForCheck:ResetMaxCheckedNum(maxNum)
    self._maxCheckedNum = maxNum
end

function InteractForCheck:ClearCurCheckedNum()
    self._curCheckedNum = 0
end

function InteractForCheck:ResetCheckedDic()
    for key, _ in pairs(self._checkedDic) do
        self._checkedDic[key] = false
    end
end

function InteractForCheck:GetChecked(dataIdx)
    if dataIdx then
        return self._checkedDic[dataIdx]
    else
        return false
    end
end

function InteractForCheck:AddCurCheckedNum()
    self._curCheckedNum = self._curCheckedNum + 1
end

function InteractForCheck:ReduceCurCheckedNum()
    self._curCheckedNum = self._curCheckedNum - 1
end

function InteractForCheck:GetRemainedNum()
    return self._maxCheckedNum - self._curCheckedNum
end

function InteractForCheck:GetCheckedNum()
    local num = 0
    for _, flag in pairs(self._checkedDic) do
        if flag then
            num = num + 1
        end
    end
    return num
end

--[[
    @desc: 返回是否选中状态
]]
function InteractForCheck:GetCheckedDic()
    return self._checkedDic
end

function InteractForCheck:OnDestroy()
    self._checkedDic = nil
end

return InteractForCheck