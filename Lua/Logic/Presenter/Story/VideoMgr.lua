module("VideoMgr",package.seeall)

--播放器对象
local mVideoPlayer = nil
--回调函数对象
local mSeekCallFunc = nil
local mPrepareCallFunc = nil
local mFinishCallFunc = nil
local mVideoLoadedCallFunc = nil
local mVideoStartedCallFunc =nil
--缓存的主相机
local TempMainCamera=nil
--资源列表
local mCacheTabel={}
--当前视频资源名
local mCurrentName=nil
local mTextureLoader = nil
local mRenderTexture = nil
--模块初始化
function InitModule()
    require("Logic/Presenter/UI/Story/UI_VideoPlayer");
    InitPlayer()
end

--==============================--
--desc:私有函数区域
--==============================---

--视频系统回调函数
function VideoPrepareFinished(VideoPlayer)
    SetTime(0)
    if mVideoPlayer:GetRenderMode()==2 then 
        UI_VideoPlayer.SetRenderTexture(mVideoPlayer:GetRenderTexture())
        if mVideoPlayer:GetRenderTexture()==nil then Skip() end
        if mPrepareCallFunc then mPrepareCallFunc() end
    end
end

function OnError(VideoPlayer)
    if mVideoPlayer:GetRenderMode()==2 then 
        GameVideoPlayer.Instance():SetRenderTexture(nil)
        UI_VideoPlayer.CleanScreen()
        UIMgr.UnShowUI(AllUI.UI_VideoPlayer)
        if mFinishCallFunc then mFinishCallFunc() end
        SetClip(nil)
        mCurrentName=nil
        EnableMainCamera(true)
        CleanAssetCache()
    end
end

--结束回调 关闭UI
function VideoFinished(VideoPlayer)
    if mVideoPlayer:GetRenderMode()==2 then 
        GameVideoPlayer.Instance():SetRenderTexture(nil)
        UI_VideoPlayer.CleanScreen()
        UIMgr.UnShowUI(AllUI.UI_VideoPlayer)
        if mFinishCallFunc then mFinishCallFunc() end
        SetClip(nil)
        mCurrentName=nil
        EnableMainCamera(true)
        CleanAssetCache()
    end
end
--设置时间回调
function VideoSeekFinished(VideoPlayer)
    if mVideoPlayer:GetRenderMode()==2 then 
        if mSeekCallFunc then 
            mSeekCallFunc()
        end
    end
end
--开始播放回调
function VideoStartedFinished(VideoPlayer)
    if mVideoPlayer:GetRenderMode()==2 then 
        EnableMainCamera(false)
        if mVideoStartedCallFunc then 
            mVideoStartedCallFunc()
        end
    end
end

function GetTexture()
    local function OnLoadTexture(loader)
        local tex = loader:GetObject()
        mRenderTexture=tex
    end
    if not mTextureLoader then mTextureLoader = LoaderMgr.CreateTextureLoader(); end
    mTextureLoader:LoadObject(GameAsset.RenderTexture,OnLoadTexture);
end

--初始化播放器
function InitPlayer()
    GameVideoPlayer.Instance():Init();
   -- GameVideoPlayer.Instance():SetClipMode();
    GameVideoPlayer.Instance():SetLuaCallBack(VideoPrepareFinished,VideoFinished,VideoSeekFinished,VideoStartedFinished)
    GameVideoPlayer.Instance():SetRenderTextureModeAutoTexture(5)--(UIMgr.GetCamera(), false, 1, 2);
    GameVideoPlayer.Instance():SetRenderTextureSize(1024,1024,16)
    GameVideoPlayer.Instance():SetSkipOnDrop(true)
    GameVideoPlayer.Instance():SetLuaOnError(OnError)
    mVideoPlayer = GameVideoPlayer.Instance()
end

--设置渲染尺寸
function SetRenderTextureSize(w,h,d)
    mVideoPlayer:SetRenderTextureSize(w,h,d)
end

--设置视频源
function SetClip(videoClip)
    mVideoPlayer:SetClip(videoClip);
end

function GetClip()
    return mVideoPlayer:GetClip()
end

function EnableMainCamera(enable)
    CameraMgr.EnableMainCamera(enable)
end

--资源加载完毕
function EndLoadVideo(loader)
    local videoClip = loader:GetObject()
    local videoResName = loader:GetResID()
    if videoClip then
        AddCacheToTable(videoResName,videoClip)
    end
    GameLog.Log("EndLoadVideo , videoClip = %s", videoClip)
    SetClip(videoClip)
    if mVideoLoadedCallFunc then
        GameLog.Log("mVideoLoadedCallFunc")
        mVideoLoadedCallFunc(videoClip)
    end
end

