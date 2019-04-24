Shader "CookbookShaders/Chapter03/BlinnPhong" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_SpecPower ("Specular Power", Range(0,1)) = 0.5
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf BlinnPhong

		sampler2D _MainTex;
		float _SpecPower;
		float4 _MainTint;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
			o.Specular = _SpecPower;
			o.Gloss = c.r;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
