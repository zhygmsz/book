module("TextHelper",package.seeall);

local mImageLabelCache = {};
local mImageLabelArg = {};
local mImageLoader = nil;
local mImageIconSize = {compressRatio = 100, width = 88, height = 88 };

local function FindImageLabel(self)
	local cache = mImageLabelCache[self];
	if not cache then 
		local imageLabelObj = UnityEngine.GameObject.New("ImageLabel");
		imageLabelObj.transform.parent = self:GetRoot(); 
		imageLabelObj.transform.localScale = Vector3.one;

		cache = {};
		cache.imageLabel = imageLabelObj:AddComponent(typeof(GameCore.UIImageLabel));
		cache.helpLabel = self:FindComponent("UILabel","Offset/Prefab/HelpLabel");
		cache.helpSprite = self:FindComponent("UISprite","Offset/Prefab/HelpSprite");
		cache.helpTexture = self:FindComponent("UITexture","Offset/Prefab/HelpTexture");
		cache.helpAtlasSprites = {};
		local helpAtlasRoot = self:Find("Offset/Prefab/HelpAtlas");
		if helpAtlasRoot then
			helpAtlasRoot = helpAtlasRoot.transform;
			for i = 1,helpAtlasRoot.childCount do
				local child = helpAtlasRoot:GetChild(i - 1);
				local sprite = child.gameObject:GetComponent("UISprite");
				table.insert(cache.helpAtlasSprites,sprite);
			end
		else
			table.insert(cache.helpAtlasSprites,cache.helpSprite);
		end
		cache.helpLabel.transform.parent.gameObject:SetActive(false);
		mImageLabelCache[self] = cache;
	end
	return cache;
end

local function FindLink(linkIndex,linkData)
	if linkData.linkType == Chat_pb.ChatMsgLink.AT then
			
	elseif linkData.linkType == Chat_pb.ChatMsgLink.PLAYER then
		return linkData.isValid, linkData.contentWithId, linkData.linkDesc.textDesc.color, 2
	elseif linkData.linkType == Chat_pb.ChatMsgLink.PAINT then
		return true,"[913]","",1;
	elseif linkData.linkType == Chat_pb.ChatMsgLink.EMOJI then
		return linkData.isValid, linkData.contentWithId, "", 1
	elseif linkData.linkType == Chat_pb.ChatMsgLink.ITEM 
		or linkData.linkType == Chat_pb.ChatMsgLink.ITEMID
		or linkData.linkType == Chat_pb.ChatMsgLink.PLAYER then
		--物品，物品id，玩家信息
		return linkData.isValid, linkData.contentWithId, linkData.linkDesc.textDesc.color, 2
	elseif linkData.linkType == Chat_pb.ChatMsgLink.EMOJI_CUSTOM then
		local linkContent = linkIndex >= 10 and string.format("[texture:%s]",linkIndex) or string.format("[texture:0%s]",linkIndex);
		return true,linkContent,"",3;
	elseif linkData.linkType == Chat_pb.ChatMsgLink.HYPER_TEXT then
		--超链接文本
		return linkData.isValid, linkData.contentWithId, linkData.linkDesc.textDesc.color, 2
	end
end

local function FindTexture(self,itemIcon,index)
	UIUtil.LoadImage(itemIcon,self.size,self.links[index].strParams[1],true);
end

local function Process(self)
	local cache = FindImageLabel(self);
	local arg = mImageLabelArg;
	cache.imageLabel:PrepareCommon(arg.sc,arg.ss,arg.cc,arg.ct,arg.ec,arg.es,arg.cw,arg.ch,arg.cs,arg.ca,arg.cr);
	cache.imageLabel:PrepareFontTexture(cache.helpLabel,cache.helpSprite,cache.helpTexture,self);
	for i = 1,#cache.helpAtlasSprites do
		cache.imageLabel:PrepareAtlas(cache.helpAtlasSprites[i].atlas,false);
	end
	for i = 1,#arg.links do	
		local validLink,linkContent,linkColor,linkType = FindLink(i,arg.links[i]);
		--自定义表情的尺寸，以后做
		if validLink then cache.imageLabel:PrepareLinks(i,linkContent,linkColor,linkType,80,80); end
	end
	cache.imageLabel:ProcessText();
	if not arg.it.imageLabelContent then arg.it.imageLabelContent = arg.cr.gameObject:GetComponent("GameCore.UIImageLabelContent"); end
	if not mImageLoader then mImageLoader = GameCore.UIImageLabelContent.TextureLoader(FindTexture,arg); end
	arg.it.imageLabelContent:LoadTexture(mImageLoader);
	arg.it.curWidth = arg.it.imageLabelContent.mLineWidth;
	arg.it.curHeight = math.abs(arg.it.imageLabelContent.mLineOffsetY);
end

--[[
初始化图文混排文本
self 				UIFrame 				UI对应的C#脚本,OnCreate(self)的self
item 				table 					一个table,当前contentRoot的拥有者
content 			string 					图文混排字符串
contentRoot 		Transform 				图文混排根结点,图文的锚点
contentWidth 		int 					最大行宽度
contentSpace 		int 					行间距
contentAlignLeft	bool 					是否左对齐
contentLinks 		Chat_pb.ChatMsgLink		字符串携带的链接信息,repeated类型
startColor			string					前缀颜色
startString			string					前缀字符串
endColor			string 					后缀颜色
endString			string					后缀字符串
contentColor		string					内容颜色
--]]
function ProcessItemCommon(self,item,content,contentRoot,contentWidth,contentSpace,contentAlignLeft,contentLinks,startColor,startString,endColor,endString,contentColor)
	mImageLabelArg.it = item;
	mImageLabelArg.sc = startColor or "[000000]";
	mImageLabelArg.ss = startString or "";
	mImageLabelArg.cc = contentColor or "";
	mImageLabelArg.ct = content;
	mImageLabelArg.ec = endColor or "[000000]";
	mImageLabelArg.es = endString or "";
	mImageLabelArg.cw = contentWidth;
	mImageLabelArg.ch = 10000;
	mImageLabelArg.cs = contentSpace;
	mImageLabelArg.ca = contentAlignLeft;
	mImageLabelArg.cr = contentRoot;
	mImageLabelArg.links = contentLinks or {};
	mImageLabelArg.size = mImageIconSize;
	Process(self);
end