--直接加载视频资源
function LoadClipFromAssetBundle(videoResName)
    if mCacheTabel[videoResName]==nil then
        mCacheTabel[videoResName]={}
    end
    if mCacheTabel[videoResName].loader==nil then
        mCacheTabel[videoResName].loader = LoaderMgr.CreateAssetLoader();
    end
    mCacheTabel[videoResName].loader:LoadObject(videoResName,EndLoadVideo);
end

function LoadVideo()
    LoadClipFromAssetBundle(mCurrentName)
end

--==============================--
--desc:公共函数区域
--==============================--
--自动区分情况 播放函数
function PlayVideo(videoResName)
    -- if mCacheTabel[videoResName]==nil then
    --     LoadAndPlayVideo(videoResName)
    -- else
    --     local clipObj = mCacheTabel[videoResName].clip or mCacheTabel[videoResName].loader:GetObject()
    --     PlayVideoWithClip(videoResName,clipObj)
    -- end
    PlayVideoWithURL(videoResName)
end

--传入URL 自动播放
function PlayVideoWithURL(name)
    mCurrentName=name
    if SystemInfo.IsEditor() then 
        local url = string.format("Res/Video/%s.mp4",name)
        GameVideoPlayer.Instance():SetUrlMode(url,false)
    else
        local videoname = string.lower(string.format("%s.mp4",name))
        local url = GameCore.ResMgr.Instance:GetCustomFilePath(videoname);--"bundles/video_jianningzhanshi.mp4"
        GameVideoPlayer.Instance():SetUrlMode(url,true)
    end
    mVideoLoadedCallFunc = Play
    UI_VideoPlayer.SetUICompleted(Play)
    UIMgr.ShowUI(AllUI.UI_VideoPlayer)
end

--加载完自动播放
function LoadAndPlayVideo(videoResName)
    mCurrentName=videoResName
    UI_VideoPlayer.SetUICompleted(LoadVideo)
    mVideoLoadedCallFunc = Play
    UIMgr.ShowUI(AllUI.UI_VideoPlayer)
end

--传入视频文件 自动播放
function PlayVideoWithClip(name,clipObj)
    mCurrentName=name
    mVideoLoadedCallFunc = Play
    AddCacheToTable(name,clipObj)
    SetClip(clipObj)
    UI_VideoPlayer.SetUICompleted(Play)
    UIMgr.ShowUI(AllUI.UI_VideoPlayer)
end

--设置用户操作回调 分别对应时机为 视频文件准备完毕 视频结束 调到某个时间点 视频加载完毕 视频开始播放
function SetLuaCallBack(videoPrepareFinished,videoFinished,videoSeekFinished,videoLoaded,videoStarted)
    mPrepareCallFunc = videoPrepareFinished
    mFinishCallFunc = videoFinished
    mSeekCallFunc = videoSeekFinished
    mVideoLoadedCallFunc = videoLoaded
    mVideoStartedCallFunc = videoStarted
end

--设置播放模式 默认是 1-全屏跳过 2--播放器模式 3--跳过按钮跳过 4--全屏不可跳过
function SetMode(model)
    UI_VideoPlayer.SetMode(model)
end

--设置UI的跳过数据
function SetSkipShow(skip,askTip,tipText)
    UI_VideoPlayer.SetSkipShow(skip,askTip,tipText)
end

--获取视频长度
function Duration()
    return mVideoPlayer:Duration()
end
--设置视频时间
function SetTime(t)
    mVideoPlayer:SetTime(t);
end

--当前播放时间
function RunningTime()
   return mVideoPlayer:GetTime();
end

--设置视频的渲染相机
function SetCamera(camera)
    mVideoPlayer:SetCamera(camera);
end

--播放
function Play()
    -- if tolua.isnull(GetClip()) then
    --     GameLog.Log("SkipVideo ")
    --     Skip()
    -- else
    --     GameLog.Log("PlayVideo ")
    --     mVideoPlayer:Play()
    -- end
    GameLog.Log("PlayVideo ")
    mVideoPlayer:Play()
end

--跳过
function Skip()
    EnableMainCamera(true)
    mVideoPlayer:Skip()
end

--暂停
function Pause()
    mVideoPlayer:Pause()
end

--停止
function Stop()
    EnableMainCamera(true)
    TempMainCamera=nil
    mVideoPlayer:Stop()
end

--准备
function Prepare()
    mVideoPlayer:Prepare()
end

--设置音量
function SetVolume(vol)
    mVideoPlayer:SetVolume(vol)
end

--加载资源名到内存记录表
function AddCacheToTable(name,clip)
    if mCacheTabel[name]==nil then
        mCacheTabel[name]={}
        mCacheTabel[name].clip = clip
    else
        mCacheTabel[name].clip = clip
	end
end

--清内存
function CleanAssetCache()
    for name,obj in pairs(mCacheTabel) do
        LoaderMgr.DeleteLoader(obj.loader)
    end
    mCacheTabel = {}
end

return VideoMgr