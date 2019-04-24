Shader "CookbookShaders/Chapter04/FresnelReflection" 
{
	Properties 
	{
		_MainTint("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Cubemap ("Cubemap", CUBE) = ""{}
		_ReflectionAmount ("Reflection Amount", Range(0,1)) = 1
		_RimPower ("Fresnel Falloff", Range(0.1, 8)) = 2
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_SpecPower ("Specular Power", Range(0,1)) = 0.5
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf BlinnPhong
		#pragma target 3.0

		samplerCUBE _Cubemap;
		sampler2D _MainTex;
		float4 _MainTint;
		float _ReflectionAmount;
		float _RimPower;
		float _SpecPower;
		

		struct Input 
		{
			float2 uv_MainTex;
			float3 worldRefl;
			float3 viewDir;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			
			float rim = 1-saturate(dot(o.Normal, normalize(IN.viewDir)));
			rim = pow(rim, _RimPower);
		
			o.Albedo = c.rgb * _MainTint.rgb;
			o.Emission = (texCUBE(_Cubemap, IN.worldRefl).rgb * _ReflectionAmount) * rim;
			o.Specular = _SpecPower;
			o.Gloss = 1.0;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
