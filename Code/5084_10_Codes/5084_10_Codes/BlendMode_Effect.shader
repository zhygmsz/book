Shader "Custom/BlendMode_Effect" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlendTex ("Blend Texture", 2D) = "white"{}
		_Opacity ("Blend Opacity", Range(0,1)) = 1
	}
	
	SubShader 
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;
			uniform sampler2D _BlendTex;
			fixed _Opacity;

			fixed4 frag(v2f_img i) : COLOR
			{
				//Get the colors from the RenderTexture and the uv's
				//from the v2f_img struct
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				fixed4 blendTex = tex2D(_BlendTex, i.uv);
				
				//Perform a multiply Blend mode
				//fixed4 blendedMultiply = renderTex * blendTex;
				//fixed4 blendedAdd = renderTex + blendTex;
				fixed4 blendedScreen = (1.0 - ((1.0 - renderTex) * (1.0 - blendTex)));
				
				//Adjust amount of Blend Mode with a lerp
				renderTex = lerp(renderTex, blendedScreen, _Opacity);
				
				return renderTex;
			}
	
			ENDCG
		}
	} 
	FallBack off
}
