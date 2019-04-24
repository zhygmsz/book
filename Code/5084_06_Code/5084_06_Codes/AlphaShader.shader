Shader "Cookbook/Chapter06/SimpleAlpha" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_TransVal ("Transparency Value", Range(0,1)) = 0.5
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque"}
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert alpha

		sampler2D _MainTex;
		float _TransVal;

		struct Input 
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			
			o.Albedo = c.rgb;
			o.Alpha = c.b * _TransVal;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
