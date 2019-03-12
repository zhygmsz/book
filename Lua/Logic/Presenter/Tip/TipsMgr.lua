module("TipsMgr",package.seeall);

local TempWorldTable ={
   
}

local function DoTipById(id, ...)
    local data = {}
    data.id = id
    data.args = {...}
    GameEvent.Trigger(EVT.UITIPS, EVT.UITIPS_SHOWTIPS, data)
end

local function DoTipConfirm(content, style, okFunc, cancelFunc, okStr, cancelStr, newLayer, newDepth)
    local confirmData = {}
    confirmData.content = content
    confirmData.style = style
    confirmData.okFunc = okFunc
    confirmData.cancelFunc = cancelFunc
    confirmData.okStr = okStr
    confirmData.cancelStr = cancelStr
    confirmData.newLayer = newLayer
    confirmData.newDepth = newDepth
    TipConfirm(confirmData)
end

local function DoTipConfirmPlayer(playerid,content, style, okFunc, cancelFunc, okStr, cancelStr, newLayer, newDepth)
    local confirmData = {}
    confirmData.pid = playerid;
    confirmData.content = content
    confirmData.style = style
    confirmData.okFunc = okFunc
    confirmData.cancelFunc = cancelFunc
    confirmData.okStr = okStr
    confirmData.cancelStr = cancelStr
    confirmData.newLayer = newLayer
    confirmData.newDepth = newDepth
    TipConfirmPlayer(confirmData)
end

--通过字符表key弹出提示信息,具体显示方式由配置表字段决定
function TipByKey(key,...)
    local tipData = WordData.GetWordDataByKey(key);
        
    if not tipData then
        tipData = WordData.GetWordDataDefault();
        tipData.value = key;
        GameLog.LogError("Tipsmgr.TipByKey -> tipData is nil, key = %s", key)
    end
    DoTipById(tipData.id, ...)
end

function TipByID(id, ...)
    DoTipById(id, ...)
end

--展示属性变化
function TipProChange(changes)
    if changes then
        GameEvent.Trigger(EVT.UITIPS, EVT.UITIPS_SHOWPROCHANGE, changes)
    end
end

--公告（顶部滚屏）
function TipTop(content)
    if content then
        GameEvent.Trigger(EVT.UITIPS, EVT.UITIPS_SHOWTOPTIPBYSTR, content)
    end
end

--通用提示
function TipCommon(content, data)
    if content then
        GameEvent.Trigger(EVT.UITIPS, EVT.UITIPS_SHOWCOMMON, content, data)
    end
end

--显示确认框
--[[
data =
{
    content = content,
    style = style,
    okFunc = okFunc,
    cancelFunc = cancelFunc,
    okStr = okStr,
    cancelStr = cancelStr,
    newLayer = newLayer,
    newDepth = newDepth,
    --closeFunc = closeFunc,
    --showClose = showClose,
}
--]]
function TipConfirm(data)
    if data then
        GameEvent.Trigger(EVT.UITIPS, EVT.UITIPS_SHOWCONFIRM, data)
    end
end

function TipConfirmPlayer(data)
    if data then
        GameEvent.Trigger(EVT.UITIPS, EVT.UITIPS_SHOWCONFIRM_PLAYER,data);
    end
end
--标题和内容说明提示框
function TipDerscribe(data)
    if data then
        UI_Tips_Describe.ShowDescribe(data)
    end
end

--以字符表key，显示确认框, 并显示玩家信息
function TipConfirmPlayerByKey(key, playerid, okFunc, cancelFunc, ...)
    local tipData = WordData.GetWordDataByKey(key);
    local content = key;
    local tipyType = WordData_pb.TipTypeData.STYLE_ALL;
    if not tipData then
        GameLog.LogError("Tipsmgr.TipConfirmByKey -> tipData is nil, key = %s", key);
        
    else
        local ret, str = xpcall(string.format, traceback, tipData.value, ...);
        if not ret then
            GameLog.LogError("TipsMgr.TipConfirmByKey -> ret is false, err = %s", content)
            return
        else
            content = str;
        end
        local tipTypeData = WordData.GetTipTypeData(tipData.tipTypeID);
        
        if not tipTypeData then
            GameLog.LogError("Tipsmgr.TipConfirmByKey -> tipTypeData is nil, key = %s", key)
        else
            tipyType = tipTypeData.style;
        end
    end


    DoTipConfirmPlayer(playerid, content, tipyType, okFunc, cancelFunc);
end

--以字符表key，显示确认框
function TipConfirmByKey(key, okFunc, cancelFunc, ...)
    local tipData = WordData.GetWordDataByKey(key);
    local content = key;
    local tipyType = WordData_pb.TipTypeData.STYLE_ALL;
    if not tipData then
        GameLog.LogError("Tipsmgr.TipConfirmByKey -> tipData is nil, key = %s", key);
        
    else
        local ret, str = xpcall(string.format, traceback, tipData.value, ...);
        if not ret then
            GameLog.LogError("TipsMgr.TipConfirmByKey -> ret is false, err = %s", content)
            return
        else
            content = str;
        end
        local tipTypeData = WordData.GetTipTypeData(tipData.tipTypeID);
        
        if not tipTypeData then
            GameLog.LogError("Tipsmgr.TipConfirmByKey -> tipTypeData is nil, key = %s", key)
        else
            tipyType = tipTypeData.style;
        end
    end


    DoTipConfirm(content, tipyType, okFunc, cancelFunc);
