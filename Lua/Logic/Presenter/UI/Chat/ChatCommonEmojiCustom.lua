ChatCommonEmojiCustom = class("ChatCommonEmojiCustom");

function ChatCommonEmojiCustom:ctor(uiInfo)
    --事件偏移
    self._eventOffset1 = 1000;
    self._eventOffset2 = 1500;
    self._eventOffset3 = 2000;
    self._eventOffset4 = 2500;
    --表情
    self._wrap1 = uiInfo:FindComponent("UIWrapContent","Offset/EmojiCustomRoot/EmojiCustomRoot/ScrollView/Wrap1");
    self._wrap2 = uiInfo:FindComponent("UIWrapContent","Offset/EmojiCustomRoot/EmojiCustomRoot/ScrollView/Wrap2");
    self._wrapCall1 = UIWrapContent.OnInitializeItem(function(go,wrapIndex,realIndex) self:OnInitEmoji(go,1,wrapIndex,realIndex); end);
    self._wrapCall2 = UIWrapContent.OnInitializeItem(function(go,wrapIndex,realIndex) self:OnInitEmoji(go,2,wrapIndex,realIndex); end);
    self._wrap1Items = {};
    self._wrap2Items = {};
    self._wrap1Prefab = uiInfo:Find("Offset/EmojiCustomRoot/EmojiCustomRoot/ScrollView/ItemPrefab").transform;
    for i = 1,9 do
        local item1 = {};
        item1.gameObject = uiInfo:DuplicateAndAdd(self._wrap1Prefab,self._wrap1.transform,i);
        item1.transform = item1.gameObject.transform;
        item1.add = item1.transform:Find("Add").gameObject;
        item1.icon = item1.transform:Find("Icon").gameObject:GetComponent("UITexture");
        item1.event = item1.gameObject:GetComponent("GameCore.UIEvent");
        item1.event.id = self._eventOffset1 + i;
        table.insert(self._wrap1Items,item1);

        local item2 = {};
        item2.gameObject = uiInfo:DuplicateAndAdd(self._wrap1Prefab,self._wrap2.transform,i);
        item2.transform = item2.gameObject.transform;
        item2.add = item2.transform:Find("Add").gameObject;
        item2.icon = item2.transform:Find("Icon").gameObject:GetComponent("UITexture");
        item2.event = item2.gameObject:GetComponent("GameCore.UIEvent");
        item2.event.id = self._eventOffset2 + i;
        item2.add:SetActive(false);
        table.insert(self._wrap2Items,item2);
    end
    self._wrap1Prefab.gameObject:SetActive(false);
    self._wrapPanel = uiInfo:FindComponent("UIScrollView","Offset/EmojiCustomRoot/EmojiCustomRoot/ScrollView");
    self._wrapPanel.resetOffset = Vector3.New(31,0,0);
    self._wrapCount = 7;

    --表情包
    self._wrap3 = uiInfo:FindComponent("UIWrapContent","Offset/EmojiCustomRoot/EmojiPackageRoot/ScrollView/Wrap");
    self._wrapCall3 = UIWrapContent.OnInitializeItem(function(go,wrapIndex,realIndex) self:OnInitPackage(go,wrapIndex,realIndex); end);
    self._wrap3Prefab = uiInfo:Find("Offset/EmojiCustomRoot/EmojiPackageRoot/ScrollView/ItemPrefab");
    self._wrap3Items = {};
    for i = 1,20 do
        local item3 = {};
        item3.gameObject = uiInfo:DuplicateAndAdd(self._wrap3Prefab,self._wrap3.transform,i);
        item3.transform = item3.gameObject.transform;
        item3.add = item3.transform:Find("Add").gameObject;
        item3.select = item3.transform:Find("Select").gameObject;
        item3.favorite = item3.transform:Find("Favorite").gameObject;
        item3.icon = item3.transform:Find("Icon").gameObject:GetComponent("UITexture");
        item3.event = item3.gameObject:GetComponent("GameCore.UIEvent");
        item3.event.id = self._eventOffset3 + i;
        table.insert(self._wrap3Items,item3);
    end
    self._wrap3Prefab.gameObject:SetActive(false);

    --添加自定义表情
    self._addEmojiObj = uiInfo:Find("Offset/EmojiCustomRoot/EmojiAdd").gameObject;
    self._addEmojiBgObj = uiInfo:Find("Offset/EmojiCustomRoot/EmojiAdd/Bg").gameObject;
    self._addEmojiPhotoObj = uiInfo:Find("Offset/EmojiCustomRoot/EmojiAdd/Photo").gameObject;
    self._addEmojiCameraObj = uiInfo:Find("Offset/EmojiCustomRoot/EmojiAdd/Camera").gameObject;
    self._addEmojiPackageObj = uiInfo:Find("Offset/EmojiCustomRoot/EmojiAdd/Package").gameObject;
    self._addEmojiObj:SetActive(false);

    --自定义表情限定大小
    self._emojiTakeSize = {compressRatio = 70, width = 256, height = 256 };
    self._emojiPackageSize = {compressRatio = 100, width = 48, height = 48 };
    self._emojiSingleSize = { compressRatio = 100, width = 88, height = 88 };

    --图片加载管理器
    self._imageLoader = GameBase.ImageLoader.GetInstance();

    --上传进度条
    self._addState = {};
    self._addState.gameObject = uiInfo:Find("Offset/EmojiCustomRoot/EmojiAddState").gameObject;
    self._addState.transform = self._addState.gameObject;
    self._addState.slider = self._addState.gameObject:GetComponent("UISlider");
    self._addState.state = false;
    self._addState.gameObject:SetActive(false);
