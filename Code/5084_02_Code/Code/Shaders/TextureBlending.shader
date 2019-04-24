Shader "CookbookShaders/Chapter02/TextureBlending" 
{
	Properties 
	{
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		
		//Add the properties below so we can input all of our textures
		_ColorA ("Terrain Color A", Color) = (1,1,1,1)
		_ColorB ("Terrain Color B", Color) = (1,1,1,1)
		_RTexture ("Red Channel Texture", 2D) = ""{}
		_GTexture ("Green Channel Texture", 2D) = ""{}
		_BTexture ("Blue Channel Texture", 2D) = ""{}
		_ATexture ("Alpha Channel Texture", 2D) = ""{}
		_BlendTex ("Blend Texture", 2D) = ""{}
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		float4 _MainTint;
		float4 _ColorA;
		float4 _ColorB;
		sampler2D _RTexture;
		sampler2D _GTexture;
		sampler2D _BTexture;
		sampler2D _BlendTex;
		sampler2D _ATexture;

		struct Input 
		{
			float2 uv_RTexture;
			float2 uv_GTexture;
			float2 uv_BTexture;
			float2 uv_ATexture;
			float2 uv_BlendTex;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			//Get the pixel data from the blend texture
			//we need a float 4 here because the texture 
			//will return R,G,B,and A or X,Y,Z, and W
			float4 blendData = tex2D(_BlendTex, IN.uv_BlendTex);
			
			//Get the data from the textures we want to blend
			float4 rTexData = tex2D(_RTexture, IN.uv_RTexture);
			float4 gTexData = tex2D(_GTexture, IN.uv_GTexture);
			float4 bTexData = tex2D(_BTexture, IN.uv_BTexture);
			float4 aTexData = tex2D(_ATexture, IN.uv_ATexture);
			
			//No we need to contruct a new RGBA value and add all 
			//the different blended texture back together
			float4 finalColor;
			finalColor = lerp(rTexData, gTexData, blendData.g);
			finalColor = lerp(finalColor, bTexData, blendData.b);
			finalColor = lerp(finalColor, aTexData, blendData.a);
			finalColor.a = 1.0;
			
			//Add on our terrain tinting colors
			float4 terrainLayers = lerp(_ColorA, _ColorB, blendData.r);
			finalColor *= terrainLayers;
			finalColor = saturate(finalColor);
				
			o.Albedo = finalColor.rgb * _MainTint.rgb;
			o.Alpha = finalColor.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
