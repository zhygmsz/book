Shader "CookbookShaders/Chapter04/NormalMappedReflection" 
{
	Properties 
	{
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_Cubemap ("Cubemap", CUBE) = ""{}
		_ReflAmount ("Reflection Amount", Range(0,1)) = 0.5
	}
	
	SubShader
	 {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		samplerCUBE _Cubemap;
		sampler2D _MainTex;
		sampler2D _NormalMap;
		float4 _MainTint;
		float _ReflAmount;

		struct Input 
		{
			float2 uv_MainTex;
			float2 uv_NormalMap;
			float3 worldRefl;
			INTERNAL_DATA
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			
			float3 normals = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap)).rgb;
			o.Normal = normals;
			
			o.Emission = texCUBE (_Cubemap, WorldReflectionVector (IN, o.Normal)).rgb * _ReflAmount;
			o.Albedo = c.rgb * _MainTint;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
