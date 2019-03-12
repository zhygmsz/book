module("UI_Charge_Instruction",package.seeall);

local mUI;

local mToggleGroup;
local mCreditGrid;
local mAliGrid;
local mWeChatGrid;
local function OnCreditCreate(trans,index)
    local titleText = WordData.GetWordStringByKey("charge_instruction_creditcard_title_"..index);--信用卡标题
    trans:Find("label"):GetComponent("UILabel").text = titleText;
    local sprite = WordData.GetWordStringByKey("charge_instruction_creditcard_image_"..index);--信用卡图片名
    trans:Find("SetupInterface"):GetComponent("UISprite").spriteName = sprite;
end

local function OnAlipayCreate(trans,index)
    local titleText = WordData.GetWordStringByKey("charge_instruction_alipay_title_"..index);--支付宝标题
    trans:Find("label"):GetComponent("UILabel").text = titleText;
    local sprite = WordData.GetWordStringByKey("charge_instruction_alipay_image_"..index);--支付宝图片名
    trans:Find("SetupInterface"):GetComponent("UISprite").spriteName = sprite;
end

local function OnWeChatPayCreate(trans,index)
    local titleText = WordData.GetWordStringByKey("charge_instruction_WeChat_title_"..index);--微信标题
    trans:Find("label"):GetComponent("UILabel").text = titleText;
    local sprite = WordData.GetWordStringByKey("charge_instruction_WeChat_image_"..index);--微信图片名
    trans:Find("SetupInterface"):GetComponent("UISprite").spriteName = sprite;
end

function OnCreate(ui)

    mToggleGroup = ToggleGroupGo.new();
    local alipayTrans = ui:Find("Offset/ChoiceTabList/AlipayTab");
    local aliPanelGo = ui:Find("Offset/AlipayDrag").gameObject;
    mToggleGroup:AddItem({trs = alipayTrans,eventId = 1, ui = aliPanelGo});
    mAliGrid = UIScrollGridTable.new(ui,"Offset/AlipayDrag/Scroll View");
    local aliCount = ConfigData.GetIntValue("charge_instruction_alipay_count") or 0;--支付宝说明数量
    mAliGrid:ResetWrapContent(aliCount,OnAlipayCreate);
    
    local wechatPayTrans =ui:Find("Offset/ChoiceTabList/WeChatTab");
    local wechatPayPanelGo = ui:Find("Offset/WeChatDrag").gameObject;
    mToggleGroup:AddItem({trs=wechatPayTrans,eventId=2,ui=wechatPayPanelGo});
    mWeChatGrid = UIScrollGridTable.new(ui,"Offset/WeChatDrag/Scroll View");
    local wechatCount = ConfigData.GetIntValue("charge_instruction_wechat_count") or 0;--微信说明数量
    mWeChatGrid:ResetWrapContent(wechatCount,OnWeChatPayCreate);
    
    local creditCardTrans = ui:Find("Offset/ChoiceTabList/CreditCardTab");
    local creditPanelGo = ui:Find("Offset/CreditCardDrag").gameObject;
    mToggleGroup:AddItem({trs = creditCardTrans,eventId = 3, ui = creditPanelGo});
    mCreditGrid = UIScrollGridTable.new(ui,"Offset/CreditCardDrag/Scroll View");
    local creditCount = ConfigData.GetIntValue("charge_instruction_creditcard_count") or 0;--信用卡说明数量
    mCreditGrid:ResetWrapContent(creditCount,OnCreditCreate);



end

function OnEnable(ui)
    mToggleGroup:Init(1);
    mCreditGrid:ResetInitPosition();
    mAliGrid:ResetInitPosition();
    mWeChatGrid:ResetInitPosition();
end

function OnDisable(ui)
end

function OnClick(go,id)
    if id == 0 then
        UIMgr.UnShowUI(AllUI.UI_Charge_Instruction);
    elseif id == 1 or id == 2 or id==3 then
        mToggleGroup:OnClick(id);
    end
end