module("CameraLayer",package.seeall);

local layers = {};
--------------------------------------------层级 定义顺序与UNITY保持一致---------------------------------------------
-------------------------------------------------UNITY默认层级------------------------------------------------------
DefaultName = "Default";
DefaultLayer = LayerMask.NameToLayer(DefaultName);

TransparentFXName = "TransparentFX";
TransparentFXLayer = LayerMask.NameToLayer(TransparentFXName);

IgnoreRaycastName = "Ignore Raycast";
IgnoreRaycastLayer = LayerMask.NameToLayer(IgnoreRaycastName);

WaterName = "Water";
WaterLayer = LayerMask.NameToLayer(WaterName);

UILayerName = "UI";
UILayer = LayerMask.NameToLayer(UILayerName);
---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------美术效果层级---------------------------------------------------------
--天空盒
SkyName = "Sky";
SkyLayer = LayerMask.NameToLayer(SkyName);
--特效
EffectName = "Effect";
EffectLayer = LayerMask.NameToLayer(EffectName);
--场景
SceneMaskName = "SceneMask";
SceneMaskLayer = LayerMask.NameToLayer(SceneMaskName);
--PBR
PBRName = "PBR";
PBRLayer = LayerMask.NameToLayer(PBRName);
--树
TreeName = "Tree";
TreeLayer = LayerMask.NameToLayer(TreeName);
--墙
WallName = "Wall";
WallLayer = LayerMask.NameToLayer(WallName);
--地面
SurfaceName = "Surface";
SurfaceLayer = LayerMask.NameToLayer(SurfaceName);
---------------------------------------------------------------------------------------------------------------------

-------------------------------------------------程序逻辑层级---------------------------------------------------------
--触发器
TriggerName = "Trigger";
TriggerLayer = LayerMask.NameToLayer(TriggerName);
--实体
EntityName = "Entity";
EntityLayer = LayerMask.NameToLayer(EntityName);
--主角
PlayerName = "Player";
PlayerLayer = LayerMask.NameToLayer(PlayerName);
--RenderTexture
RenderTextureName = "RenderTexture";
RenderTextureLayer = LayerMask.NameToLayer(RenderTextureName);
--剧情
SequenceName = "Sequence";
SequenceLayer = LayerMask.NameToLayer(SequenceName);
--分享
ShareLayerName = "ShareLayer";
ShareLayer = LayerMask.NameToLayer(ShareLayerName);

AIPetName = "AIPet";
AIPetLayer = LayerMask.NameToLayer(AIPetName);

-------------------------------------------------摄像机和射线碰撞MASK---------------------------------------------------------
--主摄像机层级
MainMaskLayer = -1 - LayerMask.GetMask(ShareLayerName,SequenceName,RenderTextureName,TriggerName,UILayerName);

--可移动层级
CanMoveLayer = LayerMask.GetMask(SurfaceName);

--渲染RenderTexture
RenderTextureMaskLayer =  LayerMask.GetMask(RenderTextureName);

--阴影产生层级
ShadowCasterMaskLayer = LayerMask.GetMask(PlayerName,EntityName);

--不接受阴影层级
IgnoreShadowLayer = -1 - LayerMask.GetMask(SurfaceName);

--摄像机碰撞后拉近层级
CameraHitDistanceMaskLayer = LayerMask.GetMask(SurfaceName,WallName);

--摄像机碰撞后隐藏层级
CameraHitHideMaskLayer = LayerMask.GetMask(TreeName);

--摄像机碰撞后半透层级
CameraHitAlphaMaskLayer = LayerMask.GetMask(TreeName);
------------------------------------------------------------------------------------------------------------------------------