module("UI_PersonalSpace_Voice", package.seeall);

local _self = nil
--输入信息
local mInputInfo = {}
local _self = nil

function OnCreate(self)
    _self=self
end


local mEvents = {};
function RegEvent(self)
end

function UnRegEvent(self)
	mEvents = {};
end

function OnEnable(self)
	RegEvent(self);
	UpdateView()
end

function OnDisable(self)
	mCurSelectIndex = - 1;
	UnRegEvent(self);
end

function onDestroy(self)
	--ClearLoaders()
end

--刷险背包界面显示
function UpdateView()
  
end

function RecordFinished(speechText,speechLength,speechPath)
    GameLog.Log(speechPath)
end

function OnPress(press,id)
    if id == 403 then
        --TODO 语音使用方式修改,请使用新的录音方式
    end
end

function OnClick(go, id)
    if id == 400 then
        --弹出录制界面
    elseif id == 404 then --删除
        
    elseif id == 405 then --播放

    elseif id == 406 then --保存
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Voice)
    elseif id == 407 then --关闭
        UIMgr.UnShowUI(AllUI.UI_PersonalSpace_Voice)
    end
end

return UI_PersonalSpace_Voice