end

--以下四个方法ok,cancel按钮都显示
function TipConfirmByStr(str, okFunc, cancelFunc)
    DoTipConfirm(str, WordData_pb.TipTypeData.STYLE_ALL, okFunc, cancelFunc)
end

function TipConfirmByCustomStr(str, okFunc, cancelFunc, okStr, cancelStr)
    DoTipConfirm(str, WordData_pb.TipTypeData.STYLE_ALL, okFunc, cancelFunc, okStr, cancelStr)
end

function TipConfirmByStrWithOrder(str, okFunc, cancelFunc, newLayer, newDepth)
    DoTipConfirm(str, WordData_pb.TipTypeData.STYLE_ALL, okFunc, cancelFunc, nil, nil, newLayer, newDepth)
end

function TipConfirmByCustomStrWithOrder(str, okFunc, cancelFunc, okStr, cancelStr, newLayer, newDepth)
    DoTipConfirm(str, WordData_pb.TipTypeData.STYLE_ALL, okFunc, cancelFunc, okStr, cancelStr, newLayer, newDepth)
end

--以下四个方法只显示ok按钮
function TipConfirmOkByStr(str, okFunc)
    DoTipConfirm(str, WordData_pb.TipTypeData.STYLE_OK, okFunc)
end

function TipConfirmOkByCustomStr(str, okFunc, okStr)
    DoTipConfirm(str, WordData_pb.TipTypeData.STYLE_OK, okFunc, nil, okStr)
end

function TipConfirmOkByStrWithOrder(str, okFunc, newLayer, newDepth)
    DoTipConfirm(str, WordData_pb.TipTypeData.STYLE_OK, okFunc, nil, nil, nil, newLayer, newDepth)
end

function TipConfirmOkByCustomStrWithOrder(str, okFunc, okStr, newLayer, newDepth)
    DoTipConfirm(str, WordData_pb.TipTypeData.STYLE_OK, okFunc, nil, okStr, nil, newLayer, newDepth)
end

--强制关闭当前显示的确认框
function TipConfirmOnClose()
    GameEvent.Trigger(EVT.UITIPS, EVT.UITIPS_CLOSECONFIRM)
end

function TipConfirmPlayerOnClose()
    GameEvent.Trigger(EVT.UITIPS, EVT.UITIPS_CLOSECONFIRM_PLAYER);
end

--通过字符表key获取中文
function GetTipByKey(key, ...)
    local tipData = WordData.GetWordDataByKey(key);
    if tipData then
        return string.format(tipData.value,...);
    else
        if TempWorldTable[key] then
            return  TempWorldTable[key]
        end
        return "";
    end
end

--调试专用,弹出一条提示信息,供开发人员查看
function TipByFormat(format,...)
    local content = string.format(format,...)
    TipCommon(content);
    GameLog.LogError(content);
end

--通过ID弹出错误信息，由服务器控制具体文本，不带参数，目前由服务器维护，后续交给策划
--客户端只根据服务器传来的ID获取文本内容并显示 根据重要程度决定是否弹出确认框 默认在控制台打印错误
function TipErrorByID(id,isImportant,...)
    local errorData = WordData.GetErrorDataByID(id)
    local errorValue = string.format("can't find msg error data by id %s",id);
    if errorData then
        errorValue = string.format(errorData.value,...);
    else
        return
    end
    if isImportant then
        TipConfirmByStr(errorValue);
    else
        TipCommon(errorValue);
    end
    GameLog.LogError("Error ID: "..tostring(id).." "..errorValue);
end

function InitModule()
    local function OpenCommonTipsUI()
        if not AllUI.UI_Story_Main.enable then UIMgr.ShowUI(AllUI.UI_Story_Main) end
        if not AllUI.UI_Tips.enable then UIMgr.ShowUI(AllUI.UI_Tips) end
        if not AllUI.UI_Tips_Confirm.enable then UIMgr.ShowUI(AllUI.UI_Tips_Confirm) end
        if not AllUI.UI_Tips_ConfirmPlayer.enable then UIMgr.ShowUI(AllUI.UI_Tips_ConfirmPlayer) end
    end
    local function OnMapEnterFinish()
        GameEvent.Trigger(EVT.UITIPS,EVT.UITIPS_SETBOTTOMANCHOR);
    end
    local function OnMapEnterLoad()
        OpenCommonTipsUI();
    end
    GameEvent.Reg(EVT.MAPEVENT,EVT.MAP_ENTER_LOAD,OnMapEnterLoad);
    GameEvent.Reg(EVT.MAPEVENT,EVT.MAP_ENTER_FINISH,OnMapEnterFinish);

    require("Logic/Presenter/UI/Tip/UI_Tips_Describe");
    OpenCommonTipsUI();
end

return TipsMgr