end

function ChatCommonEmojiCustom:LoadCustomImage(icon,url,size,isURL)
    if isURL then
        UIUtil.LoadImage(icon,size,url,isURL);
    else
        local fullPath = string.format("%s/%s",UnityEngine.Application.persistentDataPath,url);
        icon.mainTexture = self._imageLoader:LoadImage(fullPath);
    end
end

function ChatCommonEmojiCustom:OnInitPackage(go,wrapIndex,realIndex)
    local item = self._wrap3Items[wrapIndex + 1];
    if realIndex >= 0 and realIndex < #self._packageDatas then
        item.realIndex = realIndex + 1;
        item.add:SetActive(item.realIndex == 1);
        item.favorite:SetActive(item.realIndex == 2);
        item.select:SetActive(self._packageIndex == item.realIndex);
        if item.realIndex > 2 then
            local realData = self._packageDatas[item.realIndex];
            self:LoadCustomImage(item.icon,realData.emojis[1],self._emojiPackageSize,true);
        else
            item.icon.mainTexture = nil;
        end
    end
end

function ChatCommonEmojiCustom:OnInitEmoji(go,lineIndex,wrapIndex,realIndex)
    local item = (lineIndex == 1) and self._wrap1Items[wrapIndex + 1] or self._wrap2Items[wrapIndex + 1];
    local emojiURL = (lineIndex == 1) and self._packageDataLine1[realIndex + 1] or self._packageDataLine2[realIndex + 1];
    if not emojiURL then return end
    item.url = emojiURL;
    if emojiURL == "" then
        self._uploadingItem = item;
        item.add:SetActive(not self._uploadData.uploading);
        if not self._uploadData.uploading then 
            item.icon.mainTexture = nil; 
        else
            self:LoadCustomImage(item.icon,self._uploadData.localPath,self._emojiSingleSize,false);
        end
    else
        item.add:SetActive(false);
        self:LoadCustomImage(item.icon,item.url,self._emojiSingleSize,true);
    end
end

