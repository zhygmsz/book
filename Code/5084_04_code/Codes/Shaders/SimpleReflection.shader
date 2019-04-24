Shader "CookbookShaders/Chapter04/SimpleReflection" 
{
	Properties 
	{
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Cubemap ("CubeMap", CUBE) = ""{}
		_ReflAmount ("Reflection Amount", Range(0.01, 1)) = 0.5
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
		samplerCUBE _Cubemap;
		float4 _MainTint;
		float _ReflAmount;

		struct Input 
		{
			float2 uv_MainTex;
			float3 worldRefl;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
			o.Emission = texCUBE(_Cubemap, IN.worldRefl).rgb * _ReflAmount;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
