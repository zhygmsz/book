module("UI_Tip_UnLockBag",package.seeall)
local mSilverIcon;
local mSilverNum;
local Des
local Title

msg =""
num= 0
title=""
okFunc = nil
cancelFunc = nil

function OnCreate(self)
    mSilverNum = self:FindComponent("UILabel","Offset/Bg/SilverNum");
    mSilverIcon = self:FindComponent("UISprite","Offset/Bg/SilverIcon");
    Des = self:FindComponent("UILabel","Offset/Bg/Des");
    Title = self:FindComponent("UILabel","Offset/Bg/Title");
end

function OnEnable(self)
    Des.text = msg
    mSilverNum.text = string.NumberFormat(num,0)
    Title.text = title
end

function OnDisable(self)
end

function SetData(ititle,imsg,inum,iokFunc,icancelFunc)
    msg=imsg
    num= tonumber(inum)
    title=ititle
    okFunc = iokFunc
    cancelFunc = icancelFunc
end

function ShowTip(ititle,imsg,inum,iokFunc,icancelFunc)
    SetData(ititle,imsg,inum,iokFunc,icancelFunc)
    UIMgr.ShowUI(AllUI.UI_Tip_UnLockBag);
end

function OnClick(go,id)
    if id == 10 then--确定
        if okFunc then
            okFunc(num)
        end
        UIMgr.UnShowUI(AllUI.UI_Tip_UnLockBag);
    elseif id == 11 then--取消
        if cancelFunc then cancelFunc() end
        UIMgr.UnShowUI(AllUI.UI_Tip_UnLockBag);
    elseif id == 0 then--关闭
        UIMgr.UnShowUI(AllUI.UI_Tip_UnLockBag);
    end
end
--endregion