function ChatCommonEmojiCustom:InitPackage()
    self._packageIndex = 2;
    self._packageDatas = {};
    self._packageDataLine1 = {};
    self._packageDataLine2 = {};
    self._wrap1:ResetWrapContent(#self._packageDataLine1,self._wrapCall1);
    self._wrap2:ResetWrapContent(#self._packageDataLine2,self._wrapCall2);
    self._wrap3:ResetWrapContent(#self._packageDatas,self._wrapCall3);
end

function ChatCommonEmojiCustom:SwitchPackage(packageIndex,forceSwitch)
    if (forceSwitch or packageIndex ~= self._packageIndex) and (packageIndex >= 2 and packageIndex <= #self._packageDatas) then
        self._packageIndex = packageIndex;
        self._packageDataLine1 = {};
        self._packageDataLine2 = {};
        local needAddIcon = self._packageIndex == 2;
        if needAddIcon then table.insert(self._packageDataLine1,""); end
        local packageData = self._packageDatas[self._packageIndex];
        local tmpIndex = needAddIcon and 2 or 1;
        for i = 1,#packageData.emojis do
            if tmpIndex <= self._wrapCount then
                table.insert(self._packageDataLine1,packageData.emojis[i]);
            else
                table.insert(self._packageDataLine2,packageData.emojis[i]);
            end
            tmpIndex = tmpIndex + 1;
            if tmpIndex > self._wrapCount * 2 then tmpIndex = 1 end
        end
        self._wrap1:ResetWrapContent(#self._packageDataLine1,self._wrapCall1);
        self._wrap2:ResetWrapContent(#self._packageDataLine2,self._wrapCall2);
    end
end

function ChatCommonEmojiCustom:OnEnable()
    TouchMgr.SetListenOnNGUIEvent(self,true,true);
    self._getEmojiPackageEvent = MessageSub.Register(GameConfig.SUB_G_CHAT,GameConfig.SUB_U_CHAT_EMOJI_PACKAGE_GET,self.OnGetEmojiPackage,self);
    self._uploadData = ChatMgr.GetUploadData();
    self:InitPackage();
    ChatMgr.RequestGetEmojiDatas();
end

function ChatCommonEmojiCustom:OnUpdate()
    if self._uploadData.uploading and self._uploadData.uploadFile and self._uploadingItem then
        if not self._addState.state then
            self._addState.state = true;
            self._addState.transform.parent = self._uploadingItem.transform;
            self._addState.transform.localPosition = Vector3.zero;
            self._addState.gameObject:SetActive(true);
        end
        self._addState.slider.value = self._uploadData.progress();
    end
end

function ChatCommonEmojiCustom:OnDisable()
    TouchMgr.SetListenOnNGUIEvent(self,false);
    MessageSub.UnRegister(GameConfig.SUB_G_CHAT,GameConfig.SUB_U_CHAT_EMOJI_PACKAGE_GET,self._getEmojiPackageEvent);
end

function ChatCommonEmojiCustom:OnClickScreen(clickPos)
    if not self._addEmojiObj then return end
    if self._addEmojiCameraObj == UICamera.currentTouch.last then return end
    if self._addEmojiPhotoObj == UICamera.currentTouch.last then return end
    if self._addEmojiPackageObj == UICamera.currentTouch.last then return end
    if self._addEmojiBgObj == UICamera.currentTouch.last then return end
    self._addEmojiObj:SetActive(false);
end

function ChatCommonEmojiCustom:OnClick(id)
    if id > self._eventOffset1 and id <= self._eventOffset2 then
        --表情包内部表情第一行
        local wrapIndex = id - self._eventOffset1;
        local wrapItem = self._wrap1Items[wrapIndex];
        if wrapItem.url == "" then
            if not self._uploadData.uploading then self._addEmojiObj:SetActive(true); end
        else
            return Chat_pb.ChatMsgLink.EMOJI_CUSTOM,wrapItem.url;
        end
    elseif id > self._eventOffset2 and id <= self._eventOffset3 then
        --表情包内部表情第二行      
        local wrapIndex = id - self._eventOffset2;
        local wrapItem = self._wrap2Items[wrapIndex];
        return Chat_pb.ChatMsgLink.EMOJI_CUSTOM,wrapItem.url;
    elseif id > self._eventOffset3 and id < self._eventOffset4 then
        --表情包列表
        local wrapIndex = id - self._eventOffset3;
        local wrapItem = self._wrap3Items[wrapIndex];
        if wrapItem.realIndex == 1 then
            --打开表情站
            UIMgr.ShowUI(AllUI.UI_Chat_EmojiPackage);
        else
            --切换表情包
            self:SwitchPackage(wrapItem.realIndex);
        end
    elseif id == 2500 then
        --打开相册选择图片上传
        self._addEmojiObj:SetActive(false);
        PhotoMgr.OpenPhotoLibrary(self._emojiTakeSize.compressRatio,self._emojiTakeSize.width,self._emojiTakeSize.height,self.OnTakePhoto,self);
    elseif id == 2501 then
        --打开相机拍摄图片上传
        self._addEmojiObj:SetActive(false);
        PhotoMgr.OpenCamera(self._emojiTakeSize.compressRatio,self._emojiTakeSize.width,self._emojiTakeSize.height,self.OnTakePhoto,self)
    elseif id == 2502 then
        --打开我的表情站
        self._addEmojiObj:SetActive(false);
        UIMgr.ShowUI(AllUI.UI_Chat_EmojiCustom);
    end
end

function ChatCommonEmojiCustom:OnTakePhoto(relativePath)
    PhotoMgr.MakeClipImage(relativePath,self._emojiSingleSize.compressRatio,self._emojiSingleSize.width,self._emojiSingleSize.height,self.OnMakeClip,self)
end

function ChatCommonEmojiCustom:OnMakeClip(srcPath,dstPath)
    ChatMgr.RequestAddEmoji(srcPath,self.OnUpload,self);
end

function ChatCommonEmojiCustom:OnUpload(successFlag)
    self._addState.gameObject:SetActive(false);
    self._addState.state = false;
    if self._packageIndex == 2 then self:SwitchPackage(self._packageIndex,true); end
end

function ChatCommonEmojiCustom:OnGetEmojiPackage()
    local allPackages = ChatMgr.GetAllEmojiPackageDatas();
    self._packageDatas = {{}};
    for i = 1,#allPackages do
        self._packageDatas[i + 1] = allPackages[i];
    end
    self:SwitchPackage(self._packageIndex,true);
    self._wrap3:ResetWrapContent(#self._packageDatas,self._wrapCall3);
end